import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// The application name shown in the app bar and store listing.
  ///
  /// In bn, this message translates to:
  /// **'ফ্যামিলি হাব'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In bn, this message translates to:
  /// **'হোম'**
  String get navHome;

  /// No description provided for @navChores.
  ///
  /// In bn, this message translates to:
  /// **'কাজ'**
  String get navChores;

  /// No description provided for @navBazar.
  ///
  /// In bn, this message translates to:
  /// **'বাজার'**
  String get navBazar;

  /// No description provided for @navFamily.
  ///
  /// In bn, this message translates to:
  /// **'পরিবার'**
  String get navFamily;

  /// No description provided for @actionSave.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষণ'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In bn, this message translates to:
  /// **'বাতিল'**
  String get actionCancel;

  /// No description provided for @actionRetry.
  ///
  /// In bn, this message translates to:
  /// **'আবার চেষ্টা করুন'**
  String get actionRetry;

  /// No description provided for @actionDelete.
  ///
  /// In bn, this message translates to:
  /// **'মুছুন'**
  String get actionDelete;

  /// No description provided for @actionEdit.
  ///
  /// In bn, this message translates to:
  /// **'সম্পাদনা'**
  String get actionEdit;

  /// No description provided for @actionAdd.
  ///
  /// In bn, this message translates to:
  /// **'যোগ করুন'**
  String get actionAdd;

  /// No description provided for @catalogEditorEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এখনও কিছু নেই।'**
  String get catalogEditorEmpty;

  /// No description provided for @catalogEditorActions.
  ///
  /// In bn, this message translates to:
  /// **'সারির কাজ'**
  String get catalogEditorActions;

  /// No description provided for @catalogEditorActivate.
  ///
  /// In bn, this message translates to:
  /// **'আবার চালু করুন'**
  String get catalogEditorActivate;

  /// No description provided for @catalogEditorDeactivate.
  ///
  /// In bn, this message translates to:
  /// **'বন্ধ করুন'**
  String get catalogEditorDeactivate;

  /// No description provided for @catalogEditorAddTitle.
  ///
  /// In bn, this message translates to:
  /// **'নতুন সারি'**
  String get catalogEditorAddTitle;

  /// No description provided for @catalogEditorEditTitle.
  ///
  /// In bn, this message translates to:
  /// **'সারি সম্পাদনা'**
  String get catalogEditorEditTitle;

  /// No description provided for @catalogEditorLabelBn.
  ///
  /// In bn, this message translates to:
  /// **'নাম (বাংলা)'**
  String get catalogEditorLabelBn;

  /// No description provided for @catalogEditorLabelEn.
  ///
  /// In bn, this message translates to:
  /// **'নাম (ইংরেজি, ঐচ্ছিক)'**
  String get catalogEditorLabelEn;

  /// No description provided for @actionClose.
  ///
  /// In bn, this message translates to:
  /// **'বন্ধ করুন'**
  String get actionClose;

  /// No description provided for @actionBack.
  ///
  /// In bn, this message translates to:
  /// **'ফিরে যান'**
  String get actionBack;

  /// No description provided for @actionContinue.
  ///
  /// In bn, this message translates to:
  /// **'চালিয়ে যান'**
  String get actionContinue;

  /// No description provided for @actionDone.
  ///
  /// In bn, this message translates to:
  /// **'সম্পন্ন'**
  String get actionDone;

  /// No description provided for @authSignInTitle.
  ///
  /// In bn, this message translates to:
  /// **'লগ ইন করুন'**
  String get authSignInTitle;

  /// No description provided for @authSignUpTitle.
  ///
  /// In bn, this message translates to:
  /// **'নতুন অ্যাকাউন্ট খুলুন'**
  String get authSignUpTitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In bn, this message translates to:
  /// **'ইমেইল'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড'**
  String get authPasswordLabel;

  /// No description provided for @authForgotPassword.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড ভুলে গেছেন?'**
  String get authForgotPassword;

  /// No description provided for @authSignOut.
  ///
  /// In bn, this message translates to:
  /// **'লগ আউট'**
  String get authSignOut;

  /// No description provided for @authEmailVerificationSent.
  ///
  /// In bn, this message translates to:
  /// **'যাচাইকরণ ইমেইল পাঠানো হয়েছে।'**
  String get authEmailVerificationSent;

  /// Headline on the welcome screen.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের হিসাব, এক জায়গায়'**
  String get authWelcomeHeadline;

  /// No description provided for @authWelcomeMessage.
  ///
  /// In bn, this message translates to:
  /// **'বাজার খরচ, পরিবারের তহবিল আর কাজের রুটিন — সবাই মিলে একসাথে সামলান।'**
  String get authWelcomeMessage;

  /// No description provided for @authGetStarted.
  ///
  /// In bn, this message translates to:
  /// **'শুরু করুন'**
  String get authGetStarted;

  /// No description provided for @authSignInAction.
  ///
  /// In bn, this message translates to:
  /// **'লগ ইন'**
  String get authSignInAction;

  /// No description provided for @authCreateAccountAction.
  ///
  /// In bn, this message translates to:
  /// **'নতুন অ্যাকাউন্ট খুলুন'**
  String get authCreateAccountAction;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'আপনার ইমেইল ও পাসওয়ার্ড দিয়ে প্রবেশ করুন।'**
  String get authSignInSubtitle;

  /// No description provided for @authSignUpSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাকাউন্ট খুললে একটি যাচাইকরণ ইমেইল পাঠানো হবে।'**
  String get authSignUpSubtitle;

  /// No description provided for @authNoAccountYet.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাকাউন্ট নেই?'**
  String get authNoAccountYet;

  /// No description provided for @authAlreadyHaveAccount.
  ///
  /// In bn, this message translates to:
  /// **'আগেই অ্যাকাউন্ট আছে?'**
  String get authAlreadyHaveAccount;

  /// No description provided for @authShowPassword.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড দেখান'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড লুকান'**
  String get authHidePassword;

  /// No description provided for @authEmailHint.
  ///
  /// In bn, this message translates to:
  /// **'যেমন name@example.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordHint.
  ///
  /// In bn, this message translates to:
  /// **'অন্তত ৮ অক্ষর'**
  String get authPasswordHint;

  /// No description provided for @authEmailConfirmed.
  ///
  /// In bn, this message translates to:
  /// **'ইমেইল'**
  String get authEmailConfirmed;

  /// No description provided for @authPasswordTooShortHelper.
  ///
  /// In bn, this message translates to:
  /// **'কমপক্ষে ৮ অক্ষরের পাসওয়ার্ড দিন।'**
  String get authPasswordTooShortHelper;

  /// No description provided for @authPasswordConfirmLabel.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড আবার লিখুন'**
  String get authPasswordConfirmLabel;

  /// No description provided for @authFailureValidationPasswordMismatch.
  ///
  /// In bn, this message translates to:
  /// **'দুটি পাসওয়ার্ড মিলছে না।'**
  String get authFailureValidationPasswordMismatch;

  /// No description provided for @authFailureValidationPasswordConfirmRequired.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ডটি আবার লিখুন।'**
  String get authFailureValidationPasswordConfirmRequired;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড রিসেট'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'ইমেইল দিন, আমরা একটি রিসেট লিংক পাঠাব।'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authForgotPasswordSend.
  ///
  /// In bn, this message translates to:
  /// **'রিসেট লিংক পাঠান'**
  String get authForgotPasswordSend;

  /// No description provided for @authForgotPasswordSentTitle.
  ///
  /// In bn, this message translates to:
  /// **'ইমেইল পাঠানো হয়েছে'**
  String get authForgotPasswordSentTitle;

  /// No description provided for @authForgotPasswordSentMessage.
  ///
  /// In bn, this message translates to:
  /// **'{email} ঠিকানায় একটি রিসেট লিংক পাঠানো হয়েছে। স্প্যাম ফোল্ডারও দেখে নিন।'**
  String authForgotPasswordSentMessage(String email);

  /// No description provided for @authVerifyEmailTitle.
  ///
  /// In bn, this message translates to:
  /// **'ইমেইল যাচাই করুন'**
  String get authVerifyEmailTitle;

  /// No description provided for @authVerifyEmailMessage.
  ///
  /// In bn, this message translates to:
  /// **'{email} ঠিকানায় একটি যাচাইকরণ লিংক পাঠানো হয়েছে। লিংকে চাপ দিয়ে তারপর নিচের বাটনে চাপ দিন।'**
  String authVerifyEmailMessage(String email);

  /// No description provided for @authVerifyEmailIHaveVerified.
  ///
  /// In bn, this message translates to:
  /// **'আমি যাচাই করেছি'**
  String get authVerifyEmailIHaveVerified;

  /// No description provided for @authVerifyEmailResend.
  ///
  /// In bn, this message translates to:
  /// **'আবার ইমেইল পাঠান'**
  String get authVerifyEmailResend;

  /// No description provided for @authVerifyEmailStillUnverified.
  ///
  /// In bn, this message translates to:
  /// **'এখনো যাচাই হয়নি। ইমেইলের লিংকে চাপ দিন, তারপর আবার চেষ্টা করুন।'**
  String get authVerifyEmailStillUnverified;

  /// No description provided for @authVerifyEmailVerified.
  ///
  /// In bn, this message translates to:
  /// **'ইমেইল যাচাই সম্পন্ন হয়েছে।'**
  String get authVerifyEmailVerified;

  /// No description provided for @authVerifyEmailSignOutInstead.
  ///
  /// In bn, this message translates to:
  /// **'অন্য অ্যাকাউন্টে ঢুকুন'**
  String get authVerifyEmailSignOutInstead;

  /// No description provided for @authUsingAccount.
  ///
  /// In bn, this message translates to:
  /// **'লগ ইন করা আছে: {email}'**
  String authUsingAccount(String email);

  /// No description provided for @authFailurePermissionDenied.
  ///
  /// In bn, this message translates to:
  /// **'আপনার এই কাজটি করার অনুমতি নেই।'**
  String get authFailurePermissionDenied;

  /// No description provided for @authFailureNotFound.
  ///
  /// In bn, this message translates to:
  /// **'আপনার অ্যাকাউন্টটি খুঁজে পাওয়া যায়নি।'**
  String get authFailureNotFound;

  /// No description provided for @authFailureConflict.
  ///
  /// In bn, this message translates to:
  /// **'কেউ ইতিমধ্যে তথ্য বদলেছে। অ্যাপটি আবার খুলে চেষ্টা করুন।'**
  String get authFailureConflict;

  /// No description provided for @authFailureNetwork.
  ///
  /// In bn, this message translates to:
  /// **'ইন্টারনেট সংযোগ পাওয়া যায়নি। সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।'**
  String get authFailureNetwork;

  /// No description provided for @authFailureInvalidCredentials.
  ///
  /// In bn, this message translates to:
  /// **'ইমেইল বা পাসওয়ার্ড ঠিক নয়।'**
  String get authFailureInvalidCredentials;

  /// No description provided for @authFailureUserNotFound.
  ///
  /// In bn, this message translates to:
  /// **'এই ইমেইলে কোনো অ্যাকাউন্ট নেই।'**
  String get authFailureUserNotFound;

  /// No description provided for @authFailureEmailInUse.
  ///
  /// In bn, this message translates to:
  /// **'এই ইমেইলে আগেই একটি অ্যাকাউন্ট আছে। লগ ইন করে দেখুন।'**
  String get authFailureEmailInUse;

  /// No description provided for @authFailureWeakPassword.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ডটি দুর্বল। অন্তত ৮ অক্ষরের পাসওয়ার্ড দিন।'**
  String get authFailureWeakPassword;

  /// No description provided for @authFailureTooManyRequests.
  ///
  /// In bn, this message translates to:
  /// **'অনেকবার চেষ্টা করা হয়েছে। কিছুক্ষণ পরে আবার চেষ্টা করুন।'**
  String get authFailureTooManyRequests;

  /// No description provided for @authFailureUserDisabled.
  ///
  /// In bn, this message translates to:
  /// **'এই অ্যাকাউন্টটি বন্ধ করা হয়েছে। পরিবারের অ্যাডমিনের সাথে কথা বলুন।'**
  String get authFailureUserDisabled;

  /// No description provided for @authFailureRequiresRecentLogin.
  ///
  /// In bn, this message translates to:
  /// **'নিরাপত্তার জন্য আবার লগ ইন করুন, তারপর চেষ্টা করুন।'**
  String get authFailureRequiresRecentLogin;

  /// No description provided for @authFailureInvalidEmail.
  ///
  /// In bn, this message translates to:
  /// **'ইমেইল ঠিকানাটি সঠিক নয়।'**
  String get authFailureInvalidEmail;

  /// No description provided for @authFailureNoCurrentUser.
  ///
  /// In bn, this message translates to:
  /// **'আপনি আগে লগ আউট করেছেন। আবার লগ ইন করুন।'**
  String get authFailureNoCurrentUser;

  /// No description provided for @authFailureValidationRequired.
  ///
  /// In bn, this message translates to:
  /// **'{field} পূরণ করুন।'**
  String authFailureValidationRequired(String field);

  /// No description provided for @authFailureValidationInvalidEmail.
  ///
  /// In bn, this message translates to:
  /// **'সঠিক ইমেইল ঠিকানা দিন।'**
  String get authFailureValidationInvalidEmail;

  /// No description provided for @authFailureValidationPasswordTooShort.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড অন্তত ৮ অক্ষরের হতে হবে।'**
  String get authFailureValidationPasswordTooShort;

  /// No description provided for @authFailureUnknown.
  ///
  /// In bn, this message translates to:
  /// **'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।'**
  String get authFailureUnknown;

  /// No description provided for @authFieldEmail.
  ///
  /// In bn, this message translates to:
  /// **'ইমেইল'**
  String get authFieldEmail;

  /// No description provided for @authFieldPassword.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড'**
  String get authFieldPassword;

  /// No description provided for @errorPermissionDenied.
  ///
  /// In bn, this message translates to:
  /// **'আপনার এই কাজটি করার অনুমতি নেই।'**
  String get errorPermissionDenied;

  /// No description provided for @errorNotFound.
  ///
  /// In bn, this message translates to:
  /// **'তথ্যটি খুঁজে পাওয়া যায়নি।'**
  String get errorNotFound;

  /// No description provided for @errorConflict.
  ///
  /// In bn, this message translates to:
  /// **'কেউ ইতিমধ্যে এই তথ্য পরিবর্তন করেছে। আবার চেষ্টা করুন।'**
  String get errorConflict;

  /// No description provided for @errorNetwork.
  ///
  /// In bn, this message translates to:
  /// **'ইন্টারনেট সংযোগ পাওয়া যায়নি। সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।'**
  String get errorNetwork;

  /// No description provided for @errorUnknown.
  ///
  /// In bn, this message translates to:
  /// **'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।'**
  String get errorUnknown;

  /// No description provided for @errorValidationRequired.
  ///
  /// In bn, this message translates to:
  /// **'{field} পূরণ করুন।'**
  String errorValidationRequired(String field);

  /// No description provided for @errorValidationEmail.
  ///
  /// In bn, this message translates to:
  /// **'সঠিক ইমেইল ঠিকানা দিন।'**
  String get errorValidationEmail;

  /// No description provided for @errorValidationPasswordTooShort.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড অন্তত ৮ অক্ষরের হতে হবে।'**
  String get errorValidationPasswordTooShort;

  /// No description provided for @emptyGenericTitle.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কিছু নেই'**
  String get emptyGenericTitle;

  /// No description provided for @emptyGenericMessage.
  ///
  /// In bn, this message translates to:
  /// **'শুরু করতে নিচের বাটনে চাপ দিন।'**
  String get emptyGenericMessage;

  /// No description provided for @emptyNoDataTitle.
  ///
  /// In bn, this message translates to:
  /// **'কোনো তথ্য নেই'**
  String get emptyNoDataTitle;

  /// No description provided for @emptyNoDataMessage.
  ///
  /// In bn, this message translates to:
  /// **'এই তালিকাটি এখন খালি।'**
  String get emptyNoDataMessage;

  /// No description provided for @loadingGeneric.
  ///
  /// In bn, this message translates to:
  /// **'লোড হচ্ছে…'**
  String get loadingGeneric;

  /// No description provided for @offlineBanner.
  ///
  /// In bn, this message translates to:
  /// **'আপনি অফলাইনে আছেন। সংযোগ ফিরলে তথ্য সিঙ্ক হবে।'**
  String get offlineBanner;

  /// No description provided for @settingsTitle.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস'**
  String get settingsTitle;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাপিয়ারেন্স'**
  String get settingsThemeTitle;

  /// No description provided for @settingsThemeMode.
  ///
  /// In bn, this message translates to:
  /// **'থিম মোড'**
  String get settingsThemeMode;

  /// No description provided for @settingsColourPalette.
  ///
  /// In bn, this message translates to:
  /// **'রঙের প্যালেট'**
  String get settingsColourPalette;

  /// No description provided for @settingsFollowDevice.
  ///
  /// In bn, this message translates to:
  /// **'ডিভাইস অনুসরণ করুন'**
  String get settingsFollowDevice;

  /// No description provided for @settingsFollowDeviceSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'আপনার সিস্টেমের আলো / অন্ধকার সেটিং ব্যবহার করবে'**
  String get settingsFollowDeviceSubtitle;

  /// No description provided for @settingsThemeSelected.
  ///
  /// In bn, this message translates to:
  /// **'নির্বাচিত'**
  String get settingsThemeSelected;

  /// No description provided for @settingsThemeSelectedSemantics.
  ///
  /// In bn, this message translates to:
  /// **'{theme} থিম, নির্বাচিত'**
  String settingsThemeSelectedSemantics(String theme);

  /// No description provided for @settingsThemeUnselectedSemantics.
  ///
  /// In bn, this message translates to:
  /// **'{theme} থিম'**
  String settingsThemeUnselectedSemantics(String theme);

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In bn, this message translates to:
  /// **'ভাষা'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageSection.
  ///
  /// In bn, this message translates to:
  /// **'ভাষা নির্বাচন করুন'**
  String get settingsLanguageSection;

  /// No description provided for @settingsLanguageBangla.
  ///
  /// In bn, this message translates to:
  /// **'বাংলা'**
  String get settingsLanguageBangla;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In bn, this message translates to:
  /// **'ইংরেজি'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাপের ভাষা তাৎক্ষণিকভাবে পরিবর্তিত হয়'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsBanglaDigits.
  ///
  /// In bn, this message translates to:
  /// **'বাংলা অঙ্ক ব্যবহার করুন'**
  String get settingsBanglaDigits;

  /// No description provided for @settingsBanglaDigitsSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'সংখ্যা ও তারিখ বাংলা অঙ্কে (০১২৩) দেখাবে'**
  String get settingsBanglaDigitsSubtitle;

  /// No description provided for @settingsLanguageSelectedSemantics.
  ///
  /// In bn, this message translates to:
  /// **'{language} ভাষা, নির্বাচিত'**
  String settingsLanguageSelectedSemantics(String language);

  /// No description provided for @languageNameBn.
  ///
  /// In bn, this message translates to:
  /// **'বাংলা'**
  String get languageNameBn;

  /// No description provided for @languageNameEn.
  ///
  /// In bn, this message translates to:
  /// **'English'**
  String get languageNameEn;

  /// No description provided for @devTokensTitle.
  ///
  /// In bn, this message translates to:
  /// **'ডেভ — থিম টোকেন'**
  String get devTokensTitle;

  /// No description provided for @devGalleryTitle.
  ///
  /// In bn, this message translates to:
  /// **'ডেভ — গ্যালারি'**
  String get devGalleryTitle;

  /// No description provided for @homeViewThemeTokens.
  ///
  /// In bn, this message translates to:
  /// **'থিম টোকেন দেখুন'**
  String get homeViewThemeTokens;

  /// No description provided for @moduleComingSoonTitle.
  ///
  /// In bn, this message translates to:
  /// **'শীঘ্রই আসছে'**
  String get moduleComingSoonTitle;

  /// No description provided for @moduleComingSoonMessage.
  ///
  /// In bn, this message translates to:
  /// **'এই অংশটি এখনো তৈরি হচ্ছে।'**
  String get moduleComingSoonMessage;

  /// No description provided for @bazarHomeEmptyTitle.
  ///
  /// In bn, this message translates to:
  /// **'বাজার এখনো খালি'**
  String get bazarHomeEmptyTitle;

  /// No description provided for @bazarHomeEmptyMessage.
  ///
  /// In bn, this message translates to:
  /// **'খরচ, বাজার তালিকা ও হিসাবের অংশগুলো ধাপে ধাপে এখানে যোগ হবে।'**
  String get bazarHomeEmptyMessage;

  /// No description provided for @bazarCatalogSetupTitle.
  ///
  /// In bn, this message translates to:
  /// **'স্টার্টার বাজার তালিকা সেট করুন'**
  String get bazarCatalogSetupTitle;

  /// No description provided for @bazarCatalogSetupMessage.
  ///
  /// In bn, this message translates to:
  /// **'শুরু করার জন্য ১১টি ক্যাটাগরি ও ৫৪টি সাধারণ আইটেম যোগ করুন। পরে আপনি সেগুলো সম্পাদনা, যোগ বা লুকাতে পারবেন।'**
  String get bazarCatalogSetupMessage;

  /// No description provided for @bazarCatalogSetupAction.
  ///
  /// In bn, this message translates to:
  /// **'তালিকা তৈরি করুন'**
  String get bazarCatalogSetupAction;

  /// No description provided for @bazarCatalogSetupBusy.
  ///
  /// In bn, this message translates to:
  /// **'বাজার তালিকা তৈরি হচ্ছে…'**
  String get bazarCatalogSetupBusy;

  /// No description provided for @bazarCatalogAskAdminTitle.
  ///
  /// In bn, this message translates to:
  /// **'বাজার তালিকা তৈরি হয়নি'**
  String get bazarCatalogAskAdminTitle;

  /// No description provided for @bazarCatalogAskAdminMessage.
  ///
  /// In bn, this message translates to:
  /// **'বাজার তালিকা তৈরি করতে একজন অ্যাডমিনকে বলুন।'**
  String get bazarCatalogAskAdminMessage;

  /// No description provided for @bazarSettingsTitle.
  ///
  /// In bn, this message translates to:
  /// **'বাজারের সেটিংস'**
  String get bazarSettingsTitle;

  /// No description provided for @unitKg.
  ///
  /// In bn, this message translates to:
  /// **'কেজি'**
  String get unitKg;

  /// No description provided for @unitG.
  ///
  /// In bn, this message translates to:
  /// **'গ্রাম'**
  String get unitG;

  /// No description provided for @unitLitre.
  ///
  /// In bn, this message translates to:
  /// **'লিটার'**
  String get unitLitre;

  /// No description provided for @unitPiece.
  ///
  /// In bn, this message translates to:
  /// **'পিস'**
  String get unitPiece;

  /// No description provided for @unitDozen.
  ///
  /// In bn, this message translates to:
  /// **'ডজন'**
  String get unitDozen;

  /// No description provided for @unitPacket.
  ///
  /// In bn, this message translates to:
  /// **'প্যাকেট'**
  String get unitPacket;

  /// No description provided for @unitCylinder.
  ///
  /// In bn, this message translates to:
  /// **'সিলিন্ডার'**
  String get unitCylinder;

  /// No description provided for @bazarFundingFund.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের তহবিল'**
  String get bazarFundingFund;

  /// No description provided for @bazarFundingMember.
  ///
  /// In bn, this message translates to:
  /// **'সদস্য পরিশোধিত'**
  String get bazarFundingMember;

  /// No description provided for @bazarAdvancePending.
  ///
  /// In bn, this message translates to:
  /// **'অপেক্ষমাণ'**
  String get bazarAdvancePending;

  /// No description provided for @bazarAdvancePartial.
  ///
  /// In bn, this message translates to:
  /// **'আংশিক সমন্বিত'**
  String get bazarAdvancePartial;

  /// No description provided for @bazarAdvanceSettled.
  ///
  /// In bn, this message translates to:
  /// **'সমন্বিত'**
  String get bazarAdvanceSettled;

  /// No description provided for @bazarAdvanceVoided.
  ///
  /// In bn, this message translates to:
  /// **'বাতিল'**
  String get bazarAdvanceVoided;

  /// No description provided for @bazarErrRequired.
  ///
  /// In bn, this message translates to:
  /// **'এই ঘরটি পূরণ করুন।'**
  String get bazarErrRequired;

  /// No description provided for @bazarErrTooLong.
  ///
  /// In bn, this message translates to:
  /// **'লেখাটি অনেক বড় হয়ে গেছে।'**
  String get bazarErrTooLong;

  /// No description provided for @bazarErrInvalidAmount.
  ///
  /// In bn, this message translates to:
  /// **'সঠিক অঙ্ক লিখুন।'**
  String get bazarErrInvalidAmount;

  /// No description provided for @bazarErrAmountNotPositive.
  ///
  /// In bn, this message translates to:
  /// **'অঙ্কটি শূন্যের বেশি হতে হবে।'**
  String get bazarErrAmountNotPositive;

  /// No description provided for @bazarErrFutureDate.
  ///
  /// In bn, this message translates to:
  /// **'তারিখ ভবিষ্যতের হতে পারে না।'**
  String get bazarErrFutureDate;

  /// No description provided for @bazarErrQtyUnitRequired.
  ///
  /// In bn, this message translates to:
  /// **'পরিমাণ ও একক দুটোই দিন।'**
  String get bazarErrQtyUnitRequired;

  /// No description provided for @bazarErrMemberRequired.
  ///
  /// In bn, this message translates to:
  /// **'সদস্যটি বেছে নিন।'**
  String get bazarErrMemberRequired;

  /// No description provided for @bazarErrCategoryRequired.
  ///
  /// In bn, this message translates to:
  /// **'ক্যাটাগরি বেছে নিন।'**
  String get bazarErrCategoryRequired;

  /// No description provided for @bazarErrItemNameRequired.
  ///
  /// In bn, this message translates to:
  /// **'আইটেমের নাম লিখুন।'**
  String get bazarErrItemNameRequired;

  /// No description provided for @bazarErrTooManyLines.
  ///
  /// In bn, this message translates to:
  /// **'সারি অনেক বেশি; কিছু সরিয়ে দিন।'**
  String get bazarErrTooManyLines;

  /// No description provided for @bazarErrInvalidMonth.
  ///
  /// In bn, this message translates to:
  /// **'সঠিক মাস বেছে নিন।'**
  String get bazarErrInvalidMonth;

  /// No description provided for @bazarErrInvalidRange.
  ///
  /// In bn, this message translates to:
  /// **'শেষ তারিখ শুরুর তারিখের পরে হতে হবে।'**
  String get bazarErrInvalidRange;

  /// No description provided for @bazarErrNegative.
  ///
  /// In bn, this message translates to:
  /// **'অঙ্ক ঋণাত্মক হতে পারে না।'**
  String get bazarErrNegative;

  /// No description provided for @bazarErrTooManyDecimals.
  ///
  /// In bn, this message translates to:
  /// **'সর্বোচ্চ দুই দশমিক স্থান ব্যবহার করুন।'**
  String get bazarErrTooManyDecimals;

  /// No description provided for @bazarErrTooLarge.
  ///
  /// In bn, this message translates to:
  /// **'অঙ্কটি অনেক বড়।'**
  String get bazarErrTooLarge;

  /// No description provided for @bazarErrMonthLocked.
  ///
  /// In bn, this message translates to:
  /// **'এই মাস বন্ধ আছে। খুলতে অ্যাডমিনকে বলুন।'**
  String get bazarErrMonthLocked;

  /// No description provided for @bazarErrAdvanceSettled.
  ///
  /// In bn, this message translates to:
  /// **'এই অগ্রিম আংশিক বা সম্পূর্ণ সমন্বয় হয়ে গেছে।'**
  String get bazarErrAdvanceSettled;

  /// No description provided for @bazarErrOverpayment.
  ///
  /// In bn, this message translates to:
  /// **'বাকি থাকা অঙ্কের চেয়ে বেশি দেওয়া হয়েছে।'**
  String get bazarErrOverpayment;

  /// No description provided for @bazarErrAlreadyClosed.
  ///
  /// In bn, this message translates to:
  /// **'এই মাস ইতিমধ্যে বন্ধ আছে।'**
  String get bazarErrAlreadyClosed;

  /// No description provided for @bazarErrNotClosed.
  ///
  /// In bn, this message translates to:
  /// **'এই মাস বন্ধ নয়।'**
  String get bazarErrNotClosed;

  /// No description provided for @bazarErrReopenNoteRequired.
  ///
  /// In bn, this message translates to:
  /// **'মাসটি কেন খুলছেন তা লিখুন।'**
  String get bazarErrReopenNoteRequired;

  /// No description provided for @bazarErrCatalogNotEmpty.
  ///
  /// In bn, this message translates to:
  /// **'তালিকায় এখনো আইটেম আছে; আগে সেগুলো আর্কাইভ করুন।'**
  String get bazarErrCatalogNotEmpty;

  /// No description provided for @bazarErrDuplicateItem.
  ///
  /// In bn, this message translates to:
  /// **'ঠিক এই ধরনের খরচ সবেমাত্র যোগ হয়েছে। আবার সংরক্ষণের আগে দেখে নিন।'**
  String get bazarErrDuplicateItem;

  /// No description provided for @bazarErrImportAlreadyUndone.
  ///
  /// In bn, this message translates to:
  /// **'এই ইমপোর্ট আগেই বাতিল হয়েছে।'**
  String get bazarErrImportAlreadyUndone;

  /// No description provided for @bazarErrImportHasLockedMonth.
  ///
  /// In bn, this message translates to:
  /// **'ফাইলে বন্ধ মাসের সারি আছে।'**
  String get bazarErrImportHasLockedMonth;

  /// No description provided for @bazarErrConcurrentEdit.
  ///
  /// In bn, this message translates to:
  /// **'আপনার আগেই কেউ এটি বদলেছেন। রিফ্রেশ করে আবার চেষ্টা করুন।'**
  String get bazarErrConcurrentEdit;

  /// No description provided for @bazarErrNotFound.
  ///
  /// In bn, this message translates to:
  /// **'রেকর্ডটি আর নেই। রিফ্রেশ করে আবার চেষ্টা করুন।'**
  String get bazarErrNotFound;

  /// No description provided for @bazarErrNotAllowed.
  ///
  /// In bn, this message translates to:
  /// **'শুধু সংসার ব্যবস্থাপক বা অ্যাডমিন এটি করতে পারেন।'**
  String get bazarErrNotAllowed;

  /// No description provided for @bazarErrUnknown.
  ///
  /// In bn, this message translates to:
  /// **'কিছু একটা সমস্যা হয়েছে। আবার চেষ্টা করুন।'**
  String get bazarErrUnknown;

  /// No description provided for @profileSetupTitle.
  ///
  /// In bn, this message translates to:
  /// **'আপনার প্রোফাইল তৈরি করুন'**
  String get profileSetupTitle;

  /// No description provided for @profileSetupMessage.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারকে জানান আপনি কে।'**
  String get profileSetupMessage;

  /// No description provided for @familyChoiceTitle.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারে যোগ দিন বা নতুন তৈরি করুন'**
  String get familyChoiceTitle;

  /// No description provided for @familyChoiceMessage.
  ///
  /// In bn, this message translates to:
  /// **'নতুন পরিবার তৈরি করুন, অথবা আমন্ত্রণ কোড দিয়ে যোগ দিন।'**
  String get familyChoiceMessage;

  /// No description provided for @pendingTitle.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদনের অপেক্ষায়'**
  String get pendingTitle;

  /// No description provided for @pendingMessage.
  ///
  /// In bn, this message translates to:
  /// **'চালিয়ে যেতে পরিবারের অ্যাডমিনকে আপনার অনুরোধ অনুমোদন করতে হবে।'**
  String get pendingMessage;

  /// No description provided for @disabledTitle.
  ///
  /// In bn, this message translates to:
  /// **'প্রবেশ বন্ধ আছে'**
  String get disabledTitle;

  /// No description provided for @disabledMessage.
  ///
  /// In bn, this message translates to:
  /// **'এই পরিবারে আপনার প্রবেশ বন্ধ করা হয়েছে। অনুগ্রহ করে অ্যাডমিনের সাথে যোগাযোগ করুন।'**
  String get disabledMessage;

  /// No description provided for @placeholderContinueProfile.
  ///
  /// In bn, this message translates to:
  /// **'চালিয়ে যান (অস্থায়ী)'**
  String get placeholderContinueProfile;

  /// No description provided for @placeholderCreateFamily.
  ///
  /// In bn, this message translates to:
  /// **'পরীক্ষামূলক পরিবার তৈরি করুন (অস্থায়ী)'**
  String get placeholderCreateFamily;

  /// No description provided for @placeholderApproveMe.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদিত ধরে নিন (অস্থায়ী)'**
  String get placeholderApproveMe;

  /// No description provided for @notFoundTitle.
  ///
  /// In bn, this message translates to:
  /// **'পাতাটি পাওয়া যায়নি'**
  String get notFoundTitle;

  /// No description provided for @notFoundMessage.
  ///
  /// In bn, this message translates to:
  /// **'আপনি যে পাতাটি খুলেছেন সেটি নেই।'**
  String get notFoundMessage;

  /// No description provided for @notFoundAction.
  ///
  /// In bn, this message translates to:
  /// **'হোমে যান'**
  String get notFoundAction;

  /// No description provided for @profileFullName.
  ///
  /// In bn, this message translates to:
  /// **'পুরো নাম'**
  String get profileFullName;

  /// No description provided for @profileNickname.
  ///
  /// In bn, this message translates to:
  /// **'ডাকনাম (ঐচ্ছিক)'**
  String get profileNickname;

  /// No description provided for @profileGender.
  ///
  /// In bn, this message translates to:
  /// **'লিঙ্গ (ঐচ্ছিক)'**
  String get profileGender;

  /// No description provided for @genderMale.
  ///
  /// In bn, this message translates to:
  /// **'পুরুষ'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In bn, this message translates to:
  /// **'নারী'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In bn, this message translates to:
  /// **'অন্যান্য'**
  String get genderOther;

  /// No description provided for @genderNone.
  ///
  /// In bn, this message translates to:
  /// **'বলতে চাই না'**
  String get genderNone;

  /// No description provided for @profileRelationship.
  ///
  /// In bn, this message translates to:
  /// **'সম্পর্ক'**
  String get profileRelationship;

  /// No description provided for @profileAvatar.
  ///
  /// In bn, this message translates to:
  /// **'একটি অ্যাভাটার বেছে নিন'**
  String get profileAvatar;

  /// No description provided for @profileSave.
  ///
  /// In bn, this message translates to:
  /// **'প্রোফাইল সংরক্ষণ করুন'**
  String get profileSave;

  /// No description provided for @profileSpouse.
  ///
  /// In bn, this message translates to:
  /// **'স্বামী/স্ত্রী (ঐচ্ছিক)'**
  String get profileSpouse;

  /// No description provided for @profileSpouseNone.
  ///
  /// In bn, this message translates to:
  /// **'কেউ নয়'**
  String get profileSpouseNone;

  /// No description provided for @relFather.
  ///
  /// In bn, this message translates to:
  /// **'বাবা'**
  String get relFather;

  /// No description provided for @relMother.
  ///
  /// In bn, this message translates to:
  /// **'মা'**
  String get relMother;

  /// No description provided for @relSon.
  ///
  /// In bn, this message translates to:
  /// **'ছেলে'**
  String get relSon;

  /// No description provided for @relDaughter.
  ///
  /// In bn, this message translates to:
  /// **'মেয়ে'**
  String get relDaughter;

  /// No description provided for @relHusband.
  ///
  /// In bn, this message translates to:
  /// **'স্বামী'**
  String get relHusband;

  /// No description provided for @relWife.
  ///
  /// In bn, this message translates to:
  /// **'স্ত্রী'**
  String get relWife;

  /// No description provided for @relHousewife.
  ///
  /// In bn, this message translates to:
  /// **'গৃহিণী'**
  String get relHousewife;

  /// No description provided for @relDaughterInLaw.
  ///
  /// In bn, this message translates to:
  /// **'পুত্রবধূ'**
  String get relDaughterInLaw;

  /// No description provided for @relSonInLaw.
  ///
  /// In bn, this message translates to:
  /// **'জামাই'**
  String get relSonInLaw;

  /// No description provided for @relOther.
  ///
  /// In bn, this message translates to:
  /// **'অন্যান্য'**
  String get relOther;

  /// No description provided for @familyCreateAction.
  ///
  /// In bn, this message translates to:
  /// **'নতুন পরিবার তৈরি করুন'**
  String get familyCreateAction;

  /// No description provided for @familyJoinAction.
  ///
  /// In bn, this message translates to:
  /// **'কোড দিয়ে যোগ দিন'**
  String get familyJoinAction;

  /// No description provided for @familyNameLabel.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের নাম'**
  String get familyNameLabel;

  /// No description provided for @familyCreateSubmit.
  ///
  /// In bn, this message translates to:
  /// **'পরিবার তৈরি করুন'**
  String get familyCreateSubmit;

  /// No description provided for @joinCodeLabel.
  ///
  /// In bn, this message translates to:
  /// **'আমন্ত্রণ কোড'**
  String get joinCodeLabel;

  /// No description provided for @joinSubmit.
  ///
  /// In bn, this message translates to:
  /// **'যোগদানের অনুরোধ করুন'**
  String get joinSubmit;

  /// No description provided for @joinHint.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের অ্যাডমিনের কাছ থেকে ৮ অক্ষরের কোড নিন।'**
  String get joinHint;

  /// No description provided for @membersTitle.
  ///
  /// In bn, this message translates to:
  /// **'সদস্য'**
  String get membersTitle;

  /// No description provided for @membersPending.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদনের অপেক্ষায়'**
  String get membersPending;

  /// No description provided for @membersActive.
  ///
  /// In bn, this message translates to:
  /// **'সক্রিয়'**
  String get membersActive;

  /// No description provided for @membersDisabled.
  ///
  /// In bn, this message translates to:
  /// **'নিষ্ক্রিয়'**
  String get membersDisabled;

  /// No description provided for @memberYou.
  ///
  /// In bn, this message translates to:
  /// **'আপনি'**
  String get memberYou;

  /// No description provided for @memberApprove.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদন'**
  String get memberApprove;

  /// No description provided for @memberReject.
  ///
  /// In bn, this message translates to:
  /// **'প্রত্যাখ্যান'**
  String get memberReject;

  /// No description provided for @memberDisable.
  ///
  /// In bn, this message translates to:
  /// **'নিষ্ক্রিয় করুন'**
  String get memberDisable;

  /// No description provided for @memberReenable.
  ///
  /// In bn, this message translates to:
  /// **'আবার সক্রিয় করুন'**
  String get memberReenable;

  /// No description provided for @roleAdmin.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাডমিন'**
  String get roleAdmin;

  /// No description provided for @roleModerator.
  ///
  /// In bn, this message translates to:
  /// **'সংসার ব্যবস্থাপক'**
  String get roleModerator;

  /// No description provided for @roleMember.
  ///
  /// In bn, this message translates to:
  /// **'সদস্য'**
  String get roleMember;

  /// No description provided for @memberProfileTitle.
  ///
  /// In bn, this message translates to:
  /// **'সদস্যের প্রোফাইল'**
  String get memberProfileTitle;

  /// No description provided for @memberEditProfile.
  ///
  /// In bn, this message translates to:
  /// **'আমার প্রোফাইল সম্পাদনা'**
  String get memberEditProfile;

  /// No description provided for @memberRoleLabel.
  ///
  /// In bn, this message translates to:
  /// **'ভূমিকা'**
  String get memberRoleLabel;

  /// No description provided for @memberStatusLabel.
  ///
  /// In bn, this message translates to:
  /// **'অবস্থা'**
  String get memberStatusLabel;

  /// No description provided for @invitationsTitle.
  ///
  /// In bn, this message translates to:
  /// **'আমন্ত্রণ'**
  String get invitationsTitle;

  /// No description provided for @invitationCreate.
  ///
  /// In bn, this message translates to:
  /// **'আমন্ত্রণ কোড তৈরি করুন'**
  String get invitationCreate;

  /// No description provided for @invitationCopy.
  ///
  /// In bn, this message translates to:
  /// **'কোড কপি করুন'**
  String get invitationCopy;

  /// No description provided for @invitationCopied.
  ///
  /// In bn, this message translates to:
  /// **'কোড কপি হয়েছে'**
  String get invitationCopied;

  /// No description provided for @invitationExpiresOn.
  ///
  /// In bn, this message translates to:
  /// **'মেয়াদ শেষ'**
  String get invitationExpiresOn;

  /// No description provided for @invStatusActive.
  ///
  /// In bn, this message translates to:
  /// **'অব্যবহৃত'**
  String get invStatusActive;

  /// No description provided for @invStatusUsed.
  ///
  /// In bn, this message translates to:
  /// **'ব্যবহৃত'**
  String get invStatusUsed;

  /// No description provided for @invStatusExpired.
  ///
  /// In bn, this message translates to:
  /// **'মেয়াদোত্তীর্ণ'**
  String get invStatusExpired;

  /// No description provided for @invStatusRevoked.
  ///
  /// In bn, this message translates to:
  /// **'বাতিল'**
  String get invStatusRevoked;

  /// No description provided for @invitationsEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো আমন্ত্রণ নেই'**
  String get invitationsEmpty;

  /// No description provided for @rolesTitle.
  ///
  /// In bn, this message translates to:
  /// **'ভূমিকা'**
  String get rolesTitle;

  /// No description provided for @rolesMakeAdmin.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাডমিন বানান'**
  String get rolesMakeAdmin;

  /// No description provided for @rolesTransferTitle.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাডমিনের দায়িত্ব হস্তান্তর করবেন?'**
  String get rolesTransferTitle;

  /// No description provided for @rolesTransferMessage.
  ///
  /// In bn, this message translates to:
  /// **'আপনি সাধারণ সদস্য হয়ে যাবেন।'**
  String get rolesTransferMessage;

  /// No description provided for @actionConfirm.
  ///
  /// In bn, this message translates to:
  /// **'নিশ্চিত করুন'**
  String get actionConfirm;

  /// No description provided for @familySettingsTitle.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের সেটিংস'**
  String get familySettingsTitle;

  /// No description provided for @settingsTimezone.
  ///
  /// In bn, this message translates to:
  /// **'সময় অঞ্চল'**
  String get settingsTimezone;

  /// No description provided for @settingsCurrency.
  ///
  /// In bn, this message translates to:
  /// **'মুদ্রা'**
  String get settingsCurrency;

  /// No description provided for @settingsModules.
  ///
  /// In bn, this message translates to:
  /// **'মডিউল'**
  String get settingsModules;

  /// No description provided for @settingsSaved.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষিত হয়েছে'**
  String get settingsSaved;

  /// No description provided for @famFailureNameRequired.
  ///
  /// In bn, this message translates to:
  /// **'একটি নাম লিখুন।'**
  String get famFailureNameRequired;

  /// No description provided for @famFailureCodeInvalid.
  ///
  /// In bn, this message translates to:
  /// **'কোডটি সঠিক নয়। কোডে ৮টি অক্ষর ও সংখ্যা থাকে।'**
  String get famFailureCodeInvalid;

  /// No description provided for @famFailureCodeNotFound.
  ///
  /// In bn, this message translates to:
  /// **'এই কোডে কোনো আমন্ত্রণ পাওয়া যায়নি।'**
  String get famFailureCodeNotFound;

  /// No description provided for @famFailureCodeUsed.
  ///
  /// In bn, this message translates to:
  /// **'এই কোডটি আগেই ব্যবহার করা হয়েছে।'**
  String get famFailureCodeUsed;

  /// No description provided for @famFailureCodeExpired.
  ///
  /// In bn, this message translates to:
  /// **'কোডটির মেয়াদ শেষ। নতুন কোড চান।'**
  String get famFailureCodeExpired;

  /// No description provided for @famFailureCodeRevoked.
  ///
  /// In bn, this message translates to:
  /// **'কোডটি বাতিল করা হয়েছে।'**
  String get famFailureCodeRevoked;

  /// No description provided for @famFailureAlreadyMember.
  ///
  /// In bn, this message translates to:
  /// **'আপনি ইতিমধ্যে এই পরিবারে আছেন।'**
  String get famFailureAlreadyMember;

  /// No description provided for @famFailureLastAdmin.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারে অন্তত একজন অ্যাডমিন থাকতে হবে। আগে অন্য কাউকে অ্যাডমিন বানান।'**
  String get famFailureLastAdmin;

  /// No description provided for @famFailureTooManyAdmins.
  ///
  /// In bn, this message translates to:
  /// **'একটি পরিবারে সর্বোচ্চ তিনজন অ্যাডমিন থাকতে পারে।'**
  String get famFailureTooManyAdmins;

  /// No description provided for @famFailureNotAllowed.
  ///
  /// In bn, this message translates to:
  /// **'এটি করার অনুমতি আপনার নেই।'**
  String get famFailureNotAllowed;

  /// No description provided for @famFailureProfileRequired.
  ///
  /// In bn, this message translates to:
  /// **'আগে আপনার প্রোফাইল সম্পূর্ণ করুন।'**
  String get famFailureProfileRequired;

  /// No description provided for @avatarOption.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাভাটার {number}'**
  String avatarOption(String number);

  /// Status label for a chore occurrence that is scheduled.
  ///
  /// In bn, this message translates to:
  /// **'সময় নির্ধারিত'**
  String get statusScheduled;

  /// No description provided for @statusInProgress.
  ///
  /// In bn, this message translates to:
  /// **'চলছে'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In bn, this message translates to:
  /// **'সম্পন্ন'**
  String get statusCompleted;

  /// No description provided for @statusVerified.
  ///
  /// In bn, this message translates to:
  /// **'যাচাইকৃত'**
  String get statusVerified;

  /// No description provided for @statusOverdue.
  ///
  /// In bn, this message translates to:
  /// **'সময় পার হয়েছে'**
  String get statusOverdue;

  /// 'See all' link on a section header.
  ///
  /// In bn, this message translates to:
  /// **'সব দেখুন'**
  String get commonSeeAll;

  /// No description provided for @errorViewTitle.
  ///
  /// In bn, this message translates to:
  /// **'কিছু ভুল হয়েছে'**
  String get errorViewTitle;

  /// Screen-reader label for a loading skeleton.
  ///
  /// In bn, this message translates to:
  /// **'লোড হচ্ছে'**
  String get loadingSemantics;

  /// No description provided for @progressSemantics.
  ///
  /// In bn, this message translates to:
  /// **'{label}, {percent} শতাংশ সম্পন্ন'**
  String progressSemantics(String label, String percent);

  /// No description provided for @thumbSemantics.
  ///
  /// In bn, this message translates to:
  /// **'{name} ছবি'**
  String thumbSemantics(String name);

  /// No description provided for @galleryAvatar.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাভাটার'**
  String get galleryAvatar;

  /// No description provided for @galleryItemThumb.
  ///
  /// In bn, this message translates to:
  /// **'জিনিসের ছবি'**
  String get galleryItemThumb;

  /// No description provided for @galleryStatusChip.
  ///
  /// In bn, this message translates to:
  /// **'অবস্থার চিপ'**
  String get galleryStatusChip;

  /// No description provided for @galleryStatusGlyph.
  ///
  /// In bn, this message translates to:
  /// **'অবস্থার চিহ্ন'**
  String get galleryStatusGlyph;

  /// No description provided for @galleryFlagChip.
  ///
  /// In bn, this message translates to:
  /// **'ফ্ল্যাগ চিপ'**
  String get galleryFlagChip;

  /// No description provided for @galleryReasonSheet.
  ///
  /// In bn, this message translates to:
  /// **'কারণ শিট'**
  String get galleryReasonSheet;

  /// No description provided for @galleryMinutesField.
  ///
  /// In bn, this message translates to:
  /// **'সময়ের ঘর'**
  String get galleryMinutesField;

  /// No description provided for @galleryWeekdayChips.
  ///
  /// In bn, this message translates to:
  /// **'বার বাছাই'**
  String get galleryWeekdayChips;

  /// No description provided for @galleryColorSwatchPicker.
  ///
  /// In bn, this message translates to:
  /// **'রং বাছাই'**
  String get galleryColorSwatchPicker;

  /// No description provided for @galleryAvatarStack.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাভাটার সারি'**
  String get galleryAvatarStack;

  /// No description provided for @galleryStepProgress.
  ///
  /// In bn, this message translates to:
  /// **'ধাপের অগ্রগতি'**
  String get galleryStepProgress;

  /// No description provided for @galleryMiniMarkdown.
  ///
  /// In bn, this message translates to:
  /// **'ঘরের নিয়মের লেখা'**
  String get galleryMiniMarkdown;

  /// No description provided for @galleryCatalogEditor.
  ///
  /// In bn, this message translates to:
  /// **'তালিকা সম্পাদনা'**
  String get galleryCatalogEditor;

  /// No description provided for @galleryOpenSheet.
  ///
  /// In bn, this message translates to:
  /// **'শিট খুলুন'**
  String get galleryOpenSheet;

  /// No description provided for @gallerySampleDueTime.
  ///
  /// In bn, this message translates to:
  /// **'শেষ সময়'**
  String get gallerySampleDueTime;

  /// Sample mini-markdown for the gallery; keep the structure when translating.
  ///
  /// In bn, this message translates to:
  /// **'# ঘরের নিয়ম\n- খাওয়ার পর নিজের প্লেট ধুয়ে রাখা\n- **সকাল ৯টার মধ্যে রান্নাঘর খালি থাকতে হবে**\n1. গাছে পানি দেওয়া\n2. উঠান ঝাঁট দেওয়া'**
  String get gallerySampleRules;

  /// No description provided for @gallerySectionHeader.
  ///
  /// In bn, this message translates to:
  /// **'সেকশন হেডার'**
  String get gallerySectionHeader;

  /// No description provided for @galleryAppCard.
  ///
  /// In bn, this message translates to:
  /// **'কার্ড'**
  String get galleryAppCard;

  /// No description provided for @galleryMoneyText.
  ///
  /// In bn, this message translates to:
  /// **'টাকার লেখা'**
  String get galleryMoneyText;

  /// No description provided for @galleryProgressRing.
  ///
  /// In bn, this message translates to:
  /// **'প্রগ্রেস রিং'**
  String get galleryProgressRing;

  /// No description provided for @galleryEmptyState.
  ///
  /// In bn, this message translates to:
  /// **'খালি অবস্থা'**
  String get galleryEmptyState;

  /// No description provided for @galleryLoadingView.
  ///
  /// In bn, this message translates to:
  /// **'লোডিং দৃশ্য'**
  String get galleryLoadingView;

  /// No description provided for @galleryErrorView.
  ///
  /// In bn, this message translates to:
  /// **'ত্রুটির দৃশ্য'**
  String get galleryErrorView;

  /// No description provided for @galleryPillBottomBar.
  ///
  /// In bn, this message translates to:
  /// **'পিল নেভিগেশন বার'**
  String get galleryPillBottomBar;

  /// No description provided for @gallerySampleTitle.
  ///
  /// In bn, this message translates to:
  /// **'নমুনা শিরোনাম'**
  String get gallerySampleTitle;

  /// No description provided for @gallerySampleMessage.
  ///
  /// In bn, this message translates to:
  /// **'এটি একটি নমুনা বার্তা যা ওভারফ্লো যাচাই করে।'**
  String get gallerySampleMessage;

  /// No description provided for @gallerySampleItemName.
  ///
  /// In bn, this message translates to:
  /// **'আলু'**
  String get gallerySampleItemName;

  /// No description provided for @gallerySamplePersonName.
  ///
  /// In bn, this message translates to:
  /// **'করিম উদ্দিন'**
  String get gallerySamplePersonName;

  /// No description provided for @syncWaitingTitle.
  ///
  /// In bn, this message translates to:
  /// **'সংযোগের অপেক্ষায়…'**
  String get syncWaitingTitle;

  /// No description provided for @syncWaitingMessage.
  ///
  /// In bn, this message translates to:
  /// **'ইন্টারনেট সংযোগ আছে কিনা দেখুন, তারপর আবার চেষ্টা করুন। আপনার তথ্য নিরাপদ আছে।'**
  String get syncWaitingMessage;

  /// No description provided for @syncSavedOffline.
  ///
  /// In bn, this message translates to:
  /// **'এই ডিভাইসে সংরক্ষিত হয়েছে — অনলাইনে এলে সিঙ্ক হবে'**
  String get syncSavedOffline;

  /// No description provided for @syncBannerSyncing.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি পরিবর্তন সিঙ্ক হচ্ছে'**
  String syncBannerSyncing(int count);

  /// No description provided for @syncBannerOffline.
  ///
  /// In bn, this message translates to:
  /// **'অফলাইন — {count}টি পরিবর্তন অপেক্ষায়'**
  String syncBannerOffline(int count);

  /// No description provided for @gallerySyncBanner.
  ///
  /// In bn, this message translates to:
  /// **'সিঙ্ক ব্যানার'**
  String get gallerySyncBanner;

  /// No description provided for @famFailureAlreadyInFamily.
  ///
  /// In bn, this message translates to:
  /// **'আপনি ইতিমধ্যে একটি পরিবারে আছেন। আগে সেটি ছেড়ে দিন।'**
  String get famFailureAlreadyInFamily;

  /// No description provided for @familyLeave.
  ///
  /// In bn, this message translates to:
  /// **'পরিবার ছেড়ে যান'**
  String get familyLeave;

  /// No description provided for @familyLeaveConfirmTitle.
  ///
  /// In bn, this message translates to:
  /// **'পরিবার ছেড়ে যাবেন?'**
  String get familyLeaveConfirmTitle;

  /// No description provided for @familyLeaveConfirmBody.
  ///
  /// In bn, this message translates to:
  /// **'আপনার আগের কাজ ও হিসাবের ইতিহাস পরিবারে থেকে যাবে। পরে আপনি নতুন পরিবার খুলতে বা অন্য পরিবারে যোগ দিতে পারবেন।'**
  String get familyLeaveConfirmBody;

  /// No description provided for @familyLeaveLastAdminReason.
  ///
  /// In bn, this message translates to:
  /// **'আপনিই একমাত্র অ্যাডমিন। ছেড়ে যাওয়ার আগে আরেকজনকে অ্যাডমিন করুন।'**
  String get familyLeaveLastAdminReason;

  /// No description provided for @pendingCancelRequest.
  ///
  /// In bn, this message translates to:
  /// **'অনুরোধ বাতিল করুন'**
  String get pendingCancelRequest;

  /// No description provided for @invitationRevoke.
  ///
  /// In bn, this message translates to:
  /// **'কোড বাতিল করুন'**
  String get invitationRevoke;

  /// No description provided for @invitationRevokeConfirmTitle.
  ///
  /// In bn, this message translates to:
  /// **'কোডটি বাতিল করবেন?'**
  String get invitationRevokeConfirmTitle;

  /// No description provided for @invitationRevokeConfirmBody.
  ///
  /// In bn, this message translates to:
  /// **'এই কোড দিয়ে আর কেউ যোগ দিতে পারবে না।'**
  String get invitationRevokeConfirmBody;

  /// No description provided for @securityTitle.
  ///
  /// In bn, this message translates to:
  /// **'নিরাপত্তা'**
  String get securityTitle;

  /// No description provided for @securityChangePassword.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড পরিবর্তন'**
  String get securityChangePassword;

  /// No description provided for @securityCurrentPassword.
  ///
  /// In bn, this message translates to:
  /// **'বর্তমান পাসওয়ার্ড'**
  String get securityCurrentPassword;

  /// No description provided for @securityNewPassword.
  ///
  /// In bn, this message translates to:
  /// **'নতুন পাসওয়ার্ড'**
  String get securityNewPassword;

  /// No description provided for @securityPasswordChanged.
  ///
  /// In bn, this message translates to:
  /// **'পাসওয়ার্ড পরিবর্তন হয়েছে।'**
  String get securityPasswordChanged;

  /// No description provided for @securityPasswordSame.
  ///
  /// In bn, this message translates to:
  /// **'নতুন পাসওয়ার্ড বর্তমানটির থেকে আলাদা হতে হবে।'**
  String get securityPasswordSame;

  /// No description provided for @securityCurrentPasswordRequired.
  ///
  /// In bn, this message translates to:
  /// **'আপনার বর্তমান পাসওয়ার্ড লিখুন।'**
  String get securityCurrentPasswordRequired;

  /// No description provided for @securityCurrentPasswordWrong.
  ///
  /// In bn, this message translates to:
  /// **'বর্তমান পাসওয়ার্ডটি সঠিক নয়।'**
  String get securityCurrentPasswordWrong;

  /// No description provided for @securityDeleteTitle.
  ///
  /// In bn, this message translates to:
  /// **'আমার অ্যাকাউন্ট মুছুন'**
  String get securityDeleteTitle;

  /// No description provided for @securityDeleteBody.
  ///
  /// In bn, this message translates to:
  /// **'আপনি পরিবার ছেড়ে যাবেন এবং আপনার সাইন-ইন মুছে যাবে। পরিবারের ইতিহাস ঠিক রাখতে পুরোনো রেকর্ডে আপনার নাম থাকবে।'**
  String get securityDeleteBody;

  /// No description provided for @securityDeletePending.
  ///
  /// In bn, this message translates to:
  /// **'মুছে ফেলা শেষ হয়নি। শেষ করতে পাসওয়ার্ড লিখুন।'**
  String get securityDeletePending;

  /// No description provided for @securityDeleteAction.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাকাউন্ট মুছুন'**
  String get securityDeleteAction;

  /// No description provided for @securityDeleteFinish.
  ///
  /// In bn, this message translates to:
  /// **'মুছে ফেলা শেষ করুন'**
  String get securityDeleteFinish;

  /// No description provided for @securityDeleteConfirmTitle.
  ///
  /// In bn, this message translates to:
  /// **'আপনার অ্যাকাউন্ট মুছবেন?'**
  String get securityDeleteConfirmTitle;

  /// No description provided for @securityDeleteConfirmBody.
  ///
  /// In bn, this message translates to:
  /// **'এটি আর ফেরানো যাবে না।'**
  String get securityDeleteConfirmBody;

  /// No description provided for @accountDeleteLastAdminHasMembers.
  ///
  /// In bn, this message translates to:
  /// **'আপনি একমাত্র অ্যাডমিন এবং পরিবারে আরও সদস্য আছেন। আগে অ্যাডমিনের দায়িত্ব হস্তান্তর করুন।'**
  String get accountDeleteLastAdminHasMembers;

  /// No description provided for @relationshipsTitle.
  ///
  /// In bn, this message translates to:
  /// **'সম্পর্কের তালিকা'**
  String get relationshipsTitle;

  /// No description provided for @relationshipsHint.
  ///
  /// In bn, this message translates to:
  /// **'তৈরি-করা সম্পর্কগুলো পরিবর্তন করা যায় না। নিজের সম্পর্ক যোগ, নাম পরিবর্তন বা বন্ধ করতে পারেন।'**
  String get relationshipsHint;

  /// No description provided for @relationshipsAdd.
  ///
  /// In bn, this message translates to:
  /// **'সম্পর্ক যোগ করুন'**
  String get relationshipsAdd;

  /// No description provided for @relationshipsLabelBn.
  ///
  /// In bn, this message translates to:
  /// **'বাংলায় নাম'**
  String get relationshipsLabelBn;

  /// No description provided for @relationshipsLabelEn.
  ///
  /// In bn, this message translates to:
  /// **'ইংরেজিতে নাম'**
  String get relationshipsLabelEn;

  /// No description provided for @relationshipsSpouseRelevant.
  ///
  /// In bn, this message translates to:
  /// **'স্বামী/স্ত্রী বাছাই দেখান'**
  String get relationshipsSpouseRelevant;

  /// No description provided for @relationshipsBuiltIn.
  ///
  /// In bn, this message translates to:
  /// **'তৈরি-করা'**
  String get relationshipsBuiltIn;

  /// No description provided for @relationshipsActive.
  ///
  /// In bn, this message translates to:
  /// **'চালু'**
  String get relationshipsActive;

  /// No description provided for @relationshipsDisabled.
  ///
  /// In bn, this message translates to:
  /// **'বন্ধ'**
  String get relationshipsDisabled;

  /// No description provided for @relationshipsEnable.
  ///
  /// In bn, this message translates to:
  /// **'চালু করুন'**
  String get relationshipsEnable;

  /// No description provided for @relationshipsDisable.
  ///
  /// In bn, this message translates to:
  /// **'বন্ধ করুন'**
  String get relationshipsDisable;

  /// No description provided for @relationshipsFailureLabel.
  ///
  /// In bn, this message translates to:
  /// **'একটি নাম লিখুন (সর্বোচ্চ ৪০ অক্ষর)।'**
  String get relationshipsFailureLabel;

  /// No description provided for @relationshipsFailureTooMany.
  ///
  /// In bn, this message translates to:
  /// **'তালিকা পূর্ণ।'**
  String get relationshipsFailureTooMany;

  /// No description provided for @relationshipsFailureBuiltIn.
  ///
  /// In bn, this message translates to:
  /// **'তৈরি-করা সম্পর্ক পরিবর্তন করা যায় না।'**
  String get relationshipsFailureBuiltIn;

  /// No description provided for @activityFamilyCreated.
  ///
  /// In bn, this message translates to:
  /// **'পরিবার “{familyName}” তৈরি হয়েছে'**
  String activityFamilyCreated(String familyName);

  /// No description provided for @activityFamilyUpdated.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের সেটিংস হালনাগাদ হয়েছে'**
  String get activityFamilyUpdated;

  /// No description provided for @activityMemberRequested.
  ///
  /// In bn, this message translates to:
  /// **'{memberName} যোগ দিতে অনুরোধ করেছেন'**
  String activityMemberRequested(String memberName);

  /// No description provided for @activityMemberApproved.
  ///
  /// In bn, this message translates to:
  /// **'{memberName}-কে অনুমোদন দেওয়া হয়েছে'**
  String activityMemberApproved(String memberName);

  /// No description provided for @activityMemberRejected.
  ///
  /// In bn, this message translates to:
  /// **'{memberName}-কে গ্রহণ করা হয়নি'**
  String activityMemberRejected(String memberName);

  /// No description provided for @activityMemberDisabled.
  ///
  /// In bn, this message translates to:
  /// **'{memberName}-কে বন্ধ করা হয়েছে'**
  String activityMemberDisabled(String memberName);

  /// No description provided for @activityMemberRoleChanged.
  ///
  /// In bn, this message translates to:
  /// **'{memberName} এখন {newRole}'**
  String activityMemberRoleChanged(String memberName, String newRole);

  /// No description provided for @activityAdminTransferred.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাডমিনের দায়িত্ব {memberName}-কে দেওয়া হয়েছে'**
  String activityAdminTransferred(String memberName);

  /// No description provided for @activityMemberLeft.
  ///
  /// In bn, this message translates to:
  /// **'{memberName} পরিবার ছেড়ে গেছেন'**
  String activityMemberLeft(String memberName);

  /// No description provided for @activityMemberCancelled.
  ///
  /// In bn, this message translates to:
  /// **'{memberName} অনুরোধ প্রত্যাহার করেছেন'**
  String activityMemberCancelled(String memberName);

  /// No description provided for @activityInvitationCreated.
  ///
  /// In bn, this message translates to:
  /// **'আমন্ত্রণ {code} তৈরি হয়েছে'**
  String activityInvitationCreated(String code);

  /// No description provided for @activityInvitationRevoked.
  ///
  /// In bn, this message translates to:
  /// **'আমন্ত্রণ {code} বাতিল হয়েছে'**
  String activityInvitationRevoked(String code);

  /// No description provided for @activityBazarCatalogSeeded.
  ///
  /// In bn, this message translates to:
  /// **'{categories}টি ক্যাটাগরি ও {items}টি আইটেম দিয়ে বাজারের তালিকা চালু হয়েছে'**
  String activityBazarCatalogSeeded(String categories, String items);

  /// No description provided for @activityBazarCategoryCreated.
  ///
  /// In bn, this message translates to:
  /// **'ক্যাটাগরি “{name}” যোগ করা হয়েছে'**
  String activityBazarCategoryCreated(String name);

  /// No description provided for @activityBazarCategoryUpdated.
  ///
  /// In bn, this message translates to:
  /// **'ক্যাটাগরি “{name}” হালনাগাদ হয়েছে'**
  String activityBazarCategoryUpdated(String name);

  /// No description provided for @activityBazarCategoryDeactivated.
  ///
  /// In bn, this message translates to:
  /// **'ক্যাটাগরি “{name}” আর্কাইভ করা হয়েছে'**
  String activityBazarCategoryDeactivated(String name);

  /// No description provided for @activityBazarItemCreated.
  ///
  /// In bn, this message translates to:
  /// **'আইটেম “{name}” যোগ করা হয়েছে'**
  String activityBazarItemCreated(String name);

  /// No description provided for @activityBazarItemUpdated.
  ///
  /// In bn, this message translates to:
  /// **'আইটেম “{name}” হালনাগাদ হয়েছে'**
  String activityBazarItemUpdated(String name);

  /// No description provided for @activityBazarItemDeactivated.
  ///
  /// In bn, this message translates to:
  /// **'আইটেম “{name}” আর্কাইভ করা হয়েছে'**
  String activityBazarItemDeactivated(String name);

  /// No description provided for @activityBazarExpenseCreated.
  ///
  /// In bn, this message translates to:
  /// **'{item} কেনা হয়েছে {amount} দিয়ে ({funding})'**
  String activityBazarExpenseCreated(
    String item,
    String amount,
    String funding,
  );

  /// No description provided for @activityBazarExpenseUpdated.
  ///
  /// In bn, this message translates to:
  /// **'{item} সম্পাদনা করা হয়েছে ({fields})'**
  String activityBazarExpenseUpdated(String item, String fields);

  /// No description provided for @activityBazarExpenseDeleted.
  ///
  /// In bn, this message translates to:
  /// **'{item} মুছে ফেলা হয়েছে ({amount})'**
  String activityBazarExpenseDeleted(String item, String amount);

  /// No description provided for @activityBazarExpenseRestored.
  ///
  /// In bn, this message translates to:
  /// **'{item} ফিরিয়ে আনা হয়েছে ({amount})'**
  String activityBazarExpenseRestored(String item, String amount);

  /// No description provided for @activityBazarTripCreated.
  ///
  /// In bn, this message translates to:
  /// **'{lines}টি আইটেমের বাজার যাত্রা {amount} দিয়ে সংরক্ষণ হয়েছে'**
  String activityBazarTripCreated(String lines, String amount);

  /// No description provided for @activityBazarBudgetSaved.
  ///
  /// In bn, this message translates to:
  /// **'{month}-এর বাজেট {amount} নির্ধারণ করা হয়েছে'**
  String activityBazarBudgetSaved(String month, String amount);

  /// No description provided for @activityBazarSettingsUpdated.
  ///
  /// In bn, this message translates to:
  /// **'বাজারের সেটিংস হালনাগাদ হয়েছে'**
  String get activityBazarSettingsUpdated;

  /// No description provided for @activityBazarContributionPlanSet.
  ///
  /// In bn, this message translates to:
  /// **'{month}-এ {member}-এর চাঁদা {amount} নির্ধারণ করা হয়েছে'**
  String activityBazarContributionPlanSet(
    String month,
    String member,
    String amount,
  );

  /// No description provided for @activityBazarContributionRecorded.
  ///
  /// In bn, this message translates to:
  /// **'{month}-এ {member}-এর {amount} চাঁদা রেকর্ড করা হয়েছে'**
  String activityBazarContributionRecorded(
    String month,
    String member,
    String amount,
  );

  /// No description provided for @activityBazarContributionVoided.
  ///
  /// In bn, this message translates to:
  /// **'{month}-এ {member}-এর {amount} চাঁদা বাতিল করা হয়েছে'**
  String activityBazarContributionVoided(
    String month,
    String member,
    String amount,
  );

  /// No description provided for @activityBazarContributionRequested.
  ///
  /// In bn, this message translates to:
  /// **'{month}-এর জন্য {member} {amount} দিতে চেয়েছেন'**
  String activityBazarContributionRequested(
    String month,
    String member,
    String amount,
  );

  /// No description provided for @activityBazarContributionRequestEdited.
  ///
  /// In bn, this message translates to:
  /// **'{month}-এর জন্য {member} {amount} দেওয়ার অনুরোধ সম্পাদনা করেছেন'**
  String activityBazarContributionRequestEdited(
    String month,
    String member,
    String amount,
  );

  /// No description provided for @activityBazarContributionRequestCancelled.
  ///
  /// In bn, this message translates to:
  /// **'{month}-এর জন্য {member} {amount} দেওয়ার অনুরোধ প্রত্যাহার করেছেন'**
  String activityBazarContributionRequestCancelled(
    String month,
    String member,
    String amount,
  );

  /// No description provided for @activityBazarContributionApproved.
  ///
  /// In bn, this message translates to:
  /// **'{month}-এ {member}-এর {amount} চাঁদা অনুমোদিত হয়েছে'**
  String activityBazarContributionApproved(
    String month,
    String member,
    String amount,
  );

  /// No description provided for @activityBazarContributionRejected.
  ///
  /// In bn, this message translates to:
  /// **'{month}-এ {member}-এর {amount} চাঁদা গ্রহণ করা হয়নি ({reason})'**
  String activityBazarContributionRejected(
    String month,
    String member,
    String amount,
    String reason,
  );

  /// No description provided for @activityBazarContributionChangeRequested.
  ///
  /// In bn, this message translates to:
  /// **'{month}-এর জন্য {member} {old} থেকে {amount}-এ চাঁদা বদলাতে বলেছেন'**
  String activityBazarContributionChangeRequested(
    String month,
    String member,
    String amount,
    String old,
  );

  /// No description provided for @activityBazarContributionChangeApproved.
  ///
  /// In bn, this message translates to:
  /// **'{month}-এ {member}-এর চাঁদা {old} থেকে {amount}-এ বদলের অনুমোদন হয়েছে'**
  String activityBazarContributionChangeApproved(
    String month,
    String member,
    String amount,
    String old,
  );

  /// No description provided for @activityBazarContributionChangeRejected.
  ///
  /// In bn, this message translates to:
  /// **'{month}-এ {member}-এর চাঁদা {old} থেকে {amount}-এ বদলের অনুমোদন হয়নি'**
  String activityBazarContributionChangeRejected(
    String month,
    String member,
    String amount,
    String old,
  );

  /// No description provided for @activityBazarOpeningBalanceSet.
  ///
  /// In bn, this message translates to:
  /// **'{month}-এর প্রারম্ভিক ব্যালেন্স {amount}'**
  String activityBazarOpeningBalanceSet(String month, String amount);

  /// No description provided for @activityBazarAdvanceSettled.
  ///
  /// In bn, this message translates to:
  /// **'{member}-এর অগ্রিম {amount} সমন্বয় হয়েছে ({status})'**
  String activityBazarAdvanceSettled(
    String member,
    String amount,
    String status,
  );

  /// No description provided for @activityBazarMonthClosed.
  ///
  /// In bn, this message translates to:
  /// **'{month} বন্ধ করা হয়েছে, ব্যালেন্স {balance}'**
  String activityBazarMonthClosed(String month, String balance);

  /// No description provided for @activityBazarMonthReopened.
  ///
  /// In bn, this message translates to:
  /// **'{month} আবার খোলা হয়েছে ({note})'**
  String activityBazarMonthReopened(String month, String note);

  /// No description provided for @activityBazarImportCompleted.
  ///
  /// In bn, this message translates to:
  /// **'ইমপোর্ট শেষ: {rows}টি সারি, {amount}'**
  String activityBazarImportCompleted(String rows, String amount);

  /// No description provided for @activityBazarImportUndone.
  ///
  /// In bn, this message translates to:
  /// **'ইমপোর্ট বাতিল: {rows}টি সারি, {amount}'**
  String activityBazarImportUndone(String rows, String amount);

  /// No description provided for @activityUnknown.
  ///
  /// In bn, this message translates to:
  /// **'কিছু পরিবর্তন হয়েছে'**
  String get activityUnknown;

  /// No description provided for @galleryMonthSwitcher.
  ///
  /// In bn, this message translates to:
  /// **'মাস পরিবর্তনকারী'**
  String get galleryMonthSwitcher;

  /// No description provided for @galleryAmountField.
  ///
  /// In bn, this message translates to:
  /// **'পরিমাণের ঘর'**
  String get galleryAmountField;

  /// No description provided for @galleryTotalDisplay.
  ///
  /// In bn, this message translates to:
  /// **'মোট প্রদর্শন'**
  String get galleryTotalDisplay;

  /// No description provided for @galleryProgressBarStatus.
  ///
  /// In bn, this message translates to:
  /// **'সীমার অগ্রগতি বার'**
  String get galleryProgressBarStatus;

  /// No description provided for @galleryDaySectionHeader.
  ///
  /// In bn, this message translates to:
  /// **'দিনের শিরোনাম'**
  String get galleryDaySectionHeader;

  /// No description provided for @galleryPersonPicker.
  ///
  /// In bn, this message translates to:
  /// **'ব্যক্তি নির্বাচন'**
  String get galleryPersonPicker;

  /// No description provided for @galleryCategoryBadge.
  ///
  /// In bn, this message translates to:
  /// **'ক্যাটেগরি ব্যাজ'**
  String get galleryCategoryBadge;

  /// No description provided for @monthSwitcherPrevious.
  ///
  /// In bn, this message translates to:
  /// **'আগের মাস'**
  String get monthSwitcherPrevious;

  /// No description provided for @monthSwitcherNext.
  ///
  /// In bn, this message translates to:
  /// **'পরের মাস'**
  String get monthSwitcherNext;

  /// No description provided for @monthSwitcherPick.
  ///
  /// In bn, this message translates to:
  /// **'মাস বেছে নিন'**
  String get monthSwitcherPick;

  /// No description provided for @monthPickerPreviousYear.
  ///
  /// In bn, this message translates to:
  /// **'আগের বছর'**
  String get monthPickerPreviousYear;

  /// No description provided for @monthPickerNextYear.
  ///
  /// In bn, this message translates to:
  /// **'পরের বছর'**
  String get monthPickerNextYear;

  /// No description provided for @totalDisplayCalculated.
  ///
  /// In bn, this message translates to:
  /// **'পরিমাণ × দর থেকে হিসাব করা'**
  String get totalDisplayCalculated;

  /// No description provided for @totalDisplayEmpty.
  ///
  /// In bn, this message translates to:
  /// **'মোট এখনো নেই'**
  String get totalDisplayEmpty;

  /// No description provided for @progressLevelOk.
  ///
  /// In bn, this message translates to:
  /// **'ঠিক আছে'**
  String get progressLevelOk;

  /// No description provided for @progressLevelWarning.
  ///
  /// In bn, this message translates to:
  /// **'সীমার কাছাকাছি'**
  String get progressLevelWarning;

  /// No description provided for @progressLevelExceeded.
  ///
  /// In bn, this message translates to:
  /// **'সীমা ছাড়িয়েছে'**
  String get progressLevelExceeded;

  /// No description provided for @progressLevelNoLimit.
  ///
  /// In bn, this message translates to:
  /// **'সীমা নির্ধারিত নেই'**
  String get progressLevelNoLimit;

  /// No description provided for @progressBarSemantics.
  ///
  /// In bn, this message translates to:
  /// **'{label}: {percent} শতাংশ, {level}'**
  String progressBarSemantics(String label, String percent, String level);

  /// No description provided for @personPickerNone.
  ///
  /// In bn, this message translates to:
  /// **'কেউ নয়'**
  String get personPickerNone;

  /// No description provided for @actionUndo.
  ///
  /// In bn, this message translates to:
  /// **'পূর্বাবস্থায় ফেরান'**
  String get actionUndo;

  /// No description provided for @bazarErrExpenseDeleted.
  ///
  /// In bn, this message translates to:
  /// **'এই খরচটি মুছে ফেলা হয়েছে। আগে ফিরিয়ে আনুন।'**
  String get bazarErrExpenseDeleted;

  /// No description provided for @expenseAddTitle.
  ///
  /// In bn, this message translates to:
  /// **'খরচ যোগ করুন'**
  String get expenseAddTitle;

  /// No description provided for @expenseEditTitle.
  ///
  /// In bn, this message translates to:
  /// **'খরচ সম্পাদনা'**
  String get expenseEditTitle;

  /// No description provided for @expenseMenuTrip.
  ///
  /// In bn, this message translates to:
  /// **'বাজার ট্রিপ (অনেক পণ্য)'**
  String get expenseMenuTrip;

  /// No description provided for @expenseDateLabel.
  ///
  /// In bn, this message translates to:
  /// **'তারিখ'**
  String get expenseDateLabel;

  /// No description provided for @expenseItemLabel.
  ///
  /// In bn, this message translates to:
  /// **'পণ্য'**
  String get expenseItemLabel;

  /// No description provided for @expenseItemHint.
  ///
  /// In bn, this message translates to:
  /// **'পণ্যের নাম লিখুন'**
  String get expenseItemHint;

  /// No description provided for @expenseAddNewItem.
  ///
  /// In bn, this message translates to:
  /// **'{name} নতুন পণ্য হিসেবে যোগ করুন'**
  String expenseAddNewItem(String name);

  /// No description provided for @expenseCategoryLabel.
  ///
  /// In bn, this message translates to:
  /// **'ক্যাটেগরি'**
  String get expenseCategoryLabel;

  /// No description provided for @expenseRememberItem.
  ///
  /// In bn, this message translates to:
  /// **'পণ্যটি মনে রাখুন'**
  String get expenseRememberItem;

  /// No description provided for @expenseTotalField.
  ///
  /// In bn, this message translates to:
  /// **'মোট টাকা'**
  String get expenseTotalField;

  /// No description provided for @expenseTotalLabel.
  ///
  /// In bn, this message translates to:
  /// **'মোট'**
  String get expenseTotalLabel;

  /// No description provided for @expenseQtyPriceSection.
  ///
  /// In bn, this message translates to:
  /// **'অথবা পরিমাণ ও প্রতি এককের দাম লিখুন'**
  String get expenseQtyPriceSection;

  /// No description provided for @expenseQtyField.
  ///
  /// In bn, this message translates to:
  /// **'পরিমাণ'**
  String get expenseQtyField;

  /// No description provided for @expenseUnitLabel.
  ///
  /// In bn, this message translates to:
  /// **'একক'**
  String get expenseUnitLabel;

  /// No description provided for @expenseUnitPriceField.
  ///
  /// In bn, this message translates to:
  /// **'প্রতি এককের দাম'**
  String get expenseUnitPriceField;

  /// No description provided for @expenseUnitPriceHint.
  ///
  /// In bn, this message translates to:
  /// **'সর্বশেষ দাম: {price}'**
  String expenseUnitPriceHint(String price);

  /// No description provided for @expenseFundingLabel.
  ///
  /// In bn, this message translates to:
  /// **'কে টাকা দিয়েছে?'**
  String get expenseFundingLabel;

  /// No description provided for @expenseFundingFund.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের তহবিল থেকে'**
  String get expenseFundingFund;

  /// No description provided for @expenseFundingReimbursable.
  ///
  /// In bn, this message translates to:
  /// **'সদস্য দিয়েছে, ফেরত পাবে'**
  String get expenseFundingReimbursable;

  /// No description provided for @expenseFundingPersonal.
  ///
  /// In bn, this message translates to:
  /// **'সদস্য নিজের টাকায় দিয়েছে, ফেরত নয়'**
  String get expenseFundingPersonal;

  /// No description provided for @expensePaidByLabel.
  ///
  /// In bn, this message translates to:
  /// **'যিনি দিয়েছেন'**
  String get expensePaidByLabel;

  /// No description provided for @expenseMoreSection.
  ///
  /// In bn, this message translates to:
  /// **'আরও তথ্য'**
  String get expenseMoreSection;

  /// No description provided for @expenseShopField.
  ///
  /// In bn, this message translates to:
  /// **'দোকান'**
  String get expenseShopField;

  /// No description provided for @expenseNoteField.
  ///
  /// In bn, this message translates to:
  /// **'নোট'**
  String get expenseNoteField;

  /// No description provided for @expensePurchaserLabel.
  ///
  /// In bn, this message translates to:
  /// **'যিনি কিনেছেন'**
  String get expensePurchaserLabel;

  /// No description provided for @expenseSaveAddAnother.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষণ করে আরেকটি যোগ করুন'**
  String get expenseSaveAddAnother;

  /// No description provided for @expenseSaved.
  ///
  /// In bn, this message translates to:
  /// **'খরচ সংরক্ষণ হয়েছে'**
  String get expenseSaved;

  /// No description provided for @expenseUpdated.
  ///
  /// In bn, this message translates to:
  /// **'খরচ হালনাগাদ হয়েছে'**
  String get expenseUpdated;

  /// No description provided for @expenseUnknownMember.
  ///
  /// In bn, this message translates to:
  /// **'একজন সদস্য'**
  String get expenseUnknownMember;

  /// No description provided for @expenseDuplicateTitle.
  ///
  /// In bn, this message translates to:
  /// **'মনে হচ্ছে একই খরচ আগেই যোগ হয়েছে'**
  String get expenseDuplicateTitle;

  /// No description provided for @expenseDuplicateMessage.
  ///
  /// In bn, this message translates to:
  /// **'{item} একই টাকায় কয়েক মিনিট আগে যোগ করা হয়েছে।'**
  String expenseDuplicateMessage(String item);

  /// No description provided for @expenseDuplicateSaveAnyway.
  ///
  /// In bn, this message translates to:
  /// **'তবুও সংরক্ষণ করুন'**
  String get expenseDuplicateSaveAnyway;

  /// No description provided for @tripTitle.
  ///
  /// In bn, this message translates to:
  /// **'বাজার ট্রিপ'**
  String get tripTitle;

  /// No description provided for @tripAddLine.
  ///
  /// In bn, this message translates to:
  /// **'পণ্য যোগ করুন'**
  String get tripAddLine;

  /// No description provided for @tripLineSheetTitle.
  ///
  /// In bn, this message translates to:
  /// **'ট্রিপে পণ্য যোগ করুন'**
  String get tripLineSheetTitle;

  /// No description provided for @tripLineSheetSave.
  ///
  /// In bn, this message translates to:
  /// **'ট্রিপে যোগ করুন'**
  String get tripLineSheetSave;

  /// No description provided for @tripLinesCount.
  ///
  /// In bn, this message translates to:
  /// **'পণ্য: {count}'**
  String tripLinesCount(String count);

  /// No description provided for @tripEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো পণ্য নেই। প্রথম পণ্যটি যোগ করুন।'**
  String get tripEmpty;

  /// No description provided for @tripTotalLabel.
  ///
  /// In bn, this message translates to:
  /// **'ট্রিপের মোট'**
  String get tripTotalLabel;

  /// No description provided for @tripSaveAll.
  ///
  /// In bn, this message translates to:
  /// **'সব সংরক্ষণ করুন'**
  String get tripSaveAll;

  /// No description provided for @tripSaved.
  ///
  /// In bn, this message translates to:
  /// **'ট্রিপ সংরক্ষণ হয়েছে'**
  String get tripSaved;

  /// No description provided for @tripLineRemoved.
  ///
  /// In bn, this message translates to:
  /// **'পণ্য সরানো হয়েছে'**
  String get tripLineRemoved;

  /// No description provided for @tripLimitReached.
  ///
  /// In bn, this message translates to:
  /// **'একটি ট্রিপে সর্বোচ্চ ৪০টি পণ্য থাকতে পারে।'**
  String get tripLimitReached;

  /// No description provided for @expenseListTitle.
  ///
  /// In bn, this message translates to:
  /// **'খরচের তালিকা'**
  String get expenseListTitle;

  /// No description provided for @expenseListFilteredTotal.
  ///
  /// In bn, this message translates to:
  /// **'এই তালিকার মোট'**
  String get expenseListFilteredTotal;

  /// No description provided for @expenseListEmptyTitle.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসে কোনো খরচ নেই'**
  String get expenseListEmptyTitle;

  /// No description provided for @expenseListEmptyMessage.
  ///
  /// In bn, this message translates to:
  /// **'প্রথম খরচ যোগ করলে এখানে দেখা যাবে।'**
  String get expenseListEmptyMessage;

  /// No description provided for @expenseListFilteredEmptyTitle.
  ///
  /// In bn, this message translates to:
  /// **'ফিল্টারের সাথে মেলে এমন কিছু নেই'**
  String get expenseListFilteredEmptyTitle;

  /// No description provided for @expenseListFilteredEmptyMessage.
  ///
  /// In bn, this message translates to:
  /// **'সব খরচ দেখতে ফিল্টার মুছে ফেলুন।'**
  String get expenseListFilteredEmptyMessage;

  /// No description provided for @expenseListLocked.
  ///
  /// In bn, this message translates to:
  /// **'এই মাস বন্ধ। এন্ট্রি শুধু দেখা যাবে।'**
  String get expenseListLocked;

  /// No description provided for @expenseListRefresh.
  ///
  /// In bn, this message translates to:
  /// **'রিফ্রেশ'**
  String get expenseListRefresh;

  /// No description provided for @expenseShowMore.
  ///
  /// In bn, this message translates to:
  /// **'আরও দেখান'**
  String get expenseShowMore;

  /// No description provided for @expenseRowDeleted.
  ///
  /// In bn, this message translates to:
  /// **'মুছে ফেলা'**
  String get expenseRowDeleted;

  /// No description provided for @expenseRowTrip.
  ///
  /// In bn, this message translates to:
  /// **'ট্রিপ'**
  String get expenseRowTrip;

  /// No description provided for @expenseFilterTitle.
  ///
  /// In bn, this message translates to:
  /// **'ফিল্টার'**
  String get expenseFilterTitle;

  /// No description provided for @expenseFilterRange.
  ///
  /// In bn, this message translates to:
  /// **'তারিখের সীমা'**
  String get expenseFilterRange;

  /// No description provided for @expenseFilterRangeActive.
  ///
  /// In bn, this message translates to:
  /// **'{start} থেকে {end}'**
  String expenseFilterRangeActive(String start, String end);

  /// No description provided for @expenseRangeAll.
  ///
  /// In bn, this message translates to:
  /// **'পুরো মাস'**
  String get expenseRangeAll;

  /// No description provided for @expenseRangeToday.
  ///
  /// In bn, this message translates to:
  /// **'আজ'**
  String get expenseRangeToday;

  /// No description provided for @expenseRangeYesterday.
  ///
  /// In bn, this message translates to:
  /// **'গতকাল'**
  String get expenseRangeYesterday;

  /// No description provided for @expenseRangeLast7.
  ///
  /// In bn, this message translates to:
  /// **'গত ৭ দিন'**
  String get expenseRangeLast7;

  /// No description provided for @expenseRangeThisWeek.
  ///
  /// In bn, this message translates to:
  /// **'এই সপ্তাহ'**
  String get expenseRangeThisWeek;

  /// No description provided for @expenseRangeThisMonth.
  ///
  /// In bn, this message translates to:
  /// **'এই মাস'**
  String get expenseRangeThisMonth;

  /// No description provided for @expenseRangeLastMonth.
  ///
  /// In bn, this message translates to:
  /// **'গত মাস'**
  String get expenseRangeLastMonth;

  /// No description provided for @expenseRangeThisYear.
  ///
  /// In bn, this message translates to:
  /// **'এই বছর'**
  String get expenseRangeThisYear;

  /// No description provided for @expenseRangeCustom.
  ///
  /// In bn, this message translates to:
  /// **'তারিখ বেছে নিন'**
  String get expenseRangeCustom;

  /// No description provided for @expenseFilterCategory.
  ///
  /// In bn, this message translates to:
  /// **'ক্যাটেগরি'**
  String get expenseFilterCategory;

  /// No description provided for @expenseFilterItem.
  ///
  /// In bn, this message translates to:
  /// **'পণ্য'**
  String get expenseFilterItem;

  /// No description provided for @expenseFilterMember.
  ///
  /// In bn, this message translates to:
  /// **'সদস্য'**
  String get expenseFilterMember;

  /// No description provided for @expenseFilterFunding.
  ///
  /// In bn, this message translates to:
  /// **'টাকার উৎস'**
  String get expenseFilterFunding;

  /// No description provided for @expenseFilterAny.
  ///
  /// In bn, this message translates to:
  /// **'যেকোনো'**
  String get expenseFilterAny;

  /// No description provided for @expenseFilterShowDeleted.
  ///
  /// In bn, this message translates to:
  /// **'মুছে ফেলা দেখান'**
  String get expenseFilterShowDeleted;

  /// No description provided for @expenseFilterReset.
  ///
  /// In bn, this message translates to:
  /// **'ফিল্টার মুছুন'**
  String get expenseFilterReset;

  /// No description provided for @expenseDetailTitle.
  ///
  /// In bn, this message translates to:
  /// **'খরচ'**
  String get expenseDetailTitle;

  /// No description provided for @expenseDetailAddedBy.
  ///
  /// In bn, this message translates to:
  /// **'যোগ করেছেন'**
  String get expenseDetailAddedBy;

  /// No description provided for @expenseDetailPayment.
  ///
  /// In bn, this message translates to:
  /// **'টাকার উৎস ও হিসাব'**
  String get expenseDetailPayment;

  /// No description provided for @expenseNotYoursMessage.
  ///
  /// In bn, this message translates to:
  /// **'আপনি শুধু নিজের খরচ পরিবর্তন করতে পারবেন।'**
  String get expenseNotYoursMessage;

  /// No description provided for @expenseLedgerFund.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের তহবিল থেকে দেওয়া হয়েছে'**
  String get expenseLedgerFund;

  /// No description provided for @expenseLedgerPersonal.
  ///
  /// In bn, this message translates to:
  /// **'{name} নিজের টাকায় দিয়েছেন, ফেরত নেই'**
  String expenseLedgerPersonal(String name);

  /// No description provided for @expenseLedgerPending.
  ///
  /// In bn, this message translates to:
  /// **'{name} দিয়েছেন। {amount} ফেরত দেওয়া বাকি।'**
  String expenseLedgerPending(String name, String amount);

  /// No description provided for @expenseLedgerPartial.
  ///
  /// In bn, this message translates to:
  /// **'{name} দিয়েছেন। {total} এর মধ্যে {settled} ফেরত দেওয়া হয়েছে।'**
  String expenseLedgerPartial(String name, String settled, String total);

  /// No description provided for @expenseLedgerSettled.
  ///
  /// In bn, this message translates to:
  /// **'{name} দিয়েছেন। পুরোটা ফেরত দেওয়া হয়েছে।'**
  String expenseLedgerSettled(String name);

  /// No description provided for @expenseLedgerVoided.
  ///
  /// In bn, this message translates to:
  /// **'খরচের সাথে ফেরতও বাতিল হয়েছে।'**
  String get expenseLedgerVoided;

  /// No description provided for @expenseDeleteTitle.
  ///
  /// In bn, this message translates to:
  /// **'এই খরচ মুছে ফেলবেন?'**
  String get expenseDeleteTitle;

  /// No description provided for @expenseDeleteMessage.
  ///
  /// In bn, this message translates to:
  /// **'{name} মোট থেকে বাদ যাবে। সাথে সাথে পূর্বাবস্থায় ফেরাতে পারবেন।'**
  String expenseDeleteMessage(String name);

  /// No description provided for @expenseDeleted.
  ///
  /// In bn, this message translates to:
  /// **'খরচ মুছে ফেলা হয়েছে'**
  String get expenseDeleted;

  /// No description provided for @expenseRestore.
  ///
  /// In bn, this message translates to:
  /// **'ফিরিয়ে আনুন'**
  String get expenseRestore;

  /// No description provided for @expenseRestored.
  ///
  /// In bn, this message translates to:
  /// **'খরচ ফিরিয়ে আনা হয়েছে'**
  String get expenseRestored;

  /// No description provided for @expenseHistoryTitle.
  ///
  /// In bn, this message translates to:
  /// **'পরিবর্তনের ইতিহাস'**
  String get expenseHistoryTitle;

  /// No description provided for @expenseHistoryEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো পরিবর্তন নেই।'**
  String get expenseHistoryEmpty;

  /// No description provided for @expenseHistoryEntry.
  ///
  /// In bn, this message translates to:
  /// **'{who} {date} তারিখে পরিবর্তন করেছেন'**
  String expenseHistoryEntry(String who, String date);

  /// No description provided for @expenseHistoryWas.
  ///
  /// In bn, this message translates to:
  /// **'{field} আগে ছিল: {value}'**
  String expenseHistoryWas(String field, String value);

  /// No description provided for @catalogTitle.
  ///
  /// In bn, this message translates to:
  /// **'পণ্য ও ক্যাটেগরি'**
  String get catalogTitle;

  /// No description provided for @catalogTabCategories.
  ///
  /// In bn, this message translates to:
  /// **'ক্যাটেগরি'**
  String get catalogTabCategories;

  /// No description provided for @catalogTabItems.
  ///
  /// In bn, this message translates to:
  /// **'পণ্য'**
  String get catalogTabItems;

  /// No description provided for @catalogAdd.
  ///
  /// In bn, this message translates to:
  /// **'যোগ করুন'**
  String get catalogAdd;

  /// No description provided for @catalogAddCategory.
  ///
  /// In bn, this message translates to:
  /// **'ক্যাটেগরি যোগ করুন'**
  String get catalogAddCategory;

  /// No description provided for @catalogEditCategory.
  ///
  /// In bn, this message translates to:
  /// **'ক্যাটেগরি সম্পাদনা'**
  String get catalogEditCategory;

  /// No description provided for @catalogAddItem.
  ///
  /// In bn, this message translates to:
  /// **'পণ্য যোগ করুন'**
  String get catalogAddItem;

  /// No description provided for @catalogEditItem.
  ///
  /// In bn, this message translates to:
  /// **'পণ্য সম্পাদনা'**
  String get catalogEditItem;

  /// No description provided for @catalogCategoryName.
  ///
  /// In bn, this message translates to:
  /// **'ক্যাটেগরির নাম'**
  String get catalogCategoryName;

  /// No description provided for @catalogNameBn.
  ///
  /// In bn, this message translates to:
  /// **'বাংলা নাম'**
  String get catalogNameBn;

  /// No description provided for @catalogNameEn.
  ///
  /// In bn, this message translates to:
  /// **'ইংরেজি নাম (ঐচ্ছিক)'**
  String get catalogNameEn;

  /// No description provided for @catalogEmoji.
  ///
  /// In bn, this message translates to:
  /// **'ইমোজি (ঐচ্ছিক)'**
  String get catalogEmoji;

  /// No description provided for @catalogColour.
  ///
  /// In bn, this message translates to:
  /// **'রং'**
  String get catalogColour;

  /// No description provided for @catalogColourSemantics.
  ///
  /// In bn, this message translates to:
  /// **'রং {number}'**
  String catalogColourSemantics(int number);

  /// No description provided for @catalogActive.
  ///
  /// In bn, this message translates to:
  /// **'তালিকায় দেখানো হবে'**
  String get catalogActive;

  /// No description provided for @catalogActiveHint.
  ///
  /// In bn, this message translates to:
  /// **'মুছে না ফেলে লুকাতে বন্ধ করুন।'**
  String get catalogActiveHint;

  /// No description provided for @catalogHidden.
  ///
  /// In bn, this message translates to:
  /// **'লুকানো'**
  String get catalogHidden;

  /// No description provided for @catalogReorder.
  ///
  /// In bn, this message translates to:
  /// **'সাজাতে টেনে আনুন'**
  String get catalogReorder;

  /// No description provided for @catalogReadOnly.
  ///
  /// In bn, this message translates to:
  /// **'আপনি এটি দেখতে পারবেন, কিন্তু শুধু সংসার ব্যবস্থাপক বা অ্যাডমিন পরিবর্তন করতে পারবেন।'**
  String get catalogReadOnly;

  /// No description provided for @catalogCategoriesEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো ক্যাটেগরি নেই'**
  String get catalogCategoriesEmpty;

  /// No description provided for @catalogItemsEmpty.
  ///
  /// In bn, this message translates to:
  /// **'কোনো পণ্য পাওয়া যায়নি'**
  String get catalogItemsEmpty;

  /// No description provided for @catalogSearch.
  ///
  /// In bn, this message translates to:
  /// **'পণ্য খুঁজুন'**
  String get catalogSearch;

  /// No description provided for @catalogAllCategories.
  ///
  /// In bn, this message translates to:
  /// **'সব'**
  String get catalogAllCategories;

  /// No description provided for @catalogDefaultUnit.
  ///
  /// In bn, this message translates to:
  /// **'সাধারণ একক'**
  String get catalogDefaultUnit;

  /// No description provided for @catalogAliases.
  ///
  /// In bn, this message translates to:
  /// **'অন্য বানান (খোঁজার জন্য)'**
  String get catalogAliases;

  /// No description provided for @catalogAliasField.
  ///
  /// In bn, this message translates to:
  /// **'একটি বানান যোগ করুন'**
  String get catalogAliasField;

  /// No description provided for @catalogAliasAdd.
  ///
  /// In bn, this message translates to:
  /// **'বানান যোগ করুন'**
  String get catalogAliasAdd;

  /// No description provided for @catalogAliasLimit.
  ///
  /// In bn, this message translates to:
  /// **'সর্বোচ্চ ১০টি বানান দেওয়া যাবে।'**
  String get catalogAliasLimit;

  /// No description provided for @bazarSettingsWeekStart.
  ///
  /// In bn, this message translates to:
  /// **'সপ্তাহ শুরু'**
  String get bazarSettingsWeekStart;

  /// No description provided for @bazarSettingsTarget.
  ///
  /// In bn, this message translates to:
  /// **'মাসিক পারিবারিক চাঁদার লক্ষ্য'**
  String get bazarSettingsTarget;

  /// No description provided for @bazarSettingsDueDay.
  ///
  /// In bn, this message translates to:
  /// **'চাঁদা দেওয়ার তারিখ (প্রতি মাসে)'**
  String get bazarSettingsDueDay;

  /// No description provided for @bazarSettingsAlerts.
  ///
  /// In bn, this message translates to:
  /// **'বাজেট সতর্কতা (বাজেটের শতাংশ)'**
  String get bazarSettingsAlerts;

  /// No description provided for @bazarSettingsWarnAt.
  ///
  /// In bn, this message translates to:
  /// **'সতর্ক করুন'**
  String get bazarSettingsWarnAt;

  /// No description provided for @bazarSettingsExceededAt.
  ///
  /// In bn, this message translates to:
  /// **'সীমা ছাড়ালে'**
  String get bazarSettingsExceededAt;

  /// No description provided for @bazarSettingsThresholdRange.
  ///
  /// In bn, this message translates to:
  /// **'১ থেকে ২০০ এর মধ্যে পূর্ণ সংখ্যা দিন।'**
  String get bazarSettingsThresholdRange;

  /// No description provided for @bazarSettingsThresholdOrder.
  ///
  /// In bn, this message translates to:
  /// **'সতর্কতার শতাংশ সীমা ছাড়ানোর শতাংশের চেয়ে কম হতে হবে।'**
  String get bazarSettingsThresholdOrder;

  /// No description provided for @bazarSettingsFundStart.
  ///
  /// In bn, this message translates to:
  /// **'তহবিল শুরুর মাস'**
  String get bazarSettingsFundStart;

  /// No description provided for @bazarSettingsFundStartUnset.
  ///
  /// In bn, this message translates to:
  /// **'শুরুর জমা (ওপেনিং ব্যালান্স) লিখলে নিজে থেকে ঠিক হবে।'**
  String get bazarSettingsFundStartUnset;

  /// No description provided for @budgetTitle.
  ///
  /// In bn, this message translates to:
  /// **'বাজেট'**
  String get budgetTitle;

  /// No description provided for @budgetNote.
  ///
  /// In bn, this message translates to:
  /// **'বাজেট একটি পরিকল্পনা; তহবিলের ব্যালান্সই আসল টাকা।'**
  String get budgetNote;

  /// No description provided for @budgetEmptyTitle.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসের কোনো বাজেট নেই'**
  String get budgetEmptyTitle;

  /// No description provided for @budgetEmptyMessage.
  ///
  /// In bn, this message translates to:
  /// **'মাসের পরিকল্পনা করলে খরচের সঙ্গে তুলনা দেখতে পাবেন।'**
  String get budgetEmptyMessage;

  /// No description provided for @budgetEmptyReadOnly.
  ///
  /// In bn, this message translates to:
  /// **'সংসার ব্যবস্থাপক বা অ্যাডমিন এখনো এই মাসের পরিকল্পনা করেননি।'**
  String get budgetEmptyReadOnly;

  /// No description provided for @budgetPlanThisMonth.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসের পরিকল্পনা করুন'**
  String get budgetPlanThisMonth;

  /// No description provided for @budgetCopyLast.
  ///
  /// In bn, this message translates to:
  /// **'গত মাসের বাজেট কপি করুন'**
  String get budgetCopyLast;

  /// No description provided for @budgetEdit.
  ///
  /// In bn, this message translates to:
  /// **'বাজেট সম্পাদনা'**
  String get budgetEdit;

  /// No description provided for @budgetOverall.
  ///
  /// In bn, this message translates to:
  /// **'পুরো মাস'**
  String get budgetOverall;

  /// No description provided for @budgetLeft.
  ///
  /// In bn, this message translates to:
  /// **'{amount} বাকি'**
  String budgetLeft(String amount);

  /// No description provided for @budgetOver.
  ///
  /// In bn, this message translates to:
  /// **'{amount} বেশি'**
  String budgetOver(String amount);

  /// No description provided for @budgetByCategory.
  ///
  /// In bn, this message translates to:
  /// **'ক্যাটাগরি অনুযায়ী'**
  String get budgetByCategory;

  /// No description provided for @budgetDryTitle.
  ///
  /// In bn, this message translates to:
  /// **'শুকনা বাজারের আনুমানিক হিসাব'**
  String get budgetDryTitle;

  /// No description provided for @budgetDrySummary.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি আইটেম, {total}'**
  String budgetDrySummary(String count, String total);

  /// No description provided for @budgetDryEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো আইটেম নেই।'**
  String get budgetDryEmpty;

  /// No description provided for @budgetTotalField.
  ///
  /// In bn, this message translates to:
  /// **'মোট বাজেট (খালি রাখলে যোগফল ধরা হবে)'**
  String get budgetTotalField;

  /// No description provided for @budgetDryFromLines.
  ///
  /// In bn, this message translates to:
  /// **'নিচের আইটেমগুলোর যোগফল'**
  String get budgetDryFromLines;

  /// No description provided for @budgetCategoryEstimates.
  ///
  /// In bn, this message translates to:
  /// **'ক্যাটাগরি অনুযায়ী আনুমানিক হিসাব'**
  String get budgetCategoryEstimates;

  /// No description provided for @budgetLineName.
  ///
  /// In bn, this message translates to:
  /// **'আইটেম'**
  String get budgetLineName;

  /// No description provided for @budgetLineStock.
  ///
  /// In bn, this message translates to:
  /// **'মজুদ'**
  String get budgetLineStock;

  /// No description provided for @budgetLineRate.
  ///
  /// In bn, this message translates to:
  /// **'দর'**
  String get budgetLineRate;

  /// No description provided for @budgetLineTotal.
  ///
  /// In bn, this message translates to:
  /// **'মোট'**
  String get budgetLineTotal;

  /// No description provided for @budgetAddLine.
  ///
  /// In bn, this message translates to:
  /// **'আইটেম যোগ করুন'**
  String get budgetAddLine;

  /// No description provided for @budgetRemoveLine.
  ///
  /// In bn, this message translates to:
  /// **'আইটেম সরান'**
  String get budgetRemoveLine;

  /// No description provided for @budgetLinesSum.
  ///
  /// In bn, this message translates to:
  /// **'আইটেমের মোট'**
  String get budgetLinesSum;

  /// No description provided for @budgetSaved.
  ///
  /// In bn, this message translates to:
  /// **'বাজেট সংরক্ষিত হয়েছে'**
  String get budgetSaved;

  /// No description provided for @budgetErrExists.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসের বাজেট আগেই আছে।'**
  String get budgetErrExists;

  /// No description provided for @budgetNoLastMonth.
  ///
  /// In bn, this message translates to:
  /// **'কপি করার মতো গত মাসের বাজেট নেই।'**
  String get budgetNoLastMonth;

  /// No description provided for @budgetReadOnly.
  ///
  /// In bn, this message translates to:
  /// **'আপনি বাজেট দেখতে পারবেন, কিন্তু শুধু সংসার ব্যবস্থাপক বা অ্যাডমিন বদলাতে পারবেন।'**
  String get budgetReadOnly;

  /// No description provided for @budgetAlertsTitle.
  ///
  /// In bn, this message translates to:
  /// **'বাজেট সতর্কতা'**
  String get budgetAlertsTitle;

  /// No description provided for @fundTitle.
  ///
  /// In bn, this message translates to:
  /// **'পারিবারিক ফান্ড'**
  String get fundTitle;

  /// No description provided for @fundBalanceTitle.
  ///
  /// In bn, this message translates to:
  /// **'ফান্ডের ব্যালেন্স'**
  String get fundBalanceTitle;

  /// No description provided for @fundReceived.
  ///
  /// In bn, this message translates to:
  /// **'জমা'**
  String get fundReceived;

  /// No description provided for @fundSpent.
  ///
  /// In bn, this message translates to:
  /// **'খরচ'**
  String get fundSpent;

  /// No description provided for @fundReimbursed.
  ///
  /// In bn, this message translates to:
  /// **'ফেরত দেওয়া'**
  String get fundReimbursed;

  /// No description provided for @fundClosedOn.
  ///
  /// In bn, this message translates to:
  /// **'{date} তারিখে বন্ধ হয়েছে'**
  String fundClosedOn(String date);

  /// No description provided for @fundMonthClosedNotice.
  ///
  /// In bn, this message translates to:
  /// **'এই মাস বন্ধ, তাই এতে নতুন কিছু যোগ করা যাবে না।'**
  String get fundMonthClosedNotice;

  /// No description provided for @fundOverflowWarning.
  ///
  /// In bn, this message translates to:
  /// **'ফান্ডের তালিকা অনেক বড়; ব্যালেন্স ঠিক রাখতে পুরোনো মাসগুলো বন্ধ করুন।'**
  String get fundOverflowWarning;

  /// No description provided for @fundDriftWarning.
  ///
  /// In bn, this message translates to:
  /// **'একটি বন্ধ মাস খাতার সাথে মিলছে না। সেটি আবার খুলে, ঠিক করে আবার বন্ধ করুন।'**
  String get fundDriftWarning;

  /// No description provided for @fundLedgerIssues.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি খরচের সাথে ফান্ডের এন্ট্রি মিলছে না।'**
  String fundLedgerIssues(int count);

  /// No description provided for @fundMembersTitle.
  ///
  /// In bn, this message translates to:
  /// **'সদস্যদের জমা'**
  String get fundMembersTitle;

  /// No description provided for @fundNoMembers.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো সক্রিয় সদস্য নেই।'**
  String get fundNoMembers;

  /// No description provided for @fundNoPlan.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসের কোনো পরিকল্পনা নেই'**
  String get fundNoPlan;

  /// No description provided for @fundPaidUp.
  ///
  /// In bn, this message translates to:
  /// **'সম্পূর্ণ জমা হয়েছে'**
  String get fundPaidUp;

  /// No description provided for @fundRemainingAmount.
  ///
  /// In bn, this message translates to:
  /// **'{amount} বাকি'**
  String fundRemainingAmount(String amount);

  /// No description provided for @fundCredit.
  ///
  /// In bn, this message translates to:
  /// **'{amount} বেশি'**
  String fundCredit(String amount);

  /// No description provided for @fundAwaitingApproval.
  ///
  /// In bn, this message translates to:
  /// **'{amount} অনুমোদনের অপেক্ষায়'**
  String fundAwaitingApproval(String amount);

  /// No description provided for @fundHistoryTitle.
  ///
  /// In bn, this message translates to:
  /// **'ফান্ডের হিসাব'**
  String get fundHistoryTitle;

  /// No description provided for @fundHistoryEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসে ফান্ডে এখনো কিছু নেই।'**
  String get fundHistoryEmpty;

  /// No description provided for @fundTxContribution.
  ///
  /// In bn, this message translates to:
  /// **'জমা'**
  String get fundTxContribution;

  /// No description provided for @fundTxExpense.
  ///
  /// In bn, this message translates to:
  /// **'খরচ'**
  String get fundTxExpense;

  /// No description provided for @fundTxReimbursement.
  ///
  /// In bn, this message translates to:
  /// **'ফেরত দেওয়া'**
  String get fundTxReimbursement;

  /// No description provided for @fundTxOpening.
  ///
  /// In bn, this message translates to:
  /// **'প্রারম্ভিক ব্যালেন্স'**
  String get fundTxOpening;

  /// No description provided for @fundTxAdjustment.
  ///
  /// In bn, this message translates to:
  /// **'সংশোধন'**
  String get fundTxAdjustment;

  /// No description provided for @fundSetupTitle.
  ///
  /// In bn, this message translates to:
  /// **'ফান্ড শুরু করুন'**
  String get fundSetupTitle;

  /// No description provided for @fundSetupMessage.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের কাছে এখন যে টাকা আছে লিখে ফান্ড ও তার প্রথম মাস শুরু করুন।'**
  String get fundSetupMessage;

  /// No description provided for @fundOpeningBalance.
  ///
  /// In bn, this message translates to:
  /// **'প্রারম্ভিক ব্যালেন্স'**
  String get fundOpeningBalance;

  /// No description provided for @fundSaveOpening.
  ///
  /// In bn, this message translates to:
  /// **'প্রারম্ভিক ব্যালেন্স সংরক্ষণ'**
  String get fundSaveOpening;

  /// No description provided for @fundAddContribution.
  ///
  /// In bn, this message translates to:
  /// **'জমা যোগ করুন'**
  String get fundAddContribution;

  /// No description provided for @fundRequestContribution.
  ///
  /// In bn, this message translates to:
  /// **'জমার অনুরোধ করুন'**
  String get fundRequestContribution;

  /// No description provided for @fundSaveContribution.
  ///
  /// In bn, this message translates to:
  /// **'জমা সংরক্ষণ'**
  String get fundSaveContribution;

  /// No description provided for @fundSendRequest.
  ///
  /// In bn, this message translates to:
  /// **'অনুরোধ পাঠান'**
  String get fundSendRequest;

  /// No description provided for @fundSendChangeRequest.
  ///
  /// In bn, this message translates to:
  /// **'পরিবর্তনের অনুরোধ পাঠান'**
  String get fundSendChangeRequest;

  /// No description provided for @fundEditRequest.
  ///
  /// In bn, this message translates to:
  /// **'অনুরোধ সম্পাদনা'**
  String get fundEditRequest;

  /// No description provided for @fundRequestChange.
  ///
  /// In bn, this message translates to:
  /// **'পরিবর্তনের অনুরোধ'**
  String get fundRequestChange;

  /// No description provided for @fundContributionLocked.
  ///
  /// In bn, this message translates to:
  /// **'মাস বন্ধ'**
  String get fundContributionLocked;

  /// No description provided for @fundMemberLabel.
  ///
  /// In bn, this message translates to:
  /// **'কে দিয়েছেন'**
  String get fundMemberLabel;

  /// No description provided for @fundAmountLabel.
  ///
  /// In bn, this message translates to:
  /// **'টাকার পরিমাণ'**
  String get fundAmountLabel;

  /// No description provided for @fundMethodLabel.
  ///
  /// In bn, this message translates to:
  /// **'কীভাবে দেওয়া হয়েছে'**
  String get fundMethodLabel;

  /// No description provided for @fundMethodCash.
  ///
  /// In bn, this message translates to:
  /// **'নগদ'**
  String get fundMethodCash;

  /// No description provided for @fundMethodBkash.
  ///
  /// In bn, this message translates to:
  /// **'বিকাশ'**
  String get fundMethodBkash;

  /// No description provided for @fundMethodNagad.
  ///
  /// In bn, this message translates to:
  /// **'নগদ (Nagad)'**
  String get fundMethodNagad;

  /// No description provided for @fundMethodBank.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাংক'**
  String get fundMethodBank;

  /// No description provided for @fundMethodOther.
  ///
  /// In bn, this message translates to:
  /// **'অন্য'**
  String get fundMethodOther;

  /// No description provided for @fundPendingTitle.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদনের অপেক্ষায়'**
  String get fundPendingTitle;

  /// No description provided for @bazarDashboardPendingApprovals.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি জমার অনুরোধ অনুমোদনের অপেক্ষায়'**
  String bazarDashboardPendingApprovals(String count);

  /// No description provided for @fundPendingEmpty.
  ///
  /// In bn, this message translates to:
  /// **'কোনো অনুরোধ অপেক্ষায় নেই।'**
  String get fundPendingEmpty;

  /// No description provided for @fundApprove.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদন'**
  String get fundApprove;

  /// No description provided for @fundReject.
  ///
  /// In bn, this message translates to:
  /// **'প্রত্যাখ্যান'**
  String get fundReject;

  /// No description provided for @fundRejectReasonTitle.
  ///
  /// In bn, this message translates to:
  /// **'কেন প্রত্যাখ্যান করছেন?'**
  String get fundRejectReasonTitle;

  /// No description provided for @fundRejectReasonHint.
  ///
  /// In bn, this message translates to:
  /// **'সদস্য এই কারণটি দেখতে পাবেন।'**
  String get fundRejectReasonHint;

  /// No description provided for @fundRejectedReason.
  ///
  /// In bn, this message translates to:
  /// **'প্রত্যাখ্যাত: {reason}'**
  String fundRejectedReason(String reason);

  /// No description provided for @fundVoid.
  ///
  /// In bn, this message translates to:
  /// **'বাতিল'**
  String get fundVoid;

  /// No description provided for @fundGeneratePlan.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসের পরিকল্পনা তৈরি করুন'**
  String get fundGeneratePlan;

  /// No description provided for @fundStatusPending.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদনের অপেক্ষায়'**
  String get fundStatusPending;

  /// No description provided for @fundStatusApproved.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদিত'**
  String get fundStatusApproved;

  /// No description provided for @fundStatusRejected.
  ///
  /// In bn, this message translates to:
  /// **'প্রত্যাখ্যাত'**
  String get fundStatusRejected;

  /// No description provided for @fundStatusVoided.
  ///
  /// In bn, this message translates to:
  /// **'বাতিল করা'**
  String get fundStatusVoided;

  /// No description provided for @advanceTitle.
  ///
  /// In bn, this message translates to:
  /// **'অগ্রিম ফেরত'**
  String get advanceTitle;

  /// No description provided for @advanceOwedTo.
  ///
  /// In bn, this message translates to:
  /// **'{name}-কে দিতে হবে'**
  String advanceOwedTo(String name);

  /// No description provided for @advancePaidTo.
  ///
  /// In bn, this message translates to:
  /// **'{name}-কে দেওয়া হয়েছে'**
  String advancePaidTo(String name);

  /// No description provided for @advanceOpenCount.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি অগ্রিম বাকি'**
  String advanceOpenCount(int count);

  /// No description provided for @advanceTotalOwed.
  ///
  /// In bn, this message translates to:
  /// **'মোট বাকি'**
  String get advanceTotalOwed;

  /// No description provided for @advanceShowSettled.
  ///
  /// In bn, this message translates to:
  /// **'পরিশোধিত দেখান'**
  String get advanceShowSettled;

  /// No description provided for @advanceEmptyTitle.
  ///
  /// In bn, this message translates to:
  /// **'ফেরত দেওয়ার কিছু নেই'**
  String get advanceEmptyTitle;

  /// No description provided for @advanceEmptyMessage.
  ///
  /// In bn, this message translates to:
  /// **'কোনো সদস্য নিজের টাকায় পরিবারের জন্য খরচ করলে, ফেরত দেওয়ার আগ পর্যন্ত তা এখানে দেখা যাবে।'**
  String get advanceEmptyMessage;

  /// No description provided for @advanceSettledOf.
  ///
  /// In bn, this message translates to:
  /// **'ফেরত দেওয়া'**
  String get advanceSettledOf;

  /// No description provided for @advanceRemaining.
  ///
  /// In bn, this message translates to:
  /// **'বাকি'**
  String get advanceRemaining;

  /// No description provided for @advanceSettleTitle.
  ///
  /// In bn, this message translates to:
  /// **'ফেরত দিন'**
  String get advanceSettleTitle;

  /// No description provided for @advanceSettleAction.
  ///
  /// In bn, this message translates to:
  /// **'ফেরত দেওয়া লিখুন'**
  String get advanceSettleAction;

  /// No description provided for @monthCloseTitle.
  ///
  /// In bn, this message translates to:
  /// **'মাস বন্ধ করুন'**
  String get monthCloseTitle;

  /// No description provided for @monthCloseManagerOnly.
  ///
  /// In bn, this message translates to:
  /// **'শুধু সংসার ব্যবস্থাপক বা অ্যাডমিন মাস বন্ধ বা আবার খুলতে পারবেন।'**
  String get monthCloseManagerOnly;

  /// No description provided for @monthCloseCurrentHint.
  ///
  /// In bn, this message translates to:
  /// **'এই মাস বন্ধ করলে এটি পড়ার মতো হয়ে যাবে এবং এর ব্যালেন্স পরের মাসে যাবে।'**
  String get monthCloseCurrentHint;

  /// No description provided for @monthCloseWillRecord.
  ///
  /// In bn, this message translates to:
  /// **'এই মাস যে ব্যালেন্স নথিভুক্ত করবে'**
  String get monthCloseWillRecord;

  /// No description provided for @monthCloseAdvances.
  ///
  /// In bn, this message translates to:
  /// **'বন্ধের পর অগ্রিম বাকি'**
  String get monthCloseAdvances;

  /// No description provided for @monthCloseExpected.
  ///
  /// In bn, this message translates to:
  /// **'পরিকল্পিত জমা'**
  String get monthCloseExpected;

  /// No description provided for @monthCloseReceived.
  ///
  /// In bn, this message translates to:
  /// **'গৃহীত জমা'**
  String get monthCloseReceived;

  /// No description provided for @monthClose.
  ///
  /// In bn, this message translates to:
  /// **'মাস বন্ধ করুন'**
  String get monthClose;

  /// No description provided for @monthCloseConfirmTitle.
  ///
  /// In bn, this message translates to:
  /// **'এই মাস বন্ধ করবেন?'**
  String get monthCloseConfirmTitle;

  /// No description provided for @monthCloseConfirmMessage.
  ///
  /// In bn, this message translates to:
  /// **'মাসটি পড়ার মতো হয়ে যাবে এবং ব্যালেন্স পরের মাসে যাবে। কিছু ভুল থাকলে পরে আবার খুলতে পারবেন।'**
  String get monthCloseConfirmMessage;

  /// No description provided for @monthClosedDone.
  ///
  /// In bn, this message translates to:
  /// **'মাস বন্ধ হয়েছে'**
  String get monthClosedDone;

  /// No description provided for @monthReopen.
  ///
  /// In bn, this message translates to:
  /// **'মাস আবার খুলুন'**
  String get monthReopen;

  /// No description provided for @monthReopenedDone.
  ///
  /// In bn, this message translates to:
  /// **'মাস আবার খোলা হয়েছে'**
  String get monthReopenedDone;

  /// No description provided for @monthReopenNoteTitle.
  ///
  /// In bn, this message translates to:
  /// **'কেন এই মাস আবার খুলছেন?'**
  String get monthReopenNoteTitle;

  /// No description provided for @monthReopenNoteHint.
  ///
  /// In bn, this message translates to:
  /// **'একটি ছোট কারণ (অন্তত ৩ অক্ষর)।'**
  String get monthReopenNoteHint;

  /// No description provided for @monthClosedChip.
  ///
  /// In bn, this message translates to:
  /// **'{month} (বন্ধ)'**
  String monthClosedChip(String month);

  /// No description provided for @reportTitle.
  ///
  /// In bn, this message translates to:
  /// **'রিপোর্ট'**
  String get reportTitle;

  /// No description provided for @reportTabSummary.
  ///
  /// In bn, this message translates to:
  /// **'সারসংক্ষেপ'**
  String get reportTabSummary;

  /// No description provided for @reportTabCategories.
  ///
  /// In bn, this message translates to:
  /// **'ক্যাটেগরি'**
  String get reportTabCategories;

  /// No description provided for @reportTabItems.
  ///
  /// In bn, this message translates to:
  /// **'আইটেম'**
  String get reportTabItems;

  /// No description provided for @reportTabDays.
  ///
  /// In bn, this message translates to:
  /// **'দিন'**
  String get reportTabDays;

  /// No description provided for @reportTabMembers.
  ///
  /// In bn, this message translates to:
  /// **'সদস্য'**
  String get reportTabMembers;

  /// No description provided for @reportTabDry.
  ///
  /// In bn, this message translates to:
  /// **'শুকনা বাজার'**
  String get reportTabDry;

  /// No description provided for @reportTabContributions.
  ///
  /// In bn, this message translates to:
  /// **'জমা'**
  String get reportTabContributions;

  /// No description provided for @reportTotal.
  ///
  /// In bn, this message translates to:
  /// **'মোট'**
  String get reportTotal;

  /// No description provided for @reportAmount.
  ///
  /// In bn, this message translates to:
  /// **'টাকা'**
  String get reportAmount;

  /// No description provided for @reportAveragePerDay.
  ///
  /// In bn, this message translates to:
  /// **'দৈনিক গড়'**
  String get reportAveragePerDay;

  /// No description provided for @reportRows.
  ///
  /// In bn, this message translates to:
  /// **'এন্ট্রি'**
  String get reportRows;

  /// No description provided for @reportRange.
  ///
  /// In bn, this message translates to:
  /// **'সময়কাল'**
  String get reportRange;

  /// No description provided for @reportSummaryColumn.
  ///
  /// In bn, this message translates to:
  /// **'বিবরণ'**
  String get reportSummaryColumn;

  /// No description provided for @reportCategoryColumn.
  ///
  /// In bn, this message translates to:
  /// **'ক্যাটেগরি'**
  String get reportCategoryColumn;

  /// No description provided for @reportItemColumn.
  ///
  /// In bn, this message translates to:
  /// **'আইটেম'**
  String get reportItemColumn;

  /// No description provided for @reportDayColumn.
  ///
  /// In bn, this message translates to:
  /// **'দিন'**
  String get reportDayColumn;

  /// No description provided for @reportMemberColumn.
  ///
  /// In bn, this message translates to:
  /// **'সদস্য'**
  String get reportMemberColumn;

  /// No description provided for @reportPercent.
  ///
  /// In bn, this message translates to:
  /// **'{percent}%'**
  String reportPercent(String percent);

  /// No description provided for @reportUp.
  ///
  /// In bn, this message translates to:
  /// **'বেড়েছে'**
  String get reportUp;

  /// No description provided for @reportDown.
  ///
  /// In bn, this message translates to:
  /// **'কমেছে'**
  String get reportDown;

  /// No description provided for @reportFlat.
  ///
  /// In bn, this message translates to:
  /// **'অপরিবর্তিত'**
  String get reportFlat;

  /// No description provided for @reportPrevious.
  ///
  /// In bn, this message translates to:
  /// **'আগে'**
  String get reportPrevious;

  /// No description provided for @reportComparedWith.
  ///
  /// In bn, this message translates to:
  /// **'{period}-এর তুলনায়'**
  String reportComparedWith(String period);

  /// No description provided for @reportNoPreviousData.
  ///
  /// In bn, this message translates to:
  /// **'আগের কোনো তথ্য নেই'**
  String get reportNoPreviousData;

  /// No description provided for @reportComparisonSemantics.
  ///
  /// In bn, this message translates to:
  /// **'{period}-এর তুলনায় {direction} {amount}, {percent}'**
  String reportComparisonSemantics(
    String direction,
    String amount,
    String percent,
    String period,
  );

  /// No description provided for @reportPrevDay.
  ///
  /// In bn, this message translates to:
  /// **'আগের দিন'**
  String get reportPrevDay;

  /// No description provided for @reportPrevWeek.
  ///
  /// In bn, this message translates to:
  /// **'গত সপ্তাহ'**
  String get reportPrevWeek;

  /// No description provided for @reportPrevMonth.
  ///
  /// In bn, this message translates to:
  /// **'গত মাস'**
  String get reportPrevMonth;

  /// No description provided for @reportPrevYear.
  ///
  /// In bn, this message translates to:
  /// **'গত বছর'**
  String get reportPrevYear;

  /// No description provided for @reportPrevRange.
  ///
  /// In bn, this message translates to:
  /// **'আগের সময়কাল'**
  String get reportPrevRange;

  /// No description provided for @reportDryEstimate.
  ///
  /// In bn, this message translates to:
  /// **'পরিকল্পিত'**
  String get reportDryEstimate;

  /// No description provided for @reportDryActual.
  ///
  /// In bn, this message translates to:
  /// **'খরচ'**
  String get reportDryActual;

  /// No description provided for @reportDryDelta.
  ///
  /// In bn, this message translates to:
  /// **'পার্থক্য'**
  String get reportDryDelta;

  /// No description provided for @reportDryPlanned.
  ///
  /// In bn, this message translates to:
  /// **'পরিকল্পনা'**
  String get reportDryPlanned;

  /// No description provided for @reportDryEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এই সময়ের জন্য শুকনা বাজারের কোনো পরিকল্পনা নেই।'**
  String get reportDryEmpty;

  /// No description provided for @reportOver.
  ///
  /// In bn, this message translates to:
  /// **'বেশি'**
  String get reportOver;

  /// No description provided for @reportUnder.
  ///
  /// In bn, this message translates to:
  /// **'কম'**
  String get reportUnder;

  /// No description provided for @reportExpected.
  ///
  /// In bn, this message translates to:
  /// **'পরিকল্পিত'**
  String get reportExpected;

  /// No description provided for @reportTruncated.
  ///
  /// In bn, this message translates to:
  /// **'এই সময়ে অনেকগুলো এন্ট্রি, সব দেখানো যাচ্ছে না। নির্ভুল রিপোর্টের জন্য ছোট সময় বেছে নিন।'**
  String get reportTruncated;

  /// No description provided for @chartNoData.
  ///
  /// In bn, this message translates to:
  /// **'এই সময়ের জন্য দেখানোর মতো কিছু নেই।'**
  String get chartNoData;

  /// No description provided for @chartOther.
  ///
  /// In bn, this message translates to:
  /// **'অন্যান্য'**
  String get chartOther;

  /// No description provided for @chartSlice.
  ///
  /// In bn, this message translates to:
  /// **'{name} {amount}, মোটের {percent}%'**
  String chartSlice(String name, String amount, String percent);

  /// No description provided for @chartDaySummary.
  ///
  /// In bn, this message translates to:
  /// **'সবচেয়ে বেশি খরচ {day}: {amount}'**
  String chartDaySummary(String day, String amount);

  /// No description provided for @choresEmptyTitle.
  ///
  /// In bn, this message translates to:
  /// **'কোনো কাজ নেই'**
  String get choresEmptyTitle;

  /// No description provided for @choresEmptyMessage.
  ///
  /// In bn, this message translates to:
  /// **'কাজ যোগ হলে এখানে দেখা যাবে।'**
  String get choresEmptyMessage;

  /// No description provided for @choresManageAction.
  ///
  /// In bn, this message translates to:
  /// **'পরিচালনা'**
  String get choresManageAction;

  /// No description provided for @choresManageTitle.
  ///
  /// In bn, this message translates to:
  /// **'কাজ পরিচালনা'**
  String get choresManageTitle;

  /// No description provided for @choresManageEmptyTitle.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কিছু নেই'**
  String get choresManageEmptyTitle;

  /// No description provided for @choresManageEmptyMessage.
  ///
  /// In bn, this message translates to:
  /// **'কাজ পরিচালনার টুল এখানে দেখা যাবে।'**
  String get choresManageEmptyMessage;

  /// Display name of the Chores module.
  ///
  /// In bn, this message translates to:
  /// **'কাজ'**
  String get choresModuleTitle;

  /// No description provided for @permissionManageChoreTemplates.
  ///
  /// In bn, this message translates to:
  /// **'কাজ ও রোটেশন পরিচালনা'**
  String get permissionManageChoreTemplates;

  /// No description provided for @permissionReassignChore.
  ///
  /// In bn, this message translates to:
  /// **'কাজ অন্যজনকে দেওয়া'**
  String get permissionReassignChore;

  /// No description provided for @permissionRequestSwap.
  ///
  /// In bn, this message translates to:
  /// **'কাজ বদলের অনুরোধ'**
  String get permissionRequestSwap;

  /// No description provided for @permissionCompleteOwnChore.
  ///
  /// In bn, this message translates to:
  /// **'নিজের কাজ শেষ করা'**
  String get permissionCompleteOwnChore;

  /// No description provided for @permissionCommentOnChore.
  ///
  /// In bn, this message translates to:
  /// **'কাজে মন্তব্য করা'**
  String get permissionCommentOnChore;

  /// No description provided for @permissionVerifyChore.
  ///
  /// In bn, this message translates to:
  /// **'অন্যের কাজ যাচাই করা'**
  String get permissionVerifyChore;

  /// No description provided for @permissionCompleteChoreForOthers.
  ///
  /// In bn, this message translates to:
  /// **'অন্যের কাজ শেষ করে দেওয়া'**
  String get permissionCompleteChoreForOthers;

  /// No description provided for @permissionRecordOwnAvailability.
  ///
  /// In bn, this message translates to:
  /// **'নিজের অনুপস্থিতি জানানো'**
  String get permissionRecordOwnAvailability;

  /// No description provided for @permissionManageAvailability.
  ///
  /// In bn, this message translates to:
  /// **'অনুপস্থিতি পরিচালনা'**
  String get permissionManageAvailability;

  /// No description provided for @permissionManageChoreOccurrences.
  ///
  /// In bn, this message translates to:
  /// **'কাজ বাদ দেওয়া, আবার খোলা বা টীকা দেওয়া'**
  String get permissionManageChoreOccurrences;

  /// No description provided for @permissionModerateChoreComments.
  ///
  /// In bn, this message translates to:
  /// **'মন্তব্য লুকানো'**
  String get permissionModerateChoreComments;

  /// Status of a chore skipped for an absence or by a manager.
  ///
  /// In bn, this message translates to:
  /// **'বাদ দেওয়া'**
  String get choreStatusSkipped;

  /// No description provided for @choreFlagNeedsCover.
  ///
  /// In bn, this message translates to:
  /// **'কেউ এখনও নেই'**
  String get choreFlagNeedsCover;

  /// No description provided for @choreFlagAwaitingVerification.
  ///
  /// In bn, this message translates to:
  /// **'যাচাই বাকি'**
  String get choreFlagAwaitingVerification;

  /// No description provided for @choreFlagNeedsAttention.
  ///
  /// In bn, this message translates to:
  /// **'দৃষ্টি দেওয়ার কাজ'**
  String get choreFlagNeedsAttention;

  /// Shown on a projected occurrence that has no document yet.
  ///
  /// In bn, this message translates to:
  /// **'পরিকল্পিত'**
  String get choreFlagPlanned;

  /// No description provided for @choreFlagSwapPending.
  ///
  /// In bn, this message translates to:
  /// **'বদলের অনুরোধ বাকি'**
  String get choreFlagSwapPending;

  /// No description provided for @reasonSheetHint.
  ///
  /// In bn, this message translates to:
  /// **'কেন? (অন্তত ৩টি অক্ষর)'**
  String get reasonSheetHint;

  /// No description provided for @reasonSheetTooShort.
  ///
  /// In bn, this message translates to:
  /// **'অন্তত {min}টি অক্ষর লিখুন।'**
  String reasonSheetTooShort(int min);

  /// A chore due time that is not set: due by the end of the day.
  ///
  /// In bn, this message translates to:
  /// **'দিনের শেষে'**
  String get minutesFieldNotSet;

  /// No description provided for @minutesFieldClear.
  ///
  /// In bn, this message translates to:
  /// **'সময় মুছে ফেলুন'**
  String get minutesFieldClear;

  /// No description provided for @colorSwatchLabel.
  ///
  /// In bn, this message translates to:
  /// **'রং {index}, মোট {count}টি'**
  String colorSwatchLabel(int index, int count);

  /// No description provided for @avatarStackMore.
  ///
  /// In bn, this message translates to:
  /// **'{first} এবং আরও {rest} জন'**
  String avatarStackMore(String first, int rest);

  /// No description provided for @avatarStackMoreShort.
  ///
  /// In bn, this message translates to:
  /// **'+{hidden}'**
  String avatarStackMoreShort(int hidden);

  /// No description provided for @stepProgressSemantic.
  ///
  /// In bn, this message translates to:
  /// **'{total}টি ধাপের {done}টি শেষ'**
  String stepProgressSemantic(String done, String total);

  /// No description provided for @choresFailure_required.
  ///
  /// In bn, this message translates to:
  /// **'এটি পূরণ করা জরুরি।'**
  String get choresFailure_required;

  /// No description provided for @choresFailure_too_long.
  ///
  /// In bn, this message translates to:
  /// **'লেখাটি খুব বড় হয়ে গেছে।'**
  String get choresFailure_too_long;

  /// No description provided for @choresFailure_invalid_time.
  ///
  /// In bn, this message translates to:
  /// **'সঠিক সময় দিন।'**
  String get choresFailure_invalid_time;

  /// No description provided for @choresFailure_invalid_recurrence.
  ///
  /// In bn, this message translates to:
  /// **'এই পুনরাবৃত্তির নিয়ম ঠিক নেই।'**
  String get choresFailure_invalid_recurrence;

  /// No description provided for @choresFailure_no_dates.
  ///
  /// In bn, this message translates to:
  /// **'অন্তত একটি দিন বেছে নিন।'**
  String get choresFailure_no_dates;

  /// No description provided for @choresFailure_invalid_range.
  ///
  /// In bn, this message translates to:
  /// **'শেষ তারিখ শুরুর আগে হতে পারে না।'**
  String get choresFailure_invalid_range;

  /// No description provided for @choresFailure_invalid_date.
  ///
  /// In bn, this message translates to:
  /// **'তারিখটি সঠিক নয়।'**
  String get choresFailure_invalid_date;

  /// No description provided for @choresFailure_too_many_subtasks.
  ///
  /// In bn, this message translates to:
  /// **'ধাপ সংখ্যায় বেশি হয়ে গেছে (সর্বোচ্চ ৩০)।'**
  String get choresFailure_too_many_subtasks;

  /// No description provided for @choresFailure_too_many_slots.
  ///
  /// In bn, this message translates to:
  /// **'দিনে বার সংখ্যায় বেশি (সর্বোচ্চ ৬)।'**
  String get choresFailure_too_many_slots;

  /// No description provided for @choresFailure_duplicate_slot.
  ///
  /// In bn, this message translates to:
  /// **'একই নামে দুটি বার আছে।'**
  String get choresFailure_duplicate_slot;

  /// No description provided for @choresFailure_too_many_items.
  ///
  /// In bn, this message translates to:
  /// **'পরিমাণটি বেশি হয়ে গেছে।'**
  String get choresFailure_too_many_items;

  /// No description provided for @choresFailure_duplicate_id.
  ///
  /// In bn, this message translates to:
  /// **'এই নামটি আগেই ব্যবহার করা হয়েছে।'**
  String get choresFailure_duplicate_id;

  /// No description provided for @choresFailure_reason_required.
  ///
  /// In bn, this message translates to:
  /// **'কারণ লিখতে হবে।'**
  String get choresFailure_reason_required;

  /// No description provided for @choresFailure_reason_too_short.
  ///
  /// In bn, this message translates to:
  /// **'কারণে অন্তত ৩টি অক্ষর দিন।'**
  String get choresFailure_reason_too_short;

  /// No description provided for @choresFailure_member_required.
  ///
  /// In bn, this message translates to:
  /// **'একজন সদস্য বেছে নিন।'**
  String get choresFailure_member_required;

  /// No description provided for @choresFailure_invalid_rotation.
  ///
  /// In bn, this message translates to:
  /// **'এই রোটেশনটি সঠিক নয়।'**
  String get choresFailure_invalid_rotation;

  /// No description provided for @choresFailure_too_few_members.
  ///
  /// In bn, this message translates to:
  /// **'রোটেশনে অন্তত দুই জন সদস্য দিন।'**
  String get choresFailure_too_few_members;

  /// No description provided for @choresFailure_invalid_horizon.
  ///
  /// In bn, this message translates to:
  /// **'১৪ থেকে ৯০ দিনের মধ্যে একটি সীমা বেছে নিন।'**
  String get choresFailure_invalid_horizon;

  /// No description provided for @choresFailure_invalid_week_start.
  ///
  /// In bn, this message translates to:
  /// **'সপ্তাহের প্রথম দিন সঠিকভাবে বেছে নিন।'**
  String get choresFailure_invalid_week_start;

  /// No description provided for @choresFailure_invalid_minutes.
  ///
  /// In bn, this message translates to:
  /// **'০০:০০ থেকে ২৩:৫৯ এর মধ্যে সময় দিন।'**
  String get choresFailure_invalid_minutes;

  /// No description provided for @choresFailure_not_assigned_to_you.
  ///
  /// In bn, this message translates to:
  /// **'এই কাজটি আপনার নয়।'**
  String get choresFailure_not_assigned_to_you;

  /// No description provided for @choresFailure_already_completed.
  ///
  /// In bn, this message translates to:
  /// **'এই কাজটি আগেই শেষ হয়েছে।'**
  String get choresFailure_already_completed;

  /// No description provided for @choresFailure_not_completed.
  ///
  /// In bn, this message translates to:
  /// **'এই কাজটি এখনও শেষ হয়নি।'**
  String get choresFailure_not_completed;

  /// No description provided for @choresFailure_required_subtasks_open.
  ///
  /// In bn, this message translates to:
  /// **'আগে জরুরি ধাপগুলো শেষ করুন।'**
  String get choresFailure_required_subtasks_open;

  /// No description provided for @choresFailure_self_verification.
  ///
  /// In bn, this message translates to:
  /// **'নিজের কাজ নিজে যাচাই করা যায় না।'**
  String get choresFailure_self_verification;

  /// No description provided for @choresFailure_verification_not_required.
  ///
  /// In bn, this message translates to:
  /// **'এই কাজে যাচাই দরকার নেই।'**
  String get choresFailure_verification_not_required;

  /// No description provided for @choresFailure_already_verified.
  ///
  /// In bn, this message translates to:
  /// **'এই কাজটি আগেই যাচাই হয়েছে।'**
  String get choresFailure_already_verified;

  /// No description provided for @choresFailure_verified_requires_manager.
  ///
  /// In bn, this message translates to:
  /// **'যাচাই হওয়া কাজ শুধু পরিচালক আবার খুলতে পারেন।'**
  String get choresFailure_verified_requires_manager;

  /// No description provided for @choresFailure_occurrence_started.
  ///
  /// In bn, this message translates to:
  /// **'এই কাজটি শুরু হয়ে গেছে।'**
  String get choresFailure_occurrence_started;

  /// No description provided for @choresFailure_already_skipped.
  ///
  /// In bn, this message translates to:
  /// **'এই কাজটি আগেই বাদ দেওয়া হয়েছে।'**
  String get choresFailure_already_skipped;

  /// No description provided for @choresFailure_not_skipped.
  ///
  /// In bn, this message translates to:
  /// **'এই কাজটি বাদ দেওয়া হয়নি।'**
  String get choresFailure_not_skipped;

  /// No description provided for @choresFailure_swap_not_pending.
  ///
  /// In bn, this message translates to:
  /// **'এই অনুরোধটি আর খোলা নেই।'**
  String get choresFailure_swap_not_pending;

  /// No description provided for @choresFailure_swap_expired.
  ///
  /// In bn, this message translates to:
  /// **'এই অনুরোধের সময় শেষ।'**
  String get choresFailure_swap_expired;

  /// No description provided for @choresFailure_swaps_disabled.
  ///
  /// In bn, this message translates to:
  /// **'এই পরিবারে কাজ বদল বন্ধ আছে।'**
  String get choresFailure_swaps_disabled;

  /// No description provided for @choresFailure_cover_not_needed.
  ///
  /// In bn, this message translates to:
  /// **'এই কাজে ইতিমধ্যে কেউ আছেন।'**
  String get choresFailure_cover_not_needed;

  /// No description provided for @choresFailure_availability_overlap.
  ///
  /// In bn, this message translates to:
  /// **'এই দিনগুলোতে অনুপস্থিতি আগেই জানানো আছে।'**
  String get choresFailure_availability_overlap;

  /// No description provided for @choresFailure_member_unavailable.
  ///
  /// In bn, this message translates to:
  /// **'সদস্যটি ওই দিনে অনুপস্থিত।'**
  String get choresFailure_member_unavailable;

  /// No description provided for @choresFailure_template_paused.
  ///
  /// In bn, this message translates to:
  /// **'এই কাজটি সাময়িকভাবে বন্ধ।'**
  String get choresFailure_template_paused;

  /// No description provided for @choresFailure_rotation_member_inactive.
  ///
  /// In bn, this message translates to:
  /// **'রোটেশনের একজন সদস্য আর সক্রিয় নন।'**
  String get choresFailure_rotation_member_inactive;

  /// No description provided for @choresFailure_range_too_large.
  ///
  /// In bn, this message translates to:
  /// **'একবারে তৈরি করার জন্য সীমাটি বেশি বড়।'**
  String get choresFailure_range_too_large;

  /// No description provided for @choresFailure_starter_pack_applied.
  ///
  /// In bn, this message translates to:
  /// **'এই স্টার্টার প্যাক আগেই যোগ করা হয়েছে।'**
  String get choresFailure_starter_pack_applied;

  /// No description provided for @choresFailure_occurrence_deleted.
  ///
  /// In bn, this message translates to:
  /// **'এই কাজটি মুছে ফেলা হয়েছে।'**
  String get choresFailure_occurrence_deleted;

  /// No description provided for @choresFailure_concurrent_edit.
  ///
  /// In bn, this message translates to:
  /// **'অন্য কেউ এটি বদলে ফেলেছেন; আবার খুলে চেষ্টা করুন।'**
  String get choresFailure_concurrent_edit;

  /// No description provided for @choresFailure_last_group_in_use.
  ///
  /// In bn, this message translates to:
  /// **'এই দলটি এখনও কাজে ব্যবহার হচ্ছে।'**
  String get choresFailure_last_group_in_use;

  /// No description provided for @choresFailure_not_a_recipient.
  ///
  /// In bn, this message translates to:
  /// **'অনুরোধটি আপনার জন্য নয়।'**
  String get choresFailure_not_a_recipient;

  /// No description provided for @choresFailure_not_found.
  ///
  /// In bn, this message translates to:
  /// **'এটি আর নেই।'**
  String get choresFailure_not_found;

  /// No description provided for @choresFailure_permission_denied.
  ///
  /// In bn, this message translates to:
  /// **'এটি করার অনুমতি আপনার নেই।'**
  String get choresFailure_permission_denied;

  /// No description provided for @choresFailure_network.
  ///
  /// In bn, this message translates to:
  /// **'ইন্টারনেট সংযোগ নেই। 연결 দেখে আবার চেষ্টা করুন।'**
  String get choresFailure_network;

  /// No description provided for @choresFailure_unknown.
  ///
  /// In bn, this message translates to:
  /// **'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।'**
  String get choresFailure_unknown;

  /// No description provided for @activityChoresSettingsUpdated.
  ///
  /// In bn, this message translates to:
  /// **'কাজের সেটিংস বদলেছেন'**
  String get activityChoresSettingsUpdated;

  /// No description provided for @activityChoresRotationPolicyUpdated.
  ///
  /// In bn, this message translates to:
  /// **'অনুপস্থিতির নিয়ম বদলেছেন'**
  String get activityChoresRotationPolicyUpdated;

  /// No description provided for @activityChoresTemplateCreated.
  ///
  /// In bn, this message translates to:
  /// **'{name} কাজটি যোগ করেছেন'**
  String activityChoresTemplateCreated(String name);

  /// No description provided for @activityChoresTemplateUpdated.
  ///
  /// In bn, this message translates to:
  /// **'{name} কাজটি বদলেছেন'**
  String activityChoresTemplateUpdated(String name);

  /// No description provided for @activityChoresTemplatePaused.
  ///
  /// In bn, this message translates to:
  /// **'{name} কাজটি সাময়িকভাবে বন্ধ করেছেন'**
  String activityChoresTemplatePaused(String name);

  /// No description provided for @activityChoresTemplateResumed.
  ///
  /// In bn, this message translates to:
  /// **'{name} কাজটি আবার চালু করেছেন'**
  String activityChoresTemplateResumed(String name);

  /// No description provided for @activityChoresTemplateArchived.
  ///
  /// In bn, this message translates to:
  /// **'{name} কাজটি আর্কাইভ করেছেন'**
  String activityChoresTemplateArchived(String name);

  /// No description provided for @activityChoresTemplateDuplicated.
  ///
  /// In bn, this message translates to:
  /// **'{name} কাজটির কপি করেছেন'**
  String activityChoresTemplateDuplicated(String name);

  /// No description provided for @activityChoresStarterPackApplied.
  ///
  /// In bn, this message translates to:
  /// **'স্টার্টার কাজগুলো যোগ করেছেন ({templates}টি কাজ, {groups}টি দল)'**
  String activityChoresStarterPackApplied(String templates, String groups);

  /// No description provided for @activityChoresDutyGroupCreated.
  ///
  /// In bn, this message translates to:
  /// **'{name} দলটি যোগ করেছেন'**
  String activityChoresDutyGroupCreated(String name);

  /// No description provided for @activityChoresDutyGroupUpdated.
  ///
  /// In bn, this message translates to:
  /// **'{name} দলটি বদলেছেন'**
  String activityChoresDutyGroupUpdated(String name);

  /// No description provided for @activityChoresRotationChanged.
  ///
  /// In bn, this message translates to:
  /// **'{name} এর রোটেশন বদলেছেন'**
  String activityChoresRotationChanged(String name);

  /// No description provided for @activityChoresOccurrencesGenerated.
  ///
  /// In bn, this message translates to:
  /// **'{from} থেকে {to} পর্যন্ত কাজ তৈরি হয়েছে ({count})'**
  String activityChoresOccurrencesGenerated(
    String from,
    String to,
    String count,
  );

  /// No description provided for @activityChoresOccurrencesReplanned.
  ///
  /// In bn, this message translates to:
  /// **'{from} থেকে {name} কাজটি আবার পরিকল্পনা করেছেন'**
  String activityChoresOccurrencesReplanned(String name, String from);

  /// No description provided for @activityChoresOccurrenceCompleted.
  ///
  /// In bn, this message translates to:
  /// **'{member} {date}-এ {name} শেষ করেছেন'**
  String activityChoresOccurrenceCompleted(
    String member,
    String name,
    String date,
  );

  /// No description provided for @activityChoresOccurrenceUncompleted.
  ///
  /// In bn, this message translates to:
  /// **'{member} {date}-এ {name} আবার অসম্পূর্ণ করেছেন'**
  String activityChoresOccurrenceUncompleted(
    String member,
    String name,
    String date,
  );

  /// No description provided for @activityChoresOccurrenceVerified.
  ///
  /// In bn, this message translates to:
  /// **'{member} {date}-এ {name} যাচাই করেছেন'**
  String activityChoresOccurrenceVerified(
    String member,
    String name,
    String date,
  );

  /// No description provided for @activityChoresOccurrenceReopened.
  ///
  /// In bn, this message translates to:
  /// **'{member} {date}-এ {name} আবার খুলেছেন'**
  String activityChoresOccurrenceReopened(
    String member,
    String name,
    String date,
  );

  /// No description provided for @activityChoresOccurrenceException.
  ///
  /// In bn, this message translates to:
  /// **'{member} {date}-এ {name} এর জন্য ব্যতিক্রম লিখেছেন'**
  String activityChoresOccurrenceException(
    String member,
    String name,
    String date,
  );

  /// No description provided for @activityChoresOccurrenceSkipped.
  ///
  /// In bn, this message translates to:
  /// **'{member} {date}-এ {name} বাদ দিয়েছেন'**
  String activityChoresOccurrenceSkipped(
    String member,
    String name,
    String date,
  );

  /// No description provided for @activityChoresOccurrenceUnskipped.
  ///
  /// In bn, this message translates to:
  /// **'{member} {date}-এ {name} আবার চালু করেছেন'**
  String activityChoresOccurrenceUnskipped(
    String member,
    String name,
    String date,
  );

  /// No description provided for @activityChoresOccurrenceReassigned.
  ///
  /// In bn, this message translates to:
  /// **'{member} {date}-এ {name} অন্যকে দিয়েছেন'**
  String activityChoresOccurrenceReassigned(
    String member,
    String name,
    String date,
  );

  /// No description provided for @activityChoresCommentAdded.
  ///
  /// In bn, this message translates to:
  /// **'{member} {date}-এ {name} নিয়ে মন্তব্য করেছেন'**
  String activityChoresCommentAdded(String member, String name, String date);

  /// No description provided for @activityChoresCommentHidden.
  ///
  /// In bn, this message translates to:
  /// **'{member} {date}-এ {name} এর একটি মন্তব্য লুকিয়েছেন'**
  String activityChoresCommentHidden(String member, String name, String date);

  /// No description provided for @activityChoresAvailabilityAdded.
  ///
  /// In bn, this message translates to:
  /// **'{member} {from} থেকে {to} পর্যন্ত অনুপস্থিতি জানিয়েছেন'**
  String activityChoresAvailabilityAdded(String member, String from, String to);

  /// No description provided for @activityChoresAvailabilityCancelled.
  ///
  /// In bn, this message translates to:
  /// **'{member} {from} থেকে {to} পর্যন্ত অনুপস্থিতি বাতিল করেছেন'**
  String activityChoresAvailabilityCancelled(
    String member,
    String from,
    String to,
  );

  /// No description provided for @activityChoresAvailabilityDecided.
  ///
  /// In bn, this message translates to:
  /// **'{member} {from} থেকে {to} পর্যন্ত অনুপস্থিতির সিদ্ধান্ত দিয়েছেন'**
  String activityChoresAvailabilityDecided(
    String member,
    String from,
    String to,
  );

  /// No description provided for @activityChoresSwapRequested.
  ///
  /// In bn, this message translates to:
  /// **'{member} {to}-কে {date}-এ {name} ধরতে অনুরোধ করেছেন'**
  String activityChoresSwapRequested(
    String member,
    String to,
    String name,
    String date,
  );

  /// No description provided for @activityChoresSwapAccepted.
  ///
  /// In bn, this message translates to:
  /// **'{to} {date}-এ {name} নিতে রাজি হয়েছেন'**
  String activityChoresSwapAccepted(String to, String name, String date);

  /// No description provided for @activityChoresSwapDeclined.
  ///
  /// In bn, this message translates to:
  /// **'{to} {date}-এ {name} নিতে রাজি হননি'**
  String activityChoresSwapDeclined(String to, String name, String date);

  /// No description provided for @activityChoresSwapCancelled.
  ///
  /// In bn, this message translates to:
  /// **'{member} {date}-এ {name} এর অনুরোধ বাতিল করেছেন'**
  String activityChoresSwapCancelled(String member, String name, String date);

  /// No description provided for @activityChoresSwapExpired.
  ///
  /// In bn, this message translates to:
  /// **'{date}-এ {name} এর অনুরোধের সময় শেষ হয়েছে'**
  String activityChoresSwapExpired(String name, String date);

  /// No description provided for @activityChoresCoverAssigned.
  ///
  /// In bn, this message translates to:
  /// **'{to} {date}-এ {name} সামলাবেন'**
  String activityChoresCoverAssigned(String to, String name, String date);

  /// No description provided for @occurrenceDetailTitle.
  ///
  /// In bn, this message translates to:
  /// **'কাজ'**
  String get occurrenceDetailTitle;

  /// No description provided for @occurrenceDueToday.
  ///
  /// In bn, this message translates to:
  /// **'আজ, {time}টার মধ্যে'**
  String occurrenceDueToday(String time);

  /// No description provided for @occurrenceDueDay.
  ///
  /// In bn, this message translates to:
  /// **'{date}, {time}টার মধ্যে'**
  String occurrenceDueDay(String time, String date);

  /// No description provided for @occurrenceDueNoTime.
  ///
  /// In bn, this message translates to:
  /// **'দিনের শেষে'**
  String get occurrenceDueNoTime;

  /// No description provided for @occurrenceUnassigned.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কেউ দায়িত্বে নেই'**
  String get occurrenceUnassigned;

  /// No description provided for @occurrenceCoveringFor.
  ///
  /// In bn, this message translates to:
  /// **'{name}-এর হয়ে করছেন'**
  String occurrenceCoveringFor(String name);

  /// No description provided for @occurrenceStepsTitle.
  ///
  /// In bn, this message translates to:
  /// **'ধাপগুলো'**
  String get occurrenceStepsTitle;

  /// No description provided for @occurrenceInstructionsTitle.
  ///
  /// In bn, this message translates to:
  /// **'কীভাবে করবেন'**
  String get occurrenceInstructionsTitle;

  /// No description provided for @occurrenceEstimated.
  ///
  /// In bn, this message translates to:
  /// **'প্রায় {minutes} মিনিট'**
  String occurrenceEstimated(String minutes);

  /// No description provided for @occurrenceDifficultyEasy.
  ///
  /// In bn, this message translates to:
  /// **'সহজ'**
  String get occurrenceDifficultyEasy;

  /// No description provided for @occurrenceDifficultyNormal.
  ///
  /// In bn, this message translates to:
  /// **'সাধারণ'**
  String get occurrenceDifficultyNormal;

  /// No description provided for @occurrenceDifficultyHard.
  ///
  /// In bn, this message translates to:
  /// **'কঠিন'**
  String get occurrenceDifficultyHard;

  /// No description provided for @occurrenceTimelineTitle.
  ///
  /// In bn, this message translates to:
  /// **'ইতিহাস'**
  String get occurrenceTimelineTitle;

  /// No description provided for @occurrenceEventCompleted.
  ///
  /// In bn, this message translates to:
  /// **'{name} সম্পন্ন করেছেন'**
  String occurrenceEventCompleted(String name);

  /// No description provided for @occurrenceEventUncompleted.
  ///
  /// In bn, this message translates to:
  /// **'{name} সম্পন্নতা ফিরিয়ে নিয়েছেন'**
  String occurrenceEventUncompleted(String name);

  /// No description provided for @occurrenceEventVerified.
  ///
  /// In bn, this message translates to:
  /// **'{name} যাচাই করেছেন'**
  String occurrenceEventVerified(String name);

  /// No description provided for @occurrenceEventReopened.
  ///
  /// In bn, this message translates to:
  /// **'{name} আবার খুলেছেন: {reason}'**
  String occurrenceEventReopened(String name, String reason);

  /// No description provided for @occurrenceEventReassigned.
  ///
  /// In bn, this message translates to:
  /// **'{name} {to}-কে দিয়েছেন: {reason}'**
  String occurrenceEventReassigned(String name, String to, String reason);

  /// No description provided for @occurrenceEventSkipped.
  ///
  /// In bn, this message translates to:
  /// **'{name} বাদ দিয়েছেন: {reason}'**
  String occurrenceEventSkipped(String name, String reason);

  /// No description provided for @occurrenceEventUnskipped.
  ///
  /// In bn, this message translates to:
  /// **'{name} আবার ফিরিয়ে দিয়েছেন'**
  String occurrenceEventUnskipped(String name);

  /// No description provided for @occurrenceEventException.
  ///
  /// In bn, this message translates to:
  /// **'{name} নোট দিয়ে শেষ করেছেন: {reason}'**
  String occurrenceEventException(String name, String reason);

  /// No description provided for @occurrenceEventSwapped.
  ///
  /// In bn, this message translates to:
  /// **'{name} {to}-এর সাথে বদল করেছেন'**
  String occurrenceEventSwapped(String name, String to);

  /// No description provided for @occurrenceEventCovered.
  ///
  /// In bn, this message translates to:
  /// **'{name} {to}-এর কাজ করেছেন'**
  String occurrenceEventCovered(String name, String to);

  /// No description provided for @occurrenceActionComplete.
  ///
  /// In bn, this message translates to:
  /// **'সম্পন্ন করুন'**
  String get occurrenceActionComplete;

  /// No description provided for @occurrenceActionUndo.
  ///
  /// In bn, this message translates to:
  /// **'সম্পন্নতা ফিরিয়ে নিন'**
  String get occurrenceActionUndo;

  /// No description provided for @occurrenceActionVerify.
  ///
  /// In bn, this message translates to:
  /// **'যাচাই করুন'**
  String get occurrenceActionVerify;

  /// No description provided for @occurrenceActionReopen.
  ///
  /// In bn, this message translates to:
  /// **'আবার খুলুন'**
  String get occurrenceActionReopen;

  /// No description provided for @occurrenceActionReassign.
  ///
  /// In bn, this message translates to:
  /// **'অন্যকে দিন'**
  String get occurrenceActionReassign;

  /// No description provided for @occurrenceActionSkip.
  ///
  /// In bn, this message translates to:
  /// **'বাদ দিন'**
  String get occurrenceActionSkip;

  /// No description provided for @occurrenceActionUnskip.
  ///
  /// In bn, this message translates to:
  /// **'ফিরিয়ে দিন'**
  String get occurrenceActionUnskip;

  /// No description provided for @occurrenceActionException.
  ///
  /// In bn, this message translates to:
  /// **'নোট দিয়ে শেষ করুন'**
  String get occurrenceActionException;

  /// No description provided for @occurrenceActionSwap.
  ///
  /// In bn, this message translates to:
  /// **'আমি এটা করতে পারব না'**
  String get occurrenceActionSwap;

  /// No description provided for @occurrenceReopenTitle.
  ///
  /// In bn, this message translates to:
  /// **'কেন আবার খুলবেন?'**
  String get occurrenceReopenTitle;

  /// No description provided for @occurrenceReassignTitle.
  ///
  /// In bn, this message translates to:
  /// **'কে করবে?'**
  String get occurrenceReassignTitle;

  /// No description provided for @occurrenceReassignReasonTitle.
  ///
  /// In bn, this message translates to:
  /// **'কেন অন্যকে দিচ্ছেন?'**
  String get occurrenceReassignReasonTitle;

  /// No description provided for @occurrenceSkipTitle.
  ///
  /// In bn, this message translates to:
  /// **'কেন বাদ দিচ্ছেন?'**
  String get occurrenceSkipTitle;

  /// No description provided for @occurrenceExceptionTitle.
  ///
  /// In bn, this message translates to:
  /// **'কী করা যায়নি?'**
  String get occurrenceExceptionTitle;

  /// No description provided for @occurrenceUndone.
  ///
  /// In bn, this message translates to:
  /// **'সম্পন্নতা ফিরিয়ে নেওয়া হয়েছে'**
  String get occurrenceUndone;

  /// No description provided for @occurrenceStepReopened.
  ///
  /// In bn, this message translates to:
  /// **'হয়ে গেছে: কাজটি আবার খোলা আছে।'**
  String get occurrenceStepReopened;

  /// No description provided for @occurrencePlannedReadOnly.
  ///
  /// In bn, this message translates to:
  /// **'এটি এখন শুধু পরিকল্পিত; প্রথম পরিবর্তনেই কাজটি যোগ হবে।'**
  String get occurrencePlannedReadOnly;

  /// No description provided for @occurrenceAwaitingVerification.
  ///
  /// In bn, this message translates to:
  /// **'কাজটি শেষ হয়েছে; যিনি করেননি তিনি যাচাই করবেন।'**
  String get occurrenceAwaitingVerification;

  /// No description provided for @occurrenceReopenStepsTitle.
  ///
  /// In bn, this message translates to:
  /// **'কোন ধাপগুলো আবার করতে হবে?'**
  String get occurrenceReopenStepsTitle;

  /// No description provided for @occurrenceReopenStepsHint.
  ///
  /// In bn, this message translates to:
  /// **'যেগুলো বেছে নেবেন সেগুলোর টিক মুছে যাবে।'**
  String get occurrenceReopenStepsHint;

  /// No description provided for @todayTitle.
  ///
  /// In bn, this message translates to:
  /// **'আজ'**
  String get todayTitle;

  /// No description provided for @todayEmptyTitle.
  ///
  /// In bn, this message translates to:
  /// **'আজ কোনো কাজ নেই'**
  String get todayEmptyTitle;

  /// No description provided for @todayEmptyMessage.
  ///
  /// In bn, this message translates to:
  /// **'ফাঁকা সময়টা উপভোগ করুন, বা পরে করার জন্য কাজ যোগ করুন।'**
  String get todayEmptyMessage;

  /// No description provided for @todaySectionOverdue.
  ///
  /// In bn, this message translates to:
  /// **'বিলম্বিত'**
  String get todaySectionOverdue;

  /// No description provided for @todaySectionDone.
  ///
  /// In bn, this message translates to:
  /// **'আজ সম্পন্ন'**
  String get todaySectionDone;

  /// No description provided for @todayScopeMine.
  ///
  /// In bn, this message translates to:
  /// **'আমার কাজ'**
  String get todayScopeMine;

  /// No description provided for @todayScopeFamily.
  ///
  /// In bn, this message translates to:
  /// **'পুরো পরিবার'**
  String get todayScopeFamily;

  /// No description provided for @todayProgress.
  ///
  /// In bn, this message translates to:
  /// **'{total}-এর মধ্যে {done} সম্পন্ন'**
  String todayProgress(String done, String total);

  /// No description provided for @todayUndo.
  ///
  /// In bn, this message translates to:
  /// **'ফিরিয়ে নিন'**
  String get todayUndo;

  /// No description provided for @verifyTitle.
  ///
  /// In bn, this message translates to:
  /// **'যাচাইয়ের অপেক্ষায়'**
  String get verifyTitle;

  /// No description provided for @verifyEmptyTitle.
  ///
  /// In bn, this message translates to:
  /// **'যাচাই করার কিছু নেই'**
  String get verifyEmptyTitle;

  /// No description provided for @verifyEmptyMessage.
  ///
  /// In bn, this message translates to:
  /// **'কেউ শেষ করে দিলে যে কাজগুলো যাচাই দরকার, সেগুলো এখানে দেখাবে।'**
  String get verifyEmptyMessage;

  /// No description provided for @verifyApprove.
  ///
  /// In bn, this message translates to:
  /// **'ঠিক আছে'**
  String get verifyApprove;

  /// No description provided for @verifyReopen.
  ///
  /// In bn, this message translates to:
  /// **'ফেরত দিন'**
  String get verifyReopen;

  /// No description provided for @choreDayPartEarlyMorning.
  ///
  /// In bn, this message translates to:
  /// **'ভোর'**
  String get choreDayPartEarlyMorning;

  /// No description provided for @choreDayPartMorning.
  ///
  /// In bn, this message translates to:
  /// **'সকাল'**
  String get choreDayPartMorning;

  /// No description provided for @choreDayPartNoon.
  ///
  /// In bn, this message translates to:
  /// **'দুপুর'**
  String get choreDayPartNoon;

  /// No description provided for @choreDayPartAfternoon.
  ///
  /// In bn, this message translates to:
  /// **'বিকাল'**
  String get choreDayPartAfternoon;

  /// No description provided for @choreDayPartEvening.
  ///
  /// In bn, this message translates to:
  /// **'সন্ধ্যা'**
  String get choreDayPartEvening;

  /// No description provided for @choreDayPartNight.
  ///
  /// In bn, this message translates to:
  /// **'রাত'**
  String get choreDayPartNight;

  /// No description provided for @choreDueTime.
  ///
  /// In bn, this message translates to:
  /// **'{time}টার মধ্যে'**
  String choreDueTime(String time);

  /// No description provided for @choreStepsCount.
  ///
  /// In bn, this message translates to:
  /// **'{done}/{total}'**
  String choreStepsCount(String done, String total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
