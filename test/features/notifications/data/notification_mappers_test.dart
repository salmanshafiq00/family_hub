import 'package:family_hub/core/firebase/base_mapper.dart';
import 'package:family_hub/core/notifications/domain/notification_type.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/features/family/data/family_mappers.dart';
import 'package:family_hub/features/notifications/data/delivery_mappers.dart';
import 'package:family_hub/features/notifications/data/notification_defaults_mappers.dart';
import 'package:family_hub/features/notifications/domain/notification_defaults.dart';
import 'package:family_hub/features/notifications/domain/notification_delivery_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final metadata = BaseMapper.createMetadata(
    uid: 'user',
    clock: FakeClock(DateTime.utc(2026, 11, 6)),
  );

  test('family-seeded enabled-only defaults inherit field defaults', () {
    final seeded = FamilyMappers.notificationDefaultsMap(metadata);

    expect(seeded, containsPair('enabled', true));
    expect(
      NotificationDefaultsMappers.fromMap(seeded),
      NotificationDefaults.defaults,
    );
  });

  test('family defaults round-trip and fall back independently by field', () {
    final settings = NotificationDefaults(
      enabled: false,
      chores: false,
      defaultOffsetsMinutes: <int>[15, 45],
      morningSummaryMinutes: 480,
    );
    final encoded = NotificationDefaultsMappers.toMap(settings, metadata);
    expect(NotificationDefaultsMappers.fromMap(encoded), settings);

    final partial = NotificationDefaultsMappers.fromMap(<String, dynamic>{
      'enabled': false,
      'defaultOffsetsMinutes': <int>[0],
      'morningSummaryMinutes': 900,
    });
    expect(partial.enabled, isFalse);
    expect(partial.chores, isTrue);
    expect(partial.defaultOffsetsMinutes, <int>[30]);
    expect(partial.morningSummaryMinutes, 900);
  });

  test(
    'delivery settings round-trip and malformed values use safe defaults',
    () {
      final settings = NotificationDeliverySettings(
        pushEnabled: true,
        modes: const <String, DeliveryMode>{
          'swap_request': DeliveryMode.normal,
          'member_approved': DeliveryMode.push,
        },
        quietRespectedByPush: false,
      );
      final encoded = DeliveryMappers.toMap(settings, metadata);
      expect(DeliveryMappers.fromMap(encoded), settings);

      final malformed = DeliveryMappers.fromMap(<String, dynamic>{
        'pushEnabled': 'yes',
        'quietRespectedByPush': 1,
        'modes': <String, dynamic>{
          'unknown': 'push',
          'morning_summary': 'push',
          'swap_request': 'invalid',
        },
      });
      expect(malformed.pushEnabled, isFalse);
      expect(malformed.quietRespectedByPush, isTrue);
      expect(malformed.modes, NotificationDeliverySettings.defaults().modes);
    },
  );

  test('member preferences preserve unset fields for inheritance', () {
    final prefs = NotificationDefaultsMappers.memberPrefsFromMap(
      <String, dynamic>{
        'pushEnabled': false,
        'chores': false,
        'defaultOffsetsMinutes': <int>[15],
      },
    );
    final resolved = prefs.resolve(
      NotificationDefaults(bazar: false, morningSummaryMinutes: 500),
    );

    expect(prefs.pushEnabled, isFalse);
    expect(resolved.choresEnabled, isFalse);
    expect(resolved.bazarEnabled, isFalse);
    expect(resolved.defaultOffsetsMinutes, <int>[15]);
    expect(resolved.morningSummary.minutes, 500);
    expect(
      NotificationDefaultsMappers.memberPrefsToMap(prefs),
      <String, Object>{
        'pushEnabled': false,
        'chores': false,
        'defaultOffsetsMinutes': <int>[15],
      },
    );
  });
}
