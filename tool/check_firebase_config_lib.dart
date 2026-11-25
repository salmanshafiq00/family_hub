import 'dart:convert';

/// Local-only check of the Firebase files that are hidden from git.
///
/// The real `apiKey` / `appId` values are never printed: a result names the
/// field that failed, not its content.
enum CheckStatus { pass, fail, warn }

final class ConfigCheck {
  const ConfigCheck(this.status, this.label);

  final CheckStatus status;
  final String label;

  String render() => '${status.name.toUpperCase()} $label';
}

/// Files that must stay skip-worktree protected so a checkout cannot revert
/// the owner's real Firebase configuration.
const List<String> protectedFirebaseFiles = <String>[
  'lib/core/firebase/firebase_options_dev.dart',
  'lib/core/firebase/firebase_options_prod.dart',
  'android/app/src/dev/google-services.json',
  'android/app/src/prod/google-services.json',
];

/// Runs every check over the contents of the four files.
List<ConfigCheck> checkFirebaseConfig({
  required String devOptions,
  required String devGoogleServices,
  required String prodOptions,
  required String prodGoogleServices,
}) {
  return <ConfigCheck>[
    ..._checkFlavor(
      'dev',
      options: devOptions,
      googleServices: devGoogleServices,
      expectedPackage: 'com.familyhub.family_hub.dev',
    ),
    ..._checkFlavor(
      'prod',
      options: prodOptions,
      googleServices: prodGoogleServices,
      expectedPackage: 'com.familyhub.family_hub',
    ),
  ];
}

/// Warns for every protected file that is not marked skip-worktree (`S `).
List<ConfigCheck> checkSkipWorktree(String gitLsFilesVerboseOutput) {
  final protected = <String>{
    for (final line in const LineSplitter().convert(gitLsFilesVerboseOutput))
      if (line.startsWith('S ')) line.substring(2).trim(),
  };
  return <ConfigCheck>[
    for (final path in protectedFirebaseFiles)
      protected.contains(path)
          ? ConfigCheck(CheckStatus.pass, '$path is skip-worktree protected')
          : ConfigCheck(
              CheckStatus.warn,
              '$path is NOT skip-worktree protected',
            ),
  ];
}

List<ConfigCheck> _checkFlavor(
  String flavor, {
  required String options,
  required String googleServices,
  required String expectedPackage,
}) {
  final parsed = _parseOptions(options);
  if (parsed == null) {
    return <ConfigCheck>[
      ConfigCheck(
        CheckStatus.fail,
        '$flavor options: android block or projectId not found',
      ),
    ];
  }

  final results = <ConfigCheck>[];
  if (parsed.apiKey.isEmpty || parsed.apiKey.contains('placeholder')) {
    results.add(
      ConfigCheck(CheckStatus.fail, '$flavor options: apiKey is a placeholder'),
    );
  }
  if (parsed.appId.isEmpty || parsed.appId.contains('placeholder')) {
    results.add(
      ConfigCheck(CheckStatus.fail, '$flavor options: appId is a placeholder'),
    );
  }
  if (results.isEmpty) {
    results.add(ConfigCheck(CheckStatus.pass, '$flavor options'));
  }

  results.addAll(
    _checkGoogleServices(
      flavor,
      googleServices,
      projectId: parsed.projectId,
      appId: parsed.appId,
      expectedPackage: expectedPackage,
    ),
  );
  return results;
}

List<ConfigCheck> _checkGoogleServices(
  String flavor,
  String raw, {
  required String projectId,
  required String appId,
  required String expectedPackage,
}) {
  final decoded = _decode(raw);
  if (decoded == null) {
    return <ConfigCheck>[
      ConfigCheck(CheckStatus.fail, '$flavor google-services: not valid JSON'),
    ];
  }

  final projectInfo = decoded['project_info'];
  final clients = decoded['client'];
  if (projectInfo is! Map<String, dynamic> ||
      clients is! List<dynamic> ||
      clients.isEmpty) {
    return <ConfigCheck>[
      ConfigCheck(
        CheckStatus.fail,
        '$flavor google-services: project_info or client missing',
      ),
    ];
  }
  final client = clients.first;
  if (client is! Map<String, dynamic>) {
    return <ConfigCheck>[
      ConfigCheck(CheckStatus.fail, '$flavor google-services: client missing'),
    ];
  }
  final clientInfo = client['client_info'];
  if (clientInfo is! Map<String, dynamic>) {
    return <ConfigCheck>[
      ConfigCheck(
        CheckStatus.fail,
        '$flavor google-services: client_info missing',
      ),
    ];
  }
  final androidInfo = clientInfo['android_client_info'];
  if (androidInfo is! Map<String, dynamic>) {
    return <ConfigCheck>[
      ConfigCheck(
        CheckStatus.fail,
        '$flavor google-services: android_client_info missing',
      ),
    ];
  }

  final results = <ConfigCheck>[];
  if (projectInfo['project_id'] != projectId) {
    results.add(
      ConfigCheck(
        CheckStatus.fail,
        '$flavor google-services: project_id mismatch',
      ),
    );
  }
  if (androidInfo['package_name'] != expectedPackage) {
    results.add(
      ConfigCheck(
        CheckStatus.fail,
        '$flavor google-services: package_name mismatch',
      ),
    );
  }
  if (clientInfo['mobilesdk_app_id'] != appId) {
    results.add(
      ConfigCheck(
        CheckStatus.fail,
        '$flavor google-services: mobilesdk_app_id mismatch',
      ),
    );
  }

  final keys = client['api_key'];
  final firstKey = keys is List<dynamic> && keys.isNotEmpty ? keys.first : null;
  final currentKey = firstKey is Map<String, dynamic>
      ? firstKey['current_key']
      : null;
  if (currentKey is! String ||
      currentKey.isEmpty ||
      currentKey.contains('placeholder')) {
    results.add(
      ConfigCheck(
        CheckStatus.fail,
        '$flavor google-services: api key is a placeholder',
      ),
    );
  }

  if (results.isEmpty) {
    results.add(ConfigCheck(CheckStatus.pass, '$flavor google-services'));
  }
  return results;
}

Map<String, dynamic>? _decode(String raw) {
  try {
    final decoded = jsonDecode(raw);
    return decoded is Map<String, dynamic> ? decoded : null;
  } on FormatException {
    return null;
  }
}

({String apiKey, String appId, String projectId})? _parseOptions(
  String source,
) {
  final android = RegExp(
    r'static const FirebaseOptions android = FirebaseOptions\(([\s\S]*?)\);',
  ).firstMatch(source);
  final projectId = RegExp(r"static const String projectId = '([^']*)';")
      .firstMatch(source);
  if (android == null || projectId == null) return null;

  final body = android.group(1) ?? '';
  final apiKey = RegExp(r"apiKey:\s*'([^']*)'").firstMatch(body)?.group(1);
  final appId = RegExp(r"appId:\s*'([^']*)'").firstMatch(body)?.group(1);
  if (apiKey == null || appId == null) return null;

  return (apiKey: apiKey, appId: appId, projectId: projectId.group(1) ?? '');
}
