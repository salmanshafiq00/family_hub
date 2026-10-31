import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_controller.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/presentation/template_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

String _templateName(BuildContext context, ChoreTemplate template) =>
    Localizations.localeOf(context).languageCode == 'bn'
    ? template.draft.nameBn
    : (template.draft.nameEn ?? template.draft.nameBn);

/// The chores that follow a duty group's rota, and (for a manager) a picker
/// that puts another chore on it (P3-18).
///
/// "Add" edits the TEMPLATE's `assignee.dutyGroupId` through
/// `DutyGroupController.addTemplate`: the group stores no chore list.
class GroupTemplatesSection extends ConsumerWidget {
  const GroupTemplatesSection({
    required this.groupId,
    required this.canManage,
    super.key,
  });

  final String groupId;
  final bool canManage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final templates = ref.watch(dutyGroupTemplatesProvider(groupId));
    final busy = ref.watch(dutyGroupControllerProvider.select((s) => s.saving));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dutyChoresTitle,
          style: textTheme.titleSmall?.copyWith(color: t.textPrimary),
        ),
        const SizedBox(height: 4),
        if (templates.isEmpty)
          Text(
            l10n.dutyChoresEmpty,
            style: textTheme.bodyMedium?.copyWith(color: t.textSecondary),
          ),
        for (final template in templates)
          ConstrainedBox(
            key: ValueKey<String>('chore_${template.id}'),
            constraints: const BoxConstraints(minHeight: 48),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                _templateName(context, template),
                style: textTheme.bodyLarge?.copyWith(color: t.textPrimary),
              ),
            ),
          ),
        if (canManage) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: const ValueKey<String>('add_chore'),
            style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: busy ? null : () => _add(context, ref),
            icon: const Icon(Icons.add),
            label: Text(l10n.dutyChoreAdd),
          ),
        ],
      ],
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final added = context.l10n.dutyChoreAdded;
    final controller = ref.read(dutyGroupControllerProvider.notifier);
    final candidates = <ChoreTemplate>[
      for (final record in ref.read(templatesProvider))
        if (!record.template.isArchived &&
            record.template.draft.assignee.dutyGroupId != groupId)
          record.template,
    ];
    final picked = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      builder: (sheet) => _PickSheet(candidates: candidates),
    );
    if (picked == null) return;
    final status = await controller.addTemplate(groupId, picked);
    if (status == DutyGroupStatus.saved) {
      messenger.showSnackBar(SnackBar(content: Text(added)));
    }
  }
}

class _PickSheet extends StatelessWidget {
  const _PickSheet({required this.candidates});

  final List<ChoreTemplate> candidates;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      children: [
        Text(l10n.dutyChoreAdd, style: textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(l10n.dutyChoreAddNote, style: textTheme.bodySmall),
        const SizedBox(height: 8),
        if (candidates.isEmpty) Text(l10n.dutyChoreAddNone),
        for (final template in candidates)
          ListTile(
            key: ValueKey<String>('pick_chore_${template.id}'),
            minVerticalPadding: 12,
            title: Text(_templateName(context, template)),
            onTap: () => Navigator.of(context).pop(template.id),
          ),
      ],
    );
  }
}
