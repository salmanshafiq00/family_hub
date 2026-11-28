# বিজ্ঞপ্তি ও রিমাইন্ডার — কীভাবে কাজ করে

এই ফাইলটি Family Hub-এর সব বিজ্ঞপ্তি (notification) ও রিমাইন্ডার (reminder) এক জায়গায়
বোঝায়: কোন বিজ্ঞপ্তি কখন, কেন, কার কাছে যায়, কোন ধরনের (Normal না Push), ট্যাপ করলে কী হয়,
এবং রিমাইন্ডারের নিয়ম কী। কোডে পরিবর্তন করলে এই ফাইলটিও হালনাগাদ করুন।

সোর্স-অব-ট্রুথ কোড:

* `lib/core/notifications/` — বিজ্ঞপ্তির ধরন, চ্যানেল, প্ল্যানার, শিডিউলার, ট্যাপ-রাউটার, পুশ।
* `lib/features/notifications/` — ইনবক্স, সেটিংস, রিমাইন্ডার UI, টেক্সট।
* `docs/decisions/0015-two-delivery-modes-local-and-push.md` — Normal vs Push সিদ্ধান্ত।
* `docs/decisions/0016-virtual-inbox-items.md` — ভার্চুয়াল ইনবক্স আইটেম।
* `docs/decisions/0020-push-via-cloud-functions-blaze.md` — পুশ পাঠানোর সীমাবদ্ধতা।

---

## ১. এক নজরে

Family Hub-এ দুই ধরনের বিজ্ঞপ্তি আছে:

| ধরন | কী | কোথায় তৈরি হয় | অ্যাপ বন্ধ থাকলে? |
| --- | --- | --- | --- |
| **Normal (সাধারণ)** | ইন-অ্যাপ ইনবক্স + এই ফোনে লোকাল নোটিফিকেশন | ফোনেই (শুদ্ধ `ReminderPlanner` সময়ভিত্তিক, ফোরগ্রাউন্ড ব্রিজ ইভেন্টভিত্তিক) | শুধু আগে থেকে শিডিউল করা রিমাইন্ডার আসে |
| **Push (পুশ)** | Firebase Cloud Messaging (FCM) | সার্ভার (Cloud Function) — **বর্তমানে নেই** | হ্যাঁ, যদি পাঠানোর ব্যবস্থা থাকত |

গুরুত্বপূর্ণ: প্রতিটি বিজ্ঞপ্তির ধরনের **একটিমাত্র কার্যকর মোড** থাকে — Normal অথবা Push,
দুটো নয়। এই সিদ্ধান্ত শুধু `DeliveryPolicy.effective(...)` এক জায়গায় নেয়, যাতে একই ঘটনা
দুবার বিজ্ঞপ্তি না দেয়।

> **বর্তমান অবস্থা (Spark প্ল্যান):** FCM receive client আছে, কিন্তু পুশ *পাঠানোর* sender নেই
> (`FeatureFlags.pushBackend = false`)। তাই এখন কার্যত সব বিজ্ঞপ্তি Normal। পুশ সেটিং
> সংরক্ষিত থাকলেও পুশ চালু না হওয়া পর্যন্ত ব্যবহার হয় না।

---

## ২. বিজ্ঞপ্তির শ্রেণি ও বিভাগ

**তিনটি বিভাগ (`NotificationCategory`):** `chores` (কাজ), `bazar` (বাজার ও অর্থ), `family` (পরিবার)।

**তিনটি ধরন (`NotificationTypeKind`):**

* **event** — অন্য কেউ কিছু করলে ঘটে (যেমন অদলবদলের অনুরোধ)। সার্ভার ইভেন্ট, তাই push-capable।
* **scheduled** — সময়ভিত্তিক, ফোনেই হিসাব হয় (যেমন কাজের সময়)। push-capable নয়।
* **derived** — ডেটার অবস্থা থেকে পাওয়া (বাজেট %, অর্জন)। push-capable নয়।

শুধু **event** ধরন `pushCapable = true`। scheduled ও derived সবসময় Normal এবং সেটিংসে
lock করা থাকে (`notificationTypeLocked`: "ফোনেই তৈরি হয়; সার্ভার ইভেন্ট নেই।")।

