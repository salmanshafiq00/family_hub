import 'package:family_hub/core/audit/audit_event.dart';
import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/audit/audit_ref_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/id_generator.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_item_mapping.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_item_repository.dart';
import 'package:family_hub/features/chores/starter_packs/domain/starter_pack.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';
import 'package:family_hub/features/chores/templates/domain/template_validator.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';
import 'package:family_hub/features/family/domain/permission_access.dart';

/// Lets a manager or admin edit the family's own starter pack.
///
/// Every method: permission -> (validation) -> one repository write. The audit
/// entry uses the existing chore vocabulary (no new event types, so the rules'
/// audit list is unchanged): created / updated / archived for one line, and
/// "settings updated" for customise and reset.
class ManageStarterItems {
  const ManageStarterItems({
    required this._items,
    required this._families,
    required this._clock,
    required this._newId,
  });

  final StarterItemRepository _items;
  final FamilyRepository _families;
  final Clock _clock;
  final IdGenerator _newId;

  /// Copies [base] into the family's own list. Fails with `Conflict` when the
  /// family already has its own list.
  Future<Result<void>> customise({
    required String actorUid,
    required String familyId,
    required StarterPack base,
  }) async {
    final current = await _guard(actorUid, familyId);
    if (current.failureOrNull case final failure?) {
      return Failure<void>(failure);
    }
    if (current.valueOrNull!.isNotEmpty) {
      return const Failure<void>(Conflict(code: 'starter_list_customised'));
    }
    return _items.replaceAll(
      familyId,
      items: <ChoreTemplate>[
        for (var i = 0; i < base.templates.length; i++)
          base.templates[i].toItem(sortOrder: i),
      ],
      removeIds: const <String>[],
      event: _event(
        AuditEventType.choresSettingsUpdated,
        actorUid,
        familyId,
        'starter_list',
      ),
    );
  }

  /// Removes the family's own list; the built-in list is used again.
  Future<Result<void>> reset({
    required String actorUid,
    required String familyId,
  }) async {
    final current = await _guard(actorUid, familyId);
    if (current.failureOrNull case final failure?) {
      return Failure<void>(failure);
    }
    return _items.replaceAll(
      familyId,
      items: const <ChoreTemplate>[],
      removeIds: <String>[
        for (final record in current.valueOrNull!) record.template.id,
      ],
      event: _event(
        AuditEventType.choresSettingsUpdated,
        actorUid,
        familyId,
        'starter_list',
      ),
    );
  }

  /// Adds a line ([itemId] null) or replaces one.
  Future<Result<ChoreTemplate>> save({
    required String actorUid,
    required String familyId,
    required TemplateDraft draft,
    String? itemId,
  }) async {
    final current = await _guard(actorUid, familyId);
    if (current.failureOrNull case final failure?) {
      return Failure<ChoreTemplate>(failure);
    }
    final invalid = TemplateValidator.validate(draft);
    if (invalid != null) return Failure<ChoreTemplate>(invalid);

    final records = current.valueOrNull!;
    ChoreTemplate? existing;
    if (itemId != null) {
      for (final record in records) {
        if (record.template.id == itemId) existing = record.template;
      }
      if (existing == null) {
        return const Failure<ChoreTemplate>(NotFound());
      }
    }
    var next = 0;
    for (final record in records) {
      if (record.template.sortOrder >= next) {
        next = record.template.sortOrder + 1;
      }
    }
    // A pack line never carries a person, an end date or planning extras.
    final clean = draft.copyWith(
      assignee: AssigneeSpec.manual,
      clearEndDate: true,
    );
    final id = existing?.id ?? _newId();
    final item = ChoreTemplate(
      id: id,
      draft: clean,
      sortOrder: existing?.sortOrder ?? next,
      seedKey: id,
    );
    final written = await _items.save(
      familyId,
      item,
      _event(
        existing == null
            ? AuditEventType.choresTemplateCreated
            : AuditEventType.choresTemplateUpdated,
        actorUid,
        familyId,
        draft.nameBn,
      ),
    );
    final failure = written.failureOrNull;
    if (failure != null) return Failure<ChoreTemplate>(failure);
    return Success<ChoreTemplate>(item);
  }

  Future<Result<void>> delete({
    required String actorUid,
    required String familyId,
    required String itemId,
  }) async {
    final current = await _guard(actorUid, familyId);
    if (current.failureOrNull case final failure?) {
      return Failure<void>(failure);
    }
    String? name;
    for (final record in current.valueOrNull!) {
      if (record.template.id == itemId) name = record.template.draft.nameBn;
    }
    if (name == null) return const Failure<void>(NotFound());
    return _items.delete(
      familyId,
      itemId,
      _event(AuditEventType.choresTemplateArchived, actorUid, familyId, name),
    );
  }

  /// Permission check + the current list, in one step.
  Future<Result<List<TemplateRecord>>> _guard(
    String actorUid,
    String familyId,
  ) async {
    final permitted = await requirePermission(
      _families,
      familyId: familyId,
      actorUid: actorUid,
      permission: Permission.manageChoreTemplates,
    );
    final denied = permitted.failureOrNull;
    if (denied != null) return Failure<List<TemplateRecord>>(denied);
    return _items.list(familyId);
  }

  AuditEvent _event(
    String type,
    String actorUid,
    String familyId,
    String name,
  ) => AuditEvent(
    id: _newId(),
    type: type,
    actorId: actorUid,
    refType: AuditRefType.choreSettings,
    refId: familyId,
    at: _clock.nowUtc(),
    params: <String, String>{'name': name},
  );
}
