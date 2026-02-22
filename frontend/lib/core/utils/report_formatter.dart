/// Utilities to turn raw wellness report text into plain, structured output.
/// Strips all Markdown (**, #, -, *) so only plain text is shown; headings = bold, rest = normal.
class ReportFormatter {
  ReportFormatter._();

  /// Remove all markdown so only plain text remains. No asterisks, bullets, or hashes.
  static String stripMarkdown(String text) {
    if (text.isEmpty) return text;
    String s = text;
    // Bold: **text** or __text__
    s = s.replaceAllMapped(RegExp(r'\*\*([^*]*)\*\*'), (m) => m.group(1) ?? '');
    s = s.replaceAllMapped(RegExp(r'__([^_]*)__'), (m) => m.group(1) ?? '');
    // Italic/single asterisk: *text*
    s = s.replaceAllMapped(RegExp(r'\*([^*]*)\*'), (m) => m.group(1) ?? '');
    s = s.replaceAllMapped(RegExp(r'_([^_\s][^_]*)_'), (m) => m.group(1) ?? '');
    // Headings: # ## ### at start of line
    s = s.replaceAll(RegExp(r'^#+\s*', multiLine: true), '');
    // Stray asterisks/underscores (e.g. left over from malformed **)
    s = s.replaceAll(RegExp(r'\*+'), '');
    s = s.replaceAll(RegExp(r'_+'), ' ');
    return s.trim();
  }

  /// Strip leading bullet or number from a line so it's plain text.
  static String _stripLinePrefix(String trimmed) {
    // Leading "- " or "* " (bullet)
    String line = trimmed.replaceFirst(RegExp(r'^[-*]\s+'), '');
    // Leading "1. " "2. " etc (numbered list)
    line = line.replaceFirst(RegExp(r'^\d+\.\s+'), '');
    return line.trim();
  }

  /// Parse report into segments: headings (bold) and body (normal). Output is plain text only.
  static List<ReportSegment> parseReport(String rawReport) {
    final String plain = stripMarkdown(rawReport);
    final List<ReportSegment> segments = [];
    for (final line in plain.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        segments.add(const ReportSegment(text: '\n', isBold: false));
        continue;
      }
      final noBullet = _stripLinePrefix(trimmed);
      // Only short lines ending with colon are treated as section headings (bold).
      final isHeader = noBullet.endsWith(':') && noBullet.length <= 60;
      final displayText = noBullet.isEmpty ? trimmed : noBullet;
      segments.add(ReportSegment(
        text: (displayText.isEmpty ? ' ' : displayText) + '\n',
        isBold: isHeader,
      ));
    }
    return segments;
  }
}

class ReportSegment {
  const ReportSegment({required this.text, required this.isBold});
  final String text;
  final bool isBold;
}
