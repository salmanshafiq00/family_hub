import 'package:family_hub/app/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// True when there is a screen under this one to go back to.
///
/// Without a [GoRouter] above (a plain widget test) the plain navigator decides.
bool canGoBack(BuildContext context) =>
    GoRouter.maybeOf(context)?.canPop() ?? Navigator.of(context).canPop();

/// A screen that a phone notification can open with `go()` has NOTHING under it
/// in the stack, so the system back button would close the app. This wrapper
/// sends that back press to Home instead; when there is a screen to go back to,
/// it does nothing and the normal pop happens.
class HomeFallbackBack extends StatelessWidget {
  const HomeFallbackBack({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: canGoBack(context),
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) context.go(AppRoutes.home);
    },
    child: child,
  );
}

/// The app bar's back button for the same screens: the automatic one is missing
/// when nothing is under the screen. Use `leading: homeFallbackLeading(context)`.
Widget? homeFallbackLeading(BuildContext context) {
  if (canGoBack(context)) return null;
  return IconButton(
    key: const Key('home_fallback_back'),
    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    icon: const BackButtonIcon(),
    onPressed: () => context.go(AppRoutes.home),
  );
}
