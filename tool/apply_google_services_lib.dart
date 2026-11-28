import 'dart:convert';

/// Values copied from a real `google-services.json` (never printed).
final class AndroidFirebaseValues {
  const AndroidFirebaseValues({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    required this.packageName,
  });

  final String apiKey;
  final String appId;
  final String messagingSenderId;
  final String projectId;
  final String packageName;
}

/// Thrown with a message that never contains a key value.
final class ApplyException implements Exception {
  const ApplyException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Reads the first client of a downloaded `google-services.json` and checks it
/// is real, for [expectedProject] and [expectedPackage].
AndroidFirebaseValues parseGoogleServices(
  String raw, {
  required String expectedProject,
  required String expectedPackage,
}) {
  final Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } on FormatException {
    throw const ApplyException('google-services.json is not valid JSON');
  }
  if (decoded is! Map<String, dynamic>) {
    throw const ApplyException('google-services.json has the wrong shape');
  }
  final info = decoded['project_info'];
  final clients = decoded['client'];
  if (info is! Map<String, dynamic> || clients is! List || clients.isEmpty) {
    throw const ApplyException('project_info or client is missing');
  }

  final projectId = info['project_id'];
  final number = info['project_number'];
  if (projectId != expectedProject) {
    throw ApplyException(
      'project_id is "$projectId", expected "$expectedProject". '
      'Download the file from the familyhub-app-ai project.',
    );
  }

  for (final client in clients) {
    if (client is! Map<String, dynamic>) continue;
    final clientInfo = client['client_info'];
    if (clientInfo is! Map<String, dynamic>) continue;
    final android = clientInfo['android_client_info'];
    if (android is! Map<String, dynamic>) continue;
    if (android['package_name'] != expectedPackage) continue;

    final appId = clientInfo['mobilesdk_app_id'];
    final keys = client['api_key'];
    final key = keys is List && keys.isNotEmpty && keys.first is Map
        ? (keys.first as Map)['current_key']
        : null;
    if (appId is! String || key is! String || number is! String) {
      throw const ApplyException('app id, api key or project number missing');
    }
    if (appId.contains('placeholder') || key.contains('placeholder')) {
      throw const ApplyException('the file still contains placeholder values');
    }
    return AndroidFirebaseValues(
      apiKey: key,
      appId: appId,
      messagingSenderId: number,
      projectId: projectId as String,
      packageName: expectedPackage,
    );
  }
  throw ApplyException('no client with package "$expectedPackage" found');
}

/// Replaces apiKey, appId and messagingSenderId inside the `android` block of
/// a `firebase_options_*.dart` source. Every other block stays untouched.
String patchAndroidBlock(String source, AndroidFirebaseValues v) {
  final block = RegExp(
    r'(static const FirebaseOptions android = FirebaseOptions\()([\s\S]*?)(\);)',
  );
  final match = block.firstMatch(source);
  if (match == null) {
    throw const ApplyException('android FirebaseOptions block not found');
  }
  var body = match.group(2)!;
  body = _swap(body, 'apiKey', v.apiKey);
  body = _swap(body, 'appId', v.appId);
  body = _swap(body, 'messagingSenderId', v.messagingSenderId);
  return source.replaceRange(
    match.start,
    match.end,
    '${match.group(1)}$body${match.group(3)}',
  );
}

String _swap(String body, String field, String value) {
  final pattern = RegExp("$field:\\s*'[^']*'");
  if (!pattern.hasMatch(body)) {
    throw ApplyException('field $field not found in android block');
  }
  return body.replaceFirst(pattern, "$field: '$value'");
}
