import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/features/chores/settings/domain/chore_catalog_entries.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/settings/domain/default_chore_settings.dart';

/// Checks a whole [ChoreSettings] before it is saved (road map P3-06).
///
/// Returns the FIRST problem as a [Validation] with a stable code, or `null`.
/// The order is fixed so the message a user sees is predictable: scalars first,
/// then each catalog (size, unique ids, built-ins kept, at least one active).
///
/// The rules enforce the same ranges (they cannot loop, so they check the list
/// sizes and the first/last item's shape); this validator is the authority for
/// the item-level rules.
abstract final class ChoreSettingsValidator {
  /// `null` when [s] may be saved.
  static Validation? validate(ChoreSettings s) {
    // ── Scalars ─────────────────────────────────────────────────────────────
    if (s.weekStartDay < DateTime.monday || s.weekStartDay > DateTime.sunday) {
      return const Validation('weekStartDay', 'invalid_week_start');
    }
    if (s.generationHorizonDays <
            ChoreSettingsLimits.minGenerationHorizonDays ||
        s.generationHorizonDays >
            ChoreSettingsLimits.maxGenerationHorizonDays) {
      return const Validation('generationHorizonDays', 'invalid_horizon');
    }
    if (s.projectedMonthsAhead < 0 ||
        s.projectedMonthsAhead > ChoreSettingsLimits.maxProjectedMonthsAhead) {
      return const Validation('projectedMonthsAhead', 'invalid_range');
    }
    if (s.overdueGraceMinutes < 0 ||
        s.overdueGraceMinutes > ChoreSettingsLimits.maxOverdueGraceMinutes) {
      return const Validation('overdueGraceMinutes', 'invalid_range');
    }
    if (s.swapExpiryBufferMinutes < 0 ||
        s.swapExpiryBufferMinutes >
            ChoreSettingsLimits.maxSwapExpiryBufferMinutes) {
      return const Validation('swapExpiryBufferMinutes', 'invalid_range');
    }
    if (s.houseRules.length > ChoreSettingsLimits.maxHouseRulesLength) {
      return const Validation('houseRules', 'too_long');
    }

    // ── Groups ──────────────────────────────────────────────────────────────
    if (s.groups.length > ChoreSettingsLimits.maxGroups) {
      return const Validation('groups', 'too_many_items');
    }
    final groupError = _checkList(
      field: 'groups',
      ids: [for (final g in s.groups) g.id],
      active: [for (final g in s.groups) g.active],
      builtIn: [for (final g in s.groups) g.builtIn],
      builtInNames: [for (final g in s.groups) g.nameBn],
      seedIds: _seedIds(defaultGroups),
      // A family may delete a built-in GROUP: groups are display data and a
      // chore whose group is gone falls back to `other` (ChoreCatalogs).
      keepSeeds: false,
    );
    if (groupError != null) return groupError;
    for (final group in s.groups) {
      if (group.nameBn.trim().isEmpty) {
        return const Validation('groups', 'required');
      }
      if (group.nameBn.length > 40 ||
          (group.nameEn?.length ?? 0) > 40 ||
          group.iconKey.isEmpty ||
          group.iconKey.length > 24) {
        return const Validation('groups', 'too_long');
      }
      if (group.colorIndex < 0 ||
          group.colorIndex >= ChoreSettingsLimits.paletteLength) {
        return const Validation('groups', 'invalid_range');
      }
    }

    // ── Due-time presets ────────────────────────────────────────────────────
    if (s.dueTimePresets.length > ChoreSettingsLimits.maxDueTimePresets) {
      return const Validation('dueTimePresets', 'too_many_items');
    }
    final presetError = _checkList(
      field: 'dueTimePresets',
      ids: [for (final p in s.dueTimePresets) p.id],
      active: [for (final p in s.dueTimePresets) p.active],
      builtIn: [for (final p in s.dueTimePresets) p.builtIn],
      builtInNames: [for (final p in s.dueTimePresets) p.labelBn],
      seedIds: _seedIds(defaultDueTimePresets),
    );
    if (presetError != null) return presetError;
    for (final preset in s.dueTimePresets) {
      if (preset.minutes < 0 || preset.minutes > 1439) {
        return const Validation('dueTimePresets', 'invalid_minutes');
      }
      if (preset.labelBn.trim().isEmpty) {
        return const Validation('dueTimePresets', 'required');
      }
      if (preset.labelBn.length > 30 || (preset.labelEn?.length ?? 0) > 30) {
        return const Validation('dueTimePresets', 'too_long');
      }
    }

    // ── Absence reasons ─────────────────────────────────────────────────────
    if (s.absenceReasons.length > ChoreSettingsLimits.maxAbsenceReasons) {
      return const Validation('absenceReasons', 'too_many_items');
    }
    final reasonError = _checkList(
      field: 'absenceReasons',
      ids: [for (final r in s.absenceReasons) r.id],
      active: [for (final r in s.absenceReasons) r.active],
      builtIn: [for (final r in s.absenceReasons) r.builtIn],
      builtInNames: [for (final r in s.absenceReasons) r.labelBn],
      seedIds: _seedIds(defaultAbsenceReasons),
    );
    if (reasonError != null) return reasonError;
    for (final reason in s.absenceReasons) {
      if (reason.labelBn.trim().isEmpty) {
        return const Validation('absenceReasons', 'required');
      }
      if (reason.labelBn.length > 30 || (reason.labelEn?.length ?? 0) > 30) {
        return const Validation('absenceReasons', 'too_long');
      }
    }

    return null;
  }