---

## ৩. সব বিজ্ঞপ্তির তালিকা — কখন, কাকে, কীভাবে

### ৩.১ ইভেন্ট বিজ্ঞপ্তি (অন্য সদস্যের কাজে ঘটে)

এগুলো ইনবক্সে সংরক্ষিত হয় এবং (পুশ চালু থাকলে) পুশ হতে পারে। ইনবক্সের বাক্য
`inbox_text.dart` থেকে তৈরি হয়; নাম দেখানোর সময় uid থেকে resolve হয়।

| Type id | বিভাগ | ডিফল্ট মোড | কখন তৈরি হয় | কাকে যায় | ইনবক্সে যা লেখা আসে | ট্যাপে যায় |
| --- | --- | --- | --- | --- | --- | --- |
| `swap_request` | chores | Push | কেউ অদলবদল/কভার চাইলে | যে সদস্যের কাছে চাওয়া হচ্ছে | "{নাম} আপনাকে {তারিখ}-এ {কাজ} নিতে বলছেন" / কভার হলে "{নাম}-এর {তারিখ}-এ {কাজ} কাজে বদলি দরকার" | অনুরোধটি সার্ভার থেকে লোড হয়; এখনো pending ও আপনার হলে সাড়া দেওয়ার শিট, নাহলে বার্তা |
| `swap_result` | chores | Push | অনুরোধ গ্রহণ/বাতিল/মেয়াদ শেষ | অনুরোধকারী (বাতিল হলে প্রাপক) | "{নাম} … রাজি হয়েছেন/হননি/বাতিল করেছেন/সময় শেষ" | swap request আইটেম |
| `needs_cover` | chores | Push | কেউ অনুপস্থিত, কাজে বিকল্প দরকার | অনুপস্থিত সদস্য ও ম্যানেজার | "{নাম} {শুরু} থেকে {শেষ} নেই: {সংখ্যা}টি কাজে বদলি দরকার" | availability স্ক্রিন |
| `chore_assigned` | chores | Push | কাজ অন্যকে বদলি দেওয়া / বাল্ক বরাদ্দ | নতুন সদস্য | "{নাম} {তারিখ}-এর {কাজ} আপনাকে দিয়েছেন" / বাল্ক হলে "{নাম} … {সংখ্যা}টি কাজ দিয়েছেন" | occurrence ডিটেইল (বাল্ক হলে chores তালিকা) |
| `chore_reopened` | chores | Push | সম্পন্ন কাজ আবার খোলা | assignee | "{নাম} {তারিখ}-এর {কাজ} আবার খুলেছেন" | occurrence ডিটেইল |
| `comment_attention` | chores | Normal | কাজ ভুল/অসম্পূর্ণ চিহ্নিত | assignee | "{নাম} {তারিখ}-এর {কাজ} চিহ্নিত করেছেন" | occurrence ডিটেইল |
| `verification_needed` | chores | Normal | কাজ শেষ, যাচাই দরকার | যাচাইকারী | "{নাম} {তারিখ}-এর {কাজ} শেষ করেছেন; যাচাই দরকার" | occurrence ডিটেইল |
| `absence_decision` | chores | Normal | অনুপস্থিতির অনুরোধ অনুমোদিত/বাতিল | সদস্য | "{নাম} আপনার অনুপস্থিতি অনুমোদন করেছেন/বাতিল করেছেন" | availability স্ক্রিন |
| `member_join_request` | family | Push | কেউ পরিবারে যোগ দিতে চাইলে | admin/manager | (ভার্চুয়াল আইটেম হিসেবে দেখায়, নিচে ৩.৩) | সদস্য তালিকা |
| `member_approved` | family | Push | যোগদানের অনুরোধ অনুমোদিত | নতুন সদস্য | "পরিবারে যোগ দেওয়ার আপনার অনুরোধ অনুমোদিত হয়েছে।" | হোম |

> নোট: `member_join_request` টাইপ-টেবিলে আছে (মোড নির্ধারণের জন্য), কিন্তু বাস্তবে যোগদানের
> অনুরোধ admin-এর ইনবক্সে **ভার্চুয়াল** আইটেম হিসেবে দেখায়, সংরক্ষিত সারি হিসেবে নয়।

