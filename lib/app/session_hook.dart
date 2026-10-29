import 'package:family_hub/app/routing/session_phase.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/family/presentation/membership_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app-level work that starts once the session is active (B-01).
///
/// It is the ONE place that knows "signed in + active member + family id":
///
/// * it starts the occurrence generation run once per family
///   (`ensureOccurrencesOnOpenCallProvider`); without that caller Today is
///   empty forever;
/// * it shows that run's non-offline failure once, so a denied or broken
///   generation is never swallowed (CLAUDE.md rule 9).
///
/// It renders nothing: the shell calls it, because a `ref.listen` needs a
/// widget that stays mounted while the app changes screens.
void startSessionHooks(BuildContext context, WidgetRef ref) {
  final phase = ref.watch(sessionPhaseProvider);
  final familyId = ref.watch(membershipProvider).value?.familyId;
  if (phase == SessionPhase.active && familyId != null) {
    ref.read(ensureOccurrencesOnOpenCallProvider)(familyId);
  }

  ref.listen<GenerationFailure?>(generationFailureProvider, (_, failure) {
    if (failure == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.choresFailureMessage(failure.failure)),
      ),
    );
    // One message per failure; a later successful run clears it.
    ref.read(generationFailureProvider.notifier).clear(failure.familyId);
  });
}
