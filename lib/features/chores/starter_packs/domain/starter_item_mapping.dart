import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_pack.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';

/// The date stored in an item's `startDate` (the field is required by the
/// shared document shape; applying a pack always replaces it with today).
final DateKey kStarterItemEpoch = DateKey(2000, 1, 1);

/// Converts between the pack's in-memory line and the stored item.
extension StarterTemplateToItem on StarterTemplate {
  ChoreTemplate toItem({required int sortOrder}) => ChoreTemplate(
    id: seedKey,
    draft: toDraft(startDate: kStarterItemEpoch),
    sortOrder: sortOrder,
    seedKey: seedKey,
  );
}

/// A stored item back as a pack line. Every family-made line is `High`: the
/// family wrote it, so nothing is left to confirm.
StarterTemplate starterTemplateOf(ChoreTemplate item) {
  final d = item.draft;
  return StarterTemplate(
    seedKey: item.seedKey ?? item.id,
    nameBn: d.nameBn,
    nameEn: d.nameEn,
    groupId: d.groupId,
    recurrence: d.recurrence,
    slots: d.slots,
    instructions: d.instructions,
    subtasks: d.subtasks,
    verification: d.verification,
    confidence: Confidence.high,
    iconKey: d.iconKey,
    colorIndex: d.colorIndex,
  );
}
