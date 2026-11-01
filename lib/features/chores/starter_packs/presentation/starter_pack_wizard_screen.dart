import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/starter_packs/domain/packs/family_pdf_pack.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/starter_pack_wizard_controller.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/starter_pack_wizard_state.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/widgets/starter_pack_pick_step.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/widgets/starter_pack_result_view.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/widgets/starter_pack_review_step.dart';
import 'package:family_hub/features/chores/starter_packs/presentation/widgets/starter_pack_who_step.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/shared/widgets/app_card.dart';
import 'package:family_hub/shared/widgets/busy_button.dart';
import 'package:family_hub/shared/widgets/empty_state.dart';
import 'package:family_hub/shared/widgets/error_view.dart';
import 'package:family_hub/shared/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The starter-pack wizard (P3-19).
///
/// Pick → review (confidence per line) → who does what → apply → Open Today.
/// Reachable from Manage at any time, so a family can add lines it skipped the
/// first time; the use case is idempotent, so a second run never duplicates.
class StarterPackWizardScreen extends ConsumerWidget {
  const StarterPackWizardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final canManage = ref.can(Permission.manageChoreTemplates);
    final members = ref.watch(membersProvider);

    final Widget body;
    if (!canManage) {
      body = EmptyState(
        icon: Icons.lock_outline_rounded,
        title: l10n.starterPackTitle,
        message: l10n.starterPackManagersOnly,
      );
    } else if (members.hasError && !members.hasValue) {
      body = ErrorView(
        message: l10n.choresFailure_unknown,
        retryLabel: l10n.actionRetry,
        onRetry: () => ref.invalidate(membersProvider),
      );
    } else if (!members.hasValue) {
      body = const LoadingView(lines: 4);
    } else {
      body = const _WizardBody();
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.starterPackTitle)),
      body: body,
    );
  }
}

class _WizardBody extends ConsumerWidget {
  const _WizardBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(starterPackWizardProvider);
    final formatters = ref.watch(appFormattersProvider);
    final roster = ref.watch(dutyRosterProvider);

    if (state.done) {
      return StarterPackResultView(
        outcome: state.outcome!,
        formatters: formatters,
        onOpenToday: () => context.go(AppRoutes.choresToday),
        onOpenTemplates: () => context.go(AppRoutes.choresTemplates),
      );
    }

    final controller = ref.read(starterPackWizardProvider.notifier);

    return Column(
      children: <Widget>[
        _StepHeader(state: state),
        if (state.failure case final failure?)
          _FailureBanner(message: l10n.choresFailureMessage(failure)),
        Expanded(
          child: switch (state.step) {
            StarterPackWizardStep.pick => StarterPackPickStep(
              pack: familyPdfPack,
              formatters: formatters,
            ),
            StarterPackWizardStep.review => StarterPackReviewStep(
              templates: familyPdfPack.templates,
              selected: state.selectedSeedKeys,
              onToggle: controller.toggleTemplate,
              houseRules: state.houseRules,
              addHouseRules: state.addHouseRules,
              onAddHouseRules: controller.setAddHouseRules,
              onHouseRulesChanged: controller.setHouseRules,
              formatters: formatters,
            ),
            StarterPackWizardStep.who => StarterPackWhoStep(
              members: roster,
              useRotation: state.useRotation,
              rotationMemberIds: state.rotationMemberIds,
              firstMemberId: state.firstMemberId,
              cycleUnit: state.cycleUnit,
              onUseRotation: controller.setUseRotation,
              onToggleMember: controller.toggleRotationMember,
              onFirstMember: controller.setFirstMember,
              onCycleUnit: controller.setCycleUnit,
            ),
          },
        ),
        _BottomBar(state: state, controller: controller),
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.state});

  final StarterPackWizardState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _title(context),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                l10n.starterPackStepOf(
                  '${state.stepNumber}',
                  '${StarterPackWizardStep.values.length}',
                ),
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: t.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(t.radiusPill),
            child: LinearProgressIndicator(
              value:
                  state.stepNumber / StarterPackWizardStep.values.length,
              minHeight: 6,
              backgroundColor: t.surfaceSunken,
              color: t.accent,
            ),
          ),
        ],
      ),
    );
  }

  String _title(BuildContext context) => switch (state.step) {
    StarterPackWizardStep.pick => context.l10n.starterPackStepPick,
    StarterPackWizardStep.review => context.l10n.starterPackStepReview,
    StarterPackWizardStep.who => context.l10n.starterPackStepWho,
  };
}

class _FailureBanner extends StatelessWidget {
  const _FailureBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: AppCard(
        color: t.statusOverdueContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Semantics(
          container: true,
          liveRegion: true,
          label: message,
          excludeSemantics: true,
          child: Row(
            children: <Widget>[
              Icon(Icons.error_outline_rounded, color: t.statusOverdueOn),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: t.statusOverdueOn),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.state, required this.controller});

  final StarterPackWizardState state;
  final StarterPackWizardController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final last = state.step == StarterPackWizardStep.who;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: <Widget>[
            if (state.step != StarterPackWizardStep.pick) ...<Widget>[
              OutlinedButton(
                key: const ValueKey<String>('starter_back'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 52),
                ),
                onPressed: state.applying ? null : controller.back,
                child: Text(l10n.actionBack),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: BusyButton(
                key: ValueKey<String>(
                  last ? 'starter_apply' : 'starter_next',
                ),
                label: last ? l10n.starterPackApply : l10n.actionContinue,
                busyLabel: l10n.starterPackApplying,
                busy: state.applying,
                onPressed: last ? controller.apply : controller.nextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
