part of 'notification_settings_screen.dart';

bool _sameInts(List<int> left, List<int> right) =>
    left.length == right.length &&
    List<int>.generate(
      left.length,
      (index) => left[index] - right[index],
    ).every((difference) => difference == 0);

String _effectivePushReason(
  BuildContext context,
  WidgetRef ref,
  MemberNotificationPrefs member,
) {
  final l10n = context.l10n;
  if (!member.pushEnabled) return l10n.notificationPushDisabledHere;
  final mode = ref.watch(effectiveModeProvider('swap_request'));
  if (!mode.hasValue) return l10n.notificationSenderChecking;
  return switch (mode.requireValue.reason) {
    DeliveryReason.backendUnavailable => l10n.notificationSenderSparkHint,
    DeliveryReason.masterOff => l10n.notificationPushAdminOff,
    DeliveryReason.noPermission => l10n.notificationPermissionDenied,
    DeliveryReason.noToken => l10n.notificationPushTokenMissing,
    DeliveryReason.memberOptedOut => l10n.notificationPushDisabledHere,
    DeliveryReason.pushChosen => l10n.notificationSenderReady,
    DeliveryReason.normalChosen ||
    DeliveryReason.notPushCapable => l10n.notificationNormal,
  };
}
