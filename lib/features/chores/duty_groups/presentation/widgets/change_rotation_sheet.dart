import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_builder.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_change_request.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_engine.dart';
import 'package:family_hub/features/chores/duty_groups/domain/usecases/change_rotation.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_labels.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/widgets/change_rotation_fields.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/widgets/rota_preview.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/shared/widgets/choice_wrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Asks which change to make to [group]'s rotation, and from when. Returns the
/// request, or `null` when the manager cancels (P3-18).
Future<RotationChangeRequest?> showChangeRotationSheet(
  BuildContext context, {
  required DutyGroup group,
}) => showModalBottomSheet<RotationChangeRequest>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (context) => ChangeRotationSheet(group: group),
);

/// The sheet behind [showChangeRotationSheet].
///
/// It shows the rotation AFTER the change, built by the same
/// `RotationBuilder` call the use case makes, so "nothing before this date
/// changes" is something the manager can see before saving.
class ChangeRotationSheet extends ConsumerStatefulWidget {
  const ChangeRotationSheet({required this.group, super.key});

  final DutyGroup group;

  @override
  ConsumerState<ChangeRotationSheet> createState() =>
      _ChangeRotationSheetState();
}

class _ChangeRotationSheetState extends ConsumerState<ChangeRotationSheet> {
  RotationChange _mode = RotationChange.add;
  String? _memberId;
  late List<String> _order = List<String>.of(widget.group.members);
  String? _startsWith;
  DateKey? _effectiveFrom;

  DateKey _today() => ref.read(familyDateKeysProvider).today();

  /// The default: the next cycle boundary on or after today.
  DateKey _defaultFrom() {
    final today = _today();
    final version = RotationEngine.versionFor(widget.group.rotation, today);
    return version == null
        ? today
        : RotationBuilder.nextBoundary(version, today);
  }

  RotationChangeRequest _request() => RotationChangeRequest(
    change: _mode,
    effectiveFrom: _effectiveFrom ?? _defaultFrom(),
    memberId: _memberId,
    members: _order,
    startsWith: _startsWith ?? (_order.isEmpty ? null : _order.first),
  );

  void _setMode(RotationChange mode) => setState(() {
    _mode = mode;
    _memberId = null;
    _order = List<String>.of(widget.group.members);
    _startsWith = null;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final formatters = ref.watch(appFormattersProvider);
    final templates = ref.watch(dutyGroupTemplatesProvider(widget.group.id));
    final recurrence = templates.isEmpty
        ? null
        : templates.first.draft.recurrence;

    final request = _request();
    final result = request.preview(
      widget.group.rotation,
      recurrence: recurrence,
    );
    final candidate = result.valueOrNull;
    final failure = result.failureOrNull;
    final needsMember =
        _mode != RotationChange.reorder && (_memberId ?? '').isEmpty;
    final boundary = candidate?.versions.last.from;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dutyChangeTitle,
              style: textTheme.titleLarge?.copyWith(color: t.textPrimary),
            ),
            const SizedBox(height: 12),
            ChoiceWrap<RotationChange>(
              options: [
                ChoiceOption<RotationChange>(
                  RotationChange.add,
                  l10n.dutyChangeAdd,
                  key: const ValueKey<String>('mode_add'),
                ),
                ChoiceOption<RotationChange>(
                  RotationChange.remove,
                  l10n.dutyChangeRemove,
                  key: const ValueKey<String>('mode_remove'),
                ),
                ChoiceOption<RotationChange>(
                  RotationChange.reorder,
                  l10n.dutyChangeReorder,
                  key: const ValueKey<String>('mode_reorder'),
                ),
              ],
              selected: _mode,
              onChanged: _setMode,
            ),
            const SizedBox(height: 16),
            ChangeRotationFields(
              mode: _mode,
              members: widget.group.members,
              memberId: _memberId,
              order: _order,
              startsWith: _startsWith,
              onMember: (id) => setState(() => _memberId = id),
              onOrder: (order) => setState(() => _order = order),
              onStartsWith: (id) => setState(() => _startsWith = id),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.dutyChangeFrom,
              style: textTheme.labelLarge?.copyWith(color: t.textSecondary),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton.icon(
                key: const ValueKey<String>('change_from'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                ),
                onPressed: _pickDate,
                icon: const Icon(Icons.event_outlined),
                label: Text(
                  formatters.fullDate(dateOfKey(request.effectiveFrom)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (failure != null && !needsMember)
              Text(
                l10n.choresFailureMessage(failure),
                style: textTheme.bodyMedium?.copyWith(color: t.danger),
              )
            else if (boundary != null && !needsMember) ...[
              Text(
                l10n.dutyChangeNothingBefore(
                  formatters.fullDate(dateOfKey(boundary)),
                ),
                style: textTheme.bodyMedium?.copyWith(color: t.textSecondary),
              ),
              const SizedBox(height: 16),
              RotaPreviewView(
                rotation: candidate!,
                title: l10n.dutyChangeAfter,
                recurrence: recurrence,
              ),
            ] else
              Text(
                l10n.dutyChangePickMember,
                style: textTheme.bodyMedium?.copyWith(color: t.textSecondary),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.actionCancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    key: const ValueKey<String>('change_apply'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    onPressed: candidate == null || needsMember
                        ? null
                        : () => Navigator.of(context).pop(request),
                    child: Text(l10n.dutyChangeApply),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final current = dateOfKey(_effectiveFrom ?? _defaultFrom());
    final picked = await showDatePicker(
      context: context,
      helpText: context.l10n.dutyRotationPickDate,
      initialDate: current,
      firstDate: dateOfKey(_today()),
      lastDate: DateTime.utc(current.year + 2, 12, 31),
    );
    if (picked == null || !mounted) return;
    setState(() => _effectiveFrom = keyOfDate(picked));
  }
}
