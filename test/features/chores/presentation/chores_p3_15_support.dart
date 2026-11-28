import 'package:family_hub/app/theme/theme_builder.dart';
import 'package:family_hub/app/theme/theme_controller.dart'
    show sharedPreferencesProvider;
import 'package:family_hub/app/theme/theme_registry.dart';
import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/clock_provider.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/comments/presentation/comment_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/today_providers.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/chores/templates/presentation/template_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:family_hub/features/notifications/domain/notification_defaults.dart';
import 'package:family_hub/features/notifications/domain/notification_delivery_settings.dart';

import '../../../support/in_memory_notification_backend.dart';

import '../chores_test_helpers.dart';

/// Shared harness for the P3-15 screen tests (Today, Verify, Detail, bar).
///
/// 320 dp wide, English, `disableAnimations`, the in-memory chores backend and
/// one acting member (`uid`, `role`). Providers a test may need to change are
/// named parameters, because Riverpod 3 rejects overriding the same provider
/// twice; [overrides] can only add providers the harness left alone.
Future<ChoresFixture> pumpP3Screen(
  WidgetTester tester, {
  Widget? home,
  GoRouter? router,
  ChoresFixture? sharedFixture,
  String uid = 'cara',
  Role role = Role.member,
  double textScale = 1.0,
  double width = 320,
  double height = 800,
  int themeIndex = 0,
  String languageCode = 'en',
  List<ChoreOccurrence> occurrences = const <ChoreOccurrence>[],
  PermissionSettings? permissionSettings,
  NotificationDefaultsRepository? notificationDefaultsRepository,
  NotificationDeliveryRepository? notificationDeliveryRepository,
  List<Override> overrides = const <Override>[],
}) async {
  tester.view
    ..physicalSize = Size(width, height)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final fixture = sharedFixture ?? ChoresFixture();
  if (occurrences.isNotEmpty || sharedFixture == null) {
    fixture.occurrences.occurrences[ChoresFixture.familyId] =
        <String, ChoreOccurrence>{for (final o in occurrences) o.id: o};
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(prefs),
        appFormattersProvider.overrideWithValue(
          AppFormatters(
            languageCode: languageCode,
            useBanglaDigits: languageCode == 'bn',
          ),
        ),
        occurrenceRepositoryProvider.overrideWithValue(fixture.occurrences),
        commentRepositoryProvider.overrideWithValue(fixture.comments),
        generationMarkerRepositoryProvider.overrideWithValue(
          fixture.occurrences,
        ),
        dutyGroupRepositoryProvider.overrideWithValue(
          fixture.chores.dutyGroups,
        ),
        templateRepositoryProvider.overrideWithValue(fixture.chores),
        choreSettingsRepositoryProvider.overrideWithValue(fixture.settings),
        familyRepositoryProvider.overrideWithValue(fixture.families),
        currentFamilyIdProvider.overrideWithValue(ChoresFixture.familyId),
        currentUidProvider.overrideWithValue(uid),
        clockProvider.overrideWithValue(fixture.clock),
        currentActorProvider.overrideWithValue(
          PermissionActor(uid: uid, role: role, isActive: true),
        ),
        permissionSettingsProvider.overrideWithValue(
          permissionSettings ?? PermissionSettings.defaults,
        ),
        // No running timer in a widget test.
        nowTickProvider.overrideWith((ref) => const Stream<DateTime>.empty()),
        ...notificationTestOverrides(
          defaultsRepository: notificationDefaultsRepository,
          deliveryRepository: notificationDeliveryRepository,
        ),
        ...overrides,
      ],
      child: _app(
        home: home,
        router: router,
        textScale: textScale,
        languageCode: languageCode,
        themeIndex: themeIndex,
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 250));
  return fixture;
}

Widget _app({
  required Widget? home,
  required GoRouter? router,
  required double textScale,
  required String languageCode,
  int themeIndex = 0,
}) {
  final theme = buildThemeData(appThemes[themeIndex]);
  const delegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  Widget scale(BuildContext context, Widget? child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(textScale),
      disableAnimations: true,
    ),
    child: child!,
  );
  if (router != null) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: theme,
      locale: Locale(languageCode),
      localizationsDelegates: delegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: scale,
      routerConfig: router,
    );
  }
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme,
    locale: Locale(languageCode),
    localizationsDelegates: delegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: scale,
    home: home,
  );
}
