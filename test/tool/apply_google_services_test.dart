import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/apply_google_services_lib.dart';

String _json({String project = 'familyhub-app-ai', String key = 'realkey'}) =>
    jsonEncode({
      'project_info': {'project_number': '123456', 'project_id': project},
      'client': [
        {
          'client_info': {
            'mobilesdk_app_id': '1:123456:android:abc',
            'android_client_info': {'package_name': 'com.familyhub.family_hub.dev'},
          },
          'api_key': [
            {'current_key': key},
          ],
        },
      ],
    });

const _source = '''
static const String projectId = 'familyhub-app-ai';
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'webplaceholder',
    appId: '1:1:web:devplaceholder',
    messagingSenderId: '1',
  );
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'placeholder',
    appId: '1:1:android:devplaceholder',
    messagingSenderId: '1',
    projectId: projectId,
  );
''';

void main() {
  const pkg = 'com.familyhub.family_hub.dev';

  test('parses a real file', () {
    final v = parseGoogleServices(_json(), expectedProject: 'familyhub-app-ai', expectedPackage: pkg);
    expect(v.appId, '1:123456:android:abc');
    expect(v.messagingSenderId, '123456');
  });

  test('rejects wrong project and placeholder keys', () {
    expect(
      () => parseGoogleServices(_json(project: 'familyhub-dev'), expectedProject: 'familyhub-app-ai', expectedPackage: pkg),
      throwsA(isA<ApplyException>()),
    );
    expect(
      () => parseGoogleServices(_json(key: 'placeholder'), expectedProject: 'familyhub-app-ai', expectedPackage: pkg),
      throwsA(isA<ApplyException>()),
    );
  });

  test('patches only the android block', () {
    final v = parseGoogleServices(_json(), expectedProject: 'familyhub-app-ai', expectedPackage: pkg);
    final out = patchAndroidBlock(_source, v);
    expect(out, contains("apiKey: 'realkey'"));
    expect(out, contains("appId: '1:123456:android:abc'"));
    expect(out, contains("apiKey: 'webplaceholder'"));
    expect(out, contains('1:1:web:devplaceholder'));
  });
}
