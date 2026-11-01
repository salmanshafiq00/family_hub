import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/availability/domain/availability_index.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_filters.dart';
import 'package:family_hub/features/chores/settings/domain/chore_catalog_entries.dart';

/// Who is away on a day, for the hatch and the strip in the day panel
/// (Appendix B.3).
///
/// Reads the shared [AvailabilityIndex], which stays empty until P3-26 builds
/// it from `memberAvailability`; an empty index simply gives no overlay. The
/// index carries no absence type yet, so the overlay lists members only.
abstract final class UnavailabilityOverlay {
  /// The members to show as away on [day].
  ///
  /// "Mine" shows only the viewer; "Family" shows everybody, narrowed to the
  /// members of an active member filter (so filtering on Dave does not hatch
  /// the day for Cara's sickness).
  static Set<String> forDay({
    required AvailabilityIndex index,
    required DateKey day,
    required CalendarScope scope,
    required String? viewerId,
    required CalendarFilters filters,
  }) {
    final away = index.unavailableOn(day);
    if (away.isEmpty) return const <String>{};
    return <String>{
      for (final member in away)
        if (_visible(member, scope, viewerId, filters)) member,
    };
  }

  static bool _visible(
    String member,
    CalendarScope scope,
    String? viewerId,
    CalendarFilters filters,
  ) {
    if (scope == CalendarScopeKind.mine && member != viewerId) return false;
    if (filters.memberIds.isNotEmpty && !filters.memberIds.contains(member)) {
      return false;
    }
    return true;
  }
}
