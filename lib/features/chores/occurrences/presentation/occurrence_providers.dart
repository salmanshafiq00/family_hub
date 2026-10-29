import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/firebase/query_limits.dart';
import 'package:family_hub/core/utils/clock_provider.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/generation_plan.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_event.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_repository.dart';
import 'package:family_hub/features/chores/occurrences/domain/usecases/ensure_occurrences.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/chores/templates/presentation/template_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Overridden in `bootstrap.dart` and in tests (same pattern as Bazar).
final occurrenceRepositoryProvider = Provider<OccurrenceRepository>(
  (ref) => throw UnimplementedError(
    'occurrenceRepositoryProvider must be overridden (bootstrap.dart / tests).',
  ),
);

/// The generation marker (`settings/choreGeneration`, D-P3-10).  Overridden
/// with the same object as [occurrenceRepositoryProvider] in the app.
final generationMarkerRepositoryProvider = Provider<GenerationMarkerRepository>(
  (ref) => throw UnimplementedError(
    'generationMarkerRepositoryProvider must be overridden '
    '(bootstrap.dart / tests).',
  ),
);

/// One live listener for [month] (D-P3-8, C-2).
///
/// It returns `null` while the first snapshot is loading (and while offline
/// with nothing cached), and `truncated` tells a screen that the month holds
/// more than [kMaxOccurrencesPerMonth] documents.  Soft-deleted documents are
/// filtered here, once, so no screen has to remember to.
final monthOccurrencesProvider =
    StreamProvider.family<MonthOccurrences, MonthKey>((ref, month) {
      final familyId = ref.watch(currentFamilyIdProvider);
      if (familyId == null) {
        return Stream.value(MonthOccurrences.empty);
      }
      final range = monthRange(month);
      return ref
          .watch(occurrenceRepositoryProvider)
          .watchRange(familyId, from: range.start, to: range.end)
          .map(MonthOccurrences.fromDocuments);
    }, isAutoDispose: false);

/// One document (a projected item has none: the screen falls back to a draft).
final occurrenceProvider = StreamProvider.family<ChoreOccurrence?, String>((
  ref,
  id,
) {
  final familyId = ref.watch(currentFamilyIdProvider);
  if (familyId == null) return Stream.value(null);
  return ref.watch(occurrenceRepositoryProvider).watchOne(familyId, id);
});

/// The lifecycle history of one occurrence, oldest first.
final occurrenceEventsProvider =
    StreamProvider.family<List<OccurrenceEvent>, String>((ref, id) {
      final familyId = ref.watch(currentFamilyIdProvider);
      if (familyId == null) return Stream.value(const <OccurrenceEvent>[]);
      return ref.watch(occurrenceRepositoryProvider).watchEvents(familyId, id);
    });

/// The verification queue: completed documents, newest first.  A caller drops
/// the ones whose snapshot says `verification == off`.
final verifyQueueProvider = StreamProvider<List<ChoreOccurrence>>((ref) {
  final familyId = ref.watch(currentFamilyIdProvider);
  if (familyId == null) return Stream.value(const <ChoreOccurrence>[]);
  return ref.watch(occurrenceRepositoryProvider).watchVerifyQueue(familyId);
});

/// The live generation marker: every date up to it is materialized.
final generationMarkerProvider = StreamProvider<DateKey?>((ref) {
  final familyId = ref.watch(currentFamilyIdProvider);
  if (familyId == null) return Stream.value(null);
  return ref.watch(generationMarkerRepositoryProvider).watchThrough(familyId);
});

/// The materialized-through day, or null while it is unknown.
final generationThroughProvider = Provider<DateKey?>(
  (ref) => ref.watch(generationMarkerProvider).value,
);

/// The `EnsureOccurrences` use case (the app-open hook runs it once).
final ensureOccurrencesProvider = Provider<EnsureOccurrences>(
  (ref) => EnsureOccurrences(
    occurrences: ref.watch(occurrenceRepositoryProvider),
    markers: ref.watch(generationMarkerRepositoryProvider),
    templates: ref.watch(templateRepositoryProvider),
    dutyGroups: ref.watch(dutyGroupRepositoryProvider),
    settings: ref.watch(choreSettingsRepositoryProvider),
    families: ref.watch(familyRepositoryProvider),
    dateKeys: ref.watch(familyDateKeysProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// The app-open generation run, started ONCE per family per app start by
/// `ChoresGenerationHook` (B-01).
///
/// The value is the failure to SHOW, or null when there is nothing to report:
/// the run succeeded, there is no signed-in user, or the device is offline
/// (`Network` retries silently on the next open - the deterministic ids make a
/// repeat harmless). Every other failure is returned instead of swallowed
/// (CLAUDE rule 9: no silent catches); it never throws, so a failed generation
/// can still never block the app start.
final ensureOccurrencesOnOpenProvider =
    FutureProvider.family<AppFailure?, String>((ref, familyId) async {
      final uid = ref.read(currentUidProvider);
      if (uid == null) return null;
      try {
        final result = await ref.read(ensureOccurrencesProvider)(
          familyId: familyId,
          actorUid: uid,
          today: ref.read(familyDateKeysProvider).today(),
        );
        final failure = result.failureOrNull;
        if (failure == null || failure is Network) return null;
        return failure;
      } on Object catch (error) {
        // A thrown error is reported as `Unknown`, not rethrown: the hook runs
        // beside the app start and must never take it down.
        return Unknown(error);
      }
    }, isAutoDispose: false);

/// One month of live occurrences plus the truncation flag.
final class MonthOccurrences {
  const MonthOccurrences({required this.items, required this.truncated});

  static const MonthOccurrences empty = MonthOccurrences(
    items: <ChoreOccurrence>[],
    truncated: false,
  );

  /// Live (not soft-deleted) documents, in `dateKey` then slot order.
  final List<ChoreOccurrence> items;

  /// True when the query returned its probe document: the month is incomplete.
  final bool truncated;

  /// Maps one snapshot; the extra probe document sets [truncated].
  static MonthOccurrences fromDocuments(List<ChoreOccurrence> documents) {
    final truncated = documents.length > kMaxOccurrencesPerMonth;
    final items = <ChoreOccurrence>[
      for (final occurrence in documents)
        if (!occurrence.isDeleted) occurrence,
    ]..sort(compareOccurrences);
    return MonthOccurrences(
      items: truncated && items.length > kMaxOccurrencesPerMonth
          ? items.sublist(0, kMaxOccurrencesPerMonth)
          : items,
      truncated: truncated,
    );
  }
}

/// Calendar order: the day, then the due time, then the main slot first.
int compareOccurrences(ChoreOccurrence a, ChoreOccurrence b) {
  final byDate = a.dateKey.compareTo(b.dateKey);
  if (byDate != 0) return byDate;
  final byDue = a.dueAt.compareTo(b.dueAt);
  if (byDue != 0) return byDue;
  return (a.slotKey ?? '').compareTo(b.slotKey ?? '');
}
