import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Enforces the layer table of CLAUDE.md on the real import GRAPH (H8).
///
/// The old test only looked at direct imports, so a domain file could reach
/// Flutter through a helper.  This one parses every `import`/`export` in
/// `lib/`, resolves it and walks it transitively:
///
/// a) nothing reachable from `lib/features/*/domain/**`, `lib/core/permissions/**`,
///    `lib/core/errors/**`, `lib/core/audit/**` or `lib/core/utils/**` (except
///    `clock_provider.dart`) imports Flutter, Riverpod, go_router or Firebase;
/// b) `presentation/`, `shared/` and `modules/` never import `data/` or Firebase;
/// c) `lib/app/` reaches `data/` and Firebase only from `bootstrap.dart`;
/// d) no feature's domain imports a presentation or data folder.
///
/// `core/localization` and `core/firebase` are documented exceptions: they are
/// the Flutter and Firebase adapters, and nothing pure may reach them.
void main() {
  final directive = RegExp(r"""^\s*(?:import|export)\s+['"]([^'"]+)['"]""");
  final forbiddenPackage = RegExp(
    r'^(flutter|flutter_riverpod|riverpod|go_router|firebase_[a-z_]+|cloud_firestore)$',
  );
  final firebasePackage = RegExp(r'^(firebase_[a-z_]+|cloud_firestore)$');
  final dataFolder = RegExp(r'^lib/(?:[a-z_/]+/)?data/');
  final featureDomain = RegExp(r'^lib/features/[^/]+/domain/');

  /// Where [uri], written in [from], points: an internal `lib/...` path or an
  /// external package name (`dart:` imports are neither).
  ({String? file, String? package}) resolve(String from, String uri) {
    if (uri.startsWith('package:family_hub/')) {
      return (
        file: 'lib/${uri.substring('package:family_hub/'.length)}',
        package: null,
      );
    }
    if (uri.startsWith('package:')) {
      return (file: null, package: uri.substring(8).split('/').first);
    }
    if (uri.startsWith('dart:')) return (file: null, package: null);
    final parts = <String>[...from.split('/')..removeLast(), ...uri.split('/')];
    final out = <String>[];
    for (final p in parts) {
      if (p == '..') {
        if (out.isNotEmpty) out.removeLast();
      } else if (p != '.' && p.isNotEmpty) {
        out.add(p);
      }
    }
    return (file: out.join('/'), package: null);
  }

  /// file -> (internal imports, external packages).
  Map<String, ({List<String> internal, List<String> packages})> buildGraph(
    Map<String, List<String>> sources,
  ) {
    final graph = <String, ({List<String> internal, List<String> packages})>{};
    sources.forEach((file, lines) {
      final internal = <String>[];
      final packages = <String>[];
      for (final line in lines) {
        final m = directive.firstMatch(line);
        if (m == null) continue;
        final r = resolve(file, m.group(1)!);
        if (r.file != null) internal.add(r.file!);
        if (r.package != null) packages.add(r.package!);
      }
      graph[file] = (internal: internal, packages: packages);
    });
    return graph;
  }

  /// Every `root -> ... -> file` chain that ends in a forbidden package.
  List<String> forbiddenReach(
    Map<String, ({List<String> internal, List<String> packages})> graph,
    bool Function(String file) isRoot,
  ) {
    final found = <String>[];
    for (final root in graph.keys.where(isRoot)) {
      final parent = <String, String?>{root: null};
      final stack = <String>[root];
      while (stack.isNotEmpty) {
        final current = stack.removeLast();
        final node = graph[current];
        if (node == null) continue;
        for (final package in node.packages) {
          if (forbiddenPackage.hasMatch(package)) {
            final chain = <String>[];
            for (String? x = current; x != null; x = parent[x]) {
              chain.add(x);
            }
            found.add(
              '$root reaches package:$package via ${chain.reversed.join(' -> ')}',
            );
          }
        }
        for (final next in node.internal) {
          if (!parent.containsKey(next)) {
            parent[next] = current;
            stack.add(next);
          }
        }
      }
    }
    return found;
  }

  bool isPure(String f) {
    if (featureDomain.hasMatch(f)) return true;
    if (f.startsWith('lib/core/permissions/') ||
        f.startsWith('lib/core/errors/') ||
        f.startsWith('lib/core/audit/') ||
        f.startsWith('lib/core/notifications/domain/')) {
      return true;
    }
    return f.startsWith('lib/core/utils/') &&
        !f.endsWith('/clock_provider.dart');
  }

  List<String> featureReach(
    Map<String, ({List<String> internal, List<String> packages})> graph,
    String rootPrefix,
  ) {
    final found = <String>[];
    for (final root in graph.keys.where(
      (file) => file.startsWith(rootPrefix),
    )) {
      final visited = <String>{root};
      final stack = <String>[root];
      while (stack.isNotEmpty) {
        final current = stack.removeLast();
        for (final next in graph[current]?.internal ?? const <String>[]) {
          if (next.startsWith('lib/features/')) {
            found.add('$root reaches feature code through $next');
          } else if (visited.add(next)) {
            stack.add(next);
          }
        }
      }
    }
    return found;
  }

  Map<String, List<String>> readLib() => {
    for (final f
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart')))
      f.path.replaceAll(r'\', '/'): f.readAsLinesSync(),
  };

  // ── Detector self-tests (a vacuous pass is worse than no test) ─────────────

  group('the graph detector', () {
    final fake = <String, List<String>>{
      'lib/features/x/domain/a.dart': [
        "import 'package:family_hub/core/utils/helper.dart';",
      ],
      'lib/core/utils/helper.dart': ["import 'riverpod_wrapper.dart';"],
      'lib/core/utils/riverpod_wrapper.dart': [
        "import 'package:flutter_riverpod/flutter_riverpod.dart';",
      ],
      'lib/core/utils/clock_provider.dart': [
        "import 'package:flutter_riverpod/flutter_riverpod.dart';",
      ],
      'lib/core/utils/clock.dart': ["import 'dart:async';"],
    };

    test('sees a Flutter package reached through a helper', () {
      final bad = forbiddenReach(buildGraph(fake), isPure);
      expect(
        bad.any(
          (b) =>
              b.startsWith('lib/features/x/domain/a.dart') &&
              b.contains('flutter_riverpod'),
        ),
        isTrue,
        reason: bad.join('\n'),
      );
    });

    test(
      'clock_provider.dart is the one allowed Riverpod file in core/utils',
      () {
        expect(isPure('lib/core/utils/clock_provider.dart'), isFalse);
        expect(isPure('lib/core/utils/clock.dart'), isTrue);
      },
    );

    test('resolves relative imports', () {
      expect(
        resolve('lib/core/utils/helper.dart', '../audit/x.dart').file,
        'lib/core/audit/x.dart',
      );
      expect(resolve('lib/a/b.dart', 'dart:io').file, isNull);
    });

    test('a clean pure chain reports nothing', () {
      final clean = buildGraph({
        'lib/features/x/domain/a.dart': [
          "import 'package:family_hub/core/utils/clock.dart';",
        ],
        'lib/core/utils/clock.dart': ["import 'dart:async';"],
      });
      expect(forbiddenReach(clean, isPure), isEmpty);
    });

    test('core notifications cannot reach feature code', () {
      final bad = featureReach(
        buildGraph({
          'lib/core/notifications/domain/a.dart': [
            "import 'package:family_hub/core/notifications/helper.dart';",
          ],
          'lib/core/notifications/helper.dart': [
            "import 'package:family_hub/features/x/domain/model.dart';",
          ],
        }),
        'lib/core/notifications/domain/',
      );
      expect(bad, hasLength(1));
    });
  });

  // ── The real tree ──────────────────────────────────────────────────────────

  final graph = buildGraph(readLib());

  test(
    'a) the pure layers reach no Flutter, Riverpod, router or Firebase package',
    () {
      expect(forbiddenReach(graph, isPure), isEmpty);
    },
  );

  test('core notifications domain does not import feature code', () {
    expect(featureReach(graph, 'lib/core/notifications/domain/'), isEmpty);
  });

  test(
    'b) presentation/, shared/ and modules/ never touch Firebase or data/',
    () {
      final bad = <String>[];
      graph.forEach((file, node) {
        final inScope =
            (file.startsWith('lib/features/') &&
                file.contains('/presentation/')) ||
            file.startsWith('lib/shared/') ||
            file.startsWith('lib/modules/');
        if (!inScope) return;
        for (final p in node.packages) {
          if (firebasePackage.hasMatch(p)) bad.add('$file imports package:$p');
        }
        for (final i in node.internal) {
          if (dataFolder.hasMatch(i)) bad.add('$file imports $i');
        }
      });
      expect(bad, isEmpty);
    },
  );

  test(
    'c) lib/app/ reaches data/ and Firebase only through bootstrap.dart',
    () {
      final bad = <String>[];
      graph.forEach((file, node) {
        if (!file.startsWith('lib/app/') || file == 'lib/app/bootstrap.dart') {
          return;
        }
        for (final p in node.packages) {
          if (firebasePackage.hasMatch(p)) bad.add('$file imports package:$p');
        }
        for (final i in node.internal) {
          if (dataFolder.hasMatch(i)) bad.add('$file imports $i');
        }
      });
      expect(bad, isEmpty);
    },
  );

  test('d) no feature domain imports a presentation/ or data/ folder', () {
    final bad = <String>[];
    graph.forEach((file, node) {
      if (!featureDomain.hasMatch(file)) return;
      for (final i in node.internal) {
        if (RegExp(r'^lib/features/[^/]+/(presentation|data)/').hasMatch(i)) {
          bad.add('$file imports $i');
        }
      }
    });
    expect(bad, isEmpty);
  });
}
