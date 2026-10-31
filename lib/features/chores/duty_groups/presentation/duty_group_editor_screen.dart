import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/permissions/permission.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation_draft.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_controller.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/widgets/change_rotation_sheet.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/widgets/duty_group_fields.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/widgets/duty_group_status_banner.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/widgets/group_roster_view.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/widgets/group_templates_section.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/widgets/rota_preview.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/widgets/rotation_editor.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/shared/widgets/busy_button.dart';
import 'package:family_hub/shared/widgets/empty_state.dart';
import 'package:family_hub/shared/widgets/error_view.dart';
import 'package:family_hub/shared/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Creates a duty group ([groupId] null) or edits a stored one (P3-18).
///
/// New: name, colour and the first rotation version. Stored: name, colour,
/// active switch, the read-only roster, the rota preview, the change-rotation
/// sheet and the chores of the group. Everybody may open it; without
/// `manageChoreTemplates` every control is off and a note says why.
class DutyGroupEditorScreen extends ConsumerStatefulWidget {
  const DutyGroupEditorScreen({this.groupId, super.key});

  final String? groupId;

  @override
  ConsumerState<DutyGroupEditorScreen> createState() => _EditorState();
}

class _EditorState extends ConsumerState<DutyGroupEditorScreen> {
  final TextEditingController _nameBn = TextEditingController();
  final TextEditingController _nameEn = TextEditingController();
  int _colorIndex = 0;
  bool _active = true;
  RotationDraft? _draft;
  bool _loaded = false;

  @override
  void dispose() {
    _nameBn.dispose();
    _nameEn.dispose();
    super.dispose();
  }

  void _load(DutyGroup? group) {
    if (_loaded) return;
    _loaded = true;
    if (group == null) {
      _draft = RotationDraft(
        members: const <String>[],
        startsOn: ref.read(familyDateKeysProvider).today(),
        cycleUnit: CycleUnit.week,
        weekStartDay: ref.read(choreSettingsProvider).weekStartDay,
      );
      return;
    }
    _nameBn.text = group.nameBn;
    _nameEn.text = group.nameEn ?? '';
    _colorIndex = group.colorIndex ?? 0;
    _active = group.active;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final id = widget.groupId;
    final group = id == null ? null : ref.watch(dutyGroupProvider(id));
    final stream = ref.watch(dutyGroupsStreamProvider);

    final Widget body;
    if (id != null && group == null) {
      if (stream.hasError && !stream.hasValue) {
        final error = stream.error;
        body = ErrorView(
          message: l10n.choresFailureMessage(
            error is AppFailure ? error : Unknown(error),
          ),
          onRetry: () => ref.invalidate(dutyGroupsStreamProvider),
        );
      } else if (!stream.hasValue) {
        body = const LoadingView();
      } else {
        body = EmptyState(
          icon: Icons.groups_outlined,
          title: l10n.dutyGroupNotFound,
        );
      }
    } else {
      _load(group);
      body = _form(context, group);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(id == null ? l10n.dutyGroupNew : l10n.dutyGroupEditTitle),
      ),
      body: body,
    );
  }

  Widget _form(BuildContext context, DutyGroup? group) {
    final l10n = context.l10n;
    final canManage = ref.can(Permission.manageChoreTemplates);
    final busy = ref.watch(dutyGroupControllerProvider.select((s) => s.saving));
    final enabled = canManage && !busy;
    final draft = _draft;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!canManage)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.lock_outline),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.dutyGroupReadOnly)),
              ],
            ),
          ),
        const DutyGroupStatusBanner(),
        DutyGroupFields(
          nameBn: _nameBn,
          nameEn: _nameEn,
          colorIndex: _colorIndex,
          onColor: (value) => setState(() => _colorIndex = value),
          enabled: enabled,
          active: group == null ? null : _active,
          onActive: (value) => setState(() => _active = value),
        ),
        const SizedBox(height: 16),
        if (group == null && draft != null) ...[
          RotationEditor(
            draft: draft,
            enabled: enabled,
            onChanged: (value) => setState(() => _draft = value),
          ),
          const SizedBox(height: 16),
          if (draft.toRotation().valueOrNull case final rotation?)
            RotaPreviewView(rotation: rotation, from: draft.startsOn),
        ] else if (group != null) ...[
          GroupRosterView(memberIds: group.members),
          const SizedBox(height: 16),
          RotaPreviewView(
            rotation: group.rotation,
            recurrence: ref
                .watch(dutyGroupTemplatesProvider(group.id))
                .firstOrNull
                ?.draft
                .recurrence,
          ),
          if (canManage) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const ValueKey<String>('change_rotation'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: busy ? null : () => _change(group),
              icon: const Icon(Icons.swap_vert),
              label: Text(l10n.dutyChangeTitle),
            ),
          ],
          const SizedBox(height: 24),
          GroupTemplatesSection(groupId: group.id, canManage: canManage),
        ],
        if (canManage) ...[
          const SizedBox(height: 24),
          BusyButton(
            key: const ValueKey<String>('save_group'),
            label: l10n.dutyGroupSave,
            busy: busy,
            onPressed: () => _save(group),
          ),
        ],
      ],
    );
  }

  String? _english() {
    final text = _nameEn.text.trim();
    return text.isEmpty ? null : text;
  }

  Future<void> _save(DutyGroup? group) async {
    final controller = ref.read(dutyGroupControllerProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final saved = context.l10n.dutyGroupSaved;
    final router = GoRouter.of(context);

    if (group == null) {
      final created = await controller.create(
        nameBn: _nameBn.text.trim(),
        nameEn: _english(),
        colorIndex: _colorIndex,
        rotation: _draft!.toRotation(),
      );
      if (created == null || !mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(saved)));
      _leave(router);
      return;
    }

    var ok = await controller.update(
      groupId: group.id,
      nameBn: _nameBn.text.trim(),
      nameEn: _english(),
      colorIndex: _colorIndex,
      active: _active,
    );
    if (!mounted) return;
    if (!ok && ref.read(dutyGroupControllerProvider).needsDeactivateConfirm) {
      final confirmed = await _confirmDeactivate();
      if (confirmed != true || !mounted) return;
      ok = await controller.update(
        groupId: group.id,
        nameBn: _nameBn.text.trim(),
        nameEn: _english(),
        colorIndex: _colorIndex,
        active: _active,
        confirmDeactivate: true,
      );
    }
    if (ok) messenger.showSnackBar(SnackBar(content: Text(saved)));
  }

  Future<bool?> _confirmDeactivate() {
    final l10n = context.l10n;
    return showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l10n.dutyGroupDeactivateTitle),
        content: Text(l10n.dutyGroupDeactivateMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            key: const ValueKey<String>('confirm_deactivate'),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l10n.dutyGroupDeactivateConfirm),
          ),
        ],
      ),
    );
  }

  Future<void> _change(DutyGroup group) async {
    final controller = ref.read(dutyGroupControllerProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final saved = context.l10n.dutyGroupSaved;
    final request = await showChangeRotationSheet(context, group: group);
    if (request == null || !mounted) return;
    final status = await controller.changeRotation(group.id, request);
    if (status == DutyGroupStatus.saved) {
      messenger.showSnackBar(SnackBar(content: Text(saved)));
    }
  }

  void _leave(GoRouter router) {
    if (router.canPop()) {
      router.pop();
    } else {
      router.go(AppRoutes.choresDutyGroups);
    }
  }
}
