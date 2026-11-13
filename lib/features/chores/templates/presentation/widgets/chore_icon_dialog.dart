import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/presentation/chore_icons.dart';
import 'package:flutter/material.dart';

/// Opens the searchable catalog. Returns the chosen key, or null on cancel.
Future<String?> showChoreIconDialog(
  BuildContext context, {
  String? selected,
  List<String> recentKeys = const <String>[],
}) => showDialog<String>(
  context: context,
  builder: (_) =>
      _IconCatalogDialog(selected: selected, recentKeys: recentKeys),
);

class _IconCatalogDialog extends StatefulWidget {
  const _IconCatalogDialog({required this.selected, required this.recentKeys});

  final String? selected;
  final List<String> recentKeys;

  @override
  State<_IconCatalogDialog> createState() => _IconCatalogDialogState();
}

class _IconCatalogDialogState extends State<_IconCatalogDialog> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ChoreIconDef> get _matches {
    final query = _query.trim().toLowerCase();
    final matches = query.isEmpty
        ? choreIcons
        : <ChoreIconDef>[
            for (final icon in choreIcons)
              if (icon.key.contains(query) ||
                  icon.nameEn.toLowerCase().contains(query) ||
                  icon.nameBn.contains(_query.trim()))
                icon,
          ];
    if (query.isNotEmpty) return matches;

    // Previously used icons lead the unfiltered grid.
    final byKey = <String, ChoreIconDef>{
      for (final icon in matches) icon.key: icon,
    };
    final ordered = <ChoreIconDef>[];
    final seen = <String>{};
    for (final key in <String?>[widget.selected, ...widget.recentKeys]) {
      final icon = key == null ? null : byKey[key];
      if (icon != null && seen.add(icon.key)) ordered.add(icon);
    }
    for (final icon in matches) {
      if (seen.add(icon.key)) ordered.add(icon);
    }
    return ordered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final matches = _matches;
    return AlertDialog(
      title: Text(l10n.choreIconPickTitle),
      content: SizedBox(
        width: double.maxFinite,
        height: 380,
        child: Column(
          children: [
            TextField(
              key: const ValueKey<String>('icon_search'),
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search_rounded),
                hintText: l10n.choreIconSearchHint,
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: matches.isEmpty
                  ? Center(
                      child: Text(
                        l10n.choreIconNoMatches,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: t.textSecondary),
                      ),
                    )
                  : GridView.builder(
                      key: const ValueKey<String>('icon_grid'),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 56,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final icon = matches[index];
                        return ChoreIconChoice(
                          iconKey: icon.key,
                          selected: icon.key == widget.selected,
                          enabled: true,
                          onTap: () => Navigator.of(context).pop(icon.key),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
      ],
    );
  }
}

/// One 48 dp icon target, used by the quick row and the catalog grid. A
/// selected icon has a heavier ring AND a check badge (never colour alone).
class ChoreIconChoice extends StatelessWidget {
  const ChoreIconChoice({
    required this.iconKey,
    required this.selected,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final String iconKey;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final label = choreIconLabel(context, iconKey) ?? iconKey;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: InkResponse(
          key: ValueKey<String>('icon_$iconKey'),
          onTap: enabled ? onTap : null,
          radius: 28,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? t.accentSoft : null,
              border: Border.all(
                color: selected ? t.accentStrong : t.outline,
                width: selected ? 3 : 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  choreIcon(iconKey),
                  size: 22,
                  color: selected ? t.accentStrong : t.textPrimary,
                ),
                if (selected)
                  PositionedDirectional(
                    end: 0,
                    bottom: 0,
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: t.accentStrong,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
