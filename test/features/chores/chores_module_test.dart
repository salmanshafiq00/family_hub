import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/app/routing/redirect_rules.dart';
import 'package:family_hub/app/routing/session_phase.dart';
import 'package:family_hub/features/chores/chores_entries.dart';
import 'package:family_hub/features/chores/chores_module.dart';
import 'package:family_hub/features/family/domain/module_flags.dart';
import 'package:family_hub/modules/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('ChoresModule routes', () {
    const module = ChoresModule();

    test('one root route at /chores with a nested manage route', () {
      final routes = module.routes;
      expect(routes, hasLength(1));

      final root = routes.single as GoRoute;
      expect(root.path, AppRoutes.chores);
      final paths = root.routes.whereType<GoRoute>().map((r) => r.path).toList();
      expect(paths, contains('manage'));
      expect(paths.toSet(), hasLength(paths.length));
    });

    test('the manage constant sits under the module base path', () {
      expect(AppRoutes.choresManage, '${AppRoutes.chores}/manage');
      expect(AppRoutes.choresManage, startsWith('${module.basePath}/'));
    });

    test('registry still lists Chores first with an unchanged contract', () {
      final chores = ModuleRegistry.standard().byId('chores')!;
      expect(chores, isA<ChoresModule>());
      expect(chores.requiredPermission, isNull);
      expect(chores.dashboardCards, isEmpty);
      expect(chores.reports, isEmpty);
    });

    test('a family switching Chores off removes it from the enabled list', () {
      final registry = ModuleRegistry.standard();
      const off = ModuleFlags({'chores': false});
      expect(registry.enabled(off).map((m) => m.id), ['bazar']);
    });
  });

  group('guards for /chores/manage', () {
    test('an active member may open it', () {
      expect(
        resolveRedirect(
          phase: SessionPhase.active,
          location: AppRoutes.choresManage,
        ),
        isNull,
      );
    });

    test('a deep link never bypasses a gate', () {
      expect(
        resolveRedirect(
          phase: SessionPhase.signedOut,
          location: AppRoutes.choresManage,
        ),
        AppRoutes.welcome,
      );
      expect(
        resolveRedirect(
          phase: SessionPhase.pending,
          location: AppRoutes.choresManage,
        ),
        AppRoutes.pending,
      );
    });
  });

  group('choresEntries', () {
    test('starts empty and has unique ids and routes under /chores', () {
      final ids = choresEntries.map((e) => e.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
      for (final entry in choresEntries) {
        expect(entry.route, startsWith(AppRoutes.chores), reason: entry.id);
      }
    });
  });
}
