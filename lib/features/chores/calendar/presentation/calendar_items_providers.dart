import 'dart:async';

import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/availability/presentation/availability_index_provider.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_prefs.dart';
import 'package:family_hub/features/chores/calendar/presentation/month_items.dart';
import 'package:family_hub/features/chores/duty_groups/presentation/duty_group_providers.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_item.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_generator.dart';
import 'package:family_hub/features/chores/occurrences/presentation/occurrence_providers.dart';
import 'package:family_hub/features/chores/occurrences/presentation/today_providers.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/chores/templates/presentation/template_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How long a month that nobody shows any more keeps its listener, so swiping
/// back to it is instant and costs no reads (roadmap P3-21).
const Duration kMonthRetention = Duration(seconds: 60);

/// The retention above; a test overrides it with a few milliseconds.
final monthRetentionProvider = Provider<Duration>((ref) => kMonthRetention);

/// Today in the family zone. It changes at midnight and nowhere else: the
/// minute ticker is filtered by `select`, so the calendar models that depend on
/// it are not rebuilt every minute.
final todayKeyProvider = Provider<DateKey>((ref) {
  final keys = ref.watch(familyDateKeysProvider);
  return ref.watch(nowProvider.select(keys.dateKeyOf));
});

/// The person's own "show planned chores" switch (it overrides the family's).
final calendarShowProjectedProvider = Provider<bool>(
  (ref) => ref.watch(calendarPrefsProvider.select((p) => p.showProjected)),
);

/// The chores the generator WOULD write for [month] but has not written yet
/// (D-P3-6): `OccurrenceGenerator.drafts`, the same function that writes them,
/// so a planned day and a generated day can never disagree (C-9, B-08).
///
/// Only days from today to the end of the month `projectedMonthsAhead` ahead
/// are projected, and only while the person has the switch on. While any input
/// is still loading the result is EMPTY rather than wrong: an unknown roster
/// would show every rotation chore as "needs a cover" for a moment.
final projectedItemsProvider = Provider.autoDispose
    .family<List<ChoreItem>, MonthKey>((ref, month) {
      if (!ref.watch(calendarShowProjectedProvider)) {
        return const <ChoreItem>[];
      }
      final today = ref.watch(todayKeyProvider);
      final ahead = ref.watch(
        choreSettingsProvider.select((s) => s.projectedMonthsAhead),
      );
      final first = today.monthKey;
      final last = first.addMonths(ahead);
      if (month.compareTo(first) < 0 || month.compareTo(last) > 0) {
        return const <ChoreItem>[];
      }

      final members = ref.watch(membersProvider);
      final templatesLoaded = ref.watch(templatesStreamProvider).hasValue;
      final groupsLoaded = ref.watch(dutyGroupsStreamProvider).hasValue;
      if (!members.hasValue || !templatesLoaded || !groupsLoaded) {
        return const <ChoreItem>[];
      }

      final availability = ref.watch(availabilityIndexProvider);
      final drafts = OccurrenceGenerator.drafts(
        templates: ref.watch(activeTemplatesProvider),
        dutyGroups: ref.watch(dutyGroupsProvider),
        members: members.requireValue,
        range: DateKeyRange(
          month == first ? today : month.startOfMonth,
          month.endOfMonth,
        ),
        dateKeys: ref.watch(familyDateKeysProvider),
        availabilityIndex: availability,
        policy: ref.watch(rotationPolicyProvider),
      );
      return <ChoreItem>[
        for (final draft in drafts)
          ChoreItem.fromDraft(draft, availability: availability),
      ];
    });

/// One projected chore by id (the detail screen's fallback for a chore that is
/// planned but not written yet, U-03), or null when [id] is not projected.
final projectedItemProvider = Provider.autoDispose.family<ChoreItem?, String>((
  ref,
  id,
) {
  final month = occurrenceMonthOf(id);
  if (month == null) return null;
  for (final item in ref.watch(projectedItemsProvider(month))) {
    if (item.id == id) return item;
  }
  return null;
});

final RegExp _idDatePattern = RegExp(
  r'_(\d{4})(\d{2})\d{2}(?:_[a-z0-9]{1,12})?$',
);

/// The month an occurrence id belongs to (`{templateId}_{yyyyMMdd}[_slot]`).
MonthKey? occurrenceMonthOf(String id) {
  final match = _idDatePattern.firstMatch(id);
  if (match == null) return null;
  final month = int.parse(match.group(2)!);
  if (month < 1 || month > 12) return null;
  return MonthKey(int.parse(match.group(1)!), month);
}

/// Everything the calendar shows for [month]: the stored chores plus the
/// projected ones, merged by id (the STORED one wins), with the status a screen
/// shows. This is the list the models, the Today screen and the board read.
///
/// * It reads the ONE month listener (`monthOccurrencesProvider`); scope and
///   filters are not inputs, so changing them costs no read (rule 37).
/// * It is rebuilt every minute (overdue), but its value is `==`-filtered, so
///   the models behind it only rebuild when a chore really changed.
/// * A month nobody shows keeps its listener for [kMonthRetention].
final monthItemsProvider = Provider.autoDispose
    .family<AsyncValue<MonthItems>, MonthKey>((ref, month) {
      _retainBriefly(ref);
      final stored = ref.watch(monthOccurrencesProvider(month));
      if (!stored.hasValue) {
        return mapAsync<MonthOccurrences, MonthItems>(
          stored,
          (_) => MonthItems.empty,
        );
      }
      final availability = ref.watch(availabilityIndexProvider);
      final grace = ref.watch(
        choreSettingsProvider.select((s) => s.overdueGraceMinutes),
      );
      final now = ref.watch(nowProvider);

      final byId = <String, ChoreItem>{
        for (final occurrence in stored.requireValue.items)
          occurrence.id: withDisplayStatus(
            ChoreItem.fromOccurrence(occurrence, availability: availability),
            now,
            grace,
          ),
      };
      for (final planned in ref.watch(projectedItemsProvider(month))) {
        byId.putIfAbsent(
          planned.id,
          () => withDisplayStatus(planned, now, grace),
        );
      }
      return AsyncData<MonthItems>(
        MonthItems(
          items: byId.values.toList()..sort(compareChoreItems),
          truncated: stored.requireValue.truncated,
        ),
      );
    });

/// Keeps an auto-dispose provider alive for [monthRetentionProvider] after its
/// last listener leaves, and cancels the wait when somebody comes back.
void _retainBriefly(Ref ref) {
  final retention = ref.read(monthRetentionProvider);
  final link = ref.keepAlive();
  Timer? timer;
  ref
    ..onCancel(() {
      timer?.cancel();
      timer = Timer(retention, link.close);
    })
    ..onResume(() {
      timer?.cancel();
      timer = null;
    })
    ..onDispose(() => timer?.cancel());
}
