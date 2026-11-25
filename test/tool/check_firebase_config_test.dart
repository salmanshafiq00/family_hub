import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_firebase_config_lib.dart';

const _devPackage = 'com.familyhub.family_hub.dev';
const _prodPackage = 'com.familyhub.family_hub';
const _devAppId = '1:1234567890:android:devapp';
const _prodAppId = '1:1234567890:android:prodapp';

void main() {
  group('checkFirebaseConfig', () {
    test('passes matching options and google-services files', () {
      final checks = checkFirebaseConfig(
        devOptions: _options(appId: _devAppId),
        devGoogleServices: _google(appId: _devAppId),
        prodOptions: _options(appId: _prodAppId),
        prodGoogleServices: _google(package: _prodPackage, appId: _prodAppId),
      );

      expect(_labels(checks, CheckStatus.fail), isEmpty);
      expect(_labels(checks, CheckStatus.pass), hasLength(4));
    });

    test('fails on a placeholder api key or app id', () {
      final apiKeyChecks = checkFirebaseConfig(
        devOptions: _options(appId: _devAppId, apiKey: 'placeholder-key'),
        devGoogleServices: _google(appId: _devAppId),
        prodOptions: _options(appId: _prodAppId),
        prodGoogleServices: _google(package: _prodPackage, appId: _prodAppId),
      );
      expect(
        _labels(apiKeyChecks, CheckStatus.fail),
        contains('dev options: apiKey is a placeholder'),
      );

      final appIdChecks = checkFirebaseConfig(
        devOptions: _options(appId: 'devplaceholder00001'),
        devGoogleServices: _google(appId: _devAppId),
        prodOptions: _options(appId: _prodAppId),
        prodGoogleServices: _google(package: _prodPackage, appId: _prodAppId),
      );
      expect(
        _labels(appIdChecks, CheckStatus.fail),
        contains('dev options: appId is a placeholder'),
      );
    });

    test('fails on a project, package or app id mismatch', () {
      expect(
        _labels(
          _devChecks(googleServices: _google(projectId: 'familyhub-dev')),
          CheckStatus.fail,
        ),
        contains('dev google-services: project_id mismatch'),
      );
      expect(
        _labels(
          _devChecks(googleServices: _google(package: 'wrong.package')),
          CheckStatus.fail,
        ),
        contains('dev google-services: package_name mismatch'),
      );
      expect(
        _labels(
          _devChecks(googleServices: _google(appId: '1:1:android:other')),
          CheckStatus.fail,
        ),
        contains('dev google-services: mobilesdk_app_id mismatch'),
      );
    });

    test('fails on a placeholder key or malformed google-services', () {
      expect(
        _labels(
          _devChecks(googleServices: _google(currentKey: 'placeholder-key')),
          CheckStatus.fail,
        ),
        contains('dev google-services: api key is a placeholder'),
      );
      expect(
        _labels(_devChecks(googleServices: '{'), CheckStatus.fail),
        contains('dev google-services: not valid JSON'),
      );
      expect(
        _labels(
          _devChecks(googleServices: jsonEncode(<String, Object>{})),
          CheckStatus.fail,
        ),
        contains('dev google-services: project_info or client missing'),
      );
    });

    test('never prints key values', () {
      final checks = checkFirebaseConfig(
        devOptions: _options(appId: _devAppId),
        devGoogleServices: _google(appId: _devAppId),
        prodOptions: _options(appId: _prodAppId),
        prodGoogleServices: _google(package: _prodPackage, appId: _prodAppId),
      );

      for (final check in checks) {
        expect(check.render(), isNot(contains('real-api-key')));
        expect(check.render(), isNot(contains(_devAppId)));
        expect(check.render(), isNot(contains(_prodAppId)));
      }
    });
  });

  group('checkSkipWorktree', () {
    test('passes every protected file marked S', () {
      final checks = checkSkipWorktree(
        protectedFirebaseFiles.map((path) => 'S $path').join('\n'),
      );

      expect(_labels(checks, CheckStatus.warn), isEmpty);
      expect(_labels(checks, CheckStatus.pass), hasLength(4));
    });

    test('warns for a file that is not skip-worktree', () {
      final checks = checkSkipWorktree(
        'S ${protectedFirebaseFiles.first}\n'
        'H ${protectedFirebaseFiles[1]}',
      );

      expect(
        _labels(checks, CheckStatus.warn),
        contains('${protectedFirebaseFiles[1]} is NOT skip-worktree protected'),
      );
    });
  });
}

List<ConfigCheck> _devChecks({required String googleServices}) {
  return checkFirebaseConfig(
    devOptions: _options(appId: _devAppId),
    devGoogleServices: googleServices,
    prodOptions: _options(appId: _prodAppId),
    prodGoogleServices: _google(package: _prodPackage, appId: _prodAppId),
  );
}

List<String> _labels(List<ConfigCheck> checks, CheckStatus status) => <String>[
  for (final check in checks)
    if (check.status == status) check.label,
];

String _options({
  String apiKey = 'real-api-key',
  String appId = _devAppId,
  String projectId = 'familyhub-app-ai',
}) {
  return '''
class TestOptions {
  static const String projectId = '$projectId';

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: '$apiKey',
    appId: '$appId',
    messagingSenderId: '1234567890',
    projectId: projectId,
  );
}
''';
}

String _google({
  String projectId = 'familyhub-app-ai',
  String package = _devPackage,
  String appId = _devAppId,
  String currentKey = 'real-api-key',
}) {
  return jsonEncode(<String, Object>{
    'project_info': <String, Object>{
      'project_number': '1234567890',
      'project_id': projectId,
    },
    'client': <Object>[
      <String, Object>{
        'client_info': <String, Object>{
          'mobilesdk_app_id': appId,
          'android_client_info': <String, Object>{'package_name': package},
        },
        'api_key': <Object>[
          <String, Object>{'current_key': currentKey},
        ],
      },
    ],
  });
}
