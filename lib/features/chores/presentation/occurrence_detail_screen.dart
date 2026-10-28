import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_event.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/repair_status.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_action_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/today_providers.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/presentation/widgets/occurrence_actions_bar.dart';
import 'package:family_hub/features/chores/presentation/widgets/occurrence_header.dart';
import 'package:family_hub/features/chores/presentation/widgets/occurrence_timeline.dart';
import 'package:family_hub/features/chores/presentation/widgets/subtask_checklist.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/shared/widgets/error_view.dart';
import 'package:family_hub/shared/widgets/loading_view.dart';
import 'package:family_hub/shared/widgets/reason_sheet.dart';
import 'package:family_hub/shared/widgets/mini_markdown_view.dart';
import 'package:family_hub/shared/widgets/person_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One chore, in full (P3-15): header, steps, instructions, history and the
/// permission-aware action bar.
///
/// It never writes directly: every button calls a P3-14 use case through its
/// provider and the listeners push the new state back. On open it repairs a
/// stale `status` cache once (D-P3-9) and ignores an offline failure silently —
/// the value a screen shows is derived anyway.
class OccurrenceDetailScreen extends ConsumerStatefulWidget {
  const OccurrenceDetailScreen({required this.occurrenceId, super.key});

  final String occurrenceId;

  @override
  ConsumerState<OccurrenceDetailScreen> createState() =>
      _OccurrenceDetailScreenState();
}

