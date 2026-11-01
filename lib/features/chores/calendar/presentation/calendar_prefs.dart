import 'dart:convert';

import 'package:family_hub/app/theme/theme_controller.dart'
    show sharedPreferencesProvider;
import 'package:family_hub/features/chores/calendar/domain/calendar_enums.dart';
import 'package:family_hub/features/chores/calendar/domain/calendar_filters.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/settings/domain/chore_catalog_entries.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/settings/presentation/chore_settings_providers.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The `SharedPreferences` key of one family's calendar preferences (D-P3-21).
///
/// One key PER FAMILY: a phone that switches family (or a shared tablet) never
/// carries a view or a filter over into somebody else's household.
String calendarPrefsKey(String familyId) => 'chores.calendar.prefs.$familyId';

/// What one person chose for the chore calendar (Appendix B.4, D-P3-21).
///
/// These are LOCAL to the device and the family: they are never synced.  The
/// free-text search is deliberately NOT part of them (a stale search that
/// silently hides chores after a restart would look like missing data); it
/// lives in `calendarQueryProvider` for the session only.
final class CalendarPrefs {
  const CalendarPrefs({
    required this.view,
    required this.scope,
    required this.showProjected,
    this.density = Density.comfortable,
    this.markerStyle = MarkerStyle.glyphs,
    this.heatMode = HeatMode.off,
    this.filters = CalendarFilters.none,
  });

  /// The initial values: the family's `settings/chores` (D-P3-21).
  factory CalendarPrefs.fromSettings(ChoreSettings settings) => CalendarPrefs(
    view: settings.defaultCalendarView,
    scope: settings.defaultScope,
    showProjected: settings.showProjected,
  );

  final CalendarView view;
  final CalendarScope scope;

  /// The person's own switch; it overrides the family default.
  final bool showProjected;
  final Density density;
  final MarkerStyle markerStyle;
  final HeatMode heatMode;

  /// Always without free text (see the class comment).
  final CalendarFilters filters;

  CalendarPrefs copyWith({
    CalendarView? view,
    CalendarScope? scope,
    bool? showProjected,
    Density? density,
    MarkerStyle? markerStyle,
    HeatMode? heatMode,
    CalendarFilters? filters,
  }) => CalendarPrefs(
    view: view ?? this.view,
    scope: scope ?? this.scope,
    showProjected: showProjected ?? this.showProjected,
    density: density ?? this.density,
    markerStyle: markerStyle ?? this.markerStyle,
    heatMode: heatMode ?? this.heatMode,
    filters: filters == null ? this.filters : filters.copyWith(query: ''),
  );

  /// The stored form. Only stable ids are written, so a renamed enum constant
  /// can never make an old phone misread the value.
  Map<String, Object?> toJson() => <String, Object?>{
    'v': 1,
    'view': view.id,
    'scope': scope.id,
    'showProjected': showProjected,
    'density': density.id,
    'markerStyle': markerStyle.id,
    'heatMode': heatMode.id,
    'groupIds': filters.groupIds.toList()..sort(),
    'statuses': <String>[for (final status in filters.statuses) status.id]
      ..sort(),
    'memberIds': filters.memberIds.toList()..sort(),
    'onlyNeedsAttention': filters.onlyNeedsAttention,
  };

