import 'package:family_hub/features/chores/starter_packs/domain/starter_pack.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';

/// The nine daily lines (sheet rows 1-9).
///
/// Data only, decoded from the family's "Starter Pack of Chores" sheet (one
/// row = one line). Changing a line means editing this list, exactly as if the
/// family had edited the template in the app.
const List<StarterTemplate> familyPdfDailyTemplates = <StarterTemplate>[
  StarterTemplate(
    seedKey: 'living_room',
    nameBn: 'বসার রুম পরিষ্কার',
    nameEn: 'Living Room Cleaning',
    groupId: 'living',
    iconKey: 'living',
    colorIndex: 5,
    confidence: Confidence.high,
    recurrence: DailyRecurrence(),
    slots: <TemplateSlot>[
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
        dueMinutes: 1080,
      ),
    ],
    instructions:
        '- আগে জিনিস গুছিয়ে, তারপর ঝাড়ু, সবশেষে মোছা — এই ক্রমে করুন।\n'
        '- ঝাড়ু দেওয়ার সময় সোফা ও টেবিলের নিচ পর্যন্ত পরিষ্কার করুন।\n'
        '- ঘর মোছা দিনে একবার, দুপুরে সব কাজ শেষ হওয়ার পর।',
    subtasks: <TemplateSubtask>[
      TemplateSubtask(id: 's1', title: 'সোফা ও কুশন গোছানো'),
      TemplateSubtask(id: 's2', title: 'টি টেবিল গোছানো'),
      TemplateSubtask(id: 's3', title: 'ডাইনিং টেবিল গোছানো ও মোছা'),
      TemplateSubtask(id: 's4', title: 'ঝাড়ু দেওয়া'),
      TemplateSubtask(
        id: 's5',
        title: 'মোছা (শুধু দুপুরের বারে, অন্য সব কাজ শেষে)',
      ),
    ],
  ),
  StarterTemplate(
    seedKey: 'breakfast',
    nameBn: 'সকালের নাস্তা বানানো',
    nameEn: 'Prepare Breakfast',
    groupId: 'cooking',
    iconKey: 'breakfast',
    colorIndex: 11,
    confidence: Confidence.high,
    recurrence: DailyRecurrence(),
    slots: <TemplateSlot>[
      TemplateSlot(key: TemplateLimits.mainSlotKey, dueMinutes: 540),
    ],
    instructions:
        '- সকাল ৯টার মধ্যে নাস্তা প্রস্তুত রাখুন।\n'
        '- রান্না শুরুর আগে ফ্রিজের বাসি খাবার দেখে নিন।',
    subtasks: <TemplateSubtask>[
      TemplateSubtask(id: 's1', title: 'দরকারি উপকরণ বের করে ঠিক করা'),
      TemplateSubtask(id: 's2', title: 'নাস্তা রান্না করা'),
      TemplateSubtask(id: 's3', title: 'ঢেকে ডাইনিং টেবিলে রাখা'),
    ],
  ),
  StarterTemplate(
    seedKey: 'lunch',
    nameBn: 'দুপুরের রান্না',
    nameEn: 'Cook Lunch',
    groupId: 'cooking',
    iconKey: 'lunch',
    colorIndex: 2,
    confidence: Confidence.high,
    recurrence: DailyRecurrence(),
    slots: <TemplateSlot>[
      TemplateSlot(key: TemplateLimits.mainSlotKey, dueMinutes: 840),
    ],
    instructions:
        '- দুপুর ২টার মধ্যে রান্না শেষ করুন।\n'
        '- রান্না শেষে চুলা, রান্নাঘর ও ময়লার বেলচা পরিষ্কারের কাজগুলোও করুন।',
    subtasks: <TemplateSubtask>[
      TemplateSubtask(id: 's1', title: 'উপকরণ কাটা ও ধোয়া'),
      TemplateSubtask(id: 's2', title: 'ভাত ও তরকারি রান্না করা'),
      TemplateSubtask(id: 's3', title: 'ঢেকে ডাইনিং টেবিলে রাখা'),
    ],
  ),
  StarterTemplate(
    seedKey: 'dinner',
    nameBn: 'রাতের রান্না',
    nameEn: 'Cook Dinner',
    groupId: 'cooking',
    iconKey: 'dinner',
    colorIndex: 19,
    confidence: Confidence.high,
    recurrence: DailyRecurrence(),
    slots: <TemplateSlot>[
      TemplateSlot(key: TemplateLimits.mainSlotKey, dueMinutes: 1260),
    ],
    instructions:
        '- রাত ৯টার মধ্যে রান্না শেষ করার চেষ্টা করুন।\n'
        '- রাতের ভাত রান্নার সময় আগের তরকারি গরম করে ফেলুন, যাতে নষ্ট না হয়।\n'
        '- রান্না শেষে চুলার সব নব বন্ধ আছে কিনা দেখে নিন।',
    subtasks: <TemplateSubtask>[
      TemplateSubtask(id: 's1', title: 'উপকরণ কাটা ও ধোয়া'),
      TemplateSubtask(id: 's2', title: 'রাতের ভাত ও তরকারি রান্না করা'),
      TemplateSubtask(id: 's3', title: 'আগের তরকারি থাকলে গরম করে নেওয়া'),
      TemplateSubtask(id: 's4', title: 'ঢেকে ডাইনিং টেবিলে রাখা'),
    ],
  ),
  StarterTemplate(
    seedKey: 'water',
    nameBn: 'ফিল্টারে পানি ভরা',
    nameEn: 'Refill Water Filter',
    groupId: 'water',
    iconKey: 'water',
    colorIndex: 1,
    confidence: Confidence.high,
    recurrence: DailyRecurrence(),
    slots: <TemplateSlot>[
      TemplateSlot(key: TemplateLimits.mainSlotKey, dueMinutes: 1200),
    ],
    instructions:
        '- পানি দেওয়ার আগে ওপরের স্টোরেজ ও ঢাকনা পরিষ্কার করুন।\n'
        '- হাত ধুয়ে ফিল্টারে হাত দিন এবং ভরার পর সবসময় ঢাকনা দিয়ে রাখুন।',
    subtasks: <TemplateSubtask>[
      TemplateSubtask(
        id: 's1',
        title: 'ফিল্টারের ঢাকনা ও ওপরের স্টোরেজ ধুয়ে নেওয়া',
      ),
      TemplateSubtask(id: 's2', title: 'পরিষ্কার পানি ভরা'),
      TemplateSubtask(id: 's3', title: 'ঢাকনা ভালোভাবে লাগানো'),
    ],
  ),
  StarterTemplate(
    seedKey: 'dishes',
    nameBn: 'থালা বাসন পরিষ্কার',
    nameEn: 'Wash Dishes',
    groupId: 'kitchen',
    iconKey: 'handwash',
    colorIndex: 18,
    confidence: Confidence.high,
    recurrence: DailyRecurrence(),
    slots: <TemplateSlot>[
      TemplateSlot(
        key: TemplateLimits.mainSlotKey,
        labelBn: 'নাস্তার পর',
        labelEn: 'After breakfast',
        dueMinutes: 600,
      ),
      TemplateSlot(
        key: 'noon',
        labelBn: 'দুপুরের পর',
        labelEn: 'After lunch',
        dueMinutes: 900,
      ),
      TemplateSlot(
        key: 'night',
        labelBn: 'রাতের পর',
        labelEn: 'After dinner',
        dueMinutes: 1320,
      ),
    ],
    instructions:
        '- বেসিনে কেউ নিজের থালা-বাটি জমিয়ে রাখবে না।\n'
        '- রাতের বাসন রাতেই ধুয়ে ফেলুন; এঁটো বাসন রাতভর থাকলে তেলাপোকা ও পোকা আসে।\n'
        '- ধোয়ার পর বাসন র‍্যাকে রেখে শুকাতে দিন।',
    subtasks: <TemplateSubtask>[
      TemplateSubtask(id: 's1', title: 'নাস্তার পরের থালা-বাসন ধোয়া'),
      TemplateSubtask(id: 's2', title: 'দুপুরের খাবারের পরের থালা-বাসন ধোয়া'),
      TemplateSubtask(id: 's3', title: 'রাতের খাবারের পরের থালা-বাসন ধোয়া'),
      TemplateSubtask(
        id: 's4',
        title: 'সিঙ্কের ছাঁকনির ময়লা ফেলে বেসিন খালি রাখা',
      ),
    ],
  ),
  StarterTemplate(
    seedKey: 'fridge_check',
    nameBn: 'ফ্রিজের খাবার দেখভাল',
    nameEn: 'Check Fridge Food',
    groupId: 'kitchen',
    iconKey: 'box',
    colorIndex: 18,
    confidence: Confidence.high,
    recurrence: DailyRecurrence(),
    slots: <TemplateSlot>[
      TemplateSlot(key: TemplateLimits.mainSlotKey, dueMinutes: 540),
    ],
    instructions:
        '- যার রান্না থাকবে, সে রান্না শুরুর আগে ফ্রিজ দেখে নেবে।\n'
        '- গন্ধ, রং বা স্বাদ বদলালে খাবার ফেলে দিন; রান্না করা খাবার সাধারণত ২–৩ দিনের বেশি রাখবেন না।\n'
        '- সন্দেহ হলে খাবেন না, ফেলে দিন।',
    subtasks: <TemplateSubtask>[
      TemplateSubtask(id: 's1', title: 'বাসি ও পুরনো খাবার দেখা'),
      TemplateSubtask(id: 's2', title: 'নষ্ট বা গন্ধ হওয়া খাবার ফেলে দেওয়া'),
      TemplateSubtask(id: 's3', title: 'খাবার ঢাকনাসহ পাত্রে গুছিয়ে রাখা'),
    ],
  ),
  StarterTemplate(
    seedKey: 'kitchen_after',
    nameBn: 'রান্নার পর রান্নাঘর পরিষ্কার',
    nameEn: 'Clean Kitchen After Cooking',
    groupId: 'kitchen',
    iconKey: 'cleaning',
    colorIndex: 0,
    confidence: Confidence.high,
    recurrence: DailyRecurrence(),
    slots: <TemplateSlot>[
      TemplateSlot(key: TemplateLimits.mainSlotKey, dueMinutes: 900),
    ],
    instructions:
        '- চুলা ঠান্ডা হলে মুছুন; গ্যাসের নব বন্ধ আছে কিনা নিশ্চিত হোন। ইন্ডাকশন হলে প্লাগ খুলে মুছুন।\n'
        '- বেসিনে কেউ কিছু জমিয়ে রাখবে না।\n'
        '- তেল-চর্বি জমলে কুসুম গরম পানি ও ডিশ সাবান ব্যবহার করুন।',
    subtasks: <TemplateSubtask>[
      TemplateSubtask(id: 's1', title: 'চুলা ও চুলার আশপাশ মোছা'),
      TemplateSubtask(
        id: 's2',
        title: 'রান্নাঘরের বেসিন (উপর ও নিচ) পরিষ্কার করা',
      ),
      TemplateSubtask(id: 's3', title: 'কাউন্টারটপ মোছা'),
      TemplateSubtask(id: 's4', title: 'মেঝের তেল ও পানি মুছে ফেলা'),
    ],
  ),
  StarterTemplate(
    seedKey: 'scoop',
    nameBn: 'ময়লার বেলচা পরিষ্কার',
    nameEn: 'Clean Garbage Scoop (Dustpan)',
    groupId: 'kitchen',
    iconKey: 'trash_sweep',
    colorIndex: 15,
    confidence: Confidence.high,
    recurrence: DailyRecurrence(),
    instructions:
        '- প্রতিদিন রান্নার শেষে ধুয়ে পরিষ্কার করে ফেলবে।\n'
        '- ভেজা ময়লা লেগে থাকলে দুর্গন্ধ হয়, তাই ধুয়ে শুকিয়ে রাখুন।',
    subtasks: <TemplateSubtask>[
      TemplateSubtask(id: 's1', title: 'বেলচার ময়লা বালতিতে ফেলা'),
      TemplateSubtask(id: 's2', title: 'পানি ও সাবান দিয়ে ধোয়া'),
      TemplateSubtask(id: 's3', title: 'শুকিয়ে নির্দিষ্ট জায়গায় রাখা'),
    ],
  ),
];
