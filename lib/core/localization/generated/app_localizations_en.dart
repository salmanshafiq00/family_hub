// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Family Hub';

  @override
  String get navHome => 'Home';

  @override
  String get navChores => 'Chores';

  @override
  String get navBazar => 'Bazar';

  @override
  String get navFamily => 'Family';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionRetry => 'Retry';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionAdd => 'Add';

  @override
  String get catalogEditorEmpty => 'Nothing here yet.';

  @override
  String get catalogEditorActions => 'Row actions';

  @override
  String get catalogEditorActivate => 'Use again';

  @override
  String get catalogEditorDeactivate => 'Turn off';

  @override
  String get catalogEditorAddTitle => 'Add a row';

  @override
  String get catalogEditorEditTitle => 'Edit the row';

  @override
  String get catalogEditorLabelBn => 'Name (Bangla)';

  @override
  String get catalogEditorLabelEn => 'Name (English, optional)';

  @override
  String get actionClose => 'Close';

  @override
  String get actionBack => 'Back';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionDone => 'Done';

  @override
  String get authSignInTitle => 'Sign in';

  @override
  String get authSignUpTitle => 'Create account';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get authEmailVerificationSent => 'Verification email sent.';

  @override
  String get authWelcomeHeadline => 'Your family\'s money, in one place';

  @override
  String get authWelcomeMessage =>
      'Bazar spending, the family fund and the chore rota — managed together.';

  @override
  String get authGetStarted => 'Get started';

  @override
  String get authSignInAction => 'Sign in';

  @override
  String get authCreateAccountAction => 'Create an account';

  @override
  String get authSignInSubtitle => 'Enter with your email and password.';

  @override
  String get authSignUpSubtitle =>
      'We will send a verification email when you sign up.';

  @override
  String get authNoAccountYet => 'No account yet?';

  @override
  String get authAlreadyHaveAccount => 'Already have an account?';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authEmailHint => 'e.g. name@example.com';

  @override
  String get authPasswordHint => 'At least 8 characters';

  @override
  String get authEmailConfirmed => 'Email';

  @override
  String get authPasswordTooShortHelper => 'Use at least 8 characters.';

  @override
  String get authPasswordConfirmLabel => 'Repeat password';

  @override
  String get authFailureValidationPasswordMismatch =>
      'The two passwords do not match.';

  @override
  String get authFailureValidationPasswordConfirmRequired =>
      'Please repeat the password.';

  @override
  String get authForgotPasswordTitle => 'Reset password';

  @override
  String get authForgotPasswordSubtitle =>
      'Enter your email and we will send a reset link.';

  @override
  String get authForgotPasswordSend => 'Send reset link';

  @override
  String get authForgotPasswordSentTitle => 'Email sent';

  @override
  String authForgotPasswordSentMessage(String email) {
    return 'A reset link was sent to $email. Check your spam folder too.';
  }

  @override
  String get authVerifyEmailTitle => 'Verify your email';

  @override
  String authVerifyEmailMessage(String email) {
    return 'We sent a verification link to $email. Tap the link, then press the button below.';
  }

  @override
  String get authVerifyEmailIHaveVerified => 'I have verified';

  @override
  String get authVerifyEmailResend => 'Send the email again';

  @override
  String get authVerifyEmailStillUnverified =>
      'Not verified yet. Tap the link in the email, then try again.';

  @override
  String get authVerifyEmailVerified => 'Your email is verified.';

  @override
  String get authVerifyEmailSignOutInstead => 'Use a different account';

  @override
  String authUsingAccount(String email) {
    return 'Signed in as $email';
  }

  @override
  String get authFailurePermissionDenied =>
      'You do not have permission to do this.';

  @override
  String get authFailureNotFound => 'Your account could not be found.';

  @override
  String get authFailureConflict =>
      'Someone already changed this. Reopen the app and try again.';

  @override
  String get authFailureNetwork =>
      'No internet connection. Check your connection and try again.';

  @override
  String get authFailureInvalidCredentials =>
      'That email or password is not correct.';

  @override
  String get authFailureUserNotFound => 'There is no account for this email.';

  @override
  String get authFailureEmailInUse =>
      'An account already uses this email. Try signing in.';

  @override
  String get authFailureWeakPassword =>
      'That password is too weak. Use at least 8 characters.';

  @override
  String get authFailureTooManyRequests =>
      'Too many attempts. Please try again in a little while.';

  @override
  String get authFailureUserDisabled =>
      'This account is disabled. Talk to your family admin.';

  @override
  String get authFailureRequiresRecentLogin =>
      'For security, sign in again and then retry.';

  @override
  String get authFailureInvalidEmail => 'That email address is not valid.';

  @override
  String get authFailureNoCurrentUser =>
      'You were signed out. Please sign in again.';

  @override
  String authFailureValidationRequired(String field) {
    return 'Please fill in $field.';
  }

  @override
  String get authFailureValidationInvalidEmail =>
      'Enter a valid email address.';

  @override
  String get authFailureValidationPasswordTooShort =>
      'Password must be at least 8 characters.';

  @override
  String get authFailureUnknown => 'Something went wrong. Please try again.';

  @override
  String get authFieldEmail => 'email';

  @override
  String get authFieldPassword => 'password';

  @override
  String get errorPermissionDenied => 'You do not have permission to do this.';

  @override
  String get errorNotFound => 'That item could not be found.';

  @override
  String get errorConflict => 'Someone already changed this. Please try again.';

  @override
  String get errorNetwork =>
      'No internet connection. Check your connection and try again.';

  @override
  String get errorUnknown => 'Something went wrong. Please try again.';

  @override
  String errorValidationRequired(String field) {
    return 'Please fill in $field.';
  }

  @override
  String get errorValidationEmail => 'Enter a valid email address.';

  @override
  String get errorValidationPasswordTooShort =>
      'Password must be at least 8 characters.';

  @override
  String get emptyGenericTitle => 'Nothing here yet';

  @override
  String get emptyGenericMessage => 'Tap the button below to get started.';

  @override
  String get emptyNoDataTitle => 'No data';

  @override
  String get emptyNoDataMessage => 'This list is empty right now.';

  @override
  String get loadingGeneric => 'Loading…';

  @override
  String get offlineBanner =>
      'You are offline. Data will sync when the connection returns.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsThemeTitle => 'Appearance';

  @override
  String get settingsThemeMode => 'Theme mode';

  @override
  String get settingsColourPalette => 'Colour palette';

  @override
  String get settingsFollowDevice => 'Follow device';

  @override
  String get settingsFollowDeviceSubtitle =>
      'Uses your system light / dark setting';

  @override
  String get settingsThemeSelected => 'Selected';

  @override
  String settingsThemeSelectedSemantics(String theme) {
    return '$theme theme, selected';
  }

  @override
  String settingsThemeUnselectedSemantics(String theme) {
    return '$theme theme';
  }

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageSection => 'Choose a language';

  @override
  String get settingsLanguageBangla => 'Bangla';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageSubtitle => 'The app language changes instantly';

  @override
  String get settingsBanglaDigits => 'Use Bangla digits';

  @override
  String get settingsBanglaDigitsSubtitle =>
      'Numbers and dates shown with Bangla digits (০১২৩)';

  @override
  String settingsLanguageSelectedSemantics(String language) {
    return '$language language, selected';
  }

  @override
  String get languageNameBn => 'বাংলা';

  @override
  String get languageNameEn => 'English';

  @override
  String get devTokensTitle => 'Dev — Theme Tokens';

  @override
  String get devGalleryTitle => 'Dev — Gallery';

  @override
  String get homeViewThemeTokens => 'View Theme Tokens';

  @override
  String get moduleComingSoonTitle => 'Coming soon';

  @override
  String get moduleComingSoonMessage => 'This section is still being built.';

  @override
  String get bazarHomeEmptyTitle => 'Bazar is empty';

  @override
  String get bazarHomeEmptyMessage =>
      'Expenses, shopping lists and accounts will be added here step by step.';

  @override
  String get bazarCatalogSetupTitle => 'Set up the starter catalog';

  @override
  String get bazarCatalogSetupMessage =>
      'Add 11 categories and 54 common items to get started. You can edit, add or hide them later.';

  @override
  String get bazarCatalogSetupAction => 'Set up catalog';

  @override
  String get bazarCatalogSetupBusy => 'Setting up the catalog…';

  @override
  String get bazarCatalogAskAdminTitle => 'Catalog not set up';

  @override
  String get bazarCatalogAskAdminMessage =>
      'Ask an admin to set up the catalog.';

  @override
  String get bazarSettingsTitle => 'Bazar settings';

  @override
  String get unitKg => 'kg';

  @override
  String get unitG => 'g';

  @override
  String get unitLitre => 'litre';

  @override
  String get unitPiece => 'pcs';

  @override
  String get unitDozen => 'dozen';

  @override
  String get unitPacket => 'packet';

  @override
  String get unitCylinder => 'cylinder';

  @override
  String get bazarFundingFund => 'family fund';

  @override
  String get bazarFundingMember => 'member paid';

  @override
  String get bazarAdvancePending => 'pending';

  @override
  String get bazarAdvancePartial => 'partly settled';

  @override
  String get bazarAdvanceSettled => 'settled';

  @override
  String get bazarAdvanceVoided => 'voided';

  @override
  String get bazarErrRequired => 'Please fill in this field.';

  @override
  String get bazarErrTooLong => 'This text is too long.';

  @override
  String get bazarErrInvalidAmount => 'Enter a valid amount.';

  @override
  String get bazarErrAmountNotPositive => 'The amount must be more than zero.';

  @override
  String get bazarErrFutureDate => 'The date cannot be in the future.';

  @override
  String get bazarErrQtyUnitRequired => 'Enter both a quantity and a unit.';

  @override
  String get bazarErrMemberRequired => 'Choose the member this belongs to.';

  @override
  String get bazarErrCategoryRequired => 'Choose a category.';

  @override
  String get bazarErrItemNameRequired => 'Enter the item name.';

  @override
  String get bazarErrTooManyLines => 'There are too many lines; remove some.';

  @override
  String get bazarErrInvalidMonth => 'Choose a valid month.';

  @override
  String get bazarErrInvalidRange =>
      'The end date must be after the start date.';

  @override
  String get bazarErrNegative => 'The amount cannot be below zero.';

  @override
  String get bazarErrTooManyDecimals => 'Use at most two decimal places.';

  @override
  String get bazarErrTooLarge => 'That amount is too large.';

  @override
  String get bazarErrMonthLocked =>
      'This month is closed. Ask an admin to reopen it.';

  @override
  String get bazarErrAdvanceSettled =>
      'This advance has already been partly or fully settled.';

  @override
  String get bazarErrOverpayment =>
      'The amount is more than what is still owed.';

  @override
  String get bazarErrAlreadyClosed => 'This month is already closed.';

  @override
  String get bazarErrNotClosed => 'This month is not closed.';

  @override
  String get bazarErrReopenNoteRequired =>
      'Write why the month is being reopened.';

  @override
  String get bazarErrCatalogNotEmpty =>
      'The catalog still has items; archive them first.';

  @override
  String get bazarErrDuplicateItem =>
      'A similar expense was just added. Check it before saving again.';

  @override
  String get bazarErrImportAlreadyUndone =>
      'This import has already been undone.';

  @override
  String get bazarErrImportHasLockedMonth =>
      'The file has rows in a closed month.';

  @override
  String get bazarErrConcurrentEdit =>
      'Somebody else changed this first. Reload and try again.';

  @override
  String get bazarErrNotFound =>
      'That record no longer exists. Refresh and try again.';

  @override
  String get bazarErrNotAllowed =>
      'Only the Household Manager or Admin can do this.';

  @override
  String get bazarErrUnknown => 'Something went wrong. Please try again.';

  @override
  String get profileSetupTitle => 'Set up your profile';

  @override
  String get profileSetupMessage => 'Tell your family who you are.';

  @override
  String get familyChoiceTitle => 'Join or create a family';

  @override
  String get familyChoiceMessage =>
      'Create a new family, or join one with an invitation code.';

  @override
  String get pendingTitle => 'Waiting for approval';

  @override
  String get pendingMessage =>
      'A family admin needs to approve your request before you can continue.';

  @override
  String get disabledTitle => 'Access turned off';

  @override
  String get disabledMessage =>
      'Your access to this family has been turned off. Please contact a family admin.';

  @override
  String get placeholderContinueProfile => 'Continue (temporary)';

  @override
  String get placeholderCreateFamily => 'Create a test family (temporary)';

  @override
  String get placeholderApproveMe => 'Pretend I was approved (temporary)';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notFoundMessage => 'The page you opened does not exist.';

  @override
  String get notFoundAction => 'Go to Home';

  @override
  String get profileFullName => 'Full name';

  @override
  String get profileNickname => 'Nickname (optional)';

  @override
  String get profileGender => 'Gender (optional)';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other';

  @override
  String get genderNone => 'Prefer not to say';

  @override
  String get profileRelationship => 'Relationship';

  @override
  String get profileAvatar => 'Choose an avatar';

  @override
  String get profileSave => 'Save profile';

  @override
  String get profileSpouse => 'Spouse (optional)';

  @override
  String get profileSpouseNone => 'None';

  @override
  String get relFather => 'Father';

  @override
  String get relMother => 'Mother';

  @override
  String get relSon => 'Son';

  @override
  String get relDaughter => 'Daughter';

  @override
  String get relHusband => 'Husband';

  @override
  String get relWife => 'Wife';

  @override
  String get relHousewife => 'Housewife';

  @override
  String get relDaughterInLaw => 'Daughter-in-law';

  @override
  String get relSonInLaw => 'Son-in-law';

  @override
  String get relOther => 'Other';

  @override
  String get familyCreateAction => 'Create a family';

  @override
  String get familyJoinAction => 'Join with a code';

  @override
  String get familyNameLabel => 'Family name';

  @override
  String get familyCreateSubmit => 'Create family';

  @override
  String get joinCodeLabel => 'Invitation code';

  @override
  String get joinSubmit => 'Request to join';

  @override
  String get joinHint => 'Ask a family admin for the 8-character code.';

  @override
  String get membersTitle => 'Members';

  @override
  String get membersPending => 'Waiting for approval';

  @override
  String get membersActive => 'Active';

  @override
  String get membersDisabled => 'Disabled';

  @override
  String get memberYou => 'You';

  @override
  String get memberApprove => 'Approve';

  @override
  String get memberReject => 'Reject';

  @override
  String get memberDisable => 'Disable';

  @override
  String get memberReenable => 'Re-enable';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleModerator => 'Household Manager';

  @override
  String get roleMember => 'Member';

  @override
  String get memberProfileTitle => 'Member profile';

  @override
  String get memberEditProfile => 'Edit my profile';

  @override
  String get memberRoleLabel => 'Role';

  @override
  String get memberStatusLabel => 'Status';

  @override
  String get invitationsTitle => 'Invitations';

  @override
  String get invitationCreate => 'Create invitation code';

  @override
  String get invitationCopy => 'Copy code';

  @override
  String get invitationCopied => 'Code copied';

  @override
  String get invitationExpiresOn => 'Expires';

  @override
  String get invStatusActive => 'Unused';

  @override
  String get invStatusUsed => 'Used';

  @override
  String get invStatusExpired => 'Expired';

  @override
  String get invStatusRevoked => 'Cancelled';

  @override
  String get invitationsEmpty => 'No invitations yet';

  @override
  String get rolesTitle => 'Roles';

  @override
  String get rolesMakeAdmin => 'Make admin';

  @override
  String get rolesTransferTitle => 'Transfer the admin role?';

  @override
  String get rolesTransferMessage => 'You will become a regular member.';

  @override
  String get actionConfirm => 'Confirm';

  @override
  String get familySettingsTitle => 'Family settings';

  @override
  String get settingsTimezone => 'Time zone';

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsModules => 'Modules';

  @override
  String get settingsSaved => 'Saved';

  @override
  String get famFailureNameRequired => 'Please enter a name.';

  @override
  String get famFailureCodeInvalid =>
      'That code does not look right. Codes have 8 letters and digits.';

  @override
  String get famFailureCodeNotFound => 'No invitation found for that code.';

  @override
  String get famFailureCodeUsed => 'That code was already used.';

  @override
  String get famFailureCodeExpired =>
      'That code has expired. Ask for a new one.';

  @override
  String get famFailureCodeRevoked => 'That code was cancelled.';

  @override
  String get famFailureAlreadyMember => 'You already belong to this family.';

  @override
  String get famFailureLastAdmin =>
      'A family needs at least one admin. Make someone else admin first.';

  @override
  String get famFailureTooManyAdmins =>
      'A family can have at most three admins.';

  @override
  String get famFailureNotAllowed => 'You do not have permission to do that.';

  @override
  String get famFailureProfileRequired => 'Complete your profile first.';

  @override
  String avatarOption(String number) {
    return 'Avatar $number';
  }

  @override
  String get statusScheduled => 'Scheduled';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusVerified => 'Verified';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get errorViewTitle => 'Something went wrong';

  @override
  String get loadingSemantics => 'Loading';

  @override
  String progressSemantics(String label, String percent) {
    return '$label, $percent percent complete';
  }

  @override
  String thumbSemantics(String name) {
    return 'Image of $name';
  }

  @override
  String get galleryAvatar => 'Avatar';

  @override
  String get galleryItemThumb => 'Item thumbnail';

  @override
  String get galleryStatusChip => 'Status chip';

  @override
  String get galleryStatusGlyph => 'Status glyph';

  @override
  String get galleryFlagChip => 'Flag chip';

  @override
  String get galleryReasonSheet => 'Reason sheet';

  @override
  String get galleryMinutesField => 'Time field';

  @override
  String get galleryWeekdayChips => 'Weekday picker';

  @override
  String get galleryColorSwatchPicker => 'Colour picker';

  @override
  String get galleryAvatarStack => 'Avatar stack';

  @override
  String get galleryStepProgress => 'Step progress';

  @override
  String get galleryMiniMarkdown => 'House rules text';

  @override
  String get galleryCatalogEditor => 'List editor';

  @override
  String get galleryOpenSheet => 'Open the sheet';

  @override
  String get gallerySampleDueTime => 'Due time';

  @override
  String get gallerySampleRules =>
      '# House rules\n- Wash your own plate after eating\n- **The kitchen must be clear by 9 am**\n1. Water the plants\n2. Sweep the yard';

  @override
  String get gallerySectionHeader => 'Section header';

  @override
  String get galleryAppCard => 'Card';

  @override
  String get galleryMoneyText => 'Money text';

  @override
  String get galleryProgressRing => 'Progress ring';

  @override
  String get galleryEmptyState => 'Empty state';

  @override
  String get galleryLoadingView => 'Loading view';

  @override
  String get galleryErrorView => 'Error view';

  @override
  String get galleryPillBottomBar => 'Pill navigation bar';

  @override
  String get gallerySampleTitle => 'Sample title';

  @override
  String get gallerySampleMessage =>
      'This is a sample message used to check for overflow.';

  @override
  String get gallerySampleItemName => 'Potato';

  @override
  String get gallerySamplePersonName => 'Karim Uddin';

  @override
  String get syncWaitingTitle => 'Waiting for connection…';

  @override
  String get syncWaitingMessage =>
      'Check your internet connection and try again. Your data is safe.';

  @override
  String get syncSavedOffline => 'Saved on this device – will sync when online';

  @override
  String syncBannerSyncing(int count) {
    return 'Syncing $count change(s)';
  }

  @override
  String syncBannerOffline(int count) {
    return 'Offline – $count change(s) waiting';
  }

  @override
  String get gallerySyncBanner => 'Sync banner';

  @override
  String get famFailureAlreadyInFamily =>
      'You already belong to a family. Leave it first.';

  @override
  String get familyLeave => 'Leave family';

  @override
  String get familyLeaveConfirmTitle => 'Leave this family?';

  @override
  String get familyLeaveConfirmBody =>
      'Your past activity stays in the family\'s history. Afterwards you can create or join a family again.';

  @override
  String get familyLeaveLastAdminReason =>
      'You are the only admin. Make someone else an admin before leaving.';

  @override
  String get pendingCancelRequest => 'Cancel request';

  @override
  String get invitationRevoke => 'Revoke code';

  @override
  String get invitationRevokeConfirmTitle => 'Revoke this code?';

  @override
  String get invitationRevokeConfirmBody =>
      'Nobody will be able to join with this code any more.';

  @override
  String get securityTitle => 'Security';

  @override
  String get securityChangePassword => 'Change password';

  @override
  String get securityCurrentPassword => 'Current password';

  @override
  String get securityNewPassword => 'New password';

  @override
  String get securityPasswordChanged => 'Password changed.';

  @override
  String get securityPasswordSame =>
      'The new password must differ from the current one.';

  @override
  String get securityCurrentPasswordRequired => 'Enter your current password.';

  @override
  String get securityCurrentPasswordWrong =>
      'The current password is not correct.';

  @override
  String get securityDeleteTitle => 'Delete my account';

  @override
  String get securityDeleteBody =>
      'You leave your family and your sign-in is removed. Your name stays on past records so the family history stays complete.';

  @override
  String get securityDeletePending =>
      'Deleting was not finished. Enter your password to finish.';

  @override
  String get securityDeleteAction => 'Delete account';

  @override
  String get securityDeleteFinish => 'Finish deleting';

  @override
  String get securityDeleteConfirmTitle => 'Delete your account?';

  @override
  String get securityDeleteConfirmBody => 'This cannot be undone.';

  @override
  String get accountDeleteLastAdminHasMembers =>
      'You are the only admin and others are still in the family. Transfer the admin role first.';

  @override
  String get relationshipsTitle => 'Relationships';

  @override
  String get relationshipsHint =>
      'Built-in entries are locked. You can add, rename and disable your own.';

  @override
  String get relationshipsAdd => 'Add relationship';

  @override
  String get relationshipsLabelBn => 'Name in Bangla';

  @override
  String get relationshipsLabelEn => 'Name in English';

  @override
  String get relationshipsSpouseRelevant => 'Offer the spouse picker';

  @override
  String get relationshipsBuiltIn => 'Built in';

  @override
  String get relationshipsActive => 'In use';

  @override
  String get relationshipsDisabled => 'Disabled';

  @override
  String get relationshipsEnable => 'Enable';

  @override
  String get relationshipsDisable => 'Disable';

  @override
  String get relationshipsFailureLabel =>
      'Enter a name (at most 40 characters).';

  @override
  String get relationshipsFailureTooMany => 'The list is full.';

  @override
  String get relationshipsFailureBuiltIn =>
      'Built-in entries cannot be changed.';

  @override
  String activityFamilyCreated(String familyName) {
    return 'Family “$familyName” was created';
  }

  @override
  String get activityFamilyUpdated => 'Family settings were updated';

  @override
  String activityMemberRequested(String memberName) {
    return '$memberName asked to join';
  }

  @override
  String activityMemberApproved(String memberName) {
    return '$memberName was approved';
  }

  @override
  String activityMemberRejected(String memberName) {
    return '$memberName was not accepted';
  }

  @override
  String activityMemberDisabled(String memberName) {
    return '$memberName was disabled';
  }

  @override
  String activityMemberRoleChanged(String memberName, String newRole) {
    return '$memberName is now $newRole';
  }

  @override
  String activityAdminTransferred(String memberName) {
    return 'Admin role moved to $memberName';
  }

  @override
  String activityMemberLeft(String memberName) {
    return '$memberName left the family';
  }

  @override
  String activityMemberCancelled(String memberName) {
    return '$memberName withdrew the request';
  }

  @override
  String activityInvitationCreated(String code) {
    return 'Invitation $code was created';
  }

  @override
  String activityInvitationRevoked(String code) {
    return 'Invitation $code was revoked';
  }

  @override
  String activityBazarCatalogSeeded(String categories, String items) {
    return 'Bazar catalog started with $categories categories and $items items';
  }

  @override
  String activityBazarCategoryCreated(String name) {
    return 'Category “$name” was added';
  }

  @override
  String activityBazarCategoryUpdated(String name) {
    return 'Category “$name” was updated';
  }

  @override
  String activityBazarCategoryDeactivated(String name) {
    return 'Category “$name” was archived';
  }

  @override
  String activityBazarItemCreated(String name) {
    return 'Item “$name” was added';
  }

  @override
  String activityBazarItemUpdated(String name) {
    return 'Item “$name” was updated';
  }

  @override
  String activityBazarItemDeactivated(String name) {
    return 'Item “$name” was archived';
  }

  @override
  String activityBazarExpenseCreated(
    String item,
    String amount,
    String funding,
  ) {
    return 'Bought $item for $amount ($funding)';
  }

  @override
  String activityBazarExpenseUpdated(String item, String fields) {
    return '$item was edited ($fields)';
  }

  @override
  String activityBazarExpenseDeleted(String item, String amount) {
    return '$item was deleted ($amount)';
  }

  @override
  String activityBazarExpenseRestored(String item, String amount) {
    return '$item was restored ($amount)';
  }

  @override
  String activityBazarTripCreated(String lines, String amount) {
    return 'Bazar trip with $lines items for $amount was saved';
  }

  @override
  String activityBazarBudgetSaved(String month, String amount) {
    return 'Budget for $month set to $amount';
  }

  @override
  String get activityBazarSettingsUpdated => 'Bazar settings were updated';

  @override
  String activityBazarContributionPlanSet(
    String month,
    String member,
    String amount,
  ) {
    return '$member\'s contribution for $month set to $amount';
  }

  @override
  String activityBazarContributionRecorded(
    String month,
    String member,
    String amount,
  ) {
    return '$member\'s contribution of $amount for $month was recorded';
  }

  @override
  String activityBazarContributionVoided(
    String month,
    String member,
    String amount,
  ) {
    return '$member\'s contribution of $amount for $month was voided';
  }

  @override
  String activityBazarContributionRequested(
    String month,
    String member,
    String amount,
  ) {
    return '$member offered $amount for $month';
  }

  @override
  String activityBazarContributionRequestEdited(
    String month,
    String member,
    String amount,
  ) {
    return '$member edited the offer of $amount for $month';
  }

  @override
  String activityBazarContributionRequestCancelled(
    String month,
    String member,
    String amount,
  ) {
    return '$member withdrew the offer of $amount for $month';
  }

  @override
  String activityBazarContributionApproved(
    String month,
    String member,
    String amount,
  ) {
    return '$member\'s contribution of $amount for $month was approved';
  }

  @override
  String activityBazarContributionRejected(
    String month,
    String member,
    String amount,
    String reason,
  ) {
    return '$member\'s contribution of $amount for $month was rejected ($reason)';
  }

  @override
  String activityBazarContributionChangeRequested(
    String month,
    String member,
    String amount,
    String old,
  ) {
    return '$member asked to change the contribution for $month from $old to $amount';
  }

  @override
  String activityBazarContributionChangeApproved(
    String month,
    String member,
    String amount,
    String old,
  ) {
    return '$member\'s change for $month from $old to $amount was approved';
  }

  @override
  String activityBazarContributionChangeRejected(
    String month,
    String member,
    String amount,
    String old,
  ) {
    return '$member\'s change for $month from $old to $amount was rejected';
  }

  @override
  String activityBazarOpeningBalanceSet(String month, String amount) {
    return 'Opening balance for $month is $amount';
  }

  @override
  String activityBazarAdvanceSettled(
    String member,
    String amount,
    String status,
  ) {
    return '$member\'s advance was settled by $amount ($status)';
  }

  @override
  String activityBazarMonthClosed(String month, String balance) {
    return '$month was closed with a balance of $balance';
  }

  @override
  String activityBazarMonthReopened(String month, String note) {
    return '$month was reopened ($note)';
  }

  @override
  String activityBazarImportCompleted(String rows, String amount) {
    return 'Import finished: $rows rows for $amount';
  }

  @override
  String activityBazarImportUndone(String rows, String amount) {
    return 'Import undone: $rows rows for $amount';
  }

  @override
  String get activityUnknown => 'Something changed';

  @override
  String get galleryMonthSwitcher => 'Month switcher';

  @override
  String get galleryAmountField => 'Amount field';

  @override
  String get galleryTotalDisplay => 'Total display';

  @override
  String get galleryProgressBarStatus => 'Limit progress bar';

  @override
  String get galleryDaySectionHeader => 'Day header';

  @override
  String get galleryPersonPicker => 'Person picker';

  @override
  String get galleryCategoryBadge => 'Category badge';

  @override
  String get monthSwitcherPrevious => 'Previous month';

  @override
  String get monthSwitcherNext => 'Next month';

  @override
  String get monthSwitcherPick => 'Choose a month';

  @override
  String get monthPickerPreviousYear => 'Previous year';

  @override
  String get monthPickerNextYear => 'Next year';

  @override
  String get totalDisplayCalculated => 'Calculated from quantity × price';

  @override
  String get totalDisplayEmpty => 'No total yet';

  @override
  String get progressLevelOk => 'On track';

  @override
  String get progressLevelWarning => 'Nearing the limit';

  @override
  String get progressLevelExceeded => 'Over the limit';

  @override
  String get progressLevelNoLimit => 'No limit set';

  @override
  String progressBarSemantics(String label, String percent, String level) {
    return '$label: $percent percent, $level';
  }

  @override
  String get personPickerNone => 'No one';

  @override
  String get actionUndo => 'Undo';

  @override
  String get bazarErrExpenseDeleted =>
      'This expense was deleted. Restore it first.';

  @override
  String get expenseAddTitle => 'Add expense';

  @override
  String get expenseEditTitle => 'Edit expense';

  @override
  String get expenseMenuTrip => 'Bazar trip (many items)';

  @override
  String get expenseDateLabel => 'Date';

  @override
  String get expenseItemLabel => 'Item';

  @override
  String get expenseItemHint => 'Type the item name';

  @override
  String expenseAddNewItem(String name) {
    return 'Add $name as a new item';
  }

  @override
  String get expenseCategoryLabel => 'Category';

  @override
  String get expenseRememberItem => 'Remember this item';

  @override
  String get expenseTotalField => 'Total amount';

  @override
  String get expenseTotalLabel => 'Total';

  @override
  String get expenseQtyPriceSection => 'Or enter quantity and price per unit';

  @override
  String get expenseQtyField => 'Quantity';

  @override
  String get expenseUnitLabel => 'Unit';

  @override
  String get expenseUnitPriceField => 'Price per unit';

  @override
  String expenseUnitPriceHint(String price) {
    return 'Last price: $price';
  }

  @override
  String get expenseFundingLabel => 'Who paid?';

  @override
  String get expenseFundingFund => 'From family fund';

  @override
  String get expenseFundingReimbursable => 'Paid by a member, to be reimbursed';

  @override
  String get expenseFundingPersonal => 'Paid by a member, personal';

  @override
  String get expensePaidByLabel => 'Paid by';

  @override
  String get expenseMoreSection => 'More details';

  @override
  String get expenseShopField => 'Shop';

  @override
  String get expenseNoteField => 'Note';

  @override
  String get expensePurchaserLabel => 'Bought by';

  @override
  String get expenseSaveAddAnother => 'Save and add another';

  @override
  String get expenseSaved => 'Expense saved';

  @override
  String get expenseUpdated => 'Expense updated';

  @override
  String get expenseUnknownMember => 'A member';

  @override
  String get expenseDuplicateTitle => 'Looks like a duplicate';

  @override
  String expenseDuplicateMessage(String item) {
    return '$item with the same amount was added a few minutes ago.';
  }

  @override
  String get expenseDuplicateSaveAnyway => 'Save anyway';

  @override
  String get tripTitle => 'Bazar trip';

  @override
  String get tripAddLine => 'Add item';

  @override
  String get tripLineSheetTitle => 'Add item to the trip';

  @override
  String get tripLineSheetSave => 'Add to trip';

  @override
  String tripLinesCount(String count) {
    return 'Items: $count';
  }

  @override
  String get tripEmpty => 'No items yet. Add the first item.';

  @override
  String get tripTotalLabel => 'Trip total';

  @override
  String get tripSaveAll => 'Save all';

  @override
  String get tripSaved => 'Trip saved';

  @override
  String get tripLineRemoved => 'Item removed';

  @override
  String get tripLimitReached => 'A trip can have at most 40 items.';

  @override
  String get expenseListTitle => 'Expenses';

  @override
  String get expenseListFilteredTotal => 'Total for this view';

  @override
  String get expenseListEmptyTitle => 'No expenses this month';

  @override
  String get expenseListEmptyMessage => 'Add the first expense to see it here.';

  @override
  String get expenseListFilteredEmptyTitle => 'Nothing matches the filters';

  @override
  String get expenseListFilteredEmptyMessage =>
      'Clear the filters to see every expense.';

  @override
  String get expenseListLocked =>
      'This month is closed. Entries are read-only.';

  @override
  String get expenseListRefresh => 'Refresh';

  @override
  String get expenseShowMore => 'Show more';

  @override
  String get expenseRowDeleted => 'Deleted';

  @override
  String get expenseRowTrip => 'Trip';

  @override
  String get expenseFilterTitle => 'Filter';

  @override
  String get expenseFilterRange => 'Date range';

  @override
  String expenseFilterRangeActive(String start, String end) {
    return '$start to $end';
  }

  @override
  String get expenseRangeAll => 'Whole month';

  @override
  String get expenseRangeToday => 'Today';

  @override
  String get expenseRangeYesterday => 'Yesterday';

  @override
  String get expenseRangeLast7 => 'Last 7 days';

  @override
  String get expenseRangeThisWeek => 'This week';

  @override
  String get expenseRangeThisMonth => 'This month';

  @override
  String get expenseRangeLastMonth => 'Last month';

  @override
  String get expenseRangeThisYear => 'This year';

  @override
  String get expenseRangeCustom => 'Choose dates';

  @override
  String get expenseFilterCategory => 'Category';

  @override
  String get expenseFilterItem => 'Item';

  @override
  String get expenseFilterMember => 'Member';

  @override
  String get expenseFilterFunding => 'Funding';

  @override
  String get expenseFilterAny => 'Any';

  @override
  String get expenseFilterShowDeleted => 'Show deleted';

  @override
  String get expenseFilterReset => 'Clear filters';

  @override
  String get expenseDetailTitle => 'Expense';

  @override
  String get expenseDetailAddedBy => 'Added by';

  @override
  String get expenseDetailPayment => 'Payment';

  @override
  String get expenseNotYoursMessage => 'You can change only your own expenses.';

  @override
  String get expenseLedgerFund => 'Paid from the family fund';

  @override
  String expenseLedgerPersonal(String name) {
    return 'Paid by $name from their own money, no reimbursement';
  }

  @override
  String expenseLedgerPending(String name, String amount) {
    return 'Paid by $name. $amount is waiting to be reimbursed.';
  }

  @override
  String expenseLedgerPartial(String name, String settled, String total) {
    return 'Paid by $name. $settled of $total has been reimbursed.';
  }

  @override
  String expenseLedgerSettled(String name) {
    return 'Paid by $name. Fully reimbursed.';
  }

  @override
  String get expenseLedgerVoided =>
      'The reimbursement was cancelled with the expense.';

  @override
  String get expenseDeleteTitle => 'Delete this expense?';

  @override
  String expenseDeleteMessage(String name) {
    return '$name will be removed from the totals. You can undo it right away.';
  }

  @override
  String get expenseDeleted => 'Expense deleted';

  @override
  String get expenseRestore => 'Restore';

  @override
  String get expenseRestored => 'Expense restored';

  @override
  String get expenseHistoryTitle => 'Edit history';

  @override
  String get expenseHistoryEmpty => 'No changes yet.';

  @override
  String expenseHistoryEntry(String who, String date) {
    return '$who changed this on $date';
  }

  @override
  String expenseHistoryWas(String field, String value) {
    return '$field was: $value';
  }

  @override
  String get catalogTitle => 'Catalog';

  @override
  String get catalogTabCategories => 'Categories';

  @override
  String get catalogTabItems => 'Items';

  @override
  String get catalogAdd => 'Add';

  @override
  String get catalogAddCategory => 'Add category';

  @override
  String get catalogEditCategory => 'Edit category';

  @override
  String get catalogAddItem => 'Add item';

  @override
  String get catalogEditItem => 'Edit item';

  @override
  String get catalogCategoryName => 'Category name';

  @override
  String get catalogNameBn => 'Name in Bangla';

  @override
  String get catalogNameEn => 'Name in English (optional)';

  @override
  String get catalogEmoji => 'Emoji (optional)';

  @override
  String get catalogColour => 'Colour';

  @override
  String catalogColourSemantics(int number) {
    return 'Colour $number';
  }

  @override
  String get catalogActive => 'Shown in lists';

  @override
  String get catalogActiveHint => 'Turn off to hide it without deleting.';

  @override
  String get catalogHidden => 'Hidden';

  @override
  String get catalogReorder => 'Drag to reorder';

  @override
  String get catalogReadOnly =>
      'You can look at this, but only the Household Manager or Admin can change it.';

  @override
  String get catalogCategoriesEmpty => 'No categories yet';

  @override
  String get catalogItemsEmpty => 'No items found';

  @override
  String get catalogSearch => 'Search items';

  @override
  String get catalogAllCategories => 'All';

  @override
  String get catalogDefaultUnit => 'Default unit';

  @override
  String get catalogAliases => 'Other spellings (for search)';

  @override
  String get catalogAliasField => 'Add a spelling';

  @override
  String get catalogAliasAdd => 'Add spelling';

  @override
  String get catalogAliasLimit => 'At most 10 spellings.';

  @override
  String get bazarSettingsWeekStart => 'Week starts on';

  @override
  String get bazarSettingsTarget => 'Monthly family contribution target';

  @override
  String get bazarSettingsDueDay => 'Contribution due day of the month';

  @override
  String get bazarSettingsAlerts => 'Budget alerts (percent of the budget)';

  @override
  String get bazarSettingsWarnAt => 'Warn at';

  @override
  String get bazarSettingsExceededAt => 'Exceeded at';

  @override
  String get bazarSettingsThresholdRange =>
      'Enter whole numbers from 1 to 200.';

  @override
  String get bazarSettingsThresholdOrder =>
      'The warning level must be lower than the exceeded level.';

  @override
  String get bazarSettingsFundStart => 'Fund start month';

  @override
  String get bazarSettingsFundStartUnset =>
      'Set automatically when you record the opening balance.';

  @override
  String get budgetTitle => 'Budget';

  @override
  String get budgetNote =>
      'A budget is a plan; the fund balance is real money.';

  @override
  String get budgetEmptyTitle => 'No budget for this month';

  @override
  String get budgetEmptyMessage =>
      'Plan the month to see how your spending compares.';

  @override
  String get budgetEmptyReadOnly =>
      'The Household Manager or Admin has not planned this month yet.';

  @override
  String get budgetPlanThisMonth => 'Plan this month';

  @override
  String get budgetCopyLast => 'Copy last month';

  @override
  String get budgetEdit => 'Edit budget';

  @override
  String get budgetOverall => 'Whole month';

  @override
  String budgetLeft(String amount) {
    return '$amount left';
  }

  @override
  String budgetOver(String amount) {
    return '$amount over';
  }

  @override
  String get budgetByCategory => 'By category';

  @override
  String get budgetDryTitle => 'Dry-grocery estimate';

  @override
  String budgetDrySummary(String count, String total) {
    return '$count lines, $total';
  }

  @override
  String get budgetDryEmpty => 'No estimate lines yet.';

  @override
  String get budgetTotalField => 'Total budget (leave empty to use the sum)';

  @override
  String get budgetDryFromLines => 'Sum of the lines below';

  @override
  String get budgetCategoryEstimates => 'Estimate per category';

  @override
  String get budgetLineName => 'Item';

  @override
  String get budgetLineStock => 'In stock';

  @override
  String get budgetLineRate => 'Rate';

  @override
  String get budgetLineTotal => 'Total';

  @override
  String get budgetAddLine => 'Add line';

  @override
  String get budgetRemoveLine => 'Remove line';

  @override
  String get budgetLinesSum => 'Lines total';

  @override
  String get budgetSaved => 'Budget saved';

  @override
  String get budgetErrExists => 'This month already has a budget.';

  @override
  String get budgetNoLastMonth => 'There is no budget for last month to copy.';

  @override
  String get budgetReadOnly =>
      'You can see the budget, but only the Household Manager or Admin can change it.';

  @override
  String get budgetAlertsTitle => 'Budget alerts';

  @override
  String get fundTitle => 'Family fund';

  @override
  String get fundBalanceTitle => 'Fund balance';

  @override
  String get fundReceived => 'Received';

  @override
  String get fundSpent => 'Spent';

  @override
  String get fundReimbursed => 'Reimbursed';

  @override
  String fundClosedOn(String date) {
    return 'Closed on $date';
  }

  @override
  String get fundMonthClosedNotice =>
      'This month is closed, so nothing new can be added to it.';

  @override
  String get fundOverflowWarning =>
      'The fund list is very long; close older months so the balance stays exact.';

  @override
  String get fundDriftWarning =>
      'A closed month does not match the ledger. Reopen it, fix it and close it again.';

  @override
  String fundLedgerIssues(int count) {
    return '$count expenses do not match their fund entries.';
  }

  @override
  String get fundMembersTitle => 'Contributions by member';

  @override
  String get fundNoMembers => 'No active members yet.';

  @override
  String get fundNoPlan => 'no plan this month';

  @override
  String get fundPaidUp => 'fully paid';

  @override
  String fundRemainingAmount(String amount) {
    return '$amount left';
  }

  @override
  String fundCredit(String amount) {
    return '$amount extra';
  }

  @override
  String fundAwaitingApproval(String amount) {
    return '$amount awaiting approval';
  }

  @override
  String get fundHistoryTitle => 'Fund history';

  @override
  String get fundHistoryEmpty => 'Nothing in the fund this month yet.';

  @override
  String get fundTxContribution => 'Contribution';

  @override
  String get fundTxExpense => 'Expense';

  @override
  String get fundTxReimbursement => 'Reimbursement';

  @override
  String get fundTxOpening => 'Opening balance';

  @override
  String get fundTxAdjustment => 'Correction';

  @override
  String get fundSetupTitle => 'Set up the fund';

  @override
  String get fundSetupMessage =>
      'Record the money the family already has, to start the fund and its first month.';

  @override
  String get fundOpeningBalance => 'Opening balance';

  @override
  String get fundSaveOpening => 'Save opening balance';

  @override
  String get fundAddContribution => 'Add contribution';

  @override
  String get fundRequestContribution => 'Request contribution';

  @override
  String get fundSaveContribution => 'Save contribution';

  @override
  String get fundSendRequest => 'Send request';

  @override
  String get fundSendChangeRequest => 'Send change request';

  @override
  String get fundEditRequest => 'Edit request';

  @override
  String get fundRequestChange => 'Request a change';

  @override
  String get fundContributionLocked => 'Month closed';

  @override
  String get fundMemberLabel => 'Who paid';

  @override
  String get fundAmountLabel => 'Amount';

  @override
  String get fundMethodLabel => 'How it was paid';

  @override
  String get fundMethodCash => 'Cash';

  @override
  String get fundMethodBkash => 'bKash';

  @override
  String get fundMethodNagad => 'Nagad';

  @override
  String get fundMethodBank => 'Bank';

  @override
  String get fundMethodOther => 'Other';

  @override
  String get fundPendingTitle => 'Waiting for approval';

  @override
  String bazarDashboardPendingApprovals(String count) {
    return '$count contributions awaiting approval';
  }

  @override
  String get fundPendingEmpty => 'No requests are waiting.';

  @override
  String get fundApprove => 'Approve';

  @override
  String get fundReject => 'Reject';

  @override
  String get fundRejectReasonTitle => 'Why is it rejected?';

  @override
  String get fundRejectReasonHint => 'The member will see this reason.';

  @override
  String fundRejectedReason(String reason) {
    return 'Rejected: $reason';
  }

  @override
  String get fundVoid => 'Void';

  @override
  String get fundGeneratePlan => 'Generate this month\'s plan';

  @override
  String get fundStatusPending => 'awaiting approval';

  @override
  String get fundStatusApproved => 'approved';

  @override
  String get fundStatusRejected => 'rejected';

  @override
  String get fundStatusVoided => 'voided';

  @override
  String get advanceTitle => 'Advance repayments';

  @override
  String advanceOwedTo(String name) {
    return 'Owed to $name';
  }

  @override
  String advancePaidTo(String name) {
    return 'Paid to $name';
  }

  @override
  String advanceOpenCount(int count) {
    return '$count open advances';
  }

  @override
  String get advanceTotalOwed => 'Total still owed';

  @override
  String get advanceShowSettled => 'Show settled';

  @override
  String get advanceEmptyTitle => 'Nothing to pay back';

  @override
  String get advanceEmptyMessage =>
      'When a member pays for the family out of their own pocket, it appears here until they are paid back.';

  @override
  String get advanceSettledOf => 'repaid';

  @override
  String get advanceRemaining => 'still owed';

  @override
  String get advanceSettleTitle => 'Pay this back';

  @override
  String get advanceSettleAction => 'Record repayment';

  @override
  String get monthCloseTitle => 'Close month';

  @override
  String get monthCloseManagerOnly =>
      'Only the Household Manager or Admin can close or reopen a month.';

  @override
  String get monthCloseCurrentHint =>
      'Closing this month makes it read-only and carries its balance into next month.';

  @override
  String get monthCloseWillRecord => 'Closing balance this month will record';

  @override
  String get monthCloseAdvances => 'Open advances after closing';

  @override
  String get monthCloseExpected => 'Planned contributions';

  @override
  String get monthCloseReceived => 'Contributions received';

  @override
  String get monthClose => 'Close month';

  @override
  String get monthCloseConfirmTitle => 'Close this month?';

  @override
  String get monthCloseConfirmMessage =>
      'The month becomes read-only and the balance carries into the next month. You can reopen it later if something is wrong.';

  @override
  String get monthClosedDone => 'Month closed';

  @override
  String get monthReopen => 'Reopen month';

  @override
  String get monthReopenedDone => 'Month reopened';

  @override
  String get monthReopenNoteTitle => 'Why reopen this month?';

  @override
  String get monthReopenNoteHint => 'A short reason (at least 3 characters).';

  @override
  String monthClosedChip(String month) {
    return '$month (closed)';
  }

  @override
  String get reportTitle => 'Reports';

  @override
  String get reportTabSummary => 'Summary';

  @override
  String get reportTabCategories => 'Categories';

  @override
  String get reportTabItems => 'Items';

  @override
  String get reportTabDays => 'Days';

  @override
  String get reportTabMembers => 'Members';

  @override
  String get reportTabDry => 'Dry groceries';

  @override
  String get reportTabContributions => 'Contributions';

  @override
  String get reportTotal => 'Total';

  @override
  String get reportAmount => 'Amount';

  @override
  String get reportAveragePerDay => 'Average per day';

  @override
  String get reportRows => 'Entries';

  @override
  String get reportRange => 'Period';

  @override
  String get reportSummaryColumn => 'Measure';

  @override
  String get reportCategoryColumn => 'Category';

  @override
  String get reportItemColumn => 'Item';

  @override
  String get reportDayColumn => 'Day';

  @override
  String get reportMemberColumn => 'Member';

  @override
  String reportPercent(String percent) {
    return '$percent%';
  }

  @override
  String get reportUp => 'Up';

  @override
  String get reportDown => 'Down';

  @override
  String get reportFlat => 'No change';

  @override
  String get reportPrevious => 'Before';

  @override
  String reportComparedWith(String period) {
    return 'compared with $period';
  }

  @override
  String get reportNoPreviousData => 'no earlier data';

  @override
  String reportComparisonSemantics(
    String direction,
    String amount,
    String percent,
    String period,
  ) {
    return '$direction $amount, $percent, compared with $period';
  }

  @override
  String get reportPrevDay => 'the day before';

  @override
  String get reportPrevWeek => 'last week';

  @override
  String get reportPrevMonth => 'last month';

  @override
  String get reportPrevYear => 'last year';

  @override
  String get reportPrevRange => 'the previous period';

  @override
  String get reportDryEstimate => 'Planned';

  @override
  String get reportDryActual => 'Spent';

  @override
  String get reportDryDelta => 'Difference';

  @override
  String get reportDryPlanned => 'planned';

  @override
  String get reportDryEmpty => 'No dry-grocery plan for this period.';

  @override
  String get reportOver => 'over';

  @override
  String get reportUnder => 'under';

  @override
  String get reportExpected => 'planned';

  @override
  String get reportTruncated =>
      'This period has too many entries to show in full. Choose a shorter period for an exact report.';

  @override
  String get chartNoData => 'Nothing to chart for this period yet.';

  @override
  String get chartOther => 'Other';

  @override
  String chartSlice(String name, String amount, String percent) {
    return '$name $amount, $percent% of total';
  }

  @override
  String chartDaySummary(String day, String amount) {
    return 'Highest spending on $day: $amount';
  }

  @override
  String get choresEmptyTitle => 'No chores yet';

  @override
  String get choresEmptyMessage =>
      'Chores will show up here once they are added.';

  @override
  String get choresManageAction => 'Manage';

  @override
  String get choresManageTitle => 'Manage chores';

  @override
  String get choresManageEmptyTitle => 'Nothing here yet';

  @override
  String get choresManageEmptyMessage => 'Chore tools will appear here.';

  @override
  String get choresModuleTitle => 'Chores';

  @override
  String get permissionManageChoreTemplates => 'Manage chores and rotations';

  @override
  String get permissionReassignChore => 'Reassign a chore';

  @override
  String get permissionRequestSwap => 'Ask to swap a chore';

  @override
  String get permissionCompleteOwnChore => 'Complete my chores';

  @override
  String get permissionCommentOnChore => 'Comment on a chore';

  @override
  String get permissionVerifyChore => 'Verify someone\'s chore';

  @override
  String get permissionCompleteChoreForOthers =>
      'Complete someone else\'s chore';

  @override
  String get permissionRecordOwnAvailability => 'Record my absence';

  @override
  String get permissionManageAvailability => 'Manage absences';

  @override
  String get permissionManageChoreOccurrences =>
      'Skip, reopen or annotate a chore';

  @override
  String get permissionModerateChoreComments => 'Hide a comment';

  @override
  String get choreStatusSkipped => 'Skipped';

  @override
  String get choreFlagNeedsCover => 'Needs an assignee';

  @override
  String get choreFlagAwaitingVerification => 'Awaiting verification';

  @override
  String get choreFlagNeedsAttention => 'Needs attention';

  @override
  String get choreFlagPlanned => 'Planned';

  @override
  String get choreFlagSwapPending => 'Swap pending';

  @override
  String get reasonSheetHint => 'Why? (at least 3 characters)';

  @override
  String reasonSheetTooShort(int min) {
    return 'Write at least $min characters.';
  }

  @override
  String get minutesFieldNotSet => 'End of day';

  @override
  String get minutesFieldClear => 'Clear the time';

  @override
  String colorSwatchLabel(int index, int count) {
    return 'Colour $index of $count';
  }

  @override
  String avatarStackMore(String first, int rest) {
    return '$first and $rest more';
  }

  @override
  String avatarStackMoreShort(int hidden) {
    return '+$hidden';
  }

  @override
  String stepProgressSemantic(String done, String total) {
    return '$done of $total steps done';
  }

  @override
  String get choresFailure_required => 'This field is required.';

  @override
  String get choresFailure_too_long => 'That text is too long.';

  @override
  String get choresFailure_invalid_time => 'Enter a valid time.';

  @override
  String get choresFailure_invalid_recurrence =>
      'This repeat pattern is not valid.';

  @override
  String get choresFailure_no_dates => 'Pick at least one day.';

  @override
  String get choresFailure_invalid_range =>
      'The end must not be before the start.';

  @override
  String get choresFailure_invalid_date => 'That date is not valid.';

  @override
  String get choresFailure_too_many_subtasks => 'Too many steps (30 at most).';

  @override
  String get choresFailure_too_many_slots =>
      'Too many times a day (6 at most).';

  @override
  String get choresFailure_duplicate_slot =>
      'Two times a day share the same name.';

  @override
  String get choresFailure_too_many_items => 'That is too many items.';

  @override
  String get choresFailure_duplicate_id => 'That name is already in use.';

  @override
  String get choresFailure_reason_required => 'A reason is required.';

  @override
  String get choresFailure_reason_too_short =>
      'The reason needs at least 3 characters.';

  @override
  String get choresFailure_member_required => 'Choose a member.';

  @override
  String get choresFailure_invalid_rotation => 'This rotation is not valid.';

  @override
  String get choresFailure_too_few_members =>
      'Add at least two members to rotate.';

  @override
  String get choresFailure_invalid_horizon =>
      'Choose a planning range between 14 and 90 days.';

  @override
  String get choresFailure_invalid_week_start =>
      'Choose a valid first day of the week.';

  @override
  String get choresFailure_invalid_minutes =>
      'Enter a time between 00:00 and 23:59.';

  @override
  String get choresFailure_not_assigned_to_you =>
      'This chore is not assigned to you.';

  @override
  String get choresFailure_already_completed =>
      'This chore is already completed.';

  @override
  String get choresFailure_not_completed => 'This chore is not completed yet.';

  @override
  String get choresFailure_required_subtasks_open =>
      'Finish the required steps first.';

  @override
  String get choresFailure_self_verification =>
      'You cannot verify your own chore.';

  @override
  String get choresFailure_verification_not_required =>
      'This chore does not need verification.';

  @override
  String get choresFailure_already_verified =>
      'This chore is already verified.';

  @override
  String get choresFailure_verified_requires_manager =>
      'Only a manager can reopen a verified chore.';

  @override
  String get choresFailure_occurrence_started =>
      'This chore has already started.';

  @override
  String get choresFailure_already_skipped => 'This chore is already skipped.';

  @override
  String get choresFailure_not_skipped => 'This chore is not skipped.';

  @override
  String get choresFailure_swap_not_pending =>
      'This request is no longer open.';

  @override
  String get choresFailure_swap_expired => 'This request has expired.';

  @override
  String get choresFailure_swaps_disabled =>
      'Swapping is switched off for this family.';

  @override
  String get choresFailure_cover_not_needed =>
      'This chore already has an assignee.';

  @override
  String get choresFailure_availability_overlap =>
      'An absence already covers these days.';

  @override
  String get choresFailure_member_unavailable =>
      'That member is absent on this day.';

  @override
  String get choresFailure_template_paused => 'This chore is paused.';

  @override
  String get choresFailure_rotation_member_inactive =>
      'A member in the rotation is no longer active.';

  @override
  String get choresFailure_range_too_large =>
      'That range is too long to generate at once.';

  @override
  String get choresFailure_starter_pack_applied =>
      'That starter pack is already added.';

  @override
  String get choresFailure_occurrence_deleted => 'This chore was deleted.';

  @override
  String get choresFailure_concurrent_edit =>
      'Someone else changed this; reopen and try again.';

  @override
  String get choresFailure_last_group_in_use => 'Chores still use this group.';

  @override
  String get choresFailure_not_a_recipient =>
      'This request is not addressed to you.';

  @override
  String get choresFailure_not_found => 'That item no longer exists.';

  @override
  String get choresFailure_permission_denied =>
      'You do not have permission to do that.';

  @override
  String get choresFailure_network =>
      'No connection. Check your internet and try again.';

  @override
  String get choresFailure_unknown => 'Something went wrong. Please try again.';

  @override
  String get activityChoresSettingsUpdated => 'Updated the chore settings';

  @override
  String get activityChoresRotationPolicyUpdated =>
      'Changed the absence policy';

  @override
  String activityChoresTemplateCreated(String name) {
    return 'Added the chore $name';
  }

  @override
  String activityChoresTemplateUpdated(String name) {
    return 'Edited the chore $name';
  }

  @override
  String activityChoresTemplatePaused(String name) {
    return 'Paused the chore $name';
  }

  @override
  String activityChoresTemplateResumed(String name) {
    return 'Resumed the chore $name';
  }

  @override
  String activityChoresTemplateArchived(String name) {
    return 'Archived the chore $name';
  }

  @override
  String activityChoresTemplateDuplicated(String name) {
    return 'Copied the chore $name';
  }

  @override
  String activityChoresStarterPackApplied(String templates, String groups) {
    return 'Added the starter chores ($templates chores, $groups groups)';
  }

  @override
  String activityChoresDutyGroupCreated(String name) {
    return 'Added the duty group $name';
  }

  @override
  String activityChoresDutyGroupUpdated(String name) {
    return 'Edited the duty group $name';
  }

  @override
  String activityChoresRotationChanged(String name) {
    return 'Changed the rotation of $name';
  }

  @override
  String activityChoresOccurrencesGenerated(
    String from,
    String to,
    String count,
  ) {
    return 'Planned chores from $from to $to ($count)';
  }

  @override
  String activityChoresOccurrencesReplanned(String name, String from) {
    return 'Replanned the chore $name from $from';
  }

  @override
  String activityChoresOccurrenceCompleted(
    String member,
    String name,
    String date,
  ) {
    return '$member completed $name on $date';
  }

  @override
  String activityChoresOccurrenceUncompleted(
    String member,
    String name,
    String date,
  ) {
    return '$member un-completed $name on $date';
  }

  @override
  String activityChoresOccurrenceVerified(
    String member,
    String name,
    String date,
  ) {
    return '$member verified $name on $date';
  }

  @override
  String activityChoresOccurrenceReopened(
    String member,
    String name,
    String date,
  ) {
    return '$member reopened $name on $date';
  }

  @override
  String activityChoresOccurrenceException(
    String member,
    String name,
    String date,
  ) {
    return '$member recorded an exception for $name on $date';
  }

  @override
  String activityChoresOccurrenceSkipped(
    String member,
    String name,
    String date,
  ) {
    return '$member skipped $name on $date';
  }

  @override
  String activityChoresOccurrenceUnskipped(
    String member,
    String name,
    String date,
  ) {
    return '$member un-skipped $name on $date';
  }

  @override
  String activityChoresOccurrenceReassigned(
    String member,
    String name,
    String date,
  ) {
    return '$member reassigned $name on $date';
  }

  @override
  String activityChoresCommentAdded(String member, String name, String date) {
    return '$member commented on $name on $date';
  }

  @override
  String activityChoresCommentHidden(String member, String name, String date) {
    return '$member hid a comment on $name on $date';
  }

  @override
  String activityChoresAvailabilityAdded(
    String member,
    String from,
    String to,
  ) {
    return '$member recorded an absence from $from to $to';
  }

  @override
  String activityChoresAvailabilityCancelled(
    String member,
    String from,
    String to,
  ) {
    return '$member cancelled an absence from $from to $to';
  }

  @override
  String activityChoresAvailabilityDecided(
    String member,
    String from,
    String to,
  ) {
    return '$member decided an absence from $from to $to';
  }

  @override
  String activityChoresSwapRequested(
    String member,
    String to,
    String name,
    String date,
  ) {
    return '$member asked $to to take $name on $date';
  }

  @override
  String activityChoresSwapAccepted(String to, String name, String date) {
    return '$to accepted $name on $date';
  }

  @override
  String activityChoresSwapDeclined(String to, String name, String date) {
    return '$to declined $name on $date';
  }

  @override
  String activityChoresSwapCancelled(String member, String name, String date) {
    return '$member cancelled the request for $name on $date';
  }

  @override
  String activityChoresSwapExpired(String name, String date) {
    return 'The request for $name on $date expired';
  }

  @override
  String activityChoresCoverAssigned(String to, String name, String date) {
    return '$to will cover $name on $date';
  }

  @override
  String get occurrenceDetailTitle => 'Chore';

  @override
  String occurrenceDueToday(String time) {
    return 'Today, by $time';
  }

  @override
  String occurrenceDueDay(String time, String date) {
    return '$date, by $time';
  }

  @override
  String get occurrenceDueNoTime => 'By the end of the day';

  @override
  String get occurrenceUnassigned => 'Nobody assigned yet';

  @override
  String occurrenceCoveringFor(String name) {
    return 'Covering for $name';
  }

  @override
  String get occurrenceStepsTitle => 'Steps';

  @override
  String get occurrenceInstructionsTitle => 'How to do it';

  @override
  String occurrenceEstimated(String minutes) {
    return 'About $minutes min';
  }

  @override
  String get occurrenceDifficultyEasy => 'Easy';

  @override
  String get occurrenceDifficultyNormal => 'Normal';

  @override
  String get occurrenceDifficultyHard => 'Hard';

  @override
  String get occurrenceTimelineTitle => 'History';

  @override
  String occurrenceEventCompleted(String name) {
    return 'Completed by $name';
  }

  @override
  String occurrenceEventUncompleted(String name) {
    return 'Completion undone by $name';
  }

  @override
  String occurrenceEventVerified(String name) {
    return 'Verified by $name';
  }

  @override
  String occurrenceEventReopened(String name, String reason) {
    return 'Reopened by $name: $reason';
  }

  @override
  String occurrenceEventReassigned(String name, String to, String reason) {
    return '$name moved it to $to: $reason';
  }

  @override
  String occurrenceEventSkipped(String name, String reason) {
    return 'Skipped by $name: $reason';
  }

  @override
  String occurrenceEventUnskipped(String name) {
    return 'Put back by $name';
  }

  @override
  String occurrenceEventException(String name, String reason) {
    return 'Exception by $name: $reason';
  }

  @override
  String occurrenceEventSwapped(String name, String to) {
    return '$name swapped with $to';
  }

  @override
  String occurrenceEventCovered(String name, String to) {
    return '$name covered for $to';
  }

  @override
  String get occurrenceActionComplete => 'Mark done';

  @override
  String get occurrenceActionUndo => 'Undo completion';

  @override
  String get occurrenceActionVerify => 'Verify';

  @override
  String get occurrenceActionReopen => 'Reopen';

  @override
  String get occurrenceActionReassign => 'Reassign';

  @override
  String get occurrenceActionSkip => 'Skip';

  @override
  String get occurrenceActionUnskip => 'Put back';

  @override
  String get occurrenceActionException => 'Finish with a note';

  @override
  String get occurrenceActionSwap => 'I can\'t do this';

  @override
  String get occurrenceReopenTitle => 'Why reopen it?';

  @override
  String get occurrenceReassignTitle => 'Who should do it?';

  @override
  String get occurrenceReassignReasonTitle => 'Why move it?';

  @override
  String get occurrenceSkipTitle => 'Why skip it?';

  @override
  String get occurrenceExceptionTitle => 'What could not be done?';

  @override
  String get occurrenceUndone => 'Completion undone';

  @override
  String get occurrenceStepReopened => 'Done: the chore is open again.';

  @override
  String get occurrencePlannedReadOnly =>
      'This chore is only planned; the first change will add it.';

  @override
  String get occurrenceAwaitingVerification =>
      'Done; somebody else has to check it.';

  @override
  String get occurrenceReopenStepsTitle => 'Which steps have to be done again?';

  @override
  String get occurrenceReopenStepsHint => 'The ones you pick will be unticked.';

  @override
  String get todayTitle => 'Today';

  @override
  String get todayEmptyTitle => 'Nothing to do today';

  @override
  String get todayEmptyMessage =>
      'Enjoy the free time, or plan a chore for later.';

  @override
  String get todayAllDoneTitle => 'All done for today';

  @override
  String get todayAllDoneMessage =>
      'Every chore for today is finished. Well done!';

  @override
  String get todaySectionOverdue => 'Overdue';

  @override
  String get todaySectionDone => 'Done today';

  @override
  String get todayScopeMine => 'Mine';

  @override
  String get todayScopeFamily => 'Whole family';

  @override
  String todayProgress(String done, String total) {
    return '$done of $total done';
  }

  @override
  String get todayUndo => 'Undo';

  @override
  String get verifyTitle => 'Waiting for a check';

  @override
  String get verifyEmptyTitle => 'Nothing to verify';

  @override
  String get verifyEmptyMessage =>
      'Chores somebody finished and needs a check on will appear here.';

  @override
  String get verifyApprove => 'Approve';

  @override
  String get verifyReopen => 'Send back';

  @override
  String get choreDayPartEarlyMorning => 'Early morning';

  @override
  String get choreDayPartMorning => 'Morning';

  @override
  String get choreDayPartNoon => 'Noon';

  @override
  String get choreDayPartAfternoon => 'Afternoon';

  @override
  String get choreDayPartEvening => 'Evening';

  @override
  String get choreDayPartNight => 'Night';

  @override
  String choreDueTime(String time) {
    return 'by $time';
  }

  @override
  String choreStepsCount(String done, String total) {
    return '$done/$total';
  }

  @override
  String get choresSettingsTitle => 'Chore settings';

  @override
  String get choresSettingsSubtitle =>
      'Preferences, rotation policies and catalogs';

  @override
  String get choresSettingsCalendarTitle => 'Calendar & display';

  @override
  String get choresSettingsGenerationTitle => 'Generation & timing';

  @override
  String get choresSettingsCatalogsTitle => 'Catalogs';

  @override
  String get choresSettingsPoliciesTitle => 'Policies & rules';

  @override
  String get choresSettingsHouseRulesTitle => 'House rules';

  @override
  String get choresSettingsDefaultView => 'Default calendar view';

  @override
  String get choresSettingsDefaultScope => 'Default chore scope';

  @override
  String get choresSettingsWeekStart => 'Week start day';

  @override
  String get choresSettingsShowProjected => 'Show projected chores';

  @override
  String get choresSettingsShowProjectedSubtitle =>
      'Displays projected upcoming occurrences on the calendar';

  @override
  String choresSettingsProjectedMonths(String months) {
    return 'Projected months ahead: $months';
  }

  @override
  String get choresCalendarViewAgenda => 'Agenda';

  @override
  String get choresCalendarViewMonth => 'Month';

  @override
  String get choresCalendarViewWeek => 'Week';

  @override
  String get choresCalendarScopeMine => 'My chores';

  @override
  String get choresCalendarScopeAll => 'All chores';

  @override
  String choresSettingsHorizon(String days) {
    return 'Generation horizon: $days days';
  }

  @override
  String get choresSettingsHorizonSubtitle =>
      'Occurrences are generated this many days in advance (14-90 days)';

  @override
  String choresSettingsOverdueGrace(String minutes) {
    return 'Overdue grace period: $minutes minutes';
  }

  @override
  String get choresSettingsOverdueGraceSubtitle =>
      'Buffer after due time before a chore counts as overdue';

  @override
  String get choresSettingsGroupsTitle => 'Chore groups';

  @override
  String get choresSettingsPresetsTitle => 'Due-time presets';

  @override
  String get choresSettingsAbsenceReasonsTitle => 'Absence reasons';

  @override
  String get choresGroupDeactivateWarningTitle => 'Deactivate group?';

  @override
  String get choresGroupDeactivateWarningMessage =>
      'Some active chores use this group. Deactivating it will hide it for new chores, but existing chores keep it. Continue?';

  @override
  String get choresGroupColor => 'Color';

  @override
  String get choresGroupIcon => 'Icon';

  @override
  String get choresGroupAddTitle => 'Add chore group';

  @override
  String get choresGroupEditTitle => 'Edit chore group';

  @override
  String get choresPresetAddTitle => 'Add time preset';

  @override
  String get choresPresetEditTitle => 'Edit time preset';

  @override
  String get choresPresetTime => 'Time of day';

  @override
  String get choresSettingsAbsencePolicyTitle => 'Absence policy';

  @override
  String get choresPolicyAskCoverTitle => 'Ask for cover (Policy A)';

  @override
  String get choresPolicyAskCoverDesc =>
      'The absent member personally asks another family member to cover their task.';

  @override
  String get choresPolicyAskCoverExample =>
      'Example: When away on urgent work, send a cover request to another member.';

  @override
  String get choresPolicyAutoCoverTitle => 'Auto-cover proposal (Policy B)';

  @override
  String get choresPolicyAutoCoverDesc =>
      'The app suggests a replacement member and sends them a request they may accept or decline.';

  @override
  String get choresPolicyAutoCoverExample =>
      'Example: The next free person in rotation gets an automatic cover request.';

  @override
  String get choresPolicySkipTitle => 'Skip chore (Policy C)';

  @override
  String get choresPolicySkipDesc =>
      'The occurrence is marked as skipped due to absence and remains neutral in scoring.';

  @override
  String get choresPolicySkipExample =>
      'Example: Non-critical chores are simply skipped until their next scheduled run.';

  @override
  String get choresSettingsSwapsEnabled => 'Allow chore swaps';

  @override
  String get choresSettingsSwapsEnabledSubtitle =>
      'Members may request to swap tasks with one another';

  @override
  String choresSettingsSwapBuffer(String minutes) {
    return 'Swap request expiry: $minutes minutes';
  }

  @override
  String get choresSettingsSwapBufferSubtitle =>
      'How long a swap request stays valid before expiring';

  @override
  String get choresSettingsAbsenceApproval =>
      'Absence requires manager approval';

  @override
  String get choresSettingsAbsenceApprovalSubtitle =>
      'Absence requests stay pending until confirmed by a manager';

  @override
  String get choresSettingsWorkloadVisible =>
      'Workload share visible to all members';

  @override
  String get choresSettingsWorkloadVisibleSubtitle =>
      'Shows this month\'s chore distribution to all active members';

  @override
  String get choresSettingsCompleteForOthers =>
      'Allow members to complete for others';

  @override
  String get choresSettingsCompleteForOthersSubtitle =>
      'Members can check off chores assigned to other people (Admin only)';

  @override
  String get choresSettingsHouseRulesEditor => 'House rules (markdown)';

  @override
  String get choresSettingsHouseRulesPreview => 'Preview';

  @override
  String get choresSettingsHouseRulesHelp =>
      'Use # Heading, - Bullet point, or **bold** text.';

  @override
  String get choresSettingsHouseRulesEmpty => 'No house rules specified yet.';

  @override
  String get choresSettingsSave => 'Save settings';

  @override
  String get choresSettingsResetSection => 'Reset section';

  @override
  String get choresSettingsResetConfirmTitle => 'Reset section to defaults?';

  @override
  String get choresSettingsResetConfirmMessage =>
      'This section\'s values will be reset to defaults. Existing chores and templates will not be deleted.';

  @override
  String get choresSettingsDiscardTitle => 'Discard changes?';

  @override
  String get choresSettingsDiscardMessage =>
      'You have unsaved changes. Are you sure you want to discard them?';

  @override
  String get choresSettingsSaved => 'Chore settings saved';

  @override
  String get choresSettingsNotAllowed =>
      'You do not have permission to manage chore settings.';

  @override
  String get choresSettingsPickIcon => 'Choose icon';

  @override
  String get dutyGroupsTitle => 'Duty groups';

  @override
  String get dutyGroupsSubtitle => 'Who is on duty and the rota';

  @override
  String get dutyGroupsEmptyTitle => 'No duty groups yet';

  @override
  String get dutyGroupsEmptyMessage =>
      'A duty group shares a set of chores among a few people, turn by turn.';

  @override
  String get dutyGroupNew => 'New duty group';

  @override
  String dutyGroupsTruncated(String count) {
    return 'Only the first $count groups are shown.';
  }

  @override
  String dutyGroupOnDutyNow(String name) {
    return 'On duty now: $name';
  }

  @override
  String get dutyGroupNobodyOnDuty => 'Nobody is on duty yet';

  @override
  String dutyGroupChoreCount(String count) {
    return 'Chores: $count';
  }

  @override
  String dutyGroupMemberCount(String count) {
    return 'Members: $count';
  }

  @override
  String get dutyGroupSwitchedOff => 'Switched off';

  @override
  String get dutyGroupEditTitle => 'Edit duty group';

  @override
  String get dutyGroupNameBn => 'Name (Bangla)';

  @override
  String get dutyGroupNameEn => 'Name (English, optional)';

  @override
  String get dutyGroupActive => 'Active';

  @override
  String get dutyGroupActiveSubtitle =>
      'A switched-off group stays in the history.';

  @override
  String get dutyGroupSave => 'Save group';

  @override
  String get dutyGroupSaved => 'Group saved';

  @override
  String get dutyGroupReadOnly =>
      'Only people who manage chores can change duty groups.';

  @override
  String get dutyGroupNotFound => 'This duty group no longer exists.';

  @override
  String get dutyGroupDeactivateTitle => 'Switch off this group?';

  @override
  String get dutyGroupDeactivateMessage =>
      'Chores still use this group. They keep pointing at it until you move them.';

  @override
  String get dutyGroupDeactivateConfirm => 'Switch off';

  @override
  String get dutyRotationMembers => 'Members in turn order';

  @override
  String get dutyRotationNeedTwo => 'Add at least two members.';

  @override
  String get dutyRotationAddMember => 'Add a member';

  @override
  String get dutyRotationNoCandidates =>
      'Every active member is already in the group.';

  @override
  String dutyRotationRemoveMember(String name) {
    return 'Remove $name';
  }

  @override
  String dutyRotationMoveMember(String name) {
    return 'Drag to move $name';
  }

  @override
  String get dutyRotationCycleUnit => 'The turn changes every';

  @override
  String get dutyRotationUnitDay => 'Day';

  @override
  String get dutyRotationUnitWeek => 'Week';

  @override
  String get dutyRotationUnitMonth => 'Month';

  @override
  String get dutyRotationUnitOccurrence => 'Chore day';

  @override
  String dutyRotationWeekStart(String day) {
    return 'Weeks start on $day';
  }

  @override
  String get dutyRotationStartsWith => 'Starts with';

  @override
  String get dutyRotationStartsOn => 'Starts on';

  @override
  String get dutyRotationPickDate => 'Pick a date';

  @override
  String get dutyRotaTitle => 'Next turns';

  @override
  String get dutyRotaNeedsSchedule =>
      'This rota counts chore days, so it needs a schedule to preview.';

  @override
  String get dutyRotaNobody => 'Nobody yet';

  @override
  String dutyRotaRange(String start, String end) {
    return '$start to $end';
  }

  @override
  String dutyRotaCellLabel(String range, String name) {
    return '$range: $name';
  }

  @override
  String dutyRotaCellLabelCover(String range, String name) {
    return '$range: $name, needs a cover';
  }

  @override
  String get dutyNeedsCover => 'Needs a cover';

  @override
  String get dutyMemberGone => 'No longer active, so turns need a cover';

  @override
  String get dutyRosterTitle => 'Current members';

  @override
  String get dutyChangeTitle => 'Change the rotation';

  @override
  String get dutyChangeAdd => 'Add a member';

  @override
  String get dutyChangeRemove => 'Remove a member';

  @override
  String get dutyChangeReorder => 'Change the order';

  @override
  String get dutyChangeFrom => 'Takes effect on';

  @override
  String dutyChangeNothingBefore(String date) {
    return 'Nothing before $date changes.';
  }

  @override
  String get dutyChangeApply => 'Apply change';

  @override
  String get dutyChangeAfter => 'After the change';

  @override
  String get dutyChangePickMember => 'Choose a member';

  @override
  String get dutyPlanFailed => 'Saved, but planning the dates failed.';

  @override
  String get dutyPlanning => 'Planning the dates…';

  @override
  String get dutyChoresTitle => 'Chores in this group';

  @override
  String get dutyChoresEmpty => 'No chores in this group yet.';

  @override
  String get dutyChoreAdd => 'Add chore to this group';

  @override
  String get dutyChoreAddNone => 'Every chore is already in this group.';

  @override
  String get dutyChoreAddNote =>
      'Upcoming chores that have not started move to this rota.';

  @override
  String get dutyChoreAdded => 'Chore added to the group';

  @override
  String get actionDiscard => 'Discard';

  @override
  String get choresSettingsNeedsInternet =>
      'Saving chore settings needs an internet connection. Your changes are kept here; try again when you are online.';

  @override
  String get choresSettingsResetConfirmAction => 'Reset';

  @override
  String get choreTemplatesTitle => 'Chore templates';

  @override
  String get choreTemplatesSubtitle => 'Create and edit the family chores';

  @override
  String get choreTemplatesNotAllowed =>
      'Only admins and moderators can manage chores.';

  @override
  String get choreListNew => 'New chore';

  @override
  String get choreListSearch => 'Search chores';

  @override
  String get choreListEmptyTitle => 'No chores yet';

  @override
  String get choreListEmptyMessage =>
      'Create the first chore with the New chore button.';

  @override
  String get choreListEmptyFiltered => 'No chores match';

  @override
  String get choreListTruncated =>
      'Only the first chores are shown. Archive chores you no longer need to see the rest.';

  @override
  String get choreListUpdated => 'Updated';

  @override
  String get choreListInvalidSchedule => 'Schedule cannot be read';

  @override
  String choreListNext(String date) {
    return 'Next: $date';
  }

  @override
  String get choreStatusActive => 'Active';

  @override
  String get choreStatusPaused => 'Paused';

  @override
  String get choreStatusArchived => 'Archived';

  @override
  String get choreActionPause => 'Pause';

  @override
  String get choreActionResume => 'Resume';

  @override
  String get choreActionDuplicate => 'Duplicate';

  @override
  String get choreActionArchive => 'Archive';

  @override
  String get choreArchiveConfirmTitle => 'Archive this chore?';

  @override
  String get choreArchiveConfirmMessage =>
      'It stops creating new days. Past days and history are kept.';

  @override
  String get choreDuplicateSuffix => ' (copy)';

  @override
  String get choreDuplicated => 'Chore duplicated';

  @override
  String choreSlotCount(String count) {
    return '$count time(s) a day';
  }

  @override
  String get choreStrategyRotation => 'Rotation';

  @override
  String get choreStrategyFixed => 'Fixed person';

  @override
  String get choreStrategyManual => 'Assigned by hand';

  @override
  String get choreEditorTitleNew => 'New chore';

  @override
  String get choreEditorTitleEdit => 'Edit chore';

  @override
  String get choreEditorNotFound => 'This chore was not found';

  @override
  String get choreEditorArchivedNote =>
      'This chore is archived. It can be viewed but not changed.';

  @override
  String get choreEditorPlanningFailed =>
      'The chore was saved, but planning its days failed. Retry to finish.';

  @override
  String get choreEditorSectionBasics => 'Basics';

  @override
  String get choreEditorSectionSchedule => 'Schedule';

  @override
  String get choreEditorSectionWho => 'Who does it';

  @override
  String get choreEditorSectionSteps => 'Steps';

  @override
  String get choreEditorSectionInstructions => 'Instructions';

  @override
  String get choreEditorSectionOptions => 'Options';

  @override
  String get choreEditorNameBn => 'Name (Bangla)';

  @override
  String get choreEditorNameEn => 'Name (English, optional)';

  @override
  String get choreEditorGroup => 'Group';

  @override
  String get choreEditorIcon => 'Icon';

  @override
  String get choreEditorColor => 'Color';

  @override
  String get choreEditorRepeat => 'Repeats';

  @override
  String get choreEditorRepeatChange => 'Change repeat';

  @override
  String get choreEditorNextDates => 'Next dates';

  @override
  String get choreEditorNoNextDates => 'No upcoming dates';

  @override
  String choreEditorStartDate(String date) {
    return 'Starts $date';
  }

  @override
  String choreEditorEndDate(String date) {
    return 'Ends $date';
  }

  @override
  String get choreEditorEndDateNone => 'No end date';

  @override
  String get choreEditorEndDateClear => 'Remove end date';

  @override
  String get choreEditorTimes => 'Times of day';

  @override
  String get choreEditorEstimatedMinutes => 'Estimated minutes (optional)';

  @override
  String get choreEditorDifficulty => 'Difficulty';

  @override
  String get choreDifficultyEasy => 'Easy';

  @override
  String get choreDifficultyNormal => 'Normal';

  @override
  String get choreDifficultyHard => 'Hard';

  @override
  String get choreEditorVerification => 'Needs verification';

  @override
  String get choreEditorVerificationHelp =>
      'A manager checks it after it is done.';

  @override
  String get choreEditorActive => 'Active';

  @override
  String get choreEditorActiveHelp => 'Paused chores create no new days.';

  @override
  String get choreRemindersTitle => 'Reminders';

  @override
  String get choreRemindersStoredNote =>
      'Saved for later: reminders are sent in a future update.';

  @override
  String get choreReminderAtDue => 'At the due time';

  @override
  String get choreReminderBeforeTitle => 'Before the due time';

  @override
  String choreReminderBefore(String minutes) {
    return '$minutes min before';
  }

  @override
  String get choreReminderCustom => 'Other minutes (1-1440)';

  @override
  String get choreReminderCustomAdd => 'Add reminder time';

  @override
  String get choreReminderOverdue => 'When overdue';

  @override
  String get choreReminderOverdueAfter => 'Minutes after the due time';

  @override
  String choreSlotTitle(String number) {
    return 'Time $number';
  }

  @override
  String get choreSlotLabel => 'Name of this time (optional)';

  @override
  String get choreSlotDueTime => 'Due time';

  @override
  String get choreSlotAdd => 'Add another time';

  @override
  String get choreSlotRemove => 'Remove this time';

  @override
  String choreSlotLimit(String max) {
    return 'At most $max times a day.';
  }

  @override
  String get choreSubtasksEmpty => 'No steps yet. Steps are optional.';

  @override
  String get choreSubtaskAdd => 'Add a step';

  @override
  String get choreSubtaskTitle => 'Step';

  @override
  String get choreSubtaskRequired => 'Required step';

  @override
  String get choreSubtaskHint => 'Hint (optional)';

  @override
  String get choreSubtaskRemove => 'Remove step';

  @override
  String choreSubtaskLimit(String max) {
    return 'At most $max steps.';
  }

  @override
  String get choreInstructionsBold => 'Bold';

  @override
  String get choreInstructionsBullet => 'Bullet list';

  @override
  String get choreInstructionsNumbered => 'Numbered list';

  @override
  String get choreInstructionsHint => 'How to do this chore';

  @override
  String get choreInstructionsEmpty => 'No instructions';

  @override
  String get choreAssigneeManualHelp =>
      'Nobody is assigned until a manager picks someone.';

  @override
  String get choreAssigneeFixedLabel => 'Who does it';

  @override
  String get choreAssigneeSourceGroup => 'Duty group';

  @override
  String get choreAssigneeSourceOwn => 'Own rotation';

  @override
  String get choreAssigneePickGroup => 'Choose a duty group';

  @override
  String get choreAssigneeNoGroups =>
      'There is no duty group yet. Create one or use an own rotation.';

  @override
  String get choreReplanTitle => 'Apply this change to';

  @override
  String get choreReplanMessage =>
      'Days that are already started or done are never changed.';

  @override
  String get choreReplanFutureOnly => 'Future days only';

  @override
  String get choreReplanIncludeUpcoming =>
      'Future days and upcoming days nobody has started';

  @override
  String get recurrenceKindOnce => 'Once';

  @override
  String get recurrenceKindDaily => 'Every day';

  @override
  String get recurrenceKindEveryNDays => 'Every few days';

  @override
  String get recurrenceKindWeekdays => 'On certain weekdays';

  @override
  String get recurrenceKindEveryNWeeks => 'Every few weeks';

  @override
  String get recurrenceKindDaysOfMonth => 'Dates of the month';

  @override
  String get recurrenceKindNthWeekday => 'A weekday of the month';

  @override
  String get recurrenceKindLastDay => 'Last day of the month';

  @override
  String get recurrencePickerTitle => 'Repeat';

  @override
  String get recurrencePickerOnceDate => 'Date';

  @override
  String get recurrencePickerEveryNDays => 'Every how many days';

  @override
  String get recurrencePickerEveryNWeeks => 'Every how many weeks';

  @override
  String get recurrencePickerDaysOfMonth => 'Dates of the month';

  @override
  String get recurrencePickerMonthEnd => 'If the month is shorter';

  @override
  String get recurrencePickerMonthEndClamp => 'Use the last day';

  @override
  String get recurrencePickerMonthEndSkip => 'Skip that month';

  @override
  String get recurrencePickerNth => 'Which one';

  @override
  String get recurrencePickerWeekday => 'Day of the week';

  @override
  String get recurrencePickerWeekdays => 'Days of the week';

  @override
  String get recurrenceNthFirst => 'first';

  @override
  String get recurrenceNthSecond => 'second';

  @override
  String get recurrenceNthThird => 'third';

  @override
  String get recurrenceNthFourth => 'fourth';

  @override
  String get recurrenceNthLast => 'last';

  @override
  String get recurrenceListSeparator => ', ';

  @override
  String get recurrenceSummaryOnce => 'Once';

  @override
  String get recurrenceSummaryDaily => 'Every day';

  @override
  String recurrenceSummaryEveryNDays(String n) {
    return 'Every $n days';
  }

  @override
  String recurrenceSummaryWeekdays(String days) {
    return 'Every $days';
  }

  @override
  String recurrenceSummaryEveryNWeeks(String n, String days) {
    return 'Every $n weeks on $days';
  }

  @override
  String recurrenceSummaryDaysOfMonth(String days) {
    return 'On day $days of every month';
  }

  @override
  String recurrenceSummaryNthWeekday(String nth, String weekday) {
    return 'Every $nth $weekday of the month';
  }

  @override
  String get recurrenceSummaryLastDay => 'On the last day of every month';

  @override
  String get starterPackTitle => 'Starter pack';

  @override
  String get starterPackSubtitle => 'Add the family\'s usual chores in one go';

  @override
  String get starterPackManagersOnly =>
      'Only a Household Manager can add a starter pack.';

  @override
  String get starterPackPickBody =>
      'Pick a pack. Every line becomes one of your family\'s own chores; nothing is locked.';

  @override
  String get starterPackFamilyPdfTitle => 'Our family chore list (PDF)';

  @override
  String get starterPackFamilyPdfDescription =>
      'The daily, weekly and monthly chores from the family\'s handwritten list.';

  @override
  String starterPackTemplateCount(String count) {
    return '$count chores';
  }

  @override
  String starterPackCountHigh(String count) {
    return '$count high confidence';
  }

  @override
  String starterPackCountMedium(String count) {
    return '$count medium confidence';
  }

  @override
  String starterPackCountLow(String count) {
    return '$count low confidence';
  }

  @override
  String get starterPackPickHint =>
      'High lines are ticked already. You will confirm the rest in the next step.';

  @override
  String get starterPackReviewBody =>
      'Untick anything you do not want. Medium and Low lines need your confirmation.';

  @override
  String get starterPackConfidenceHigh => 'High';

  @override
  String get starterPackConfidenceMedium => 'Medium';

  @override
  String get starterPackConfidenceLow => 'Low';

  @override
  String get starterPackConfidenceLegend => 'Confidence:';

  @override
  String get starterPackPleaseConfirm => 'please confirm';

  @override
  String get starterPackDetailsTitle => 'Chore details';

  @override
  String get starterPackDetailsSchedule => 'Schedule';

  @override
  String get starterPackDetailsNotes => 'Notes';

  @override
  String get starterPackDetailsSteps => 'Steps';

  @override
  String get starterPackEndOfDay => 'Any time';

  @override
  String get starterPackHouseRulesTitle => 'House rules';

  @override
  String get starterPackHouseRulesHint =>
      'These are saved in Chore settings and shown on the Manage hub.';

  @override
  String get starterPackHouseRulesSwitch => 'Add the house rules from the list';

  @override
  String get starterPackWhoBody =>
      'Choose who shares the daily duty, who goes first and how often the turn changes. Or leave the chores unassigned and decide later.';

  @override
  String get starterPackRotationSwitch => 'Share these chores by rotation';

  @override
  String get starterPackRotationNeedsTwo =>
      'A rotation needs at least two active members.';

  @override
  String get starterPackNoRotationInfo =>
      'The chores will have no assignee. You can assign them one by one later.';

  @override
  String get starterPackMembersTitle => 'Members in the rotation';

  @override
  String get starterPackFirstMemberTitle => 'Who goes first';

  @override
  String get starterPackCycleTitle => 'Turn changes every';

  @override
  String get starterPackNoMembers =>
      'There are no active members to rotate yet. You can assign the chores later.';

  @override
  String get starterPackApply => 'Add these chores';

  @override
  String get starterPackApplying => 'Adding chores…';

  @override
  String get starterPackOpenToday => 'Open Today';

  @override
  String get starterPackResultTitle => 'Starter pack added';

  @override
  String starterPackResultTemplates(String count) {
    return '$count chores added';
  }

  @override
  String starterPackResultSkipped(String count) {
    return '$count already existed';
  }

  @override
  String starterPackResultGroups(String count) {
    return '$count chore groups added';
  }

  @override
  String starterPackResultPresets(String count) {
    return '$count due-time presets added';
  }

  @override
  String starterPackResultDutyGroups(String count) {
    return '$count duty groups added';
  }

  @override
  String get starterPackResultRules => 'House rules added';

  @override
  String starterPackResultGenerated(String count) {
    return '$count chores prepared for today';
  }

  @override
  String get starterPackResultGenerationFailed =>
      'The chores were saved, but today\'s tasks could not be prepared. Open Today and try again.';

  @override
  String starterPackStepOf(String current, String total) {
    return 'Step $current of $total';
  }

  @override
  String get starterPackStepPick => 'Pick a pack';

  @override
  String get starterPackStepReview => 'Review';

  @override
  String get starterPackStepWho => 'Who does what';

  @override
  String get calendarTruncatedBanner =>
      'This month has many chores - not all of them are shown';

  @override
  String get calendarTruncatedBannerAction => 'Open filters';

  @override
  String get calendarToday => 'Today';

  @override
  String get calendarPreviousMonth => 'Previous month';

  @override
  String get calendarNextMonth => 'Next month';

  @override
  String get calendarPickMonth => 'Choose month and year';

  @override
  String get calendarPreviousYear => 'Previous year';

  @override
  String get calendarNextYear => 'Next year';

  @override
  String get calendarGridLabel => 'Month calendar';

  @override
  String get calendarFilters => 'Filters';

  @override
  String calendarFiltersActive(String count) {
    return 'Filters, $count on';
  }

  @override
  String get calendarFiltersNone => 'No filters are on.';

  @override
  String get calendarClearFilters => 'Clear filters';

  @override
  String get calendarDayEmptyTitle => 'No chores this day';

  @override
  String get calendarDayEmptyMessage => 'Nothing is planned for this day.';

  @override
  String calendarDayHeader(String date, String count) {
    return '$date · $count chores';
  }

  @override
  String calendarCellChores(String count) {
    return '$count chores';
  }

  @override
  String calendarCellOverdue(String count) {
    return '$count overdue';
  }

  @override
  String calendarCellMine(String count) {
    return '$count yours';
  }

  @override
  String get calendarCellSelected => 'Selected';

  @override
  String get calendarOpenToday => 'Open today\'s chores';

  @override
  String calendarFreeDays(String count) {
    return '$count free days';
  }

  @override
  String get calendarLoadEarlier => 'Show earlier weeks';

  @override
  String get calendarLoadLater => 'Show later weeks';

  @override
  String get calendarJumpToToday => 'Jump to today';

  @override
  String get calendarLegend => 'What the symbols mean';

  @override
  String get calendarFilterGroups => 'Groups';

  @override
  String get calendarFilterStatuses => 'Status';

  @override
  String get calendarFilterMembers => 'People';

  @override
  String get calendarFilterNeedsAttention => 'Needs attention only';

  @override
  String get calendarSearchHint => 'Search chores';

  @override
  String get calendarAddChore => 'Add chore';

  @override
  String get calendarMonthNarrow =>
      'The month view needs a wider screen, so the week is shown.';

  @override
  String get calendarQuickActions => 'Chore actions';

  @override
  String calendarRemoveFilter(String label) {
    return 'Remove filter $label';
  }

  @override
  String get calendarPreviousWeek => 'Previous week';

  @override
  String get calendarNextWeek => 'Next week';

  @override
  String get calendarCellNeedsCover => 'needs cover';

  @override
  String get calendarCellNeedsAttention => 'needs attention';

  @override
  String get calendarCellAway => 'someone is away';

  @override
  String get calendarCellPlanned => 'planned';

  @override
  String get calendarDisplayOptions => 'Display options';

  @override
  String get calendarHeatMode => 'Workload tint';

  @override
  String get calendarHeatModeHint =>
      'Days with more work get a darker background.';

  @override
  String get calendarHeatLegend => 'Workload';

  @override
  String get calendarHeatLess => 'Less';

  @override
  String get calendarHeatMore => 'More';

  @override
  String get calendarHeatLegendLabel =>
      'Workload from less to more, in four shades';

  @override
  String get calendarLegendMarks => 'Day cell marks';

  @override
  String get calendarLegendPlanned =>
      'Slanted lines: every chore of the day is only planned';

  @override
  String get calendarLegendAway =>
      'Lines leaning the other way: someone is away';

  @override
  String get calendarMonthLandscape =>
      'The month view is not offered on a phone held sideways, so the week is shown.';

  @override
  String get calendarUseFamilyDefaults => 'Use family defaults';

  @override
  String get calendarDayPanelLabel => 'Chores of the selected day';

  @override
  String get galleryCalendarPolish => 'Calendar heat and hatch';

  @override
  String get galleryDashboardCardFrame => 'Dashboard card';

  @override
  String get galleryGreetingHeader => 'Greeting';

  @override
  String get galleryBellButton => 'Notification bell';

  @override
  String get galleryBellOverflow => '9+';

  @override
  String get galleryAlertStrip => 'Alert strip';

  @override
  String get galleryActivityTile => 'Activity';

  @override
  String get galleryStatPill => 'Stat pill';

  @override
  String get galleryTimeOffsetChips => 'Time offsets';

  @override
  String get galleryQuietHoursPicker => 'Quiet hours';

  @override
  String get galleryQuietHoursStart => 'Start time';

  @override
  String get galleryQuietHoursEnd => 'End time';

  @override
  String get gallerySwitchTileWithReason => 'Switch with reason';

  @override
  String get galleryLevelRing => 'Level progress';

  @override
  String get galleryBadgeMedal => 'Achievement badge';

  @override
  String get galleryEarned => 'Earned';

  @override
  String get galleryUnearned => 'Not earned';

  @override
  String get galleryPlantStageView => 'Plant stage';

  @override
  String get galleryConfettiView => 'Celebration confetti';

  @override
  String get galleryDiagnosticRow => 'Diagnostic row';

  @override
  String get galleryReorderableCardTile => 'Reorderable card';

  @override
  String get galleryDragLabel => 'Drag to move';

  @override
  String get galleryMoveUp => 'Move up';

  @override
  String get galleryMoveDown => 'Move down';

  @override
  String get galleryAccessCell => 'Role access';

  @override
  String get galleryAccessHidden => 'Hidden';

  @override
  String get galleryAccessOn => 'On';

  @override
  String get galleryAccessOff => 'Off';

  @override
  String get galleryAccessRequired => 'Required';

  @override
  String get galleryDeliveryModeTile => 'Notification delivery';

  @override
  String get galleryDeliveryNormal => 'Normal';

  @override
  String get galleryDeliveryPush => 'Push';

  @override
  String get galleryRecommended => 'Recommended';

  @override
  String get commentsTitle => 'Comments';

  @override
  String get commentsEmpty =>
      'No comments yet. Say what is wrong or what was done.';

  @override
  String get commentsHint => 'Write a comment';

  @override
  String get commentsSend => 'Send';

  @override
  String get commentsFlagLabel => 'Flag as incorrect or incomplete';

  @override
  String get commentFlagged => 'Needs attention';

  @override
  String get commentResolved => 'Resolved';

  @override
  String get commentResolve => 'Mark as resolved';

  @override
  String get commentReopenWithReason => 'Reopen with this reason';

  @override
  String get commentHide => 'Hide';

  @override
  String get commentUnhide => 'Show again';

  @override
  String get commentHiddenByManager => 'Hidden by a manager';

  @override
  String get commentHideTitle => 'Hide this comment';

  @override
  String get commentUnhideTitle => 'Show this comment again';

  @override
  String get commentHideHint => 'Why? (3 to 200 characters)';

  @override
  String get commentYou => 'You';

  @override
  String get commentUnreadSemantics => 'New comments';

  @override
  String get commentsLimitReached => 'Only the first 200 comments are shown.';

  @override
  String commentsNew(String count) {
    return '$count new';
  }

  @override
  String commentBubbleLabel(String author, String time, String text) {
    return '$author, $time: $text';
  }

  @override
  String activityChoresCommentUnhidden(
    String member,
    String name,
    String date,
  ) {
    return '$member showed a comment on $name on $date again';
  }

  @override
  String get inboxTitle => 'Notifications';

  @override
  String get inboxEmpty => 'No notifications yet';

  @override
  String get inboxToday => 'Today';

  @override
  String get inboxEarlier => 'Earlier';

  @override
  String get inboxSparkNote =>
      'You will see new requests when you open the app.';

  @override
  String get inboxMarkAllRead => 'Mark all as read';

  @override
  String get inboxUnreadSemantics => 'Unread';

  @override
  String get inboxSomeone => 'Someone';

  @override
  String get inboxUnknown => 'New notification';

  @override
  String get swapSheetTitle => 'Ask someone to take this chore';

  @override
  String get swapSheetPerson => 'Who can take it?';

  @override
  String get swapSheetNobody => 'Nobody is available that day.';

  @override
  String get swapSheetReasonHint => 'Why can you not do it?';

  @override
  String get swapSheetSend => 'Send request';

  @override
  String get swapResponseTitle => 'Answer the request';

  @override
  String get swapAccept => 'Accept';

  @override
  String get swapDecline => 'Decline';

  @override
  String get swapDeclineReasonTitle => 'Why not? (optional)';

  @override
  String get swapNeedsInternet => 'This needs an internet connection.';

  @override
  String get swapBannerCancel => 'Cancel request';

  @override
  String get needsCoverTitle => 'Chores that need a cover';

  @override
  String get needsCoverSubtitle => 'Chores nobody can do yet';

  @override
  String get needsCoverEmpty => 'Every chore has someone';

  @override
  String get needsCoverNoAccess => 'Only managers can assign chores.';

  @override
  String get needsCoverAssign => 'Assign';

  @override
  String get availabilityTitle => 'Absences';

  @override
  String get availabilitySubtitle => 'Days you are away';

  @override
  String get availabilityMine => 'Mine';

  @override
  String get availabilityEveryone => 'Everyone';

  @override
  String get availabilityAdd => 'Add absence';

  @override
  String get availabilityEmpty => 'No absences';

  @override
  String get availabilityType => 'Type';

  @override
  String get availabilityPickDates => 'Choose dates';

  @override
  String get availabilityReasonHint => 'Reason (3 to 200 characters)';

  @override
  String get availabilitySave => 'Save';

  @override
  String get availabilityApprove => 'Approve';

  @override
  String get availabilityReject => 'Reject';

  @override
  String get availabilityCancel => 'Cancel absence';

  @override
  String get availabilityStatusPending => 'Waiting for approval';

  @override
  String get availabilityStatusActive => 'Approved';

  @override
  String get availabilityStatusRejected => 'Rejected';

  @override
  String get availabilityStatusCancelled => 'Cancelled';

  @override
  String get availabilityPolicyAsk =>
      'Your chores will be listed as needing a cover, and you and the managers will be told.';

  @override
  String get availabilityPolicyAuto =>
      'Someone who is free will be asked to cover each chore. Nothing changes until they accept.';

  @override
  String get availabilityPolicySkip =>
      'A manager will mark these chores as skipped.';

  @override
  String inboxBellLabel(String count) {
    return 'Notifications, $count unread';
  }

  @override
  String inboxSwapRequest(String name, String chore, String date) {
    return '$name asks you to take $chore on $date';
  }

  @override
  String inboxCoverRequest(String name, String chore, String date) {
    return '$name needs a cover for $chore on $date';
  }

  @override
  String inboxSwapAccepted(String name, String chore, String date) {
    return '$name accepted $chore on $date';
  }

  @override
  String inboxSwapDeclined(String name, String chore, String date) {
    return '$name declined $chore on $date';
  }

  @override
  String inboxSwapCancelled(String name, String chore, String date) {
    return '$name cancelled the request for $chore on $date';
  }

  @override
  String inboxSwapExpired(String chore, String date) {
    return 'The request for $chore on $date ran out of time';
  }

  @override
  String inboxReassigned(String name, String chore, String date) {
    return '$name moved $chore on $date to you';
  }

  @override
  String inboxNeedsCover(String name, String count, String from, String to) {
    return '$name is away from $from to $to: $count chores need a cover';
  }

  @override
  String inboxAbsenceApproved(String name) {
    return '$name approved your absence';
  }

  @override
  String inboxAbsenceRejected(String name) {
    return '$name rejected your absence';
  }

  @override
  String inboxChoreReopened(String name, String chore, String date) {
    return '$name reopened $chore on $date';
  }

  @override
  String inboxCommentAttention(String name, String chore, String date) {
    return '$name flagged $chore on $date';
  }

  @override
  String inboxVerificationNeeded(String name, String chore, String date) {
    return '$name finished $chore on $date; it needs checking';
  }

  @override
  String swapLoadLabel(String count) {
    return '$count chores this month';
  }

  @override
  String swapSheetPreview(String name, String chore, String date) {
    return 'Request to $name: take $chore on $date';
  }

  @override
  String swapReasonLabel(String reason) {
    return 'Reason: $reason';
  }

  @override
  String swapBannerSent(String name) {
    return 'Request sent to $name';
  }

  @override
  String swapBannerForYou(String name) {
    return '$name asked you to take this chore';
  }

  @override
  String availabilityRangeLine(String from, String to) {
    return '$from to $to';
  }

  @override
  String availabilityAffected(String count) {
    return '$count chores are affected';
  }

  @override
  String get rotaTitle => 'Rota board';

  @override
  String get rotaSubtitle => 'Who does what, and how much';

  @override
  String get rotaWeek => 'Week';

  @override
  String get rotaMonth => 'Month';

  @override
  String get rotaOnDuty => 'On duty today';

  @override
  String get rotaOnDutyNobody => 'Nobody has a chore today.';

  @override
  String get rotaShareTitle => 'Share of the work';

  @override
  String get rotaMatrixTitle => 'Members by day';

  @override
  String get rotaEmpty => 'No chores in this range yet.';

  @override
  String get rotaNoAccess => 'The workload is hidden from members.';

  @override
  String rotaShareValue(String percent) {
    return '$percent% of the work';
  }

  @override
  String rotaMemberStats(String assigned, String done) {
    return '$assigned chores, $done done';
  }

  @override
  String rotaCovers(String given, String received) {
    return 'Covered $given, was covered $received';
  }

  @override
  String rotaAway(String days) {
    return '$days days away';
  }

  @override
  String rotaOnDutyCount(String name, String count) {
    return '$name: $count chores';
  }

  @override
  String rotaCellLabel(String member, String day, String count) {
    return '$member, $day: $count chores';
  }

  @override
  String choresDashNext(String name) {
    return 'Next: $name';
  }

  @override
  String choresDashOverdueCount(String count) {
    return '$count overdue';
  }

  @override
  String get choresDashOverdueNone => 'Nothing is overdue';

  @override
  String choresDashOverdueOldest(String name) {
    return 'Oldest: $name';
  }

  @override
  String choresDashVerifyCount(String count) {
    return '$count chores wait for a check';
  }

  @override
  String get choresDashWeekTitle => 'This week';

  @override
  String choresDashWeekDay(String day, String count) {
    return '$day: $count chores';
  }

  @override
  String get choresNewAction => 'New chore';

  @override
  String get choresMyTodayAction => 'My today';

  @override
  String get permissionManageEngagement =>
      'Manage badges, levels and notification defaults';

  @override
  String get permissionManageDashboardLayout =>
      'Choose which dashboard cards each role sees';

  @override
  String get dashModuleCore => 'Family';

  @override
  String get dashModuleBazar => 'Bazar and fund';

  @override
  String get dashModuleChores => 'Chores';

  @override
  String get dashCardBudgetAlert => 'Budget alert';

  @override
  String get dashCardApprovals => 'Approvals';

  @override
  String get dashCardChoresToday => 'Chores today';

  @override
  String get dashCardChoresOverdue => 'Overdue chores';

  @override
  String get dashCardChoresVerify => 'Waiting for a check';

  @override
  String get dashCardBazarMonth => 'Spending this month';

  @override
  String get dashCardBazarFund => 'Family fund';

  @override
  String get dashCardUpcoming => 'Coming up';

  @override
  String get dashCardChoresWeek => 'This week';

  @override
  String get dashCardHubLevel => 'Hub level';

  @override
  String get dashCardRecentActivity => 'Recent activity';

  @override
  String get notifChannelChoresDue => 'Chore reminders';

  @override
  String get notifChannelChoresOverdue => 'Overdue chores';

  @override
  String get notifChannelDailySummary => 'Morning summary';

  @override
  String get notifChannelBazar => 'Bazar and fund';

  @override
  String get notifChannelFamily => 'Family';

  @override
  String get notifChannelPushEvents => 'Push alerts';

  @override
  String get levelNameSeed => 'Seed';

  @override
  String get levelNameSprout => 'Sprout';

  @override
  String get levelNameSeedling => 'Seedling';

  @override
  String get levelNameSapling => 'Sapling';

  @override
  String get levelNameYoungTree => 'Young tree';

  @override
  String get levelNameFlowering => 'Flowering';

  @override
  String get levelNameFruiting => 'Fruiting';

  @override
  String get levelNameGrandTree => 'Grand tree';

  @override
  String get engagementVisibilityPrivate => 'private';

  @override
  String get engagementVisibilityLevels => 'levels and badges only';

  @override
  String get activityNotificationDefaultsUpdated =>
      'Notification defaults were changed';

  @override
  String get activityNotificationDeliveryUpdated =>
      'Push and normal delivery settings were changed';

  @override
  String get activityDashboardPolicyUpdated =>
      'Dashboard access for roles was changed';

  @override
  String get activityEngagementSettingsUpdated =>
      'Badge and level settings were changed';

  @override
  String activityEngagementPrivacyUpdated(String visibility) {
    return 'Stats sharing: $visibility';
  }

  @override
  String get notificationFailure_invalid_minutes =>
      'Enter a number of minutes between 1 and 1440.';

  @override
  String get notificationFailure_invalid_offsets =>
      'One of the reminder times is not valid.';

  @override
  String get notificationFailure_too_many_offsets =>
      'You can set at most 5 reminders.';

  @override
  String get notificationFailure_invalid_quiet_hours =>
      'The quiet hours are not valid.';

  @override
  String get notificationFailure_unknown_notification_type =>
      'This notification type is not known.';

  @override
  String get notificationFailure_type_not_push_capable =>
      'This notification cannot be sent as a push.';

  @override
  String get notificationFailure_permission_denied_by_os =>
      'Notifications are turned off for this app in the phone settings.';

  @override
  String get notificationFailure_exact_alarm_denied =>
      'Exact reminder times are not allowed on this phone. Reminders may arrive a little late.';

  @override
  String get notificationFailure_scheduler_unavailable =>
      'Reminders could not be scheduled on this phone.';

  @override
  String get notificationFailure_push_unavailable =>
      'Push notifications are not available right now.';

  @override
  String get notificationFailure_inboxItem =>
      'This notification could not be found.';

  @override
  String reminderDueTitle(String choreName) {
    return 'Time for $choreName';
  }

  @override
  String reminderDueBody(String choreName, String time) {
    return 'It is time to do $choreName, due at $time.';
  }

  @override
  String reminderBeforeTitle(String choreName) {
    return 'Coming up: $choreName';
  }

  @override
  String reminderBeforeBody(String choreName, String minutes, String time) {
    return '$choreName is due in $minutes minutes, at $time.';
  }

  @override
  String reminderOverdueTitle(String choreName) {
    return 'Still open: $choreName';
  }

  @override
  String reminderOverdueBody(String choreName) {
    return '$choreName is not complete yet.';
  }

  @override
  String get reminderNudgeTitle => 'A reminder for today';

  @override
  String reminderNudgeBody(String count) {
    return '$count more chores are still open today.';
  }

  @override
  String get reminderSummaryTitle => 'Today\'s chores';

  @override
  String reminderSummaryBody(String count) {
    return 'You have $count chores today.';
  }

  @override
  String get reminderContributionDueTitle => 'Monthly contribution reminder';

  @override
  String get reminderContributionDueBody =>
      'Your contribution for this month is due.';

  @override
  String get reminderMonthEndTitle => 'Month-end bazar reminder';

  @override
  String get reminderMonthEndBody =>
      'It is time to close this month\'s bazar books.';

  @override
  String get engagementFailure_invalid_levels => 'The level list is not valid.';

  @override
  String get engagementFailure_levels_not_ascending =>
      'Each level needs more points than the one before it.';

  @override
  String get engagementFailure_too_many_levels =>
      'You can have at most 12 levels.';

  @override
  String get engagementFailure_invalid_threshold =>
      'One of the badge limits is not valid.';

  @override
  String get engagementFailure_invalid_points =>
      'One of the point values is not valid.';

  @override
  String get engagementFailure_invalid_permille =>
      'One of the percentage values is not valid.';

  @override
  String get engagementFailure_invalid_visibility =>
      'This sharing choice is not valid.';

  @override
  String get engagementFailure_stats_not_owner =>
      'Only the owner can change these stats.';

  @override
  String get engagementFailure_stats_regression =>
      'These stats could not be updated.';

  @override
  String get engagementFailure_engagement_disabled =>
      'Badges and levels are switched off for this family.';

  @override
  String get engagementFailure_already_celebrated =>
      'Today celebration was already shown.';

  @override
  String get engagementFailure_sharing_not_allowed =>
      'Sharing is not turned on for this family.';

  @override
  String get engagementFailure_memberStats => 'These stats could not be found.';

  @override
  String get dashboardFailure_unknown_card =>
      'This dashboard card is not known.';

  @override
  String get dashboardFailure_invalid_access =>
      'This access choice is not valid.';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get greetingDefaultName => 'there';

  @override
  String get dashboardBellOverflow => '9+';

  @override
  String get dashboardMenu => 'Dashboard options';

  @override
  String get dashboardCustomize => 'Customize dashboard';

  @override
  String get dashboardAccess => 'Dashboard access by role';

  @override
  String get dashboardEmptyTitle => 'Your dashboard is empty';

  @override
  String get dashboardEmptyMessage =>
      'Choose which cards to show and arrange them for yourself.';

  @override
  String get dashboardUpcomingTitle => 'Coming up';

  @override
  String get dashboardUpcomingEmpty =>
      'You have no upcoming chores assigned to you.';

  @override
  String get dashboardApprovalsTitle => 'Needs your attention';

  @override
  String dashboardPendingJoinRequests(String count) {
    return 'Join requests: $count';
  }

  @override
  String dashboardPendingContributions(String count) {
    return 'Contribution requests: $count';
  }

  @override
  String get dashboardRecentActivityTitle => 'Recent activity';

  @override
  String get dashboardHubLevelTitle => 'Hub Level';

  @override
  String get dashboardHubLevelComingSoon =>
      'Your family progress will appear here.';

  @override
  String get dashboardAskAiTitle => 'Ask Family Hub';

  @override
  String get dashboardAskAiMessage => 'Ask a question about your household.';

  @override
  String get dashboardCardBudgetAlert => 'Budget alert';

  @override
  String get dashboardCardApprovals => 'Approvals';

  @override
  String get dashboardCardChoresToday => 'Today\'s chores';

  @override
  String get dashboardCardChoresOverdue => 'Overdue chores';

  @override
  String get dashboardCardChoresVerify => 'Awaiting verification';

  @override
  String get dashboardCardBazarMonth => 'Monthly spending';

  @override
  String get dashboardCardBazarFund => 'Fund balance';

  @override
  String get dashboardCardUpcoming => 'Coming up';

  @override
  String get dashboardCardChoresWeek => 'This week';

  @override
  String get dashboardCardHubLevel => 'Hub Level';

  @override
  String get dashboardCardRecentActivity => 'Recent activity';

  @override
  String get dashboardPersonalLayoutNote =>
      'Only you see this dashboard layout.';

  @override
  String get dashboardHiddenCards => 'Hidden cards';

  @override
  String get dashboardAddBack => 'Add back';

  @override
  String get dashboardMoveUp => 'Move up';

  @override
  String get dashboardMoveDown => 'Move down';

  @override
  String dashboardDragCard(Object card) {
    return 'Reorder $card';
  }

  @override
  String get dashboardRequired => 'Required';

  @override
  String get dashboardReset => 'Reset to default';

  @override
  String get dashboardResetTitle => 'Reset dashboard layout?';

  @override
  String get dashboardResetMessage =>
      'Your card order and visibility will return to the default.';

  @override
  String get dashboardPrefsSyncPending =>
      'Your layout is saved on this device and will sync when online.';

  @override
  String get dashboardAccessInfo =>
      'Choose which dashboard cards Household Managers and Members can see. Admins always see every available card.';

  @override
  String get dashboardAdminAlways => 'Admin: Always visible';

  @override
  String get dashboardPreviewTitle => 'Preview as';

  @override
  String get dashboardPreviewEmpty => 'No cards are visible in this preview.';

  @override
  String get dashboardAccessHidden => 'Hidden';

  @override
  String get dashboardAccessVisible => 'Visible';

  @override
  String get dashboardAccessOff => 'Off by default';

  @override
  String get dashboardCardPermissionMissing =>
      'This role cannot use the card\'s feature.';

  @override
  String get dashboardAccessOffline =>
      'Connect to the internet to save dashboard access.';

  @override
  String get dashboardSaving => 'Saving…';

  @override
  String get dashboardAccessDenied =>
      'You do not have permission to change dashboard access.';

  @override
  String get dashboardResetRecommended => 'Reset to recommended';

  @override
  String get dashboardResetRecommendedTitle => 'Reset dashboard access?';

  @override
  String get dashboardResetRecommendedMessage =>
      'All role access choices will return to the recommended defaults.';

  @override
  String get dashboardDiscardTitle => 'Discard changes?';

  @override
  String get dashboardDiscardMessage =>
      'Your unsaved dashboard access changes will be lost.';

  @override
  String get dashboardDiscard => 'Discard';

  @override
  String get activityTitle => 'Activity';

  @override
  String get activityEmpty => 'There is no activity yet.';

  @override
  String get activityNoMatches => 'No activity matches these filters.';

  @override
  String get activityLoadError =>
      'Could not load activity. Check your connection and try again.';

  @override
  String get activityLoadMore => 'Load more';

  @override
  String get activityModuleFilter => 'Module';

  @override
  String get activityModuleAll => 'All modules';

  @override
  String get activityModuleBazar => 'Bazar & finance';

  @override
  String get activityModuleChores => 'Chores';

  @override
  String get activityModuleFamily => 'Family';

  @override
  String get activityModuleEngagement => 'Badges & levels';

  @override
  String get activityMemberFilter => 'Member';

  @override
  String get activityMemberAll => 'All members';

  @override
  String get activityUnknownActor => 'Unknown member';
}
