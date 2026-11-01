import 'package:family_hub/features/chores/availability/domain/availability_index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Who is away on which day (D-P3-12).
///
/// Empty until P3-26 builds it from `memberAvailability`; the calendar, the
/// projection and the chore items already read it, so an absence will reach
/// every screen the moment this provider returns a real index. P3-26 replaces
/// the body of this one provider (and nothing else needs to change).
final availabilityIndexProvider = Provider<AvailabilityIndex>(
  (ref) => AvailabilityIndex.empty,
);
