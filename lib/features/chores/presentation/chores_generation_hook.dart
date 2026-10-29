import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/family/domain/membership.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/membership_providers.dart';
import 'package:family_hub/modules/module_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The family whose occurrences this device should keep generated, or null.
///
/// Non-null only for a SIGNED-IN, ACTIVE member while the Chores module is on:
/// that is the one place that already knows all three (B-01). A pending or
/// disabled member never reaches the shell, and a module that is switched off
/// must not write chore documents.
final choresGenerationTargetProvider = Provider<String?>((ref) {
  final membership = ref.watch(membershipProvider).value;
  if (membership == null || membership.status != MembershipStatus.active) {
    return null;
  }
  if (ref.watch(currentUidProvider) == null) return null;
  final choresOn = ref
      .watch(enabledModulesProvider)
      .any((module) => module.id == 'chores');
  return choresOn ? membership.familyId : null;
});

/// Starts `EnsureOccurrences` once per family per app start (B-01) and shows
/// every failure that is not just "offline".
///
/// It wraps the app shell, so it lives exactly as long as a signed-in session.
/// The run itself is `ensureOccurrencesOnOpenProvider`, which is keep-alive per
/// family, so rebuilding the shell or switching tabs never starts a second run.
class ChoresGenerationHook extends ConsumerWidget {
  const ChoresGenerationHook({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyId = ref.watch(choresGenerationTargetProvider);
    if (familyId != null) {
      ref.listen(ensureOccurrencesOnOpenProvider(familyId), (_, next) {
        final failure = next.hasValue ? next.value : null;
        if (failure == null) return;
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(context.l10n.choresFailureMessage(failure))),
        );
      });
    }
    return child;
  }
}