### ৩.২ সময়ভিত্তিক ও derived বিজ্ঞপ্তি (শুধু লোকাল, ফোনেই হিসাব)

এগুলো `ReminderPlanner` তৈরি করে এবং সবসময় Normal। সবগুলোই **আপনার নিজের** (assignee =
আপনি), খোলা, পাওয়া যায় এমন, এবং ভবিষ্যতের কাজের জন্য।

| Type id | বিভাগ | কখন | চ্যানেল | শিরোনাম/বার্তা | ট্যাপে যায় |
| --- | --- | --- | --- | --- | --- |
| `chore_due` | chores | নির্ধারিত সময়ে (`dueMinutes` থাকলে) এবং প্রতিটি offset আগে | `chores_due` | "{কাজ} করার সময় হয়েছে" / "{কাজ} কাজটি {সময়}-এর মধ্যে করুন।" | occurrence ডিটেইল |
| `chore_due` (before) | chores | due-র আগে প্রতিটি offset মিনিটে | `chores_due` | "{কাজ} কাজটির কথা মনে করিয়ে দিচ্ছি" / "{কাজ} কাজটি {মিনিট} মিনিট পরে, {সময়}-এ করতে হবে।" | occurrence ডিটেইল |
| `evening_nudge` | chores | `dueMinutes` না থাকলে দিনের শেষ কাজে ১৯:০০-এ | `chores_overdue` | "আজকের কাজের কথা" / "আজ আরও {সংখ্যা}টি কাজ বাকি আছে।" | occurrence ডিটেইল |
| `chore_overdue` | chores | due-র `overdueAfterMinutes` পরে (ডিফল্ট ৬০ মিনিট), যদি চালু থাকে | `chores_overdue` | "বাকি আছে: {কাজ}" / "{কাজ} কাজটি এখনো সম্পন্ন হয়নি।" | occurrence ডিটেইল |
| `morning_summary` | chores | যে দিনে অন্তত একটি কাজ বাকি, সেদিন সকালে (ডিফল্ট ০৭:০০) | `daily_summary` | "আজকের কাজ" / "আজ আপনার {সংখ্যা}টি কাজ আছে।" | আজকের কাজ তালিকা |
| `contribution_due` | bazar | এই মাসের চাঁদা না দিলে, নির্ধারিত দিনের আগের দিন ও দিনে ০৯:০০-এ | `bazar` | "মাসিক জমার কথা" / "আপনার এই মাসের জমা দেওয়ার সময় হয়েছে।" | bazar fund |
| `month_end` | bazar | মাস বন্ধ করার যোগ্য হলে, মাসের শেষ দিনে ১৮:০০-এ | `bazar` | "মাস শেষের হিসাব" / "এই মাসের বাজারের হিসাব বন্ধ করার সময় হয়েছে।" | bazar fund |
| `budget_alert` | bazar | derived — বাজেট সীমায় পৌঁছালে | — (ইনবক্স) | "আপনার বাজেট {শতাংশ}% হয়েছে।" | বাজেট স্ক্রিন |
| `achievement` | chores | derived — কোনো অর্জন হলে | — (ইনবক্স/সেলিব্রেশন) | — | — |

### ৩.৩ ইনবক্স — সংরক্ষিত বনাম ভার্চুয়াল

* **সংরক্ষিত (stored):** উপরের ইভেন্ট সারিগুলো `notificationInbox/{id}`-এ লেখা হয়, যে batch-এ
  মূল কাজটি হয় সেই একই batch-এ (আলাদা call নয়)। প্রতিটি সদস্য শুধু নিজের সারি পড়তে পারে।
* **ভার্চুয়াল (virtual):** কিছু আইটেম কোনো লিখিত সারি নয়, ডেটার *অবস্থা* থেকে ফোনে তৈরি হয়
  (`VirtualInbox.build`), এবং কারণ থাকলে দেখায়, কারণ চলে গেলে মিলিয়ে যায়:
  * `virtual_budget_alert` — বাজেট %
  * `virtual_pending_join_requests` — পর্যালোচনার অপেক্ষায় যোগদান অনুরোধ (admin)
  * `virtual_pending_contribution_requests` — পর্যালোচনার অপেক্ষায় অবদান অনুরোধ
  * `virtual_contribution_due` — এই মাসের চাঁদা বাকি
  * `virtual_awaiting_verification` — যাচাইয়ের অপেক্ষায় কাজের সংখ্যা

