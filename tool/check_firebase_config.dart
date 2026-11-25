import 'dart:io';

import 'check_firebase_config_lib.dart';

/// Local check for the Firebase files that git must never see.
///
/// Run it after every `git checkout`, `stash`, `reset`, `pull` or clone:
/// `dart run tool/check_firebase_config.dart`.
Future<void> main() async {
  final checks = <ConfigCheck>[
    ...checkFirebaseConfig(
      devOptions: _read('lib/core/firebase/firebase_options_dev.dart'),
      devGoogleServices: _read('android/app/src/dev/google-services.json'),
      prodOptions: _read('lib/core/firebase/firebase_options_prod.dart'),
      prodGoogleServices: _read('android/app/src/prod/google-services.json'),
    ),
    ...await _checkGitProtection(),
  ];

  for (final check in checks) {
    stdout.writeln(check.render());
  }
  if (checks.any((check) => check.status == CheckStatus.fail)) {
    exitCode = 1;
  }
}

String _read(String path) {
  try {
    return File(path).readAsStringSync();
  } on FileSystemException {
    return '';
  }
}

Future<List<ConfigCheck>> _checkGitProtection() async {
  try {
    final result = await Process.run('git', <String>['ls-files', '-v']);
    if (result.exitCode != 0) {
      return <ConfigCheck>[
        const ConfigCheck(
          CheckStatus.warn,
          'git ls-files -v could not run; skip-worktree not checked',
        ),
      ];
    }
    return checkSkipWorktree(result.stdout.toString());
  } on ProcessException {
    return <ConfigCheck>[
      const ConfigCheck(
        CheckStatus.warn,
        'git is not available; skip-worktree not checked',
      ),
    ];
  }
}
