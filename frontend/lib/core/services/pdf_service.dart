import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../shared/models/diagnosis_record.dart';
import '../../shared/models/health_insight.dart';
import '../utils/report_formatter.dart';
import '../../shared/models/user_health_profile.dart';
import '../../shared/models/user_profile.dart';

class PdfService {
  /// Full report (existing behaviour).
  Future<void> exportInsight({
    required UserProfile profile,
    required HealthInsight insight,
    required Map<String, String> labels,
    UserHealthProfile? healthProfile,
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(labels['title'] ?? 'Masika',
                  style: pw.TextStyle(fontSize: 22)),
              pw.SizedBox(height: 12),
              pw.Text('${labels['name']}: ${profile.name}'),
              pw.Text('${labels['age']}: ${profile.age}'),
              pw.Text(
                  '${labels['cycle_length']}: ${profile.cycleLength} ${labels['days']}'),
              pw.Text(
                  '${labels['period_duration']}: ${profile.periodDuration} ${labels['days']}'),
              if (healthProfile != null) ...[
                pw.Text('Flow: ${healthProfile.flowRate} · Pain: ${healthProfile.painDuringPeriod ? "Yes" : "No"} · Pads/day: ${healthProfile.padsPerDay}'),
              ],
              pw.SizedBox(height: 16),
              pw.Text(labels['summary'] ?? 'Summary',
                  style: pw.TextStyle(fontSize: 16)),
              pw.Text(insight.summary),
              pw.SizedBox(height: 12),
              pw.Text(labels['possible_causes'] ?? 'Possible causes',
                  style: pw.TextStyle(fontSize: 16)),
              pw.Bullet(text: insight.possibleCauses.join(', ')),
              pw.SizedBox(height: 12),
              pw.Text(labels['what_this_means'] ?? 'What this means',
                  style: pw.TextStyle(fontSize: 16)),
              pw.Text(insight.whatThisMeans),
              pw.SizedBox(height: 12),
              pw.Text(labels['what_to_do'] ?? 'What to do',
                  style: pw.TextStyle(fontSize: 16)),
              pw.Text(insight.whatToDo),
              pw.SizedBox(height: 12),
              pw.Text(labels['when_to_consult'] ?? 'When to consult doctor',
                  style: pw.TextStyle(fontSize: 16)),
              pw.Text(insight.whenToConsult),
              pw.SizedBox(height: 12),
              pw.Text(insight.disclaimer),
            ],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  /// Summarized one-page report using profile and optional health profile. Used for reports.
  Future<void> exportInsightSummarized({
    required UserProfile profile,
    required HealthInsight insight,
    required Map<String, String> labels,
    UserHealthProfile? healthProfile,
  }) async {
    final doc = pw.Document();
    final small = pw.TextStyle(fontSize: 9);
    final bold = pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(labels['title'] ?? 'Masika Health Report',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('${labels['name']}: ${profile.name}  ·  ${labels['age']}: ${profile.age}',
                style: small),
            pw.Text(
                '${labels['cycle_length']}: ${profile.cycleLength} ${labels['days']}  ·  ${labels['period_duration']}: ${profile.periodDuration} ${labels['days']}',
                style: small),
            if (healthProfile != null)
              pw.Text(
                  'Flow: ${healthProfile.flowRate}  ·  Pain: ${healthProfile.painDuringPeriod ? "Yes" : "No"}  ·  Pads/day: ${healthProfile.padsPerDay}  ·  Weakness: ${healthProfile.weaknessLevel}',
                  style: small),
            pw.SizedBox(height: 14),
            pw.Text(labels['summary'] ?? 'Summary', style: bold),
            pw.SizedBox(height: 4),
            pw.Text(_truncate(insight.summary, 320), style: small),
            pw.SizedBox(height: 10),
            pw.Text(labels['possible_causes'] ?? 'Key points', style: bold),
            pw.SizedBox(height: 2),
            pw.Bullet(text: insight.possibleCauses.take(3).join(' · '), style: small),
            pw.SizedBox(height: 6),
            pw.Text(labels['what_to_do'] ?? 'What to do', style: bold),
            pw.SizedBox(height: 2),
            pw.Text(_truncate(insight.whatToDo, 280), style: small),
            pw.SizedBox(height: 10),
            pw.Text(labels['when_to_consult'] ?? 'When to consult', style: bold),
            pw.SizedBox(height: 2),
            pw.Text(_truncate(insight.whenToConsult, 220), style: small),
            pw.SizedBox(height: 8),
            pw.Text(_truncate(insight.disclaimer, 180), style: small),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  static String _truncate(String s, int maxLen) {
    if (s.length <= maxLen) return s;
    return '${s.substring(0, maxLen).trim()}...';
  }

  /// AI Diagnosis report PDF: Masika Private Limited header, app name, result, inputs, wellness report.
  Future<void> exportDiagnosisReport(DiagnosisRecord record) async {
    const titleFont = pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold);
    const headingFont = pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold);
    const bodyFont = pw.TextStyle(fontSize: 10);
    const smallFont = pw.TextStyle(fontSize: 9);

    final dateStr = record.createdAt != null
        ? DateFormat('MMM d, yyyy · h:mm a').format(record.createdAt!)
        : DateFormat('MMM d, yyyy').format(DateTime.now());

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        header: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Masika Private Limited', style: titleFont),
              pw.SizedBox(height: 2),
              pw.Text('Masika — Wellness & Health Insights', style: smallFont),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1),
            ],
          ),
        ),
        footer: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 12),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Divider(thickness: 0.5),
              pw.SizedBox(height: 4),
              pw.Text(
                'This report is for informational purposes only and does not replace professional medical advice.',
                style: smallFont,
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.Text('AI Diagnosis Report', style: titleFont),
          pw.SizedBox(height: 4),
          pw.Text(dateStr, style: smallFont),
          pw.SizedBox(height: 20),
          pw.Text('Result', style: headingFont),
          pw.SizedBox(height: 6),
          pw.Text(record.prediction, style: bodyFont),
          if (record.probabilities != null && record.probabilities!.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            ...record.probabilities!.entries.map(
              (e) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 4),
                child: pw.Text(
                  '${e.key}: ${(e.value * 100).toStringAsFixed(1)}%',
                  style: bodyFont,
                ),
              ),
            ),
          ],
          pw.SizedBox(height: 20),
          if (record.inputData.isNotEmpty) ...[
            pw.Text('Input summary', style: headingFont),
            pw.SizedBox(height: 6),
            ...record.inputData.entries
                .where((e) => e.value != null && e.value.toString().trim().isNotEmpty)
                .map(
                  (e) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(
                      '${_labelKey(e.key)}: ${e.value}',
                      style: bodyFont,
                    ),
                  ),
                ),
            pw.SizedBox(height: 20),
          ],
          if (record.report != null && record.report!.trim().isNotEmpty) ...[
            pw.Text('Wellness report', style: headingFont),
            pw.SizedBox(height: 6),
            ...ReportFormatter.parseReport(record.report!).map(
              (seg) => pw.Text(
                seg.text.isEmpty ? ' ' : seg.text,
                style: seg.isBold ? headingFont : bodyFont,
              ),
            ),
          ],
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  static String _labelKey(String key) {
    final k = key.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (m) => ' ${m.group(0)!.toLowerCase()}',
    );
    return k.isEmpty ? key : k.trim();
  }
}
