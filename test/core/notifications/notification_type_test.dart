import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/features/notifications/domain/inbox_port.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the catalog matches the 18 roadmap types in admin screen order', () {
    expect(NotificationTypes.all.map((type) => type.id).toList(), <String>[
      'swap_request',
      'swap_result',
      'needs_cover',
      'chore_assigned',
      'chore_reopened',
      'comment_attention',
      'verification_needed',
      'absence_decision',
      'member_join_request',
      'member_approved',
      'chore_due',
      'chore_overdue',
      'evening_nudge',
      'morning_summary',
      'contribution_due',
      'month_end',
      'budget_alert',
      'achievement',
    ]);
  });

  test('push capability follows the event kind', () {
    for (final type in NotificationTypes.all) {
      expect(
        type.pushCapable,
        type.kind == NotificationTypeKind.event,
        reason: type.id,
      );
    }
  });

  test('categories and event kinds match the catalog specification', () {
    expect(
      NotificationTypes.all
          .where((type) => type.category == NotificationCategory.chores)
          .map((type) => type.id),
      containsAll(<String>[
        'swap_request',
        'swap_result',
        'needs_cover',
        'chore_assigned',
        'chore_reopened',
        'comment_attention',
        'verification_needed',
        'absence_decision',
        'chore_due',
        'chore_overdue',
        'evening_nudge',
        'morning_summary',
        'achievement',
      ]),
    );
    expect(
      NotificationTypes.all
          .where((type) => type.category == NotificationCategory.bazar)
          .map((type) => type.id),
      <String>['contribution_due', 'month_end', 'budget_alert'],
    );
    expect(
      NotificationTypes.all
          .where((type) => type.category == NotificationCategory.family)
          .map((type) => type.id),
      <String>['member_join_request', 'member_approved'],
    );
    expect(
      NotificationTypes.all
          .where((type) => type.kind == NotificationTypeKind.scheduled)
          .map((type) => type.id),
      <String>[
        'chore_due',
        'chore_overdue',
        'evening_nudge',
        'morning_summary',
        'contribution_due',
        'month_end',
      ],
    );
    expect(
      NotificationTypes.all
          .where((type) => type.kind == NotificationTypeKind.derived)
          .map((type) => type.id),
      <String>['budget_alert', 'achievement'],
    );
  });

  test('recommended modes match the roadmap defaults', () {
    final recommendedPushIds = NotificationTypes.all
        .where((type) => type.recommendedMode == DeliveryMode.push)
        .map((type) => type.id)
        .toSet();

    expect(recommendedPushIds, <String>{
      'swap_request',
      'swap_result',
      'needs_cover',
      'chore_assigned',
      'chore_reopened',
      'member_join_request',
      'member_approved',
    });
    expect(
      NotificationTypes.all
          .where((type) => !type.pushCapable)
          .every((type) => !type.userMutable),
      isTrue,
    );
  });

  test('every catalog type has a unique, non-empty localization key', () {
    final keys = NotificationTypes.all.map((type) => type.labelKey).toSet();
    expect(keys, hasLength(NotificationTypes.all.length));
    expect(keys.every((key) => key.isNotEmpty), isTrue);
  });

  test(
    'inbox types map to catalog ids, including the two planned additions',
    () {
      for (final inboxType in InboxType.all) {
        expect(
          NotificationTypes.forInbox(inboxType),
          inboxType,
          reason: inboxType,
        );
      }
      expect(NotificationTypes.forInbox('chore_assigned'), 'chore_assigned');
      expect(NotificationTypes.forInbox('member_approved'), 'member_approved');
      expect(NotificationTypes.forInbox('unknown'), isNull);
    },
  );

  test('catalog lookup returns null for unknown ids', () {
    expect(NotificationTypes.byId('swap_request')?.id, 'swap_request');
    expect(NotificationTypes.byId('unknown'), isNull);
  });

  test('catalog entries have value equality and copyWith', () {
    final type = NotificationTypes.all.first;
    expect(type.copyWith(), type);
    expect(type.copyWith(recommendedMode: DeliveryMode.normal), isNot(type));
    expect(
      type.copyWith(recommendedMode: DeliveryMode.normal).hashCode,
      isNot(type.hashCode),
    );
  });
}
