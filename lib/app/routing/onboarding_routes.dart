import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:family_hub/features/auth/presentation/screens/login_screen.dart';
import 'package:family_hub/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:family_hub/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:family_hub/features/auth/presentation/screens/welcome_screen.dart';
import 'package:family_hub/features/family/presentation/screens/create_family_screen.dart';
import 'package:family_hub/features/family/presentation/screens/family_choice_screen.dart';
import 'package:family_hub/features/family/presentation/screens/join_family_screen.dart';
import 'package:family_hub/features/family/presentation/screens/pending_screen.dart';
import 'package:family_hub/features/onboarding/presentation/screens/profile_setup_screen.dart';
import 'package:go_router/go_router.dart';

/// Top-level auth and onboarding routes that run outside the shell.
List<RouteBase> authAndOnboardingRoutes() => [
  // ── Auth ────────────────────────────────────────────────────────────
  GoRoute(
    path: AppRoutes.welcome,
    builder: (context, state) => const WelcomeScreen(),
  ),
  GoRoute(
    path: AppRoutes.login,
    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: AppRoutes.signUp,
    builder: (context, state) => const SignUpScreen(),
  ),
  GoRoute(
    path: AppRoutes.forgotPassword,
    builder: (context, state) => const ForgotPasswordScreen(),
  ),
  GoRoute(
    path: AppRoutes.verifyEmail,
    builder: (context, state) => const VerifyEmailScreen(),
  ),

  // ── Onboarding gates ────────────────────────────────────────────────
  GoRoute(
    path: AppRoutes.profileSetup,
    builder: (context, state) => const ProfileSetupScreen(),
  ),
  GoRoute(
    path: AppRoutes.familyChoice,
    builder: (context, state) => const FamilyChoiceScreen(),
    routes: [
      GoRoute(
        path: 'create',
        builder: (context, state) => const CreateFamilyScreen(),
      ),
      GoRoute(
        path: 'join',
        builder: (context, state) => const JoinFamilyScreen(),
      ),
    ],
  ),
  GoRoute(
    path: AppRoutes.pending,
    builder: (context, state) => const PendingScreen(),
  ),
  GoRoute(
    path: AppRoutes.disabled,
    builder: (context, state) => const DisabledScreen(),
  ),
];
