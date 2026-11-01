import 'package:family_hub/features/chores/settings/domain/default_chore_settings.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_pack.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';

/// The family's decoded chore list (Appendix A.1) as starter-pack DATA.
///
/// This file and `default_chore_settings.dart` are the only places allowed to
/// hold seed ids (road map P3-19). Nothing here is code: changing a line means
/// editing this list, exactly as if the family had edited the template in the
/// app. Every line carries the confidence the PDF was decoded with.

// ── Shared times and recurrences ─────────────────────────────────────────────

const TemplateSlot _at9 = TemplateSlot(
  key: TemplateLimits.mainSlotKey,
  dueMinutes: 540,
);
const TemplateSlot _at14 = TemplateSlot(
  key: TemplateLimits.mainSlotKey,
  dueMinutes: 840,
);
const TemplateSlot _at19 = TemplateSlot(
  key: TemplateLimits.mainSlotKey,
  dueMinutes: 1140,
);
const TemplateSlot _at20 = TemplateSlot(
  key: TemplateLimits.mainSlotKey,
  dueMinutes: 1200,
);
const TemplateSlot _at22 = TemplateSlot(
  key: TemplateLimits.mainSlotKey,
  dueMinutes: 1320,
);
const TemplateSlot _anyTime = TemplateSlot(key: TemplateLimits.mainSlotKey);

const List<TemplateSlot> _threeTimes = <TemplateSlot>[
  TemplateSlot(
    key: TemplateLimits.mainSlotKey,
    labelBn: 'সকাল',
    labelEn: 'Morning',
    dueMinutes: 540,
  ),
  TemplateSlot(
    key: 'noon',
    labelBn: 'দুপুর',
    labelEn: 'Noon',
    dueMinutes: 840,
  ),
  TemplateSlot(
    key: 'evening',
    labelBn: 'সন্ধ্যা',
    labelEn: 'Evening',
    dueMinutes: 1140,
  ),
];

const Recurrence _daily = DailyRecurrence();
const Recurrence _saturday = WeekdaysRecurrence(
  weekdays: <int>[DateTime.saturday],
);
const Recurrence _firstOfMonth = DaysOfMonthRecurrence(days: <int>[1]);

/// The five fridge steps (Appendix A.1), shared by the weekly and monthly
/// deep-clean lines.
const List<TemplateSubtask> _fridgeSteps = <TemplateSubtask>[
  TemplateSubtask(id: 'food', title: 'খাবার ও বাসি খাবার দেখা'),
  TemplateSubtask(
    id: 'shelves',
    title: 'খাবার নিরাপদে সরিয়ে তাক ও কম্পার্টমেন্ট পরিষ্কার',
  ),
  TemplateSubtask(id: 'gasket', title: 'দরজার গ্যাসকেট পরিষ্কার'),
  TemplateSubtask(id: 'door', title: 'দরজা ও বাইরের অংশ পরিষ্কার'),
  TemplateSubtask(id: 'reassemble', title: 'তাক ও ডিভাইডার শুকিয়ে ঠিকভাবে লাগানো'),
];

