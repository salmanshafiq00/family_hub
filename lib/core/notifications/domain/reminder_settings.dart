import 'package:family_hub/core/notifications/domain/notification_type.dart';

final class MorningSummary {
  const MorningSummary({required this.enabled, required this.minutes});

  final bool enabled;
  final int minutes;

  MorningSummary copyWith({bool? enabled, int? minutes}) => MorningSummary(
    enabled: enabled ?? this.enabled,
    minutes: minutes ?? this.minutes,
  );

  @override
  bool operator ==(Object other) =>
      other is MorningSummary &&
      other.enabled == enabled &&
      other.minutes == minutes;

  @override
  int get hashCode => Object.hash(enabled, minutes);
}

final class QuietHours {
  const QuietHours({
    required this.enabled,
    required this.startMinutes,
    required this.endMinutes,
  });

  final bool enabled;
  final int startMinutes;
  final int endMinutes;

  bool get isValid =>
      startMinutes >= 0 &&
      startMinutes < 1440 &&
      endMinutes >= 0 &&
      endMinutes < 1440 &&
      startMinutes != endMinutes;

  QuietHours copyWith({bool? enabled, int? startMinutes, int? endMinutes}) =>
      QuietHours(
        enabled: enabled ?? this.enabled,
        startMinutes: startMinutes ?? this.startMinutes,
        endMinutes: endMinutes ?? this.endMinutes,
      );

  @override
  bool operator ==(Object other) =>
      other is QuietHours &&
      other.enabled == enabled &&
      other.startMinutes == startMinutes &&
      other.endMinutes == endMinutes;

  @override
  int get hashCode => Object.hash(enabled, startMinutes, endMinutes);
}

final class ReminderSettings {
  factory ReminderSettings({
    bool? globalEnabled,
    bool? choresEnabled,
    bool? bazarEnabled,
    bool? familyEnabled,
    List<int>? defaultOffsetsMinutes,
    bool? atDue,
    bool? overdueEnabled,
    int? overdueAfterMinutes,
    bool? morningSummaryEnabled,
    int? morningSummaryMinutes,
    bool? quietEnabled,
    int? quietStartMinutes,
    int? quietEndMinutes,
  }) => ReminderSettings._(
    globalEnabled,
    choresEnabled,
    bazarEnabled,
    familyEnabled,
    defaultOffsetsMinutes,
    atDue,
    overdueEnabled,
    overdueAfterMinutes,
    morningSummaryEnabled,
    morningSummaryMinutes,
    quietEnabled,
    quietStartMinutes,
    quietEndMinutes,
  );

  ReminderSettings._(
    this._globalEnabled,
    this._choresEnabled,
    this._bazarEnabled,
    this._familyEnabled,
    List<int>? defaultOffsetsMinutes,
    this._atDue,
    this._overdueEnabled,
    this._overdueAfterMinutes,
    this._morningSummaryEnabled,
    this._morningSummaryMinutes,
    this._quietEnabled,
    this._quietStartMinutes,
    this._quietEndMinutes,
  ) : _defaultOffsetsMinutes = defaultOffsetsMinutes == null
          ? null
          : List<int>.unmodifiable(defaultOffsetsMinutes);

  static const int eveningNudgeMinutes = 1140;
  static const int defaultOverdueAfterMinutes = 60;
  static const int defaultMorningSummaryMinutes = 420;
  static const int defaultQuietStartMinutes = 1380;
  static const int defaultQuietEndMinutes = 360;
  static const List<int> recommendedOffsetsMinutes = <int>[30];

  static ReminderSettings defaults() => ReminderSettings();

  final bool? _globalEnabled;
  final bool? _choresEnabled;
  final bool? _bazarEnabled;
  final bool? _familyEnabled;
  final List<int>? _defaultOffsetsMinutes;
  final bool? _atDue;
  final bool? _overdueEnabled;
  final int? _overdueAfterMinutes;
  final bool? _morningSummaryEnabled;
  final int? _morningSummaryMinutes;
  final bool? _quietEnabled;
  final int? _quietStartMinutes;
  final int? _quietEndMinutes;

  bool get globalEnabled => _globalEnabled ?? true;
  bool get choresEnabled => _choresEnabled ?? true;
  bool get bazarEnabled => _bazarEnabled ?? true;
  bool get familyEnabled => _familyEnabled ?? true;
  List<int> get defaultOffsetsMinutes =>
      _defaultOffsetsMinutes ?? recommendedOffsetsMinutes;
  bool? get globalEnabledOverride => _globalEnabled;
  bool? get choresEnabledOverride => _choresEnabled;
  bool? get bazarEnabledOverride => _bazarEnabled;
  bool? get familyEnabledOverride => _familyEnabled;
  List<int>? get defaultOffsetsMinutesOverride => _defaultOffsetsMinutes;
  bool get atDue => _atDue ?? true;
  bool? get atDueOverride => _atDue;
  bool get overdueEnabled => _overdueEnabled ?? false;
  bool? get overdueEnabledOverride => _overdueEnabled;
  int get overdueAfterMinutes =>
      _overdueAfterMinutes ?? defaultOverdueAfterMinutes;
  int? get overdueAfterMinutesOverride => _overdueAfterMinutes;
  bool? get morningSummaryEnabledOverride => _morningSummaryEnabled;
  int? get morningSummaryMinutesOverride => _morningSummaryMinutes;
  bool? get quietEnabledOverride => _quietEnabled;
  int? get quietStartMinutesOverride => _quietStartMinutes;
  int? get quietEndMinutesOverride => _quietEndMinutes;

