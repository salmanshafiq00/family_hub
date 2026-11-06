enum NotificationCategory { chores, bazar, family }

enum NotificationTypeKind { event, scheduled, derived }

enum DeliveryMode { normal, push }

final class NotificationType {
  const NotificationType({
    required this.id,
    required this.category,
    required this.kind,
    required this.pushCapable,
    required this.recommendedMode,
    required this.userMutable,
    required this.labelKey,
  }) : assert(pushCapable == (kind == NotificationTypeKind.event));

  final String id;
  final NotificationCategory category;
  final NotificationTypeKind kind;
  final bool pushCapable;
  final DeliveryMode recommendedMode;
  final bool userMutable;
  final String labelKey;

  NotificationType copyWith({
    String? id,
    NotificationCategory? category,
    NotificationTypeKind? kind,
    bool? pushCapable,
    DeliveryMode? recommendedMode,
    bool? userMutable,
    String? labelKey,
  }) => NotificationType(
    id: id ?? this.id,
    category: category ?? this.category,
    kind: kind ?? this.kind,
    pushCapable: pushCapable ?? this.pushCapable,
    recommendedMode: recommendedMode ?? this.recommendedMode,
    userMutable: userMutable ?? this.userMutable,
    labelKey: labelKey ?? this.labelKey,
  );

  @override
  bool operator ==(Object other) =>
      other is NotificationType &&
      other.id == id &&
      other.category == category &&
      other.kind == kind &&
      other.pushCapable == pushCapable &&
      other.recommendedMode == recommendedMode &&
      other.userMutable == userMutable &&
      other.labelKey == labelKey;

  @override
  int get hashCode => Object.hash(
    id,
    category,
    kind,
    pushCapable,
    recommendedMode,
    userMutable,
    labelKey,
  );
}

