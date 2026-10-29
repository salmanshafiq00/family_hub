import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:flutter/material.dart';

/// Asks for a reason in one shared sheet, so every Phase 3 flow validates it
/// the same way (D-P3-17, CLAUDE.md rule 40).
///
/// [options], when given, are an optional checklist above the text field.  It
/// is returned instead of the text (see [showReasonChecklistSheet], B-04).
///
/// Returns the trimmed text when the user confirms, or `null` when the sheet is
/// dismissed (including the system back gesture) — the caller must treat
/// `null` as "no action", never as an empty reason.
///
/// Validation: 3–300 characters by default (`minLength` / `maxLength`). With
/// `required: false` an empty field is accepted and returned as `''`;
/// otherwise the confirm button stays disabled until the text is long enough,
/// and the message that explains why is shown as soon as the user types
/// something too short.
Future<String?> showReasonSheet(
  BuildContext context, {
  required String title,
  String? hint,
  int minLength = 3,
  int maxLength = 300,
  bool required = true,
  String? initialText,
}) {
  assert(minLength >= 0, 'minLength must not be negative');
  assert(maxLength >= minLength, 'maxLength must not be below minLength');
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) => _ReasonSheet(
      title: title,
      hint: hint,
      minLength: minLength,
      maxLength: maxLength,
      required: required,
      initialText: initialText,
    ),
  );
}

class _ReasonSheet extends StatefulWidget {
  const _ReasonSheet({
    required this.title,
    required this.hint,
    required this.minLength,
    required this.maxLength,
    required this.required,
    required this.initialText,
    this.checklist,
  });

  final String title;
  final String? hint;
  final int minLength;
  final int maxLength;
  final bool required;
  final String? initialText;

  /// The steps the person may tick to redo (B-04); null for a plain reason.
  final ChecklistSpec? checklist;

  @override
  State<_ReasonSheet> createState() => _ReasonSheetState();
}

/// A reason PLUS a checklist of steps to redo (B-04, road map Appendix C).
///
/// The person picks which of the steps that were done have to be done again;
/// the same choice is then unticked in the reopen patch.  Returns `null` when
/// the sheet is dismissed.
Future<({String reason, List<String> stepIds})?> showReasonChecklistSheet(
  BuildContext context, {
  required String title,
  required String checklistTitle,
  required String hint,
  required List<String> options,
  required List<bool> selected,
}) => showModalBottomSheet<({String reason, List<String> stepIds})>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (sheetContext) => _ReasonSheet(
    title: title,
    hint: null,
    minLength: 3,
    maxLength: 300,
    required: true,
    initialText: null,
    checklist: ChecklistSpec(
      title: checklistTitle,
      hint: hint,
      options: <String>[...options],
      selected: <bool>[for (final flag in selected) flag],
    ),
  ),
);

/// The optional checklist of [_ReasonSheet].
final class ChecklistSpec {
  const ChecklistSpec({
    required this.title,
    required this.hint,
    required this.options,
    required this.selected,
  });

  final String title;
  final String hint;
  final List<String> options;
  final List<bool> selected;
}

class _ReasonSheetState extends State<_ReasonSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialText,
  );
  late final List<bool> _checked = <bool>[...?widget.checklist?.selected];
  bool _touched = false;

  /// What the sheet answers: the reason; `stepIds` is empty without a
  /// checklist, so a plain reason still comes back as a record (the result
  /// type never varies between the two sheets).
  ({String reason, List<String> stepIds}) _sheetResult() => (
    reason: _trimmed,
    stepIds: _pickedSteps,
  );

  /// The steps picked (in the order the sheet listed them).
  List<String> get _pickedSteps {
    final checklist = widget.checklist;
    if (checklist == null) return const <String>[];
    return <String>[
      for (var i = 0; i < checklist.options.length; i++)
        if (i < _checked.length && _checked[i]) checklist.options[i],
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _trimmed => _controller.text.trim();

  bool get _valid =>
      _trimmed.length >= widget.minLength ||
      (!widget.required && _trimmed.isEmpty);

  String? get _error {
    if (!_touched || _valid) return null;
    return context.l10n.reasonSheetTooShort(widget.minLength);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final insets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + insets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
          if (widget.checklist != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              widget.checklist!.title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              widget.checklist!.hint,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: tokens.textSecondary),
            ),
            const SizedBox(height: 4),
            for (var i = 0; i < widget.checklist!.options.length; i++)
              CheckboxListTile(
                value: i < _checked.length && _checked[i],
                onChanged: (value) =>
                    setState(() => _checked[i] = value ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(widget.checklist!.options[i]),
              ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            // With a checklist the user reads it first: no keyboard popping
            // up over the steps.
            autofocus: widget.checklist == null,
            minLines: 3,
            maxLines: 6,
            maxLength: widget.maxLength,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: widget.hint ?? l10n.reasonSheetHint,
              errorText: _error,
            ),
            onChanged: (_) => setState(() => _touched = true),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.actionCancel),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  backgroundColor: tokens.accent,
                  foregroundColor: tokens.textOnAccent,
                ),
                onPressed: _valid
                    ? () => Navigator.of(context).pop<Object?>(_sheetResult())
                    : null,
                child: Text(l10n.actionSave),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
