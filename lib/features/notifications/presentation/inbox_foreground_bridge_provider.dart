import 'dart:async';

import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/notifications/domain/notification_id_factory.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/notifications/domain/planned_notification.dart';
import 'package:family_hub/core/notifications/domain/push_message.dart';
import 'package:family_hub/core/notifications/presentation/push_providers.dart';
import 'package:family_hub/core/utils/clock_provider.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/notifications/domain/inbox_item.dart';
import 'package:family_hub/features/notifications/presentation/foreground_notification_bridge.dart';
import 'package:family_hub/features/notifications/presentation/inbox_providers.dart';
import 'package:family_hub/features/notifications/presentation/inbox_text.dart';
import 'package:family_hub/features/notifications/presentation/notification_providers.dart';
import 'package:family_hub/features/notifications/presentation/reminder_providers.dart';
import 'package:family_hub/app/theme/theme_controller.dart'
    show sharedPreferencesProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bridges newly-created inbox rows and foreground FCM messages to local
/// notifications. The first inbox snapshot is a baseline, not a notification
/// batch; local and push delivery share the same persisted inbox-id set.
final foregroundNotificationBridgeProvider = Provider<void>((ref) {
  final diagnostics = ref.read(reminderDiagnosticsProvider.notifier);
  final knownIds = <String>{};
  final pendingNormal = <String, InboxItem>{};
  final pendingPush = <String, PushMessage>{};
  var hasBaseline = false;
  var flushing = false;

  Future<void> show({
    required String inboxId,
    required String title,
    required String body,
    required String route,
    required NotificationChannelId channel,
  }) async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    final notification = PlannedNotification(
      id: NotificationIdFactory.of('inbox', inboxId, uid),
      kind: PlannedNotificationKind.nudge,
      scheduledAt: ref.read(clockProvider).nowUtc(),
      title: title,
      body: body,
      payload: route,
      refId: inboxId,
      channelId: channel,
    );
    final bridge = ForegroundNotificationBridge(
      scheduler: ref.read(reminderSchedulerProvider),
      preferences: ref.read(sharedPreferencesProvider),
      viewerId: uid,
    );
    await bridge.showOnce(inboxId, notification);
  }

  Future<void> flush() async {
    if (flushing) return;
    flushing = true;
    try {
      var madeProgress = true;
      while (madeProgress) {
        madeProgress = false;
        for (final entry in pendingNormal.entries.toList()) {
          final typeId = NotificationTypes.forInbox(entry.value.type);
          if (typeId == null) {
            pendingNormal.remove(entry.key);
            continue;
          }
          final mode = ref.read(effectiveModeProvider(typeId));
          if (!mode.hasValue && !mode.hasError) continue;
          pendingNormal.remove(entry.key);
          madeProgress = true;
          if (mode.hasError) {
            diagnostics.recordError(
              mode.error!,
              mode.stackTrace ?? StackTrace.empty,
            );
            continue;
          }
          if (mode.requireValue.mode != DeliveryMode.normal) continue;

          final locale = ref.read(localeControllerProvider).locale;
          final l10n = lookupAppLocalizations(locale);
          final item = entry.value;
          final type = NotificationTypes.byId(typeId);
          if (type == null) continue;
          final channel = switch (type.category) {
            NotificationCategory.family => NotificationChannelId.family,
            NotificationCategory.bazar => NotificationChannelId.bazar,
            NotificationCategory.chores => NotificationChannelId.pushEvents,
          };
          await show(
            inboxId: item.id,
            title: l10n.appName,
            body: inboxTextOf(
              l10n,
              ref.read(appFormattersProvider),
              item,
              ref.read(membersProvider).value ?? const [],
            ),
            // Open the exact row so an actionable item (a swap request) can
            // show its response sheet after the tap.
            route: AppRoutes.inboxItem(item.id),
            channel: channel,
          );
        }

        for (final entry in pendingPush.entries.toList()) {
          pendingPush.remove(entry.key);
          madeProgress = true;
          final message = entry.value;
          final locale = ref.read(localeControllerProvider).locale;
          final l10n = lookupAppLocalizations(locale);
          await show(
            inboxId: entry.key,
            title: message.title?.trim().isNotEmpty == true
                ? message.title!.trim()
                : l10n.appName,
            body: message.body?.trim().isNotEmpty == true
                ? message.body!.trim()
                : l10n.inboxUnknown,
            route: message.route ?? AppRoutes.inbox,
            channel: NotificationChannelId.pushEvents,
          );
        }
      }
    } on Object catch (error, stackTrace) {
      diagnostics.recordError(error, stackTrace);
    } finally {
      flushing = false;
    }
  }

  ref.listen(inboxProvider, (_, next) {
    if (!next.hasValue) {
      final error = next.error;
      if (error != null) {
        diagnostics.recordError(error, next.stackTrace ?? StackTrace.empty);
      }
      return;
    }
    final items = next.requireValue;
    if (!hasBaseline) {
      knownIds.addAll(items.map((item) => item.id));
      hasBaseline = true;
      return;
    }
    for (final item in items) {
      if (knownIds.add(item.id) && item.isUnread) {
        pendingNormal[item.id] = item;
      }
    }
    unawaited(flush());
  });

  for (final type in NotificationTypes.all) {
    ref.listen(effectiveModeProvider(type.id), (_, _) {
      unawaited(flush());
    });
  }

  ref.listen(pushForegroundMessagesProvider, (_, next) {
    if (next.hasValue) {
      final message = next.requireValue;
      final inboxId = message.inboxId;
      if (inboxId != null && inboxId.isNotEmpty) {
        pendingPush[inboxId] = message;
        unawaited(flush());
      }
    } else if (next.error != null) {
      diagnostics.recordError(next.error!, next.stackTrace ?? StackTrace.empty);
    }
  });
});
