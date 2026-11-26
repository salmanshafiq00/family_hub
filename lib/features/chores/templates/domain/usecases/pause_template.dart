import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/id_generator.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';
import 'package:family_hub/features/chores/templates/domain/usecases/template_change.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';

/// Switches a template off: `active = false`, no occurrences generated from
/// now on. Already-written future occurrences stay until Replan removes them
/// (D-P3-23), and completed history is never touched.
class PauseTemplate {
  const PauseTemplate({
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
    auditType: AuditEventType.choresTemplatePaused,
    // The P3-08 rules require `revision` to grow by exactly one on EVERY
    // template update, including a lifecycle change (pause is not a content
    // edit, but the document is still written).
    change: (current) =>
        current.copyWith(active: false, revision: current.revision + 1),
  );
}