ভার্চুয়াল আইটেম কখনো পুশ হয় না (সার্ভার ইভেন্ট নেই) এবং এর "পড়া" অবস্থা প্রতি ডিভাইসে
লোকালি (`SharedPreferences`) থাকে। মডিউল বন্ধ থাকলে সংশ্লিষ্ট আইটেম ইনবক্স থেকে লুকিয়ে যায়
(`inbox_visibility.dart`)।

বেলের ব্যাজ = সংরক্ষিত অপঠিত + ভার্চুয়াল অ-স্বীকৃত (`InboxBell`, `inboxBellLabel`)।

---

## ৪. ট্যাপ করলে কী হয়

### ৪.১ লোকাল নোটিফিকেশন ট্যাপ

লোকাল বিজ্ঞপ্তির `payload` সাধারণত একটি রুট, যেমন `/chores/occurrence/{id}`,
`/chores/today`, `/bazar/fund`। ট্যাপ হলে `NotificationTapRouter.route(...)`:

1. payload খালি হলে কিছুই করে না।
2. রুটার তখনো attach না হলে payload জমা রাখে, পরে attach হলে replay করে।
3. `resolve(...)` শুধু অনুমোদিত prefix গ্রহণ করে: `/chores`, `/bazar`, `/inbox`, `/activity`,
   `/settings/notifications`।
4. scheme/authority/query/fragment থাকলে, বা `..`/`.` সেগমেন্ট থাকলে → বাতিল।
5. যে মডিউল বন্ধ (chores/bazar), তার রুট হলে → `/home`।
6. অ্যাপ বন্ধ থাকা অবস্থায় ট্যাপে অ্যাপ খুললে `getNotificationAppLaunchDetails` থেকে payload
   নিয়ে একইভাবে রাউট হয়।

### ৪.২ পুশ ট্যাপ (backend থাকলে)

`PushMessage.route` = `data['route']`, অথবা `data['inboxId']` থাকলে `/inbox/{id}`।
অজানা বা বন্ধ-মডিউল রুট হলে **সবসময় `/home`**-এ যায় (লোকালের মতো নীরবে বাতিল নয়)।
ট্যাপ দুভাবে ধরা হয়: `onOpenedApp` স্ট্রিম এবং `getInitialMessage` (অ্যাপ ঠান্ডা শুরু হলে)।

### ৪.৩ ইনবক্স সারি ট্যাপ

`openInboxItem` প্রথমে সারিটি পড়া হিসেবে চিহ্নিত করে (সংরক্ষিত হলে সার্ভারে, ভার্চুয়াল হলে
লোকালি), তারপর গন্তব্যে যায়:

| আইটেম | যায় |
| --- | --- |
| budget alert | বাজেট স্ক্রিন |
| pending join requests | সদস্য তালিকা |
| pending contribution requests | bazar fund pending |
| contribution due | bazar fund |
| awaiting verification | কাজ যাচাই স্ক্রিন |
| chore assigned (summary) | কাজ তালিকা |
| swap request | অনুরোধ লোড; pending ও আপনার হলে সাড়া-শিট, নাহলে বার্তা |
| availability | availability স্ক্রিন |
| occurrence | occurrence ডিটেইল |
| member approved | হোম |

> swap request ট্যাপে অনুরোধটি **সার্ভার থেকে id দিয়ে** লোড হয় (ক্যাশের প্রথম snapshot-এর
> জন্য অপেক্ষা নয়), যাতে ফোনের নোটিফিকেশন থেকে ঠান্ডা শুরু হলেও সত্যিকারের অনুরোধ "বন্ধ"
> না দেখায়। ইনবক্স স্ক্রিনে "সব পড়া হয়েছে" ও "সব বিজ্ঞপ্তি মুছুন" (soft delete/archive)
> আছে।

