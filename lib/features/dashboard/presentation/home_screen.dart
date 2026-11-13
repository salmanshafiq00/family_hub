import 'package:family_hub/app/feature_flags.dart';
import 'package:family_hub/app/flavor.dart';
import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/dashboard/domain/dashboard_refresh.dart';
import 'package:family_hub/features/dashboard/presentation/dashboard_grid.dart';
import 'package:family_hub/features/dashboard/presentation/dashboard_header.dart';
import 'package:family_hub/features/dashboard/presentation/dashboard_providers.dart';
import 'package:family_hub/features/dashboard/presentation/widgets/ask_ai_entry.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/shared/widgets/empty_state.dart';
import 'package:family_hub/shared/widgets/error_view.dart';
import 'package:family_hub/shared/widgets/loading_view.dart';
import 'package:family_hub/shared/widgets/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final familyId = ref.read(currentFamilyIdProvider);
    final uid = ref.read(currentUidProvider);
    final failure = await const DashboardRefresh().run(
      ensureOccurrences: () async {
        if (familyId == null || uid == null) return null;
        final result = await ref.read(ensureOccurrencesProvider)(
          familyId: familyId,
          actorUid: uid,
          today: ref.read(familyDateKeysProvider).today(),
        );
        return result.failureOrNull;
      },
      invalidateOneShotProviders: () {
        ref.invalidate(dashboardGreetingProvider);
        ref.invalidate(dashboardCardsProvider);
      },
    );
    if (!context.mounted || failure == null) return;
    final message = switch (failure) {
      Network() => l10n.errorNetwork,
      PermissionDenied() => l10n.errorPermissionDenied,
      _ => l10n.errorUnknown,
    };
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final flavor = ref.watch(flavorProvider);
    final cards = ref.watch(dashboardCardsProvider);
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refresh(context, ref),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 20),
                sliver: SliverToBoxAdapter(child: DashboardHeader()),
              ),
              ...cards.when<List<Widget>>(
                loading: () => const <Widget>[
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: SizedBox(
                        height: 240,
                        child: LoadingView(lines: 5),
                      ),
                    ),
                  ),
                ],
                error: (failure, _) => <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: ErrorView(
                        message: switch (failure) {
                          Network() => l10n.errorNetwork,
                          PermissionDenied() => l10n.errorPermissionDenied,
                          _ => l10n.errorUnknown,
                        },
                        onRetry: () => ref.invalidate(dashboardCardsProvider),
                      ),
                    ),
                  ),
                ],
                data: (visible) => visible.isEmpty
                    ? <Widget>[
                        // P4-23: `SliverFillRemaining(hasScrollBody: false)`
                        // sizes its child through intrinsic heights, and
                        // [EmptyState] builds on a LayoutBuilder, which refuses
                        // them - Home threw as soon as the layout had no cards.
                        // A box adapter lets the empty state size itself.
                        SliverToBoxAdapter(
                          child: EmptyState(
                            icon: Icons.dashboard_customize_outlined,
                            title: l10n.dashboardEmptyTitle,
                            message: l10n.dashboardEmptyMessage,
                            actionLabel: l10n.dashboardCustomize,
                            onAction: () =>
                                context.push(AppRoutes.customizeDashboard),
                          ),
                        ),
                      ]
                    : <Widget>[
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: DashboardGrid(
                            cards: visible,
                            twoColumns: context.layoutClass.showsTwoPanes,
                          ),
                        ),
                        if (FeatureFlags.askAi)
                          const SliverPadding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                            sliver: SliverToBoxAdapter(child: AskAiEntry()),
                          ),
                      ],
              ),
              if (flavor != Flavor.prod)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Text(
                      flavor.name,
                      key: const Key('flavor_name'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          ),
        ),
      ),
    );
  }
}
