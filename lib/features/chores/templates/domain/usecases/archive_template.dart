import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/id_generator.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';
import 'package:family_hub/features/chores/templates/domain/usecases/template_change.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';

/// Retires a template: `active = false` AND `archivedAt` set.
///
/// Archive is stronger than pause: the template disappears from the active
/// list and from the editors, and it is never deleted (CLAUDE.md rule 5). The
/// past stays readable; future occurrences are handled by Replan, not here.
class ArchiveTemplate {
  const ArchiveTemplate({
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
    auditType: AuditEventType.choresTemplateArchived,
    // Archiving twice keeps the FIRST archivedAt: the moment the family
    // retired the chore is history and must not move. `revision` still grows
    // because the P3-08 rules require +1 on every update.
    change: (current) => current.copyWith(
      active: false,
      archivedAt: current.archivedAt ?? _clock.nowUtc(),
      revision: current.revision + 1,
    ),
  );
}
