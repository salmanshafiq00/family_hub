import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_controller.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_state.dart';
import 'package:family_hub/features/chores/settings/presentation/widgets/calendar_defaults_section.dart';
import 'package:family_hub/features/chores/settings/presentation/widgets/catalog_sections.dart';
import 'package:family_hub/features/chores/settings/presentation/widgets/chore_delivery_section.dart';
import 'package:family_hub/features/chores/settings/presentation/widgets/generation_section.dart';
import 'package:family_hub/features/chores/settings/presentation/widgets/house_rules_section.dart';
import 'package:family_hub/features/chores/settings/presentation/widgets/policies_section.dart';
import 'package:family_hub/features/chores/settings/presentation/widgets/reminders_section.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/shared/widgets/busy_button.dart';
import 'package:family_hub/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'chore_settings_screen_parts.dart';

/// The chore settings page (P3-17): every field of `ChoreSettings` is edited
/// here, and nothing else in the app hard-codes them (D-P3-4).
///
/// Six sections organized into top tabs, ONE Save for all of them. The draft
/// lives in [ChoreSettingsController]; this widget only draws it. Saving needs
/// the server, so offline it keeps the draft and says so. Leaving with unsaved
/// edits asks first, and each section can go back to its defaults (after a
/// confirmation; templates are never deleted by it).
class ChoreSettingsScreen extends ConsumerWidget {
  const ChoreSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final canManage = ref.can(Permission.manageChoreTemplates);

    // A plain member who reaches this route (a stale link) sees an explanation
    // instead of the controls; the rules refuse the write anyway.
    if (!canManage) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.choresSettingsTitle)),
        body: EmptyState(
          icon: Icons.lock_outline_rounded,
          title: l10n.choresSettingsNotAllowed,
        ),
      );
    }

    final form = ref.watch(choreSettingsEditorProvider);
    final controller = ref.read(choreSettingsEditorProvider.notifier);

    ref.listen<bool>(choreSettingsEditorProvider.select((s) => s.justSaved), (
      _,
      saved,
    ) {
      if (saved) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.choresSettingsSaved)));
      }
    });

    final t = context.tokens;

    return PopScope(
      canPop: !form.isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _confirmDiscard(context);
        if (leave && context.mounted) {
          controller.discard();
          Navigator.of(context).pop();
        }
      },
      child: DefaultTabController(
        length: ChoreSettingsSection.values.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.choresSettingsTitle),
            bottom: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                for (final section in ChoreSettingsSection.values)
                  Tab(
                    key: ValueKey<String>('tab_${section.name}'),
                    child: Badge(
                      isLabelVisible: form.isSectionDirty(section),
                      backgroundColor: t.accent,
                      child: Text(_sectionTitle(l10n, section)),
                    ),
                  ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _TabScroll(
                child: _SectionCard(
                  title: l10n.choresSettingsCalendarTitle,
                  section: ChoreSettingsSection.calendar,
                  child: CalendarDefaultsSection(
                    draft: form.draft,
                    onChanged: controller.setDraft,
                  ),
                ),
              ),
              _TabScroll(
                child: _SectionCard(
                  title: l10n.choresSettingsGenerationTitle,
                  section: ChoreSettingsSection.generation,
                  child: GenerationSection(
                    draft: form.draft,
                    onChanged: controller.setDraft,
                  ),
                ),
              ),
              _TabScroll(
                child: _SectionCard(
                  title: l10n.choresSettingsCatalogsTitle,
                  section: ChoreSettingsSection.catalogs,
                  child: CatalogSections(
                    draft: form.draft,
                    onChanged: controller.setDraft,
                  ),
                ),
              ),
              _TabScroll(
                child: _SectionCard(
                  title: l10n.choresSettingsPoliciesTitle,
                  section: ChoreSettingsSection.policies,
                  child: PoliciesSection(
                    draft: form.draft,
                    policy: form.policy,
                    completeForOthers: form.completeForOthers,
                    onSettingsChanged: controller.setDraft,
                    onPolicyChanged: controller.setPolicy,
                    onCompleteForOthersChanged: (v) =>
                        controller.setCompleteForOthers(value: v),
                  ),
                ),
              ),
              _TabScroll(
                child: _SectionCard(
                  title: l10n.choresSettingsHouseRulesTitle,
                  section: ChoreSettingsSection.houseRules,
                  child: HouseRulesSection(
                    houseRules: form.draft.houseRules,
                    onChanged: (text) => controller.setDraft(
                      form.draft.copyWith(houseRules: text),
                    ),
                  ),
                ),
              ),
              _TabScroll(
                child: _SectionCard(
                  title: l10n.choresSettingsRemindersTitle,
                  section: ChoreSettingsSection.reminders,
                  child: RemindersSection(
                    defaults: form.notificationDefaults,
                    onChanged: controller.setNotificationDefaults,
                  ),
                ),
              ),
              _TabScroll(
                child: _SectionCard(
                  title: l10n.choresSettingsDeliveryTitle,
                  section: ChoreSettingsSection.delivery,
                  child: ChoreDeliverySection(
                    settings: form.deliverySettings,
                    onChanged: controller.setDeliverySettings,
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _SaveBar(form: form, onSave: controller.save),
        ),
      ),
    );
  }

  static String _sectionTitle(
    AppLocalizations l10n,
    ChoreSettingsSection section,
  ) => switch (section) {
    ChoreSettingsSection.calendar => l10n.choresSettingsCalendarTitle,
    ChoreSettingsSection.generation => l10n.choresSettingsGenerationTitle,
    ChoreSettingsSection.catalogs => l10n.choresSettingsCatalogsTitle,
    ChoreSettingsSection.policies => l10n.choresSettingsPoliciesTitle,
    ChoreSettingsSection.houseRules => l10n.choresSettingsHouseRulesTitle,
    ChoreSettingsSection.reminders => l10n.choresSettingsRemindersTitle,
    ChoreSettingsSection.delivery => l10n.choresSettingsDeliveryTitle,
  };

  static Future<bool> _confirmDiscard(BuildContext context) async {
    final l10n = context.l10n;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.choresSettingsDiscardTitle),
        content: Text(l10n.choresSettingsDiscardMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            key: const ValueKey<String>('discard_confirm'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.actionDiscard),
          ),
        ],
      ),
    );
    return leave ?? false;
  }
}
