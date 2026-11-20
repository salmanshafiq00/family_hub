import 'package:family_hub/core/firebase/base_mapper.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/features/chores/settings/data/chore_settings_mappers.dart';
import 'package:family_hub/features/chores/settings/domain/chore_catalog_entries.dart';
import 'package:family_hub/features/chores/settings/domain/chore_catalogs.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings_repository.dart';
import 'package:family_hub/features/chores/settings/domain/default_chore_settings.dart';
import 'package:flutter_test/flutter_test.dart';

/// P3-06: the map round-trips, the tolerant read, the absence-policy map and
/// the catalog lookups (the fallbacks every later screen relies on).
void main() {
  final meta = BaseMapper.createMetadata(
    uid: 'alice',
    clock: FakeClock(DateTime.utc(2026, 10, 24, 9)),
  );

  group('settings/chores map', () {
    test('round-trips the defaults unchanged', () {
      final map = ChoreSettingsMappers.toMap(ChoreSettings.defaults, meta);
      expect(ChoreSettingsMappers.fromMap(map), ChoreSettings.defaults);
    });

    test('round-trips a heavily edited object', () {
      final edited = ChoreSettings.defaults.copyWith(
        weekStartDay: 1,
        defaultCalendarView: CalendarViewKind.week,
        defaultScope: CalendarScopeKind.all,
        generationHorizonDays: 60,
        showProjected: false,
        projectedMonthsAhead: 6,
        overdueGraceMinutes: 30,
        swapsEnabled: false,
        swapExpiryBufferMinutes: 240,
        absenceNeedsApproval: true,
        workloadVisibleToMembers: true,
        houseRules: '# ঘরের নিয়ম\n- **সবাই** মেনে চলবে',
        groups: <ChoreGroup>[
          ...ChoreSettings.defaults.groups,
          const ChoreGroup(
            id: 'custom_1',
            nameBn: 'ছাদ',
            nameEn: 'Roof',
            colorIndex: 9,
            iconKey: 'roof',
            sortOrder: 7,
          ),
        ],
        dueTimePresets: <DueTimePreset>[
          ...defaultDueTimePresets,
          const DueTimePreset(id: 'custom_1', labelBn: 'ভোর ৫টা', minutes: 300),
        ],
        absenceReasons: <AbsenceReason>[
          ...defaultAbsenceReasons,
          const AbsenceReason(id: 'custom_1', labelBn: 'অতিথি'),
        ],
      );
      final map = ChoreSettingsMappers.toMap(edited, meta);
      expect(ChoreSettingsMappers.fromMap(map), edited);
    });

    test('an absent document means the defaults', () {
      expect(ChoreSettingsMappers.fromMap(null), ChoreSettings.defaults);
      expect(
        ChoreSettingsMappers.fromMap(<String, dynamic>{}),
        isNot(same(null)),
      );
    });

    test('an unknown calendar view falls back to agenda', () {
      final s = ChoreSettingsMappers.fromMap(<String, dynamic>{
        'defaultCalendarView': 'year',
        'defaultScope': 'everyone',
      });
      expect(s.defaultCalendarView, CalendarViewKind.agenda);
      expect(s.defaultScope, CalendarScopeKind.mine);
    });

    test('each scalar falls back on its own', () {
      final s = ChoreSettingsMappers.fromMap(<String, dynamic>{
        'weekStartDay': 9,
        'generationHorizonDays': 500,
        'projectedMonthsAhead': 'many',
        'overdueGraceMinutes': -5,
        'swapExpiryBufferMinutes': 99999,
        'showProjected': 'yes',
      });
      expect(s.weekStartDay, 6);
      expect(s.generationHorizonDays, 30);
      expect(s.projectedMonthsAhead, 3);
      expect(s.overdueGraceMinutes, 0);
      expect(s.swapExpiryBufferMinutes, 120);
      expect(s.showProjected, isTrue);
    });

    test('a missing list falls back to the built-in catalog', () {
      final s = ChoreSettingsMappers.fromMap(<String, dynamic>{
        'weekStartDay': 7,
      });
      expect(s.groups, defaultGroups);
      expect(s.dueTimePresets, defaultDueTimePresets);
      expect(s.absenceReasons, defaultAbsenceReasons);
    });

    test('a malformed row is skipped, the rest is kept', () {
      final s = ChoreSettingsMappers.fromMap(<String, dynamic>{
        'groups': <Object?>[
          <String, Object?>{'id': 'kitchen', 'nameBn': 'রান্নাঘর'},
          'not a row',
          <String, Object?>{'id': 'BAD ID', 'nameBn': 'x'},
          <String, Object?>{'id': 'custom_1', 'nameBn': 'ছাদ'},
          <String, Object?>{'id': 'custom_1', 'nameBn': 'duplicate'},
        ],
      });
      expect(s.groups.map((g) => g.id), ['kitchen', 'custom_1']);
    });

    test('an empty list falls back to the built-in catalog', () {
      final s = ChoreSettingsMappers.fromMap(<String, dynamic>{
        'absenceReasons': <Object?>[],
      });
      expect(s.absenceReasons, defaultAbsenceReasons);
    });

    test('an out-of-range colour is clamped to the palette', () {
      final s = ChoreSettingsMappers.fromMap(<String, dynamic>{
        'groups': <Object?>[
          <String, Object?>{'id': 'a', 'nameBn': 'ক', 'colorIndex': 99},
        ],
      });
      expect(s.groups.single.colorIndex, 0);
    });

    test('an over-long house rules string is cut to the limit', () {
      final s = ChoreSettingsMappers.fromMap(<String, dynamic>{
        'houseRules': 'x' * 2500,
      });
      expect(s.houseRules.length, ChoreSettingsLimits.maxHouseRulesLength);
    });
  });

  group('settings/rotationPolicy map', () {
    test('round-trips every policy', () {
      for (final policy in AbsencePolicy.values) {
        final map = ChoreSettingsMappers.absencePolicyToMap(policy, meta);
        expect(
          ChoreSettingsMappers.absencePolicyFromMap(map),
          policy,
          reason: policy.id,
        );
      }
    });

    test('an absent or unknown value means auto_assign', () {
      expect(
        ChoreSettingsMappers.absencePolicyFromMap(null),
        AbsencePolicy.autoAssign,
      );
      expect(
        ChoreSettingsMappers.absencePolicyFromMap(<String, dynamic>{
          'absencePolicy': 'whatever',
        }),
        AbsencePolicy.autoAssign,
      );
    });
  });

  group('ChoreCatalogs', () {
    final catalogs = ChoreCatalogs.of(ChoreSettings.defaults);

    test('groupOf falls back to "other", then to the first group', () {
      expect(catalogs.groupOf('kitchen').nameBn, 'রান্নাঘর');
      expect(catalogs.groupOf('does_not_exist').id, 'other');
      expect(catalogs.groupOf(null).id, 'other');

      final withoutOther = ChoreCatalogs.of(
        ChoreSettings.defaults.copyWith(
          groups: <ChoreGroup>[
            for (final g in defaultGroups)
              if (g.id != 'other') g,
          ],
        ),
      );
      expect(withoutOther.groupOf('nope').id, 'kitchen');
    });

    test('an empty catalog still yields a usable group', () {
      final empty = ChoreCatalogs.of(
        ChoreSettings.defaults.copyWith(groups: const <ChoreGroup>[]),
      );
      expect(empty.groupOf('anything').id, 'other');
    });

    test('groups are sorted by sortOrder', () {
      final shuffled = ChoreCatalogs.of(
        ChoreSettings.defaults.copyWith(
          groups: <ChoreGroup>[...defaultGroups.reversed],
        ),
      );
      expect(shuffled.groups.map((g) => g.id).take(3), [
        'kitchen',
        'cooking',
        'cleaning',
      ]);
    });

    test('active-only getters drop the deactivated rows', () {
      final mixed = ChoreCatalogs.of(
        ChoreSettings.defaults.copyWith(
          groups: <ChoreGroup>[
            for (final g in defaultGroups)
              if (g.id == 'fridge') g.copyWith(active: false) else g,
          ],
        ),
      );
      expect(mixed.groups, hasLength(7));
      expect(mixed.activeGroups, hasLength(6));
      expect(mixed.activeGroups.map((g) => g.id), isNot(contains('fridge')));
    });

    test('presets are sorted by clock time, not list position', () {
      expect(catalogs.presets.map((p) => p.minutes), [
        540,
        840,
        1140,
        1200,
        1320,
      ]);
      expect(catalogs.presetOf('evening')?.minutes, 1140);
      expect(catalogs.presetOf('nope'), isNull);
      expect(catalogs.presetOf(null), isNull);
    });

    test('reasons keep the family order and look up by id', () {
      expect(catalogs.absenceReasons.first.id, 'sick');
      expect(catalogs.reasonOf('travel')?.labelBn, 'ভ্রমণ');
      expect(catalogs.reasonOf('unknown'), isNull);
    });

    test('active-only preset and reason lists', () {
      final off = ChoreCatalogs.of(
        ChoreSettings.defaults.copyWith(
          dueTimePresets: <DueTimePreset>[
            for (final p in defaultDueTimePresets)
              p.id == 'noon' ? p.copyWith(active: false) : p,
          ],
          absenceReasons: <AbsenceReason>[
            for (final r in defaultAbsenceReasons)
              r.id == 'sick' ? r.copyWith(active: false) : r,
          ],
        ),
      );
      expect(off.activePresets.map((p) => p.id), isNot(contains('noon')));
      expect(
        off.activeAbsenceReasons.map((r) => r.id),
        isNot(contains('sick')),
      );
    });
  });
}
