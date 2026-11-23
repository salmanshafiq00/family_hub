import 'package:family_hub/features/chores/starter_packs/domain/packs/family_pdf_pack.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_item_mapping.dart';
import 'package:family_hub/features/chores/templates/domain/template_validator.dart';
import 'package:flutter_test/flutter_test.dart';

/// A pack line survives the trip to a stored item and back, and every built-in
/// line is something the validator accepts (so "Customise" can never write a
/// document the rules would refuse).
void main() {
  test('every built-in line round-trips through a stored item', () {
    for (var i = 0; i < familyPdfPack.templates.length; i++) {
      final line = familyPdfPack.templates[i];
      final item = line.toItem(sortOrder: i);

      expect(item.id, line.seedKey);
      expect(item.seedKey, line.seedKey);
      expect(item.sortOrder, i);
      expect(starterTemplateOf(item), line, reason: line.seedKey);
    }
  });

  test('every built-in line passes the template validator', () {
    for (final line in familyPdfPack.templates) {
      final draft = line.toItem(sortOrder: 0).draft;
      expect(TemplateValidator.validate(draft), isNull, reason: line.seedKey);
    }
  });

  test('copyWithTemplates keeps the rest of the pack', () {
    final one = familyPdfPack.templates.take(1).toList();
    final copy = familyPdfPack.copyWithTemplates(one);

    expect(copy.templates, one);
    expect(copy.id, familyPdfPack.id);
    expect(copy.houseRulesBn, familyPdfPack.houseRulesBn);
    expect(copy.groups, familyPdfPack.groups);
  });
}
