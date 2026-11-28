import 'dart:io';

import 'apply_google_services_lib.dart';

/// Restores the real Android Firebase values of one flavor from the
/// `google-services.json` you downloaded from the Firebase console.
///
/// 1. Console -> familyhub-app-ai -> Project settings -> Your apps ->
///    the Android app -> download google-services.json.
/// 2. Save it over `android/app/src/<flavor>/google-services.json`.
/// 3. dart run tool/apply_google_services.dart dev   (or prod)
/// 4. dart run tool/check_firebase_config.dart
///
/// Key values are never printed.
Future<void> main(List<String> args) async {
  const flavors = <String, ({String package, String options})>{
    'dev': (
      package: 'com.familyhub.family_hub.dev',
      options: 'lib/core/firebase/firebase_options_dev.dart',
    ),
    'prod': (
      package: 'com.familyhub.family_hub',
      options: 'lib/core/firebase/firebase_options_prod.dart',
    ),
  };
  final flavor = args.isEmpty ? null : flavors[args.first];
  if (flavor == null) {
    stderr.writeln('Usage: dart run tool/apply_google_services.dart dev|prod');
    exitCode = 64;
    return;
  }

  try {
    final jsonPath = 'android/app/src/${args.first}/google-services.json';
    final values = parseGoogleServices(
      File(jsonPath).readAsStringSync(),
      expectedProject: 'familyhub-app-ai',
      expectedPackage: flavor.package,
    );
    final file = File(flavor.options);
    file.writeAsStringSync(patchAndroidBlock(file.readAsStringSync(), values));
    stdout.writeln(
      'OK ${args.first}: android block updated in ${flavor.options}',
    );
    stdout.writeln('Next: dart run tool/check_firebase_config.dart');
  } on ApplyException catch (e) {
    stderr.writeln('FAIL ${args.first}: $e');
    exitCode = 1;
  } on FileSystemException catch (e) {
    stderr.writeln('FAIL ${args.first}: cannot read/write ${e.path}');
    exitCode = 1;
  }
}
