/// The family's chore-wide preferences (`settings/chores`), road map 3.2.
///
/// Nothing here is a closed *domain* set: groups, due-time presets, absence
/// reasons and the house rules are DATA the family edits (D-P3-4). Only the
/// three enums below are closed, because screens and the calendar switch on
/// them; an unknown stored value falls back to its default in the mapper.
library;

/// The calendar view the Chores tab opens with.
enum CalendarViewKind {
  agenda('agenda'),
  month('month'),
  week('week');

  const CalendarViewKind(this.id);

  final String id;

  static CalendarViewKind fromId(Object? id) {
    for (final kind in values) {
      if (kind.id == id) return kind;
    }
    return CalendarViewKind.agenda;
  }
}

/// Whose chores the calendar shows first.
enum CalendarScopeKind {
  mine('mine'),
  all('all');

  const CalendarScopeKind(this.id);

  final String id;

  static CalendarScopeKind fromId(Object? id) {
    for (final kind in values) {
      if (kind.id == id) return kind;
    }
    return CalendarScopeKind.mine;
  }
}

/// What a chore group is (a row of `settings/chores.groups`).
final class ChoreGroup {
  const ChoreGroup({
    required this.id,
    required this.nameBn,
    this.nameEn,
    this.colorIndex = 0,
    this.iconKey = 'other',
    this.sortOrder = 0,
    this.active = true,
    this.builtIn = false,
  });

  /// Stable machine id (`kitchen`, `custom_1`, …).
  final String id;
  final String nameBn;
  final String? nameEn;

  /// Index into `placeholderPalette` (0 … 23).
  final int colorIndex;

  /// Key into the chore icon map (`chore_icons.dart`, P3-15).
  final String iconKey;
  final int sortOrder;
  final bool active;

  /// Built-in groups may be renamed and deactivated, never removed.
  final bool builtIn;

  ChoreGroup copyWith({
    String? nameBn,
    String? nameEn,
    int? colorIndex,
    String? iconKey,
    int? sortOrder,
    bool? active,
  }) => ChoreGroup(
    id: id,
    nameBn: nameBn ?? this.nameBn,
    nameEn: nameEn ?? this.nameEn,
    colorIndex: colorIndex ?? this.colorIndex,
    iconKey: iconKey ?? this.iconKey,
    sortOrder: sortOrder ?? this.sortOrder,
    active: active ?? this.active,
    builtIn: builtIn,
  );

  Map<String, Object?> toMap() => <String, Object?>{
    'id': id,
    'nameBn': nameBn,
    'nameEn': nameEn,
    'colorIndex': colorIndex,
    'iconKey': iconKey,
    'sortOrder': sortOrder,
    'active': active,
    'builtIn': builtIn,
  };

  @override
  bool operator ==(Object other) =>
      other is ChoreGroup &&
      other.id == id &&
      other.nameBn == nameBn &&
      other.nameEn == nameEn &&
      other.colorIndex == colorIndex &&
      other.iconKey == iconKey &&
      other.sortOrder == sortOrder &&
      other.active == active &&
      other.builtIn == builtIn;

  @override
  int get hashCode => Object.hash(
    id,
    nameBn,
    nameEn,
    colorIndex,
    iconKey,
    sortOrder,
    active,
    builtIn,
  );

  @override
  String toString() => 'ChoreGroup($id, $nameBn, active: $active)';
}

/// A named time of day a chore can be due at (`dueTimePresets`).
final class DueTimePreset {
  const DueTimePreset({
    required this.id,
    required this.labelBn,
    required this.minutes,
    this.labelEn,
    this.active = true,
    this.builtIn = false,
  });

  final String id;
  final String labelBn;
  final String? labelEn;

  /// Wall-clock minutes after midnight (0 … 1439).
  final int minutes;
  final bool active;
  final bool builtIn;

  DueTimePreset copyWith({
    String? labelBn,
    String? labelEn,
    int? minutes,
    bool? active,
  }) => DueTimePreset(
    id: id,
    labelBn: labelBn ?? this.labelBn,
    labelEn: labelEn ?? this.labelEn,
    minutes: minutes ?? this.minutes,
    active: active ?? this.active,
    builtIn: builtIn,
  );

  Map<String, Object?> toMap() => <String, Object?>{
    'id': id,
    'labelBn': labelBn,
    'labelEn': labelEn,
    'minutes': minutes,
    'active': active,
    'builtIn': builtIn,
  };

  @override
  bool operator ==(Object other) =>
      other is DueTimePreset &&
      other.id == id &&
      other.labelBn == labelBn &&
      other.labelEn == labelEn &&
      other.minutes == minutes &&
      other.active == active &&
      other.builtIn == builtIn;

  @override
  int get hashCode =>
      Object.hash(id, labelBn, labelEn, minutes, active, builtIn);

  @override
  String toString() => 'DueTimePreset($id, $minutes)';
}

/// Why somebody is absent (`absenceReasons`).
final class AbsenceReason {
  const AbsenceReason({
    required this.id,
    required this.labelBn,
    this.labelEn,
    this.active = true,
    this.builtIn = false,
  });

  final String id;
  final String labelBn;
  final String? labelEn;
  final bool active;
  final bool builtIn;

  AbsenceReason copyWith({String? labelBn, String? labelEn, bool? active}) =>
      AbsenceReason(
        id: id,
        labelBn: labelBn ?? this.labelBn,
        labelEn: labelEn ?? this.labelEn,
        active: active ?? this.active,
        builtIn: builtIn,
      );

  Map<String, Object?> toMap() => <String, Object?>{
    'id': id,
    'labelBn': labelBn,
    'labelEn': labelEn,
    'active': active,
    'builtIn': builtIn,
  };

  @override
  bool operator ==(Object other) =>
      other is AbsenceReason &&
      other.id == id &&
      other.labelBn == labelBn &&
      other.labelEn == labelEn &&
      other.active == active &&
      other.builtIn == builtIn;

  @override
  int get hashCode => Object.hash(id, labelBn, labelEn, active, builtIn);

  @override
  String toString() => 'AbsenceReason($id, $labelBn)';
}

/// Limits the validator and the rules both enforce (road map 3.2).
abstract final class ChoreSettingsLimits {
  static const int maxGroups = 30;
  static const int maxDueTimePresets = 8;
  static const int maxAbsenceReasons = 12;
  static const int maxHouseRulesLength = 2000;
  static const int minGenerationHorizonDays = 14;
  static const int maxGenerationHorizonDays = 90;
  static const int maxProjectedMonthsAhead = 12;
  static const int maxOverdueGraceMinutes = 240;
  static const int maxSwapExpiryBufferMinutes = 1440;
  static const int paletteLength = 24;
}
