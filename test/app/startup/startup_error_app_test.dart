import 'package:family_hub/app/flavor.dart';
import 'package:family_hub/app/startup/startup_error_app.dart';
import 'package:family_hub/app/startup/startup_step.dart';
import 'package:family_hub/core/firebase/firebase_options_resolver.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final bn = lookupAppLocalizations(const Locale('bn'));
  final en = lookupAppLocalizations(const Locale('en'));

  testWidgets('shows the failed step and the error in Bangla and English', (
    tester,
  ) async {
    await tester.pumpWidget(
      StartupErrorApp(
        failure: StartupFailure(
          'firebase',
          StateError('boom-detail'),
          StackTrace.empty,
        ),
        onRetry: () {},
      ),
    );

    expect(find.text(bn.startupFailedTitle), findsOneWidget);
    expect(find.text(en.startupFailedTitle), findsOneWidget);
    expect(find.text(bn.startupStepLabel('firebase')), findsOneWidget);
    expect(find.text(en.startupStepLabel('firebase')), findsOneWidget);
    final details = tester.widget<SelectableText>(find.byType(SelectableText));
    expect(details.data, contains('boom-detail'));
  });

  testWidgets('shows the Firebase hint only for a configuration failure', (
    tester,
  ) async {
    await tester.pumpWidget(
      StartupErrorApp(
        failure: const StartupFailure(
          'firebase',
          FirebaseNotConfiguredException(Flavor.dev),
          StackTrace.empty,
        ),
        onRetry: () {},
      ),
    );

    expect(find.text(bn.startupFirebaseHint), findsOneWidget);
    expect(find.text(en.startupFirebaseHint), findsOneWidget);

    await tester.pumpWidget(
      StartupErrorApp(
        failure: StartupFailure(
          'firebase',
          StateError('other'),
          StackTrace.empty,
        ),
        onRetry: () {},
      ),
    );

    expect(find.text(bn.startupFirebaseHint), findsNothing);
    expect(find.text(en.startupFirebaseHint), findsNothing);
  });

  testWidgets('Retry calls onRetry', (tester) async {
    var retries = 0;

    await tester.pumpWidget(
      StartupErrorApp(
        failure: StartupFailure(
          'shared_preferences',
          StateError('boom'),
          StackTrace.empty,
        ),
        onRetry: () => retries++,
      ),
    );
    await tester.tap(find.byType(FilledButton));

    expect(retries, 1);
  });

  testWidgets('fits 360 dp at 2x text and keeps a 48 dp tap target', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      StartupErrorApp(
        failure: const StartupFailure(
          'firebase',
          FirebaseNotConfiguredException(Flavor.dev),
          StackTrace.empty,
        ),
        onRetry: () {},
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(FilledButton)).height,
      greaterThanOrEqualTo(48),
    );
  });
}
