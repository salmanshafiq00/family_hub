# Chores calendar redesign (implemented)

Replaces D1, D3 and the border painter of ``.
Layout: app bar (bell, Today, Manage) + Row 1 (title, arrows, jump-to-today, legend)
+ Row 2 (view pill, member chip, filter) + weekday header + grid that fits the space
above the collapsed day panel. Cells: centred number; person icon (mine, top-start);
state pip (top-end); other members' avatars (bottom). States: selected > today >
tint by state (overdue, done, in progress/scheduled, skipped, none).