---

## ৫. রিমাইন্ডার — বিস্তারিত

### ৫.১ সেটিংস কোথায় থাকে

* **পরিবারের ডিফল্ট** (`settings` ডকে, admin/manager): `NotificationDefaults` —
  global/category সুইচ, ডিফল্ট offset, overdue, সকালের সারাংশ, নীরব সময়।
* **সদস্যের নিজের override** (লোকাল + সিঙ্ক): `MemberNotificationPrefs`। যেসব ফিল্ড null,
  সেগুলো পরিবারের ডিফল্ট থেকে **উত্তরাধিকার** পায় (`inheritFrom`)।
* **টেমপ্লেট স্তর** (`choreTemplates.reminders`): `{enabled, atDue, offsetsMinutes[≤5],
  overdueEnabled, overdueAfterMinutes}`।

সেটিংস স্ক্রিন: `NotificationSettingsScreen` — মাস্টার সুইচ, বিভাগ, সময় (offset),
সকালের সারাংশ, নীরব সময়, পুশ সুইচ, পরিবারের ডিফল্ট, পরীক্ষামূলক বিজ্ঞপ্তি বোতাম, এবং
"পরিবারের ডিফল্ট ব্যবহার করুন"।

### ৫.২ অগ্রাধিকার (precedence) — কেন রিমাইন্ডার আসে বা আসে না

`ReminderPrecedence.resolve` ক্রম অনুযায়ী সিদ্ধান্ত নেয়:

1. **global off** → কিছুই আসে না (সময় সংরক্ষিত থাকে)।
2. **category off** → ওই বিভাগের কিছুই আসে না।
3. **template off** → শুধু ওই টেমপ্লেটের সময় বাদ যায়।
4. **template no timings** → টেমপ্লেট চালু কিন্তু atDue/offset/overdue কিছুই নেই → আসে না।
5. নাহলে **ok** → নিচের টাইমিং নিয়মে রিমাইন্ডার প্ল্যান হয়।

টেমপ্লেটে কিছু দেওয়া থাকলে তা পরিবারের ডিফল্টকে ছাপিয়ে যায়; না থাকলে ডিফল্ট ব্যবহৃত হয়।

### ৫.৩ প্ল্যানার কীভাবে হিসাব করে (`ReminderPlanner`)

* **উইন্ডো:** পরের ৭ দিন (`kReminderWindowDays`), সর্বোচ্চ ৬০টি (`kMaxPlannedNotifications`)।
* **যোগ্য কাজ:** assignee = আপনি, খোলা (scheduled/in-progress), unavailable নয়, এবং
  projected কাজ যার সময় পেরিয়ে গেছে নয়।
* **প্রতিটি যোগ্য কাজে:** atDue হলে due-এ `chore_due` (বা dueMinutes না থাকলে `evening_nudge`),
  প্রতিটি offset-এ `chore_due`, overdue চালু হলে due+overdueAfter-এ `chore_overdue`।
* **সারাংশ:** যে দিনে ≥১টি কাজ বাকি, সেদিন `morning_summary`।
* **বাজার:** চাঁদা বাকি থাকলে নির্ধারিত দিন-১ ও দিন-এ `contribution_due`; মাস বন্ধযোগ্য হলে
  মাসশেষে `month_end`।
* **বাতিল শর্ত:** সময় পেরিয়ে গেছে (>৫ সেকেন্ড সহনশীলতা) বা উইন্ডোর বাইরে → বাদ।

### ৫.৪ নীরব সময় (Quiet hours)

ডিফল্ট **২৩:০০–০৬:০০**, চালু। কোনো রিমাইন্ডার নীরব সময়ে পড়লে সেটি নীরব শেষে (০৬:০০-এ)
সরানো হয়। কিন্তু সরানোর ফলে যদি সেটি **due + ৬ ঘণ্টা** (`kQuietStaleAfterDueHours`) ছাড়িয়ে
যায়, তবে রিমাইন্ডারটি বাদ দেওয়া হয় (দেরিতে অর্থহীন নয় বলে)। শেষ-সময়ের নিয়ম শুধু সময়ভিত্তিক
রিমাইন্ডারে; সারাংশ/বাজারে due না থাকায় শুধু সরানো হয়।