  MorningSummary get morningSummary => MorningSummary(
    enabled: _morningSummaryEnabled ?? true,
    minutes: _morningSummaryMinutes ?? defaultMorningSummaryMinutes,
  );

  QuietHours get quiet => QuietHours(
    enabled: _quietEnabled ?? true,
    startMinutes: _quietStartMinutes ?? defaultQuietStartMinutes,
    endMinutes: _quietEndMinutes ?? defaultQuietEndMinutes,
  );

  bool categoryEnabled(NotificationCategory category) => switch (category) {
    NotificationCategory.chores => choresEnabled,
    NotificationCategory.bazar => bazarEnabled,
    NotificationCategory.family => familyEnabled,
  };

  ReminderSettings inheritFrom(ReminderSettings familyDefaults) =>
      ReminderSettings(
        globalEnabled: _globalEnabled ?? familyDefaults.globalEnabled,
        choresEnabled: _choresEnabled ?? familyDefaults.choresEnabled,
        bazarEnabled: _bazarEnabled ?? familyDefaults.bazarEnabled,
        familyEnabled: _familyEnabled ?? familyDefaults.familyEnabled,
        defaultOffsetsMinutes:
            _defaultOffsetsMinutes ?? familyDefaults.defaultOffsetsMinutes,
        atDue: _atDue ?? familyDefaults.atDue,
        overdueEnabled: _overdueEnabled ?? familyDefaults.overdueEnabled,
        overdueAfterMinutes:
            _overdueAfterMinutes ?? familyDefaults.overdueAfterMinutes,
        morningSummaryEnabled:
            _morningSummaryEnabled ?? familyDefaults.morningSummary.enabled,
        morningSummaryMinutes:
            _morningSummaryMinutes ?? familyDefaults.morningSummary.minutes,
        quietEnabled: _quietEnabled ?? familyDefaults.quiet.enabled,
        quietStartMinutes:
            _quietStartMinutes ?? familyDefaults.quiet.startMinutes,
        quietEndMinutes: _quietEndMinutes ?? familyDefaults.quiet.endMinutes,
      );

  ReminderSettings copyWith({
    bool? globalEnabled,
    bool? choresEnabled,
    bool? bazarEnabled,
    bool? familyEnabled,
    List<int>? defaultOffsetsMinutes,
    bool? atDue,
    bool? overdueEnabled,
    int? overdueAfterMinutes,
    bool? morningSummaryEnabled,
    int? morningSummaryMinutes,
    bool? quietEnabled,
    int? quietStartMinutes,
    int? quietEndMinutes,
  }) => ReminderSettings(
    globalEnabled: globalEnabled ?? _globalEnabled,
    choresEnabled: choresEnabled ?? _choresEnabled,
    bazarEnabled: bazarEnabled ?? _bazarEnabled,
    familyEnabled: familyEnabled ?? _familyEnabled,
    defaultOffsetsMinutes: defaultOffsetsMinutes ?? _defaultOffsetsMinutes,
    atDue: atDue ?? _atDue,
    overdueEnabled: overdueEnabled ?? _overdueEnabled,
    overdueAfterMinutes: overdueAfterMinutes ?? _overdueAfterMinutes,
    morningSummaryEnabled: morningSummaryEnabled ?? _morningSummaryEnabled,
    morningSummaryMinutes: morningSummaryMinutes ?? _morningSummaryMinutes,
    quietEnabled: quietEnabled ?? _quietEnabled,
    quietStartMinutes: quietStartMinutes ?? _quietStartMinutes,
    quietEndMinutes: quietEndMinutes ?? _quietEndMinutes,
  );

  @override
  bool operator ==(Object other) =>
      other is ReminderSettings &&
      other.globalEnabled == globalEnabled &&
      other.choresEnabled == choresEnabled &&
      other.bazarEnabled == bazarEnabled &&
      other.familyEnabled == familyEnabled &&
      _sameList(other.defaultOffsetsMinutes, defaultOffsetsMinutes) &&
      other.atDue == atDue &&
      other.overdueEnabled == overdueEnabled &&
      other.overdueAfterMinutes == overdueAfterMinutes &&
      other.morningSummary == morningSummary &&
      other.quiet == quiet;

  @override
  int get hashCode => Object.hash(
    globalEnabled,
    choresEnabled,
    bazarEnabled,
    familyEnabled,
    Object.hashAll(defaultOffsetsMinutes),
    atDue,
    overdueEnabled,
    overdueAfterMinutes,
    morningSummary,
    quiet,
  );
}

bool _sameList(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) return false;
  }
  return true;
}
