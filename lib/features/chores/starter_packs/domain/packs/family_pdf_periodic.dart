import 'package:family_hub/features/chores/starter_packs/domain/starter_pack.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';

/// The weekly and monthly lines (sheet rows 10-17).
///
/// Data only, decoded from the family's "Starter Pack of Chores" sheet (one
/// row = one line). Changing a line means editing this list, exactly as if the
/// family had edited the template in the app.
const List<StarterTemplate> familyPdfPeriodicTemplates = <StarterTemplate>[
  StarterTemplate(
    seedKey: 'kitchen_weekly',
    nameBn: 'রান্নাঘর পুরো পরিষ্কার',
    nameEn: 'Weekly Kitchen Deep Clean',
    groupId: 'kitchen',
    iconKey: 'countertops',
    colorIndex: 0,
    confidence: Confidence.high,
    recurrence: WeekdaysRecurrence(weekdays: <int>[DateTime.saturday]),
    instructions:
        '- রেক, বেসিন ও তাক সহ পুরো রান্নাঘর ভালোভাবে পরিষ্কার করুন।\n'
        '- ওপর থেকে নিচের দিকে করুন: আগে রেক ও তাক, সবশেষে মেঝে।\n'
        '- ইন্ডাকশন পরিষ্কারের আগে প্লাগ খুলে ঠান্ডা হতে দিন।',
    subtasks: <TemplateSubtask>[
      TemplateSubtask(id: 's1', title: 'রেক খালি করে মুছে গুছিয়ে রাখা'),
      TemplateSubtask(
        id: 's2',
        title: 'গ্যাসের চুলা ও ইন্ডাকশনের ওপরের অংশ পরিষ্কার',
      ),
      TemplateSubtask(id: 's3', title: 'বেসিন ও কল ঘষে পরিষ্কার'),
      TemplateSubtask(id: 's4', title: 'তাকগুলোর ধুলা ও তেল মোছা'),
      TemplateSubtask(id: 's5', title: 'বেসিনের নিচ ও পাইপের আশপাশ পরিষ্কার'),
      TemplateSubtask(id: 's6', title: 'মেঝে ঘষে ধুয়ে/মুছে নেওয়া'),
    ],
  ),
  StarterTemplate(
    seedKey: 'bin',
    nameBn: 'ময়লার বালতি পরিষ্কার',
    nameEn: 'Wash Garbage Bin',
    groupId: 'kitchen',
    iconKey: 'trash',
    colorIndex: 3,
    confidence: Confidence.high,
    recurrence: WeekdaysRecurrence(weekdays: <int>[DateTime.saturday]),
    instructions:
        '- প্রতি সপ্তাহে শনিবার ময়লার বালতি পরিষ্কার করে ফেলবে।\n'
        '- ঢাকনা থাকলে ঢাকনাও ধুয়ে নিন।\n'
        '- ভেজা বালতিতে নতুন পলিথিন লাগাবেন না; আগে শুকিয়ে নিন।',
    subtasks: <TemplateSubtask>[
      TemplateSubtask(id: 's1', title: 'বালতির ময়লা খালি করা'),
      TemplateSubtask(
        id: 's2',
        title: 'ডিটারজেন্ট ও ব্রাশ দিয়ে ভেতর-বাইরে ঘষে ধোয়া',
      ),
      TemplateSubtask(id: 's3', title: 'পানিতে ভালোভাবে ধুয়ে নেওয়া'),
      TemplateSubtask(
        id: 's4',
        title: 'রোদে বা বাতাসে শুকিয়ে নতুন পলিথিন লাগানো',
      ),
    ],
  ),
  StarterTemplate(
    seedKey: 'filter_clean',
    nameBn: 'পানির ফিল্টার পরিষ্কার',
    nameEn: 'Clean Water Filter',
    groupId: 'water',
    iconKey: 'filter',
    colorIndex: 1,
    confidence: Confidence.high,
    recurrence: WeekdaysRecurrence(weekdays: <int>[DateTime.saturday]),
    instructions:
        '- ফিল্টারের ভেতর ও ওপর ভালোভাবে পরিষ্কার করুন।\n'
        '- ক্যান্ডেল বা ফিল্টার অংশে সাবান বা কড়া রাসায়নিক ব্যবহার করবেন না; ফিল্টারের নিয়ম অনুযায়ী করুন।\n'
        '- ধোয়ার পর প্রথম এক-দুই দফা পানি ফেলে দিন।',
    subtasks: <TemplateSubtask>[
      TemplateSubtask(id: 's1', title: 'ফিল্টারের পানি খালি করা'),
      TemplateSubtask(
        id: 's2',
        title: 'ঢাকনা, ওপরের ও নিচের স্টোরেজ খুলে ধোয়া',
      ),
      TemplateSubtask(
        id: 's3',
        title: 'ক্যান্ডেল/ফিল্টার অংশ নরম ব্রাশ দিয়ে পরিষ্কার করা',
      ),
      TemplateSubtask(id: 's4', title: 'কল ও বাইরের অংশ মোছা'),
      TemplateSubtask(id: 's5', title: 'সব জোড়া লাগিয়ে পরিষ্কার পানি ভরা'),
    ],
  ),
  StarterTemplate(
    seedKey: 'fridge_monthly',
    nameBn: 'ফ্রিজ পরিষ্কার',
    nameEn: 'Deep Clean Fridge',
    groupId: 'kitchen',
    iconKey: 'kitchen',
    colorIndex: 18,
    confidence: Confidence.high,
    recurrence: DaysOfMonthRecurrence(days: <int>[1]),
    instructions:
        '- আগে খাবার বের করে ঠান্ডা রাখুন, তারপর ফ্রিজ আনপ্লাগ করুন।\n'
        '- তাক ও ড্রয়ার কুসুম গরম পানিতে মৃদু সাবান মিশিয়ে ধুয়ে বাতাসে শুকিয়ে নিন।\n'
        '- দাগ দূর করতে বেকিং সোডা বা হালকা ভিনেগার মিশ্রণ ব্যবহার করুন; ব্লিচ বা কড়া রাসায়নিক নয়।\n'
        '- রাবার গ্যাসকেট, হ্যান্ডেল, ফ্রিজের ওপর ও ড্রেন লাইন নরম সুতি কাপড়ে মুছুন।\n'
        '- ফ্রিজারে বরফ জমে থাকলে গলতে দিয়ে মুছে নিন।\n'
        '- সম্পূর্ণ শুকানোর পরই প্লাগ দিন।',
    subtasks: <TemplateSubtask>[
      TemplateSubtask(
        id: 's1',
        title: 'ভেতরের খাবার বের করে ঠান্ডা বক্স/বরফসহ রাখা ও মেয়াদ দেখা',
      ),
      TemplateSubtask(id: 's2', title: 'ফ্রিজ বন্ধ করে প্লাগ খোলা'),
      TemplateSubtask(id: 's3', title: 'তাক, ড্রয়ার ও ট্রে খুলে ধোয়া'),
      TemplateSubtask(
        id: 's4',
        title: 'ভেতরের দেয়াল ও রাবার গ্যাসকেট পরিষ্কার করা',
      ),
      TemplateSubtask(
        id: 's5',
        title: 'হ্যান্ডেল, ফ্রিজের ওপর ও ড্রেন লাইন মোছা',
      ),
      TemplateSubtask(
        id: 's6',
        title: 'সব শুকিয়ে তাক বসানো ও প্লাগ দিয়ে চালু করা',
      ),
      TemplateSubtask(
        id: 's7',
        title: 'ঠান্ডা হতে শুরু করলে খাবার সাজিয়ে রাখা',
      ),
    ],
  ),
  StarterTemplate(
    seedKey: 'covers',
    nameBn: 'সোফার কভার, টেবিলের কভার ও পাপোস ধোয়া',
    nameEn: 'Wash Sofa Covers, Table Covers & Doormats',
    groupId: 'living',
    iconKey: 'laundry',
    colorIndex: 5,
    confidence: Confidence.high,
    recurrence: DaysOfMonthRecurrence(days: <int>[1]),
    instructions:
        '- ডিটারজেন্ট পাউডার দিয়ে ধুয়ে নিন।\n'
        '- রঙিন কভার আলাদা ধুবেন, যাতে রং না ছড়ায়।\n'
        '- পুরোপুরি না শুকানো পর্যন্ত আবার লাগাবেন না।',
    subtasks: <TemplateSubtask>[
      TemplateSubtask(id: 's1', title: 'কভার ও পাপোস খুলে নেওয়া'),
      TemplateSubtask(id: 's2', title: 'ঝেড়ে ধুলা ফেলা'),
      TemplateSubtask(id: 's3', title: 'ডিটারজেন্ট পাউডারে ভিজিয়ে ধোয়া'),
      TemplateSubtask(id: 's4', title: 'পানিতে ভালোভাবে ধুয়ে শুকানো'),
      TemplateSubtask(id: 's5', title: 'সম্পূর্ণ শুকালে আবার লাগানো/বিছানো'),
    ],
  ),
  StarterTemplate(
    seedKey: 'shoe_cabinet',
    nameBn: 'জুতার বাক্স পরিষ্কার',
    nameEn: 'Clean Shoe Cabinet',
    groupId: 'living',
    iconKey: 'shelves',
    colorIndex: 15,
    confidence: Confidence.high,
    recurrence: DaysOfMonthRecurrence(days: <int>[1]),
    instructions:
        '- জুতার বাক্সের ড্রয়ারগুলো এবং প্রতিটি তাক পরিষ্কার করুন।\n'
        '- জুতা ভেজা থাকলে রোদে শুকিয়ে তারপর রাখুন।\n'
        '- দুর্গন্ধ হলে তাকে বেকিং সোডা ছড়িয়ে কিছুক্ষণ পর মুছে নিন।',
    subtasks: <TemplateSubtask>[
      TemplateSubtask(id: 's1', title: 'জুতা বের করে আলাদা রাখা'),
      TemplateSubtask(
        id: 's2',
        title: 'ড্রয়ার ও প্রতিটি তাক ঝেড়ে ভেজা কাপড়ে মোছা',
      ),
      TemplateSubtask(id: 's3', title: 'শুকিয়ে জুতা গুছিয়ে রাখা'),
    ],
  ),
  StarterTemplate(
    seedKey: 'stove',
    nameBn: 'চুলা পরিষ্কার',
    nameEn: 'Deep Clean Stoves (Gas & Induction)',
    groupId: 'kitchen',
    iconKey: 'fire_safety',
    colorIndex: 4,
    confidence: Confidence.high,
    recurrence: DaysOfMonthRecurrence(days: <int>[1]),
    instructions:
        '- শুরুর আগে সিলিন্ডারের রেগুলেটর/মেইন লাইন বন্ধ করুন এবং চুলা ঠান্ডা হতে দিন।\n'
        '- প্যান সাপোর্ট ও বার্নার ক্যাপ কুসুম গরম পানিতে সাবান/ডিটারজেন্ট মিশিয়ে ভিজিয়ে স্পঞ্জ বা ব্রাশে পরিষ্কার করুন।\n'
        '- বার্নারের আটকে থাকা ছিদ্র টুথপিক বা চিকন পিন দিয়ে আলতো করে পরিষ্কার করুন, যাতে শিখা স্বাভাবিক থাকে।\n'
        '- চুলার কোটিং ও স্টিল বডিতে শক্ত তারের জালি বা কড়া রাসায়নিক ব্যবহার করবেন না; নরম কাপড় ও লিকুইড ক্লিনার ব্যবহার করুন।\n'
        '- ইগনিশন নব ও ইলেকট্রোডে পানি ঢালবেন না; শুকনো বা হালকা ভেজা কাপড়ে মুছুন।\n'
        '- সব পার্টস পুরোপুরি শুকিয়ে বার্নার ক্যাপ ঠিকমতো বসান। তারপর গ্যাস চালু করে শিখা দেখুন।\n'
        '- গ্যাসের গন্ধ পেলে আগুন বা বৈদ্যুতিক সুইচ চালাবেন না; রেগুলেটর বন্ধ করে জানালা খুলে দিন এবং মিস্ত্রি বা গ্যাস অফিসকে জানান।\n'
        '- ইন্ডাকশনের নিচের ভেন্ট/ছিদ্রে পানি ঢালবেন না।',
    subtasks: <TemplateSubtask>[
      TemplateSubtask(id: 's1', title: 'গ্যাস সিলিন্ডার/লাইন ও চাবি বন্ধ করা'),
      TemplateSubtask(
        id: 's2',
        title: 'প্যান সাপোর্ট ও বার্নার ক্যাপ খুলে ভিজিয়ে ধোয়া',
      ),
      TemplateSubtask(id: 's3', title: 'চুলার বডি ও ড্রিপ ট্রে মোছা'),
      TemplateSubtask(id: 's4', title: 'বার্নারের ছিদ্র পরিষ্কার করা'),
      TemplateSubtask(id: 's5', title: 'পার্টস শুকিয়ে ঠিকমতো বসানো'),
      TemplateSubtask(
        id: 's6',
        title: 'গ্যাস চালু করে শিখা ও লিকেজ পরীক্ষা করা',
      ),
      TemplateSubtask(
        id: 's7',
        title: 'ইন্ডাকশন: প্লাগ খুলে ঠান্ডা হলে ওপরের অংশ মোছা',
      ),
    ],
  ),
  StarterTemplate(
    seedKey: 'exhaust',
    nameBn: 'এক্সহস্ট ফ্যান পরিষ্কার',
    nameEn: 'Clean Exhaust Fan',
    groupId: 'kitchen',
    iconKey: 'air',
    colorIndex: 10,
    confidence: Confidence.high,
    recurrence: DaysOfMonthRecurrence(days: <int>[1]),
    instructions:
        '- শুরুর আগে ফ্যানের সুইচ ও মেইন প্লাগ বন্ধ রাখুন; সম্ভব হলে মেইন সুইচও বন্ধ করুন।\n'
        '- উঁচুতে হলে মজবুত মই/চেয়ার ব্যবহার করুন এবং কাউকে ধরে রাখতে বলুন।\n'
        '- খোলা কভার ও ব্লেড কুসুম গরম পানিতে ডিশওয়াশ লিকুইড বা বেকিং সোডা মিশিয়ে ভিজিয়ে স্পঞ্জে ঘষে ধুয়ে বাতাসে শুকান।\n'
        '- মোটর বা তারে পানি লাগাবেন না; মোটরের ফ্রেম শুকনো বা সামান্য ভেজা সুতি কাপড়ে মুছুন।\n'
        '- প্লাস্টিক অংশে তারের জালি বা কড়া রাসায়নিক ব্যবহার করবেন না।\n'
        '- পুরোপুরি শুকানোর পর ব্লেড ও কভার বসিয়ে হাতে ঘুরিয়ে দেখে তারপর সংযোগ দিন।',
    subtasks: <TemplateSubtask>[
      TemplateSubtask(id: 's1', title: 'ফ্যানের সুইচ ও প্লাগ বন্ধ করা'),
      TemplateSubtask(id: 's2', title: 'সামনের কভার ও ব্লেড সাবধানে খোলা'),
      TemplateSubtask(
        id: 's3',
        title: 'কভার ও ব্লেডের তেল-চিটচিটে ময়লা ধোয়া',
      ),
      TemplateSubtask(
        id: 's4',
        title: 'মোটর ও বডি শুকনো/হালকা ভেজা কাপড়ে মোছা',
      ),
      TemplateSubtask(
        id: 's5',
        title: 'সব শুকিয়ে ফিট করে হাতে ঘুরিয়ে দেখা ও টেস্ট করা',
      ),
    ],
  ),
];