### ৫.৫ সিঙ্ক (`ReminderSyncController`)

* প্ল্যান বদলালে **২ সেকেন্ড debounce** (`kReminderSyncDebounce`)।
* নতুন প্ল্যানের সাথে pending-এর তুলনা করে: যা বাদ পড়েছে/বদলেছে বাতিল, যা নতুন শিডিউল।
* একই প্ল্যান হলে (hash একই) কিছুই করে না।
* **অ্যাপ resumed** হলে সময় অঞ্চল বদলেছে কিনা দেখে, দরকারে প্ল্যান রিফ্রেশ করে
  (`ReminderLifecycleObserver`)।
* পরিবার/সেশন বদলালে বা লগআউটে সব বাতিল (`stop`); মডিউল বন্ধ হলে ওই বিভাগের সব বাতিল।
* প্ল্যান প্রতি **১৫ মিনিটে** টিক করে (`kReminderPlanTickInterval`)।

### ৫.৬ শিডিউলিং ও চ্যানেল

* Android চ্যানেল (`notification_channels.dart`), সাউন্ড `family_hub_chime`, আইকন
  `ic_stat_family_hub`:
  * `chores_due_v2` — উচ্চ গুরুত্ব
  * `chores_overdue_v2` — ডিফল্ট
  * `daily_summary_v2` — ডিফল্ট
  * `bazar_v2` — ডিফল্ট
  * `family_v2` — ডিফল্ট
  * `push_events_v2` — উচ্চ গুরুত্ব
* **সঠিক সময়** (`exactAllowWhileIdle`) যদি exact-alarm অনুমতি থাকে, নাহলে
  **inexact** (`inexactAllowWhileIdle`)।
* প্রতিটি শিডিউলের মেটাডেটা লোকালি সংরক্ষিত, তাই reboot-এর পর pending ফিরে আসে।
* বিজ্ঞপ্তির id = `NotificationIdFactory` (kind+refId+discriminator-এর stable hash), তাই
  একই রিমাইন্ডার বারবার একই id পায় (ডুপ্লিকেট নয়)।

### ৫.৭ "কেন এই রিমাইন্ডার আসছে/আসছে না" ব্যাখ্যা

কাজের ডিটেইলে `ReminderWhyLine` একটি লাইন দেখায়, যা `ReminderExplainer.explain` থেকে আসে:

* আসবে → "পরের রিমাইন্ডার: {সময়}"।
* আসবে না → কারণ: সব বন্ধ / বিভাগ বন্ধ / টেমপ্লেট বন্ধ / টেমপ্লেটে সময় নেই / আপনাকে বরাদ্দ
  নয় / কাজ খোলা নেই / বিকল্প দরকার / পরিকল্পিত কাজের সময় পেরিয়েছে / এখন কোনো রিমাইন্ডার নেই।
* পুশ হলে → "এটি পুশ হিসেবে পাঠানো হবে।"

---

## ৬. অনুমতি, ডায়াগনস্টিকস ও সমস্যা সমাধান

* **Android ১৩+ নোটিফিকেশন অনুমতি:** প্রথম লঞ্চে জিজ্ঞাসা করা হয় না; ইন-অ্যাপ ব্যাখ্যা থেকে
  অনুরোধ করা হয় (`PermissionBanner`)। সেশন সক্রিয় হলে পুশ controller একবার অনুরোধ করে।
* **Exact alarm (Android ১২/১৪+):** `SCHEDULE_EXACT_ALARM` special access। না থাকলে রিমাইন্ডার
  inexact হয় এবং UI জানায় ("সঠিক সময়ের অ্যালার্ম বন্ধ; রিমাইন্ডার দেরিতে আসতে পারে।")।
  অ্যাপ `USE_EXACT_ALARM` ঘোষণা করে না।
* **ডায়াগনস্টিকস** (`RemindersHelpScreen`, `notificationHelpTitle` = "রিমাইন্ডার কাজ না করলে"):
  অনুমতি অবস্থা, pending সংখ্যা, পরের ফায়ার সময়, শেষ error, Android SDK।
