import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/notifications/domain/planned_notification.dart';
import 'package:family_hub/core/notifications/domain/reminder_planner.dart';
import 'package:family_hub/core/notifications/domain/reminder_precedence.dart';
import 'package:family_hub/core/notifications/domain/reminder_settings.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final texts = _FakeReminderTexts();
  final now = DateTime.utc(2026, 11, 2, 0);
  final localNow = DateTime.utc(2026, 11, 1, 20);
  final due = DateTime.utc(2026, 11, 2, 6);

  PlannableChore chore(
    String id, {
    DateTime? dueAt,
    PlannableChoreStatus status = PlannableChoreStatus.scheduled,
    String? assigneeId = 'me',
    bool isProjected = false,
    bool isUnavailable = false,
    int? dueMinutes = 360,
  }) => PlannableChore(
    id: id,
    templateId: 'template_$id',
    dueAt: dueAt ?? due,
    status: status,
    assigneeId: assigneeId,
    nameBn: 'কাজ $id',
    nameEn: 'Chore $id',
    dueMinutes: dueMinutes,
    isProjected: isProjected,
    isUnavailable: isUnavailable,
  );

  PlanInput input({
    DateTime? at,
    List<PlannableChore> items = const <PlannableChore>[],
    ReminderSettings? settings,
    Map<String, TemplateReminderConfig> templates =
        const <String, TemplateReminderConfig>{},
    BazarReminderInput bazar = const BazarReminderInput(),
    int windowDays = kReminderWindowDays,
    Map<String, DeliveryMode> effectiveModes = const <String, DeliveryMode>{},
  }) => PlanInput(
    now: at ?? now,
    viewerId: 'me',
    items: items,
    templateIndex: templates,
    settings: settings ?? ReminderSettings(quietEnabled: false),
    familyTz: 'Asia/Dhaka',
    texts: texts,
    bazar: bazar,
    windowDays: windowDays,
    effectiveModes: effectiveModes,
  );

  List<PlannedNotification> plan(PlanInput value) =>
      ReminderPlanner.plan(value);

  test('plans before-due and at-due notifications in ascending order', () {
    final result = plan(input(items: <PlannableChore>[chore('one')]));
    final choreNotifications = result
        .where((notification) => notification.refId == 'one')
        .toList();

    expect(
      choreNotifications.map((notification) => notification.kind),
      <PlannedNotificationKind>[
        PlannedNotificationKind.before,
        PlannedNotificationKind.due,
      ],
    );
    expect(
      choreNotifications.first.scheduledAt,
      due.subtract(const Duration(minutes: 30)),
    );
    expect(choreNotifications.last.scheduledAt, due);
    expect(choreNotifications.last.payload, '/chores/occurrence/one');
    expect(
      choreNotifications.every(
        (notification) =>
            notification.channelId == NotificationChannelId.choresDue,
      ),
      isTrue,
    );
  });

  test('global off suppresses reminders but retains saved timings', () {
    final settings = ReminderSettings(
      globalEnabled: false,
      defaultOffsetsMinutes: const <int>[15, 45],
      overdueEnabled: true,
      quietEnabled: false,
    );
    final result = plan(
      input(items: <PlannableChore>[chore('one')], settings: settings),
    );

    expect(
      ReminderPrecedence.resolve(
        settings: settings,
        category: NotificationCategory.chores,
      ).offsetsMinutes,
      <int>[15, 45],
    );
    expect(result.where((n) => n.refId == 'one'), isEmpty);
  });

  test('disabled template suppresses only that template', () {
    final first = chore('first');
    final second = chore('second');
    final result = plan(
      input(
        items: <PlannableChore>[first, second],
        templates: <String, TemplateReminderConfig>{
          first.templateId: TemplateReminderConfig(enabled: false),
        },
      ),
    );

    expect(result.where((n) => n.refId == first.id), isEmpty);
    expect(result.where((n) => n.refId == second.id), isNotEmpty);
  });

  test('enabled template with no timings produces no chore reminder', () {
    final item = chore('one');
    final result = plan(
      input(
        items: <PlannableChore>[item],
        templates: <String, TemplateReminderConfig>{
          item.templateId: TemplateReminderConfig(
            enabled: true,
            atDue: false,
            overdueEnabled: false,
          ),
        },
      ),
    );

    expect(result.where((n) => n.refId == item.id), isEmpty);
  });

  test('template timings replace the defaults', () {
    final item = chore('one');
    final result = plan(
      input(
        items: <PlannableChore>[item],
        templates: <String, TemplateReminderConfig>{
          item.templateId: TemplateReminderConfig(
            enabled: true,
            atDue: false,
            offsetsMinutes: const <int>[10, 20],
          ),
        },
      ),
    );
    final reminders = result.where((n) => n.refId == item.id).toList();

    expect(
      reminders.map((notification) => notification.scheduledAt),
      <DateTime>[
        due.subtract(const Duration(minutes: 20)),
        due.subtract(const Duration(minutes: 10)),
      ],
    );
  });

  test('overdue reminder is scheduled once at the configured delay', () {
    final item = chore('overdue');
    final result = plan(
      input(
        items: <PlannableChore>[item],
        templates: <String, TemplateReminderConfig>{
          item.templateId: TemplateReminderConfig(
            enabled: true,
            atDue: false,
            overdueEnabled: true,
            overdueAfterMinutes: 60,
          ),
        },
      ),
    );
    final reminders = result
        .where((n) => n.kind == PlannedNotificationKind.overdue)
        .toList();

    expect(reminders, hasLength(1));
    expect(reminders.single.scheduledAt, due.add(const Duration(hours: 1)));
    expect(reminders.single.channelId, NotificationChannelId.choresOverdue);
  });

  test('only assigned open and available chores are planned', () {
    final result = plan(
      input(
        items: <PlannableChore>[
          chore('mine'),
          chore('other', assigneeId: 'someone_else'),
          chore('completed', status: PlannableChoreStatus.completed),
          chore('verified', status: PlannableChoreStatus.verified),
          chore('skipped', status: PlannableChoreStatus.skipped),
          chore('away', isUnavailable: true),
        ],
      ),
    );

    expect(result.where((n) => n.refId == 'mine'), isNotEmpty);
    for (final id in <String>[
      'other',
      'completed',
      'verified',
      'skipped',
      'away',
    ]) {
      expect(result.where((n) => n.refId == id), isEmpty, reason: id);
    }
  });

  test('projected occurrences in the past are ignored', () {
    final result = plan(
      input(
        items: <PlannableChore>[
          chore(
            'projected',
            dueAt: now.subtract(const Duration(minutes: 1)),
            isProjected: true,
          ),
        ],
      ),
    );
    expect(result.where((n) => n.refId == 'projected'), isEmpty);
  });

  test('items beyond the selected planning window are ignored', () {
    final result = plan(
      input(
        windowDays: 2,
        items: <PlannableChore>[
          chore('inside', dueAt: now.add(const Duration(days: 1))),
          chore('outside', dueAt: now.add(const Duration(days: 3))),
        ],
      ),
    );

    expect(result.where((n) => n.refId == 'inside'), isNotEmpty);
    expect(result.where((n) => n.refId == 'outside'), isEmpty);
  });

  test('a chore without due minutes receives the 7 PM nudge, not at-due', () {
    final item = chore('untimed', dueMinutes: null);
    final result = plan(input(items: <PlannableChore>[item]));
    final reminders = result.where((n) => n.refId == item.id).toList();
    final nudge = reminders.singleWhere(
      (notification) => notification.kind == PlannedNotificationKind.nudge,
    );

    expect(nudge.scheduledAt, DateTime.utc(2026, 11, 2, 13));
    expect(
      reminders.where((n) => n.kind == PlannedNotificationKind.due),
      isEmpty,
    );
  });

  test('the evening nudge is omitted when at-due is switched off', () {
    final item = chore('untimed', dueMinutes: null);
    final result = plan(
      input(
        items: <PlannableChore>[item],
        settings: ReminderSettings(
          atDue: false,
          defaultOffsetsMinutes: const <int>[],
          quietEnabled: false,
        ),
      ),
    );

    expect(result.where((n) => n.refId == item.id), isEmpty);
  });

  test('morning summary counts open chores due that day once', () {
    final result = plan(
      input(
        at: localNow,
        items: <PlannableChore>[
          chore('one'),
          chore('two', dueAt: due.add(const Duration(hours: 1))),
          chore(
            'three',
            dueAt: due.add(const Duration(hours: 2)),
            status: PlannableChoreStatus.inProgress,
          ),
          chore(
            'done',
            status: PlannableChoreStatus.completed,
            dueAt: due.add(const Duration(hours: 3)),
          ),
        ],
      ),
    );
    final summaries = result
        .where(
          (notification) =>
              notification.kind == PlannedNotificationKind.summary,
        )
        .toList();

    expect(summaries, hasLength(1));
    expect(summaries.single.scheduledAt, DateTime.utc(2026, 11, 2, 1));
    expect(summaries.single.body, 'summary:3');
    expect(summaries.single.payload, '/chores/today');
    expect(summaries.single.channelId, NotificationChannelId.dailySummary);
  });

  test('morning summary is omitted when no eligible chore is due', () {
    final result = plan(input(at: localNow));
    expect(
      result.where((n) => n.kind == PlannedNotificationKind.summary),
      isEmpty,
    );
  });

  test('quiet hours move wrap-around notifications to their end', () {
    final item = chore('quiet', dueAt: DateTime.utc(2026, 11, 2, 0, 30));
    final result = plan(
      input(
        at: DateTime.utc(2026, 11, 1, 18),
        items: <PlannableChore>[item],
        settings: ReminderSettings(
          quietEnabled: true,
          quietStartMinutes: 1320,
          quietEndMinutes: 420,
        ),
      ),
    );

    expect(
      result.where((n) => n.refId == item.id).map((n) => n.scheduledAt),
      everyElement(DateTime.utc(2026, 11, 2, 1)),
    );
  });

  test('quiet-hours movement beyond due plus six hours drops stale chores', () {
    final item = chore('stale', dueAt: DateTime.utc(2026, 11, 1, 18, 30));
    final result = plan(
      input(
        at: DateTime.utc(2026, 11, 1, 16),
        items: <PlannableChore>[item],
        settings: ReminderSettings(
          quietEnabled: true,
          quietStartMinutes: 1380,
          quietEndMinutes: 420,
        ),
      ),
    );

    expect(result.where((n) => n.refId == item.id), isEmpty);
  });

  test('past times within five seconds are dropped; the threshold is kept', () {
    final settings = ReminderSettings(
      atDue: true,
      defaultOffsetsMinutes: const <int>[],
      quietEnabled: false,
    );
    final template = <String, TemplateReminderConfig>{
      'template_edge': TemplateReminderConfig(
        enabled: true,
        atDue: true,
        overdueEnabled: false,
      ),
    };
    final before = plan(
      input(
        at: now,
        items: <PlannableChore>[
          chore('edge', dueAt: now.add(const Duration(seconds: 4))),
        ],
        settings: settings,
        templates: template,
      ),
    );
    final atThreshold = plan(
      input(
        at: now,
        items: <PlannableChore>[
          chore('edge', dueAt: now.add(const Duration(seconds: 5))),
        ],
        settings: settings,
        templates: template,
      ),
    );

    expect(before.where((n) => n.kind == PlannedNotificationKind.due), isEmpty);
    expect(
      atThreshold.where((n) => n.kind == PlannedNotificationKind.due),
      hasLength(1),
    );
  });

  test('effective Push delivery never creates a local notification', () {
    final result = plan(
      input(
        items: <PlannableChore>[chore('push')],
        effectiveModes: const <String, DeliveryMode>{
          'chore_due': DeliveryMode.push,
        },
      ),
    );

    expect(result.where((n) => n.refId == 'push'), isEmpty);
  });

  test('contribution reminders fire on the day before and the due day', () {
    final result = plan(
      input(
        items: const <PlannableChore>[],
        bazar: const BazarReminderInput(
          contributionDueDay: 5,
          unpaidThisMonth: true,
        ),
      ),
    );
    final contributions = result
        .where((n) => n.kind == PlannedNotificationKind.contributionDue)
        .toList();

    expect(contributions, hasLength(2));
    expect(contributions.map((n) => n.scheduledAt), <DateTime>[
      DateTime.utc(2026, 11, 4, 3),
      DateTime.utc(2026, 11, 5, 3),
    ]);
    expect(contributions.every((n) => n.payload == '/bazar/fund'), isTrue);
  });

  test('contribution reminders require an unpaid plan and bazar enabled', () {
    final paid = plan(
      input(
        bazar: const BazarReminderInput(
          contributionDueDay: 5,
          unpaidThisMonth: false,
        ),
      ),
    );
    final disabled = plan(
      input(
        settings: ReminderSettings(bazarEnabled: false, quietEnabled: false),
        bazar: const BazarReminderInput(
          contributionDueDay: 5,
          unpaidThisMonth: true,
        ),
      ),
    );

    expect(
      paid.where((n) => n.kind == PlannedNotificationKind.contributionDue),
      isEmpty,
    );
    expect(
      disabled.where((n) => n.kind == PlannedNotificationKind.contributionDue),
      isEmpty,
    );
  });

  test(
    'month-end reminder is limited to eligible closers and the given day',
    () {
      final end = DateKey(2026, 11, 8);
      final eligible = plan(
        input(bazar: BazarReminderInput(canCloseMonth: true, monthEndKey: end)),
      ).where((n) => n.kind == PlannedNotificationKind.monthEnd);
      final ineligible = plan(
        input(
          bazar: BazarReminderInput(canCloseMonth: false, monthEndKey: end),
        ),
      ).where((n) => n.kind == PlannedNotificationKind.monthEnd);

      expect(eligible, hasLength(1));
      expect(eligible.single.scheduledAt, DateTime.utc(2026, 11, 8, 12));
      expect(ineligible, isEmpty);
    },
  );

  test('items crossing Dhaka midnight use the family date for summaries', () {
    final crossingNow = DateTime.utc(2026, 11, 1, 17, 59);
    final crossingDue = DateTime.utc(2026, 11, 1, 18, 1);
    final result = plan(
      input(
        at: crossingNow,
        items: <PlannableChore>[chore('midnight', dueAt: crossingDue)],
      ),
    );
    final summary = result.singleWhere(
      (n) => n.kind == PlannedNotificationKind.summary,
    );

    expect(summary.refId, '2026-11-02');
    expect(summary.scheduledAt, DateTime.utc(2026, 11, 2, 1));
  });

  test('plan output is stable, sorted, and idempotent', () {
    final value = input(items: <PlannableChore>[chore('two'), chore('one')]);
    final first = plan(value);
    final second = plan(value);

    expect(first, second);
    expect(first.map((n) => n.id).toSet(), hasLength(first.length));
    expect(
      first.map((n) => n.scheduledAt).toList(),
      orderedEquals(first.map((n) => n.scheduledAt).toList()..sort()),
    );
  });

  test('candidate plans are capped at 60 nearest notifications', () {
    final items = <PlannableChore>[
      for (var i = 0; i < 70; i++)
        chore('many_$i', dueAt: due.add(Duration(minutes: i))),
    ];
    final result = plan(input(items: items));

    expect(result, hasLength(kMaxPlannedNotifications));
    expect(
      result.map((n) => n.scheduledAt).toList(),
      orderedEquals(result.map((n) => n.scheduledAt).toList()..sort()),
    );
    expect(result.map((n) => n.id).toSet(), hasLength(result.length));
  });
}

final class _FakeReminderTexts implements ReminderTexts {
  @override
  String formatTime(DateTime instant, String familyTimezone) =>
      instant.toIso8601String();

  @override
  String choreName(String nameBn, String? nameEn) => nameEn ?? nameBn;

  @override
  String dueTitle(String choreName) => 'due:$choreName';

  @override
  String dueBody(String choreName, String time) => 'due:$choreName:$time';

  @override
  String beforeTitle(String choreName) => 'before:$choreName';

  @override
  String beforeBody(String choreName, int offsetMinutes, String time) =>
      'before:$choreName:$offsetMinutes:$time';

  @override
  String overdueTitle(String choreName) => 'overdue:$choreName';

  @override
  String overdueBody(String choreName) => 'overdue:$choreName';

  @override
  String nudgeTitle() => 'nudge';

  @override
  String nudgeBody(int remainingCount) => 'nudge:$remainingCount';

  @override
  String summaryTitle() => 'summary';

  @override
  String summaryBody(int choreCount) => 'summary:$choreCount';

  @override
  String contributionDueTitle() => 'contribution';

  @override
  String contributionDueBody() => 'contribution';

  @override
  String monthEndTitle() => 'month end';

  @override
  String monthEndBody() => 'month end';
}
