/// Makes a name comparable for the calendar search (Appendix B.4).
///
/// Lower-cases Latin letters, removes the zero-width joiner and non-joiner
/// that Bangla keyboards insert inconsistently (so "র‍্যাক" matches "র্যাক"),
/// and collapses every run of whitespace to one space. Pure; no locale data.
String normalizeBn(String input) {
  final cleaned = StringBuffer();
  for (final unit in input.runes) {
    // U+200C zero-width non-joiner, U+200D zero-width joiner, U+FEFF BOM.
    if (unit == 0x200C || unit == 0x200D || unit == 0xFEFF) continue;
    cleaned.writeCharCode(unit);
  }
  return cleaned.toString().toLowerCase().trim().replaceAll(
    RegExp(r'\s+'),
    ' ',
  );
}
