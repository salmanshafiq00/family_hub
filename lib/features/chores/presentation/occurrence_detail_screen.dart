import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/repair_status.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_action_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/today_providers.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/presentation/occurrence_action_sheets.dart';
import 'package:family_hub/features/chores/presentation/widgets/occurrence_actions_bar.dart';
import 'package:family_hub/features/chores/presentation/widgets/occurrence_detail_body.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/shared/widgets/error_view.dart';
import 'package:family_hub/shared/widgets/loading_view.dart';
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

/// Signed-in family + user, read once per tap (R0-4): no `!` on a session that
/// may have ended mid-gesture.
typedef _Session = ({String familyId, String uid});

class _OccurrenceDetailScreenState
    extends ConsumerState<OccurrenceDetailScreen> {
  bool _busy = false;
  bool _repaired = false;

  String get _id => widget.occurrenceId;

  _Session? _session() {
    final familyId = ref.read(currentFamilyIdProvider);
    final uid = ref.read(currentUidProvider);
    if (familyId == null || uid == null) return null;
    return (familyId: familyId, uid: uid);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _repairOnce());
  }

  /// Self-heal the stored `status` cache once per screen (D-P3-9, C-13).
  Future<void> _repairOnce() async {
    if (_repaired || !mounted) return;
    _repaired = true;
    final document = ref.read(occurrenceProvider(_id)).value;
    if (document == null || !RepairStatus.needsRepair(document)) return;
    final session = _session();
    if (session == null) return;
    await ref.read(repairStatusProvider)(
      familyId: session.familyId,
      actorUid: session.uid,
      occurrenceId: _id,
    );
  }

  /// Runs a use case with the current session; a `null` result means the
  /// person cancelled a sheet, so nothing is shown.
  Future<void> _run(
    Future<Result<Object?>?> Function(_Session session) action,
  ) async {
    if (_busy) return;
    final session = _session();
    if (session == null) return;
    setState(() => _busy = true);
    final result = await action(session);
    if (!mounted) return;
    setState(() => _busy = false);
    final failure = result?.failureOrNull;
    if (failure != null) _showFailure(failure);
  }

  void _showFailure(AppFailure failure) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.choresFailureMessage(failure))),
    );
  }

  void _retry() => ref.invalidate(occurrenceProvider(_id));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final item = ref.watch(occurrenceItemProvider(_id));
    final document = ref.watch(occurrenceProvider(_id));
    final events = ref.watch(occurrenceEventsProvider(_id));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.occurrenceDetailTitle)),
      body: switch ((document, item)) {
        (AsyncLoading(), _) => const LoadingView(),
        (AsyncError(:final error), _) => ErrorView(
          message: l10n.choresFailureMessage(
            error is AppFailure ? error : Unknown(error),
          ),
          onRetry: _retry,
        ),
        (_, null) => ErrorView(
          message: l10n.choresFailure_not_found,
          onRetry: _retry,
        ),
        (AsyncData(value: final ChoreOccurrence? occurrence), final found?) =>
          occurrence == null
              ? ErrorView(
                  message: l10n.choresFailure_not_found,
                  onRetry: _retry,
                )
              : OccurrenceDetailBody(
                  item: found,
                  occurrence: occurrence,
                  events: events.value ?? const [],
                  formatters: ref.watch(appFormattersProvider),
                  today: ref.watch(familyDateKeysProvider).today(),
                  busy: _busy,
                  onToggleParent: () => _run(
                    (s) => ref.read(toggleParentProvider)(
                      familyId: s.familyId,
                      actorUid: s.uid,
                      occurrenceId: _id,
                    ),
                  ),
                  onToggleSubtask: (subtaskId) => _run(
                    (s) => ref.read(toggleSubtaskProvider)(
                      familyId: s.familyId,
                      actorUid: s.uid,
                      occurrenceId: _id,
                      subtaskId: subtaskId,
                    ),
                  ),
                ),
      },
      bottomNavigationBar: item == null
          ? null
          : OccurrenceActionsBar(
              item: item,
              completedBy: document.value?.completedBy,
              busy: _busy,
              onComplete: () => _run(
                (s) => ref.read(completeOccurrenceProvider)(
                  familyId: s.familyId,
                  actorUid: s.uid,
                  occurrenceId: _id,
                ),
              ),
              onUndo: () => _run(
                (s) => ref.read(uncompleteOccurrenceProvider)(
                  familyId: s.familyId,
                  actorUid: s.uid,
                  occurrenceId: _id,
                ),
              ),
              onVerify: () => _run(
                (s) => ref.read(verifyOccurrenceProvider)(
                  familyId: s.familyId,
                  actorUid: s.uid,
                  occurrenceId: _id,
                ),
              ),
              onReopen: () =>
                  _run((_) => ref.reopenWithSheet(context, occurrenceId: _id)),
              onReassign: () => _run(
                (_) => ref.reassignWithSheets(context, occurrenceId: _id),
              ),
              onSkip: () =>
                  _run((_) => ref.skipWithSheet(context, occurrenceId: _id)),
              onUnskip: () => _run(
                (s) => ref.read(unskipOccurrenceProvider)(
                  familyId: s.familyId,
                  actorUid: s.uid,
                  occurrenceId: _id,
                ),
              ),
              onException: () => _run(
                (_) => ref.exceptionWithSheet(context, occurrenceId: _id),
              ),
              onSwap: null,
            ),
    );
  }
}
