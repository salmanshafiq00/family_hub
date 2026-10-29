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
}
