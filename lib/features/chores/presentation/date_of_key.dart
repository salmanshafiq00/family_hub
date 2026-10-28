import 'package:family_hub/core/utils/date_key.dart';

/// A `DateKey` as a `DateTime` at UTC midnight, so `AppFormatters.fullDate`
/// can name it without the phone's zone shifting the day.
DateTime dateOfKey(DateKey key) => DateTime.utc(key.year, key.month, key.day);

/// The family's today as a UTC-midnight `DateTime` (the header compares days).
DateTime todayOf(DateKey today) => dateOfKey(today);