class _OccurrenceDetailScreenState
    extends ConsumerState<OccurrenceDetailScreen> {
  bool _busy = false;
  bool _repaired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _repairOnce());
  }

  /// Self-heal the stored `status` cache once per screen (D-P3-9, C-13).
  Future<void> _repairOnce() async {
    if (_repaired || !mounted) return;
    _repaired = true;
    final document = ref.read(occurrenceProvider(widget.occurrenceId)).value;
    if (document == null || !RepairStatus.needsRepair(document)) return;
    final familyId = ref.read(currentFamilyIdProvider);
    final uid = ref.read(currentUidProvider);
    if (familyId == null || uid == null) return;
    await ref.read(repairStatusProvider)(
      familyId: familyId,
      actorUid: uid,
      occurrenceId: widget.occurrenceId,
    );
  }

  Future<void> _run(Future<Result<Object?>> Function() action) async {
    if (_busy) return;
    final familyId = ref.read(currentFamilyIdProvider);
    final uid = ref.read(currentUidProvider);
    if (familyId == null || uid == null) return;
    setState(() => _busy = true);
    final result = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    final failure = result.failureOrNull;
    if (failure != null) _showFailure(failure);
  }

  void _showFailure(AppFailure failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.choresFailureMessage(failure))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final item = ref.watch(occurrenceItemProvider(widget.occurrenceId));
    final document = ref.watch(occurrenceProvider(widget.occurrenceId));
    final events = ref.watch(occurrenceEventsProvider(widget.occurrenceId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.occurrenceDetailTitle)),
      body: switch ((document, item)) {
        (AsyncLoading(), _) => const LoadingView(),
        (AsyncError(:final error), _) => ErrorView(
          message: context.l10n.choresFailureMessage(
            error is AppFailure ? error : Unknown(error),
          ),
          onRetry: () =>
              ref.invalidate(occurrenceProvider(widget.occurrenceId)),
        ),
        (_, null) => ErrorView(
          message: l10n.choresFailure_not_found,
          onRetry: () =>
              ref.invalidate(occurrenceProvider(widget.occurrenceId)),
        ),
        (AsyncData(value: final ChoreOccurrence? occurrence), _) =>
          occurrence == null
              ? ErrorView(
                  message: l10n.choresFailure_not_found,
                  onRetry: () =>
                      ref.invalidate(occurrenceProvider(widget.occurrenceId)),
                )
              : _body(context, occurrence, events.value ?? const []),
      },
      bottomNavigationBar: item == null
          ? null
          : OccurrenceActionsBar(
              item: item,
              completedBy: document.value?.completedBy,
              busy: _busy,
              onComplete: () => _run(
                () => ref.read(completeOccurrenceProvider)(
                  familyId: ref.read(currentFamilyIdProvider)!,
                  actorUid: ref.read(currentUidProvider)!,
                  occurrenceId: widget.occurrenceId,
                ),
              ),
              onUndo: () => _run(
                () => ref.read(uncompleteOccurrenceProvider)(
                  familyId: ref.read(currentFamilyIdProvider)!,
                  actorUid: ref.read(currentUidProvider)!,
                  occurrenceId: widget.occurrenceId,
                ),
              ),
              onVerify: () => _run(
                () => ref.read(verifyOccurrenceProvider)(
                  familyId: ref.read(currentFamilyIdProvider)!,
                  actorUid: ref.read(currentUidProvider)!,
                  occurrenceId: widget.occurrenceId,
                ),
              ),
              onReopen: _reopen,
              onReassign: _reassign,
              onSkip: _skip,
              onUnskip: () => _run(
                () => ref.read(unskipOccurrenceProvider)(
                  familyId: ref.read(currentFamilyIdProvider)!,
                  actorUid: ref.read(currentUidProvider)!,
                  occurrenceId: widget.occurrenceId,
                ),
              ),
              onException: _exception,
              onSwap: null,
            ),
    );
  }

  Widget _body(
    BuildContext context,
    ChoreOccurrence occurrence,
    List<OccurrenceEvent> events,
  ) {
    final t = context.tokens;
    final formatters = ref.watch(appFormattersProvider);
    final item = ref.watch(occurrenceItemProvider(widget.occurrenceId))!;
    final today = ref.watch(familyDateKeysProvider).today();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OccurrenceHeader(item: item, formatters: formatters, today: today),
        const SizedBox(height: 20),
        SubtaskChecklist(
          item: item,
          occurrence: occurrence,
          formatters: formatters,
          busy: _busy,
          onToggleParent: () => _run(
            () => ref.read(toggleParentProvider)(
              familyId: ref.read(currentFamilyIdProvider)!,
              actorUid: ref.read(currentUidProvider)!,
              occurrenceId: widget.occurrenceId,
            ),
          ),
          onToggleSubtask: (id) => _run(
            () => ref.read(toggleSubtaskProvider)(
              familyId: ref.read(currentFamilyIdProvider)!,
              actorUid: ref.read(currentUidProvider)!,
              occurrenceId: widget.occurrenceId,
              subtaskId: id,
            ),
          ),
        ),
        if (occurrence.instructions.trim().isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            context.l10n.occurrenceInstructionsTitle,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: t.textPrimary),
          ),
          const SizedBox(height: 8),
          MiniMarkdownView(markdown: occurrence.instructions),
        ],
        const SizedBox(height: 20),
        OccurrenceTimeline(events: events, formatters: formatters),
      ],
    );
  }

  Future<void> _reopen() async {
    final reason = await showReasonSheet(
      context,
      title: context.l10n.occurrenceReopenTitle,
    );
    if (reason == null || !mounted) return;
    await _run(
      () => ref.read(reopenOccurrenceProvider)(
        familyId: ref.read(currentFamilyIdProvider)!,
        actorUid: ref.read(currentUidProvider)!,
        occurrenceId: widget.occurrenceId,
        reason: reason,
      ),
    );
  }

  Future<void> _reassign() async {
    final members = ref.read(membersProvider).value ?? const [];
    final chosen = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.occurrenceReassignTitle),
        content: PersonPicker(
          label: context.l10n.occurrenceReassignTitle,
          options: <PersonOption>[
            for (final member in members)
              if (member.isActive)
                PersonOption(
                  id: member.uid,
                  name: member.displayName,
                  avatarKey: member.avatarKey,
                ),
          ],
          selectedId: null,
          onChanged: (id) {
            if (id != null) Navigator.of(dialogContext).pop(id);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.actionCancel),
          ),
        ],
      ),
    );
    if (chosen == null || !mounted) return;
    final reason = await showReasonSheet(
      context,
      title: context.l10n.occurrenceReassignReasonTitle,
    );
    if (reason == null || !mounted) return;
    await _run(
      () => ref.read(reassignOccurrenceProvider)(
        familyId: ref.read(currentFamilyIdProvider)!,
        actorUid: ref.read(currentUidProvider)!,
        occurrenceId: widget.occurrenceId,
        toMemberId: chosen,
        reason: reason,
      ),
    );
  }

  Future<void> _skip() async {
    final reason = await showReasonSheet(
      context,
      title: context.l10n.occurrenceSkipTitle,
    );
    if (reason == null || !mounted) return;
    await _run(
      () => ref.read(skipOccurrenceProvider)(
        familyId: ref.read(currentFamilyIdProvider)!,
        actorUid: ref.read(currentUidProvider)!,
        occurrenceId: widget.occurrenceId,
        reason: reason,
      ),
    );
  }

  Future<void> _exception() async {
    final note = await showReasonSheet(
      context,
      title: context.l10n.occurrenceExceptionTitle,
    );
    if (note == null || !mounted) return;
    await _run(
      () => ref.read(recordCompletionExceptionProvider)(
        familyId: ref.read(currentFamilyIdProvider)!,
        actorUid: ref.read(currentUidProvider)!,
        occurrenceId: widget.occurrenceId,
        note: note,
      ),
    );
  }
}
