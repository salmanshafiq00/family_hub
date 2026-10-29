import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/chores_entries.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/shared/widgets/app_card.dart';
import 'package:family_hub/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The hub of chore tools (templates, settings, duty groups, ...).
///
/// It renders [entries] (default: [choresEntries]) and hides every tile the
/// viewer may not use.  Nothing here knows a role: only `ref.can` (H7).
class ChoresManageScreen extends ConsumerWidget {
  const ChoresManageScreen({this._entries, super.key});

  final List<ChoresEntry>? _entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final entries = _entries ?? choresEntries;
    final visible = [
      for (final entry in entries)
        if ((entry.requires == null || ref.can(entry.requires!)) &&
            (entry.gate == null || ref.watch(entry.gate!)))
          entry,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.choresManageTitle)),
      body: visible.isEmpty
          ? EmptyState(
              icon: Icons.tune_outlined,
              title: l10n.choresManageEmptyTitle,
              message: l10n.choresManageEmptyMessage,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: visible.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _EntryTile(entry: visible[index]),
            ),
    );
  }
}

class _EntryTile extends ConsumerWidget {
  const _EntryTile({required this.entry});

  final ChoresEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tokens;
    final subtitle = entry.subtitle?.call(l10n);
    final badgeSource = entry.badge;
    final count = badgeSource == null ? 0 : ref.watch(badgeSource);
    final formatters = ref.watch(appFormattersProvider);

    return AppCard(
      onTap: () => context.push(entry.route),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          children: [
            Icon(entry.icon, color: t.accentStrong),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title(l10n),
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: t.textPrimary),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: t.textSecondary),
                    ),
                ],
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 8),
              Badge(label: Text(formatters.number(count))),
            ],
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: t.textSecondary),
          ],
        ),
      ),
    );
  }
}