  /// The rules every catalog shares.
  ///
  /// [seed] is the built-in list: a row that is [builtIn] must correspond to a
  /// seed id. With [keepSeeds] every seed row still present must stay (renaming
  /// and deactivating are allowed, REMOVING is not — the starter pack and older
  /// occurrences may still reference it). Groups pass `false`, so a built-in
  /// group can be deleted like a custom one.
  static Validation? _checkList({
    required String field,
    required List<String> ids,
    required List<bool> active,
    required List<bool> builtIn,
    required List<String> builtInNames,
    required Set<String> seedIds,
    bool keepSeeds = true,
  }) {
    if (ids.isEmpty) {
      return Validation(field, 'no_dates');
    }
    if (ids.toSet().length != ids.length) {
      return Validation(field, 'duplicate_id');
    }
    for (final id in ids) {
      if (!_idPattern.hasMatch(id)) {
        return Validation(field, 'invalid_recurrence');
      }
    }
    if (!active.contains(true)) {
      return Validation(field, 'no_dates');
    }
    // A built-in row cannot disappear: its id must still be in the list.
    for (final id in seedIds) {
      final index = ids.indexOf(id);
      if (index < 0) {
        // The built-in was deleted. A starter pack or an existing occurrence
        // may still reference it, so removal is not allowed (road map P3-06).
        // Groups opt out: their chores fall back to `other` (keepSeeds=false).
        if (keepSeeds) return Validation(field, 'invalid_recurrence');
        continue;
      }
      if (!builtIn[index]) {
        // A seed row may be renamed/deactivated but never turned into a
        // custom row (that would let the next release re-add a duplicate).
        return Validation(field, 'invalid_recurrence');
      }
    }
    for (var i = 0; i < ids.length; i++) {
      if (builtIn[i] && !seedIds.contains(ids[i])) {
        return Validation(field, 'invalid_recurrence');
      }
      if (builtInNames[i].trim().isEmpty) {
        return Validation(field, 'required');
      }
    }
    return null;
  }

  /// The ids of the built-in rows of one catalog.
  static Set<String> _seedIds(List<Object> seed) => <String>{
    for (final row in seed)
      if (row is ChoreGroup)
        row.id
      else if (row is DueTimePreset)
        row.id
      else if (row is AbsenceReason)
        row.id,
  };

  /// Catalog ids are machine ids: lowercase letters, digits and `_`.
  static final RegExp _idPattern = RegExp(r'^[a-z0-9_]{1,24}$');
}