/// The lines the wizard offers, in Appendix A.1 order.
const List<StarterTemplate> _templates = <StarterTemplate>[
  StarterTemplate(
    seedKey: 'sweep',
    nameBn: 'ঘর ঝাড়ু দেওয়া',
    nameEn: 'Sweep the house',
    groupId: 'cleaning',
    confidence: Confidence.high,
    recurrence: _daily,
    slots: _threeTimes,
    instructions: 'সোফা ও টেবিলের নিচে পরিষ্কার করবে',
  ),
  StarterTemplate(
    seedKey: 'mop',
    nameBn: 'ঘর মোছা',
    nameEn: 'Mop the floor',
    groupId: 'cleaning',
    confidence: Confidence.high,
    recurrence: _daily,
    slots: <TemplateSlot>[_at14],
    instructions: 'মাঝখানের রুমের সব কাজ শেষ হওয়ার পরে রুম মুছবে',
  ),
  StarterTemplate(
    seedKey: 'breakfast',
    nameBn: 'সকালের নাস্তা বানানো',
    nameEn: 'Make breakfast',
    groupId: 'cooking',
    confidence: Confidence.high,
    recurrence: _daily,
    slots: <TemplateSlot>[_at9],
  ),
  StarterTemplate(
    seedKey: 'lunch',
    nameBn: 'দুপুরের রান্না',
    nameEn: 'Cook lunch',
    groupId: 'cooking',
    confidence: Confidence.high,
    recurrence: _daily,
    slots: <TemplateSlot>[_at14],
  ),
  StarterTemplate(
    seedKey: 'dinner',
    nameBn: 'রাতের রান্না',
    nameEn: 'Cook dinner',
    groupId: 'cooking',
    confidence: Confidence.medium,
    recurrence: _daily,
    slots: <TemplateSlot>[_at20],
    instructions: 'রাতের ভাত ৮টার মধ্যে রান্না শেষ',
  ),
  StarterTemplate(
    seedKey: 'water',
    nameBn: 'ফিল্টারে পানি দেওয়া',
    nameEn: 'Fill the water filter',
    groupId: 'water',
    confidence: Confidence.high,
    recurrence: _daily,
    slots: _threeTimes,
  ),
  StarterTemplate(
    seedKey: 'dishes',
    nameBn: 'থালা-বাসন পরিষ্কার',
    nameEn: 'Wash the dishes',
    groupId: 'kitchen',
    confidence: Confidence.medium,
    recurrence: _daily,
    slots: <TemplateSlot>[_at20],
    instructions: 'আগের দিন রাতেই করতে হবে',
  ),
  StarterTemplate(
    seedKey: 'fridge_check',
    nameBn: 'ফ্রিজে বাসি খাবার আছে কিনা দেখা',
    nameEn: 'Check the fridge for leftover food',
    groupId: 'fridge',
    confidence: Confidence.high,
    recurrence: _daily,
    slots: <TemplateSlot>[_anyTime],
  ),
  StarterTemplate(
    seedKey: 'kitchen_after',
    nameBn: 'রান্নার পর চুলা ও রান্নাঘর পরিষ্কার',
    nameEn: 'Clean the stove and kitchen after cooking',
    groupId: 'kitchen',
    confidence: Confidence.high,
    recurrence: _daily,
    slots: <TemplateSlot>[_at19],
    subtasks: <TemplateSubtask>[
      TemplateSubtask(id: 'stove', title: 'চুলা পরিষ্কার'),
      TemplateSubtask(id: 'sinks', title: 'উপরের ও নিচের বেসিন পরিষ্কার'),
      TemplateSubtask(
        id: 'gas_inside',
        title: 'গ্যাস চুলার ভিতর ও ২টা চাবি খুলে পরিষ্কার',
      ),
      TemplateSubtask(id: 'exhaust', title: 'এক্সহস্ট ফ্যান পরিষ্কার'),
    ],
  ),
  StarterTemplate(
    seedKey: 'bin',
    nameBn: 'ময়লা ফেলার বেলচা ও বালতি ধুয়ে পরিষ্কার',
    nameEn: 'Wash the bin scoop and bucket',
    groupId: 'kitchen',
    confidence: Confidence.medium,
    recurrence: _daily,
    slots: <TemplateSlot>[_at19],
    instructions: 'রান্নার পরে',
  ),
  StarterTemplate(
    seedKey: 'cover_wash',
    nameBn: 'সোফা ও টেবিলের কভার ধোয়া/ঝাড়া',
    nameEn: 'Wash or shake the sofa and table covers',
    groupId: 'living',
    confidence: Confidence.medium,
    recurrence: _daily,
    slots: <TemplateSlot>[_anyTime],
  ),
  StarterTemplate(
    seedKey: 'doormat',
    nameBn: 'রান্নাঘরের পাপোশ ধোয়া',
    nameEn: 'Wash the kitchen doormat',
    groupId: 'kitchen',
    confidence: Confidence.low,
    recurrence: _daily,
    slots: <TemplateSlot>[_at22],
    instructions: 'ঘুমের আগে',
  ),
  StarterTemplate(
    seedKey: 'rack_spice',
    nameBn: 'রান্নাঘরের র‍্যাকের ভিতর ও মশলার বয়াম পরিষ্কার',
    nameEn: 'Clean the kitchen rack and spice jars',
    groupId: 'kitchen',
    confidence: Confidence.medium,
    recurrence: _saturday,
    slots: <TemplateSlot>[_anyTime],
  ),
  StarterTemplate(
    seedKey: 'drawing_weekly',
    nameBn: 'ড্রয়িং রুম পরিষ্কার',
    nameEn: 'Clean the drawing room',
    groupId: 'living',
    confidence: Confidence.medium,
    recurrence: _saturday,
    slots: <TemplateSlot>[_anyTime],
    instructions: 'ফিল্টার, বেসিন, টেবিলের আশপাশ ও ফ্যান',
  ),
  StarterTemplate(
    seedKey: 'fridge_weekly',
    nameBn: 'ফ্রিজ পরিষ্কার (সাপ্তাহিক)',
    nameEn: 'Clean the fridge (weekly)',
    groupId: 'fridge',
    confidence: Confidence.high,
    recurrence: _saturday,
    slots: <TemplateSlot>[_anyTime],
    subtasks: _fridgeSteps,
    verification: VerificationMode.required,
  ),
  StarterTemplate(
    seedKey: 'fridge_monthly',
    nameBn: 'ফ্রিজ গভীর পরিষ্কার (মাসিক)',
    nameEn: 'Deep-clean the fridge (monthly)',
    groupId: 'fridge',
    confidence: Confidence.high,
    recurrence: _firstOfMonth,
    slots: <TemplateSlot>[_anyTime],
    subtasks: _fridgeSteps,
    verification: VerificationMode.required,
  ),
];

const String _houseRulesBn =
    '- রান্নাঘরের বেসিনে কেউ থালা-বাসন জমিয়ে রাখবে না\n'
    '- রান্নাঘরের বেসিন সবসময় পরিষ্কার রাখতে হবে\n'
    '- কেউ কিছু জমিয়ে রাখবে না\n'
    '- ভাত রান্নার সময় তরকারি গরম করে ফেলবে\n'
    '- রান্না সময়মতো শেষ করবে (সকাল ৯টা, দুপুর ২টা, রাত ৮টা)';

const String _houseRulesEn =
    '- Nobody leaves dishes in the kitchen sink\n'
    '- The kitchen sink always stays clean\n'
    '- Nobody leaves things lying around\n'
    '- Warm the curry while the rice cooks\n'
    '- Finish cooking on time (9 am, 2 pm, 8 pm)';

/// The one pack of Phase 3 (Appendix A.1 and A.3).
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
