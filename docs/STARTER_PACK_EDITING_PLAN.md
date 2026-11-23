# Editable Starter Pack — plan

**Goal:** an admin or Household Manager adds, edits and deletes every line of
the starter pack inside the app. No Excel round trip, no code change.

## Decisions

| # | Decision | Why |
| --- | --- | --- |
| 1 | The family's own list lives in Firestore: `families/{f}/starterPackItems/{key}`. | Each family keeps its own list; it syncs to every phone. |
| 2 | A line is stored in the **same shape as a chore template** (`ChoreTemplateMappers`, `TemplateValidator`, rules `templateOk`). | One mapper, one validator, one rule; nothing new to get wrong. |
| 3 | While the family has no list of its own, the app uses the **built-in pack** (the 17 lines from the sheet). The manager taps **Customise** to copy them in. | Existing families keep working; nothing is migrated silently. |
| 4 | **Empty list = built-in pack.** Deleting the last line, or **Reset**, returns to the built-in pack. | No extra marker document, no extra rule. |
| 5 | Who: `Permission.manageChoreTemplates` (admin + Household Manager), checked in the use case and in the rules. | Same rule as chore templates. |
| 6 | The editor **reuses the chore editor's form** (names, group, icon, colour, repeat, times, steps, instructions) on one page. No person, dates or reminders. | A pack line is only a suggestion. |
| 7 | The wizard offers the family's list when it exists, else the built-in pack. Chores already created are never changed by editing or deleting a line. | Applying is still idempotent per line key. |
| 8 | Audit uses the existing chore event types (created / updated / archived / settings updated). | No change to the audit vocabulary or its rules list. |

## Screens

- **Starter pack wizard** (existing): a new pencil button in the app bar opens the list.
- **Starter pack list** (`/chores/starter-pack/list`): note (built-in or own), **Customise** (built-in only), rows with delete, **Add** button, **Reset to built-in list** in the app bar.
- **Line editor** (`/chores/starter-pack/list/new`, `/list/:id`): the form above, Save at the bottom, asks before discarding changes.

## Files

New: `starter_item_repository.dart`, `starter_item_mapping.dart`,
`manage_starter_items.dart`, `firestore_starter_item_repository.dart`,
`starter_item_providers.dart`, `starter_item_editor_controller.dart`,
`starter_item_editor_screen.dart`, `starter_pack_list_screen.dart`,
`widgets/starter_list_row.dart`, rules test `starter_pack_items.test.mjs`,
two Dart tests.

Edited: `starter_pack.dart` (`copyWithTemplates`), wizard screen + controller
(use the effective pack), `editor_schedule_section.dart` (`showDates`),
`app_routes.dart`, `chores_module.dart`, `bootstrap.dart`, `firestore_paths.dart`,
`query_limits.dart`, `firestore.rules`, both ARB files (+ generated l10n).

## Deploy order

1. Deploy the rules: `firebase deploy --only firestore:rules`.
2. Install the app. Until the rules are live the wizard still works with the built-in pack.
