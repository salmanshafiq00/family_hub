import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/presentation/chore_icons.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_pack.dart';
import 'package:family_hub/features/chores/templates/presentation/template_labels.dart';
import 'package:family_hub/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One line of the starter list: icon, name, group, and (when the list is the
/// family's own) an edit tap and a delete menu.
class StarterListRow extends ConsumerWidget {
  const StarterListRow({
    required this.line,
    required this.editable,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final StarterTemplate line;
  final bool editable;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final group = ref.watch(choreCatalogsProvider).groupOf(line.groupId);
    final name = localizedName(context, line.nameBn, line.nameEn);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        key: ValueKey<String>('starter_row_${line.seedKey}'),
        onTap: editable ? onEdit : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              Icon(
                choreIcon(line.iconKey ?? group.iconKey),
                color: t.accentStrong,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(color: t.textPrimary),
                    ),
                    Text(
                      localizedName(context, group.nameBn, group.nameEn),
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: t.textSecondary),
                    ),
                  ],
                ),
              ),
              if (editable)
                IconButton(
                  key: ValueKey<String>('starter_delete_${line.seedKey}'),
                  tooltip: l10n.actionDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
