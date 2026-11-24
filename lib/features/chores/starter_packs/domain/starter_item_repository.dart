import 'package:family_hub/core/audit/audit_event.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/template_repository.dart';

/// Port for `starterPackItems/{seedKey}`: the family's OWN, editable starter
/// pack. An item is stored in the same shape as a chore template (so the same
/// mapper, validator and editor widgets serve it); the document id is the
/// item's seed key.
///
/// While the collection is empty the app uses the built-in pack.
abstract interface class StarterItemRepository {
  /// Live items in `sortOrder` order, bounded by `kMaxStarterItems`.
  Stream<List<TemplateRecord>> watch(String familyId);

  Future<Result<List<TemplateRecord>>> list(String familyId);

  /// Creates or replaces one item; [event] rides in the same batch.
  Future<Result<void>> save(
    String familyId,
    ChoreTemplate item,
    AuditEvent event,
  );

  /// Removes one item; [event] rides in the same batch.
  Future<Result<void>> delete(String familyId, String itemId, AuditEvent event);

  /// Writes [items] and removes [removeIds] (customise / reset). The Firestore
  /// implementation commits in several small batches (the rules cannot judge
  /// many items in one request) and undoes the items it wrote if one fails;
  /// [event] is written last, only on success.
  Future<Result<void>> replaceAll(
    String familyId, {
    required List<ChoreTemplate> items,
    required List<String> removeIds,
    required AuditEvent event,
  });
}
