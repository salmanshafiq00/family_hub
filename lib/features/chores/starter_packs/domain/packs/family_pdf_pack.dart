import 'package:family_hub/features/chores/settings/domain/default_chore_settings.dart';
import 'package:family_hub/features/chores/starter_packs/domain/packs/family_pdf_daily.dart';
import 'package:family_hub/features/chores/starter_packs/domain/packs/family_pdf_periodic.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_pack.dart';

// The family's chore list as starter-pack DATA (sheet "Starter Pack of
// Chores": 9 daily, 3 weekly and 5 monthly lines).
//
// This file, the two template lists and `default_chore_settings.dart` are the
// only places allowed to hold seed ids (road map P3-19). Nothing here is code.

/// Every line, in sheet order.
const List<StarterTemplate> _templates = <StarterTemplate>[
  ...familyPdfDailyTemplates,
  ...familyPdfPeriodicTemplates,
];

const String _houseRulesBn =
    '- রান্নাঘরের বেসিনে কেউ থালা-বাসন জমিয়ে রাখবে না\n'
    '- রান্নাঘরের বেসিন সবসময় পরিষ্কার রাখতে হবে\n'
    '- কেউ কিছু জমিয়ে রাখবে না\n'
    '- ভাত রান্নার সময় তরকারি গরম করে ফেলবে\n'
    '- রান্না সময়মতো শেষ করবে (সকাল ৯টা, দুপুর ২টা, রাত ৯টা)';

const String _houseRulesEn =
    '- Nobody leaves dishes in the kitchen sink\n'
    '- The kitchen sink always stays clean\n'
    '- Nobody leaves things lying around\n'
    '- Warm the curry while the rice cooks\n'
    '- Finish cooking on time (9 am, 2 pm, 9 pm)';

/// The one starter pack.
const StarterPack familyPdfPack = StarterPack(
  id: 'family_pdf',
  titleKey: 'starterPackFamilyPdfTitle',
  descriptionKey: 'starterPackFamilyPdfDescription',
  groups: defaultGroups,
  dueTimePresets: defaultDueTimePresets,
  templates: _templates,
  dutyGroup: StarterDutyGroup(
    nameBn: 'দৈনিক রান্নাঘর ডিউটি',
    nameEn: 'Daily kitchen duty',
    colorIndex: 1,
  ),
  houseRulesBn: _houseRulesBn,
  houseRulesEn: _houseRulesEn,
);