* **চেকলিস্ট** (UI-তে): বিজ্ঞপ্তির অনুমতি দিন; সঠিক অ্যালার্মের অনুমতি দিন; ব্যাটারি সীমাবদ্ধতা
  সরান; অ্যাপ জোর করে বন্ধ করবেন না; দিনে অন্তত একবার অ্যাপ খুলুন।
* **সততার বার্তা** (`notificationNoSenderHonesty`): রিমাইন্ডার এই ফোনে লোড হওয়া তথ্য থেকে
  নির্ধারিত; অন্য কেউ কিছু করলে অ্যাপ বন্ধ থাকলে তা অ্যাপ খুললে দেখা যাবে; বিনামূল্যের প্ল্যানে
  পুশ পাঠানোর ব্যবস্থা নেই।
* **পরীক্ষামূলক বিজ্ঞপ্তি:** সেটিংসে বোতাম — ১০ সেকেন্ড পরে `family` চ্যানেলে একটি টেস্ট।

সম্পূর্ণ ডিভাইস চেকলিস্ট: `docs/reminders_manual_test.md` ও `docs/push_manual_test.md`।

---

## ৭. সীমাবদ্ধতা ও ভবিষ্যৎ

* **Spark প্ল্যান:** পুশ *পাঠানো* সম্ভব নয় (Cloud Functions/Blaze দরকার)। তাই এখন সব Normal।
  swap request বা reassign অ্যাপ খোলার সময় ইনবক্সে জানা যায়।
* **পুশ চালু হলে যা মানতে হবে** (`0020` অনুযায়ী): credential সার্ভারে থাকবে; সংরক্ষিত
  delivery policy মানবে; payload-এ ব্যক্তির নাম/টাকা/uid থাকবে না; মাস্টার `pushEnabled`
  ডিফল্ট বন্ধ, চালু করলে per-type recommended মোড কার্যকর হয়।
* **pushCapable = false** টাইপগুলো (due, overdue, nudge, summary, contribution, month end,
  budget alert, achievement) সবসময় Normal, কারণ এগুলো ফোনেই হিসাব হয়।
* ভবিষ্যতের scheduled sweeper (`P4-26`) আরও টাইপ push-capable করতে পারে, মডেল না বদলেই।

---

## ৮. সম্পর্কিত ফাইল (দ্রুত রেফারেন্স)

| কাজ | ফাইল |
| --- | --- |
| বিজ্ঞপ্তির ধরন ও ডিফল্ট মোড | `lib/core/notifications/domain/notification_type.dart` |
| Normal/Push সিদ্ধান্ত | `lib/core/notifications/domain/delivery_policy.dart` |
| রিমাইন্ডার প্ল্যানিং | `lib/core/notifications/domain/reminder_planner.dart`, `reminder_planner_parts.dart`, `reminder_plan_input.dart` |
| অগ্রাধিকার ও ব্যাখ্যা | `lib/core/notifications/domain/reminder_precedence.dart`, `reminder_explainer.dart` |
| সেটিংস মডেল | `lib/core/notifications/domain/reminder_settings.dart` |
| শিডিউলিং ও চ্যানেল | `lib/core/notifications/data/local_notifications_scheduler.dart`, `notification_channels.dart` |
| ট্যাপ রাউটিং | `lib/core/notifications/domain/notification_tap_router.dart` |
| পুশ receive | `lib/core/notifications/data/push_messaging_service.dart`, `presentation/push_controller*.dart` |
| সিঙ্ক ও lifecycle | `lib/features/notifications/presentation/reminder_sync_controller.dart`, `reminder_providers.dart`, `lifecycle_observer.dart` |
| ইনবক্স (ডেটা/লজিক/UI) | `lib/features/notifications/domain/inbox_*.dart`, `virtual_inbox.dart`, `data/firestore_inbox_repository.dart`, `presentation/inbox_*.dart` |
| সেটিংস ও হেল্প স্ক্রিন | `lib/features/notifications/presentation/notification_settings_screen.dart`, `reminders_help_screen.dart` |
| বাংলা টেক্সট | `lib/core/localization/arb/app_bn.arb` (`reminder*`, `notif*`, `inbox*`) |
