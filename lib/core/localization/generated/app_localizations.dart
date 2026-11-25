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

  /// No description provided for @startupFailedTitle.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাপ চালু হতে পারেনি'**
  String get startupFailedTitle;

  /// No description provided for @startupFailedBody.
  ///
  /// In bn, this message translates to:
  /// **'শুরুর একটি ধাপ ব্যর্থ হয়েছে। নিচের বিবরণ ডেভেলপারকে দেখান।'**
  String get startupFailedBody;

  /// No description provided for @startupStepLabel.
  ///
  /// In bn, this message translates to:
  /// **'ধাপ: {step}'**
  String startupStepLabel(String step);

  /// No description provided for @startupFirebaseHint.
  ///
  /// In bn, this message translates to:
  /// **'Firebase-এর কী এখনো আসল নয়। firebase/README.md-এর \"Real Firebase configuration\" অংশ দেখুন।'**
  String get startupFirebaseHint;

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

  /// No description provided for @galleryReorderMoveButtons.
  ///
  /// In bn, this message translates to:
  /// **'উপরে / নিচে সরান'**
  String get galleryReorderMoveButtons;

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

  /// No description provided for @actionMoveUp.
  ///
  /// In bn, this message translates to:
  /// **'উপরে নিন'**
  String get actionMoveUp;

  /// No description provided for @actionMoveDown.
  ///
  /// In bn, this message translates to:
  /// **'নিচে নিন'**
  String get actionMoveDown;

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

  /// No description provided for @reportShareText.
  ///
  /// In bn, this message translates to:
  /// **'রিপোর্টের লেখা শেয়ার করুন'**
  String get reportShareText;

  /// No description provided for @reportExport.
  ///
  /// In bn, this message translates to:
  /// **'রপ্তানি'**
  String get reportExport;

  /// No description provided for @reportExportCsv.
  ///
  /// In bn, this message translates to:
  /// **'CSV ফাইল রপ্তানি করুন'**
  String get reportExportCsv;

  /// No description provided for @reportExportPdf.
  ///
  /// In bn, this message translates to:
  /// **'PDF রপ্তানি করুন'**
  String get reportExportPdf;

  /// No description provided for @reportExportFailed.
  ///
  /// In bn, this message translates to:
  /// **'রিপোর্ট তৈরি বা শেয়ার করা যায়নি। আবার চেষ্টা করুন।'**
  String get reportExportFailed;

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

  /// No description provided for @choresFailure_slot_name_required.
  ///
  /// In bn, this message translates to:
  /// **'প্রথমটির পর প্রতিটি সময়ের একটি নাম দিন।'**
  String get choresFailure_slot_name_required;

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

  /// No description provided for @todayAllDoneTitle.
  ///
  /// In bn, this message translates to:
  /// **'সব কাজ শেষ'**
  String get todayAllDoneTitle;

  /// No description provided for @todayAllDoneMessage.
  ///
  /// In bn, this message translates to:
  /// **'আজকের সব কাজ হয়ে গেছে। ধন্যবাদ!'**
  String get todayAllDoneMessage;

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

  /// No description provided for @choresSettingsTitle.
  ///
  /// In bn, this message translates to:
  /// **'কাজের সেটিংস'**
  String get choresSettingsTitle;

  /// No description provided for @choresSettingsSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'পছন্দ, আবর্তন নীতিমালা এবং ক্যাটালগ'**
  String get choresSettingsSubtitle;

  /// No description provided for @choresSettingsCalendarTitle.
  ///
  /// In bn, this message translates to:
  /// **'ক্যালেন্ডার ও প্রদর্শন'**
  String get choresSettingsCalendarTitle;

  /// No description provided for @choresSettingsGenerationTitle.
  ///
  /// In bn, this message translates to:
  /// **'তৈরি ও সময় নির্ধারণ'**
  String get choresSettingsGenerationTitle;

  /// No description provided for @choresSettingsCatalogsTitle.
  ///
  /// In bn, this message translates to:
  /// **'ক্যাটালগসমূহ'**
  String get choresSettingsCatalogsTitle;

  /// No description provided for @choresSettingsPoliciesTitle.
  ///
  /// In bn, this message translates to:
  /// **'নীতিমালা ও নিয়ম'**
  String get choresSettingsPoliciesTitle;

  /// No description provided for @choresSettingsHouseRulesTitle.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের নিয়ম'**
  String get choresSettingsHouseRulesTitle;

  /// No description provided for @choresSettingsDefaultView.
  ///
  /// In bn, this message translates to:
  /// **'ডিফল্ট ক্যালেন্ডার ভিউ'**
  String get choresSettingsDefaultView;

  /// No description provided for @choresSettingsDefaultScope.
  ///
  /// In bn, this message translates to:
  /// **'ডিফল্ট কাজের পরিধি'**
  String get choresSettingsDefaultScope;

  /// No description provided for @choresSettingsWeekStart.
  ///
  /// In bn, this message translates to:
  /// **'সপ্তাহ শুরুর দিন'**
  String get choresSettingsWeekStart;

  /// No description provided for @choresSettingsShowProjected.
  ///
  /// In bn, this message translates to:
  /// **'সম্ভাব্য কাজ দেখান'**
  String get choresSettingsShowProjected;

  /// No description provided for @choresSettingsShowProjectedSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'ক্যালেন্ডারে আগামী মাসের অনুমানকৃত কাজ দেখাবে'**
  String get choresSettingsShowProjectedSubtitle;

  /// No description provided for @choresSettingsProjectedMonths.
  ///
  /// In bn, this message translates to:
  /// **'আগামী পূর্বাভাস: {months} মাস'**
  String choresSettingsProjectedMonths(String months);

  /// No description provided for @choresCalendarViewAgenda.
  ///
  /// In bn, this message translates to:
  /// **'তালিকা'**
  String get choresCalendarViewAgenda;

  /// No description provided for @choresCalendarViewMonth.
  ///
  /// In bn, this message translates to:
  /// **'মাসিক'**
  String get choresCalendarViewMonth;

  /// No description provided for @choresCalendarViewWeek.
  ///
  /// In bn, this message translates to:
  /// **'সাপ্তাহিক'**
  String get choresCalendarViewWeek;

  /// No description provided for @choresCalendarScopeMine.
  ///
  /// In bn, this message translates to:
  /// **'আমার কাজ'**
  String get choresCalendarScopeMine;

  /// No description provided for @choresCalendarScopeAll.
  ///
  /// In bn, this message translates to:
  /// **'সবার কাজ'**
  String get choresCalendarScopeAll;

  /// No description provided for @choresSettingsHorizon.
  ///
  /// In bn, this message translates to:
  /// **'কাজ তৈরির সময়কাল: {days} দিন'**
  String choresSettingsHorizon(String days);

  /// No description provided for @choresSettingsHorizonSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'কত দিন আগে থেকে স্বয়ংক্রিয়ভাবে কাজ তৈরি হবে (১৪-৯০ দিন)'**
  String get choresSettingsHorizonSubtitle;

  /// No description provided for @choresSettingsOverdueGrace.
  ///
  /// In bn, this message translates to:
  /// **'গ্রেস পিরিয়ড: {minutes} মিনিট'**
  String choresSettingsOverdueGrace(String minutes);

  /// No description provided for @choresSettingsOverdueGraceSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'নির্ধারিত সময়ের কত মিনিট পর কাজ বিলম্বিত ধরা হবে'**
  String get choresSettingsOverdueGraceSubtitle;

  /// No description provided for @choresSettingsGroupsTitle.
  ///
  /// In bn, this message translates to:
  /// **'কাজের গ্রুপসমূহ'**
  String get choresSettingsGroupsTitle;

  /// No description provided for @choresSettingsPresetsTitle.
  ///
  /// In bn, this message translates to:
  /// **'সময়ের প্রিসেটসমূহ'**
  String get choresSettingsPresetsTitle;

  /// No description provided for @choresSettingsAbsenceReasonsTitle.
  ///
  /// In bn, this message translates to:
  /// **'অনুপস্থিতির কারণসমূহ'**
  String get choresSettingsAbsenceReasonsTitle;

  /// No description provided for @choresGroupDeactivateWarningTitle.
  ///
  /// In bn, this message translates to:
  /// **'গ্রুপটি বন্ধ করবেন?'**
  String get choresGroupDeactivateWarningTitle;

  /// No description provided for @choresGroupDeactivateWarningMessage.
  ///
  /// In bn, this message translates to:
  /// **'এই গ্রুপের অধীনে কিছু সক্রিয় কাজ রয়েছে। এটি বন্ধ করলে নতুন কাজে এটি বেছে নেওয়া যাবে না, তবে চলমান কাজে কোনো প্রভাব পড়বে না। চালিয়ে যেতে চান?'**
  String get choresGroupDeactivateWarningMessage;

  /// No description provided for @choresGroupColor.
  ///
  /// In bn, this message translates to:
  /// **'রং'**
  String get choresGroupColor;

  /// No description provided for @choresGroupIcon.
  ///
  /// In bn, this message translates to:
  /// **'আইকন'**
  String get choresGroupIcon;

  /// No description provided for @choresGroupAddTitle.
  ///
  /// In bn, this message translates to:
  /// **'নতুন গ্রুপ যোগ করুন'**
  String get choresGroupAddTitle;

  /// No description provided for @choresGroupEditTitle.
  ///
  /// In bn, this message translates to:
  /// **'গ্রুপ সম্পাদনা'**
  String get choresGroupEditTitle;

  /// No description provided for @choresPresetAddTitle.
  ///
  /// In bn, this message translates to:
  /// **'নতুন সময় প্রিসেট যোগ করুন'**
  String get choresPresetAddTitle;

  /// No description provided for @choresPresetEditTitle.
  ///
  /// In bn, this message translates to:
  /// **'সময় প্রিসেট সম্পাদনা'**
  String get choresPresetEditTitle;

  /// No description provided for @choresPresetTime.
  ///
  /// In bn, this message translates to:
  /// **'দিনের সময়'**
  String get choresPresetTime;

  /// No description provided for @choresSettingsAbsencePolicyTitle.
  ///
  /// In bn, this message translates to:
  /// **'অনুপস্থিতির নীতিমালা'**
  String get choresSettingsAbsencePolicyTitle;

  /// No description provided for @choresPolicyAskCoverTitle.
  ///
  /// In bn, this message translates to:
  /// **'কভারের অনুরোধ (পলিসি A)'**
  String get choresPolicyAskCoverTitle;

  /// No description provided for @choresPolicyAskCoverDesc.
  ///
  /// In bn, this message translates to:
  /// **'অনুপস্থিত সদস্য নিজে পরিবারের অন্য কাউকে তার কাজটি করার অনুরোধ জানান।'**
  String get choresPolicyAskCoverDesc;

  /// No description provided for @choresPolicyAskCoverExample.
  ///
  /// In bn, this message translates to:
  /// **'উদাহরণ: জরুরি কাজে বাইরে থাকলে অন্য সদস্যকে কাজটি করে দিতে অনুরোধ পাঠানো।'**
  String get choresPolicyAskCoverExample;

  /// No description provided for @choresPolicyAutoCoverTitle.
  ///
  /// In bn, this message translates to:
  /// **'স্বয়ংক্রিয় কভার প্রস্তাব (পলিসি B)'**
  String get choresPolicyAutoCoverTitle;

  /// No description provided for @choresPolicyAutoCoverDesc.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাপ উপযুক্ত সদস্যকে স্বয়ংক্রিয়ভাবে বেছে নিয়ে কভারের প্রস্তাব পাঠায় (তিনি গ্রহণ বা প্রত্যাখ্যান করতে পারেন)।'**
  String get choresPolicyAutoCoverDesc;

  /// No description provided for @choresPolicyAutoCoverExample.
  ///
  /// In bn, this message translates to:
  /// **'উদাহরণ: ঘূর্ণায়মান তালিকায় পরবর্তী ফ্রি সদস্যের কাছে অনুরোধ যাবে।'**
  String get choresPolicyAutoCoverExample;

  /// No description provided for @choresPolicySkipTitle.
  ///
  /// In bn, this message translates to:
  /// **'কাজ বাদ দেওয়া (পলিসি C)'**
  String get choresPolicySkipTitle;

  /// No description provided for @choresPolicySkipDesc.
  ///
  /// In bn, this message translates to:
  /// **'অনুপস্থিতির কারণে কাজটি সেদিনের জন্য বাদ দেওয়া হয় এবং স্কোরিংয়ে নিরপেক্ষ থাকে।'**
  String get choresPolicySkipDesc;

  /// No description provided for @choresPolicySkipExample.
  ///
  /// In bn, this message translates to:
  /// **'উদাহরণ: বিশেষ জরুরি না হলে কাজটি পরবর্তী শিডিউল পর্যন্ত অপেক্ষা করবে।'**
  String get choresPolicySkipExample;

  /// No description provided for @choresSettingsSwapsEnabled.
  ///
  /// In bn, this message translates to:
  /// **'কাজের অদলবদল (Swap) চালু রাখুন'**
  String get choresSettingsSwapsEnabled;

  /// No description provided for @choresSettingsSwapsEnabledSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'সদস্যরা নিজেদের মধ্যে কাজ অদলবদল করতে পারবেন'**
  String get choresSettingsSwapsEnabledSubtitle;

  /// No description provided for @choresSettingsSwapBuffer.
  ///
  /// In bn, this message translates to:
  /// **'অদলবদল অনুরোধের মেয়াদ: {minutes} মিনিট'**
  String choresSettingsSwapBuffer(String minutes);

  /// No description provided for @choresSettingsSwapBufferSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'অনুরোধ পাঠানোর পর কতক্ষণ পর্যন্ত এটি কার্যকর থাকবে'**
  String get choresSettingsSwapBufferSubtitle;

  /// No description provided for @choresSettingsAbsenceApproval.
  ///
  /// In bn, this message translates to:
  /// **'অনুপস্থিতিতে অনুমোদনের প্রয়োজন'**
  String get choresSettingsAbsenceApproval;

  /// No description provided for @choresSettingsAbsenceApprovalSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'অনুপস্থিতির অনুরোধ ম্যানেজারের সিদ্ধান্তের জন্য অপেক্ষা করবে'**
  String get choresSettingsAbsenceApprovalSubtitle;

  /// No description provided for @choresSettingsWorkloadVisible.
  ///
  /// In bn, this message translates to:
  /// **'কাজের বণ্টন সবার জন্য উন্মুক্ত'**
  String get choresSettingsWorkloadVisible;

  /// No description provided for @choresSettingsWorkloadVisibleSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের সব সক্রিয় সদস্য কাজের সমবণ্টনের হিসাব দেখতে পাবেন'**
  String get choresSettingsWorkloadVisibleSubtitle;

  /// No description provided for @choresSettingsCompleteForOthers.
  ///
  /// In bn, this message translates to:
  /// **'অন্যের কাজ সম্পন্ন করার অনুমতি'**
  String get choresSettingsCompleteForOthers;

  /// No description provided for @choresSettingsCompleteForOthersSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'যেকোনো সদস্য অন্যের কাজ সম্পন্ন করতে পারবেন (এডমিন কন্ট্রোল)'**
  String get choresSettingsCompleteForOthersSubtitle;

  /// No description provided for @choresSettingsHouseRulesEditor.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের নিয়মাবলী (মার্কডাউন)'**
  String get choresSettingsHouseRulesEditor;

  /// No description provided for @choresSettingsHouseRulesPreview.
  ///
  /// In bn, this message translates to:
  /// **'প্রিভিউ'**
  String get choresSettingsHouseRulesPreview;

  /// No description provided for @choresSettingsHouseRulesHelp.
  ///
  /// In bn, this message translates to:
  /// **'শিরোনাম: # শিরোনাম, বুলেট: - লেখা, গাঢ়: **লেখা**'**
  String get choresSettingsHouseRulesHelp;

  /// No description provided for @choresSettingsHouseRulesEmpty.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের কোনো বিশেষ নিয়ম এখনও যোগ করা হয়নি।'**
  String get choresSettingsHouseRulesEmpty;

  /// No description provided for @choresSettingsSave.
  ///
  /// In bn, this message translates to:
  /// **'সেটিংস সংরক্ষণ করুন'**
  String get choresSettingsSave;

  /// No description provided for @choresSettingsResetSection.
  ///
  /// In bn, this message translates to:
  /// **'সেকশন রিসেট করুন'**
  String get choresSettingsResetSection;

  /// No description provided for @choresSettingsResetConfirmTitle.
  ///
  /// In bn, this message translates to:
  /// **'ডিফল্টে ফিরিয়ে নিতে চান?'**
  String get choresSettingsResetConfirmTitle;

  /// No description provided for @choresSettingsResetConfirmMessage.
  ///
  /// In bn, this message translates to:
  /// **'এই সেকশনের সব পরিবর্তন ডিফল্ট অবস্থায় ফিরে যাবে। আপনার কোনো কাজ বা টেমপ্লেট মুছে যাবে না।'**
  String get choresSettingsResetConfirmMessage;

  /// No description provided for @choresSettingsDiscardTitle.
  ///
  /// In bn, this message translates to:
  /// **'পরিবর্তন বাতিল করবেন?'**
  String get choresSettingsDiscardTitle;

  /// No description provided for @choresSettingsDiscardMessage.
  ///
  /// In bn, this message translates to:
  /// **'আপনার কিছু পরিবর্তন সংরক্ষণ করা হয়নি। আপনি কি পাতা ত্যাগ করতে চান?'**
  String get choresSettingsDiscardMessage;

  /// No description provided for @choresSettingsSaved.
  ///
  /// In bn, this message translates to:
  /// **'কাজের সেটিংস সংরক্ষিত হয়েছে'**
  String get choresSettingsSaved;

  /// No description provided for @choresSettingsNotAllowed.
  ///
  /// In bn, this message translates to:
  /// **'কাজের সেটিংস পরিচালনা করার অনুমতি আপনার নেই।'**
  String get choresSettingsNotAllowed;

  /// No description provided for @choresSettingsPickIcon.
  ///
  /// In bn, this message translates to:
  /// **'আইকন বেছে নিন'**
  String get choresSettingsPickIcon;

  /// No description provided for @dutyGroupsTitle.
  ///
  /// In bn, this message translates to:
  /// **'ডিউটি গ্রুপ'**
  String get dutyGroupsTitle;

  /// No description provided for @dutyGroupsSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'কে ডিউটিতে আছেন আর রোটা কেমন'**
  String get dutyGroupsSubtitle;

  /// No description provided for @dutyGroupsEmptyTitle.
  ///
  /// In bn, this message translates to:
  /// **'এখনও কোনো ডিউটি গ্রুপ নেই'**
  String get dutyGroupsEmptyTitle;

  /// No description provided for @dutyGroupsEmptyMessage.
  ///
  /// In bn, this message translates to:
  /// **'একটি ডিউটি গ্রুপ কয়েকজনের মধ্যে একসেট কাজ পালা করে ভাগ করে দেয়।'**
  String get dutyGroupsEmptyMessage;

  /// No description provided for @dutyGroupNew.
  ///
  /// In bn, this message translates to:
  /// **'নতুন ডিউটি গ্রুপ'**
  String get dutyGroupNew;

  /// No description provided for @dutyGroupsTruncated.
  ///
  /// In bn, this message translates to:
  /// **'প্রথম {count}টি গ্রুপ দেখানো হচ্ছে।'**
  String dutyGroupsTruncated(String count);

  /// No description provided for @dutyGroupOnDutyNow.
  ///
  /// In bn, this message translates to:
  /// **'এখন ডিউটিতে: {name}'**
  String dutyGroupOnDutyNow(String name);

  /// No description provided for @dutyGroupNobodyOnDuty.
  ///
  /// In bn, this message translates to:
  /// **'এখনও কেউ ডিউটিতে নেই'**
  String get dutyGroupNobodyOnDuty;

  /// No description provided for @dutyGroupChoreCount.
  ///
  /// In bn, this message translates to:
  /// **'কাজ: {count}'**
  String dutyGroupChoreCount(String count);

  /// No description provided for @dutyGroupMemberCount.
  ///
  /// In bn, this message translates to:
  /// **'সদস্য: {count}'**
  String dutyGroupMemberCount(String count);

  /// No description provided for @dutyGroupSwitchedOff.
  ///
  /// In bn, this message translates to:
  /// **'বন্ধ আছে'**
  String get dutyGroupSwitchedOff;

  /// No description provided for @dutyGroupEditTitle.
  ///
  /// In bn, this message translates to:
  /// **'ডিউটি গ্রুপ সম্পাদনা'**
  String get dutyGroupEditTitle;

  /// No description provided for @dutyGroupNameBn.
  ///
  /// In bn, this message translates to:
  /// **'নাম (বাংলা)'**
  String get dutyGroupNameBn;

  /// No description provided for @dutyGroupNameEn.
  ///
  /// In bn, this message translates to:
  /// **'নাম (ইংরেজি, ঐচ্ছিক)'**
  String get dutyGroupNameEn;

  /// No description provided for @dutyGroupActive.
  ///
  /// In bn, this message translates to:
  /// **'সক্রিয়'**
  String get dutyGroupActive;

  /// No description provided for @dutyGroupActiveSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'বন্ধ করা গ্রুপ ইতিহাসে থেকে যায়।'**
  String get dutyGroupActiveSubtitle;

  /// No description provided for @dutyGroupSave.
  ///
  /// In bn, this message translates to:
  /// **'গ্রুপ সংরক্ষণ করুন'**
  String get dutyGroupSave;

  /// No description provided for @dutyGroupSaved.
  ///
  /// In bn, this message translates to:
  /// **'গ্রুপ সংরক্ষিত হয়েছে'**
  String get dutyGroupSaved;

  /// No description provided for @dutyGroupReadOnly.
  ///
  /// In bn, this message translates to:
  /// **'যারা কাজ পরিচালনা করেন শুধু তারাই ডিউটি গ্রুপ বদলাতে পারেন।'**
  String get dutyGroupReadOnly;

  /// No description provided for @dutyGroupNotFound.
  ///
  /// In bn, this message translates to:
  /// **'এই ডিউটি গ্রুপটি আর নেই।'**
  String get dutyGroupNotFound;

  /// No description provided for @dutyGroupDeactivateTitle.
  ///
  /// In bn, this message translates to:
  /// **'এই গ্রুপ বন্ধ করবেন?'**
  String get dutyGroupDeactivateTitle;

  /// No description provided for @dutyGroupDeactivateMessage.
  ///
  /// In bn, this message translates to:
  /// **'কিছু কাজ এখনও এই গ্রুপ ব্যবহার করছে। আপনি না সরানো পর্যন্ত সেগুলো এটিকেই দেখাবে।'**
  String get dutyGroupDeactivateMessage;

  /// No description provided for @dutyGroupDeactivateConfirm.
  ///
  /// In bn, this message translates to:
  /// **'বন্ধ করুন'**
  String get dutyGroupDeactivateConfirm;

  /// No description provided for @dutyGroupDelete.
  ///
  /// In bn, this message translates to:
  /// **'গ্রুপ মুছুন'**
  String get dutyGroupDelete;

  /// No description provided for @dutyGroupDeleteTitle.
  ///
  /// In bn, this message translates to:
  /// **'এই ডিউটি গ্রুপটি মুছবেন?'**
  String get dutyGroupDeleteTitle;

  /// No description provided for @dutyGroupDeleteMessage.
  ///
  /// In bn, this message translates to:
  /// **'{name} তালিকা থেকে সরে যাবে এবং এর পালা বন্ধ হবে। কাজগুলোর ইতিহাস রয়ে যাবে; আবার পালা চালাতে অন্য গ্রুপে সরিয়ে নিন।'**
  String dutyGroupDeleteMessage(String name);

  /// No description provided for @dutyGroupDeleted.
  ///
  /// In bn, this message translates to:
  /// **'গ্রুপ মুছে ফেলা হয়েছে'**
  String get dutyGroupDeleted;

  /// No description provided for @dutyGroupsShowSwitchedOff.
  ///
  /// In bn, this message translates to:
  /// **'বন্ধ করা গ্রুপ দেখান'**
  String get dutyGroupsShowSwitchedOff;

  /// No description provided for @dutyGroupsSwitchedOffCount.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি গ্রুপ বন্ধ আছে'**
  String dutyGroupsSwitchedOffCount(int count);

  /// No description provided for @dutyGroupsNoneActive.
  ///
  /// In bn, this message translates to:
  /// **'সব গ্রুপ বন্ধ করা আছে।'**
  String get dutyGroupsNoneActive;

  /// No description provided for @dutyRotationMembers.
  ///
  /// In bn, this message translates to:
  /// **'পালার ক্রমে সদস্য'**
  String get dutyRotationMembers;

  /// No description provided for @dutyRotationNeedTwo.
  ///
  /// In bn, this message translates to:
  /// **'কমপক্ষে দুইজন সদস্য যোগ করুন।'**
  String get dutyRotationNeedTwo;

  /// No description provided for @dutyRotationAddMember.
  ///
  /// In bn, this message translates to:
  /// **'সদস্য যোগ করুন'**
  String get dutyRotationAddMember;

  /// No description provided for @dutyRotationNoCandidates.
  ///
  /// In bn, this message translates to:
  /// **'সব সক্রিয় সদস্য ইতিমধ্যে গ্রুপে আছেন।'**
  String get dutyRotationNoCandidates;

  /// No description provided for @dutyRotationRemoveMember.
  ///
  /// In bn, this message translates to:
  /// **'{name}-কে সরান'**
  String dutyRotationRemoveMember(String name);

  /// No description provided for @dutyRotationMoveMember.
  ///
  /// In bn, this message translates to:
  /// **'{name}-কে সরাতে টানুন'**
  String dutyRotationMoveMember(String name);

  /// No description provided for @dutyRotationCycleUnit.
  ///
  /// In bn, this message translates to:
  /// **'কতদিন পরপর পালা বদলাবে'**
  String get dutyRotationCycleUnit;

  /// No description provided for @dutyRotationUnitDay.
  ///
  /// In bn, this message translates to:
  /// **'দিন'**
  String get dutyRotationUnitDay;

  /// No description provided for @dutyRotationUnitWeek.
  ///
  /// In bn, this message translates to:
  /// **'সপ্তাহ'**
  String get dutyRotationUnitWeek;

  /// No description provided for @dutyRotationUnitMonth.
  ///
  /// In bn, this message translates to:
  /// **'মাস'**
  String get dutyRotationUnitMonth;

  /// No description provided for @dutyRotationUnitOccurrence.
  ///
  /// In bn, this message translates to:
  /// **'কাজের দিন'**
  String get dutyRotationUnitOccurrence;

  /// No description provided for @dutyRotationWeekStart.
  ///
  /// In bn, this message translates to:
  /// **'সপ্তাহ শুরু হয় {day}'**
  String dutyRotationWeekStart(String day);

  /// No description provided for @dutyRotationStartsWith.
  ///
  /// In bn, this message translates to:
  /// **'প্রথম পালা'**
  String get dutyRotationStartsWith;

  /// No description provided for @dutyRotationStartsOn.
  ///
  /// In bn, this message translates to:
  /// **'শুরুর তারিখ'**
  String get dutyRotationStartsOn;

  /// No description provided for @dutyRotationPickDate.
  ///
  /// In bn, this message translates to:
  /// **'তারিখ বেছে নিন'**
  String get dutyRotationPickDate;

  /// No description provided for @dutyRotaTitle.
  ///
  /// In bn, this message translates to:
  /// **'পরের পালাগুলো'**
  String get dutyRotaTitle;

  /// No description provided for @dutyRotaNeedsSchedule.
  ///
  /// In bn, this message translates to:
  /// **'এই রোটা কাজের দিন গুনে চলে, তাই দেখাতে একটি সময়সূচি লাগবে।'**
  String get dutyRotaNeedsSchedule;

  /// No description provided for @dutyRotaNobody.
  ///
  /// In bn, this message translates to:
  /// **'এখনও কেউ নেই'**
  String get dutyRotaNobody;

  /// No description provided for @dutyRotaRange.
  ///
  /// In bn, this message translates to:
  /// **'{start} থেকে {end}'**
  String dutyRotaRange(String start, String end);

  /// No description provided for @dutyRotaCellLabel.
  ///
  /// In bn, this message translates to:
  /// **'{range}: {name}'**
  String dutyRotaCellLabel(String range, String name);

  /// No description provided for @dutyRotaCellLabelCover.
  ///
  /// In bn, this message translates to:
  /// **'{range}: {name}, কভার লাগবে'**
  String dutyRotaCellLabelCover(String range, String name);

  /// No description provided for @dutyNeedsCover.
  ///
  /// In bn, this message translates to:
  /// **'কভার লাগবে'**
  String get dutyNeedsCover;

  /// No description provided for @dutyMemberGone.
  ///
  /// In bn, this message translates to:
  /// **'আর সক্রিয় নন, তাই পালায় কভার লাগবে'**
  String get dutyMemberGone;

  /// No description provided for @dutyRosterTitle.
  ///
  /// In bn, this message translates to:
  /// **'বর্তমান সদস্য'**
  String get dutyRosterTitle;

  /// No description provided for @dutyChangeTitle.
  ///
  /// In bn, this message translates to:
  /// **'রোটেশন বদলান'**
  String get dutyChangeTitle;

  /// No description provided for @dutyChangeAdd.
  ///
  /// In bn, this message translates to:
  /// **'সদস্য যোগ করুন'**
  String get dutyChangeAdd;

  /// No description provided for @dutyChangeRemove.
  ///
  /// In bn, this message translates to:
  /// **'সদস্য সরান'**
  String get dutyChangeRemove;

  /// No description provided for @dutyChangeReorder.
  ///
  /// In bn, this message translates to:
  /// **'ক্রম বদলান'**
  String get dutyChangeReorder;

  /// No description provided for @dutyChangeCycle.
  ///
  /// In bn, this message translates to:
  /// **'কত পরপর বদলাবে'**
  String get dutyChangeCycle;

  /// No description provided for @dutyChangeFrom.
  ///
  /// In bn, this message translates to:
  /// **'কার্যকর হবে'**
  String get dutyChangeFrom;

  /// No description provided for @dutyChangeNothingBefore.
  ///
  /// In bn, this message translates to:
  /// **'{date}-এর আগের কিছুই বদলাবে না।'**
  String dutyChangeNothingBefore(String date);

  /// No description provided for @dutyChangeApply.
  ///
  /// In bn, this message translates to:
  /// **'পরিবর্তন প্রয়োগ করুন'**
  String get dutyChangeApply;

  /// No description provided for @dutyChangeAfter.
  ///
  /// In bn, this message translates to:
  /// **'পরিবর্তনের পর'**
  String get dutyChangeAfter;

  /// No description provided for @dutyChangePickMember.
  ///
  /// In bn, this message translates to:
  /// **'একজন সদস্য বেছে নিন'**
  String get dutyChangePickMember;

  /// No description provided for @dutyChangePickCycle.
  ///
  /// In bn, this message translates to:
  /// **'দিন, সপ্তাহ বা মাস বেছে নিন'**
  String get dutyChangePickCycle;

  /// No description provided for @dutyPlanFailed.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষিত হয়েছে, কিন্তু তারিখ সাজাতে ব্যর্থ হয়েছে।'**
  String get dutyPlanFailed;

  /// No description provided for @dutyPlanning.
  ///
  /// In bn, this message translates to:
  /// **'তারিখ সাজানো হচ্ছে…'**
  String get dutyPlanning;

  /// No description provided for @dutyChoresTitle.
  ///
  /// In bn, this message translates to:
  /// **'এই গ্রুপের কাজ'**
  String get dutyChoresTitle;

  /// No description provided for @dutyChoresEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এই গ্রুপে এখনও কোনো কাজ নেই।'**
  String get dutyChoresEmpty;

  /// No description provided for @dutyChoreAdd.
  ///
  /// In bn, this message translates to:
  /// **'এই গ্রুপে কাজ যোগ করুন'**
  String get dutyChoreAdd;

  /// No description provided for @dutyChoreAddNone.
  ///
  /// In bn, this message translates to:
  /// **'সব কাজ ইতিমধ্যে এই গ্রুপে আছে।'**
  String get dutyChoreAddNone;

  /// No description provided for @dutyChoreAddNote.
  ///
  /// In bn, this message translates to:
  /// **'যে আসন্ন কাজ শুরু হয়নি তা এই রোটায় চলে আসবে।'**
  String get dutyChoreAddNote;

  /// No description provided for @dutyChoreAdded.
  ///
  /// In bn, this message translates to:
  /// **'কাজটি গ্রুপে যোগ হয়েছে'**
  String get dutyChoreAdded;

  /// No description provided for @choresSettingsNeedsInternet.
  ///
  /// In bn, this message translates to:
  /// **'কাজের সেটিংস সংরক্ষণ করতে ইন্টারনেট সংযোগ লাগবে। আপনার পরিবর্তনগুলো এখানেই থাকছে, অনলাইন হলে আবার চেষ্টা করুন।'**
  String get choresSettingsNeedsInternet;

  /// No description provided for @choresSettingsResetConfirmAction.
  ///
  /// In bn, this message translates to:
  /// **'রিসেট করুন'**
  String get choresSettingsResetConfirmAction;

  /// No description provided for @choreTemplatesTitle.
  ///
  /// In bn, this message translates to:
  /// **'কাজের টেমপ্লেট'**
  String get choreTemplatesTitle;

  /// No description provided for @choreTemplatesSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের কাজ তৈরি ও সম্পাদনা করুন'**
  String get choreTemplatesSubtitle;

  /// No description provided for @choreTemplatesNotAllowed.
  ///
  /// In bn, this message translates to:
  /// **'শুধু অ্যাডমিন ও মডারেটর কাজ পরিচালনা করতে পারেন।'**
  String get choreTemplatesNotAllowed;

  /// No description provided for @choreListNew.
  ///
  /// In bn, this message translates to:
  /// **'নতুন কাজ'**
  String get choreListNew;

  /// No description provided for @choreListSearch.
  ///
  /// In bn, this message translates to:
  /// **'কাজ খুঁজুন'**
  String get choreListSearch;

  /// No description provided for @choreListEmptyTitle.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো কাজ নেই'**
  String get choreListEmptyTitle;

  /// No description provided for @choreListEmptyMessage.
  ///
  /// In bn, this message translates to:
  /// **'নতুন কাজ বোতাম দিয়ে প্রথম কাজটি তৈরি করুন।'**
  String get choreListEmptyMessage;

  /// No description provided for @choreListEmptyFiltered.
  ///
  /// In bn, this message translates to:
  /// **'কোনো কাজ মেলেনি'**
  String get choreListEmptyFiltered;

  /// No description provided for @choreListTruncated.
  ///
  /// In bn, this message translates to:
  /// **'শুধু প্রথম দিকের কাজগুলো দেখানো হচ্ছে। বাকিগুলো দেখতে অপ্রয়োজনীয় কাজ আর্কাইভ করুন।'**
  String get choreListTruncated;

  /// No description provided for @choreListUpdated.
  ///
  /// In bn, this message translates to:
  /// **'হালনাগাদ হয়েছে'**
  String get choreListUpdated;

  /// No description provided for @choreListInvalidSchedule.
  ///
  /// In bn, this message translates to:
  /// **'সময়সূচি পড়া যাচ্ছে না'**
  String get choreListInvalidSchedule;

  /// No description provided for @choreListNext.
  ///
  /// In bn, this message translates to:
  /// **'পরবর্তী: {date}'**
  String choreListNext(String date);

  /// No description provided for @choreStatusActive.
  ///
  /// In bn, this message translates to:
  /// **'সক্রিয়'**
  String get choreStatusActive;

  /// No description provided for @choreStatusPaused.
  ///
  /// In bn, this message translates to:
  /// **'বিরতিতে'**
  String get choreStatusPaused;

  /// No description provided for @choreStatusArchived.
  ///
  /// In bn, this message translates to:
  /// **'আর্কাইভ করা'**
  String get choreStatusArchived;

  /// No description provided for @choreActionPause.
  ///
  /// In bn, this message translates to:
  /// **'বিরতি দিন'**
  String get choreActionPause;

  /// No description provided for @choreActionResume.
  ///
  /// In bn, this message translates to:
  /// **'আবার চালু করুন'**
  String get choreActionResume;

  /// No description provided for @choreActionDuplicate.
  ///
  /// In bn, this message translates to:
  /// **'কপি করুন'**
  String get choreActionDuplicate;

  /// No description provided for @choreActionArchive.
  ///
  /// In bn, this message translates to:
  /// **'আর্কাইভ করুন'**
  String get choreActionArchive;

  /// No description provided for @choreArchiveConfirmTitle.
  ///
  /// In bn, this message translates to:
  /// **'এই কাজটি আর্কাইভ করবেন?'**
  String get choreArchiveConfirmTitle;

  /// No description provided for @choreArchiveConfirmMessage.
  ///
  /// In bn, this message translates to:
  /// **'এর নতুন দিন আর তৈরি হবে না। আগের দিন ও ইতিহাস থাকবে।'**
  String get choreArchiveConfirmMessage;

  /// No description provided for @choreDuplicateSuffix.
  ///
  /// In bn, this message translates to:
  /// **' (কপি)'**
  String get choreDuplicateSuffix;

  /// No description provided for @choreDuplicated.
  ///
  /// In bn, this message translates to:
  /// **'কাজটি কপি হয়েছে'**
  String get choreDuplicated;

  /// No description provided for @choreSlotCount.
  ///
  /// In bn, this message translates to:
  /// **'দিনে {count} বার'**
  String choreSlotCount(String count);

  /// No description provided for @choreStrategyRotation.
  ///
  /// In bn, this message translates to:
  /// **'পালাক্রমে'**
  String get choreStrategyRotation;

  /// No description provided for @choreStrategyFixed.
  ///
  /// In bn, this message translates to:
  /// **'নির্দিষ্ট একজন'**
  String get choreStrategyFixed;

  /// No description provided for @choreStrategyManual.
  ///
  /// In bn, this message translates to:
  /// **'হাতে বণ্টন'**
  String get choreStrategyManual;

  /// No description provided for @choreEditorTitleNew.
  ///
  /// In bn, this message translates to:
  /// **'নতুন কাজ'**
  String get choreEditorTitleNew;

  /// No description provided for @choreEditorTitleEdit.
  ///
  /// In bn, this message translates to:
  /// **'কাজ সম্পাদনা'**
  String get choreEditorTitleEdit;

  /// No description provided for @choreEditorNotFound.
  ///
  /// In bn, this message translates to:
  /// **'কাজটি পাওয়া যায়নি'**
  String get choreEditorNotFound;

  /// No description provided for @choreEditorArchivedNote.
  ///
  /// In bn, this message translates to:
  /// **'এই কাজটি আর্কাইভ করা। দেখা যাবে, কিন্তু বদলানো যাবে না।'**
  String get choreEditorArchivedNote;

  /// No description provided for @choreEditorPlanningFailed.
  ///
  /// In bn, this message translates to:
  /// **'কাজটি সংরক্ষিত হয়েছে, কিন্তু দিন সাজাতে সমস্যা হয়েছে। শেষ করতে আবার চেষ্টা করুন।'**
  String get choreEditorPlanningFailed;

  /// No description provided for @choreEditorSectionBasics.
  ///
  /// In bn, this message translates to:
  /// **'মূল তথ্য'**
  String get choreEditorSectionBasics;

  /// No description provided for @choreEditorSectionSchedule.
  ///
  /// In bn, this message translates to:
  /// **'সময়সূচি'**
  String get choreEditorSectionSchedule;

  /// No description provided for @choreEditorSectionWho.
  ///
  /// In bn, this message translates to:
  /// **'কে করবে'**
  String get choreEditorSectionWho;

  /// No description provided for @choreEditorSectionSteps.
  ///
  /// In bn, this message translates to:
  /// **'ধাপ'**
  String get choreEditorSectionSteps;

  /// No description provided for @choreEditorSectionInstructions.
  ///
  /// In bn, this message translates to:
  /// **'নির্দেশনা'**
  String get choreEditorSectionInstructions;

  /// No description provided for @choreEditorSectionOptions.
  ///
  /// In bn, this message translates to:
  /// **'অন্যান্য'**
  String get choreEditorSectionOptions;

  /// Progress label of the multi-step chore editor.
  ///
  /// In bn, this message translates to:
  /// **'ধাপ {current}/{total}'**
  String choreEditorStepOf(String current, String total);

  /// No description provided for @choreEditorNameBn.
  ///
  /// In bn, this message translates to:
  /// **'নাম (বাংলা)'**
  String get choreEditorNameBn;

  /// No description provided for @choreEditorNameEn.
  ///
  /// In bn, this message translates to:
  /// **'নাম (ইংরেজি, ঐচ্ছিক)'**
  String get choreEditorNameEn;

  /// No description provided for @choreEditorGroup.
  ///
  /// In bn, this message translates to:
  /// **'গ্রুপ'**
  String get choreEditorGroup;

  /// No description provided for @choreEditorIcon.
  ///
  /// In bn, this message translates to:
  /// **'আইকন'**
  String get choreEditorIcon;

  /// Heading above the quick icon row.
  ///
  /// In bn, this message translates to:
  /// **'পূর্বে ব্যবহৃত আইকন'**
  String get choreIconRecent;

  /// Button that opens the searchable icon catalog.
  ///
  /// In bn, this message translates to:
  /// **'আরও আইকন'**
  String get choreIconMore;

  /// No description provided for @choreIconPickTitle.
  ///
  /// In bn, this message translates to:
  /// **'আইকন বেছে নিন'**
  String get choreIconPickTitle;

  /// No description provided for @choreIconSearchHint.
  ///
  /// In bn, this message translates to:
  /// **'আইকন খুঁজুন'**
  String get choreIconSearchHint;

  /// No description provided for @choreIconNoMatches.
  ///
  /// In bn, this message translates to:
  /// **'এই নামে কোনো আইকন পাওয়া যায়নি।'**
  String get choreIconNoMatches;

  /// No description provided for @choreEditorColor.
  ///
  /// In bn, this message translates to:
  /// **'রঙ'**
  String get choreEditorColor;

  /// No description provided for @choreEditorRepeat.
  ///
  /// In bn, this message translates to:
  /// **'পুনরাবৃত্তি'**
  String get choreEditorRepeat;

  /// No description provided for @choreEditorRepeatChange.
  ///
  /// In bn, this message translates to:
  /// **'পুনরাবৃত্তি বদলান'**
  String get choreEditorRepeatChange;

  /// No description provided for @choreEditorNextDates.
  ///
  /// In bn, this message translates to:
  /// **'পরবর্তী তারিখ'**
  String get choreEditorNextDates;

  /// No description provided for @choreEditorNoNextDates.
  ///
  /// In bn, this message translates to:
  /// **'আর কোনো তারিখ নেই'**
  String get choreEditorNoNextDates;

  /// No description provided for @choreEditorStartDate.
  ///
  /// In bn, this message translates to:
  /// **'শুরু: {date}'**
  String choreEditorStartDate(String date);

  /// No description provided for @choreEditorEndDate.
  ///
  /// In bn, this message translates to:
  /// **'শেষ: {date}'**
  String choreEditorEndDate(String date);

  /// No description provided for @choreEditorEndDateNone.
  ///
  /// In bn, this message translates to:
  /// **'শেষের তারিখ নেই'**
  String get choreEditorEndDateNone;

  /// No description provided for @choreEditorEndDateClear.
  ///
  /// In bn, this message translates to:
  /// **'শেষের তারিখ সরান'**
  String get choreEditorEndDateClear;

  /// No description provided for @choreEditorTimes.
  ///
  /// In bn, this message translates to:
  /// **'দিনের সময়'**
  String get choreEditorTimes;

  /// No description provided for @choreEditorEstimatedMinutes.
  ///
  /// In bn, this message translates to:
  /// **'আনুমানিক সময় (মিনিট, ঐচ্ছিক)'**
  String get choreEditorEstimatedMinutes;

  /// No description provided for @choreEditorDifficulty.
  ///
  /// In bn, this message translates to:
  /// **'কাঠিন্য'**
  String get choreEditorDifficulty;

  /// No description provided for @choreDifficultyEasy.
  ///
  /// In bn, this message translates to:
  /// **'সহজ'**
  String get choreDifficultyEasy;

  /// No description provided for @choreDifficultyNormal.
  ///
  /// In bn, this message translates to:
  /// **'মাঝারি'**
  String get choreDifficultyNormal;

  /// No description provided for @choreDifficultyHard.
  ///
  /// In bn, this message translates to:
  /// **'কঠিন'**
  String get choreDifficultyHard;

  /// No description provided for @choreEditorVerification.
  ///
  /// In bn, this message translates to:
  /// **'যাচাই লাগবে'**
  String get choreEditorVerification;

  /// No description provided for @choreEditorVerificationHelp.
  ///
  /// In bn, this message translates to:
  /// **'কাজ শেষ হলে একজন দায়িত্বশীল যাচাই করবেন।'**
  String get choreEditorVerificationHelp;

  /// No description provided for @choreEditorActive.
  ///
  /// In bn, this message translates to:
  /// **'সক্রিয়'**
  String get choreEditorActive;

  /// No description provided for @choreEditorActiveHelp.
  ///
  /// In bn, this message translates to:
  /// **'বিরতিতে থাকা কাজের নতুন দিন তৈরি হয় না।'**
  String get choreEditorActiveHelp;

  /// No description provided for @choreRemindersTitle.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ডার'**
  String get choreRemindersTitle;

  /// No description provided for @choreRemindersStoredNote.
  ///
  /// In bn, this message translates to:
  /// **'পরে কাজে লাগবে: রিমাইন্ডার পরের আপডেটে পাঠানো হবে।'**
  String get choreRemindersStoredNote;

  /// No description provided for @choreReminderAtDue.
  ///
  /// In bn, this message translates to:
  /// **'নির্ধারিত সময়ে'**
  String get choreReminderAtDue;

  /// No description provided for @choreReminderBeforeTitle.
  ///
  /// In bn, this message translates to:
  /// **'নির্ধারিত সময়ের আগে'**
  String get choreReminderBeforeTitle;

  /// No description provided for @choreReminderBefore.
  ///
  /// In bn, this message translates to:
  /// **'{minutes} মিনিট আগে'**
  String choreReminderBefore(String minutes);

  /// No description provided for @choreReminderCustom.
  ///
  /// In bn, this message translates to:
  /// **'অন্য মিনিট (১-১৪৪০)'**
  String get choreReminderCustom;

  /// No description provided for @choreReminderCustomAdd.
  ///
  /// In bn, this message translates to:
  /// **'সময় যোগ করুন'**
  String get choreReminderCustomAdd;

  /// No description provided for @choreReminderOverdue.
  ///
  /// In bn, this message translates to:
  /// **'দেরি হলে'**
  String get choreReminderOverdue;

  /// No description provided for @choreReminderOverdueAfter.
  ///
  /// In bn, this message translates to:
  /// **'নির্ধারিত সময়ের কত মিনিট পরে'**
  String get choreReminderOverdueAfter;

  /// No description provided for @choreSlotTitle.
  ///
  /// In bn, this message translates to:
  /// **'সময় {number}'**
  String choreSlotTitle(String number);

  /// No description provided for @choreSlotLabel.
  ///
  /// In bn, this message translates to:
  /// **'এই সময়ের নাম (ঐচ্ছিক)'**
  String get choreSlotLabel;

  /// No description provided for @choreSlotLabelRequired.
  ///
  /// In bn, this message translates to:
  /// **'এই সময়ের নাম'**
  String get choreSlotLabelRequired;

  /// No description provided for @choreSlotLabelNeeded.
  ///
  /// In bn, this message translates to:
  /// **'সময়গুলো আলাদা বোঝার জন্য এর একটি নাম দিন।'**
  String get choreSlotLabelNeeded;

  /// No description provided for @choreSlotDueTime.
  ///
  /// In bn, this message translates to:
  /// **'শেষ সময়'**
  String get choreSlotDueTime;

  /// No description provided for @choreSlotAdd.
  ///
  /// In bn, this message translates to:
  /// **'আরেকটি সময় যোগ করুন'**
  String get choreSlotAdd;

  /// No description provided for @choreSlotRemove.
  ///
  /// In bn, this message translates to:
  /// **'এই সময় মুছুন'**
  String get choreSlotRemove;

  /// No description provided for @choreSlotLimit.
  ///
  /// In bn, this message translates to:
  /// **'দিনে সর্বোচ্চ {max}টি সময়।'**
  String choreSlotLimit(String max);

  /// No description provided for @choreSubtasksEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো ধাপ নেই। ধাপ ঐচ্ছিক।'**
  String get choreSubtasksEmpty;

  /// No description provided for @choreSubtaskAdd.
  ///
  /// In bn, this message translates to:
  /// **'ধাপ যোগ করুন'**
  String get choreSubtaskAdd;

  /// No description provided for @choreSubtaskTitle.
  ///
  /// In bn, this message translates to:
  /// **'ধাপ'**
  String get choreSubtaskTitle;

  /// No description provided for @choreSubtaskRequired.
  ///
  /// In bn, this message translates to:
  /// **'আবশ্যক ধাপ'**
  String get choreSubtaskRequired;

  /// No description provided for @choreSubtaskHint.
  ///
  /// In bn, this message translates to:
  /// **'ইঙ্গিত (ঐচ্ছিক)'**
  String get choreSubtaskHint;

  /// No description provided for @choreSubtaskRemove.
  ///
  /// In bn, this message translates to:
  /// **'ধাপ মুছুন'**
  String get choreSubtaskRemove;

  /// No description provided for @choreSubtaskLimit.
  ///
  /// In bn, this message translates to:
  /// **'সর্বোচ্চ {max}টি ধাপ।'**
  String choreSubtaskLimit(String max);

  /// No description provided for @choreSubtaskStepNumber.
  ///
  /// In bn, this message translates to:
  /// **'ধাপ {n}'**
  String choreSubtaskStepNumber(String n);

  /// No description provided for @choreInstructionsBold.
  ///
  /// In bn, this message translates to:
  /// **'গাঢ়'**
  String get choreInstructionsBold;

  /// No description provided for @choreInstructionsBullet.
  ///
  /// In bn, this message translates to:
  /// **'তালিকা'**
  String get choreInstructionsBullet;

  /// No description provided for @choreInstructionsNumbered.
  ///
  /// In bn, this message translates to:
  /// **'ক্রমিক তালিকা'**
  String get choreInstructionsNumbered;

  /// No description provided for @choreInstructionsHint.
  ///
  /// In bn, this message translates to:
  /// **'কাজটি কীভাবে করবেন'**
  String get choreInstructionsHint;

  /// No description provided for @choreInstructionsEmpty.
  ///
  /// In bn, this message translates to:
  /// **'কোনো নির্দেশনা নেই'**
  String get choreInstructionsEmpty;

  /// No description provided for @choreAssigneeManualHelp.
  ///
  /// In bn, this message translates to:
  /// **'কোনো দায়িত্বশীল ঠিক না করা পর্যন্ত কেউ নির্ধারিত থাকবে না।'**
  String get choreAssigneeManualHelp;

  /// No description provided for @choreAssigneeFixedLabel.
  ///
  /// In bn, this message translates to:
  /// **'কে করবে'**
  String get choreAssigneeFixedLabel;

  /// No description provided for @choreAssigneeSourceGroup.
  ///
  /// In bn, this message translates to:
  /// **'দায়িত্ব গ্রুপ'**
  String get choreAssigneeSourceGroup;

  /// No description provided for @choreAssigneeSourceOwn.
  ///
  /// In bn, this message translates to:
  /// **'নিজস্ব পালা'**
  String get choreAssigneeSourceOwn;

  /// No description provided for @choreAssigneePickGroup.
  ///
  /// In bn, this message translates to:
  /// **'একটি দায়িত্ব গ্রুপ বাছুন'**
  String get choreAssigneePickGroup;

  /// No description provided for @choreAssigneeNoGroups.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কোনো দায়িত্ব গ্রুপ নেই। একটি বানান অথবা নিজস্ব পালা ব্যবহার করুন।'**
  String get choreAssigneeNoGroups;

  /// No description provided for @choreReplanTitle.
  ///
  /// In bn, this message translates to:
  /// **'এই পরিবর্তন কোথায় প্রযোজ্য হবে'**
  String get choreReplanTitle;

  /// No description provided for @choreReplanMessage.
  ///
  /// In bn, this message translates to:
  /// **'যে দিনের কাজ শুরু বা শেষ হয়েছে তা কখনো বদলায় না।'**
  String get choreReplanMessage;

  /// No description provided for @choreReplanFutureOnly.
  ///
  /// In bn, this message translates to:
  /// **'শুধু আগামী দিনগুলো'**
  String get choreReplanFutureOnly;

  /// No description provided for @choreReplanIncludeUpcoming.
  ///
  /// In bn, this message translates to:
  /// **'আগামী দিন এবং এখনো কেউ শুরু করেনি এমন আসন্ন দিনগুলো'**
  String get choreReplanIncludeUpcoming;

  /// No description provided for @recurrenceKindOnce.
  ///
  /// In bn, this message translates to:
  /// **'একবার'**
  String get recurrenceKindOnce;

  /// No description provided for @recurrenceKindDaily.
  ///
  /// In bn, this message translates to:
  /// **'প্রতিদিন'**
  String get recurrenceKindDaily;

  /// No description provided for @recurrenceKindEveryNDays.
  ///
  /// In bn, this message translates to:
  /// **'কয়েক দিন পর পর'**
  String get recurrenceKindEveryNDays;

  /// No description provided for @recurrenceKindWeekdays.
  ///
  /// In bn, this message translates to:
  /// **'সপ্তাহের নির্দিষ্ট দিন'**
  String get recurrenceKindWeekdays;

  /// No description provided for @recurrenceKindEveryNWeeks.
  ///
  /// In bn, this message translates to:
  /// **'কয়েক সপ্তাহ পর পর'**
  String get recurrenceKindEveryNWeeks;

  /// No description provided for @recurrenceKindDaysOfMonth.
  ///
  /// In bn, this message translates to:
  /// **'মাসের নির্দিষ্ট তারিখ'**
  String get recurrenceKindDaysOfMonth;

  /// No description provided for @recurrenceKindNthWeekday.
  ///
  /// In bn, this message translates to:
  /// **'মাসের একটি সপ্তাহের দিন'**
  String get recurrenceKindNthWeekday;

  /// No description provided for @recurrenceKindLastDay.
  ///
  /// In bn, this message translates to:
  /// **'মাসের শেষ দিন'**
  String get recurrenceKindLastDay;

  /// No description provided for @recurrencePickerTitle.
  ///
  /// In bn, this message translates to:
  /// **'পুনরাবৃত্তি'**
  String get recurrencePickerTitle;

  /// No description provided for @recurrencePickerOnceDate.
  ///
  /// In bn, this message translates to:
  /// **'তারিখ'**
  String get recurrencePickerOnceDate;

  /// No description provided for @recurrencePickerEveryNDays.
  ///
  /// In bn, this message translates to:
  /// **'কত দিন পর পর'**
  String get recurrencePickerEveryNDays;

  /// No description provided for @recurrencePickerEveryNWeeks.
  ///
  /// In bn, this message translates to:
  /// **'কত সপ্তাহ পর পর'**
  String get recurrencePickerEveryNWeeks;

  /// No description provided for @recurrencePickerDaysOfMonth.
  ///
  /// In bn, this message translates to:
  /// **'মাসের তারিখ'**
  String get recurrencePickerDaysOfMonth;

  /// No description provided for @recurrencePickerMonthEnd.
  ///
  /// In bn, this message translates to:
  /// **'মাস ছোট হলে'**
  String get recurrencePickerMonthEnd;

  /// No description provided for @recurrencePickerMonthEndClamp.
  ///
  /// In bn, this message translates to:
  /// **'শেষ দিনে করুন'**
  String get recurrencePickerMonthEndClamp;

  /// No description provided for @recurrencePickerMonthEndSkip.
  ///
  /// In bn, this message translates to:
  /// **'সেই মাস বাদ দিন'**
  String get recurrencePickerMonthEndSkip;

  /// No description provided for @recurrencePickerNth.
  ///
  /// In bn, this message translates to:
  /// **'কোনটি'**
  String get recurrencePickerNth;

  /// No description provided for @recurrencePickerWeekday.
  ///
  /// In bn, this message translates to:
  /// **'সপ্তাহের দিন'**
  String get recurrencePickerWeekday;

  /// No description provided for @recurrencePickerWeekdays.
  ///
  /// In bn, this message translates to:
  /// **'সপ্তাহের দিনগুলো'**
  String get recurrencePickerWeekdays;

  /// No description provided for @recurrenceNthFirst.
  ///
  /// In bn, this message translates to:
  /// **'প্রথম'**
  String get recurrenceNthFirst;

  /// No description provided for @recurrenceNthSecond.
  ///
  /// In bn, this message translates to:
  /// **'দ্বিতীয়'**
  String get recurrenceNthSecond;

  /// No description provided for @recurrenceNthThird.
  ///
  /// In bn, this message translates to:
  /// **'তৃতীয়'**
  String get recurrenceNthThird;

  /// No description provided for @recurrenceNthFourth.
  ///
  /// In bn, this message translates to:
  /// **'চতুর্থ'**
  String get recurrenceNthFourth;

  /// No description provided for @recurrenceNthLast.
  ///
  /// In bn, this message translates to:
  /// **'শেষ'**
  String get recurrenceNthLast;

  /// No description provided for @recurrenceListSeparator.
  ///
  /// In bn, this message translates to:
  /// **', '**
  String get recurrenceListSeparator;

  /// No description provided for @recurrenceSummaryOnce.
  ///
  /// In bn, this message translates to:
  /// **'একবার'**
  String get recurrenceSummaryOnce;

  /// No description provided for @recurrenceSummaryDaily.
  ///
  /// In bn, this message translates to:
  /// **'প্রতিদিন'**
  String get recurrenceSummaryDaily;

  /// No description provided for @recurrenceSummaryEveryNDays.
  ///
  /// In bn, this message translates to:
  /// **'প্রতি {n} দিন পর পর'**
  String recurrenceSummaryEveryNDays(String n);

  /// No description provided for @recurrenceSummaryWeekdays.
  ///
  /// In bn, this message translates to:
  /// **'প্রতি {days}'**
  String recurrenceSummaryWeekdays(String days);

  /// No description provided for @recurrenceSummaryEveryNWeeks.
  ///
  /// In bn, this message translates to:
  /// **'প্রতি {n} সপ্তাহে {days}'**
  String recurrenceSummaryEveryNWeeks(String n, String days);

  /// No description provided for @recurrenceSummaryDaysOfMonth.
  ///
  /// In bn, this message translates to:
  /// **'প্রতি মাসের {days} তারিখে'**
  String recurrenceSummaryDaysOfMonth(String days);

  /// No description provided for @recurrenceSummaryNthWeekday.
  ///
  /// In bn, this message translates to:
  /// **'প্রতি মাসের {nth} {weekday}'**
  String recurrenceSummaryNthWeekday(String nth, String weekday);

  /// No description provided for @recurrenceSummaryLastDay.
  ///
  /// In bn, this message translates to:
  /// **'প্রতি মাসের শেষ দিনে'**
  String get recurrenceSummaryLastDay;

  /// No description provided for @starterPackTitle.
  ///
  /// In bn, this message translates to:
  /// **'স্টার্টার প্যাক'**
  String get starterPackTitle;

  /// No description provided for @starterListTitle.
  ///
  /// In bn, this message translates to:
  /// **'স্টার্টার প্যাকের তালিকা'**
  String get starterListTitle;

  /// No description provided for @starterListEdit.
  ///
  /// In bn, this message translates to:
  /// **'তালিকা বদলান'**
  String get starterListEdit;

  /// No description provided for @starterListBuiltInNote.
  ///
  /// In bn, this message translates to:
  /// **'এটি অ্যাপের নিজস্ব তালিকা। কাজ যোগ, বদল বা মুছতে \"নিজের মতো করুন\" চাপুন।'**
  String get starterListBuiltInNote;

  /// No description provided for @starterListCustomNote.
  ///
  /// In bn, this message translates to:
  /// **'এটি আপনার পরিবারের নিজের তালিকা। স্টার্টার প্যাক এটিই ব্যবহার করে।'**
  String get starterListCustomNote;

  /// No description provided for @starterListCustomise.
  ///
  /// In bn, this message translates to:
  /// **'নিজের মতো করুন'**
  String get starterListCustomise;

  /// No description provided for @starterListReset.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাপের তালিকায় ফিরুন'**
  String get starterListReset;

  /// No description provided for @starterListResetTitle.
  ///
  /// In bn, this message translates to:
  /// **'তালিকা রিসেট করবেন?'**
  String get starterListResetTitle;

  /// No description provided for @starterListResetMessage.
  ///
  /// In bn, this message translates to:
  /// **'আপনার নিজের তালিকা মুছে যাবে এবং অ্যাপের তালিকা আবার ব্যবহার হবে। যে কাজগুলো আগেই তৈরি হয়েছে সেগুলো বদলাবে না।'**
  String get starterListResetMessage;

  /// No description provided for @starterListSaveFailed.
  ///
  /// In bn, this message translates to:
  /// **'সেভ হয়নি, স্টার্টার তালিকা আগের মতোই আছে: {reason}'**
  String starterListSaveFailed(Object reason);

  /// No description provided for @starterListDeleteTitle.
  ///
  /// In bn, this message translates to:
  /// **'তালিকা থেকে মুছবেন?'**
  String get starterListDeleteTitle;

  /// No description provided for @starterListDeleteMessage.
  ///
  /// In bn, this message translates to:
  /// **'কাজটি আর স্টার্টার প্যাকে দেখানো হবে না। যে কাজগুলো আগেই তৈরি হয়েছে সেগুলো বদলাবে না।'**
  String get starterListDeleteMessage;

  /// No description provided for @starterPackSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের নিয়মিত কাজগুলো একবারে যোগ করুন'**
  String get starterPackSubtitle;

  /// No description provided for @starterPackManagersOnly.
  ///
  /// In bn, this message translates to:
  /// **'শুধু হাউসহোল্ড ম্যানেজার স্টার্টার প্যাক যোগ করতে পারেন।'**
  String get starterPackManagersOnly;

  /// No description provided for @starterPackPickBody.
  ///
  /// In bn, this message translates to:
  /// **'একটি প্যাক বাছুন। প্রতিটি কাজ আপনার পরিবারের নিজের তালিকায় যোগ হবে; কোনো কিছু লক থাকবে না।'**
  String get starterPackPickBody;

  /// No description provided for @starterPackFamilyPdfTitle.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের কাজের তালিকা'**
  String get starterPackFamilyPdfTitle;

  /// No description provided for @starterPackFamilyPdfDescription.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের হাতে লেখা তালিকা থেকে দৈনিক, সাপ্তাহিক ও মাসিক কাজ।'**
  String get starterPackFamilyPdfDescription;

  /// No description provided for @starterPackTemplateCount.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি কাজ'**
  String starterPackTemplateCount(String count);

  /// No description provided for @starterPackCountHigh.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি নিশ্চিত'**
  String starterPackCountHigh(String count);

  /// No description provided for @starterPackCountMedium.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি মাঝারি নিশ্চিত'**
  String starterPackCountMedium(String count);

  /// No description provided for @starterPackCountLow.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি কম নিশ্চিত'**
  String starterPackCountLow(String count);

  /// No description provided for @starterPackPickHint.
  ///
  /// In bn, this message translates to:
  /// **'নিশ্চিত কাজগুলো আগে থেকেই টিক দেওয়া আছে। বাকিগুলো পরের ধাপে আপনি নিশ্চিত করবেন।'**
  String get starterPackPickHint;

  /// No description provided for @starterPackReviewBody.
  ///
  /// In bn, this message translates to:
  /// **'যা না চান তা টিক তুলে দিন। মাঝারি ও কম নিশ্চিত কাজগুলোর জন্য আপনার নিশ্চিতকরণ দরকার।'**
  String get starterPackReviewBody;

  /// No description provided for @starterPackConfidenceHigh.
  ///
  /// In bn, this message translates to:
  /// **'নিশ্চিত'**
  String get starterPackConfidenceHigh;

  /// No description provided for @starterPackConfidenceMedium.
  ///
  /// In bn, this message translates to:
  /// **'মাঝারি'**
  String get starterPackConfidenceMedium;

  /// No description provided for @starterPackConfidenceLow.
  ///
  /// In bn, this message translates to:
  /// **'কম নিশ্চিত'**
  String get starterPackConfidenceLow;

  /// No description provided for @starterPackConfidenceLegend.
  ///
  /// In bn, this message translates to:
  /// **'নিশ্চয়তা:'**
  String get starterPackConfidenceLegend;

  /// No description provided for @starterPackPleaseConfirm.
  ///
  /// In bn, this message translates to:
  /// **'নিশ্চিত করুন'**
  String get starterPackPleaseConfirm;

  /// No description provided for @starterPackDetailsTitle.
  ///
  /// In bn, this message translates to:
  /// **'কাজের বিবরণ'**
  String get starterPackDetailsTitle;

  /// No description provided for @starterPackDetailsSchedule.
  ///
  /// In bn, this message translates to:
  /// **'সময়সূচি'**
  String get starterPackDetailsSchedule;

  /// No description provided for @starterPackDetailsNotes.
  ///
  /// In bn, this message translates to:
  /// **'নোট'**
  String get starterPackDetailsNotes;

  /// No description provided for @starterPackDetailsSteps.
  ///
  /// In bn, this message translates to:
  /// **'ধাপ'**
  String get starterPackDetailsSteps;

  /// No description provided for @starterPackEndOfDay.
  ///
  /// In bn, this message translates to:
  /// **'যখনই সুবিধা'**
  String get starterPackEndOfDay;

  /// No description provided for @starterPackHouseRulesTitle.
  ///
  /// In bn, this message translates to:
  /// **'ঘরের নিয়ম'**
  String get starterPackHouseRulesTitle;

  /// No description provided for @starterPackHouseRulesHint.
  ///
  /// In bn, this message translates to:
  /// **'এগুলো কাজের সেটিংসে সংরক্ষিত হবে এবং কাজের ম্যানেজ পেজে দেখা যাবে।'**
  String get starterPackHouseRulesHint;

  /// No description provided for @starterPackHouseRulesSwitch.
  ///
  /// In bn, this message translates to:
  /// **'তালিকার ঘরের নিয়মগুলো যোগ করুন'**
  String get starterPackHouseRulesSwitch;

  /// No description provided for @starterPackWhoBody.
  ///
  /// In bn, this message translates to:
  /// **'দৈনিক কাজ কে কে ভাগ করবেন, প্রথমে কে করবেন এবং কত দিন পর পর পালা বদলাবে তা বাছুন। অথবা এখন কাউকে না দিয়ে পরে ঠিক করুন।'**
  String get starterPackWhoBody;

  /// No description provided for @starterPackRotationSwitch.
  ///
  /// In bn, this message translates to:
  /// **'এই কাজগুলো পালা করে ভাগ করুন'**
  String get starterPackRotationSwitch;

  /// No description provided for @starterPackRotationNeedsTwo.
  ///
  /// In bn, this message translates to:
  /// **'পালার জন্য অন্তত দুইজন সক্রিয় সদস্য দরকার।'**
  String get starterPackRotationNeedsTwo;

  /// No description provided for @starterPackNoRotationInfo.
  ///
  /// In bn, this message translates to:
  /// **'কাজগুলোতে এখনই কাউকে দেওয়া হবে না। পরে একে একে দায়িত্ব দিতে পারবেন।'**
  String get starterPackNoRotationInfo;

  /// No description provided for @starterPackMembersTitle.
  ///
  /// In bn, this message translates to:
  /// **'পালায় যারা থাকবেন'**
  String get starterPackMembersTitle;

  /// No description provided for @starterPackFirstMemberTitle.
  ///
  /// In bn, this message translates to:
  /// **'প্রথমে কে'**
  String get starterPackFirstMemberTitle;

  /// No description provided for @starterPackCycleTitle.
  ///
  /// In bn, this message translates to:
  /// **'পালা বদলাবে প্রতি'**
  String get starterPackCycleTitle;

  /// No description provided for @starterPackNoMembers.
  ///
  /// In bn, this message translates to:
  /// **'পালা করার মতো সক্রিয় সদস্য এখন নেই। কাজগুলো পরে দায়িত্ব দিতে পারবেন।'**
  String get starterPackNoMembers;

  /// No description provided for @starterPackApply.
  ///
  /// In bn, this message translates to:
  /// **'এই কাজগুলো যোগ করুন'**
  String get starterPackApply;

  /// No description provided for @starterPackApplying.
  ///
  /// In bn, this message translates to:
  /// **'কাজ যোগ হচ্ছে…'**
  String get starterPackApplying;

  /// No description provided for @starterPackOpenToday.
  ///
  /// In bn, this message translates to:
  /// **'আজকের কাজ দেখুন'**
  String get starterPackOpenToday;

  /// No description provided for @starterPackResultTitle.
  ///
  /// In bn, this message translates to:
  /// **'স্টার্টার প্যাক যোগ হয়েছে'**
  String get starterPackResultTitle;

  /// No description provided for @starterPackResultTemplates.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি কাজ যোগ হয়েছে'**
  String starterPackResultTemplates(String count);

  /// No description provided for @starterPackResultSkipped.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি আগে থেকেই ছিল'**
  String starterPackResultSkipped(String count);

  /// No description provided for @starterPackResultGroups.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি কাজের গ্রুপ যোগ হয়েছে'**
  String starterPackResultGroups(String count);

  /// No description provided for @starterPackResultPresets.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি সময়ের প্রিসেট যোগ হয়েছে'**
  String starterPackResultPresets(String count);

  /// No description provided for @starterPackResultDutyGroups.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি ডিউটি গ্রুপ যোগ হয়েছে'**
  String starterPackResultDutyGroups(String count);

  /// No description provided for @starterPackResultRules.
  ///
  /// In bn, this message translates to:
  /// **'ঘরের নিয়ম যোগ হয়েছে'**
  String get starterPackResultRules;

  /// No description provided for @starterPackResultGenerated.
  ///
  /// In bn, this message translates to:
  /// **'আজকের জন্য {count}টি কাজ তৈরি হয়েছে'**
  String starterPackResultGenerated(String count);

  /// No description provided for @starterPackResultGenerationFailed.
  ///
  /// In bn, this message translates to:
  /// **'কাজগুলো সংরক্ষণ হয়েছে, কিন্তু আজকের কাজ তৈরি করা যায়নি। আজকের পেজ খুলে আবার চেষ্টা করুন।'**
  String get starterPackResultGenerationFailed;

  /// No description provided for @starterPackStepOf.
  ///
  /// In bn, this message translates to:
  /// **'ধাপ {current}/{total}'**
  String starterPackStepOf(String current, String total);

  /// No description provided for @starterPackStepPick.
  ///
  /// In bn, this message translates to:
  /// **'প্যাক বাছুন'**
  String get starterPackStepPick;

  /// No description provided for @starterPackStepReview.
  ///
  /// In bn, this message translates to:
  /// **'পর্যালোচনা'**
  String get starterPackStepReview;

  /// No description provided for @starterPackStepWho.
  ///
  /// In bn, this message translates to:
  /// **'কে কী করবেন'**
  String get starterPackStepWho;

  /// No description provided for @calendarTruncatedBanner.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসে অনেক কাজ — সব দেখানো যাচ্ছে না'**
  String get calendarTruncatedBanner;

  /// No description provided for @calendarTruncatedBannerAction.
  ///
  /// In bn, this message translates to:
  /// **'ফিল্টার দেখুন'**
  String get calendarTruncatedBannerAction;

  /// No description provided for @calendarToday.
  ///
  /// In bn, this message translates to:
  /// **'আজ'**
  String get calendarToday;

  /// No description provided for @calendarPreviousMonth.
  ///
  /// In bn, this message translates to:
  /// **'আগের মাস'**
  String get calendarPreviousMonth;

  /// No description provided for @calendarNextMonth.
  ///
  /// In bn, this message translates to:
  /// **'পরের মাস'**
  String get calendarNextMonth;

  /// No description provided for @calendarPickMonth.
  ///
  /// In bn, this message translates to:
  /// **'মাস ও বছর বাছুন'**
  String get calendarPickMonth;

  /// No description provided for @calendarPreviousYear.
  ///
  /// In bn, this message translates to:
  /// **'আগের বছর'**
  String get calendarPreviousYear;

  /// No description provided for @calendarNextYear.
  ///
  /// In bn, this message translates to:
  /// **'পরের বছর'**
  String get calendarNextYear;

  /// No description provided for @calendarGridLabel.
  ///
  /// In bn, this message translates to:
  /// **'মাসের ক্যালেন্ডার'**
  String get calendarGridLabel;

  /// No description provided for @calendarFilters.
  ///
  /// In bn, this message translates to:
  /// **'ফিল্টার'**
  String get calendarFilters;

  /// No description provided for @calendarFiltersActive.
  ///
  /// In bn, this message translates to:
  /// **'ফিল্টার, {count}টি চালু'**
  String calendarFiltersActive(String count);

  /// No description provided for @calendarFiltersNone.
  ///
  /// In bn, this message translates to:
  /// **'কোনো ফিল্টার চালু নেই।'**
  String get calendarFiltersNone;

  /// No description provided for @calendarClearFilters.
  ///
  /// In bn, this message translates to:
  /// **'ফিল্টার মুছুন'**
  String get calendarClearFilters;

  /// No description provided for @calendarAgendaOverdueToday.
  ///
  /// In bn, this message translates to:
  /// **'আজকের বিলম্বিত কাজ'**
  String get calendarAgendaOverdueToday;

  /// No description provided for @calendarAgendaNoMatch.
  ///
  /// In bn, this message translates to:
  /// **'এই ফিল্টারে কোনো কাজ পাওয়া যায়নি'**
  String get calendarAgendaNoMatch;

  /// No description provided for @calendarDayEmptyTitle.
  ///
  /// In bn, this message translates to:
  /// **'এই দিনে কোনো কাজ নেই'**
  String get calendarDayEmptyTitle;

  /// No description provided for @calendarDayEmptyMessage.
  ///
  /// In bn, this message translates to:
  /// **'এই দিনের জন্য কিছু ঠিক করা নেই।'**
  String get calendarDayEmptyMessage;

  /// No description provided for @calendarDayHeader.
  ///
  /// In bn, this message translates to:
  /// **'{date} · {count}টি কাজ'**
  String calendarDayHeader(String date, String count);

  /// No description provided for @calendarCellChores.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি কাজ'**
  String calendarCellChores(String count);

  /// No description provided for @calendarCellPast.
  ///
  /// In bn, this message translates to:
  /// **'আগের তারিখ'**
  String get calendarCellPast;

  /// No description provided for @calendarCellScheduled.
  ///
  /// In bn, this message translates to:
  /// **'নির্ধারিত'**
  String get calendarCellScheduled;

  /// No description provided for @calendarCellProgress.
  ///
  /// In bn, this message translates to:
  /// **'{total}টির মধ্যে {done}টি সম্পন্ন'**
  String calendarCellProgress(String done, String total);

  /// No description provided for @calendarCellCompleted.
  ///
  /// In bn, this message translates to:
  /// **'সব কাজ সম্পন্ন'**
  String get calendarCellCompleted;

  /// No description provided for @calendarDayOpenCount.
  ///
  /// In bn, this message translates to:
  /// **'বাকি: {count}'**
  String calendarDayOpenCount(String count);

  /// No description provided for @calendarDaySkippedCount.
  ///
  /// In bn, this message translates to:
  /// **'বাদ: {count}'**
  String calendarDaySkippedCount(String count);

  /// No description provided for @calendarCellMembers.
  ///
  /// In bn, this message translates to:
  /// **'দায়িত্বে: {names}'**
  String calendarCellMembers(String names);

  /// No description provided for @calendarUnknownMember.
  ///
  /// In bn, this message translates to:
  /// **'অজানা সদস্য'**
  String get calendarUnknownMember;

  /// No description provided for @calendarCellOverdue.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি বিলম্বিত'**
  String calendarCellOverdue(String count);

  /// No description provided for @calendarCellMine.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি আপনার'**
  String calendarCellMine(String count);

  /// No description provided for @calendarCellSelected.
  ///
  /// In bn, this message translates to:
  /// **'নির্বাচিত'**
  String get calendarCellSelected;

  /// No description provided for @calendarOpenToday.
  ///
  /// In bn, this message translates to:
  /// **'আজকের কাজ খুলুন'**
  String get calendarOpenToday;

  /// No description provided for @calendarFreeDays.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি ফাঁকা দিন'**
  String calendarFreeDays(String count);

  /// No description provided for @calendarLoadEarlier.
  ///
  /// In bn, this message translates to:
  /// **'আগের সপ্তাহ দেখুন'**
  String get calendarLoadEarlier;

  /// No description provided for @calendarLoadLater.
  ///
  /// In bn, this message translates to:
  /// **'পরের সপ্তাহ দেখুন'**
  String get calendarLoadLater;

  /// No description provided for @calendarJumpToToday.
  ///
  /// In bn, this message translates to:
  /// **'আজকে ফিরে যান'**
  String get calendarJumpToToday;

  /// No description provided for @calendarLegend.
  ///
  /// In bn, this message translates to:
  /// **'চিহ্নের অর্থ'**
  String get calendarLegend;

  /// No description provided for @calendarFilterGroups.
  ///
  /// In bn, this message translates to:
  /// **'গ্রুপ'**
  String get calendarFilterGroups;

  /// No description provided for @calendarFilterStatuses.
  ///
  /// In bn, this message translates to:
  /// **'অবস্থা'**
  String get calendarFilterStatuses;

  /// No description provided for @calendarFilterMembers.
  ///
  /// In bn, this message translates to:
  /// **'সদস্য'**
  String get calendarFilterMembers;

  /// No description provided for @calendarFilterNeedsAttention.
  ///
  /// In bn, this message translates to:
  /// **'শুধু নজর দরকার'**
  String get calendarFilterNeedsAttention;

  /// No description provided for @calendarSearchHint.
  ///
  /// In bn, this message translates to:
  /// **'কাজ খুঁজুন'**
  String get calendarSearchHint;

  /// No description provided for @calendarAddChore.
  ///
  /// In bn, this message translates to:
  /// **'কাজ যোগ করুন'**
  String get calendarAddChore;

  /// No description provided for @calendarMonthNarrow.
  ///
  /// In bn, this message translates to:
  /// **'মাসের ভিউয়ের জন্য চওড়া পর্দা লাগে, তাই সপ্তাহ দেখানো হচ্ছে।'**
  String get calendarMonthNarrow;

  /// No description provided for @calendarQuickActions.
  ///
  /// In bn, this message translates to:
  /// **'কাজের অ্যাকশন'**
  String get calendarQuickActions;

  /// No description provided for @calendarRemoveFilter.
  ///
  /// In bn, this message translates to:
  /// **'{label} ফিল্টার সরান'**
  String calendarRemoveFilter(String label);

  /// No description provided for @calendarPreviousWeek.
  ///
  /// In bn, this message translates to:
  /// **'আগের সপ্তাহ'**
  String get calendarPreviousWeek;

  /// No description provided for @calendarNextWeek.
  ///
  /// In bn, this message translates to:
  /// **'পরের সপ্তাহ'**
  String get calendarNextWeek;

  /// No description provided for @calendarCellNeedsCover.
  ///
  /// In bn, this message translates to:
  /// **'কভার লাগবে'**
  String get calendarCellNeedsCover;

  /// No description provided for @calendarCellNeedsAttention.
  ///
  /// In bn, this message translates to:
  /// **'মনোযোগ দরকার'**
  String get calendarCellNeedsAttention;

  /// No description provided for @calendarCellAway.
  ///
  /// In bn, this message translates to:
  /// **'কেউ অনুপস্থিত'**
  String get calendarCellAway;

  /// No description provided for @calendarCellPlanned.
  ///
  /// In bn, this message translates to:
  /// **'পরিকল্পিত'**
  String get calendarCellPlanned;

  /// No description provided for @calendarLegendMarks.
  ///
  /// In bn, this message translates to:
  /// **'দিনের ঘরের চিহ্ন'**
  String get calendarLegendMarks;

  /// No description provided for @calendarLegendNoChores.
  ///
  /// In bn, this message translates to:
  /// **'এই দিনে কোনো কাজ নেই'**
  String get calendarLegendNoChores;

  /// No description provided for @calendarLegendMine.
  ///
  /// In bn, this message translates to:
  /// **'ব্যক্তির আইকন: এই দিনে আপনার কাজ আছে।'**
  String get calendarLegendMine;

  /// No description provided for @calendarShowingMember.
  ///
  /// In bn, this message translates to:
  /// **'দেখানো হচ্ছে: {name}, সদস্য বদলান'**
  String calendarShowingMember(String name);

  /// No description provided for @calendarLegendAvatarDescription.
  ///
  /// In bn, this message translates to:
  /// **'সদস্যের আদ্যক্ষর ও রং দিয়ে দায়িত্বে থাকা ব্যক্তিকে চেনা যায়; অ্যাকসেন্ট রিংটি আপনাকে বোঝায়।'**
  String get calendarLegendAvatarDescription;

  /// No description provided for @calendarMonthLandscape.
  ///
  /// In bn, this message translates to:
  /// **'ফোন আড়াআড়ি ধরলে মাসের ভিউ নেই, তাই সপ্তাহ দেখানো হচ্ছে।'**
  String get calendarMonthLandscape;

  /// No description provided for @calendarUseFamilyDefaults.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের ডিফল্ট ব্যবহার করুন'**
  String get calendarUseFamilyDefaults;

  /// No description provided for @calendarDayPanelLabel.
  ///
  /// In bn, this message translates to:
  /// **'নির্বাচিত দিনের কাজ'**
  String get calendarDayPanelLabel;

  /// No description provided for @galleryCalendarPolish.
  ///
  /// In bn, this message translates to:
  /// **'ক্যালেন্ডারের সদস্য ও তারিখের অবস্থা'**
  String get galleryCalendarPolish;

  /// No description provided for @galleryDashboardCardFrame.
  ///
  /// In bn, this message translates to:
  /// **'ড্যাশবোর্ড কার্ড'**
  String get galleryDashboardCardFrame;

  /// No description provided for @galleryGreetingHeader.
  ///
  /// In bn, this message translates to:
  /// **'শুভেচ্ছা'**
  String get galleryGreetingHeader;

  /// No description provided for @galleryBellButton.
  ///
  /// In bn, this message translates to:
  /// **'নোটিফিকেশন ঘণ্টা'**
  String get galleryBellButton;

  /// No description provided for @galleryBellOverflow.
  ///
  /// In bn, this message translates to:
  /// **'৯+'**
  String get galleryBellOverflow;

  /// No description provided for @galleryAlertStrip.
  ///
  /// In bn, this message translates to:
  /// **'সতর্কতার বার'**
  String get galleryAlertStrip;

  /// No description provided for @galleryActivityTile.
  ///
  /// In bn, this message translates to:
  /// **'কার্যকলাপ'**
  String get galleryActivityTile;

  /// No description provided for @galleryStatPill.
  ///
  /// In bn, this message translates to:
  /// **'পরিসংখ্যান'**
  String get galleryStatPill;

  /// No description provided for @galleryTimeOffsetChips.
  ///
  /// In bn, this message translates to:
  /// **'সময়ের ব্যবধান'**
  String get galleryTimeOffsetChips;

  /// No description provided for @galleryQuietHoursPicker.
  ///
  /// In bn, this message translates to:
  /// **'নীরব সময়'**
  String get galleryQuietHoursPicker;

  /// No description provided for @galleryQuietHoursStart.
  ///
  /// In bn, this message translates to:
  /// **'শুরুর সময়'**
  String get galleryQuietHoursStart;

  /// No description provided for @galleryQuietHoursEnd.
  ///
  /// In bn, this message translates to:
  /// **'শেষের সময়'**
  String get galleryQuietHoursEnd;

  /// No description provided for @gallerySwitchTileWithReason.
  ///
  /// In bn, this message translates to:
  /// **'কারণসহ সুইচ'**
  String get gallerySwitchTileWithReason;

  /// No description provided for @galleryLevelRing.
  ///
  /// In bn, this message translates to:
  /// **'স্তরের অগ্রগতি'**
  String get galleryLevelRing;

  /// No description provided for @galleryBadgeMedal.
  ///
  /// In bn, this message translates to:
  /// **'অর্জনের ব্যাজ'**
  String get galleryBadgeMedal;

  /// No description provided for @galleryEarned.
  ///
  /// In bn, this message translates to:
  /// **'অর্জিত'**
  String get galleryEarned;

  /// No description provided for @galleryUnearned.
  ///
  /// In bn, this message translates to:
  /// **'এখনও অর্জিত নয়'**
  String get galleryUnearned;

  /// No description provided for @galleryPlantStageView.
  ///
  /// In bn, this message translates to:
  /// **'গাছের স্তর'**
  String get galleryPlantStageView;

  /// No description provided for @galleryConfettiView.
  ///
  /// In bn, this message translates to:
  /// **'উদ্‌যাপনের কনফেটি'**
  String get galleryConfettiView;

  /// No description provided for @galleryDiagnosticRow.
  ///
  /// In bn, this message translates to:
  /// **'ডায়াগনস্টিক সারি'**
  String get galleryDiagnosticRow;

  /// No description provided for @galleryReorderableCardTile.
  ///
  /// In bn, this message translates to:
  /// **'সাজানো যায় এমন কার্ড'**
  String get galleryReorderableCardTile;

  /// No description provided for @galleryDragLabel.
  ///
  /// In bn, this message translates to:
  /// **'টেনে সরান'**
  String get galleryDragLabel;

  /// No description provided for @galleryMoveUp.
  ///
  /// In bn, this message translates to:
  /// **'উপরে সরান'**
  String get galleryMoveUp;

  /// No description provided for @galleryMoveDown.
  ///
  /// In bn, this message translates to:
  /// **'নিচে সরান'**
  String get galleryMoveDown;

  /// No description provided for @galleryAccessCell.
  ///
  /// In bn, this message translates to:
  /// **'ভূমিকার প্রবেশাধিকার'**
  String get galleryAccessCell;

  /// No description provided for @galleryAccessHidden.
  ///
  /// In bn, this message translates to:
  /// **'লুকানো'**
  String get galleryAccessHidden;

  /// No description provided for @galleryAccessOn.
  ///
  /// In bn, this message translates to:
  /// **'চালু'**
  String get galleryAccessOn;

  /// No description provided for @galleryAccessOff.
  ///
  /// In bn, this message translates to:
  /// **'বন্ধ'**
  String get galleryAccessOff;

  /// No description provided for @galleryAccessRequired.
  ///
  /// In bn, this message translates to:
  /// **'আবশ্যক'**
  String get galleryAccessRequired;

  /// No description provided for @galleryDeliveryModeTile.
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞপ্তি পাঠানোর ধরন'**
  String get galleryDeliveryModeTile;

  /// No description provided for @galleryDeliveryNormal.
  ///
  /// In bn, this message translates to:
  /// **'সাধারণ'**
  String get galleryDeliveryNormal;

  /// No description provided for @galleryDeliveryPush.
  ///
  /// In bn, this message translates to:
  /// **'পুশ'**
  String get galleryDeliveryPush;

  /// No description provided for @galleryRecommended.
  ///
  /// In bn, this message translates to:
  /// **'প্রস্তাবিত'**
  String get galleryRecommended;

  /// No description provided for @commentsTitle.
  ///
  /// In bn, this message translates to:
  /// **'মন্তব্য'**
  String get commentsTitle;

  /// No description provided for @commentsEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এখনও কোনো মন্তব্য নেই। কী ঠিক নেই বা কী করা হয়েছে লিখুন।'**
  String get commentsEmpty;

  /// No description provided for @commentsHint.
  ///
  /// In bn, this message translates to:
  /// **'মন্তব্য লিখুন'**
  String get commentsHint;

  /// No description provided for @commentsSend.
  ///
  /// In bn, this message translates to:
  /// **'পাঠান'**
  String get commentsSend;

  /// No description provided for @commentsFlagLabel.
  ///
  /// In bn, this message translates to:
  /// **'ভুল বা অসম্পূর্ণ হিসেবে চিহ্নিত করুন'**
  String get commentsFlagLabel;

  /// No description provided for @commentFlagged.
  ///
  /// In bn, this message translates to:
  /// **'মনোযোগ দরকার'**
  String get commentFlagged;

  /// No description provided for @commentResolved.
  ///
  /// In bn, this message translates to:
  /// **'সমাধান হয়েছে'**
  String get commentResolved;

  /// No description provided for @commentResolve.
  ///
  /// In bn, this message translates to:
  /// **'সমাধান হয়েছে বলুন'**
  String get commentResolve;

  /// No description provided for @commentReopenWithReason.
  ///
  /// In bn, this message translates to:
  /// **'এই কারণে আবার খুলুন'**
  String get commentReopenWithReason;

  /// No description provided for @commentHide.
  ///
  /// In bn, this message translates to:
  /// **'লুকান'**
  String get commentHide;

  /// No description provided for @commentUnhide.
  ///
  /// In bn, this message translates to:
  /// **'আবার দেখান'**
  String get commentUnhide;

  /// No description provided for @commentHiddenByManager.
  ///
  /// In bn, this message translates to:
  /// **'ম্যানেজার লুকিয়েছেন'**
  String get commentHiddenByManager;

  /// No description provided for @commentHideTitle.
  ///
  /// In bn, this message translates to:
  /// **'এই মন্তব্য লুকান'**
  String get commentHideTitle;

  /// No description provided for @commentUnhideTitle.
  ///
  /// In bn, this message translates to:
  /// **'এই মন্তব্য আবার দেখান'**
  String get commentUnhideTitle;

  /// No description provided for @commentHideHint.
  ///
  /// In bn, this message translates to:
  /// **'কেন? (৩ থেকে ২০০ অক্ষর)'**
  String get commentHideHint;

  /// No description provided for @commentYou.
  ///
  /// In bn, this message translates to:
  /// **'আপনি'**
  String get commentYou;

  /// No description provided for @commentUnreadSemantics.
  ///
  /// In bn, this message translates to:
  /// **'নতুন মন্তব্য'**
  String get commentUnreadSemantics;

  /// No description provided for @commentsLimitReached.
  ///
  /// In bn, this message translates to:
  /// **'শুধু প্রথম ২০০টি মন্তব্য দেখানো হচ্ছে।'**
  String get commentsLimitReached;

  /// No description provided for @commentsNew.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি নতুন'**
  String commentsNew(String count);

  /// No description provided for @commentBubbleLabel.
  ///
  /// In bn, this message translates to:
  /// **'{author}, {time}: {text}'**
  String commentBubbleLabel(String author, String time, String text);

  /// No description provided for @activityChoresCommentUnhidden.
  ///
  /// In bn, this message translates to:
  /// **'{member} {date}-এ {name} এর একটি মন্তব্য আবার দেখিয়েছেন'**
  String activityChoresCommentUnhidden(String member, String name, String date);

  /// No description provided for @inboxTitle.
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞপ্তি'**
  String get inboxTitle;

  /// No description provided for @inboxEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এখনও কোনো বিজ্ঞপ্তি নেই'**
  String get inboxEmpty;

  /// No description provided for @inboxToday.
  ///
  /// In bn, this message translates to:
  /// **'আজ'**
  String get inboxToday;

  /// No description provided for @inboxEarlier.
  ///
  /// In bn, this message translates to:
  /// **'আগে'**
  String get inboxEarlier;

  /// No description provided for @inboxSparkNote.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাপ বন্ধ থাকলেও এই ফোনে অনুস্মারক আসবে; অন্যদের কাজ দেওয়া ও বদলির অনুরোধ অ্যাপ খুললে এখানে দেখা যাবে।'**
  String get inboxSparkNote;

  /// No description provided for @inboxBudgetAlert.
  ///
  /// In bn, this message translates to:
  /// **'আপনার বাজেট {percent}% হয়েছে।'**
  String inboxBudgetAlert(String percent);

  /// No description provided for @inboxPendingJoinRequests.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারে যোগ দেওয়ার {count}টি অনুরোধ পর্যালোচনা করতে হবে।'**
  String inboxPendingJoinRequests(String count);

  /// No description provided for @inboxPendingContributionRequests.
  ///
  /// In bn, this message translates to:
  /// **'অবদানের {count}টি অনুরোধ পর্যালোচনা করতে হবে।'**
  String inboxPendingContributionRequests(String count);

  /// No description provided for @inboxContributionDue.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসের আপনার অবদান দেওয়ার সময় হয়েছে।'**
  String get inboxContributionDue;

  /// No description provided for @inboxAwaitingVerification.
  ///
  /// In bn, this message translates to:
  /// **'যাচাইয়ের জন্য {count}টি কাজ অপেক্ষা করছে।'**
  String inboxAwaitingVerification(String count);

  /// No description provided for @inboxMarkAllRead.
  ///
  /// In bn, this message translates to:
  /// **'সব পড়া হয়েছে'**
  String get inboxMarkAllRead;

  /// No description provided for @inboxClearAll.
  ///
  /// In bn, this message translates to:
  /// **'সব বিজ্ঞপ্তি মুছুন'**
  String get inboxClearAll;

  /// No description provided for @inboxClearAllConfirm.
  ///
  /// In bn, this message translates to:
  /// **'এটি সব বিজ্ঞপ্তি লুকিয়ে ফেলবে। এটি পূর্বাবস্থায় ফেরানো যাবে না।'**
  String get inboxClearAllConfirm;

  /// No description provided for @inboxClearAllAction.
  ///
  /// In bn, this message translates to:
  /// **'সব মুছুন'**
  String get inboxClearAllAction;

  /// No description provided for @inboxUnreadSemantics.
  ///
  /// In bn, this message translates to:
  /// **'অপঠিত'**
  String get inboxUnreadSemantics;

  /// No description provided for @inboxSomeone.
  ///
  /// In bn, this message translates to:
  /// **'কেউ একজন'**
  String get inboxSomeone;

  /// No description provided for @inboxUnknown.
  ///
  /// In bn, this message translates to:
  /// **'নতুন বিজ্ঞপ্তি'**
  String get inboxUnknown;

  /// No description provided for @swapSheetTitle.
  ///
  /// In bn, this message translates to:
  /// **'কাউকে এই কাজটি নিতে বলুন'**
  String get swapSheetTitle;

  /// No description provided for @swapSheetPerson.
  ///
  /// In bn, this message translates to:
  /// **'কে নিতে পারবেন?'**
  String get swapSheetPerson;

  /// No description provided for @swapSheetNobody.
  ///
  /// In bn, this message translates to:
  /// **'ওই দিন কেউ ফাঁকা নেই।'**
  String get swapSheetNobody;

  /// No description provided for @swapSheetReasonHint.
  ///
  /// In bn, this message translates to:
  /// **'কেন করতে পারছেন না?'**
  String get swapSheetReasonHint;

  /// No description provided for @swapSheetSend.
  ///
  /// In bn, this message translates to:
  /// **'অনুরোধ পাঠান'**
  String get swapSheetSend;

  /// No description provided for @swapResponseTitle.
  ///
  /// In bn, this message translates to:
  /// **'অনুরোধের উত্তর দিন'**
  String get swapResponseTitle;

  /// No description provided for @swapAccept.
  ///
  /// In bn, this message translates to:
  /// **'গ্রহণ করুন'**
  String get swapAccept;

  /// No description provided for @swapDecline.
  ///
  /// In bn, this message translates to:
  /// **'না করুন'**
  String get swapDecline;

  /// No description provided for @swapDeclineReasonTitle.
  ///
  /// In bn, this message translates to:
  /// **'কেন নয়? (ঐচ্ছিক)'**
  String get swapDeclineReasonTitle;

  /// No description provided for @swapNeedsInternet.
  ///
  /// In bn, this message translates to:
  /// **'এর জন্য ইন্টারনেট দরকার।'**
  String get swapNeedsInternet;

  /// No description provided for @swapBannerCancel.
  ///
  /// In bn, this message translates to:
  /// **'অনুরোধ বাতিল করুন'**
  String get swapBannerCancel;

  /// No description provided for @needsCoverTitle.
  ///
  /// In bn, this message translates to:
  /// **'যে কাজে বদলি দরকার'**
  String get needsCoverTitle;

  /// No description provided for @needsCoverSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'যে কাজ এখনও কেউ করতে পারছে না'**
  String get needsCoverSubtitle;

  /// No description provided for @needsCoverEmpty.
  ///
  /// In bn, this message translates to:
  /// **'সব কাজেই কেউ আছেন'**
  String get needsCoverEmpty;

  /// No description provided for @needsCoverNoAccess.
  ///
  /// In bn, this message translates to:
  /// **'শুধু ম্যানেজাররা কাজ ঠিক করতে পারেন।'**
  String get needsCoverNoAccess;

  /// No description provided for @needsCoverAssign.
  ///
  /// In bn, this message translates to:
  /// **'ঠিক করুন'**
  String get needsCoverAssign;

  /// No description provided for @availabilityTitle.
  ///
  /// In bn, this message translates to:
  /// **'অনুপস্থিতি'**
  String get availabilityTitle;

  /// No description provided for @availabilitySubtitle.
  ///
  /// In bn, this message translates to:
  /// **'যে দিনগুলো আপনি নেই'**
  String get availabilitySubtitle;

  /// No description provided for @availabilityMine.
  ///
  /// In bn, this message translates to:
  /// **'আমার'**
  String get availabilityMine;

  /// No description provided for @availabilityEveryone.
  ///
  /// In bn, this message translates to:
  /// **'সবার'**
  String get availabilityEveryone;

  /// No description provided for @availabilityAdd.
  ///
  /// In bn, this message translates to:
  /// **'অনুপস্থিতি যোগ করুন'**
  String get availabilityAdd;

  /// No description provided for @availabilityEmpty.
  ///
  /// In bn, this message translates to:
  /// **'কোনো অনুপস্থিতি নেই'**
  String get availabilityEmpty;

  /// No description provided for @availabilityType.
  ///
  /// In bn, this message translates to:
  /// **'ধরন'**
  String get availabilityType;

  /// No description provided for @availabilityPickDates.
  ///
  /// In bn, this message translates to:
  /// **'তারিখ বেছে নিন'**
  String get availabilityPickDates;

  /// No description provided for @availabilityReasonHint.
  ///
  /// In bn, this message translates to:
  /// **'কারণ (৩ থেকে ২০০ অক্ষর)'**
  String get availabilityReasonHint;

  /// No description provided for @availabilitySave.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষণ করুন'**
  String get availabilitySave;

  /// No description provided for @availabilityApprove.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদন'**
  String get availabilityApprove;

  /// No description provided for @availabilityReject.
  ///
  /// In bn, this message translates to:
  /// **'বাতিল'**
  String get availabilityReject;

  /// No description provided for @availabilityCancel.
  ///
  /// In bn, this message translates to:
  /// **'অনুপস্থিতি বাতিল'**
  String get availabilityCancel;

  /// No description provided for @availabilityStatusPending.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদনের অপেক্ষায়'**
  String get availabilityStatusPending;

  /// No description provided for @availabilityStatusActive.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদিত'**
  String get availabilityStatusActive;

  /// No description provided for @availabilityStatusRejected.
  ///
  /// In bn, this message translates to:
  /// **'বাতিল হয়েছে'**
  String get availabilityStatusRejected;

  /// No description provided for @availabilityStatusCancelled.
  ///
  /// In bn, this message translates to:
  /// **'বাতিল করা হয়েছে'**
  String get availabilityStatusCancelled;

  /// No description provided for @availabilityPolicyAsk.
  ///
  /// In bn, this message translates to:
  /// **'আপনার কাজগুলো বদলি দরকার হিসেবে দেখানো হবে এবং আপনাকে ও ম্যানেজারদের জানানো হবে।'**
  String get availabilityPolicyAsk;

  /// No description provided for @availabilityPolicyAuto.
  ///
  /// In bn, this message translates to:
  /// **'প্রতিটি কাজের জন্য একজন ফাঁকা সদস্যকে বলা হবে। তিনি রাজি না হওয়া পর্যন্ত কিছু বদলাবে না।'**
  String get availabilityPolicyAuto;

  /// No description provided for @availabilityPolicySkip.
  ///
  /// In bn, this message translates to:
  /// **'একজন ম্যানেজার এই কাজগুলো বাদ দেবেন।'**
  String get availabilityPolicySkip;

  /// No description provided for @inboxBellLabel.
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞপ্তি, {count}টি অপঠিত'**
  String inboxBellLabel(String count);

  /// No description provided for @inboxSwapRequest.
  ///
  /// In bn, this message translates to:
  /// **'{name} আপনাকে {date}-এ {chore} নিতে বলছেন'**
  String inboxSwapRequest(String name, String chore, String date);

  /// No description provided for @inboxCoverRequest.
  ///
  /// In bn, this message translates to:
  /// **'{name}-এর {date}-এ {chore} কাজে বদলি দরকার'**
  String inboxCoverRequest(String name, String chore, String date);

  /// No description provided for @inboxSwapAccepted.
  ///
  /// In bn, this message translates to:
  /// **'{name} {date}-এ {chore} নিতে রাজি হয়েছেন'**
  String inboxSwapAccepted(String name, String chore, String date);

  /// No description provided for @inboxSwapDeclined.
  ///
  /// In bn, this message translates to:
  /// **'{name} {date}-এ {chore} নিতে রাজি হননি'**
  String inboxSwapDeclined(String name, String chore, String date);

  /// No description provided for @inboxSwapCancelled.
  ///
  /// In bn, this message translates to:
  /// **'{name} {date}-এর {chore} অনুরোধ বাতিল করেছেন'**
  String inboxSwapCancelled(String name, String chore, String date);

  /// No description provided for @inboxSwapExpired.
  ///
  /// In bn, this message translates to:
  /// **'{date}-এর {chore} অনুরোধের সময় শেষ হয়ে গেছে'**
  String inboxSwapExpired(String chore, String date);

  /// No description provided for @inboxReassigned.
  ///
  /// In bn, this message translates to:
  /// **'{name} {date}-এর {chore} আপনাকে দিয়েছেন'**
  String inboxReassigned(String name, String chore, String date);

  /// No description provided for @inboxMemberApproved.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারে যোগ দেওয়ার আপনার অনুরোধ অনুমোদিত হয়েছে।'**
  String get inboxMemberApproved;

  /// No description provided for @inboxChoresAssignedSummary.
  ///
  /// In bn, this message translates to:
  /// **'{name} {from} থেকে {to} পর্যন্ত আপনাকে {count}টি কাজ দিয়েছেন'**
  String inboxChoresAssignedSummary(
    String name,
    String count,
    String from,
    String to,
  );

  /// No description provided for @inboxNeedsCover.
  ///
  /// In bn, this message translates to:
  /// **'{name} {from} থেকে {to} পর্যন্ত নেই: {count}টি কাজে বদলি দরকার'**
  String inboxNeedsCover(String name, String count, String from, String to);

  /// No description provided for @inboxAbsenceApproved.
  ///
  /// In bn, this message translates to:
  /// **'{name} আপনার অনুপস্থিতি অনুমোদন করেছেন'**
  String inboxAbsenceApproved(String name);

  /// No description provided for @inboxAbsenceRejected.
  ///
  /// In bn, this message translates to:
  /// **'{name} আপনার অনুপস্থিতি বাতিল করেছেন'**
  String inboxAbsenceRejected(String name);

  /// No description provided for @inboxChoreReopened.
  ///
  /// In bn, this message translates to:
  /// **'{name} {date}-এর {chore} আবার খুলেছেন'**
  String inboxChoreReopened(String name, String chore, String date);

  /// No description provided for @inboxCommentAttention.
  ///
  /// In bn, this message translates to:
  /// **'{name} {date}-এর {chore} চিহ্নিত করেছেন'**
  String inboxCommentAttention(String name, String chore, String date);

  /// No description provided for @inboxVerificationNeeded.
  ///
  /// In bn, this message translates to:
  /// **'{name} {date}-এর {chore} শেষ করেছেন; যাচাই দরকার'**
  String inboxVerificationNeeded(String name, String chore, String date);

  /// No description provided for @swapLoadLabel.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসে {count}টি কাজ'**
  String swapLoadLabel(String count);

  /// No description provided for @swapSheetPreview.
  ///
  /// In bn, this message translates to:
  /// **'{name}-কে অনুরোধ: {date}-এ {chore} নিন'**
  String swapSheetPreview(String name, String chore, String date);

  /// No description provided for @swapReasonLabel.
  ///
  /// In bn, this message translates to:
  /// **'কারণ: {reason}'**
  String swapReasonLabel(String reason);

  /// No description provided for @swapBannerSent.
  ///
  /// In bn, this message translates to:
  /// **'{name}-কে অনুরোধ পাঠানো হয়েছে'**
  String swapBannerSent(String name);

  /// No description provided for @swapBannerForYou.
  ///
  /// In bn, this message translates to:
  /// **'{name} আপনাকে এই কাজটি নিতে বলেছেন'**
  String swapBannerForYou(String name);

  /// No description provided for @availabilityRangeLine.
  ///
  /// In bn, this message translates to:
  /// **'{from} থেকে {to}'**
  String availabilityRangeLine(String from, String to);

  /// No description provided for @availabilityAffected.
  ///
  /// In bn, this message translates to:
  /// **'এতে {count}টি কাজ প্রভাবিত হবে'**
  String availabilityAffected(String count);

  /// No description provided for @rotaTitle.
  ///
  /// In bn, this message translates to:
  /// **'দায়িত্ব বোর্ড'**
  String get rotaTitle;

  /// No description provided for @rotaSubtitle.
  ///
  /// In bn, this message translates to:
  /// **'কে কী করছেন, কতটা'**
  String get rotaSubtitle;

  /// No description provided for @rotaWeek.
  ///
  /// In bn, this message translates to:
  /// **'সপ্তাহ'**
  String get rotaWeek;

  /// No description provided for @rotaMonth.
  ///
  /// In bn, this message translates to:
  /// **'মাস'**
  String get rotaMonth;

  /// No description provided for @rotaOnDuty.
  ///
  /// In bn, this message translates to:
  /// **'আজ যাঁদের দায়িত্ব'**
  String get rotaOnDuty;

  /// No description provided for @rotaOnDutyNobody.
  ///
  /// In bn, this message translates to:
  /// **'আজ কারও কাজ নেই।'**
  String get rotaOnDutyNobody;

  /// No description provided for @rotaShareTitle.
  ///
  /// In bn, this message translates to:
  /// **'কাজের ভাগ'**
  String get rotaShareTitle;

  /// No description provided for @rotaMatrixTitle.
  ///
  /// In bn, this message translates to:
  /// **'সদস্য ও দিন'**
  String get rotaMatrixTitle;

  /// No description provided for @rotaEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এই সময়ে এখনও কোনো কাজ নেই।'**
  String get rotaEmpty;

  /// No description provided for @rotaNoAccess.
  ///
  /// In bn, this message translates to:
  /// **'কাজের ভাগ সদস্যদের জন্য লুকানো আছে।'**
  String get rotaNoAccess;

  /// No description provided for @rotaShareValue.
  ///
  /// In bn, this message translates to:
  /// **'কাজের {percent}%'**
  String rotaShareValue(String percent);

  /// No description provided for @rotaMemberStats.
  ///
  /// In bn, this message translates to:
  /// **'{assigned}টি কাজ, {done}টি শেষ'**
  String rotaMemberStats(String assigned, String done);

  /// No description provided for @rotaCovers.
  ///
  /// In bn, this message translates to:
  /// **'বদলি দিয়েছেন {given}, বদলি পেয়েছেন {received}'**
  String rotaCovers(String given, String received);

  /// No description provided for @rotaAway.
  ///
  /// In bn, this message translates to:
  /// **'{days} দিন অনুপস্থিত'**
  String rotaAway(String days);

  /// No description provided for @rotaOnDutyCount.
  ///
  /// In bn, this message translates to:
  /// **'{name}: {count}টি কাজ'**
  String rotaOnDutyCount(String name, String count);

  /// No description provided for @rotaCellLabel.
  ///
  /// In bn, this message translates to:
  /// **'{member}, {day}: {count}টি কাজ'**
  String rotaCellLabel(String member, String day, String count);

  /// No description provided for @choresDashNext.
  ///
  /// In bn, this message translates to:
  /// **'পরের কাজ: {name}'**
  String choresDashNext(String name);

  /// No description provided for @choresDashOverdueCount.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি বিলম্বিত'**
  String choresDashOverdueCount(String count);

  /// No description provided for @choresDashOverdueNone.
  ///
  /// In bn, this message translates to:
  /// **'কিছুই বিলম্বিত নয়'**
  String get choresDashOverdueNone;

  /// No description provided for @choresDashOverdueOldest.
  ///
  /// In bn, this message translates to:
  /// **'সবচেয়ে পুরোনো: {name}'**
  String choresDashOverdueOldest(String name);

  /// No description provided for @choresDashVerifyCount.
  ///
  /// In bn, this message translates to:
  /// **'যাচাইয়ের অপেক্ষায় {count}টি কাজ'**
  String choresDashVerifyCount(String count);

  /// No description provided for @choresDashWeekTitle.
  ///
  /// In bn, this message translates to:
  /// **'এই সপ্তাহ'**
  String get choresDashWeekTitle;

  /// No description provided for @choresDashWeekDay.
  ///
  /// In bn, this message translates to:
  /// **'{day}: {count}টি কাজ'**
  String choresDashWeekDay(String day, String count);

  /// No description provided for @choresNewAction.
  ///
  /// In bn, this message translates to:
  /// **'নতুন কাজ'**
  String get choresNewAction;

  /// No description provided for @choresMyTodayAction.
  ///
  /// In bn, this message translates to:
  /// **'আমার আজ'**
  String get choresMyTodayAction;

  /// No description provided for @permissionManageEngagement.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাজ, লেভেল ও বিজ্ঞপ্তির ডিফল্ট পরিচালনা'**
  String get permissionManageEngagement;

  /// No description provided for @permissionManageDashboardLayout.
  ///
  /// In bn, this message translates to:
  /// **'কোন ভূমিকা কোন ড্যাশবোর্ড কার্ড দেখবে তা ঠিক করা'**
  String get permissionManageDashboardLayout;

  /// No description provided for @dashModuleCore.
  ///
  /// In bn, this message translates to:
  /// **'পরিবার'**
  String get dashModuleCore;

  /// No description provided for @dashModuleBazar.
  ///
  /// In bn, this message translates to:
  /// **'বাজার ও ফান্ড'**
  String get dashModuleBazar;

  /// No description provided for @dashModuleChores.
  ///
  /// In bn, this message translates to:
  /// **'কাজ'**
  String get dashModuleChores;

  /// No description provided for @dashCardBudgetAlert.
  ///
  /// In bn, this message translates to:
  /// **'বাজেট সতর্কতা'**
  String get dashCardBudgetAlert;

  /// No description provided for @dashCardApprovals.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদন'**
  String get dashCardApprovals;

  /// No description provided for @dashCardChoresToday.
  ///
  /// In bn, this message translates to:
  /// **'আজকের কাজ'**
  String get dashCardChoresToday;

  /// No description provided for @dashCardChoresOverdue.
  ///
  /// In bn, this message translates to:
  /// **'বিলম্বিত কাজ'**
  String get dashCardChoresOverdue;

  /// No description provided for @dashCardChoresVerify.
  ///
  /// In bn, this message translates to:
  /// **'যাচাইয়ের অপেক্ষায়'**
  String get dashCardChoresVerify;

  /// No description provided for @dashCardBazarMonth.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসের খরচ'**
  String get dashCardBazarMonth;

  /// No description provided for @dashCardBazarFund.
  ///
  /// In bn, this message translates to:
  /// **'পারিবারিক ফান্ড'**
  String get dashCardBazarFund;

  /// No description provided for @dashCardUpcoming.
  ///
  /// In bn, this message translates to:
  /// **'আসছে'**
  String get dashCardUpcoming;

  /// No description provided for @dashCardChoresWeek.
  ///
  /// In bn, this message translates to:
  /// **'এই সপ্তাহ'**
  String get dashCardChoresWeek;

  /// No description provided for @dashCardHubLevel.
  ///
  /// In bn, this message translates to:
  /// **'হাব লেভেল'**
  String get dashCardHubLevel;

  /// No description provided for @dashCardRecentActivity.
  ///
  /// In bn, this message translates to:
  /// **'সাম্প্রতিক কার্যক্রম'**
  String get dashCardRecentActivity;

  /// No description provided for @notifChannelChoresDue.
  ///
  /// In bn, this message translates to:
  /// **'কাজের সময়'**
  String get notifChannelChoresDue;

  /// No description provided for @notifChannelChoresDueDescription.
  ///
  /// In bn, this message translates to:
  /// **'নির্ধারিত কাজের সময়ের অনুস্মারক'**
  String get notifChannelChoresDueDescription;

  /// No description provided for @notifChannelChoresOverdue.
  ///
  /// In bn, this message translates to:
  /// **'বিলম্বিত কাজ'**
  String get notifChannelChoresOverdue;

  /// No description provided for @notifChannelChoresOverdueDescription.
  ///
  /// In bn, this message translates to:
  /// **'অসম্পূর্ণ কাজের অনুস্মারক'**
  String get notifChannelChoresOverdueDescription;

  /// No description provided for @notifChannelDailySummary.
  ///
  /// In bn, this message translates to:
  /// **'সকালের সারাংশ'**
  String get notifChannelDailySummary;

  /// No description provided for @notifChannelDailySummaryDescription.
  ///
  /// In bn, this message translates to:
  /// **'আজকের কাজের সংক্ষিপ্ত তালিকা'**
  String get notifChannelDailySummaryDescription;

  /// No description provided for @notifChannelBazar.
  ///
  /// In bn, this message translates to:
  /// **'বাজার ও ফান্ড'**
  String get notifChannelBazar;

  /// No description provided for @notifChannelBazarDescription.
  ///
  /// In bn, this message translates to:
  /// **'বাজার ও ফান্ডের অনুস্মারক'**
  String get notifChannelBazarDescription;

  /// No description provided for @notifChannelFamily.
  ///
  /// In bn, this message translates to:
  /// **'পরিবার'**
  String get notifChannelFamily;

  /// No description provided for @notifChannelFamilyDescription.
  ///
  /// In bn, this message translates to:
  /// **'পরিবার-সম্পর্কিত বিজ্ঞপ্তি'**
  String get notifChannelFamilyDescription;

  /// No description provided for @notifChannelPushEvents.
  ///
  /// In bn, this message translates to:
  /// **'জরুরি বিজ্ঞপ্তি'**
  String get notifChannelPushEvents;

  /// No description provided for @notifChannelPushEventsDescription.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের গুরুত্বপূর্ণ আপডেট'**
  String get notifChannelPushEventsDescription;

  /// No description provided for @levelNameSeed.
  ///
  /// In bn, this message translates to:
  /// **'বীজ'**
  String get levelNameSeed;

  /// No description provided for @levelNameSprout.
  ///
  /// In bn, this message translates to:
  /// **'অঙ্কুর'**
  String get levelNameSprout;

  /// No description provided for @levelNameSeedling.
  ///
  /// In bn, this message translates to:
  /// **'চারা'**
  String get levelNameSeedling;

  /// No description provided for @levelNameSapling.
  ///
  /// In bn, this message translates to:
  /// **'ছোট গাছ'**
  String get levelNameSapling;

  /// No description provided for @levelNameYoungTree.
  ///
  /// In bn, this message translates to:
  /// **'তরুণ গাছ'**
  String get levelNameYoungTree;

  /// No description provided for @levelNameFlowering.
  ///
  /// In bn, this message translates to:
  /// **'ফুলের গাছ'**
  String get levelNameFlowering;

  /// No description provided for @levelNameFruiting.
  ///
  /// In bn, this message translates to:
  /// **'ফলবতী গাছ'**
  String get levelNameFruiting;

  /// No description provided for @levelNameGrandTree.
  ///
  /// In bn, this message translates to:
  /// **'মহীরুহ'**
  String get levelNameGrandTree;

  /// No description provided for @engagementVisibilityPrivate.
  ///
  /// In bn, this message translates to:
  /// **'ব্যক্তিগত'**
  String get engagementVisibilityPrivate;

  /// No description provided for @engagementVisibilityLevels.
  ///
  /// In bn, this message translates to:
  /// **'শুধু লেভেল ও ব্যাজ'**
  String get engagementVisibilityLevels;

  /// No description provided for @achievementsTitle.
  ///
  /// In bn, this message translates to:
  /// **'অর্জন'**
  String get achievementsTitle;

  /// No description provided for @celebrationTitle.
  ///
  /// In bn, this message translates to:
  /// **'আজকের কাজ সম্পন্ন!'**
  String get celebrationTitle;

  /// No description provided for @celebrationSemantics.
  ///
  /// In bn, this message translates to:
  /// **'আপনার আজকের সব কাজ সম্পন্ন হয়েছে'**
  String get celebrationSemantics;

  /// No description provided for @celebrationPointsToday.
  ///
  /// In bn, this message translates to:
  /// **'আজ পেয়েছেন {points} পয়েন্ট'**
  String celebrationPointsToday(String points);

  /// No description provided for @celebrationNewBadges.
  ///
  /// In bn, this message translates to:
  /// **'নতুন ব্যাজ'**
  String get celebrationNewBadges;

  /// No description provided for @celebrationLevelUp.
  ///
  /// In bn, this message translates to:
  /// **'আপনি নতুন লেভেলে পৌঁছেছেন!'**
  String get celebrationLevelUp;

  /// No description provided for @achievementLevel.
  ///
  /// In bn, this message translates to:
  /// **'লেভেল {level}'**
  String achievementLevel(String level);

  /// No description provided for @achievementMaxLevel.
  ///
  /// In bn, this message translates to:
  /// **'আপনি সর্বোচ্চ লেভেলে পৌঁছেছেন।'**
  String get achievementMaxLevel;

  /// No description provided for @achievementsDisabledTitle.
  ///
  /// In bn, this message translates to:
  /// **'এই পরিবারে অর্জন বন্ধ আছে।'**
  String get achievementsDisabledTitle;

  /// No description provided for @achievementPoints.
  ///
  /// In bn, this message translates to:
  /// **'{points} পয়েন্ট'**
  String achievementPoints(String points);

  /// No description provided for @achievementProgress.
  ///
  /// In bn, this message translates to:
  /// **'পরের লেভেলে যেতে {current}/{needed} পয়েন্ট'**
  String achievementProgress(String current, String needed);

  /// No description provided for @achievementStreak.
  ///
  /// In bn, this message translates to:
  /// **'বর্তমান ধারাবাহিকতা: {days} দিন'**
  String achievementStreak(String days);

  /// No description provided for @achievementBestStreak.
  ///
  /// In bn, this message translates to:
  /// **'সেরা ধারাবাহিকতা: {days} দিন'**
  String achievementBestStreak(String days);

  /// No description provided for @achievementCompleted.
  ///
  /// In bn, this message translates to:
  /// **'সম্পন্ন কাজ'**
  String get achievementCompleted;

  /// No description provided for @achievementOnTime.
  ///
  /// In bn, this message translates to:
  /// **'সময়মতো'**
  String get achievementOnTime;

  /// No description provided for @achievementCovers.
  ///
  /// In bn, this message translates to:
  /// **'অন্যের জন্য কভার'**
  String get achievementCovers;

  /// No description provided for @achievementVerified.
  ///
  /// In bn, this message translates to:
  /// **'সমস্যাহীন যাচাই'**
  String get achievementVerified;

  /// No description provided for @achievementBadges.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাজ'**
  String get achievementBadges;

  /// No description provided for @achievementEarned.
  ///
  /// In bn, this message translates to:
  /// **'অর্জিত'**
  String get achievementEarned;

  /// No description provided for @achievementLocked.
  ///
  /// In bn, this message translates to:
  /// **'এখনো অর্জিত হয়নি'**
  String get achievementLocked;

  /// No description provided for @achievementProgressCount.
  ///
  /// In bn, this message translates to:
  /// **'{current}/{needed}'**
  String achievementProgressCount(String current, String needed);

  /// No description provided for @achievementProgressPercent.
  ///
  /// In bn, this message translates to:
  /// **'{percent}% সময়মতো'**
  String achievementProgressPercent(String percent);

  /// No description provided for @badgeFreshStart.
  ///
  /// In bn, this message translates to:
  /// **'নতুন শুরু'**
  String get badgeFreshStart;

  /// No description provided for @badgeFreshStartDescription.
  ///
  /// In bn, this message translates to:
  /// **'প্রথম কাজটি সম্পন্ন করুন।'**
  String get badgeFreshStartDescription;

  /// No description provided for @badgeConsistent.
  ///
  /// In bn, this message translates to:
  /// **'ধারাবাহিক'**
  String get badgeConsistent;

  /// No description provided for @badgeConsistentDescription.
  ///
  /// In bn, this message translates to:
  /// **'{days} দিনের ধারাবাহিকতা বজায় রাখুন।'**
  String badgeConsistentDescription(String days);

  /// No description provided for @badgeReliable.
  ///
  /// In bn, this message translates to:
  /// **'নির্ভরযোগ্য'**
  String get badgeReliable;

  /// No description provided for @badgeReliableDescription.
  ///
  /// In bn, this message translates to:
  /// **'একটি সম্পূর্ণ মাসে {count}টি কাজ সময়মতো করুন।'**
  String badgeReliableDescription(String count);

  /// No description provided for @badgeHelper.
  ///
  /// In bn, this message translates to:
  /// **'সহায়ক'**
  String get badgeHelper;

  /// No description provided for @badgeHelperDescription.
  ///
  /// In bn, this message translates to:
  /// **'অন্যের জন্য {count}টি কাজ কভার করুন।'**
  String badgeHelperDescription(String count);

  /// No description provided for @badgeDetailChampion.
  ///
  /// In bn, this message translates to:
  /// **'যত্নশীল'**
  String get badgeDetailChampion;

  /// No description provided for @badgeDetailChampionDescription.
  ///
  /// In bn, this message translates to:
  /// **'সমস্যা ছাড়া {count}টি যাচাইকৃত কাজ করুন।'**
  String badgeDetailChampionDescription(String count);

  /// No description provided for @engagementPrivacyTitle.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের সঙ্গে শেয়ার'**
  String get engagementPrivacyTitle;

  /// No description provided for @engagementPrivacyExplanation.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের সদস্যরা আপনার লেভেল ও ব্যাজ দেখতে পারবেন কি না বেছে নিন।'**
  String get engagementPrivacyExplanation;

  /// No description provided for @engagementSharingSwitch.
  ///
  /// In bn, this message translates to:
  /// **'আমার লেভেল ও ব্যাজ দেখান'**
  String get engagementSharingSwitch;

  /// No description provided for @engagementSharingDescription.
  ///
  /// In bn, this message translates to:
  /// **'শুধু লেভেল ও অর্জিত ব্যাজ শেয়ার হবে। পয়েন্ট ও ব্যক্তিগত পরিসংখ্যান ব্যক্তিগত থাকবে।'**
  String get engagementSharingDescription;

  /// No description provided for @engagementFamilyLevelsTitle.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের অর্জন'**
  String get engagementFamilyLevelsTitle;

  /// No description provided for @engagementFamilyLevelsEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এখনো কেউ শেয়ার করার সিদ্ধান্ত নেননি।'**
  String get engagementFamilyLevelsEmpty;

  /// No description provided for @engagementSharedLevelAndBadges.
  ///
  /// In bn, this message translates to:
  /// **'{level} · {count}টি ব্যাজ'**
  String engagementSharedLevelAndBadges(String level, String count);

  /// No description provided for @engagementPointsNeverShared.
  ///
  /// In bn, this message translates to:
  /// **'পয়েন্ট ও ব্যক্তিগত পরিসংখ্যান কখনো শেয়ার হয় না।'**
  String get engagementPointsNeverShared;

  /// No description provided for @engagementHelpersTitle.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসের পারিবারিক সহায়তাকারী'**
  String get engagementHelpersTitle;

  /// No description provided for @engagementHelpersCount.
  ///
  /// In bn, this message translates to:
  /// **'{count}টি কভার'**
  String engagementHelpersCount(String count);

  /// No description provided for @engagementSettingsNotAllowed.
  ///
  /// In bn, this message translates to:
  /// **'শুধু পরিবারের ব্যবস্থাপকেরা এই সেটিং বদলাতে পারবেন।'**
  String get engagementSettingsNotAllowed;

  /// No description provided for @engagementSettingsSaved.
  ///
  /// In bn, this message translates to:
  /// **'অর্জনের সেটিং সংরক্ষণ করা হয়েছে।'**
  String get engagementSettingsSaved;

  /// No description provided for @engagementSettingsSaveFailed.
  ///
  /// In bn, this message translates to:
  /// **'অর্জনের সেটিং সংরক্ষণ করা যায়নি।'**
  String get engagementSettingsSaveFailed;

  /// No description provided for @engagementSettingsOffline.
  ///
  /// In bn, this message translates to:
  /// **'এই সেটিং সংরক্ষণ করতে ইন্টারনেটে যুক্ত হন।'**
  String get engagementSettingsOffline;

  /// No description provided for @engagementSettingsDiscardTitle.
  ///
  /// In bn, this message translates to:
  /// **'পরিবর্তন বাতিল করবেন?'**
  String get engagementSettingsDiscardTitle;

  /// No description provided for @engagementSettingsDiscardMessage.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষণ না করা অর্জনের পরিবর্তন হারিয়ে যাবে।'**
  String get engagementSettingsDiscardMessage;

  /// No description provided for @engagementSettingsGeneral.
  ///
  /// In bn, this message translates to:
  /// **'অর্জন'**
  String get engagementSettingsGeneral;

  /// No description provided for @engagementSettingsEnabled.
  ///
  /// In bn, this message translates to:
  /// **'লেভেল ও ব্যাজ চালু করুন'**
  String get engagementSettingsEnabled;

  /// No description provided for @engagementSettingsEnabledDescription.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের সদস্যদের অর্জনের অগ্রগতি দেখান।'**
  String get engagementSettingsEnabledDescription;

  /// No description provided for @engagementSettingsCelebrations.
  ///
  /// In bn, this message translates to:
  /// **'নতুন অর্জন উদযাপন'**
  String get engagementSettingsCelebrations;

  /// No description provided for @engagementSettingsCelebrationsDescription.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাজ বা লেভেল অর্জনে ছোট উদযাপন দেখান।'**
  String get engagementSettingsCelebrationsDescription;

  /// No description provided for @engagementSettingsHelpers.
  ///
  /// In bn, this message translates to:
  /// **'পারিবারিক সহায়তাকারী দেখান'**
  String get engagementSettingsHelpers;

  /// No description provided for @engagementSettingsHelpersDescription.
  ///
  /// In bn, this message translates to:
  /// **'আজ ও ড্যাশবোর্ডে এই মাসের সহায়তাকারীদের দেখান।'**
  String get engagementSettingsHelpersDescription;

  /// No description provided for @engagementSettingsScoring.
  ///
  /// In bn, this message translates to:
  /// **'পয়েন্ট'**
  String get engagementSettingsScoring;

  /// No description provided for @engagementSettingsEasyPoints.
  ///
  /// In bn, this message translates to:
  /// **'সহজ কাজের পয়েন্ট'**
  String get engagementSettingsEasyPoints;

  /// No description provided for @engagementSettingsNormalPoints.
  ///
  /// In bn, this message translates to:
  /// **'সাধারণ কাজের পয়েন্ট'**
  String get engagementSettingsNormalPoints;

  /// No description provided for @engagementSettingsHardPoints.
  ///
  /// In bn, this message translates to:
  /// **'কঠিন কাজের পয়েন্ট'**
  String get engagementSettingsHardPoints;

  /// No description provided for @engagementSettingsLateBonusPercent.
  ///
  /// In bn, this message translates to:
  /// **'দেরিতে শেষ করার গুণক (%)'**
  String get engagementSettingsLateBonusPercent;

  /// No description provided for @engagementSettingsVerifiedBonusPercent.
  ///
  /// In bn, this message translates to:
  /// **'যাচাইকৃত কাজের গুণক (%)'**
  String get engagementSettingsVerifiedBonusPercent;

  /// No description provided for @engagementSettingsCoverBonusPercent.
  ///
  /// In bn, this message translates to:
  /// **'কভার বোনাসের গুণক (%)'**
  String get engagementSettingsCoverBonusPercent;

  /// No description provided for @engagementSettingsLevels.
  ///
  /// In bn, this message translates to:
  /// **'লেভেল'**
  String get engagementSettingsLevels;

  /// No description provided for @engagementSettingsLevelNameBn.
  ///
  /// In bn, this message translates to:
  /// **'বাংলা লেভেলের নাম'**
  String get engagementSettingsLevelNameBn;

  /// No description provided for @engagementSettingsLevelNameEn.
  ///
  /// In bn, this message translates to:
  /// **'ইংরেজি লেভেলের নাম'**
  String get engagementSettingsLevelNameEn;

  /// No description provided for @engagementSettingsLevelPoints.
  ///
  /// In bn, this message translates to:
  /// **'প্রয়োজনীয় পয়েন্ট'**
  String get engagementSettingsLevelPoints;

  /// No description provided for @engagementSettingsAddLevel.
  ///
  /// In bn, this message translates to:
  /// **'লেভেল যোগ করুন'**
  String get engagementSettingsAddLevel;

  /// No description provided for @engagementSettingsNewLevelName.
  ///
  /// In bn, this message translates to:
  /// **'লেভেল {number}'**
  String engagementSettingsNewLevelName(String number);

  /// No description provided for @engagementSettingsRemoveLevel.
  ///
  /// In bn, this message translates to:
  /// **'লেভেল সরান'**
  String get engagementSettingsRemoveLevel;

  /// No description provided for @engagementSettingsBadgeThresholds.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাজের সীমা'**
  String get engagementSettingsBadgeThresholds;

  /// No description provided for @engagementSettingsConsistentDays.
  ///
  /// In bn, this message translates to:
  /// **'ধারাবাহিক ব্যাজের দিনের সংখ্যা'**
  String get engagementSettingsConsistentDays;

  /// No description provided for @engagementSettingsReliablePercent.
  ///
  /// In bn, this message translates to:
  /// **'নির্ভরযোগ্য ব্যাজের সময়মতো কাজের হার'**
  String get engagementSettingsReliablePercent;

  /// No description provided for @engagementSettingsReliableCount.
  ///
  /// In bn, this message translates to:
  /// **'প্রয়োজনীয় সম্পন্ন কাজ'**
  String get engagementSettingsReliableCount;

  /// No description provided for @engagementSettingsHelperCovers.
  ///
  /// In bn, this message translates to:
  /// **'সহায়ক ব্যাজের কভার সংখ্যা'**
  String get engagementSettingsHelperCovers;

  /// No description provided for @engagementSettingsDetailCount.
  ///
  /// In bn, this message translates to:
  /// **'যত্নশীল ব্যাজের যাচাইকৃত কাজ'**
  String get engagementSettingsDetailCount;

  /// No description provided for @engagementSettingsResetSection.
  ///
  /// In bn, this message translates to:
  /// **'এই অংশের ডিফল্ট ফিরিয়ে আনুন'**
  String get engagementSettingsResetSection;

  /// No description provided for @engagementSettingsVisibility.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারে দৃশ্যমানতা'**
  String get engagementSettingsVisibility;

  /// No description provided for @engagementSettingsPrivate.
  ///
  /// In bn, this message translates to:
  /// **'ব্যক্তিগত'**
  String get engagementSettingsPrivate;

  /// No description provided for @engagementSettingsLevelsOnly.
  ///
  /// In bn, this message translates to:
  /// **'শুধু লেভেল ও ব্যাজ'**
  String get engagementSettingsLevelsOnly;

  /// No description provided for @engagementSettingsVisibilityConfirmTitle.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের দৃশ্যমানতা বদলাবেন?'**
  String get engagementSettingsVisibilityConfirmTitle;

  /// No description provided for @engagementSettingsVisibilityConfirmMessage.
  ///
  /// In bn, this message translates to:
  /// **'এর ফলে সদস্যরা শেয়ার করা লেভেল ও ব্যাজ দেখতে পারবেন কি না বদলাবে। পয়েন্ট কখনো শেয়ার হয় না।'**
  String get engagementSettingsVisibilityConfirmMessage;

  /// No description provided for @engagementSettingsVisibilityAdminOnly.
  ///
  /// In bn, this message translates to:
  /// **'শুধু প্রশাসক পরিবারের দৃশ্যমানতা বদলাতে পারবেন।'**
  String get engagementSettingsVisibilityAdminOnly;

  /// No description provided for @engagementSettingsInvalidValue.
  ///
  /// In bn, this message translates to:
  /// **'সঠিক সীমার মধ্যে একটি মান লিখুন।'**
  String get engagementSettingsInvalidValue;

  /// No description provided for @activityNotificationDefaultsUpdated.
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞপ্তির ডিফল্ট বদলানো হয়েছে'**
  String get activityNotificationDefaultsUpdated;

  /// No description provided for @activityNotificationDeliveryUpdated.
  ///
  /// In bn, this message translates to:
  /// **'পুশ ও সাধারণ বিজ্ঞপ্তির সেটিং বদলানো হয়েছে'**
  String get activityNotificationDeliveryUpdated;

  /// No description provided for @activityDashboardPolicyUpdated.
  ///
  /// In bn, this message translates to:
  /// **'ড্যাশবোর্ডে কে কী দেখবে তা বদলানো হয়েছে'**
  String get activityDashboardPolicyUpdated;

  /// No description provided for @activityEngagementSettingsUpdated.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাজ ও লেভেলের সেটিং বদলানো হয়েছে'**
  String get activityEngagementSettingsUpdated;

  /// No description provided for @activityEngagementPrivacyUpdated.
  ///
  /// In bn, this message translates to:
  /// **'পরিসংখ্যান শেয়ারিং: {visibility}'**
  String activityEngagementPrivacyUpdated(String visibility);

  /// No description provided for @notificationFailure_invalid_minutes.
  ///
  /// In bn, this message translates to:
  /// **'১ থেকে ১৪৪০ এর মধ্যে মিনিট লিখুন।'**
  String get notificationFailure_invalid_minutes;

  /// No description provided for @notificationFailure_invalid_offsets.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ডারের একটি সময় সঠিক নয়।'**
  String get notificationFailure_invalid_offsets;

  /// No description provided for @notificationFailure_too_many_offsets.
  ///
  /// In bn, this message translates to:
  /// **'সর্বোচ্চ ৫টি রিমাইন্ডার দেওয়া যায়।'**
  String get notificationFailure_too_many_offsets;

  /// No description provided for @notificationFailure_invalid_quiet_hours.
  ///
  /// In bn, this message translates to:
  /// **'নীরব সময় সঠিক নয়।'**
  String get notificationFailure_invalid_quiet_hours;

  /// No description provided for @notificationFailure_unknown_notification_type.
  ///
  /// In bn, this message translates to:
  /// **'এই ধরনের বিজ্ঞপ্তি চেনা যায়নি।'**
  String get notificationFailure_unknown_notification_type;

  /// No description provided for @notificationFailure_type_not_push_capable.
  ///
  /// In bn, this message translates to:
  /// **'এই বিজ্ঞপ্তি পুশ হিসেবে পাঠানো যায় না।'**
  String get notificationFailure_type_not_push_capable;

  /// No description provided for @notificationFailure_permission_denied_by_os.
  ///
  /// In bn, this message translates to:
  /// **'ফোনের সেটিংসে এই অ্যাপের বিজ্ঞপ্তি বন্ধ আছে।'**
  String get notificationFailure_permission_denied_by_os;

  /// No description provided for @notificationFailure_exact_alarm_denied.
  ///
  /// In bn, this message translates to:
  /// **'এই ফোনে সঠিক সময়ের রিমাইন্ডার চালু নেই। রিমাইন্ডার কিছুটা দেরিতে আসতে পারে।'**
  String get notificationFailure_exact_alarm_denied;

  /// No description provided for @notificationFailure_scheduler_unavailable.
  ///
  /// In bn, this message translates to:
  /// **'এই ফোনে রিমাইন্ডার ঠিক করা যায়নি।'**
  String get notificationFailure_scheduler_unavailable;

  /// No description provided for @notificationFailure_push_unavailable.
  ///
  /// In bn, this message translates to:
  /// **'এখন পুশ বিজ্ঞপ্তি পাওয়া যাচ্ছে না।'**
  String get notificationFailure_push_unavailable;

  /// No description provided for @notificationFailure_inboxItem.
  ///
  /// In bn, this message translates to:
  /// **'এই বিজ্ঞপ্তিটি খুঁজে পাওয়া যায়নি।'**
  String get notificationFailure_inboxItem;

  /// No description provided for @notificationSettingsTitle.
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞপ্তি ও রিমাইন্ডার'**
  String get notificationSettingsTitle;

  /// No description provided for @notificationHelpTitle.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ডার কাজ না করলে'**
  String get notificationHelpTitle;

  /// No description provided for @notificationDeliveryTitle.
  ///
  /// In bn, this message translates to:
  /// **'পুশ নাকি সাধারণ বিজ্ঞপ্তি'**
  String get notificationDeliveryTitle;

  /// No description provided for @notificationCategoryChores.
  ///
  /// In bn, this message translates to:
  /// **'কাজ'**
  String get notificationCategoryChores;

  /// No description provided for @notificationCategoryBazar.
  ///
  /// In bn, this message translates to:
  /// **'বাজার ও অর্থ'**
  String get notificationCategoryBazar;

  /// No description provided for @notificationCategoryFamily.
  ///
  /// In bn, this message translates to:
  /// **'পরিবার'**
  String get notificationCategoryFamily;

  /// No description provided for @notificationTemplateHint.
  ///
  /// In bn, this message translates to:
  /// **'প্রতিটি কাজের রিমাইন্ডার তার টেমপ্লেট থেকেও বদলানো যায়।'**
  String get notificationTemplateHint;

  /// No description provided for @notificationDefaultOffsets.
  ///
  /// In bn, this message translates to:
  /// **'কাজের কতক্ষণ আগে মনে করাবেন'**
  String get notificationDefaultOffsets;

  /// No description provided for @notificationCustomOffset.
  ///
  /// In bn, this message translates to:
  /// **'মিনিট লিখুন (১–১৪৪০)'**
  String get notificationCustomOffset;

  /// No description provided for @notificationAddOffset.
  ///
  /// In bn, this message translates to:
  /// **'সময় যোগ করুন'**
  String get notificationAddOffset;

  /// No description provided for @notificationInvalidOffset.
  ///
  /// In bn, this message translates to:
  /// **'১–১৪৪০-এর মধ্যে নতুন একটি সময় লিখুন।'**
  String get notificationInvalidOffset;

  /// No description provided for @notificationOverdue.
  ///
  /// In bn, this message translates to:
  /// **'কাজ বাকি থাকলে পরে আবার মনে করান'**
  String get notificationOverdue;

  /// No description provided for @notificationQuietHours.
  ///
  /// In bn, this message translates to:
  /// **'নীরব সময়'**
  String get notificationQuietHours;

  /// No description provided for @notificationQuietStarts.
  ///
  /// In bn, this message translates to:
  /// **'শুরু'**
  String get notificationQuietStarts;

  /// No description provided for @notificationQuietEnds.
  ///
  /// In bn, this message translates to:
  /// **'শেষ'**
  String get notificationQuietEnds;

  /// No description provided for @notificationMorningSummary.
  ///
  /// In bn, this message translates to:
  /// **'সকালের কাজের সারাংশ'**
  String get notificationMorningSummary;

  /// No description provided for @notificationSummaryTime.
  ///
  /// In bn, this message translates to:
  /// **'সময়: {time}'**
  String notificationSummaryTime(String time);

  /// No description provided for @notificationAllEnabled.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ডার চালু'**
  String get notificationAllEnabled;

  /// No description provided for @notificationMasterExplanation.
  ///
  /// In bn, this message translates to:
  /// **'বন্ধ করলে সব বিভাগের রিমাইন্ডার থামবে; সময়সূচি সংরক্ষিত থাকবে।'**
  String get notificationMasterExplanation;

  /// No description provided for @notificationMasterOffReason.
  ///
  /// In bn, this message translates to:
  /// **'সব রিমাইন্ডার বন্ধ থাকায় এই বিভাগের রিমাইন্ডারও আসবে না।'**
  String get notificationMasterOffReason;

  /// No description provided for @notificationCategoryOffReason.
  ///
  /// In bn, this message translates to:
  /// **'এই বিভাগের রিমাইন্ডার বন্ধ আছে।'**
  String get notificationCategoryOffReason;

  /// No description provided for @notificationPushOnPhone.
  ///
  /// In bn, this message translates to:
  /// **'এই ফোনে পুশ বিজ্ঞপ্তি নিন'**
  String get notificationPushOnPhone;

  /// No description provided for @notificationSenderSparkHint.
  ///
  /// In bn, this message translates to:
  /// **'পুশ পাঠানোর ব্যবস্থা নেই (বিনামূল্যের প্ল্যান); এই ফোনের রিমাইন্ডার চলবে।'**
  String get notificationSenderSparkHint;

  /// No description provided for @notificationPushAdminOff.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের প্রশাসক পুশ বন্ধ রেখেছেন।'**
  String get notificationPushAdminOff;

  /// No description provided for @notificationPushSavedInactive.
  ///
  /// In bn, this message translates to:
  /// **'পুশ সেটিং সংরক্ষিত আছে, তবে পুশ চালু না হওয়া পর্যন্ত এটি ব্যবহার হবে না।'**
  String get notificationPushSavedInactive;

  /// No description provided for @notificationPushDisabledHere.
  ///
  /// In bn, this message translates to:
  /// **'এই ফোনে পুশ বন্ধ আছে।'**
  String get notificationPushDisabledHere;

  /// No description provided for @notificationPush.
  ///
  /// In bn, this message translates to:
  /// **'পুশ'**
  String get notificationPush;

  /// No description provided for @notificationNormal.
  ///
  /// In bn, this message translates to:
  /// **'সাধারণ'**
  String get notificationNormal;

  /// No description provided for @notificationFamilyDefaults.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের ডিফল্ট'**
  String get notificationFamilyDefaults;

  /// No description provided for @notificationPermissionChecking.
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞপ্তির অনুমতি দেখা হচ্ছে…'**
  String get notificationPermissionChecking;

  /// No description provided for @notificationPermissionUnavailable.
  ///
  /// In bn, this message translates to:
  /// **'ফোনের অনুমতির তথ্য পাওয়া যায়নি।'**
  String get notificationPermissionUnavailable;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In bn, this message translates to:
  /// **'এই অ্যাপের বিজ্ঞপ্তি বন্ধ আছে।'**
  String get notificationPermissionDenied;

  /// No description provided for @notificationExactAlarmMissing.
  ///
  /// In bn, this message translates to:
  /// **'সঠিক সময়ের অ্যালার্ম বন্ধ; রিমাইন্ডার দেরিতে আসতে পারে।'**
  String get notificationExactAlarmMissing;

  /// No description provided for @notificationPermissionGranted.
  ///
  /// In bn, this message translates to:
  /// **'চালু'**
  String get notificationPermissionGranted;

  /// No description provided for @notificationAllow.
  ///
  /// In bn, this message translates to:
  /// **'অনুমতি দিন'**
  String get notificationAllow;

  /// No description provided for @notificationAllowExactAlarms.
  ///
  /// In bn, this message translates to:
  /// **'অ্যালার্ম চালু করুন'**
  String get notificationAllowExactAlarms;

  /// No description provided for @notificationSaveFailed.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষণ করা যায়নি। ইন্টারনেট সংযোগ দেখে আবার চেষ্টা করুন।'**
  String get notificationSaveFailed;

  /// No description provided for @notificationTestTitle.
  ///
  /// In bn, this message translates to:
  /// **'ফ্যামিলি হাব পরীক্ষা'**
  String get notificationTestTitle;

  /// No description provided for @notificationTestBody.
  ///
  /// In bn, this message translates to:
  /// **'এটি আপনার পরীক্ষামূলক রিমাইন্ডার।'**
  String get notificationTestBody;

  /// No description provided for @notificationTestScheduled.
  ///
  /// In bn, this message translates to:
  /// **'১০ সেকেন্ডের মধ্যে পরীক্ষামূলক বিজ্ঞপ্তি আসবে।'**
  String get notificationTestScheduled;

  /// No description provided for @notificationTestFailed.
  ///
  /// In bn, this message translates to:
  /// **'পরীক্ষামূলক বিজ্ঞপ্তি ঠিক করা যায়নি।'**
  String get notificationTestFailed;

  /// No description provided for @notificationTestButton.
  ///
  /// In bn, this message translates to:
  /// **'১০ সেকেন্ডে পরীক্ষামূলক বিজ্ঞপ্তি'**
  String get notificationTestButton;

  /// No description provided for @notificationUseFamilyDefaults.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের ডিফল্ট ব্যবহার করুন'**
  String get notificationUseFamilyDefaults;

  /// No description provided for @notificationAllowPush.
  ///
  /// In bn, this message translates to:
  /// **'পুশ বিজ্ঞপ্তি চালু করুন'**
  String get notificationAllowPush;

  /// No description provided for @notificationSenderUnavailable.
  ///
  /// In bn, this message translates to:
  /// **'পুশ পাঠানোর সার্ভার সেট আপ করা নেই'**
  String get notificationSenderUnavailable;

  /// No description provided for @notificationSenderChecking.
  ///
  /// In bn, this message translates to:
  /// **'পুশ ব্যবস্থা দেখা হচ্ছে…'**
  String get notificationSenderChecking;

  /// No description provided for @notificationSenderError.
  ///
  /// In bn, this message translates to:
  /// **'পুশ ব্যবস্থার অবস্থা জানা যায়নি'**
  String get notificationSenderError;

  /// No description provided for @notificationSenderReady.
  ///
  /// In bn, this message translates to:
  /// **'পুশ পাঠানোর ব্যবস্থা প্রস্তুত'**
  String get notificationSenderReady;

  /// No description provided for @notificationSenderLastFailed.
  ///
  /// In bn, this message translates to:
  /// **'সর্বশেষ পুশ পাঠানো যায়নি'**
  String get notificationSenderLastFailed;

  /// No description provided for @notificationRecommended.
  ///
  /// In bn, this message translates to:
  /// **'প্রস্তাবিত: {recommended}'**
  String notificationRecommended(String recommended);

  /// No description provided for @notificationTypeLocked.
  ///
  /// In bn, this message translates to:
  /// **'ফোনেই তৈরি হয়; সার্ভার ইভেন্ট নেই।'**
  String get notificationTypeLocked;

  /// No description provided for @notificationDiscardTitle.
  ///
  /// In bn, this message translates to:
  /// **'পরিবর্তন বাতিল করবেন?'**
  String get notificationDiscardTitle;

  /// No description provided for @notificationDiscardMessage.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষণ না করা পরিবর্তন হারিয়ে যাবে।'**
  String get notificationDiscardMessage;

  /// No description provided for @actionDiscard.
  ///
  /// In bn, this message translates to:
  /// **'বাতিল করুন'**
  String get actionDiscard;

  /// No description provided for @notificationDiagnosticsLoading.
  ///
  /// In bn, this message translates to:
  /// **'তথ্য লোড হচ্ছে…'**
  String get notificationDiagnosticsLoading;

  /// No description provided for @notificationPushUnavailable.
  ///
  /// In bn, this message translates to:
  /// **'পুশ তথ্য পাওয়া যায়নি।'**
  String get notificationPushUnavailable;

  /// No description provided for @notificationPermissionLabel.
  ///
  /// In bn, this message translates to:
  /// **'বিজ্ঞপ্তির অনুমতি'**
  String get notificationPermissionLabel;

  /// No description provided for @notificationExactAlarmLabel.
  ///
  /// In bn, this message translates to:
  /// **'সঠিক সময়ের অ্যালার্ম'**
  String get notificationExactAlarmLabel;

  /// No description provided for @notificationBatteryLabel.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাটারি সীমাবদ্ধতা'**
  String get notificationBatteryLabel;

  /// No description provided for @notificationOpenSettings.
  ///
  /// In bn, this message translates to:
  /// **'ফোনের সেটিংস খুলুন'**
  String get notificationOpenSettings;

  /// No description provided for @notificationPendingCount.
  ///
  /// In bn, this message translates to:
  /// **'অপেক্ষমাণ রিমাইন্ডার'**
  String get notificationPendingCount;

  /// No description provided for @notificationNextScheduled.
  ///
  /// In bn, this message translates to:
  /// **'পরের নির্ধারিত রিমাইন্ডার'**
  String get notificationNextScheduled;

  /// No description provided for @notificationAndroidVersion.
  ///
  /// In bn, this message translates to:
  /// **'অ্যান্ড্রয়েড সংস্করণ'**
  String get notificationAndroidVersion;

  /// No description provided for @notificationPushToken.
  ///
  /// In bn, this message translates to:
  /// **'পুশ টোকেন'**
  String get notificationPushToken;

  /// No description provided for @notificationPushTokenPresent.
  ///
  /// In bn, this message translates to:
  /// **'এই ফোনে টোকেন আছে'**
  String get notificationPushTokenPresent;

  /// No description provided for @notificationPushTokenMissing.
  ///
  /// In bn, this message translates to:
  /// **'এই ফোনে পুশ টোকেন নেই'**
  String get notificationPushTokenMissing;

  /// No description provided for @notificationLastPushReceived.
  ///
  /// In bn, this message translates to:
  /// **'শেষ পুশ পাওয়ার সময়'**
  String get notificationLastPushReceived;

  /// No description provided for @notificationNever.
  ///
  /// In bn, this message translates to:
  /// **'এখনও হয়নি'**
  String get notificationNever;

  /// No description provided for @notificationTimezone.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের সময় অঞ্চল'**
  String get notificationTimezone;

  /// No description provided for @notificationLastError.
  ///
  /// In bn, this message translates to:
  /// **'সর্বশেষ ত্রুটি'**
  String get notificationLastError;

  /// No description provided for @notificationReminderError.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ডার নির্ধারণের ত্রুটি'**
  String get notificationReminderError;

  /// No description provided for @notificationHelpIntro.
  ///
  /// In bn, this message translates to:
  /// **'ফোনের অনুমতি ও নির্ধারিত রিমাইন্ডারের অবস্থা দেখুন।'**
  String get notificationHelpIntro;

  /// No description provided for @notificationChecklistTitle.
  ///
  /// In bn, this message translates to:
  /// **'যা পরীক্ষা করবেন'**
  String get notificationChecklistTitle;

  /// No description provided for @notificationChecklistAllow.
  ///
  /// In bn, this message translates to:
  /// **'Family Hub-এর বিজ্ঞপ্তির অনুমতি দিন।'**
  String get notificationChecklistAllow;

  /// No description provided for @notificationChecklistAlarms.
  ///
  /// In bn, this message translates to:
  /// **'সঠিক অ্যালার্মের অনুমতি দিন।'**
  String get notificationChecklistAlarms;

  /// No description provided for @notificationChecklistBattery.
  ///
  /// In bn, this message translates to:
  /// **'Family Hub-এর ব্যাটারি সীমাবদ্ধতা সরান।'**
  String get notificationChecklistBattery;

  /// No description provided for @notificationChecklistForceStop.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাপটি জোর করে বন্ধ করবেন না।'**
  String get notificationChecklistForceStop;

  /// No description provided for @notificationChecklistOpen.
  ///
  /// In bn, this message translates to:
  /// **'নতুন তথ্য লোড করতে দিনে অন্তত একবার অ্যাপ খুলুন।'**
  String get notificationChecklistOpen;

  /// No description provided for @notificationNoSenderHonesty.
  ///
  /// In bn, this message translates to:
  /// **'রিমাইন্ডার এই ফোনে লোড হওয়া তথ্য থেকে নির্ধারিত হয়। অন্য কেউ কাজ দিলে বা অদলবদলের অনুরোধ করলে, অ্যাপ বন্ধ থাকলে তা খুললে দেখা যাবে। বিনামূল্যের প্ল্যানে পুশ পাঠানোর ব্যবস্থা নেই।'**
  String get notificationNoSenderHonesty;

  /// No description provided for @notificationResetRecommended.
  ///
  /// In bn, this message translates to:
  /// **'প্রস্তাবিত সেটিং ফিরিয়ে আনুন'**
  String get notificationResetRecommended;

  /// No description provided for @notificationTypeSwapRequest.
  ///
  /// In bn, this message translates to:
  /// **'কাজ অদলবদলের অনুরোধ'**
  String get notificationTypeSwapRequest;

  /// No description provided for @notificationTypeSwapResult.
  ///
  /// In bn, this message translates to:
  /// **'অদলবদলের সিদ্ধান্ত'**
  String get notificationTypeSwapResult;

  /// No description provided for @notificationTypeNeedsCover.
  ///
  /// In bn, this message translates to:
  /// **'কাজের জন্য বিকল্প দরকার'**
  String get notificationTypeNeedsCover;

  /// No description provided for @notificationTypeChoreAssigned.
  ///
  /// In bn, this message translates to:
  /// **'নতুন কাজ বরাদ্দ'**
  String get notificationTypeChoreAssigned;

  /// No description provided for @notificationTypeChoreReopened.
  ///
  /// In bn, this message translates to:
  /// **'কাজ আবার খোলা হয়েছে'**
  String get notificationTypeChoreReopened;

  /// No description provided for @notificationTypeCommentAttention.
  ///
  /// In bn, this message translates to:
  /// **'মন্তব্যে মনোযোগ দরকার'**
  String get notificationTypeCommentAttention;

  /// No description provided for @notificationTypeVerificationNeeded.
  ///
  /// In bn, this message translates to:
  /// **'কাজ যাচাই দরকার'**
  String get notificationTypeVerificationNeeded;

  /// No description provided for @notificationTypeAbsenceDecision.
  ///
  /// In bn, this message translates to:
  /// **'অনুপস্থিতির সিদ্ধান্ত'**
  String get notificationTypeAbsenceDecision;

  /// No description provided for @notificationTypeMemberJoinRequest.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারে যোগদানের অনুরোধ'**
  String get notificationTypeMemberJoinRequest;

  /// No description provided for @notificationTypeMemberApproved.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারে যোগ অনুমোদিত'**
  String get notificationTypeMemberApproved;

  /// No description provided for @notificationTypeChoreDue.
  ///
  /// In bn, this message translates to:
  /// **'কাজের সময়'**
  String get notificationTypeChoreDue;

  /// No description provided for @notificationTypeChoreOverdue.
  ///
  /// In bn, this message translates to:
  /// **'বিলম্বিত কাজ'**
  String get notificationTypeChoreOverdue;

  /// No description provided for @notificationTypeEveningNudge.
  ///
  /// In bn, this message translates to:
  /// **'সন্ধ্যার মনে করানো'**
  String get notificationTypeEveningNudge;

  /// No description provided for @notificationTypeMorningSummary.
  ///
  /// In bn, this message translates to:
  /// **'সকালের সারাংশ'**
  String get notificationTypeMorningSummary;

  /// No description provided for @notificationTypeContributionDue.
  ///
  /// In bn, this message translates to:
  /// **'চাঁদা দেওয়ার সময়'**
  String get notificationTypeContributionDue;

  /// No description provided for @notificationTypeMonthEnd.
  ///
  /// In bn, this message translates to:
  /// **'মাস শেষের স্মরণ'**
  String get notificationTypeMonthEnd;

  /// No description provided for @notificationTypeBudgetAlert.
  ///
  /// In bn, this message translates to:
  /// **'বাজেট সতর্কতা'**
  String get notificationTypeBudgetAlert;

  /// No description provided for @notificationTypeAchievement.
  ///
  /// In bn, this message translates to:
  /// **'অর্জন'**
  String get notificationTypeAchievement;

  /// No description provided for @reminderWhyNext.
  ///
  /// In bn, this message translates to:
  /// **'পরের রিমাইন্ডার: {time}'**
  String reminderWhyNext(String time);

  /// No description provided for @reminderWhyPush.
  ///
  /// In bn, this message translates to:
  /// **'এটি পুশ হিসেবে পাঠানো হবে।'**
  String get reminderWhyPush;

  /// No description provided for @reminderWhyGlobalOff.
  ///
  /// In bn, this message translates to:
  /// **'সব রিমাইন্ডার বন্ধ আছে।'**
  String get reminderWhyGlobalOff;

  /// No description provided for @reminderWhyCategoryOff.
  ///
  /// In bn, this message translates to:
  /// **'এই বিভাগের রিমাইন্ডার বন্ধ আছে।'**
  String get reminderWhyCategoryOff;

  /// No description provided for @reminderWhyTemplateOff.
  ///
  /// In bn, this message translates to:
  /// **'এই কাজের টেমপ্লেটে রিমাইন্ডার বন্ধ আছে।'**
  String get reminderWhyTemplateOff;

  /// No description provided for @reminderWhyTemplateNoTimings.
  ///
  /// In bn, this message translates to:
  /// **'এই কাজের জন্য কোনো রিমাইন্ডারের সময় দেওয়া নেই।'**
  String get reminderWhyTemplateNoTimings;

  /// No description provided for @reminderWhyNotAssigned.
  ///
  /// In bn, this message translates to:
  /// **'এই কাজটি আপনাকে বরাদ্দ করা হয়নি।'**
  String get reminderWhyNotAssigned;

  /// No description provided for @reminderWhyNotOpen.
  ///
  /// In bn, this message translates to:
  /// **'কাজটি আর খোলা নেই।'**
  String get reminderWhyNotOpen;

  /// No description provided for @reminderWhyUnavailable.
  ///
  /// In bn, this message translates to:
  /// **'এই কাজের জন্য বিকল্প দরকার।'**
  String get reminderWhyUnavailable;

  /// No description provided for @reminderWhyProjectedPast.
  ///
  /// In bn, this message translates to:
  /// **'এই পরিকল্পিত কাজের সময় পেরিয়ে গেছে।'**
  String get reminderWhyProjectedPast;

  /// No description provided for @reminderWhyNoUpcoming.
  ///
  /// In bn, this message translates to:
  /// **'এখন থেকে নির্ধারিত কোনো রিমাইন্ডার নেই।'**
  String get reminderWhyNoUpcoming;

  /// No description provided for @reminderDueTitle.
  ///
  /// In bn, this message translates to:
  /// **'{choreName} করার সময় হয়েছে'**
  String reminderDueTitle(String choreName);

  /// No description provided for @reminderDueBody.
  ///
  /// In bn, this message translates to:
  /// **'{choreName} কাজটি {time}-এর মধ্যে করুন।'**
  String reminderDueBody(String choreName, String time);

  /// No description provided for @reminderBeforeTitle.
  ///
  /// In bn, this message translates to:
  /// **'{choreName} কাজটির কথা মনে করিয়ে দিচ্ছি'**
  String reminderBeforeTitle(String choreName);

  /// No description provided for @reminderBeforeBody.
  ///
  /// In bn, this message translates to:
  /// **'{choreName} কাজটি {minutes} মিনিট পরে, {time}-এ করতে হবে।'**
  String reminderBeforeBody(String choreName, String minutes, String time);

  /// No description provided for @reminderOverdueTitle.
  ///
  /// In bn, this message translates to:
  /// **'বাকি আছে: {choreName}'**
  String reminderOverdueTitle(String choreName);

  /// No description provided for @reminderOverdueBody.
  ///
  /// In bn, this message translates to:
  /// **'{choreName} কাজটি এখনো সম্পন্ন হয়নি।'**
  String reminderOverdueBody(String choreName);

  /// No description provided for @reminderNudgeTitle.
  ///
  /// In bn, this message translates to:
  /// **'আজকের কাজের কথা'**
  String get reminderNudgeTitle;

  /// No description provided for @reminderNudgeBody.
  ///
  /// In bn, this message translates to:
  /// **'আজ আরও {count}টি কাজ বাকি আছে।'**
  String reminderNudgeBody(String count);

  /// No description provided for @reminderSummaryTitle.
  ///
  /// In bn, this message translates to:
  /// **'আজকের কাজ'**
  String get reminderSummaryTitle;

  /// No description provided for @reminderSummaryBody.
  ///
  /// In bn, this message translates to:
  /// **'আজ আপনার {count}টি কাজ আছে।'**
  String reminderSummaryBody(String count);

  /// No description provided for @reminderContributionDueTitle.
  ///
  /// In bn, this message translates to:
  /// **'মাসিক জমার কথা'**
  String get reminderContributionDueTitle;

  /// No description provided for @reminderContributionDueBody.
  ///
  /// In bn, this message translates to:
  /// **'আপনার এই মাসের জমা দেওয়ার সময় হয়েছে।'**
  String get reminderContributionDueBody;

  /// No description provided for @reminderMonthEndTitle.
  ///
  /// In bn, this message translates to:
  /// **'মাস শেষের হিসাব'**
  String get reminderMonthEndTitle;

  /// No description provided for @reminderMonthEndBody.
  ///
  /// In bn, this message translates to:
  /// **'এই মাসের বাজারের হিসাব বন্ধ করার সময় হয়েছে।'**
  String get reminderMonthEndBody;

  /// No description provided for @engagementFailure_invalid_levels.
  ///
  /// In bn, this message translates to:
  /// **'লেভেলের তালিকা সঠিক নয়।'**
  String get engagementFailure_invalid_levels;

  /// No description provided for @engagementFailure_levels_not_ascending.
  ///
  /// In bn, this message translates to:
  /// **'প্রতিটি লেভেলে আগেরটির চেয়ে বেশি পয়েন্ট লাগবে।'**
  String get engagementFailure_levels_not_ascending;

  /// No description provided for @engagementFailure_too_many_levels.
  ///
  /// In bn, this message translates to:
  /// **'সর্বোচ্চ ১২টি লেভেল রাখা যায়।'**
  String get engagementFailure_too_many_levels;

  /// No description provided for @engagementFailure_invalid_threshold.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাজের একটি সীমা সঠিক নয়।'**
  String get engagementFailure_invalid_threshold;

  /// No description provided for @engagementFailure_invalid_points.
  ///
  /// In bn, this message translates to:
  /// **'পয়েন্টের একটি মান সঠিক নয়।'**
  String get engagementFailure_invalid_points;

  /// No description provided for @engagementFailure_invalid_permille.
  ///
  /// In bn, this message translates to:
  /// **'শতাংশের একটি মান সঠিক নয়।'**
  String get engagementFailure_invalid_permille;

  /// No description provided for @engagementFailure_invalid_visibility.
  ///
  /// In bn, this message translates to:
  /// **'শেয়ারিংয়ের এই পছন্দটি সঠিক নয়।'**
  String get engagementFailure_invalid_visibility;

  /// No description provided for @engagementFailure_stats_not_owner.
  ///
  /// In bn, this message translates to:
  /// **'এই পরিসংখ্যান শুধু এর মালিকই বদলাতে পারেন।'**
  String get engagementFailure_stats_not_owner;

  /// No description provided for @engagementFailure_stats_regression.
  ///
  /// In bn, this message translates to:
  /// **'এই পরিসংখ্যান আপডেট করা যায়নি।'**
  String get engagementFailure_stats_regression;

  /// No description provided for @engagementFailure_engagement_disabled.
  ///
  /// In bn, this message translates to:
  /// **'এই পরিবারে ব্যাজ ও লেভেল বন্ধ আছে।'**
  String get engagementFailure_engagement_disabled;

  /// No description provided for @engagementFailure_already_celebrated.
  ///
  /// In bn, this message translates to:
  /// **'আজকের উদযাপন আগেই দেখানো হয়েছে।'**
  String get engagementFailure_already_celebrated;

  /// No description provided for @engagementFailure_sharing_not_allowed.
  ///
  /// In bn, this message translates to:
  /// **'এই পরিবারে শেয়ারিং চালু নেই।'**
  String get engagementFailure_sharing_not_allowed;

  /// No description provided for @engagementFailure_memberStats.
  ///
  /// In bn, this message translates to:
  /// **'এই পরিসংখ্যান খুঁজে পাওয়া যায়নি।'**
  String get engagementFailure_memberStats;

  /// No description provided for @dashboardFailure_unknown_card.
  ///
  /// In bn, this message translates to:
  /// **'এই ড্যাশবোর্ড কার্ডটি চেনা যায়নি।'**
  String get dashboardFailure_unknown_card;

  /// No description provided for @dashboardFailure_invalid_access.
  ///
  /// In bn, this message translates to:
  /// **'প্রবেশাধিকারের এই পছন্দটি সঠিক নয়।'**
  String get dashboardFailure_invalid_access;

  /// No description provided for @greetingMorning.
  ///
  /// In bn, this message translates to:
  /// **'সুপ্রভাত'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In bn, this message translates to:
  /// **'শুভ অপরাহ্ণ'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In bn, this message translates to:
  /// **'শুভ সন্ধ্যা'**
  String get greetingEvening;

  /// No description provided for @greetingDefaultName.
  ///
  /// In bn, this message translates to:
  /// **'আপনি'**
  String get greetingDefaultName;

  /// No description provided for @dashboardBellOverflow.
  ///
  /// In bn, this message translates to:
  /// **'৯+'**
  String get dashboardBellOverflow;

  /// No description provided for @dashboardMenu.
  ///
  /// In bn, this message translates to:
  /// **'ড্যাশবোর্ডের বিকল্প'**
  String get dashboardMenu;

  /// No description provided for @dashboardCustomize.
  ///
  /// In bn, this message translates to:
  /// **'ড্যাশবোর্ড সাজান'**
  String get dashboardCustomize;

  /// No description provided for @dashboardAccess.
  ///
  /// In bn, this message translates to:
  /// **'ভূমিকা অনুযায়ী ড্যাশবোর্ড'**
  String get dashboardAccess;

  /// No description provided for @dashboardEmptyTitle.
  ///
  /// In bn, this message translates to:
  /// **'আপনার ড্যাশবোর্ড খালি'**
  String get dashboardEmptyTitle;

  /// No description provided for @dashboardEmptyMessage.
  ///
  /// In bn, this message translates to:
  /// **'কোন কার্ড দেখাবেন বেছে নিয়ে নিজের মতো সাজিয়ে নিন।'**
  String get dashboardEmptyMessage;

  /// No description provided for @dashboardUpcomingTitle.
  ///
  /// In bn, this message translates to:
  /// **'আসন্ন কাজ'**
  String get dashboardUpcomingTitle;

  /// No description provided for @dashboardUpcomingEmpty.
  ///
  /// In bn, this message translates to:
  /// **'আপনার জন্য সামনে কোনো কাজ নেই।'**
  String get dashboardUpcomingEmpty;

  /// No description provided for @dashboardApprovalsTitle.
  ///
  /// In bn, this message translates to:
  /// **'আপনার মনোযোগ প্রয়োজন'**
  String get dashboardApprovalsTitle;

  /// No description provided for @dashboardPendingJoinRequests.
  ///
  /// In bn, this message translates to:
  /// **'যোগদানের অনুরোধ: {count}'**
  String dashboardPendingJoinRequests(String count);

  /// No description provided for @dashboardPendingContributions.
  ///
  /// In bn, this message translates to:
  /// **'চাঁদার অনুরোধ: {count}'**
  String dashboardPendingContributions(String count);

  /// No description provided for @dashboardRecentActivityTitle.
  ///
  /// In bn, this message translates to:
  /// **'সাম্প্রতিক কার্যকলাপ'**
  String get dashboardRecentActivityTitle;

  /// No description provided for @dashboardHubLevelTitle.
  ///
  /// In bn, this message translates to:
  /// **'হাবের স্তর'**
  String get dashboardHubLevelTitle;

  /// No description provided for @dashboardHubLevelComingSoon.
  ///
  /// In bn, this message translates to:
  /// **'পরিবারের অগ্রগতি এখানে দেখা যাবে।'**
  String get dashboardHubLevelComingSoon;

  /// No description provided for @dashboardAskAiTitle.
  ///
  /// In bn, this message translates to:
  /// **'ফ্যামিলি হাবকে জিজ্ঞেস করুন'**
  String get dashboardAskAiTitle;

  /// No description provided for @dashboardAskAiMessage.
  ///
  /// In bn, this message translates to:
  /// **'পরিবার সম্পর্কে কোনো প্রশ্ন করুন।'**
  String get dashboardAskAiMessage;

  /// No description provided for @dashboardCardBudgetAlert.
  ///
  /// In bn, this message translates to:
  /// **'বাজেট সতর্কতা'**
  String get dashboardCardBudgetAlert;

  /// No description provided for @dashboardCardApprovals.
  ///
  /// In bn, this message translates to:
  /// **'অনুমোদনের অপেক্ষায়'**
  String get dashboardCardApprovals;

  /// No description provided for @dashboardCardChoresToday.
  ///
  /// In bn, this message translates to:
  /// **'আজকের কাজ'**
  String get dashboardCardChoresToday;

  /// No description provided for @dashboardCardChoresOverdue.
  ///
  /// In bn, this message translates to:
  /// **'বকেয়া কাজ'**
  String get dashboardCardChoresOverdue;

  /// No description provided for @dashboardCardChoresVerify.
  ///
  /// In bn, this message translates to:
  /// **'যাচাইয়ের অপেক্ষায়'**
  String get dashboardCardChoresVerify;

  /// No description provided for @dashboardCardBazarMonth.
  ///
  /// In bn, this message translates to:
  /// **'মাসিক খরচ'**
  String get dashboardCardBazarMonth;

  /// No description provided for @dashboardCardBazarFund.
  ///
  /// In bn, this message translates to:
  /// **'তহবিলের স্থিতি'**
  String get dashboardCardBazarFund;

  /// No description provided for @dashboardCardUpcoming.
  ///
  /// In bn, this message translates to:
  /// **'আসন্ন কাজ'**
  String get dashboardCardUpcoming;

  /// No description provided for @dashboardCardChoresWeek.
  ///
  /// In bn, this message translates to:
  /// **'এই সপ্তাহ'**
  String get dashboardCardChoresWeek;

  /// No description provided for @dashboardCardHubLevel.
  ///
  /// In bn, this message translates to:
  /// **'হাবের স্তর'**
  String get dashboardCardHubLevel;

  /// No description provided for @dashboardCardRecentActivity.
  ///
  /// In bn, this message translates to:
  /// **'সাম্প্রতিক কার্যকলাপ'**
  String get dashboardCardRecentActivity;

  /// No description provided for @dashboardPersonalLayoutNote.
  ///
  /// In bn, this message translates to:
  /// **'এই ড্যাশবোর্ডের বিন্যাস শুধু আপনি দেখতে পাবেন।'**
  String get dashboardPersonalLayoutNote;

  /// No description provided for @dashboardHiddenCards.
  ///
  /// In bn, this message translates to:
  /// **'লুকানো কার্ড'**
  String get dashboardHiddenCards;

  /// No description provided for @dashboardAddBack.
  ///
  /// In bn, this message translates to:
  /// **'আবার যোগ করুন'**
  String get dashboardAddBack;

  /// No description provided for @dashboardMoveUp.
  ///
  /// In bn, this message translates to:
  /// **'উপরে সরান'**
  String get dashboardMoveUp;

  /// No description provided for @dashboardMoveDown.
  ///
  /// In bn, this message translates to:
  /// **'নিচে সরান'**
  String get dashboardMoveDown;

  /// No description provided for @dashboardDragCard.
  ///
  /// In bn, this message translates to:
  /// **'{card} সাজান'**
  String dashboardDragCard(Object card);

  /// No description provided for @dashboardRequired.
  ///
  /// In bn, this message translates to:
  /// **'অবশ্যক'**
  String get dashboardRequired;

  /// No description provided for @dashboardReset.
  ///
  /// In bn, this message translates to:
  /// **'ডিফল্টে ফিরুন'**
  String get dashboardReset;

  /// No description provided for @dashboardResetTitle.
  ///
  /// In bn, this message translates to:
  /// **'ড্যাশবোর্ডের বিন্যাস ফিরিয়ে দেবেন?'**
  String get dashboardResetTitle;

  /// No description provided for @dashboardResetMessage.
  ///
  /// In bn, this message translates to:
  /// **'কার্ডের ক্রম ও দৃশ্যমানতা ডিফল্টে ফিরে যাবে।'**
  String get dashboardResetMessage;

  /// No description provided for @dashboardPrefsSyncPending.
  ///
  /// In bn, this message translates to:
  /// **'বিন্যাস এই ডিভাইসে সংরক্ষিত হয়েছে; অনলাইনে এলে সিঙ্ক হবে।'**
  String get dashboardPrefsSyncPending;

  /// No description provided for @dashboardAccessInfo.
  ///
  /// In bn, this message translates to:
  /// **'সংসার ব্যবস্থাপক ও সদস্যরা কোন ড্যাশবোর্ড কার্ড দেখবেন তা বেছে নিন। অ্যাডমিন সবসময় সব উপলভ্য কার্ড দেখবেন।'**
  String get dashboardAccessInfo;

  /// No description provided for @dashboardAdminAlways.
  ///
  /// In bn, this message translates to:
  /// **'অ্যাডমিন: সবসময় দৃশ্যমান'**
  String get dashboardAdminAlways;

  /// No description provided for @dashboardPreviewTitle.
  ///
  /// In bn, this message translates to:
  /// **'যেভাবে দেখুন'**
  String get dashboardPreviewTitle;

  /// No description provided for @dashboardPreviewEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এই পূর্বরূপে কোনো কার্ড দৃশ্যমান নয়।'**
  String get dashboardPreviewEmpty;

  /// No description provided for @dashboardAccessHidden.
  ///
  /// In bn, this message translates to:
  /// **'লুকানো'**
  String get dashboardAccessHidden;

  /// No description provided for @dashboardAccessVisible.
  ///
  /// In bn, this message translates to:
  /// **'দৃশ্যমান'**
  String get dashboardAccessVisible;

  /// No description provided for @dashboardAccessOff.
  ///
  /// In bn, this message translates to:
  /// **'ডিফল্টে বন্ধ'**
  String get dashboardAccessOff;

  /// No description provided for @dashboardCardPermissionMissing.
  ///
  /// In bn, this message translates to:
  /// **'এই ভূমিকা কার্ডটির ফিচার ব্যবহার করতে পারে না।'**
  String get dashboardCardPermissionMissing;

  /// No description provided for @dashboardAccessOffline.
  ///
  /// In bn, this message translates to:
  /// **'ড্যাশবোর্ডে প্রবেশাধিকার সংরক্ষণ করতে ইন্টারনেটে যুক্ত হন।'**
  String get dashboardAccessOffline;

  /// No description provided for @dashboardSaving.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষণ হচ্ছে…'**
  String get dashboardSaving;

  /// No description provided for @dashboardAccessDenied.
  ///
  /// In bn, this message translates to:
  /// **'ড্যাশবোর্ডে প্রবেশাধিকার পরিবর্তনের অনুমতি আপনার নেই।'**
  String get dashboardAccessDenied;

  /// No description provided for @dashboardResetRecommended.
  ///
  /// In bn, this message translates to:
  /// **'প্রস্তাবিত বিন্যাসে ফিরুন'**
  String get dashboardResetRecommended;

  /// No description provided for @dashboardResetRecommendedTitle.
  ///
  /// In bn, this message translates to:
  /// **'ড্যাশবোর্ডের প্রবেশাধিকার ফিরিয়ে দেবেন?'**
  String get dashboardResetRecommendedTitle;

  /// No description provided for @dashboardResetRecommendedMessage.
  ///
  /// In bn, this message translates to:
  /// **'সব ভূমিকার প্রবেশাধিকার প্রস্তাবিত ডিফল্টে ফিরে যাবে।'**
  String get dashboardResetRecommendedMessage;

  /// No description provided for @dashboardDiscardTitle.
  ///
  /// In bn, this message translates to:
  /// **'পরিবর্তন বাতিল করবেন?'**
  String get dashboardDiscardTitle;

  /// No description provided for @dashboardDiscardMessage.
  ///
  /// In bn, this message translates to:
  /// **'সংরক্ষণ না করা ড্যাশবোর্ড প্রবেশাধিকারের পরিবর্তন হারিয়ে যাবে।'**
  String get dashboardDiscardMessage;

  /// No description provided for @dashboardDiscard.
  ///
  /// In bn, this message translates to:
  /// **'বাতিল করুন'**
  String get dashboardDiscard;

  /// No description provided for @activityTitle.
  ///
  /// In bn, this message translates to:
  /// **'কার্যকলাপ'**
  String get activityTitle;

  /// No description provided for @activityEmpty.
  ///
  /// In bn, this message translates to:
  /// **'এখনও কোনো কার্যকলাপ নেই।'**
  String get activityEmpty;

  /// No description provided for @activityNoMatches.
  ///
  /// In bn, this message translates to:
  /// **'এই ফিল্টারে কোনো কার্যকলাপ নেই।'**
  String get activityNoMatches;

  /// No description provided for @activityLoadError.
  ///
  /// In bn, this message translates to:
  /// **'কার্যকলাপ আনা যায়নি। ইন্টারনেট সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।'**
  String get activityLoadError;

  /// No description provided for @activityLoadMore.
  ///
  /// In bn, this message translates to:
  /// **'আরও দেখুন'**
  String get activityLoadMore;

  /// No description provided for @activityModuleFilter.
  ///
  /// In bn, this message translates to:
  /// **'বিভাগ'**
  String get activityModuleFilter;

  /// No description provided for @activityModuleAll.
  ///
  /// In bn, this message translates to:
  /// **'সব বিভাগ'**
  String get activityModuleAll;

  /// No description provided for @activityModuleBazar.
  ///
  /// In bn, this message translates to:
  /// **'বাজার ও অর্থ'**
  String get activityModuleBazar;

  /// No description provided for @activityModuleChores.
  ///
  /// In bn, this message translates to:
  /// **'ঘরের কাজ'**
  String get activityModuleChores;

  /// No description provided for @activityModuleFamily.
  ///
  /// In bn, this message translates to:
  /// **'পরিবার'**
  String get activityModuleFamily;

  /// No description provided for @activityModuleEngagement.
  ///
  /// In bn, this message translates to:
  /// **'ব্যাজ ও স্তর'**
  String get activityModuleEngagement;

  /// No description provided for @activityMemberFilter.
  ///
  /// In bn, this message translates to:
  /// **'সদস্য'**
  String get activityMemberFilter;

  /// No description provided for @activityMemberAll.
  ///
  /// In bn, this message translates to:
  /// **'সব সদস্য'**
  String get activityMemberAll;

  /// No description provided for @activityUnknownActor.
  ///
  /// In bn, this message translates to:
  /// **'অজানা সদস্য'**
  String get activityUnknownActor;

  /// No description provided for @choresPolicyAutoAssignTitle.
  ///
  /// In bn, this message translates to:
  /// **'স্বয়ংক্রিয় বণ্টন (ডিফল্ট)'**
  String get choresPolicyAutoAssignTitle;

  /// No description provided for @choresPolicyAutoAssignDesc.
  ///
  /// In bn, this message translates to:
  /// **'অনুপস্থিত সদস্যের কাজ অন্য উপলব্ধ সদস্যদের মধ্যে নিজে থেকেই ভাগ হয়ে যায় (আগে একই ডিউটি গ্রুপের সদস্য)। কাউকে না পেলে কাজটি \"কাভার দরকার\" তালিকায় যায়।'**
  String get choresPolicyAutoAssignDesc;

  /// No description provided for @choresPolicyAutoAssignExample.
  ///
  /// In bn, this message translates to:
  /// **'উদাহরণ: কেউ ৩ দিন অসুস্থ থাকলে তার কাজ গ্রুপের অন্য সদস্য পেয়ে যায়। ম্যানেজার চাইলে যেকোনো কাজ \"কাভার দরকার\"-এ সরাতে পারেন।'**
  String get choresPolicyAutoAssignExample;

  /// No description provided for @availabilityPolicyShare.
  ///
  /// In bn, this message translates to:
  /// **'আপনার কাজগুলো স্বয়ংক্রিয়ভাবে অন্য সদস্যদের মধ্যে ভাগ হয়ে যাবে। কাউকে না পেলে সেগুলো \"কাভার দরকার\" তালিকায় যাবে। ম্যানেজারের অ্যাপ খোলা হলে ভাগ হয়।'**
  String get availabilityPolicyShare;

  /// No description provided for @needsCoverWhyNobody.
  ///
  /// In bn, this message translates to:
  /// **'কেউ নির্ধারিত নেই'**
  String get needsCoverWhyNobody;

  /// No description provided for @needsCoverWhyAbsent.
  ///
  /// In bn, this message translates to:
  /// **'অনুপস্থিত'**
  String get needsCoverWhyAbsent;

  /// No description provided for @needsCoverShareNow.
  ///
  /// In bn, this message translates to:
  /// **'এখনই ভাগ করুন'**
  String get needsCoverShareNow;

  /// No description provided for @needsCoverShareDone.
  ///
  /// In bn, this message translates to:
  /// **'কাজগুলো অন্য সদস্যদের মধ্যে ভাগ করা হয়েছে।'**
  String get needsCoverShareDone;

  /// No description provided for @needsCoverShareNone.
  ///
  /// In bn, this message translates to:
  /// **'এখন ভাগ করার মতো কিছু পাওয়া যায়নি।'**
  String get needsCoverShareNone;

  /// No description provided for @needsCoverCommentTitle.
  ///
  /// In bn, this message translates to:
  /// **'মন্তব্য (ঐচ্ছিক)'**
  String get needsCoverCommentTitle;

  /// No description provided for @needsCoverDefaultComment.
  ///
  /// In bn, this message translates to:
  /// **'কাভার তালিকা থেকে বরাদ্দ করা হয়েছে'**
  String get needsCoverDefaultComment;

  /// No description provided for @occurrenceActionNeedsCover.
  ///
  /// In bn, this message translates to:
  /// **'কাভার দরকারে সরান'**
  String get occurrenceActionNeedsCover;

  /// No description provided for @needsCoverMoveTitle.
  ///
  /// In bn, this message translates to:
  /// **'কেন কাভার দরকার? (ঐচ্ছিক)'**
  String get needsCoverMoveTitle;

  /// No description provided for @needsCoverMoveDefaultReason.
  ///
  /// In bn, this message translates to:
  /// **'ম্যানেজার কাজটি কাভার দরকারে সরিয়েছেন'**
  String get needsCoverMoveDefaultReason;
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
