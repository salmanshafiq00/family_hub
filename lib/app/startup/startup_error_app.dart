import 'package:family_hub/app/startup/startup_step.dart';
import 'package:family_hub/core/firebase/firebase_options_resolver.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// The last-resort screen shown when a critical startup step failed.
///
/// It deliberately needs no providers, router or theme registry: nothing but
/// Flutter and the generated localizations has run yet.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final StartupFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _StartupErrorScreen(failure: failure, onRetry: onRetry),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({required this.failure, required this.onRetry});

  final StartupFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final bn = lookupAppLocalizations(const Locale('bn'));
    final en = lookupAppLocalizations(const Locale('en'));
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final secondaryStyle = theme.textTheme.bodySmall?.copyWith(
      color: colors.onSurfaceVariant,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
              const SizedBox(height: 16),
              Text(bn.startupFailedTitle, style: theme.textTheme.headlineSmall),
              Text(
                en.startupFailedTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Text(bn.startupFailedBody, style: theme.textTheme.bodyMedium),
              Text(en.startupFailedBody, style: secondaryStyle),
              const SizedBox(height: 20),
              Text(
                bn.startupStepLabel(failure.step),
                style: theme.textTheme.labelLarge,
              ),
              Text(en.startupStepLabel(failure.step), style: secondaryStyle),
              const SizedBox(height: 8),
              SelectableText(
                failure.cause.toString(),
                style: theme.textTheme.bodySmall,
              ),
              if (failure.cause is FirebaseNotConfiguredException) ...[
                const SizedBox(height: 16),
                Text(bn.startupFirebaseHint, style: theme.textTheme.bodyMedium),
                Text(en.startupFirebaseHint, style: secondaryStyle),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onRetry,
                style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
                child: Text('${bn.actionRetry} / ${en.actionRetry}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
