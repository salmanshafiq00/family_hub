/// The STORED status of an occurrence (`choreOccurrences.status`).
///
/// `overdue` is deliberately absent: a missed deadline is derived from `dueAt`
/// and never written (D-P3-9), so the stored value cannot disagree with the
/// clock. [ChoreStatus] is what a screen shows.
enum OccurrenceStatus {
  scheduled('scheduled'),
  inProgress('in_progress'),
  completed('completed'),
  verified('verified'),
  skipped('skipped');

  const OccurrenceStatus(this.id);

  /// The stored string, mirrored by the P3-13 rules.
  final String id;

  /// Tolerant read: an unknown stored value is `scheduled`, so a document
  /// written by a newer build never crashes an older one.
  static OccurrenceStatus fromId(Object? id) {
    for (final status in values) {
      if (status.id == id) return status;
    }
    return OccurrenceStatus.scheduled;
  }
}

/// What the UI shows: the stored status plus the DERIVED `overdue`.
///
/// Every screen reads [ChoreStatus], never `occurrence.status`, so a stale
/// stored `completed` can never contradict the ticks the user sees.
enum ChoreStatus {
  scheduled('scheduled'),
  inProgress('in_progress'),
  completed('completed'),
  verified('verified'),
  skipped('skipped'),
  overdue('overdue');

  const ChoreStatus(this.id);

  /// Stable machine id (the l10n key is derived from it).
  final String id;

  /// Maps a stored status to its display status (never overdue).
  static ChoreStatus fromStored(OccurrenceStatus status) => switch (status) {
    OccurrenceStatus.scheduled => ChoreStatus.scheduled,
    OccurrenceStatus.inProgress => ChoreStatus.inProgress,
    OccurrenceStatus.completed => ChoreStatus.completed,
    OccurrenceStatus.verified => ChoreStatus.verified,
    OccurrenceStatus.skipped => ChoreStatus.skipped,
  };

  /// True for the two statuses a deadline can make overdue.
  bool get isOpen =>
      this == ChoreStatus.scheduled || this == ChoreStatus.inProgress;
}
