import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/id_generator.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';
import 'package:family_hub/features/chores/templates/domain/usecases/template_change.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';

/// Switches a paused template back on.
///
/// Resuming an ARCHIVED template is a conflict, not a resume: the archive is
/// the family's decision to retire it, and restoring one is a deliberate act
/// the UI does not offer (it would silently restart a chore nobody asked for).
class ResumeTemplate {
  const ResumeTemplate({
    required this._templates,
    required this._families,
    required this._clock,
    required this._newId,
  });

  final TemplateRepository _templates;
  final FamilyRepository _families;
  final Clock _clock;
  final IdGenerator _newId;

  Future<Result<ChoreTemplate>> call({
    required String actorUid,
    required String familyId,
    required String templateId,
  }) => applyTemplateChange(
    templates: _templates,
    families: _families,
    clock: _clock,
    newId: _newId,
    actorUid: actorUid,
    familyId: familyId,
    templateId: templateId,
    auditType: AuditEventType.choresTemplateResumed,
    // An archived template is retired, not paused: resume refuses it (the
    // Conflict surfaces as `template_paused`-style wording in the UI).
    change: (current) => current.isArchived
        ? current
        : current.copyWith(active: true, revision: current.revision + 1),
    params: (saved) => <String, String>{'name': saved.draft.nameBn},
    reject: (current) =>
        current.isArchived ? const Conflict(code: 'template_paused') : null,
  );
}
