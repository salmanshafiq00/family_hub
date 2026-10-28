import 'package:family_hub/core/localization/generated/app_localizations.dart';
import 'package:family_hub/core/permissions/permission.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One tile on the "Manage chores" hub.
///
/// Same shape as `BazarEntry`: every later Phase 3 step appends one entry and
/// the hub renders this list, hiding a tile when the viewer lacks [requires]
/// (H7, never a role test).  No copy lives here: labels are resolved by the
/// screen from [AppLocalizations].
class ChoresEntry {
  const ChoresEntry({
    required this.id,
    required this.icon,
    required this.title,
    required this.route,
    this.subtitle,
    this.requires,
    this.badge,
  });

  /// Stable id, used by tests; never shown.
  final String id;

  final IconData icon;

  /// Localized title.
  final String Function(AppLocalizations) title;

  /// Optional localized second line.
  final String Function(AppLocalizations)? subtitle;

  /// Absolute route, e.g. `AppRoutes.choresTemplates`.
  final String route;

  /// Permission the viewer needs to see this tile; `null` = everybody.
  final Permission? requires;

  /// Optional count shown on the tile (for example open verifications).  A
  /// value of zero shows nothing.
  final Provider<int>? badge;
}

/// The Manage hub tiles, in display order.
///
/// Empty on purpose: P3-01 only lays the seam.  Each step appends one entry
/// (templates P3-16, settings P3-17, duty groups P3-18, ...); keep the order
/// of the roadmap's route table (section 3.10).
final List<ChoresEntry> choresEntries = <ChoresEntry>[];