  /// Reads the stored form. [raw] that is absent, not JSON or not an object
  /// gives null (the caller then uses the family defaults); a field that is
  /// missing or unknown falls back to [fallback]'s value on its own, so a later
  /// release can add a preference without discarding the person's others.
  static CalendarPrefs? decode(String? raw, {required CalendarPrefs fallback}) {
    if (raw == null || raw.isEmpty) return null;
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      // A damaged value is not worth a crash: the family defaults apply.
      return null;
    }
    if (decoded is! Map<String, Object?>) return null;
    return CalendarPrefs(
      view: _hasId(decoded['view'])
          ? CalendarViewKind.fromId(decoded['view'])
          : fallback.view,
      scope: _hasId(decoded['scope'])
          ? CalendarScopeKind.fromId(decoded['scope'])
          : fallback.scope,
      showProjected: decoded['showProjected'] is bool
          ? decoded['showProjected']! as bool
          : fallback.showProjected,
      density: _hasId(decoded['density'])
          ? Density.fromId(decoded['density'])
          : fallback.density,
      markerStyle: _hasId(decoded['markerStyle'])
          ? MarkerStyle.fromId(decoded['markerStyle'])
          : fallback.markerStyle,
      heatMode: _hasId(decoded['heatMode'])
          ? HeatMode.fromId(decoded['heatMode'])
          : fallback.heatMode,
      filters: CalendarFilters(
        groupIds: _strings(decoded['groupIds']),
        statuses: <ChoreStatus>{
          for (final id in _strings(decoded['statuses']))
            for (final status in ChoreStatus.values)
              if (status.id == id) status,
        },
        memberIds: _strings(decoded['memberIds']),
        onlyNeedsAttention: decoded['onlyNeedsAttention'] == true,
      ),
    );
  }

  static bool _hasId(Object? value) => value is String;

  static Set<String> _strings(Object? value) => <String>{
    if (value is List<Object?>)
      for (final entry in value)
        if (entry is String) entry,
  };

  @override
  bool operator ==(Object other) =>
      other is CalendarPrefs &&
      other.view == view &&
      other.scope == scope &&
      other.showProjected == showProjected &&
      other.density == density &&
      other.markerStyle == markerStyle &&
      other.heatMode == heatMode &&
      other.filters == filters;

  @override
  int get hashCode => Object.hash(
    view,
    scope,
    showProjected,
    density,
    markerStyle,
    heatMode,
    filters,
  );

  @override
  String toString() =>
      'CalendarPrefs(${view.id}, ${scope.id}, projected: $showProjected, '
      '${density.id}, ${markerStyle.id}, heat: ${heatMode.id}, '
      'filters: ${filters.activeCount})';
}

/// The live calendar preferences of the current family on this device.
///
/// Until the person changes something, the value FOLLOWS `settings/chores`
/// (a manager who changes the family default is seen by everyone who never
/// customised). The first change stores a complete snapshot, and from then on
/// a later settings change never overwrites it, except through
/// [useFamilyDefaults] (the "Use family defaults" button).
final calendarPrefsProvider =
    NotifierProvider<CalendarPrefsController, CalendarPrefs>(
      CalendarPrefsController.new,
    );

/// True while the person has not customised anything (no stored snapshot).
final calendarUsesFamilyDefaultsProvider = Provider<bool>((ref) {
  ref.watch(calendarPrefsProvider);
  final familyId = ref.watch(currentFamilyIdProvider);
  if (familyId == null) return true;
  return !ref
      .watch(sharedPreferencesProvider)
      .containsKey(calendarPrefsKey(familyId));
});

class CalendarPrefsController extends Notifier<CalendarPrefs> {
  @override
  CalendarPrefs build() {
    final familyId = ref.watch(currentFamilyIdProvider);
    final defaults = CalendarPrefs.fromSettings(
      ref.watch(choreSettingsProvider),
    );
    if (familyId == null) return defaults;
    final raw = ref
        .watch(sharedPreferencesProvider)
        .getString(calendarPrefsKey(familyId));
    return CalendarPrefs.decode(raw, fallback: defaults) ?? defaults;
  }

  Future<void> setView(CalendarView view) => _save(state.copyWith(view: view));

  Future<void> setScope(CalendarScope scope) =>
      _save(state.copyWith(scope: scope));

  /// The scope chip: one tap flips mine / whole family.
  Future<void> toggleScope() => setScope(
    state.scope == CalendarScope.mine ? CalendarScope.all : CalendarScope.mine,
  );

  Future<void> setFilters(CalendarFilters filters) =>
      _save(state.copyWith(filters: filters));

  Future<void> clearFilters() => setFilters(CalendarFilters.none);

  Future<void> setDensity(Density density) =>
      _save(state.copyWith(density: density));

  Future<void> setMarkerStyle(MarkerStyle style) =>
      _save(state.copyWith(markerStyle: style));

  Future<void> setHeatMode(HeatMode mode) =>
      _save(state.copyWith(heatMode: mode));

  Future<void> setShowProjected({required bool value}) =>
      _save(state.copyWith(showProjected: value));

  /// Forgets the stored snapshot; the preferences follow the family again.
  Future<void> useFamilyDefaults() async {
    final familyId = ref.read(currentFamilyIdProvider);
    state = CalendarPrefs.fromSettings(ref.read(choreSettingsProvider));
    if (familyId == null) return;
    await ref
        .read(sharedPreferencesProvider)
        .remove(calendarPrefsKey(familyId));
  }

  Future<void> _save(CalendarPrefs next) async {
    if (next == state) return;
    state = next;
    final familyId = ref.read(currentFamilyIdProvider);
    if (familyId == null) return;
    await ref
        .read(sharedPreferencesProvider)
        .setString(calendarPrefsKey(familyId), jsonEncode(next.toJson()));
  }
}
