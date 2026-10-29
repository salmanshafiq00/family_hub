// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'ফ্যামিলি হাব';

  @override
  String get navHome => 'হোম';

  @override
  String get navChores => 'কাজ';

  @override
  String get navBazar => 'বাজার';

  @override
  String get navFamily => 'পরিবার';

  @override
  String get actionSave => 'সংরক্ষণ';

  @override
  String get actionCancel => 'বাতিল';

  @override
  String get actionRetry => 'আবার চেষ্টা করুন';

  @override
  String get actionDelete => 'মুছুন';

  @override
  String get actionEdit => 'সম্পাদনা';

  @override
  String get actionAdd => 'যোগ করুন';

  @override
  String get catalogEditorEmpty => 'এখনও কিছু নেই।';

  @override
  String get catalogEditorActions => 'সারির কাজ';

  @override
  String get catalogEditorActivate => 'আবার চালু করুন';

  @override
  String get catalogEditorDeactivate => 'বন্ধ করুন';

  @override
  String get catalogEditorAddTitle => 'নতুন সারি';

  @override
  String get catalogEditorEditTitle => 'সারি সম্পাদনা';

  @override
  String get catalogEditorLabelBn => 'নাম (বাংলা)';

  @override
  String get catalogEditorLabelEn => 'নাম (ইংরেজি, ঐচ্ছিক)';

  @override
  String get actionClose => 'বন্ধ করুন';

  @override
  String get actionBack => 'ফিরে যান';

  @override
  String get actionContinue => 'চালিয়ে যান';

  @override
  String get actionDone => 'সম্পন্ন';

  @override
  String get authSignInTitle => 'লগ ইন করুন';

  @override
  String get authSignUpTitle => 'নতুন অ্যাকাউন্ট খুলুন';

  @override
  String get authEmailLabel => 'ইমেইল';

  @override
  String get authPasswordLabel => 'পাসওয়ার্ড';

  @override
  String get authForgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get authSignOut => 'লগ আউট';

  @override
  String get authEmailVerificationSent => 'যাচাইকরণ ইমেইল পাঠানো হয়েছে।';

  @override
  String get authWelcomeHeadline => 'পরিবারের হিসাব, এক জায়গায়';

  @override
  String get authWelcomeMessage =>
      'বাজার খরচ, পরিবারের তহবিল আর কাজের রুটিন — সবাই মিলে একসাথে সামলান।';

  @override
  String get authGetStarted => 'শুরু করুন';

  @override
  String get authSignInAction => 'লগ ইন';

  @override
  String get authCreateAccountAction => 'নতুন অ্যাকাউন্ট খুলুন';

  @override
  String get authSignInSubtitle =>
      'আপনার ইমেইল ও পাসওয়ার্ড দিয়ে প্রবেশ করুন।';

  @override
  String get authSignUpSubtitle =>
      'অ্যাকাউন্ট খুললে একটি যাচাইকরণ ইমেইল পাঠানো হবে।';

  @override
  String get authNoAccountYet => 'অ্যাকাউন্ট নেই?';

  @override
  String get authAlreadyHaveAccount => 'আগেই অ্যাকাউন্ট আছে?';

  @override
  String get authShowPassword => 'পাসওয়ার্ড দেখান';

  @override
  String get authHidePassword => 'পাসওয়ার্ড লুকান';

  @override
  String get authEmailHint => 'যেমন name@example.com';

  @override
  String get authPasswordHint => 'অন্তত ৮ অক্ষর';

  @override
  String get authEmailConfirmed => 'ইমেইল';

  @override
  String get authPasswordTooShortHelper => 'কমপক্ষে ৮ অক্ষরের পাসওয়ার্ড দিন।';

  @override
  String get authPasswordConfirmLabel => 'পাসওয়ার্ড আবার লিখুন';

  @override
  String get authFailureValidationPasswordMismatch =>
      'দুটি পাসওয়ার্ড মিলছে না।';

  @override
  String get authFailureValidationPasswordConfirmRequired =>
      'পাসওয়ার্ডটি আবার লিখুন।';

  @override
  String get authForgotPasswordTitle => 'পাসওয়ার্ড রিসেট';

  @override
  String get authForgotPasswordSubtitle =>
      'ইমেইল দিন, আমরা একটি রিসেট লিংক পাঠাব।';

  @override
  String get authForgotPasswordSend => 'রিসেট লিংক পাঠান';

  @override
  String get authForgotPasswordSentTitle => 'ইমেইল পাঠানো হয়েছে';

  @override
  String authForgotPasswordSentMessage(String email) {
    return '$email ঠিকানায় একটি রিসেট লিংক পাঠানো হয়েছে। স্প্যাম ফোল্ডারও দেখে নিন।';
  }

  @override
  String get authVerifyEmailTitle => 'ইমেইল যাচাই করুন';

  @override
  String authVerifyEmailMessage(String email) {
    return '$email ঠিকানায় একটি যাচাইকরণ লিংক পাঠানো হয়েছে। লিংকে চাপ দিয়ে তারপর নিচের বাটনে চাপ দিন।';
  }

  @override
  String get authVerifyEmailIHaveVerified => 'আমি যাচাই করেছি';

  @override
  String get authVerifyEmailResend => 'আবার ইমেইল পাঠান';

  @override
  String get authVerifyEmailStillUnverified =>
      'এখনো যাচাই হয়নি। ইমেইলের লিংকে চাপ দিন, তারপর আবার চেষ্টা করুন।';

  @override
  String get authVerifyEmailVerified => 'ইমেইল যাচাই সম্পন্ন হয়েছে।';

  @override
  String get authVerifyEmailSignOutInstead => 'অন্য অ্যাকাউন্টে ঢুকুন';

  @override
  String authUsingAccount(String email) {
    return 'লগ ইন করা আছে: $email';
  }

  @override
  String get authFailurePermissionDenied => 'আপনার এই কাজটি করার অনুমতি নেই।';

  @override
  String get authFailureNotFound => 'আপনার অ্যাকাউন্টটি খুঁজে পাওয়া যায়নি।';

  @override
  String get authFailureConflict =>
      'কেউ ইতিমধ্যে তথ্য বদলেছে। অ্যাপটি আবার খুলে চেষ্টা করুন।';

  @override
  String get authFailureNetwork =>
      'ইন্টারনেট সংযোগ পাওয়া যায়নি। সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';

  @override
  String get authFailureInvalidCredentials => 'ইমেইল বা পাসওয়ার্ড ঠিক নয়।';

  @override
  String get authFailureUserNotFound => 'এই ইমেইলে কোনো অ্যাকাউন্ট নেই।';

  @override
  String get authFailureEmailInUse =>
      'এই ইমেইলে আগেই একটি অ্যাকাউন্ট আছে। লগ ইন করে দেখুন।';

  @override
  String get authFailureWeakPassword =>
      'পাসওয়ার্ডটি দুর্বল। অন্তত ৮ অক্ষরের পাসওয়ার্ড দিন।';

  @override
  String get authFailureTooManyRequests =>
      'অনেকবার চেষ্টা করা হয়েছে। কিছুক্ষণ পরে আবার চেষ্টা করুন।';

  @override
  String get authFailureUserDisabled =>
      'এই অ্যাকাউন্টটি বন্ধ করা হয়েছে। পরিবারের অ্যাডমিনের সাথে কথা বলুন।';

  @override
  String get authFailureRequiresRecentLogin =>
      'নিরাপত্তার জন্য আবার লগ ইন করুন, তারপর চেষ্টা করুন।';

  @override
  String get authFailureInvalidEmail => 'ইমেইল ঠিকানাটি সঠিক নয়।';

  @override
  String get authFailureNoCurrentUser =>
      'আপনি আগে লগ আউট করেছেন। আবার লগ ইন করুন।';

  @override
  String authFailureValidationRequired(String field) {
    return '$field পূরণ করুন।';
  }

  @override
  String get authFailureValidationInvalidEmail => 'সঠিক ইমেইল ঠিকানা দিন।';

  @override
  String get authFailureValidationPasswordTooShort =>
      'পাসওয়ার্ড অন্তত ৮ অক্ষরের হতে হবে।';

  @override
  String get authFailureUnknown => 'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get authFieldEmail => 'ইমেইল';

  @override
  String get authFieldPassword => 'পাসওয়ার্ড';

  @override
  String get errorPermissionDenied => 'আপনার এই কাজটি করার অনুমতি নেই।';

  @override
  String get errorNotFound => 'তথ্যটি খুঁজে পাওয়া যায়নি।';

  @override
  String get errorConflict =>
      'কেউ ইতিমধ্যে এই তথ্য পরিবর্তন করেছে। আবার চেষ্টা করুন।';

  @override
  String get errorNetwork =>
      'ইন্টারনেট সংযোগ পাওয়া যায়নি। সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।';

  @override
  String get errorUnknown => 'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।';

  @override
  String errorValidationRequired(String field) {
    return '$field পূরণ করুন।';
  }

  @override
  String get errorValidationEmail => 'সঠিক ইমেইল ঠিকানা দিন।';

  @override
  String get errorValidationPasswordTooShort =>
      'পাসওয়ার্ড অন্তত ৮ অক্ষরের হতে হবে।';

  @override
  String get emptyGenericTitle => 'এখনো কিছু নেই';

  @override
  String get emptyGenericMessage => 'শুরু করতে নিচের বাটনে চাপ দিন।';

  @override
  String get emptyNoDataTitle => 'কোনো তথ্য নেই';

  @override
  String get emptyNoDataMessage => 'এই তালিকাটি এখন খালি।';

  @override
  String get loadingGeneric => 'লোড হচ্ছে…';

  @override
  String get offlineBanner => 'আপনি অফলাইনে আছেন। সংযোগ ফিরলে তথ্য সিঙ্ক হবে।';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get settingsThemeTitle => 'অ্যাপিয়ারেন্স';

  @override
  String get settingsThemeMode => 'থিম মোড';

  @override
  String get settingsColourPalette => 'রঙের প্যালেট';

  @override
  String get settingsFollowDevice => 'ডিভাইস অনুসরণ করুন';

  @override
  String get settingsFollowDeviceSubtitle =>
      'আপনার সিস্টেমের আলো / অন্ধকার সেটিং ব্যবহার করবে';

  @override
  String get settingsThemeSelected => 'নির্বাচিত';

  @override
  String settingsThemeSelectedSemantics(String theme) {
    return '$theme থিম, নির্বাচিত';
  }

  @override
  String settingsThemeUnselectedSemantics(String theme) {
    return '$theme থিম';
  }

  @override
  String get settingsLanguageTitle => 'ভাষা';

  @override
  String get settingsLanguageSection => 'ভাষা নির্বাচন করুন';

  @override
  String get settingsLanguageBangla => 'বাংলা';

  @override
  String get settingsLanguageEnglish => 'ইংরেজি';

  @override
  String get settingsLanguageSubtitle =>
      'অ্যাপের ভাষা তাৎক্ষণিকভাবে পরিবর্তিত হয়';

  @override
  String get settingsBanglaDigits => 'বাংলা অঙ্ক ব্যবহার করুন';

  @override
  String get settingsBanglaDigitsSubtitle =>
      'সংখ্যা ও তারিখ বাংলা অঙ্কে (০১২৩) দেখাবে';

  @override
  String settingsLanguageSelectedSemantics(String language) {
    return '$language ভাষা, নির্বাচিত';
  }

  @override
  String get languageNameBn => 'বাংলা';

  @override
  String get languageNameEn => 'English';

  @override
  String get devTokensTitle => 'ডেভ — থিম টোকেন';

  @override
  String get devGalleryTitle => 'ডেভ — গ্যালারি';

  @override
  String get homeViewThemeTokens => 'থিম টোকেন দেখুন';

  @override
  String get moduleComingSoonTitle => 'শীঘ্রই আসছে';

  @override
  String get moduleComingSoonMessage => 'এই অংশটি এখনো তৈরি হচ্ছে।';

  @override
  String get bazarHomeEmptyTitle => 'বাজার এখনো খালি';

  @override
  String get bazarHomeEmptyMessage =>
      'খরচ, বাজার তালিকা ও হিসাবের অংশগুলো ধাপে ধাপে এখানে যোগ হবে।';

  @override
  String get bazarCatalogSetupTitle => 'স্টার্টার বাজার তালিকা সেট করুন';

  @override
  String get bazarCatalogSetupMessage =>
      'শুরু করার জন্য ১১টি ক্যাটাগরি ও ৫৪টি সাধারণ আইটেম যোগ করুন। পরে আপনি সেগুলো সম্পাদনা, যোগ বা লুকাতে পারবেন।';

  @override
  String get bazarCatalogSetupAction => 'তালিকা তৈরি করুন';

  @override
  String get bazarCatalogSetupBusy => 'বাজার তালিকা তৈরি হচ্ছে…';

  @override
  String get bazarCatalogAskAdminTitle => 'বাজার তালিকা তৈরি হয়নি';

  @override
  String get bazarCatalogAskAdminMessage =>
      'বাজার তালিকা তৈরি করতে একজন অ্যাডমিনকে বলুন।';

  @override
  String get bazarSettingsTitle => 'বাজারের সেটিংস';

  @override
  String get unitKg => 'কেজি';

  @override
  String get unitG => 'গ্রাম';

  @override
  String get unitLitre => 'লিটার';

  @override
  String get unitPiece => 'পিস';

  @override
  String get unitDozen => 'ডজন';

  @override
  String get unitPacket => 'প্যাকেট';

  @override
  String get unitCylinder => 'সিলিন্ডার';

  @override
  String get bazarFundingFund => 'পরিবারের তহবিল';

  @override
  String get bazarFundingMember => 'সদস্য পরিশোধিত';

  @override
  String get bazarAdvancePending => 'অপেক্ষমাণ';

  @override
  String get bazarAdvancePartial => 'আংশিক সমন্বিত';

  @override
  String get bazarAdvanceSettled => 'সমন্বিত';

  @override
  String get bazarAdvanceVoided => 'বাতিল';

  @override
  String get bazarErrRequired => 'এই ঘরটি পূরণ করুন।';

  @override
  String get bazarErrTooLong => 'লেখাটি অনেক বড় হয়ে গেছে।';

  @override
  String get bazarErrInvalidAmount => 'সঠিক অঙ্ক লিখুন।';

  @override
  String get bazarErrAmountNotPositive => 'অঙ্কটি শূন্যের বেশি হতে হবে।';

  @override
  String get bazarErrFutureDate => 'তারিখ ভবিষ্যতের হতে পারে না।';

  @override
  String get bazarErrQtyUnitRequired => 'পরিমাণ ও একক দুটোই দিন।';

  @override
  String get bazarErrMemberRequired => 'সদস্যটি বেছে নিন।';

  @override
  String get bazarErrCategoryRequired => 'ক্যাটাগরি বেছে নিন।';

  @override
  String get bazarErrItemNameRequired => 'আইটেমের নাম লিখুন।';

  @override
  String get bazarErrTooManyLines => 'সারি অনেক বেশি; কিছু সরিয়ে দিন।';

  @override
  String get bazarErrInvalidMonth => 'সঠিক মাস বেছে নিন।';

  @override
  String get bazarErrInvalidRange => 'শেষ তারিখ শুরুর তারিখের পরে হতে হবে।';

  @override
  String get bazarErrNegative => 'অঙ্ক ঋণাত্মক হতে পারে না।';

  @override
  String get bazarErrTooManyDecimals =>
      'সর্বোচ্চ দুই দশমিক স্থান ব্যবহার করুন।';

  @override
  String get bazarErrTooLarge => 'অঙ্কটি অনেক বড়।';

  @override
  String get bazarErrMonthLocked => 'এই মাস বন্ধ আছে। খুলতে অ্যাডমিনকে বলুন।';

  @override
  String get bazarErrAdvanceSettled =>
      'এই অগ্রিম আংশিক বা সম্পূর্ণ সমন্বয় হয়ে গেছে।';

  @override
  String get bazarErrOverpayment =>
      'বাকি থাকা অঙ্কের চেয়ে বেশি দেওয়া হয়েছে।';

  @override
  String get bazarErrAlreadyClosed => 'এই মাস ইতিমধ্যে বন্ধ আছে।';

  @override
  String get bazarErrNotClosed => 'এই মাস বন্ধ নয়।';

  @override
  String get bazarErrReopenNoteRequired => 'মাসটি কেন খুলছেন তা লিখুন।';

  @override
  String get bazarErrCatalogNotEmpty =>
      'তালিকায় এখনো আইটেম আছে; আগে সেগুলো আর্কাইভ করুন।';

  @override
  String get bazarErrDuplicateItem =>
      'ঠিক এই ধরনের খরচ সবেমাত্র যোগ হয়েছে। আবার সংরক্ষণের আগে দেখে নিন।';

  @override
  String get bazarErrImportAlreadyUndone => 'এই ইমপোর্ট আগেই বাতিল হয়েছে।';

  @override
  String get bazarErrImportHasLockedMonth => 'ফাইলে বন্ধ মাসের সারি আছে।';

  @override
  String get bazarErrConcurrentEdit =>
      'আপনার আগেই কেউ এটি বদলেছেন। রিফ্রেশ করে আবার চেষ্টা করুন।';

  @override
  String get bazarErrNotFound =>
      'রেকর্ডটি আর নেই। রিফ্রেশ করে আবার চেষ্টা করুন।';

  @override
  String get bazarErrNotAllowed =>
      'শুধু সংসার ব্যবস্থাপক বা অ্যাডমিন এটি করতে পারেন।';

  @override
  String get bazarErrUnknown => 'কিছু একটা সমস্যা হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get profileSetupTitle => 'আপনার প্রোফাইল তৈরি করুন';

  @override
  String get profileSetupMessage => 'পরিবারকে জানান আপনি কে।';

  @override
  String get familyChoiceTitle => 'পরিবারে যোগ দিন বা নতুন তৈরি করুন';

  @override
  String get familyChoiceMessage =>
      'নতুন পরিবার তৈরি করুন, অথবা আমন্ত্রণ কোড দিয়ে যোগ দিন।';

  @override
  String get pendingTitle => 'অনুমোদনের অপেক্ষায়';

  @override
  String get pendingMessage =>
      'চালিয়ে যেতে পরিবারের অ্যাডমিনকে আপনার অনুরোধ অনুমোদন করতে হবে।';

  @override
  String get disabledTitle => 'প্রবেশ বন্ধ আছে';

  @override
  String get disabledMessage =>
      'এই পরিবারে আপনার প্রবেশ বন্ধ করা হয়েছে। অনুগ্রহ করে অ্যাডমিনের সাথে যোগাযোগ করুন।';

  @override
  String get placeholderContinueProfile => 'চালিয়ে যান (অস্থায়ী)';

  @override
  String get placeholderCreateFamily =>
      'পরীক্ষামূলক পরিবার তৈরি করুন (অস্থায়ী)';

  @override
  String get placeholderApproveMe => 'অনুমোদিত ধরে নিন (অস্থায়ী)';

  @override
  String get notFoundTitle => 'পাতাটি পাওয়া যায়নি';

  @override
  String get notFoundMessage => 'আপনি যে পাতাটি খুলেছেন সেটি নেই।';

  @override
  String get notFoundAction => 'হোমে যান';

  @override
  String get profileFullName => 'পুরো নাম';

  @override
  String get profileNickname => 'ডাকনাম (ঐচ্ছিক)';

  @override
  String get profileGender => 'লিঙ্গ (ঐচ্ছিক)';

  @override
  String get genderMale => 'পুরুষ';

  @override
  String get genderFemale => 'নারী';

  @override
  String get genderOther => 'অন্যান্য';

  @override
  String get genderNone => 'বলতে চাই না';

  @override
  String get profileRelationship => 'সম্পর্ক';

  @override
  String get profileAvatar => 'একটি অ্যাভাটার বেছে নিন';

  @override
  String get profileSave => 'প্রোফাইল সংরক্ষণ করুন';

  @override
  String get profileSpouse => 'স্বামী/স্ত্রী (ঐচ্ছিক)';

  @override
  String get profileSpouseNone => 'কেউ নয়';

  @override
  String get relFather => 'বাবা';

  @override
  String get relMother => 'মা';

  @override
  String get relSon => 'ছেলে';

  @override
  String get relDaughter => 'মেয়ে';

  @override
  String get relHusband => 'স্বামী';

  @override
  String get relWife => 'স্ত্রী';

  @override
  String get relHousewife => 'গৃহিণী';

  @override
  String get relDaughterInLaw => 'পুত্রবধূ';

  @override
  String get relSonInLaw => 'জামাই';

  @override
  String get relOther => 'অন্যান্য';

  @override
  String get familyCreateAction => 'নতুন পরিবার তৈরি করুন';

  @override
  String get familyJoinAction => 'কোড দিয়ে যোগ দিন';

  @override
  String get familyNameLabel => 'পরিবারের নাম';

  @override
  String get familyCreateSubmit => 'পরিবার তৈরি করুন';

  @override
  String get joinCodeLabel => 'আমন্ত্রণ কোড';

  @override
  String get joinSubmit => 'যোগদানের অনুরোধ করুন';

  @override
  String get joinHint => 'পরিবারের অ্যাডমিনের কাছ থেকে ৮ অক্ষরের কোড নিন।';

  @override
  String get membersTitle => 'সদস্য';

  @override
  String get membersPending => 'অনুমোদনের অপেক্ষায়';

  @override
  String get membersActive => 'সক্রিয়';

  @override
  String get membersDisabled => 'নিষ্ক্রিয়';

  @override
  String get memberYou => 'আপনি';

  @override
  String get memberApprove => 'অনুমোদন';

  @override
  String get memberReject => 'প্রত্যাখ্যান';

  @override
  String get memberDisable => 'নিষ্ক্রিয় করুন';

  @override
  String get memberReenable => 'আবার সক্রিয় করুন';

  @override
  String get roleAdmin => 'অ্যাডমিন';

  @override
  String get roleModerator => 'সংসার ব্যবস্থাপক';

  @override
  String get roleMember => 'সদস্য';

  @override
  String get memberProfileTitle => 'সদস্যের প্রোফাইল';

  @override
  String get memberEditProfile => 'আমার প্রোফাইল সম্পাদনা';

  @override
  String get memberRoleLabel => 'ভূমিকা';

  @override
  String get memberStatusLabel => 'অবস্থা';

  @override
  String get invitationsTitle => 'আমন্ত্রণ';

  @override
  String get invitationCreate => 'আমন্ত্রণ কোড তৈরি করুন';

  @override
  String get invitationCopy => 'কোড কপি করুন';

  @override
  String get invitationCopied => 'কোড কপি হয়েছে';

  @override
  String get invitationExpiresOn => 'মেয়াদ শেষ';

  @override
  String get invStatusActive => 'অব্যবহৃত';

  @override
  String get invStatusUsed => 'ব্যবহৃত';

  @override
  String get invStatusExpired => 'মেয়াদোত্তীর্ণ';

  @override
  String get invStatusRevoked => 'বাতিল';

  @override
  String get invitationsEmpty => 'এখনো কোনো আমন্ত্রণ নেই';

  @override
  String get rolesTitle => 'ভূমিকা';

  @override
  String get rolesMakeAdmin => 'অ্যাডমিন বানান';

  @override
  String get rolesTransferTitle => 'অ্যাডমিনের দায়িত্ব হস্তান্তর করবেন?';

  @override
  String get rolesTransferMessage => 'আপনি সাধারণ সদস্য হয়ে যাবেন।';

  @override
  String get actionConfirm => 'নিশ্চিত করুন';

  @override
  String get familySettingsTitle => 'পরিবারের সেটিংস';

  @override
  String get settingsTimezone => 'সময় অঞ্চল';

  @override
  String get settingsCurrency => 'মুদ্রা';

  @override
  String get settingsModules => 'মডিউল';

  @override
  String get settingsSaved => 'সংরক্ষিত হয়েছে';

  @override
  String get famFailureNameRequired => 'একটি নাম লিখুন।';

  @override
  String get famFailureCodeInvalid =>
      'কোডটি সঠিক নয়। কোডে ৮টি অক্ষর ও সংখ্যা থাকে।';

  @override
  String get famFailureCodeNotFound => 'এই কোডে কোনো আমন্ত্রণ পাওয়া যায়নি।';

  @override
  String get famFailureCodeUsed => 'এই কোডটি আগেই ব্যবহার করা হয়েছে।';

  @override
  String get famFailureCodeExpired => 'কোডটির মেয়াদ শেষ। নতুন কোড চান।';

  @override
  String get famFailureCodeRevoked => 'কোডটি বাতিল করা হয়েছে।';

  @override
  String get famFailureAlreadyMember => 'আপনি ইতিমধ্যে এই পরিবারে আছেন।';

  @override
  String get famFailureLastAdmin =>
      'পরিবারে অন্তত একজন অ্যাডমিন থাকতে হবে। আগে অন্য কাউকে অ্যাডমিন বানান।';

  @override
  String get famFailureTooManyAdmins =>
      'একটি পরিবারে সর্বোচ্চ তিনজন অ্যাডমিন থাকতে পারে।';

  @override
  String get famFailureNotAllowed => 'এটি করার অনুমতি আপনার নেই।';

  @override
  String get famFailureProfileRequired => 'আগে আপনার প্রোফাইল সম্পূর্ণ করুন।';

  @override
  String avatarOption(String number) {
    return 'অ্যাভাটার $number';
  }

  @override
  String get statusScheduled => 'সময় নির্ধারিত';

  @override
  String get statusInProgress => 'চলছে';

  @override
  String get statusCompleted => 'সম্পন্ন';

  @override
  String get statusVerified => 'যাচাইকৃত';

  @override
  String get statusOverdue => 'সময় পার হয়েছে';

  @override
  String get commonSeeAll => 'সব দেখুন';

  @override
  String get errorViewTitle => 'কিছু ভুল হয়েছে';

  @override
  String get loadingSemantics => 'লোড হচ্ছে';

  @override
  String progressSemantics(String label, String percent) {
    return '$label, $percent শতাংশ সম্পন্ন';
  }

  @override
  String thumbSemantics(String name) {
    return '$name ছবি';
  }

  @override
  String get galleryAvatar => 'অ্যাভাটার';

  @override
  String get galleryItemThumb => 'জিনিসের ছবি';

  @override
  String get galleryStatusChip => 'অবস্থার চিপ';

  @override
  String get galleryStatusGlyph => 'অবস্থার চিহ্ন';

  @override
  String get galleryFlagChip => 'ফ্ল্যাগ চিপ';

  @override
  String get galleryReasonSheet => 'কারণ শিট';

  @override
  String get galleryMinutesField => 'সময়ের ঘর';

  @override
  String get galleryWeekdayChips => 'বার বাছাই';

  @override
  String get galleryColorSwatchPicker => 'রং বাছাই';

  @override
  String get galleryAvatarStack => 'অ্যাভাটার সারি';

  @override
  String get galleryStepProgress => 'ধাপের অগ্রগতি';

  @override
  String get galleryMiniMarkdown => 'ঘরের নিয়মের লেখা';

  @override
  String get galleryCatalogEditor => 'তালিকা সম্পাদনা';

  @override
  String get galleryOpenSheet => 'শিট খুলুন';

  @override
  String get gallerySampleDueTime => 'শেষ সময়';

  @override
  String get gallerySampleRules =>
      '# ঘরের নিয়ম\n- খাওয়ার পর নিজের প্লেট ধুয়ে রাখা\n- **সকাল ৯টার মধ্যে রান্নাঘর খালি থাকতে হবে**\n1. গাছে পানি দেওয়া\n2. উঠান ঝাঁট দেওয়া';

  @override
  String get gallerySectionHeader => 'সেকশন হেডার';

  @override
  String get galleryAppCard => 'কার্ড';

  @override
  String get galleryMoneyText => 'টাকার লেখা';

  @override
  String get galleryProgressRing => 'প্রগ্রেস রিং';

  @override
  String get galleryEmptyState => 'খালি অবস্থা';

  @override
  String get galleryLoadingView => 'লোডিং দৃশ্য';

  @override
  String get galleryErrorView => 'ত্রুটির দৃশ্য';

  @override
  String get galleryPillBottomBar => 'পিল নেভিগেশন বার';

  @override
  String get gallerySampleTitle => 'নমুনা শিরোনাম';

  @override
  String get gallerySampleMessage =>
      'এটি একটি নমুনা বার্তা যা ওভারফ্লো যাচাই করে।';

  @override
  String get gallerySampleItemName => 'আলু';

  @override
  String get gallerySamplePersonName => 'করিম উদ্দিন';

  @override
  String get syncWaitingTitle => 'সংযোগের অপেক্ষায়…';

  @override
  String get syncWaitingMessage =>
      'ইন্টারনেট সংযোগ আছে কিনা দেখুন, তারপর আবার চেষ্টা করুন। আপনার তথ্য নিরাপদ আছে।';

  @override
  String get syncSavedOffline =>
      'এই ডিভাইসে সংরক্ষিত হয়েছে — অনলাইনে এলে সিঙ্ক হবে';

  @override
  String syncBannerSyncing(int count) {
    return '$countটি পরিবর্তন সিঙ্ক হচ্ছে';
  }

  @override
  String syncBannerOffline(int count) {
    return 'অফলাইন — $countটি পরিবর্তন অপেক্ষায়';
  }

  @override
  String get gallerySyncBanner => 'সিঙ্ক ব্যানার';

  @override
  String get famFailureAlreadyInFamily =>
      'আপনি ইতিমধ্যে একটি পরিবারে আছেন। আগে সেটি ছেড়ে দিন।';

  @override
  String get familyLeave => 'পরিবার ছেড়ে যান';

  @override
  String get familyLeaveConfirmTitle => 'পরিবার ছেড়ে যাবেন?';

  @override
  String get familyLeaveConfirmBody =>
      'আপনার আগের কাজ ও হিসাবের ইতিহাস পরিবারে থেকে যাবে। পরে আপনি নতুন পরিবার খুলতে বা অন্য পরিবারে যোগ দিতে পারবেন।';

  @override
  String get familyLeaveLastAdminReason =>
      'আপনিই একমাত্র অ্যাডমিন। ছেড়ে যাওয়ার আগে আরেকজনকে অ্যাডমিন করুন।';

  @override
  String get pendingCancelRequest => 'অনুরোধ বাতিল করুন';

  @override
  String get invitationRevoke => 'কোড বাতিল করুন';

  @override
  String get invitationRevokeConfirmTitle => 'কোডটি বাতিল করবেন?';

  @override
  String get invitationRevokeConfirmBody =>
      'এই কোড দিয়ে আর কেউ যোগ দিতে পারবে না।';

  @override
  String get securityTitle => 'নিরাপত্তা';

  @override
  String get securityChangePassword => 'পাসওয়ার্ড পরিবর্তন';

  @override
  String get securityCurrentPassword => 'বর্তমান পাসওয়ার্ড';

  @override
  String get securityNewPassword => 'নতুন পাসওয়ার্ড';

  @override
  String get securityPasswordChanged => 'পাসওয়ার্ড পরিবর্তন হয়েছে।';

  @override
  String get securityPasswordSame =>
      'নতুন পাসওয়ার্ড বর্তমানটির থেকে আলাদা হতে হবে।';

  @override
  String get securityCurrentPasswordRequired =>
      'আপনার বর্তমান পাসওয়ার্ড লিখুন।';

  @override
  String get securityCurrentPasswordWrong => 'বর্তমান পাসওয়ার্ডটি সঠিক নয়।';

  @override
  String get securityDeleteTitle => 'আমার অ্যাকাউন্ট মুছুন';

  @override
  String get securityDeleteBody =>
      'আপনি পরিবার ছেড়ে যাবেন এবং আপনার সাইন-ইন মুছে যাবে। পরিবারের ইতিহাস ঠিক রাখতে পুরোনো রেকর্ডে আপনার নাম থাকবে।';

  @override
  String get securityDeletePending =>
      'মুছে ফেলা শেষ হয়নি। শেষ করতে পাসওয়ার্ড লিখুন।';

  @override
  String get securityDeleteAction => 'অ্যাকাউন্ট মুছুন';

  @override
  String get securityDeleteFinish => 'মুছে ফেলা শেষ করুন';

  @override
  String get securityDeleteConfirmTitle => 'আপনার অ্যাকাউন্ট মুছবেন?';

  @override
  String get securityDeleteConfirmBody => 'এটি আর ফেরানো যাবে না।';

  @override
  String get accountDeleteLastAdminHasMembers =>
      'আপনি একমাত্র অ্যাডমিন এবং পরিবারে আরও সদস্য আছেন। আগে অ্যাডমিনের দায়িত্ব হস্তান্তর করুন।';

  @override
  String get relationshipsTitle => 'সম্পর্কের তালিকা';

  @override
  String get relationshipsHint =>
      'তৈরি-করা সম্পর্কগুলো পরিবর্তন করা যায় না। নিজের সম্পর্ক যোগ, নাম পরিবর্তন বা বন্ধ করতে পারেন।';

  @override
  String get relationshipsAdd => 'সম্পর্ক যোগ করুন';

  @override
  String get relationshipsLabelBn => 'বাংলায় নাম';

  @override
  String get relationshipsLabelEn => 'ইংরেজিতে নাম';

  @override
  String get relationshipsSpouseRelevant => 'স্বামী/স্ত্রী বাছাই দেখান';

  @override
  String get relationshipsBuiltIn => 'তৈরি-করা';

  @override
  String get relationshipsActive => 'চালু';

  @override
  String get relationshipsDisabled => 'বন্ধ';

  @override
  String get relationshipsEnable => 'চালু করুন';

  @override
  String get relationshipsDisable => 'বন্ধ করুন';

  @override
  String get relationshipsFailureLabel => 'একটি নাম লিখুন (সর্বোচ্চ ৪০ অক্ষর)।';

  @override
  String get relationshipsFailureTooMany => 'তালিকা পূর্ণ।';

  @override
  String get relationshipsFailureBuiltIn =>
      'তৈরি-করা সম্পর্ক পরিবর্তন করা যায় না।';

  @override
  String activityFamilyCreated(String familyName) {
    return 'পরিবার “$familyName” তৈরি হয়েছে';
  }

  @override
  String get activityFamilyUpdated => 'পরিবারের সেটিংস হালনাগাদ হয়েছে';

  @override
  String activityMemberRequested(String memberName) {
    return '$memberName যোগ দিতে অনুরোধ করেছেন';
  }

  @override
  String activityMemberApproved(String memberName) {
    return '$memberName-কে অনুমোদন দেওয়া হয়েছে';
  }

  @override
  String activityMemberRejected(String memberName) {
    return '$memberName-কে গ্রহণ করা হয়নি';
  }

  @override
  String activityMemberDisabled(String memberName) {
    return '$memberName-কে বন্ধ করা হয়েছে';
  }

  @override
  String activityMemberRoleChanged(String memberName, String newRole) {
    return '$memberName এখন $newRole';
  }

  @override
  String activityAdminTransferred(String memberName) {
    return 'অ্যাডমিনের দায়িত্ব $memberName-কে দেওয়া হয়েছে';
  }

  @override
  String activityMemberLeft(String memberName) {
    return '$memberName পরিবার ছেড়ে গেছেন';
  }

  @override
  String activityMemberCancelled(String memberName) {
    return '$memberName অনুরোধ প্রত্যাহার করেছেন';
  }

  @override
  String activityInvitationCreated(String code) {
    return 'আমন্ত্রণ $code তৈরি হয়েছে';
  }

  @override
  String activityInvitationRevoked(String code) {
    return 'আমন্ত্রণ $code বাতিল হয়েছে';
  }

  @override
  String activityBazarCatalogSeeded(String categories, String items) {
    return '$categoriesটি ক্যাটাগরি ও $itemsটি আইটেম দিয়ে বাজারের তালিকা চালু হয়েছে';
  }

  @override
  String activityBazarCategoryCreated(String name) {
    return 'ক্যাটাগরি “$name” যোগ করা হয়েছে';
  }

  @override
  String activityBazarCategoryUpdated(String name) {
    return 'ক্যাটাগরি “$name” হালনাগাদ হয়েছে';
  }

  @override
  String activityBazarCategoryDeactivated(String name) {
    return 'ক্যাটাগরি “$name” আর্কাইভ করা হয়েছে';
  }

  @override
  String activityBazarItemCreated(String name) {
    return 'আইটেম “$name” যোগ করা হয়েছে';
  }

  @override
  String activityBazarItemUpdated(String name) {
    return 'আইটেম “$name” হালনাগাদ হয়েছে';
  }

  @override
  String activityBazarItemDeactivated(String name) {
    return 'আইটেম “$name” আর্কাইভ করা হয়েছে';
  }

  @override
  String activityBazarExpenseCreated(
    String item,
    String amount,
    String funding,
  ) {
    return '$item কেনা হয়েছে $amount দিয়ে ($funding)';
  }

  @override
  String activityBazarExpenseUpdated(String item, String fields) {
    return '$item সম্পাদনা করা হয়েছে ($fields)';
  }

  @override
  String activityBazarExpenseDeleted(String item, String amount) {
    return '$item মুছে ফেলা হয়েছে ($amount)';
  }

  @override
  String activityBazarExpenseRestored(String item, String amount) {
    return '$item ফিরিয়ে আনা হয়েছে ($amount)';
  }

  @override
  String activityBazarTripCreated(String lines, String amount) {
    return '$linesটি আইটেমের বাজার যাত্রা $amount দিয়ে সংরক্ষণ হয়েছে';
  }

  @override
  String activityBazarBudgetSaved(String month, String amount) {
    return '$month-এর বাজেট $amount নির্ধারণ করা হয়েছে';
  }

  @override
  String get activityBazarSettingsUpdated => 'বাজারের সেটিংস হালনাগাদ হয়েছে';

  @override
  String activityBazarContributionPlanSet(
    String month,
    String member,
    String amount,
  ) {
    return '$month-এ $member-এর চাঁদা $amount নির্ধারণ করা হয়েছে';
  }

  @override
  String activityBazarContributionRecorded(
    String month,
    String member,
    String amount,
  ) {
    return '$month-এ $member-এর $amount চাঁদা রেকর্ড করা হয়েছে';
  }

  @override
  String activityBazarContributionVoided(
    String month,
    String member,
    String amount,
  ) {
    return '$month-এ $member-এর $amount চাঁদা বাতিল করা হয়েছে';
  }

  @override
  String activityBazarContributionRequested(
    String month,
    String member,
    String amount,
  ) {
    return '$month-এর জন্য $member $amount দিতে চেয়েছেন';
  }

  @override
  String activityBazarContributionRequestEdited(
    String month,
    String member,
    String amount,
  ) {
    return '$month-এর জন্য $member $amount দেওয়ার অনুরোধ সম্পাদনা করেছেন';
  }

  @override
  String activityBazarContributionRequestCancelled(
    String month,
    String member,
    String amount,
  ) {
    return '$month-এর জন্য $member $amount দেওয়ার অনুরোধ প্রত্যাহার করেছেন';
  }

  @override
  String activityBazarContributionApproved(
    String month,
    String member,
    String amount,
  ) {
    return '$month-এ $member-এর $amount চাঁদা অনুমোদিত হয়েছে';
  }

  @override
  String activityBazarContributionRejected(
    String month,
    String member,
    String amount,
    String reason,
  ) {
    return '$month-এ $member-এর $amount চাঁদা গ্রহণ করা হয়নি ($reason)';
  }

  @override
  String activityBazarContributionChangeRequested(
    String month,
    String member,
    String amount,
    String old,
  ) {
    return '$month-এর জন্য $member $old থেকে $amount-এ চাঁদা বদলাতে বলেছেন';
  }

  @override
  String activityBazarContributionChangeApproved(
    String month,
    String member,
    String amount,
    String old,
  ) {
    return '$month-এ $member-এর চাঁদা $old থেকে $amount-এ বদলের অনুমোদন হয়েছে';
  }

  @override
  String activityBazarContributionChangeRejected(
    String month,
    String member,
    String amount,
    String old,
  ) {
    return '$month-এ $member-এর চাঁদা $old থেকে $amount-এ বদলের অনুমোদন হয়নি';
  }

  @override
  String activityBazarOpeningBalanceSet(String month, String amount) {
    return '$month-এর প্রারম্ভিক ব্যালেন্স $amount';
  }

  @override
  String activityBazarAdvanceSettled(
    String member,
    String amount,
    String status,
  ) {
    return '$member-এর অগ্রিম $amount সমন্বয় হয়েছে ($status)';
  }

  @override
  String activityBazarMonthClosed(String month, String balance) {
    return '$month বন্ধ করা হয়েছে, ব্যালেন্স $balance';
  }

  @override
  String activityBazarMonthReopened(String month, String note) {
    return '$month আবার খোলা হয়েছে ($note)';
  }

  @override
  String activityBazarImportCompleted(String rows, String amount) {
    return 'ইমপোর্ট শেষ: $rowsটি সারি, $amount';
  }

  @override
  String activityBazarImportUndone(String rows, String amount) {
    return 'ইমপোর্ট বাতিল: $rowsটি সারি, $amount';
  }

  @override
  String get activityUnknown => 'কিছু পরিবর্তন হয়েছে';

  @override
  String get galleryMonthSwitcher => 'মাস পরিবর্তনকারী';

  @override
  String get galleryAmountField => 'পরিমাণের ঘর';

  @override
  String get galleryTotalDisplay => 'মোট প্রদর্শন';

  @override
  String get galleryProgressBarStatus => 'সীমার অগ্রগতি বার';

  @override
  String get galleryDaySectionHeader => 'দিনের শিরোনাম';

  @override
  String get galleryPersonPicker => 'ব্যক্তি নির্বাচন';

  @override
  String get galleryCategoryBadge => 'ক্যাটেগরি ব্যাজ';

  @override
  String get monthSwitcherPrevious => 'আগের মাস';

  @override
  String get monthSwitcherNext => 'পরের মাস';

  @override
  String get monthSwitcherPick => 'মাস বেছে নিন';

  @override
  String get monthPickerPreviousYear => 'আগের বছর';

  @override
  String get monthPickerNextYear => 'পরের বছর';

  @override
  String get totalDisplayCalculated => 'পরিমাণ × দর থেকে হিসাব করা';

  @override
  String get totalDisplayEmpty => 'মোট এখনো নেই';

  @override
  String get progressLevelOk => 'ঠিক আছে';

  @override
  String get progressLevelWarning => 'সীমার কাছাকাছি';

  @override
  String get progressLevelExceeded => 'সীমা ছাড়িয়েছে';

  @override
  String get progressLevelNoLimit => 'সীমা নির্ধারিত নেই';

  @override
  String progressBarSemantics(String label, String percent, String level) {
    return '$label: $percent শতাংশ, $level';
  }

  @override
  String get personPickerNone => 'কেউ নয়';

  @override
  String get actionUndo => 'পূর্বাবস্থায় ফেরান';

  @override
  String get bazarErrExpenseDeleted =>
      'এই খরচটি মুছে ফেলা হয়েছে। আগে ফিরিয়ে আনুন।';

  @override
  String get expenseAddTitle => 'খরচ যোগ করুন';

  @override
  String get expenseEditTitle => 'খরচ সম্পাদনা';

  @override
  String get expenseMenuTrip => 'বাজার ট্রিপ (অনেক পণ্য)';

  @override
  String get expenseDateLabel => 'তারিখ';

  @override
  String get expenseItemLabel => 'পণ্য';

  @override
  String get expenseItemHint => 'পণ্যের নাম লিখুন';

  @override
  String expenseAddNewItem(String name) {
    return '$name নতুন পণ্য হিসেবে যোগ করুন';
  }

  @override
  String get expenseCategoryLabel => 'ক্যাটেগরি';

  @override
  String get expenseRememberItem => 'পণ্যটি মনে রাখুন';

  @override
  String get expenseTotalField => 'মোট টাকা';

  @override
  String get expenseTotalLabel => 'মোট';

  @override
  String get expenseQtyPriceSection => 'অথবা পরিমাণ ও প্রতি এককের দাম লিখুন';

  @override
  String get expenseQtyField => 'পরিমাণ';

  @override
  String get expenseUnitLabel => 'একক';

  @override
  String get expenseUnitPriceField => 'প্রতি এককের দাম';

  @override
  String expenseUnitPriceHint(String price) {
    return 'সর্বশেষ দাম: $price';
  }

  @override
  String get expenseFundingLabel => 'কে টাকা দিয়েছে?';

  @override
  String get expenseFundingFund => 'পরিবারের তহবিল থেকে';

  @override
  String get expenseFundingReimbursable => 'সদস্য দিয়েছে, ফেরত পাবে';

  @override
  String get expenseFundingPersonal => 'সদস্য নিজের টাকায় দিয়েছে, ফেরত নয়';

  @override
  String get expensePaidByLabel => 'যিনি দিয়েছেন';

  @override
  String get expenseMoreSection => 'আরও তথ্য';

  @override
  String get expenseShopField => 'দোকান';

  @override
  String get expenseNoteField => 'নোট';

  @override
  String get expensePurchaserLabel => 'যিনি কিনেছেন';

  @override
  String get expenseSaveAddAnother => 'সংরক্ষণ করে আরেকটি যোগ করুন';

  @override
  String get expenseSaved => 'খরচ সংরক্ষণ হয়েছে';

  @override
  String get expenseUpdated => 'খরচ হালনাগাদ হয়েছে';

  @override
  String get expenseUnknownMember => 'একজন সদস্য';

  @override
  String get expenseDuplicateTitle => 'মনে হচ্ছে একই খরচ আগেই যোগ হয়েছে';

  @override
  String expenseDuplicateMessage(String item) {
    return '$item একই টাকায় কয়েক মিনিট আগে যোগ করা হয়েছে।';
  }

  @override
  String get expenseDuplicateSaveAnyway => 'তবুও সংরক্ষণ করুন';

  @override
  String get tripTitle => 'বাজার ট্রিপ';

  @override
  String get tripAddLine => 'পণ্য যোগ করুন';

  @override
  String get tripLineSheetTitle => 'ট্রিপে পণ্য যোগ করুন';

  @override
  String get tripLineSheetSave => 'ট্রিপে যোগ করুন';

  @override
  String tripLinesCount(String count) {
    return 'পণ্য: $count';
  }

  @override
  String get tripEmpty => 'এখনো কোনো পণ্য নেই। প্রথম পণ্যটি যোগ করুন।';

  @override
  String get tripTotalLabel => 'ট্রিপের মোট';

  @override
  String get tripSaveAll => 'সব সংরক্ষণ করুন';

  @override
  String get tripSaved => 'ট্রিপ সংরক্ষণ হয়েছে';

  @override
  String get tripLineRemoved => 'পণ্য সরানো হয়েছে';

  @override
  String get tripLimitReached => 'একটি ট্রিপে সর্বোচ্চ ৪০টি পণ্য থাকতে পারে।';

  @override
  String get expenseListTitle => 'খরচের তালিকা';

  @override
  String get expenseListFilteredTotal => 'এই তালিকার মোট';

  @override
  String get expenseListEmptyTitle => 'এই মাসে কোনো খরচ নেই';

  @override
  String get expenseListEmptyMessage => 'প্রথম খরচ যোগ করলে এখানে দেখা যাবে।';

  @override
  String get expenseListFilteredEmptyTitle =>
      'ফিল্টারের সাথে মেলে এমন কিছু নেই';

  @override
  String get expenseListFilteredEmptyMessage =>
      'সব খরচ দেখতে ফিল্টার মুছে ফেলুন।';

  @override
  String get expenseListLocked => 'এই মাস বন্ধ। এন্ট্রি শুধু দেখা যাবে।';

  @override
  String get expenseListRefresh => 'রিফ্রেশ';

  @override
  String get expenseShowMore => 'আরও দেখান';

  @override
  String get expenseRowDeleted => 'মুছে ফেলা';

  @override
  String get expenseRowTrip => 'ট্রিপ';

  @override
  String get expenseFilterTitle => 'ফিল্টার';

  @override
  String get expenseFilterRange => 'তারিখের সীমা';

  @override
  String expenseFilterRangeActive(String start, String end) {
    return '$start থেকে $end';
  }

  @override
  String get expenseRangeAll => 'পুরো মাস';

  @override
  String get expenseRangeToday => 'আজ';

  @override
  String get expenseRangeYesterday => 'গতকাল';

  @override
  String get expenseRangeLast7 => 'গত ৭ দিন';

  @override
  String get expenseRangeThisWeek => 'এই সপ্তাহ';

  @override
  String get expenseRangeThisMonth => 'এই মাস';

  @override
  String get expenseRangeLastMonth => 'গত মাস';

  @override
  String get expenseRangeThisYear => 'এই বছর';

  @override
  String get expenseRangeCustom => 'তারিখ বেছে নিন';

  @override
  String get expenseFilterCategory => 'ক্যাটেগরি';

  @override
  String get expenseFilterItem => 'পণ্য';

  @override
  String get expenseFilterMember => 'সদস্য';

  @override
  String get expenseFilterFunding => 'টাকার উৎস';

  @override
  String get expenseFilterAny => 'যেকোনো';

  @override
  String get expenseFilterShowDeleted => 'মুছে ফেলা দেখান';

  @override
  String get expenseFilterReset => 'ফিল্টার মুছুন';

  @override
  String get expenseDetailTitle => 'খরচ';

  @override
  String get expenseDetailAddedBy => 'যোগ করেছেন';

  @override
  String get expenseDetailPayment => 'টাকার উৎস ও হিসাব';

  @override
  String get expenseNotYoursMessage =>
      'আপনি শুধু নিজের খরচ পরিবর্তন করতে পারবেন।';

  @override
  String get expenseLedgerFund => 'পরিবারের তহবিল থেকে দেওয়া হয়েছে';

  @override
  String expenseLedgerPersonal(String name) {
    return '$name নিজের টাকায় দিয়েছেন, ফেরত নেই';
  }

  @override
  String expenseLedgerPending(String name, String amount) {
    return '$name দিয়েছেন। $amount ফেরত দেওয়া বাকি।';
  }

  @override
  String expenseLedgerPartial(String name, String settled, String total) {
    return '$name দিয়েছেন। $total এর মধ্যে $settled ফেরত দেওয়া হয়েছে।';
  }

  @override
  String expenseLedgerSettled(String name) {
    return '$name দিয়েছেন। পুরোটা ফেরত দেওয়া হয়েছে।';
  }

  @override
  String get expenseLedgerVoided => 'খরচের সাথে ফেরতও বাতিল হয়েছে।';

  @override
  String get expenseDeleteTitle => 'এই খরচ মুছে ফেলবেন?';

  @override
  String expenseDeleteMessage(String name) {
    return '$name মোট থেকে বাদ যাবে। সাথে সাথে পূর্বাবস্থায় ফেরাতে পারবেন।';
  }

  @override
  String get expenseDeleted => 'খরচ মুছে ফেলা হয়েছে';

  @override
  String get expenseRestore => 'ফিরিয়ে আনুন';

  @override
  String get expenseRestored => 'খরচ ফিরিয়ে আনা হয়েছে';

  @override
  String get expenseHistoryTitle => 'পরিবর্তনের ইতিহাস';

  @override
  String get expenseHistoryEmpty => 'এখনো কোনো পরিবর্তন নেই।';

  @override
  String expenseHistoryEntry(String who, String date) {
    return '$who $date তারিখে পরিবর্তন করেছেন';
  }

  @override
  String expenseHistoryWas(String field, String value) {
    return '$field আগে ছিল: $value';
  }

  @override
  String get catalogTitle => 'পণ্য ও ক্যাটেগরি';

  @override
  String get catalogTabCategories => 'ক্যাটেগরি';

  @override
  String get catalogTabItems => 'পণ্য';

  @override
  String get catalogAdd => 'যোগ করুন';

  @override
  String get catalogAddCategory => 'ক্যাটেগরি যোগ করুন';

  @override
  String get catalogEditCategory => 'ক্যাটেগরি সম্পাদনা';

  @override
  String get catalogAddItem => 'পণ্য যোগ করুন';

  @override
  String get catalogEditItem => 'পণ্য সম্পাদনা';

  @override
  String get catalogCategoryName => 'ক্যাটেগরির নাম';

  @override
  String get catalogNameBn => 'বাংলা নাম';

  @override
  String get catalogNameEn => 'ইংরেজি নাম (ঐচ্ছিক)';

  @override
  String get catalogEmoji => 'ইমোজি (ঐচ্ছিক)';

  @override
  String get catalogColour => 'রং';

  @override
  String catalogColourSemantics(int number) {
    return 'রং $number';
  }

  @override
  String get catalogActive => 'তালিকায় দেখানো হবে';

  @override
  String get catalogActiveHint => 'মুছে না ফেলে লুকাতে বন্ধ করুন।';

  @override
  String get catalogHidden => 'লুকানো';

  @override
  String get catalogReorder => 'সাজাতে টেনে আনুন';

  @override
  String get catalogReadOnly =>
      'আপনি এটি দেখতে পারবেন, কিন্তু শুধু সংসার ব্যবস্থাপক বা অ্যাডমিন পরিবর্তন করতে পারবেন।';

  @override
  String get catalogCategoriesEmpty => 'এখনো কোনো ক্যাটেগরি নেই';

  @override
  String get catalogItemsEmpty => 'কোনো পণ্য পাওয়া যায়নি';

  @override
  String get catalogSearch => 'পণ্য খুঁজুন';

  @override
  String get catalogAllCategories => 'সব';

  @override
  String get catalogDefaultUnit => 'সাধারণ একক';

  @override
  String get catalogAliases => 'অন্য বানান (খোঁজার জন্য)';

  @override
  String get catalogAliasField => 'একটি বানান যোগ করুন';

  @override
  String get catalogAliasAdd => 'বানান যোগ করুন';

  @override
  String get catalogAliasLimit => 'সর্বোচ্চ ১০টি বানান দেওয়া যাবে।';

  @override
  String get bazarSettingsWeekStart => 'সপ্তাহ শুরু';

  @override
  String get bazarSettingsTarget => 'মাসিক পারিবারিক চাঁদার লক্ষ্য';

  @override
  String get bazarSettingsDueDay => 'চাঁদা দেওয়ার তারিখ (প্রতি মাসে)';

  @override
  String get bazarSettingsAlerts => 'বাজেট সতর্কতা (বাজেটের শতাংশ)';

  @override
  String get bazarSettingsWarnAt => 'সতর্ক করুন';

  @override
  String get bazarSettingsExceededAt => 'সীমা ছাড়ালে';

  @override
  String get bazarSettingsThresholdRange =>
      '১ থেকে ২০০ এর মধ্যে পূর্ণ সংখ্যা দিন।';

  @override
  String get bazarSettingsThresholdOrder =>
      'সতর্কতার শতাংশ সীমা ছাড়ানোর শতাংশের চেয়ে কম হতে হবে।';

  @override
  String get bazarSettingsFundStart => 'তহবিল শুরুর মাস';

  @override
  String get bazarSettingsFundStartUnset =>
      'শুরুর জমা (ওপেনিং ব্যালান্স) লিখলে নিজে থেকে ঠিক হবে।';

  @override
  String get budgetTitle => 'বাজেট';

  @override
  String get budgetNote => 'বাজেট একটি পরিকল্পনা; তহবিলের ব্যালান্সই আসল টাকা।';

  @override
  String get budgetEmptyTitle => 'এই মাসের কোনো বাজেট নেই';

  @override
  String get budgetEmptyMessage =>
      'মাসের পরিকল্পনা করলে খরচের সঙ্গে তুলনা দেখতে পাবেন।';

  @override
  String get budgetEmptyReadOnly =>
      'সংসার ব্যবস্থাপক বা অ্যাডমিন এখনো এই মাসের পরিকল্পনা করেননি।';

  @override
  String get budgetPlanThisMonth => 'এই মাসের পরিকল্পনা করুন';

  @override
  String get budgetCopyLast => 'গত মাসের বাজেট কপি করুন';

  @override
  String get budgetEdit => 'বাজেট সম্পাদনা';

  @override
  String get budgetOverall => 'পুরো মাস';

  @override
  String budgetLeft(String amount) {
    return '$amount বাকি';
  }

  @override
  String budgetOver(String amount) {
    return '$amount বেশি';
  }

  @override
  String get budgetByCategory => 'ক্যাটাগরি অনুযায়ী';

  @override
  String get budgetDryTitle => 'শুকনা বাজারের আনুমানিক হিসাব';

  @override
  String budgetDrySummary(String count, String total) {
    return '$countটি আইটেম, $total';
  }

  @override
  String get budgetDryEmpty => 'এখনো কোনো আইটেম নেই।';

  @override
  String get budgetTotalField => 'মোট বাজেট (খালি রাখলে যোগফল ধরা হবে)';

  @override
  String get budgetDryFromLines => 'নিচের আইটেমগুলোর যোগফল';

  @override
  String get budgetCategoryEstimates => 'ক্যাটাগরি অনুযায়ী আনুমানিক হিসাব';

  @override
  String get budgetLineName => 'আইটেম';

  @override
  String get budgetLineStock => 'মজুদ';

  @override
  String get budgetLineRate => 'দর';

  @override
  String get budgetLineTotal => 'মোট';

  @override
  String get budgetAddLine => 'আইটেম যোগ করুন';

  @override
  String get budgetRemoveLine => 'আইটেম সরান';

  @override
  String get budgetLinesSum => 'আইটেমের মোট';

  @override
  String get budgetSaved => 'বাজেট সংরক্ষিত হয়েছে';

  @override
  String get budgetErrExists => 'এই মাসের বাজেট আগেই আছে।';

  @override
  String get budgetNoLastMonth => 'কপি করার মতো গত মাসের বাজেট নেই।';

  @override
  String get budgetReadOnly =>
      'আপনি বাজেট দেখতে পারবেন, কিন্তু শুধু সংসার ব্যবস্থাপক বা অ্যাডমিন বদলাতে পারবেন।';

  @override
  String get budgetAlertsTitle => 'বাজেট সতর্কতা';

  @override
  String get fundTitle => 'পারিবারিক ফান্ড';

  @override
  String get fundBalanceTitle => 'ফান্ডের ব্যালেন্স';

  @override
  String get fundReceived => 'জমা';

  @override
  String get fundSpent => 'খরচ';

  @override
  String get fundReimbursed => 'ফেরত দেওয়া';

  @override
  String fundClosedOn(String date) {
    return '$date তারিখে বন্ধ হয়েছে';
  }

  @override
  String get fundMonthClosedNotice =>
      'এই মাস বন্ধ, তাই এতে নতুন কিছু যোগ করা যাবে না।';

  @override
  String get fundOverflowWarning =>
      'ফান্ডের তালিকা অনেক বড়; ব্যালেন্স ঠিক রাখতে পুরোনো মাসগুলো বন্ধ করুন।';

  @override
  String get fundDriftWarning =>
      'একটি বন্ধ মাস খাতার সাথে মিলছে না। সেটি আবার খুলে, ঠিক করে আবার বন্ধ করুন।';

  @override
  String fundLedgerIssues(int count) {
    return '$countটি খরচের সাথে ফান্ডের এন্ট্রি মিলছে না।';
  }

  @override
  String get fundMembersTitle => 'সদস্যদের জমা';

  @override
  String get fundNoMembers => 'এখনো কোনো সক্রিয় সদস্য নেই।';

  @override
  String get fundNoPlan => 'এই মাসের কোনো পরিকল্পনা নেই';

  @override
  String get fundPaidUp => 'সম্পূর্ণ জমা হয়েছে';

  @override
  String fundRemainingAmount(String amount) {
    return '$amount বাকি';
  }

  @override
  String fundCredit(String amount) {
    return '$amount বেশি';
  }

  @override
  String fundAwaitingApproval(String amount) {
    return '$amount অনুমোদনের অপেক্ষায়';
  }

  @override
  String get fundHistoryTitle => 'ফান্ডের হিসাব';

  @override
  String get fundHistoryEmpty => 'এই মাসে ফান্ডে এখনো কিছু নেই।';

  @override
  String get fundTxContribution => 'জমা';

  @override
  String get fundTxExpense => 'খরচ';

  @override
  String get fundTxReimbursement => 'ফেরত দেওয়া';

  @override
  String get fundTxOpening => 'প্রারম্ভিক ব্যালেন্স';

  @override
  String get fundTxAdjustment => 'সংশোধন';

  @override
  String get fundSetupTitle => 'ফান্ড শুরু করুন';

  @override
  String get fundSetupMessage =>
      'পরিবারের কাছে এখন যে টাকা আছে লিখে ফান্ড ও তার প্রথম মাস শুরু করুন।';

  @override
  String get fundOpeningBalance => 'প্রারম্ভিক ব্যালেন্স';

  @override
  String get fundSaveOpening => 'প্রারম্ভিক ব্যালেন্স সংরক্ষণ';

  @override
  String get fundAddContribution => 'জমা যোগ করুন';

  @override
  String get fundRequestContribution => 'জমার অনুরোধ করুন';

  @override
  String get fundSaveContribution => 'জমা সংরক্ষণ';

  @override
  String get fundSendRequest => 'অনুরোধ পাঠান';

  @override
  String get fundSendChangeRequest => 'পরিবর্তনের অনুরোধ পাঠান';

  @override
  String get fundEditRequest => 'অনুরোধ সম্পাদনা';

  @override
  String get fundRequestChange => 'পরিবর্তনের অনুরোধ';

  @override
  String get fundContributionLocked => 'মাস বন্ধ';

  @override
  String get fundMemberLabel => 'কে দিয়েছেন';

  @override
  String get fundAmountLabel => 'টাকার পরিমাণ';

  @override
  String get fundMethodLabel => 'কীভাবে দেওয়া হয়েছে';

  @override
  String get fundMethodCash => 'নগদ';

  @override
  String get fundMethodBkash => 'বিকাশ';

  @override
  String get fundMethodNagad => 'নগদ (Nagad)';

  @override
  String get fundMethodBank => 'ব্যাংক';

  @override
  String get fundMethodOther => 'অন্য';

  @override
  String get fundPendingTitle => 'অনুমোদনের অপেক্ষায়';

  @override
  String bazarDashboardPendingApprovals(String count) {
    return '$countটি জমার অনুরোধ অনুমোদনের অপেক্ষায়';
  }

  @override
  String get fundPendingEmpty => 'কোনো অনুরোধ অপেক্ষায় নেই।';

  @override
  String get fundApprove => 'অনুমোদন';

  @override
  String get fundReject => 'প্রত্যাখ্যান';

  @override
  String get fundRejectReasonTitle => 'কেন প্রত্যাখ্যান করছেন?';

  @override
  String get fundRejectReasonHint => 'সদস্য এই কারণটি দেখতে পাবেন।';

  @override
  String fundRejectedReason(String reason) {
    return 'প্রত্যাখ্যাত: $reason';
  }

  @override
  String get fundVoid => 'বাতিল';

  @override
  String get fundGeneratePlan => 'এই মাসের পরিকল্পনা তৈরি করুন';

  @override
  String get fundStatusPending => 'অনুমোদনের অপেক্ষায়';

  @override
  String get fundStatusApproved => 'অনুমোদিত';

  @override
  String get fundStatusRejected => 'প্রত্যাখ্যাত';

  @override
  String get fundStatusVoided => 'বাতিল করা';

  @override
  String get advanceTitle => 'অগ্রিম ফেরত';

  @override
  String advanceOwedTo(String name) {
    return '$name-কে দিতে হবে';
  }

  @override
  String advancePaidTo(String name) {
    return '$name-কে দেওয়া হয়েছে';
  }

  @override
  String advanceOpenCount(int count) {
    return '$countটি অগ্রিম বাকি';
  }

  @override
  String get advanceTotalOwed => 'মোট বাকি';

  @override
  String get advanceShowSettled => 'পরিশোধিত দেখান';

  @override
  String get advanceEmptyTitle => 'ফেরত দেওয়ার কিছু নেই';

  @override
  String get advanceEmptyMessage =>
      'কোনো সদস্য নিজের টাকায় পরিবারের জন্য খরচ করলে, ফেরত দেওয়ার আগ পর্যন্ত তা এখানে দেখা যাবে।';

  @override
  String get advanceSettledOf => 'ফেরত দেওয়া';

  @override
  String get advanceRemaining => 'বাকি';

  @override
  String get advanceSettleTitle => 'ফেরত দিন';

  @override
  String get advanceSettleAction => 'ফেরত দেওয়া লিখুন';

  @override
  String get monthCloseTitle => 'মাস বন্ধ করুন';

  @override
  String get monthCloseManagerOnly =>
      'শুধু সংসার ব্যবস্থাপক বা অ্যাডমিন মাস বন্ধ বা আবার খুলতে পারবেন।';

  @override
  String get monthCloseCurrentHint =>
      'এই মাস বন্ধ করলে এটি পড়ার মতো হয়ে যাবে এবং এর ব্যালেন্স পরের মাসে যাবে।';

  @override
  String get monthCloseWillRecord => 'এই মাস যে ব্যালেন্স নথিভুক্ত করবে';

  @override
  String get monthCloseAdvances => 'বন্ধের পর অগ্রিম বাকি';

  @override
  String get monthCloseExpected => 'পরিকল্পিত জমা';

  @override
  String get monthCloseReceived => 'গৃহীত জমা';

  @override
  String get monthClose => 'মাস বন্ধ করুন';

  @override
  String get monthCloseConfirmTitle => 'এই মাস বন্ধ করবেন?';

  @override
  String get monthCloseConfirmMessage =>
      'মাসটি পড়ার মতো হয়ে যাবে এবং ব্যালেন্স পরের মাসে যাবে। কিছু ভুল থাকলে পরে আবার খুলতে পারবেন।';

  @override
  String get monthClosedDone => 'মাস বন্ধ হয়েছে';

  @override
  String get monthReopen => 'মাস আবার খুলুন';

  @override
  String get monthReopenedDone => 'মাস আবার খোলা হয়েছে';

  @override
  String get monthReopenNoteTitle => 'কেন এই মাস আবার খুলছেন?';

  @override
  String get monthReopenNoteHint => 'একটি ছোট কারণ (অন্তত ৩ অক্ষর)।';

  @override
  String monthClosedChip(String month) {
    return '$month (বন্ধ)';
  }

  @override
  String get reportTitle => 'রিপোর্ট';

  @override
  String get reportTabSummary => 'সারসংক্ষেপ';

  @override
  String get reportTabCategories => 'ক্যাটেগরি';

  @override
  String get reportTabItems => 'আইটেম';

  @override
  String get reportTabDays => 'দিন';

  @override
  String get reportTabMembers => 'সদস্য';

  @override
  String get reportTabDry => 'শুকনা বাজার';

  @override
  String get reportTabContributions => 'জমা';

  @override
  String get reportTotal => 'মোট';

  @override
  String get reportAmount => 'টাকা';

  @override
  String get reportAveragePerDay => 'দৈনিক গড়';

  @override
  String get reportRows => 'এন্ট্রি';

  @override
  String get reportRange => 'সময়কাল';

  @override
  String get reportSummaryColumn => 'বিবরণ';

  @override
  String get reportCategoryColumn => 'ক্যাটেগরি';

  @override
  String get reportItemColumn => 'আইটেম';

  @override
  String get reportDayColumn => 'দিন';

  @override
  String get reportMemberColumn => 'সদস্য';

  @override
  String reportPercent(String percent) {
    return '$percent%';
  }

  @override
  String get reportUp => 'বেড়েছে';

  @override
  String get reportDown => 'কমেছে';

  @override
  String get reportFlat => 'অপরিবর্তিত';

  @override
  String get reportPrevious => 'আগে';

  @override
  String reportComparedWith(String period) {
    return '$period-এর তুলনায়';
  }

  @override
  String get reportNoPreviousData => 'আগের কোনো তথ্য নেই';

  @override
  String reportComparisonSemantics(
    String direction,
    String amount,
    String percent,
    String period,
  ) {
    return '$period-এর তুলনায় $direction $amount, $percent';
  }

  @override
  String get reportPrevDay => 'আগের দিন';

  @override
  String get reportPrevWeek => 'গত সপ্তাহ';

  @override
  String get reportPrevMonth => 'গত মাস';

  @override
  String get reportPrevYear => 'গত বছর';

  @override
  String get reportPrevRange => 'আগের সময়কাল';

  @override
  String get reportDryEstimate => 'পরিকল্পিত';

  @override
  String get reportDryActual => 'খরচ';

  @override
  String get reportDryDelta => 'পার্থক্য';

  @override
  String get reportDryPlanned => 'পরিকল্পনা';

  @override
  String get reportDryEmpty =>
      'এই সময়ের জন্য শুকনা বাজারের কোনো পরিকল্পনা নেই।';

  @override
  String get reportOver => 'বেশি';

  @override
  String get reportUnder => 'কম';

  @override
  String get reportExpected => 'পরিকল্পিত';

  @override
  String get reportTruncated =>
      'এই সময়ে অনেকগুলো এন্ট্রি, সব দেখানো যাচ্ছে না। নির্ভুল রিপোর্টের জন্য ছোট সময় বেছে নিন।';

  @override
  String get chartNoData => 'এই সময়ের জন্য দেখানোর মতো কিছু নেই।';

  @override
  String get chartOther => 'অন্যান্য';

  @override
  String chartSlice(String name, String amount, String percent) {
    return '$name $amount, মোটের $percent%';
  }

  @override
  String chartDaySummary(String day, String amount) {
    return 'সবচেয়ে বেশি খরচ $day: $amount';
  }

  @override
  String get choresEmptyTitle => 'কোনো কাজ নেই';

  @override
  String get choresEmptyMessage => 'কাজ যোগ হলে এখানে দেখা যাবে।';

  @override
  String get choresManageAction => 'পরিচালনা';

  @override
  String get choresManageTitle => 'কাজ পরিচালনা';

  @override
  String get choresManageEmptyTitle => 'এখনো কিছু নেই';

  @override
  String get choresManageEmptyMessage => 'কাজ পরিচালনার টুল এখানে দেখা যাবে।';

  @override
  String get choresModuleTitle => 'কাজ';

  @override
  String get permissionManageChoreTemplates => 'কাজ ও রোটেশন পরিচালনা';

  @override
  String get permissionReassignChore => 'কাজ অন্যজনকে দেওয়া';

  @override
  String get permissionRequestSwap => 'কাজ বদলের অনুরোধ';

  @override
  String get permissionCompleteOwnChore => 'নিজের কাজ শেষ করা';

  @override
  String get permissionCommentOnChore => 'কাজে মন্তব্য করা';

  @override
  String get permissionVerifyChore => 'অন্যের কাজ যাচাই করা';

  @override
  String get permissionCompleteChoreForOthers => 'অন্যের কাজ শেষ করে দেওয়া';

  @override
  String get permissionRecordOwnAvailability => 'নিজের অনুপস্থিতি জানানো';

  @override
  String get permissionManageAvailability => 'অনুপস্থিতি পরিচালনা';

  @override
  String get permissionManageChoreOccurrences =>
      'কাজ বাদ দেওয়া, আবার খোলা বা টীকা দেওয়া';

  @override
  String get permissionModerateChoreComments => 'মন্তব্য লুকানো';

  @override
  String get choreStatusSkipped => 'বাদ দেওয়া';

  @override
  String get choreFlagNeedsCover => 'কেউ এখনও নেই';

  @override
  String get choreFlagAwaitingVerification => 'যাচাই বাকি';

  @override
  String get choreFlagNeedsAttention => 'দৃষ্টি দেওয়ার কাজ';

  @override
  String get choreFlagPlanned => 'পরিকল্পিত';

  @override
  String get choreFlagSwapPending => 'বদলের অনুরোধ বাকি';

  @override
  String get reasonSheetHint => 'কেন? (অন্তত ৩টি অক্ষর)';

  @override
  String reasonSheetTooShort(int min) {
    return 'অন্তত $minটি অক্ষর লিখুন।';
  }

  @override
  String get minutesFieldNotSet => 'দিনের শেষে';

  @override
  String get minutesFieldClear => 'সময় মুছে ফেলুন';

  @override
  String colorSwatchLabel(int index, int count) {
    return 'রং $index, মোট $countটি';
  }

  @override
  String avatarStackMore(String first, int rest) {
    return '$first এবং আরও $rest জন';
  }

  @override
  String avatarStackMoreShort(int hidden) {
    return '+$hidden';
  }

  @override
  String stepProgressSemantic(String done, String total) {
    return '$totalটি ধাপের $doneটি শেষ';
  }

  @override
  String get choresFailure_required => 'এটি পূরণ করা জরুরি।';

  @override
  String get choresFailure_too_long => 'লেখাটি খুব বড় হয়ে গেছে।';

  @override
  String get choresFailure_invalid_time => 'সঠিক সময় দিন।';

  @override
  String get choresFailure_invalid_recurrence =>
      'এই পুনরাবৃত্তির নিয়ম ঠিক নেই।';

  @override
  String get choresFailure_no_dates => 'অন্তত একটি দিন বেছে নিন।';

  @override
  String get choresFailure_invalid_range => 'শেষ তারিখ শুরুর আগে হতে পারে না।';

  @override
  String get choresFailure_invalid_date => 'তারিখটি সঠিক নয়।';

  @override
  String get choresFailure_too_many_subtasks =>
      'ধাপ সংখ্যায় বেশি হয়ে গেছে (সর্বোচ্চ ৩০)।';

  @override
  String get choresFailure_too_many_slots =>
      'দিনে বার সংখ্যায় বেশি (সর্বোচ্চ ৬)।';

  @override
  String get choresFailure_duplicate_slot => 'একই নামে দুটি বার আছে।';

  @override
  String get choresFailure_too_many_items => 'পরিমাণটি বেশি হয়ে গেছে।';

  @override
  String get choresFailure_duplicate_id => 'এই নামটি আগেই ব্যবহার করা হয়েছে।';

  @override
  String get choresFailure_reason_required => 'কারণ লিখতে হবে।';

  @override
  String get choresFailure_reason_too_short => 'কারণে অন্তত ৩টি অক্ষর দিন।';

  @override
  String get choresFailure_member_required => 'একজন সদস্য বেছে নিন।';

  @override
  String get choresFailure_invalid_rotation => 'এই রোটেশনটি সঠিক নয়।';

  @override
  String get choresFailure_too_few_members => 'রোটেশনে অন্তত দুই জন সদস্য দিন।';

  @override
  String get choresFailure_invalid_horizon =>
      '১৪ থেকে ৯০ দিনের মধ্যে একটি সীমা বেছে নিন।';

  @override
  String get choresFailure_invalid_week_start =>
      'সপ্তাহের প্রথম দিন সঠিকভাবে বেছে নিন।';

  @override
  String get choresFailure_invalid_minutes =>
      '০০:০০ থেকে ২৩:৫৯ এর মধ্যে সময় দিন।';

  @override
  String get choresFailure_not_assigned_to_you => 'এই কাজটি আপনার নয়।';

  @override
  String get choresFailure_already_completed => 'এই কাজটি আগেই শেষ হয়েছে।';

  @override
  String get choresFailure_not_completed => 'এই কাজটি এখনও শেষ হয়নি।';

  @override
  String get choresFailure_required_subtasks_open =>
      'আগে জরুরি ধাপগুলো শেষ করুন।';

  @override
  String get choresFailure_self_verification =>
      'নিজের কাজ নিজে যাচাই করা যায় না।';

  @override
  String get choresFailure_verification_not_required =>
      'এই কাজে যাচাই দরকার নেই।';

  @override
  String get choresFailure_already_verified => 'এই কাজটি আগেই যাচাই হয়েছে।';

  @override
  String get choresFailure_verified_requires_manager =>
      'যাচাই হওয়া কাজ শুধু পরিচালক আবার খুলতে পারেন।';

  @override
  String get choresFailure_occurrence_started => 'এই কাজটি শুরু হয়ে গেছে।';

  @override
  String get choresFailure_already_skipped =>
      'এই কাজটি আগেই বাদ দেওয়া হয়েছে।';

  @override
  String get choresFailure_not_skipped => 'এই কাজটি বাদ দেওয়া হয়নি।';

  @override
  String get choresFailure_swap_not_pending => 'এই অনুরোধটি আর খোলা নেই।';

  @override
  String get choresFailure_swap_expired => 'এই অনুরোধের সময় শেষ।';

  @override
  String get choresFailure_swaps_disabled => 'এই পরিবারে কাজ বদল বন্ধ আছে।';

  @override
  String get choresFailure_cover_not_needed => 'এই কাজে ইতিমধ্যে কেউ আছেন।';

  @override
  String get choresFailure_availability_overlap =>
      'এই দিনগুলোতে অনুপস্থিতি আগেই জানানো আছে।';

  @override
  String get choresFailure_member_unavailable => 'সদস্যটি ওই দিনে অনুপস্থিত।';

  @override
  String get choresFailure_template_paused => 'এই কাজটি সাময়িকভাবে বন্ধ।';

  @override
  String get choresFailure_rotation_member_inactive =>
      'রোটেশনের একজন সদস্য আর সক্রিয় নন।';

  @override
  String get choresFailure_range_too_large =>
      'একবারে তৈরি করার জন্য সীমাটি বেশি বড়।';

  @override
  String get choresFailure_starter_pack_applied =>
      'এই স্টার্টার প্যাক আগেই যোগ করা হয়েছে।';

  @override
  String get choresFailure_occurrence_deleted => 'এই কাজটি মুছে ফেলা হয়েছে।';

  @override
  String get choresFailure_concurrent_edit =>
      'অন্য কেউ এটি বদলে ফেলেছেন; আবার খুলে চেষ্টা করুন।';

  @override
  String get choresFailure_last_group_in_use =>
      'এই দলটি এখনও কাজে ব্যবহার হচ্ছে।';

  @override
  String get choresFailure_not_a_recipient => 'অনুরোধটি আপনার জন্য নয়।';

  @override
  String get choresFailure_not_found => 'এটি আর নেই।';

  @override
  String get choresFailure_permission_denied => 'এটি করার অনুমতি আপনার নেই।';

  @override
  String get choresFailure_network =>
      'ইন্টারনেট সংযোগ নেই। 연결 দেখে আবার চেষ্টা করুন।';

  @override
  String get choresFailure_unknown => 'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get activityChoresSettingsUpdated => 'কাজের সেটিংস বদলেছেন';

  @override
  String get activityChoresRotationPolicyUpdated => 'অনুপস্থিতির নিয়ম বদলেছেন';

  @override
  String activityChoresTemplateCreated(String name) {
    return '$name কাজটি যোগ করেছেন';
  }

  @override
  String activityChoresTemplateUpdated(String name) {
    return '$name কাজটি বদলেছেন';
  }

  @override
  String activityChoresTemplatePaused(String name) {
    return '$name কাজটি সাময়িকভাবে বন্ধ করেছেন';
  }

  @override
  String activityChoresTemplateResumed(String name) {
    return '$name কাজটি আবার চালু করেছেন';
  }

  @override
  String activityChoresTemplateArchived(String name) {
    return '$name কাজটি আর্কাইভ করেছেন';
  }

  @override
  String activityChoresTemplateDuplicated(String name) {
    return '$name কাজটির কপি করেছেন';
  }

  @override
  String activityChoresStarterPackApplied(String templates, String groups) {
    return 'স্টার্টার কাজগুলো যোগ করেছেন ($templatesটি কাজ, $groupsটি দল)';
  }

  @override
  String activityChoresDutyGroupCreated(String name) {
    return '$name দলটি যোগ করেছেন';
  }

  @override
  String activityChoresDutyGroupUpdated(String name) {
    return '$name দলটি বদলেছেন';
  }

  @override
  String activityChoresRotationChanged(String name) {
    return '$name এর রোটেশন বদলেছেন';
  }

  @override
  String activityChoresOccurrencesGenerated(
    String from,
    String to,
    String count,
  ) {
    return '$from থেকে $to পর্যন্ত কাজ তৈরি হয়েছে ($count)';
  }

  @override
  String activityChoresOccurrencesReplanned(String name, String from) {
    return '$from থেকে $name কাজটি আবার পরিকল্পনা করেছেন';
  }

  @override
  String activityChoresOccurrenceCompleted(
    String member,
    String name,
    String date,
  ) {
    return '$member $date-এ $name শেষ করেছেন';
  }

  @override
  String activityChoresOccurrenceUncompleted(
    String member,
    String name,
    String date,
  ) {
    return '$member $date-এ $name আবার অসম্পূর্ণ করেছেন';
  }

  @override
  String activityChoresOccurrenceVerified(
    String member,
    String name,
    String date,
  ) {
    return '$member $date-এ $name যাচাই করেছেন';
  }

  @override
  String activityChoresOccurrenceReopened(
    String member,
    String name,
    String date,
  ) {
    return '$member $date-এ $name আবার খুলেছেন';
  }

  @override
  String activityChoresOccurrenceException(
    String member,
    String name,
    String date,
  ) {
    return '$member $date-এ $name এর জন্য ব্যতিক্রম লিখেছেন';
  }

  @override
  String activityChoresOccurrenceSkipped(
    String member,
    String name,
    String date,
  ) {
    return '$member $date-এ $name বাদ দিয়েছেন';
  }

  @override
  String activityChoresOccurrenceUnskipped(
    String member,
    String name,
    String date,
  ) {
    return '$member $date-এ $name আবার চালু করেছেন';
  }

  @override
  String activityChoresOccurrenceReassigned(
    String member,
    String name,
    String date,
  ) {
    return '$member $date-এ $name অন্যকে দিয়েছেন';
  }

  @override
  String activityChoresCommentAdded(String member, String name, String date) {
    return '$member $date-এ $name নিয়ে মন্তব্য করেছেন';
  }

  @override
  String activityChoresCommentHidden(String member, String name, String date) {
    return '$member $date-এ $name এর একটি মন্তব্য লুকিয়েছেন';
  }

  @override
  String activityChoresAvailabilityAdded(
    String member,
    String from,
    String to,
  ) {
    return '$member $from থেকে $to পর্যন্ত অনুপস্থিতি জানিয়েছেন';
  }

  @override
  String activityChoresAvailabilityCancelled(
    String member,
    String from,
    String to,
  ) {
    return '$member $from থেকে $to পর্যন্ত অনুপস্থিতি বাতিল করেছেন';
  }

  @override
  String activityChoresAvailabilityDecided(
    String member,
    String from,
    String to,
  ) {
    return '$member $from থেকে $to পর্যন্ত অনুপস্থিতির সিদ্ধান্ত দিয়েছেন';
  }

  @override
  String activityChoresSwapRequested(
    String member,
    String to,
    String name,
    String date,
  ) {
    return '$member $to-কে $date-এ $name ধরতে অনুরোধ করেছেন';
  }

  @override
  String activityChoresSwapAccepted(String to, String name, String date) {
    return '$to $date-এ $name নিতে রাজি হয়েছেন';
  }

  @override
  String activityChoresSwapDeclined(String to, String name, String date) {
    return '$to $date-এ $name নিতে রাজি হননি';
  }

  @override
  String activityChoresSwapCancelled(String member, String name, String date) {
    return '$member $date-এ $name এর অনুরোধ বাতিল করেছেন';
  }

  @override
  String activityChoresSwapExpired(String name, String date) {
    return '$date-এ $name এর অনুরোধের সময় শেষ হয়েছে';
  }

  @override
  String activityChoresCoverAssigned(String to, String name, String date) {
    return '$to $date-এ $name সামলাবেন';
  }

  @override
  String get occurrenceDetailTitle => 'কাজ';

  @override
  String occurrenceDueToday(String time) {
    return 'আজ, $timeটার মধ্যে';
  }

  @override
  String occurrenceDueDay(String time, String date) {
    return '$date, $timeটার মধ্যে';
  }

  @override
  String get occurrenceDueNoTime => 'দিনের শেষে';

  @override
  String get occurrenceUnassigned => 'এখনো কেউ দায়িত্বে নেই';

  @override
  String occurrenceCoveringFor(String name) {
    return '$name-এর হয়ে করছেন';
  }

  @override
  String get occurrenceStepsTitle => 'ধাপগুলো';

  @override
  String get occurrenceInstructionsTitle => 'কীভাবে করবেন';

  @override
  String occurrenceEstimated(String minutes) {
    return 'প্রায় $minutes মিনিট';
  }

  @override
  String get occurrenceDifficultyEasy => 'সহজ';

  @override
  String get occurrenceDifficultyNormal => 'সাধারণ';

  @override
  String get occurrenceDifficultyHard => 'কঠিন';

  @override
  String get occurrenceTimelineTitle => 'ইতিহাস';

  @override
  String occurrenceEventCompleted(String name) {
    return '$name সম্পন্ন করেছেন';
  }

  @override
  String occurrenceEventUncompleted(String name) {
    return '$name সম্পন্নতা ফিরিয়ে নিয়েছেন';
  }

  @override
  String occurrenceEventVerified(String name) {
    return '$name যাচাই করেছেন';
  }

  @override
  String occurrenceEventReopened(String name, String reason) {
    return '$name আবার খুলেছেন: $reason';
  }

  @override
  String occurrenceEventReassigned(String name, String to, String reason) {
    return '$name $to-কে দিয়েছেন: $reason';
  }

  @override
  String occurrenceEventSkipped(String name, String reason) {
    return '$name বাদ দিয়েছেন: $reason';
  }

  @override
  String occurrenceEventUnskipped(String name) {
    return '$name আবার ফিরিয়ে দিয়েছেন';
  }

  @override
  String occurrenceEventException(String name, String reason) {
    return '$name নোট দিয়ে শেষ করেছেন: $reason';
  }

  @override
  String occurrenceEventSwapped(String name, String to) {
    return '$name $to-এর সাথে বদল করেছেন';
  }

  @override
  String occurrenceEventCovered(String name, String to) {
    return '$name $to-এর কাজ করেছেন';
  }

  @override
  String get occurrenceActionComplete => 'সম্পন্ন করুন';

  @override
  String get occurrenceActionUndo => 'সম্পন্নতা ফিরিয়ে নিন';

  @override
  String get occurrenceActionVerify => 'যাচাই করুন';

  @override
  String get occurrenceActionReopen => 'আবার খুলুন';

  @override
  String get occurrenceActionReassign => 'অন্যকে দিন';

  @override
  String get occurrenceActionSkip => 'বাদ দিন';

  @override
  String get occurrenceActionUnskip => 'ফিরিয়ে দিন';

  @override
  String get occurrenceActionException => 'নোট দিয়ে শেষ করুন';

  @override
  String get occurrenceActionSwap => 'আমি এটা করতে পারব না';

  @override
  String get occurrenceReopenTitle => 'কেন আবার খুলবেন?';

  @override
  String get occurrenceReassignTitle => 'কে করবে?';

  @override
  String get occurrenceReassignReasonTitle => 'কেন অন্যকে দিচ্ছেন?';

  @override
  String get occurrenceSkipTitle => 'কেন বাদ দিচ্ছেন?';

  @override
  String get occurrenceExceptionTitle => 'কী করা যায়নি?';

  @override
  String get occurrenceUndone => 'সম্পন্নতা ফিরিয়ে নেওয়া হয়েছে';

  @override
  String get occurrenceStepReopened => 'হয়ে গেছে: কাজটি আবার খোলা আছে।';

  @override
  String get occurrencePlannedReadOnly =>
      'এটি এখন শুধু পরিকল্পিত; প্রথম পরিবর্তনেই কাজটি যোগ হবে।';

  @override
  String get occurrenceAwaitingVerification =>
      'কাজটি শেষ হয়েছে; যিনি করেননি তিনি যাচাই করবেন।';

  @override
  String get occurrenceReopenStepsTitle => 'কোন ধাপগুলো আবার করতে হবে?';

  @override
  String get occurrenceReopenStepsHint =>
      'যেগুলো বেছে নেবেন সেগুলোর টিক মুছে যাবে।';

  @override
  String get todayTitle => 'আজ';

  @override
  String get todayEmptyTitle => 'আজ কোনো কাজ নেই';

  @override
  String get todayEmptyMessage =>
      'ফাঁকা সময়টা উপভোগ করুন, বা পরে করার জন্য কাজ যোগ করুন।';

  @override
  String get todaySectionOverdue => 'বিলম্বিত';

  @override
  String get todaySectionDone => 'আজ সম্পন্ন';

  @override
  String get todayScopeMine => 'আমার কাজ';

  @override
  String get todayScopeFamily => 'পুরো পরিবার';

  @override
  String todayProgress(String done, String total) {
    return '$total-এর মধ্যে $done সম্পন্ন';
  }

  @override
  String get todayUndo => 'ফিরিয়ে নিন';

  @override
  String get verifyTitle => 'যাচাইয়ের অপেক্ষায়';

  @override
  String get verifyEmptyTitle => 'যাচাই করার কিছু নেই';

  @override
  String get verifyEmptyMessage =>
      'কেউ শেষ করে দিলে যে কাজগুলো যাচাই দরকার, সেগুলো এখানে দেখাবে।';

  @override
  String get verifyApprove => 'ঠিক আছে';

  @override
  String get verifyReopen => 'ফেরত দিন';

  @override
  String get choreDayPartEarlyMorning => 'ভোর';

  @override
  String get choreDayPartMorning => 'সকাল';

  @override
  String get choreDayPartNoon => 'দুপুর';

  @override
  String get choreDayPartAfternoon => 'বিকাল';

  @override
  String get choreDayPartEvening => 'সন্ধ্যা';

  @override
  String get choreDayPartNight => 'রাত';

  @override
  String choreDueTime(String time) {
    return '$timeটার মধ্যে';
  }

  @override
  String choreStepsCount(String done, String total) {
    return '$done/$total';
  }
}
