import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/utils/date_key.dart';

/// The deterministic id of one occurrence (D-P3-3, D-P3-5):
///
/// * `{templateId}_{yyyyMMdd}` for the template's `main` slot;
/// * `{templateId}_{yyyyMMdd}_{slotKey}` for every other slot.
///
/// A random id would let two devices create the same chore twice, so the id is
/// always rebuilt from its parts. [parse] is the inverse and is what the rules
/// mirror with their id pattern.
final class OccurrenceId {
  const OccurrenceId._({
    required this.templateId,
    required this.dateKey,
    required this.slotKey,
  });

  /// Builds the id for one (template, day, slot).
  ///
  /// [slotKey] is null (or `main`) for the template's first slot, which has no
  /// suffix; any other key must be `[a-z0-9]{1,12}`.
  factory OccurrenceId.of(
    String templateId,
    DateKey dateKey, {
    String? slotKey,
  }) {
    final normalized = slotKey == null || slotKey == 'main' ? null : slotKey;
    assert(templateId.isNotEmpty, 'a template id is required');
    assert(
      normalized == null || _slotPattern.hasMatch(normalized),
      'invalid slot key "$normalized"',
    );
    return OccurrenceId._(
      templateId: templateId,
      dateKey: dateKey,
      slotKey: normalized,
    );
  }

  static final RegExp _slotPattern = RegExp(r'^[a-z0-9]{1,12}$');
  static final RegExp _datePattern = RegExp(r'^\d{8}$');

  final String templateId;
  final DateKey dateKey;

  /// null for the `main` slot.
  final String? slotKey;

  /// The document id (`choreOccurrences/{value}`).
  String get value => slotKey == null
      ? '${templateId}_${dateKey.compact}'
      : '${templateId}_${dateKey.compact}_$slotKey';

  /// Reads an id back. The template id may itself contain underscores (the
  /// starter pack uses `tpl_dishes`), so the date and slot are taken from the
  /// END of the string, never by a left-to-right split.
  static Result<OccurrenceId> parse(String raw) {
    final parts = raw.split('_');
    if (parts.length < 2 || raw.isEmpty) {
      return const Failure<OccurrenceId>(
        Validation('occurrenceId', 'required'),
      );
    }

    final String datePart;
    String? slot;
    int templateParts;
    if (_datePattern.hasMatch(parts.last)) {
      datePart = parts.last;
      templateParts = parts.length - 1;
    } else {
      if (parts.length < 3) {
        return const Failure<OccurrenceId>(
          Validation('occurrenceId', 'required'),
        );
      }
      slot = parts.last;
      datePart = parts[parts.length - 2];
      templateParts = parts.length - 2;
      if (!_slotPattern.hasMatch(slot)) {
        return const Failure<OccurrenceId>(
          Validation('occurrenceId', 'required'),
        );
      }
      // `main` is canonical without a suffix; accepting the suffix on read
      // keeps a document written by a buggy/older build visible.
      if (slot == 'main') slot = null;
    }
    if (!_datePattern.hasMatch(datePart) || templateParts == 0) {
      return const Failure<OccurrenceId>(
        Validation('occurrenceId', 'required'),
      );
    }

    final templateId = parts.take(templateParts).join('_');
    if (templateId.isEmpty) {
      return const Failure<OccurrenceId>(
        Validation('occurrenceId', 'required'),
      );
    }
    final day = DateKey.parse(
      '${datePart.substring(0, 4)}-${datePart.substring(4, 6)}-'
      '${datePart.substring(6)}',
    );
    final failure = day.failureOrNull;
    if (failure != null) return Failure<OccurrenceId>(failure);

    return Success<OccurrenceId>(
      OccurrenceId._(
        templateId: templateId,
        dateKey: day.valueOrNull!,
        slotKey: slot,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is OccurrenceId &&
      other.templateId == templateId &&
      other.dateKey == dateKey &&
      other.slotKey == slotKey;

  @override
  int get hashCode => Object.hash(templateId, dateKey, slotKey);

  @override
  String toString() => 'OccurrenceId($value)';
}
