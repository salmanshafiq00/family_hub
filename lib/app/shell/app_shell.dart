import 'package:family_hub/core/firebase/sync_status.dart';
import 'package:family_hub/features/chores/presentation/chores_generation_hook.dart';
import 'package:family_hub/shared/widgets/pill_bottom_bar.dart';
import 'package:family_hub/shared/widgets/sync_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// One tab of the shell: the data the bottom bar needs.
///
/// The shell's branch list and this list are built from the same destinations
/// in `router.dart`, so index `i` here is always branch `i` there.
class ShellDestination {
  const ShellDestination({
    required this.id,
    required this.icon,
    required this.label,
    this.selectedIcon,
  });

  final String id;
  final IconData icon;
  final IconData? selectedIcon;

  /// Localized label factory, evaluated with the active locale.
  final String Function(BuildContext context) label;
}

/// The 4-tab shell (Home, Chores, Bazar, Family; Chores and Bazar only while
/// their module is on).  Each tab keeps its own navigation stack and scroll
/// position because go_router hosts the branches in an `IndexedStack`.
class AppShell extends StatelessWidget {
  const AppShell({
    required this.navigationShell,
    required this.destinations,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final List<ShellDestination> destinations;

  @override
  Widget build(BuildContext context) {
    // B-01: generates the chore occurrences once per app start.
    return ChoresGenerationHook(
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Shown only while changes wait for the server (H3 / rule 15).
            Consumer(
              builder: (context, ref, _) {
                final status = ref.watch(syncStatusProvider);
                return SyncBanner(
                  pendingWrites: status.pendingWrites,
                  offline: status.isOffline,
                );
              },
            ),
            PillBottomBar(
              selectedIndex: navigationShell.currentIndex,
              items: [
                for (final d in destinations)
                  PillNavItem(
                    key: Key('tab_${d.id}'),
                    icon: d.icon,
                    selectedIcon: d.selectedIcon,
                    label: d.label(context),
                  ),
              ],
              onSelected: (index) => navigationShell.goBranch(
                index,
                // Tapping the active tab again returns to the tab's first
                // screen.
                initialLocation: index == navigationShell.currentIndex,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
