part of 'template_list_screen.dart';

/// What a manager can do to a template from the list.
enum TemplateRowAction { pause, resume, duplicate, archive }

class _GroupSection extends StatelessWidget {
  const _GroupSection({
    required this.group,
    required this.rows,
    required this.canManage,
    required this.today,
    required this.formatters,
    required this.invalid,
    required this.onAction,
  });

  final ChoreGroup group;
  final List<TemplateRecord> rows;
  final bool canManage;
  final DateKey today;
  final AppFormatters formatters;
  final Set<String> invalid;
  final Future<void> Function(TemplateRowAction, ChoreTemplate) onAction;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final name = localizedName(context, group.nameBn, group.nameEn);
    return Theme(
      // The tile draws its own divider lines; the card look is enough here.
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey<String>('group_${group.id}'),
        initiallyExpanded: true,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Text(
          '$name (${formatters.number(rows.length)})',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: t.textPrimary),
        ),
        children: [
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Row(
                record: r,
                canManage: canManage,
                today: today,
                formatters: formatters,
                invalid: invalid.contains(r.template.id),
                onAction: onAction,
              ),
            ),
        ],
      ),
    );
  }
}

/// One row, with its swipe actions (managers only) and a long-press sheet that
/// offers the same three actions for people who cannot swipe.
class _Row extends StatelessWidget {
  const _Row({
    required this.record,
    required this.canManage,
    required this.today,
    required this.formatters,
    required this.invalid,
    required this.onAction,
  });

  final TemplateRecord record;
  final bool canManage;
  final DateKey today;
  final AppFormatters formatters;
  final bool invalid;
  final Future<void> Function(TemplateRowAction, ChoreTemplate) onAction;

  List<(TemplateRowAction, IconData, String)> _actions(BuildContext context) {
    final l10n = context.l10n;
    final template = record.template;
    return <(TemplateRowAction, IconData, String)>[
      if (!template.isArchived)
        if (template.active)
          (
            TemplateRowAction.pause,
            Icons.pause_circle_outline_rounded,
            l10n.choreActionPause,
          )
        else
          (
            TemplateRowAction.resume,
            Icons.play_circle_outline_rounded,
            l10n.choreActionResume,
          ),
      (
        TemplateRowAction.duplicate,
        Icons.copy_all_outlined,
        l10n.choreActionDuplicate,
      ),
      if (!template.isArchived)
        (
          TemplateRowAction.archive,
          Icons.archive_outlined,
          l10n.choreActionArchive,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final template = record.template;
    final row = TemplateListRow(
      template: template,
      today: today,
      formatters: formatters,
      invalidSchedule: invalid,
      onTap: () => context.push(AppRoutes.choresTemplateEdit(template.id)),
    );
    if (!canManage) return row;
    final actions = _actions(context);

    return GestureDetector(
      onLongPress: () => showModalBottomSheet<void>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (action, icon, label) in actions)
                ListTile(
                  key: ValueKey<String>('sheet_${action.name}'),
                  leading: Icon(icon),
                  title: Text(label),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onAction(action, template);
                  },
                ),
            ],
          ),
        ),
      ),
      child: Slidable(
        key: ValueKey<String>('template_${template.id}'),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.9,
          children: [
            for (final (action, icon, label) in actions)
              SlidableAction(
                key: ValueKey<String>('swipe_${action.name}'),
                onPressed: (_) => onAction(action, template),
                backgroundColor: t.accentSoft,
                foregroundColor: t.accentStrong,
                icon: icon,
                label: label,
              ),
          ],
        ),
        child: row,
      ),
    );
  }
}
