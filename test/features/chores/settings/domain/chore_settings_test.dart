import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/audit/audit_ref_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/features/chores/settings/domain/chore_catalog_entries.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_validator.dart';
import 'package:family_hub/features/chores/settings/domain/default_chore_settings.dart';
import 'package:family_hub/features/chores/settings/domain/usecases/update_chore_settings.dart';
import 'package:family_hub/features/chores/settings/domain/usecases/update_rotation_policy.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';

/// P3-06: the validation table, the permission matrix and the audit entry of
/// the two settings use cases.
void main() {
  late ChoresFixture fixture;
  late UpdateChoreSettings updateSettings;
  late UpdateRotationPolicy updatePolicy;

  setUp(() {
    fixture = ChoresFixture();
    updateSettings = UpdateChoreSettings(
      settings: fixture.settings,
      families: fixture.families,
      clock: fixture.clock,
      newId: fixture.ids.call,
    );
    updatePolicy = UpdateRotationPolicy(
      settings: fixture.settings,
      families: fixture.families,
      clock: fixture.clock,
      newId: fixture.ids.call,
    );
  });

  String? codeOf(ChoreSettings s) => ChoreSettingsValidator.validate(s)?.code;

  group('defaults (Appendix A.3)', () {
    test('are the documented scalars', () {
      const d = ChoreSettings.defaults;
      expect(d.weekStartDay, DateTime.saturday);
      expect(d.defaultCalendarView, CalendarViewKind.agenda);
      expect(d.defaultScope, CalendarScopeKind.mine);
      expect(d.generationHorizonDays, 30);
      expect(d.showProjected, isTrue);
      expect(d.projectedMonthsAhead, 3);
      expect(d.overdueGraceMinutes, 0);
      expect(d.swapsEnabled, isTrue);
      expect(d.swapExpiryBufferMinutes, 120);
      expect(d.absenceNeedsApproval, isFalse);
      expect(d.workloadVisibleToMembers, isFalse);
      expect(d.houseRules, isEmpty);
    });

    test('carry the seven groups, five presets and six reasons', () {
      expect(ChoreSettings.defaults.groups, hasLength(7));
      expect(ChoreSettings.defaults.dueTimePresets, hasLength(5));
      expect(ChoreSettings.defaults.absenceReasons, hasLength(6));
      expect(defaultGroups.every((g) => g.builtIn), isTrue);
      expect(
        defaultGroups.map((g) => g.id),
        containsAll(<String>[
          'kitchen',
          'cooking',
          'cleaning',
          'water',
          'fridge',
          'living',
          'other',
        ]),
      );
    });

    test('are themselves valid', () {
      expect(ChoreSettingsValidator.validate(ChoreSettings.defaults), isNull);
    });
  });

  group('validator', () {
    test('weekStartDay must be 1..7', () {
      for (final day in <int>[0, 8]) {
        expect(
          codeOf(ChoreSettings.defaults.copyWith(weekStartDay: day)),
          'invalid_week_start',
        );
      }
    });

    test('generationHorizonDays must be 14..90', () {
      for (final days in <int>[13, 91]) {
        expect(
          codeOf(ChoreSettings.defaults.copyWith(generationHorizonDays: days)),
          'invalid_horizon',
        );
      }
      expect(
        codeOf(ChoreSettings.defaults.copyWith(generationHorizonDays: 14)),
        isNull,
      );
      expect(
        codeOf(ChoreSettings.defaults.copyWith(generationHorizonDays: 90)),
        isNull,
      );
    });

    test('projected months, grace and swap buffer ranges', () {
      expect(
        codeOf(ChoreSettings.defaults.copyWith(projectedMonthsAhead: 13)),
        'invalid_range',
      );
      expect(
        codeOf(ChoreSettings.defaults.copyWith(overdueGraceMinutes: 241)),
        'invalid_range',
      );
      expect(
        codeOf(ChoreSettings.defaults.copyWith(swapExpiryBufferMinutes: 1441)),
        'invalid_range',
      );
    });

    test('house rules are capped at 2000 characters', () {
      expect(
        codeOf(ChoreSettings.defaults.copyWith(houseRules: 'x' * 2001)),
        'too_long',
      );
      expect(
        codeOf(ChoreSettings.defaults.copyWith(houseRules: 'x' * 2000)),
        isNull,
      );
    });

    test('list sizes are capped', () {
      final tooManyGroups = <ChoreGroup>[
        ...defaultGroups,
        for (var i = 0; i < 24; i++)
          ChoreGroup(id: 'custom_$i', nameBn: 'গ্রুপ $i'),
      ];
      expect(tooManyGroups, hasLength(31));
      expect(
        codeOf(ChoreSettings.defaults.copyWith(groups: tooManyGroups)),
        'too_many_items',
      );
    });

    test('ids must be unique inside a list', () {
      final duplicated = <ChoreGroup>[
        ...defaultGroups,
        const ChoreGroup(id: 'kitchen', nameBn: 'রান্নাঘর ২'),
      ];
      expect(
        codeOf(ChoreSettings.defaults.copyWith(groups: duplicated)),
        'duplicate_id',
      );
    });

    test('an id must be a machine id', () {
      final bad = <ChoreGroup>[
        ...defaultGroups,
        const ChoreGroup(id: 'Not Valid', nameBn: 'ক'),
      ];
      expect(
        codeOf(ChoreSettings.defaults.copyWith(groups: bad)),
        'invalid_recurrence',
      );
    });

    test('a built-in group may be renamed, deactivated or deleted', () {
      final renamed = <ChoreGroup>[
        for (final g in defaultGroups)
          if (g.id == 'kitchen')
            g.copyWith(nameBn: 'বড় রান্নাঘর', active: false)
          else
            g,
      ];
      expect(codeOf(ChoreSettings.defaults.copyWith(groups: renamed)), isNull);

      final removed = <ChoreGroup>[
        for (final g in defaultGroups)
          if (g.id != 'kitchen') g,
      ];
      expect(
        codeOf(ChoreSettings.defaults.copyWith(groups: removed)),
        isNull,
        reason: 'a chore falls back to the other group (ChoreCatalogs.groupOf)',
      );
    });

    test('a built-in preset or reason cannot be removed', () {
      final noMorning = <DueTimePreset>[
        for (final p in defaultDueTimePresets)
          if (p.id != 'morning') p,
      ];
      expect(
        codeOf(ChoreSettings.defaults.copyWith(dueTimePresets: noMorning)),
        'invalid_recurrence',
      );
      final noSick = <AbsenceReason>[
        for (final r in defaultAbsenceReasons)
          if (r.id != 'sick') r,
      ];
      expect(
        codeOf(ChoreSettings.defaults.copyWith(absenceReasons: noSick)),
        'invalid_recurrence',
      );
    });

    test('a seed id may not be turned into a custom row', () {
      final demoted = <ChoreGroup>[
        for (final g in defaultGroups)
          if (g.id == 'kitchen')
            ChoreGroup(id: g.id, nameBn: g.nameBn, builtIn: false)
          else
            g,
      ];
      expect(
        codeOf(ChoreSettings.defaults.copyWith(groups: demoted)),
        'invalid_recurrence',
      );
    });

    test('a built-in row must use a seed id', () {
      final invented = <ChoreGroup>[
        ...defaultGroups,
        const ChoreGroup(id: 'custom_1', nameBn: 'নতুন', builtIn: true),
      ];
      expect(
        codeOf(ChoreSettings.defaults.copyWith(groups: invented)),
        'invalid_recurrence',
      );
    });

    test('at least one active row in every list', () {
      final noneActive = <ChoreGroup>[
        for (final g in defaultGroups) g.copyWith(active: false),
      ];
      expect(
        codeOf(ChoreSettings.defaults.copyWith(groups: noneActive)),
        'no_dates',
      );
    });

    test('a group needs a name and a palette colour', () {
      final noName = <ChoreGroup>[
        ...defaultGroups,
        const ChoreGroup(id: 'custom_1', nameBn: '  '),
      ];
      expect(
        codeOf(ChoreSettings.defaults.copyWith(groups: noName)),
        'required',
      );
      final badColor = <ChoreGroup>[
        ...defaultGroups,
        const ChoreGroup(id: 'custom_1', nameBn: 'ক', colorIndex: 24),
      ];
      expect(
        codeOf(ChoreSettings.defaults.copyWith(groups: badColor)),
        'invalid_range',
      );
    });

    test('a due-time preset needs minutes in 0..1439', () {
      final bad = <DueTimePreset>[
        ...defaultDueTimePresets,
        const DueTimePreset(id: 'custom_1', labelBn: 'নতুন', minutes: 1440),
      ];
      expect(
        codeOf(ChoreSettings.defaults.copyWith(dueTimePresets: bad)),
        'invalid_minutes',
      );
    });

    test('an absence reason needs a name', () {
      final bad = <AbsenceReason>[
        ...defaultAbsenceReasons,
        const AbsenceReason(id: 'custom_1', labelBn: ''),
      ];
      expect(
        codeOf(ChoreSettings.defaults.copyWith(absenceReasons: bad)),
        'required',
      );
    });

    test('more than 8 presets or 12 reasons is too many', () {
      expect(
        codeOf(
          ChoreSettings.defaults.copyWith(
            dueTimePresets: <DueTimePreset>[
              ...defaultDueTimePresets,
              for (var i = 0; i < 4; i++)
                DueTimePreset(id: 'custom_$i', labelBn: 'সময় $i', minutes: i),
            ],
          ),
        ),
        'too_many_items',
      );
      expect(
        codeOf(
          ChoreSettings.defaults.copyWith(
            absenceReasons: <AbsenceReason>[
              ...defaultAbsenceReasons,
              for (var i = 0; i < 7; i++)
                AbsenceReason(id: 'custom_$i', labelBn: 'কারণ $i'),
            ],
          ),
        ),
        'too_many_items',
      );
    });
  });

  group('UpdateChoreSettings', () {
    test('a Household Manager saves and writes one audit entry', () async {
      final result = await updateSettings(
        actorUid: 'bob',
        familyId: ChoresFixture.familyId,
        settings: ChoreSettings.defaults.copyWith(generationHorizonDays: 45),
      );

      expect(result.isSuccess, isTrue);
      expect(fixture.settings.saves, 1);
      expect(fixture.settings.settings.generationHorizonDays, 45);
      final event = fixture.settings.events.single;
      expect(event.type, AuditEventType.choresSettingsUpdated);
      expect(event.refType, AuditRefType.choreSettings);
      expect(event.actorId, 'bob');
      expect(event.at, fixture.clock.nowUtc());
    });

    test('an admin saves', () async {
      final result = await updateSettings(
        actorUid: 'alice',
        familyId: ChoresFixture.familyId,
        settings: ChoreSettings.defaults,
      );
      expect(result.isSuccess, isTrue);
      expect(fixture.settings.saves, 1);
    });

    test('a plain member is denied and nothing is written', () async {
      final result = await updateSettings(
        actorUid: 'cara',
        familyId: ChoresFixture.familyId,
        settings: ChoreSettings.defaults,
      );
      expect(result.failureOrNull, const PermissionDenied());
      expect(fixture.settings.saves, 0);
      expect(fixture.settings.events, isEmpty);
    });

    test('a pending member is denied', () async {
      final result = await updateSettings(
        actorUid: 'erin',
        familyId: ChoresFixture.familyId,
        settings: ChoreSettings.defaults,
      );
      expect(result.failureOrNull, const PermissionDenied());
    });

    test('validation runs before the write', () async {
      final result = await updateSettings(
        actorUid: 'alice',
        familyId: ChoresFixture.familyId,
        settings: ChoreSettings.defaults.copyWith(generationHorizonDays: 5),
      );
      expect(
        result.failureOrNull,
        const Validation('generationHorizonDays', 'invalid_horizon'),
      );
      expect(fixture.settings.saves, 0);
    });

    test('permission is checked before validation', () async {
      final result = await updateSettings(
        actorUid: 'cara',
        familyId: ChoresFixture.familyId,
        settings: ChoreSettings.defaults.copyWith(weekStartDay: 99),
      );
      expect(result.failureOrNull, const PermissionDenied());
    });

    test('a repository failure is passed through', () async {
      fixture.settings.nextFailure = const Network();
      final result = await updateSettings(
        actorUid: 'alice',
        familyId: ChoresFixture.familyId,
        settings: ChoreSettings.defaults,
      );
      expect(result.failureOrNull, const Network());
    });
  });

  group('UpdateRotationPolicy', () {
    test('a manager changes the policy (closes C-3)', () async {
      final result = await updatePolicy(
        actorUid: 'bob',
        familyId: ChoresFixture.familyId,
        policy: AbsencePolicy.autoCover,
      );

      expect(result.isSuccess, isTrue);
      expect(fixture.settings.policy, AbsencePolicy.autoCover);
      expect(fixture.settings.policySaves, 1);
      final event = fixture.settings.events.single;
      expect(event.type, AuditEventType.choresRotationPolicyUpdated);
      expect(event.refType, AuditRefType.choreSettings);
      expect(event.params['policy'], 'auto_cover');
    });

    test('a plain member is denied', () async {
      final result = await updatePolicy(
        actorUid: 'cara',
        familyId: ChoresFixture.familyId,
        policy: AbsencePolicy.skip,
      );
      expect(result.failureOrNull, const PermissionDenied());
      expect(fixture.settings.policySaves, 0);
    });

    test('every policy has its stored id', () {
      expect(AbsencePolicy.values.map((p) => p.id).toList(), [
        'ask_cover',
        'auto_cover',
        'skip',
        'auto_assign',
      ]);
      expect(AbsencePolicy.fromId('skip'), AbsencePolicy.skip);
      expect(AbsencePolicy.fromId('nonsense'), AbsencePolicy.autoAssign);
      expect(AbsencePolicy.fromId(null), AbsencePolicy.autoAssign);
    });
  });
}