abstract final class NotificationTypes {
  static const List<NotificationType> all = <NotificationType>[
    NotificationType(
      id: 'swap_request',
      category: NotificationCategory.chores,
      kind: NotificationTypeKind.event,
      pushCapable: true,
      recommendedMode: DeliveryMode.push,
      userMutable: true,
      labelKey: 'notificationTypeSwapRequest',
    ),
    NotificationType(
      id: 'swap_result',
      category: NotificationCategory.chores,
      kind: NotificationTypeKind.event,
      pushCapable: true,
      recommendedMode: DeliveryMode.push,
      userMutable: true,
      labelKey: 'notificationTypeSwapResult',
    ),
    NotificationType(
      id: 'needs_cover',
      category: NotificationCategory.chores,
      kind: NotificationTypeKind.event,
      pushCapable: true,
      recommendedMode: DeliveryMode.push,
      userMutable: true,
      labelKey: 'notificationTypeNeedsCover',
    ),
    NotificationType(
      id: 'chore_assigned',
      category: NotificationCategory.chores,
      kind: NotificationTypeKind.event,
      pushCapable: true,
      recommendedMode: DeliveryMode.push,
      userMutable: true,
      labelKey: 'notificationTypeChoreAssigned',
    ),
    NotificationType(
      id: 'chore_reopened',
      category: NotificationCategory.chores,
      kind: NotificationTypeKind.event,
      pushCapable: true,
      recommendedMode: DeliveryMode.push,
      userMutable: true,
      labelKey: 'notificationTypeChoreReopened',
    ),
    NotificationType(
      id: 'comment_attention',
      category: NotificationCategory.chores,
      kind: NotificationTypeKind.event,
      pushCapable: true,
      recommendedMode: DeliveryMode.normal,
      userMutable: true,
      labelKey: 'notificationTypeCommentAttention',
    ),
    NotificationType(
      id: 'verification_needed',
      category: NotificationCategory.chores,
      kind: NotificationTypeKind.event,
      pushCapable: true,
      recommendedMode: DeliveryMode.normal,
      userMutable: true,
      labelKey: 'notificationTypeVerificationNeeded',
    ),
    NotificationType(
      id: 'absence_decision',
      category: NotificationCategory.chores,
      kind: NotificationTypeKind.event,
      pushCapable: true,
      recommendedMode: DeliveryMode.normal,
      userMutable: true,
      labelKey: 'notificationTypeAbsenceDecision',
    ),
    NotificationType(
      id: 'member_join_request',
      category: NotificationCategory.family,
      kind: NotificationTypeKind.event,
      pushCapable: true,
      recommendedMode: DeliveryMode.push,
      userMutable: true,
      labelKey: 'notificationTypeMemberJoinRequest',
    ),
    NotificationType(
      id: 'member_approved',
      category: NotificationCategory.family,
      kind: NotificationTypeKind.event,
      pushCapable: true,
      recommendedMode: DeliveryMode.push,
      userMutable: true,
      labelKey: 'notificationTypeMemberApproved',
    ),
    NotificationType(
      id: 'chore_due',
      category: NotificationCategory.chores,
      kind: NotificationTypeKind.scheduled,
      pushCapable: false,
      recommendedMode: DeliveryMode.normal,
      userMutable: false,
      labelKey: 'notificationTypeChoreDue',
    ),
    NotificationType(
      id: 'chore_overdue',
      category: NotificationCategory.chores,
      kind: NotificationTypeKind.scheduled,
      pushCapable: false,
      recommendedMode: DeliveryMode.normal,
      userMutable: false,
      labelKey: 'notificationTypeChoreOverdue',
    ),
    NotificationType(
      id: 'evening_nudge',
      category: NotificationCategory.chores,
      kind: NotificationTypeKind.scheduled,
      pushCapable: false,
      recommendedMode: DeliveryMode.normal,
      userMutable: false,
      labelKey: 'notificationTypeEveningNudge',
    ),
    NotificationType(
      id: 'morning_summary',
      category: NotificationCategory.chores,
      kind: NotificationTypeKind.scheduled,
      pushCapable: false,
      recommendedMode: DeliveryMode.normal,
      userMutable: false,
      labelKey: 'notificationTypeMorningSummary',
    ),
    NotificationType(
      id: 'contribution_due',
      category: NotificationCategory.bazar,
      kind: NotificationTypeKind.scheduled,
      pushCapable: false,
      recommendedMode: DeliveryMode.normal,
      userMutable: false,
      labelKey: 'notificationTypeContributionDue',
    ),
    NotificationType(
      id: 'month_end',
      category: NotificationCategory.bazar,
      kind: NotificationTypeKind.scheduled,
      pushCapable: false,
      recommendedMode: DeliveryMode.normal,
      userMutable: false,
      labelKey: 'notificationTypeMonthEnd',
    ),
    NotificationType(
      id: 'budget_alert',
      category: NotificationCategory.bazar,
      kind: NotificationTypeKind.derived,
      pushCapable: false,
      recommendedMode: DeliveryMode.normal,
      userMutable: false,
      labelKey: 'notificationTypeBudgetAlert',
    ),
    NotificationType(
      id: 'achievement',
      category: NotificationCategory.chores,
      kind: NotificationTypeKind.derived,
      pushCapable: false,
      recommendedMode: DeliveryMode.normal,
      userMutable: false,
      labelKey: 'notificationTypeAchievement',
    ),
  ];

  static const Map<String, String> _inboxTypeIds = <String, String>{
    'swap_request': 'swap_request',
    'swap_result': 'swap_result',
    'needs_cover': 'needs_cover',
    'chore_reopened': 'chore_reopened',
    'comment_attention': 'comment_attention',
    'verification_needed': 'verification_needed',
    'absence_decision': 'absence_decision',
    'chore_assigned': 'chore_assigned',
    'member_approved': 'member_approved',
  };

  static NotificationType? byId(String id) {
    for (final type in all) {
      if (type.id == id) return type;
    }
    return null;
  }

  static String? forInbox(String inboxType) => _inboxTypeIds[inboxType];
}
