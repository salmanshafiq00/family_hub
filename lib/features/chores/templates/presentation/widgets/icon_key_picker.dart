import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/presentation/chore_icons.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/chore_icon_dialog.dart';
import 'package:flutter/material.dart';

/// How many quick-pick icons the picker shows before "More icons".
const int kRecentIconLimit = 8;

/// Picks one of the chore icons ([choreIcons]).
///
/// Used by the template editor and by the chore-group dialog of the settings
/// page, so the two can never offer different icon sets. The editor is a
/// multi-step form, so the inline row shows only the previously used icons
/// plus one "More icons" button; the full, searchable catalog opens in a
/// dialog.
///
/// A selected icon has a heavier ring AND a check badge (never colour alone);
/// every target is at least 48 dp.
class IconKeyPicker extends StatelessWidget {
  const IconKeyPicker({
    required this.selected,
    required this.onChanged,
    this.recentKeys = const <String>[],
    this.enabled = true,
    super.key,
  });

  /// The chosen key, or null when none is chosen yet.
  final String? selected;
  final ValueChanged<String> onChanged;

  /// Keys used by the family's other chores/groups, most useful first.
  final List<String> recentKeys;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final quick = quickIconKeys(recentKeys, selected);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.choreIconRecent,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: t.textSecondary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final key in quick)
              ChoreIconChoice(
                iconKey: key,
                selected: key == selected,
                enabled: enabled,
                onTap: () => onChanged(key),
              ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const ValueKey<String>('icon_more'),
          onPressed: enabled
              ? () async {
                  final picked = await showChoreIconDialog(
                    context,
                    selected: selected,
                    recentKeys: recentKeys,
                  );
                  if (picked != null) onChanged(picked);
                }
              : null,
          icon: const Icon(Icons.search_rounded),
          label: Text(l10n.choreIconMore),
        ),
      ],
    );
  }
}

/// The quick row: the selection first, then the previously used keys, then the
/// start of the catalog so a new family is never shown an empty row.
List<String> quickIconKeys(
  List<String> recentKeys,
  String? selected, {
  int limit = kRecentIconLimit,
}) {
  final keys = <String>[];
  void add(String? key) {
    if (key == null || keys.length >= limit || keys.contains(key)) return;
    if (_knownKeys.contains(key)) keys.add(key);
  }

  add(selected);
  for (final key in recentKeys) {
    add(key);
  }
  for (final key in knownIconKeys) {
    add(key);
  }
  return keys;
}

final Set<String> _knownKeys = <String>{
  for (final icon in choreIcons) icon.key,
};
