import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/today_providers.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/chores/templates/presentation/template_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../chores_test_helpers.dart';
import '../presentation/chores_p3_15_support.dart';

/// The overrides every duty-group screen needs (P3-18).
///
/// One in-memory family: no listener, no network, no running timer. Tests may
/// append their own after these.
List<Override> dutyGroupOverrides(ChoresFixture fixture) => <Override>[
  dutyGroupRepositoryProvider.overrideWithValue(fixture.chores.dutyGroups),
  templateRepositoryProvider.overrideWithValue(fixture.chores),
  choreSettingsRepositoryProvider.overrideWithValue(fixture.settings),
  occurrenceRepositoryProvider.overrideWithValue(fixture.occurrences),
  generationMarkerRepositoryProvider.overrideWithValue(fixture.occurrences),
  familyRepositoryProvider.overrideWithValue(fixture.families),
  currentFamilyIdProvider.overrideWithValue(ChoresFixture.familyId),
  nowTickProvider.overrideWith((ref) => const Stream<DateTime>.empty()),
  permissionSettingsProvider.overrideWithValue(PermissionSettings.defaults),
];

/// Pumps a duty-group screen with [dutyGroupOverrides] already applied.
Future<ChoresFixture> pumpDutyGroupScreen(
  WidgetTester tester, {
  required ChoresFixture sharedFixture,
  GoRouter? router,
  Widget? home,
  String uid = 'bob',
  Role role = Role.moderator,
  double textScale = 1,
  List<Override> overrides = const <Override>[],
}) => pumpP3Screen(
  tester,
  sharedFixture: sharedFixture,
  router: router,
  home: home,
  uid: uid,
  role: role,
  textScale: textScale,
  overrides: <Override>[...dutyGroupOverrides(sharedFixture), ...overrides],
);

/// The container behind a pumped screen, for read-only assertions.
ProviderContainer containerOfScreen(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
