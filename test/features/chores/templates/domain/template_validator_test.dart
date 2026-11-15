import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/chores/templates/domain/template_validator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// P3-07: the validation table (road map 3.6 codes).
void main() {
  DateKey d(String iso) => DateKey.parse(iso).valueOrNull!;

  String? codeOf(TemplateDraft draft) =>
      TemplateValidator.validate(draft)?.code;

  Validation? validationOf(TemplateDraft draft) =>
      TemplateValidator.validate(draft);

  RotationVersion version({
    String from = '2026-10-01',
    List<String> members = const ['alice', 'bob'],
    int anchorIndex = 0,
    int weekStartDay = 6,
  }) => RotationVersion(
    from: d(from),
    members: members,
    anchorDate: d(from),
    anchorIndex: anchorIndex,
    cycleUnit: CycleUnit.week,
    weekStartDay: weekStartDay,
  );

  test('a plain valid draft has no problem', () {
    expect(TemplateValidator.validate(aTemplate()), isNull);
  });

  group('name', () {
    test('is required', () {
      expect(codeOf(aTemplate(nameBn: '   ')), 'required');
      expect(validationOf(aTemplate(nameBn: ''))?.field, 'nameBn');
    });

    test('is at most 80 characters', () {
      expect(codeOf(aTemplate(nameBn: 'ক' * 80)), isNull);
      expect(codeOf(aTemplate(nameBn: 'ক' * 81)), 'too_long');
    });

    test('the English name is optional but capped too', () {
      expect(codeOf(aTemplate(nameEn: null)), isNull);
      expect(codeOf(aTemplate(nameEn: 'x' * 81)), 'too_long');
    });
  });

  group('schedule', () {
    test('an end before the start is invalid_range', () {
      expect(
        codeOf(aTemplate(startDate: d('2026-11-01'), endDate: d('2026-10-01'))),
        'invalid_range',
      );
      expect(
        codeOf(aTemplate(startDate: d('2026-11-01'), endDate: d('2026-11-01'))),
        isNull,
        reason: 'a single day is a valid span',
      );
    });

    test('the recurrence is validated with the span', () {
      expect(
        codeOf(
          aTemplate(
            recurrence: OnceRecurrence(d('2026-09-01')),
            startDate: d('2026-10-01'),
          ),
        ),
        'no_dates',
      );
      expect(
        codeOf(aTemplate(recurrence: const WeekdaysRecurrence(weekdays: []))),
        'no_dates',
      );
    });
  });

  group('slots', () {
    test('at least one slot', () {
      expect(codeOf(aTemplate(slots: const <TemplateSlot>[])), 'no_dates');
    });

    test('at most six', () {
      final six = <TemplateSlot>[
        aSlot(),
        for (var i = 0; i < 5; i++) aSlot(key: 's$i', labelBn: 'বার $i'),
      ];
      expect(codeOf(aTemplate(slots: six)), isNull);
      expect(
        codeOf(
          aTemplate(
            slots: <TemplateSlot>[
              ...six,
              aSlot(key: 's5', labelBn: 'ষষ্ঠ'),
            ],
          ),
        ),
        'too_many_slots',
      );
    });

    test('the first slot must be main', () {
      expect(
        codeOf(aTemplate(slots: <TemplateSlot>[aSlot(key: 'noon')])),
        'invalid_recurrence',
      );
      expect(
        codeOf(
          aTemplate(
            slots: <TemplateSlot>[
              aSlot(key: 'main'),
              aSlot(key: 'noon'),
            ],
          ),
        ),
        'slot_name_required',
        reason: 'a second slot also needs a label',
      );
    });

    test('slot keys are lowercase alphanumeric, 1..12 characters', () {
      expect(
        codeOf(
          aTemplate(
            slots: <TemplateSlot>[
              aSlot(),
              aSlot(key: 'Noon', labelBn: 'দুপুর'),
            ],
          ),
        ),
        'invalid_recurrence',
      );
      expect(
        codeOf(
          aTemplate(
            slots: <TemplateSlot>[
              aSlot(),
              aSlot(key: 'abcdefghijklm', labelBn: 'দুপুর'),
            ],
          ),
        ),
        'invalid_recurrence',
      );
    });

    test('duplicate slot keys are rejected', () {
      expect(
        codeOf(
          aTemplate(
            slots: <TemplateSlot>[
              aSlot(),
              aSlot(key: 'main', labelBn: 'দুপুর'),
            ],
          ),
        ),
        'duplicate_slot',
      );
    });

    test('a due time must be a real time of day', () {
      expect(
        codeOf(aTemplate(slots: <TemplateSlot>[aSlot(dueMinutes: 1440)])),
        'invalid_time',
      );
      expect(
        codeOf(aTemplate(slots: <TemplateSlot>[aSlot(dueMinutes: null)])),
        isNull,
        reason: 'no time means end of day',
      );
    });

    test('a second slot needs a Bangla label', () {
      expect(
        codeOf(
          aTemplate(
            slots: <TemplateSlot>[
              aSlot(),
              aSlot(key: 'noon', labelBn: 'দুপুর'),
            ],
          ),
        ),
        isNull,
      );
    });
  });

  group('subtasks', () {
    test('at most 30', () {
      final thirty = <TemplateSubtask>[
        for (var i = 0; i < 30; i++) aSubtask(id: 's$i'),
      ];
      expect(codeOf(aTemplate(subtasks: thirty)), isNull);
      expect(
        codeOf(
          aTemplate(
            subtasks: <TemplateSubtask>[
              ...thirty,
              aSubtask(id: 's30'),
            ],
          ),
        ),
        'too_many_subtasks',
      );
    });

    test('ids are unique and well formed', () {
      expect(
        codeOf(
          aTemplate(
            subtasks: <TemplateSubtask>[
              aSubtask(id: 'a'),
              aSubtask(id: 'a'),
            ],
          ),
        ),
        'duplicate_id',
      );
      expect(
        codeOf(aTemplate(subtasks: <TemplateSubtask>[aSubtask(id: 'BAD')])),
        'invalid_recurrence',
      );
    });

    test('a title is required and at most 120 characters', () {
      expect(
        codeOf(aTemplate(subtasks: <TemplateSubtask>[aSubtask(title: ' ')])),
        'required',
      );
      expect(
        codeOf(
          aTemplate(subtasks: <TemplateSubtask>[aSubtask(title: 'ক' * 121)]),
        ),
        'too_long',
      );
    });

    test('a hint is at most 200 characters', () {
      expect(
        codeOf(
          aTemplate(subtasks: <TemplateSubtask>[aSubtask(hint: 'x' * 201)]),
        ),
        'too_long',
      );
    });
  });

  group('assignee', () {
    test('manual needs nothing', () {
      expect(codeOf(aTemplate()), isNull);
    });

    test('fixed needs a member', () {
      expect(
        codeOf(
          aTemplate(
            assignee: const AssigneeSpec(strategy: AssigneeStrategy.fixed),
          ),
        ),
        'member_required',
      );
      expect(
        codeOf(
          aTemplate(
            assignee: const AssigneeSpec(
              strategy: AssigneeStrategy.fixed,
              fixedMemberId: 'cara',
            ),
          ),
        ),
        isNull,
      );
    });

    test('rotation needs a duty group or its own rotation', () {
      expect(
        codeOf(
          aTemplate(
            assignee: const AssigneeSpec(strategy: AssigneeStrategy.rotation),
          ),
        ),
        'invalid_rotation',
      );
      expect(
        codeOf(
          aTemplate(
            assignee: const AssigneeSpec(
              strategy: AssigneeStrategy.rotation,
              dutyGroupId: 'kitchen_duty',
            ),
          ),
        ),
        isNull,
      );
    });

    test('a duty-group id must be a catalog id', () {
      expect(
        codeOf(
          aTemplate(
            assignee: const AssigneeSpec(
              strategy: AssigneeStrategy.rotation,
              dutyGroupId: 'NOT VALID',
            ),
          ),
        ),
        'invalid_rotation',
      );
    });

    test('an own rotation needs at least two members', () {
      expect(
        codeOf(
          aTemplate(
            assignee: AssigneeSpec(
              strategy: AssigneeStrategy.rotation,
              rotation: Rotation(
                versions: <RotationVersion>[
                  version(members: const ['alice']),
                ],
              ),
            ),
          ),
        ),
        'too_few_members',
      );
      expect(
        codeOf(
          aTemplate(
            assignee: AssigneeSpec(
              strategy: AssigneeStrategy.rotation,
              rotation: Rotation(versions: <RotationVersion>[version()]),
            ),
          ),
        ),
        isNull,
      );
    });

    test('at most twelve members and twenty versions', () {
      final many = <String>[for (var i = 0; i < 13; i++) 'm$i'];
      expect(
        codeOf(
          aTemplate(
            assignee: AssigneeSpec(
              strategy: AssigneeStrategy.rotation,
              rotation: Rotation(
                versions: <RotationVersion>[version(members: many)],
              ),
            ),
          ),
        ),
        'too_many_items',
      );

      final twenty = <RotationVersion>[
        for (var i = 0; i < 20; i++)
          version(
            from:
                '${2026 + i ~/ 12}-${(i % 12 + 1).toString().padLeft(2, '0')}-01',
          ),
      ];
      expect(
        codeOf(
          aTemplate(
            assignee: AssigneeSpec(
              strategy: AssigneeStrategy.rotation,
              rotation: Rotation(versions: twenty),
            ),
          ),
        ),
        isNull,
      );
      expect(
        codeOf(
          aTemplate(
            assignee: AssigneeSpec(
              strategy: AssigneeStrategy.rotation,
              rotation: Rotation(
                versions: <RotationVersion>[
                  ...twenty,
                  version(from: '2027-01-01'),
                ],
              ),
            ),
          ),
        ),
        'too_many_items',
      );
    });

    test('versions must strictly increase by date', () {
      expect(
        codeOf(
          aTemplate(
            assignee: AssigneeSpec(
              strategy: AssigneeStrategy.rotation,
              rotation: Rotation(
                versions: <RotationVersion>[
                  version(from: '2026-10-10'),
                  version(from: '2026-10-01'),
                ],
              ),
            ),
          ),
        ),
        'invalid_rotation',
      );
    });

    test('an anchor index must point at a member', () {
      expect(
        codeOf(
          aTemplate(
            assignee: AssigneeSpec(
              strategy: AssigneeStrategy.rotation,
              rotation: Rotation(
                versions: <RotationVersion>[version(anchorIndex: 2)],
              ),
            ),
          ),
        ),
        'invalid_rotation',
      );
    });

    test('a week start outside 1..7 is rejected', () {
      expect(
        codeOf(
          aTemplate(
            assignee: AssigneeSpec(
              strategy: AssigneeStrategy.rotation,
              rotation: Rotation(
                versions: <RotationVersion>[version(weekStartDay: 0)],
              ),
            ),
          ),
        ),
        'invalid_week_start',
      );
    });

    test('duplicate members in one version are rejected', () {
      expect(
        codeOf(
          aTemplate(
            assignee: AssigneeSpec(
              strategy: AssigneeStrategy.rotation,
              rotation: Rotation(
                versions: <RotationVersion>[
                  version(members: const ['alice', 'alice']),
                ],
              ),
            ),
          ),
        ),
        'invalid_rotation',
      );
    });
  });

  group('text and time fields', () {
    test('instructions are capped at 4000 characters', () {
      expect(codeOf(aTemplate(instructions: 'x' * 4000)), isNull);
      expect(codeOf(aTemplate(instructions: 'x' * 4001)), 'too_long');
    });

    test('estimated minutes are 1..600', () {
      expect(codeOf(aTemplate(estimatedMinutes: 0)), 'invalid_minutes');
      expect(codeOf(aTemplate(estimatedMinutes: 601)), 'invalid_minutes');
      expect(codeOf(aTemplate(estimatedMinutes: 45)), isNull);
    });

    test('the icon key and the colour are bounded', () {
      expect(codeOf(aTemplate(iconKey: 'x' * 25)), 'too_long');
      expect(codeOf(aTemplate(colorIndex: 24)), 'invalid_range');
      expect(codeOf(aTemplate(colorIndex: 23)), isNull);
    });

    test('reminders are stored within their limits', () {
      expect(
        codeOf(
          aTemplate(
            reminders: const ReminderConfig(
              offsetsMinutes: [10, 20, 30, 40, 50],
            ),
          ),
        ),
        isNull,
      );
      expect(
        codeOf(
          aTemplate(
            reminders: const ReminderConfig(
              offsetsMinutes: [10, 20, 30, 40, 50, 60],
            ),
          ),
        ),
        'too_many_items',
      );
      expect(
        codeOf(aTemplate(reminders: const ReminderConfig(offsetsMinutes: [0]))),
        'invalid_minutes',
      );
      expect(
        codeOf(
          aTemplate(reminders: const ReminderConfig(overdueAfterMinutes: 0)),
        ),
        'invalid_minutes',
      );
    });
  });
}
