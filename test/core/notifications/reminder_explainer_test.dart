import 'package:family_hub/core/notifications/domain/reminder_explainer.dart';
import 'package:family_hub/core/notifications/domain/reminder_planner.dart';
import 'package:family_hub/core/notifications/domain/reminder_precedence.dart';
import 'package:family_hub/core/notifications/domain/reminder_settings.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final texts = _FakeReminderTexts();
  final now = DateTime.utc(2026, 11, 2, 0);
  final dueAt = DateTime.utc(2026, 11, 2, 6);

  PlannableChore chore({
    String? assigneeId = 'me',
    PlannableChoreStatus status = PlannableChoreStatus.scheduled,
    bool isUnavailable = false,
    bool isProjected = false,
  }) => PlannableChore(
    id: 'item',
    templateId: 'template',
    dueAt: dueAt,
    dueMinutes: 360,
    status: status,
    assigneeId: assigneeId,
    nameBn: 'কাজ',
    isUnavailable: isUnavailable,
    isProjected: isProjected,
  );

  ReminderExplanation explain({
    PlannableChore? item,
    ReminderSettings? settings,
    Map<String, TemplateReminderConfig> templates =
        const <String, TemplateReminderConfig>{},
    Map<String, DeliveryMode> effectiveModes = const <String, DeliveryMode>{},
  }) => ReminderExplainer.explain(
    item: item ?? chore(),
    settings: settings ?? ReminderSettings(quietEnabled: false),
    now: now,
    familyTz: 'Asia/Dhaka',
    texts: texts,
    viewerId: 'me',
    templateIndex: templates,
    effectiveModes: effectiveModes,
  );

  test('uses the planner to report the next local reminder', () {
    final result = explain();

    expect(result.willFire, isTrue);
    expect(result.nextAt, dueAt.subtract(const Duration(minutes: 30)));
    expect(result.reasons, isEmpty);
  });

  test('returns the exact precedence reason when reminders are disabled', () {
    final cases = <(ReminderSettings, ReminderExplanationReason)>[
      (
        ReminderSettings(globalEnabled: false),
        ReminderExplanationReason.globalOff,
      ),
      (
        ReminderSettings(choresEnabled: false),
        ReminderExplanationReason.categoryOff,
      ),
    ];

    for (final (settings, reason) in cases) {
      final result = explain(settings: settings);
      expect(result.willFire, isFalse);
      expect(result.nextAt, isNull);
      expect(result.reasons, <ReminderExplanationReason>[reason]);
    }
  });

  test('reports template off and no-timings reasons', () {
    final off = explain(
      templates: <String, TemplateReminderConfig>{
        'template': TemplateReminderConfig(enabled: false),
      },
    );
    final noTimings = explain(
      templates: <String, TemplateReminderConfig>{
        'template': TemplateReminderConfig(
          enabled: true,
          atDue: false,
          overdueEnabled: false,
        ),
      },
    );

    expect(off.reasons, <ReminderExplanationReason>[
      ReminderExplanationReason.templateOff,
    ]);
    expect(noTimings.reasons, <ReminderExplanationReason>[
      ReminderExplanationReason.templateNoTimings,
    ]);
  });

  test(
    'explains assignment, status, availability and projected-past filters',
    () {
      final cases = <(PlannableChore, ReminderExplanationReason)>[
        (
          chore(assigneeId: 'someone_else'),
          ReminderExplanationReason.notAssigned,
        ),
        (
          chore(status: PlannableChoreStatus.completed),
          ReminderExplanationReason.notOpen,
        ),
        (chore(isUnavailable: true), ReminderExplanationReason.unavailable),
        (
          chore(isProjected: true)
              .copyWithDueAt(now.subtract(const Duration(minutes: 1))),
          ReminderExplanationReason.projectedPast,
        ),
      ];

      for (final (item, reason) in cases) {
        final result = explain(item: item);
        expect(result.willFire, isFalse);
        expect(result.reasons, <ReminderExplanationReason>[reason]);
      }
    },
  );

  test('reports push delivery rather than a local reminder', () {
    final result = explain(
      effectiveModes: const <String, DeliveryMode>{
        'chore_due': DeliveryMode.push,
      },
    );

    expect(result.willFire, isTrue);
    expect(result.nextAt, isNull);
    expect(result.reasons, <ReminderExplanationReason>[
      ReminderExplanationReason.deliveredAsPush,
    ]);
  });

  test(
    'reports no upcoming reminder when all configured times have passed',
    () {
      final result = explain(
        settings: ReminderSettings(
          defaultOffsetsMinutes: const <int>[],
          atDue: false,
          overdueEnabled: false,
          quietEnabled: false,
        ),
      );

      expect(result.willFire, isFalse);
      expect(result.nextAt, isNull);
      expect(result.reasons, <ReminderExplanationReason>[
        ReminderExplanationReason.templateNoTimings,
      ]);
    },
  );
}

final class _FakeReminderTexts implements ReminderTexts {
  @override
  String formatTime(DateTime instant, String familyTimezone) => 'time';

  @override
  String choreName(String nameBn, String? nameEn) => nameEn ?? nameBn;

  @override
  String dueTitle(String choreName) => 'due';

  @override
  String dueBody(String choreName, String time) => 'due';

  @override
  String beforeTitle(String choreName) => 'before';

  @override
  String beforeBody(String choreName, int offsetMinutes, String time) =>
      'before';

  @override
  String overdueTitle(String choreName) => 'overdue';

  @override
  String overdueBody(String choreName) => 'overdue';

  @override
  String nudgeTitle() => 'nudge';

  @override
  String nudgeBody(int remainingCount) => 'nudge';

  @override
  String summaryTitle() => 'summary';

  @override
  String summaryBody(int choreCount) => 'summary';

  @override
  String contributionDueTitle() => 'contribution';

  @override
  String contributionDueBody() => 'contribution';

  @override
  String monthEndTitle() => 'month-end';

  @override
  String monthEndBody() => 'month-end';
}

extension on PlannableChore {
  PlannableChore copyWithDueAt(DateTime value) => PlannableChore(
    id: id,
    templateId: templateId,
    dueAt: value,
    status: status,
    assigneeId: assigneeId,
    nameBn: nameBn,
    nameEn: nameEn,
    dueMinutes: dueMinutes,
    categoryHint: categoryHint,
    isProjected: isProjected,
    isUnavailable: isUnavailable,
  );
}
