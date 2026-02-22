import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/utils/report_formatter.dart';
import '../../../../shared/models/diagnosis_record.dart';
import '../../../../shared/providers/app_providers.dart';

/// Full-page output of an AI analysis: prediction, probabilities, and input summary.
/// Shown after "Analyze Data" or when opening a record from Analysis History.
class AnalysisResultScreen extends ConsumerWidget {
  const AnalysisResultScreen({
    super.key,
    required this.record,
    this.showInputSummary = true,
  });

  final DiagnosisRecord record;
  final bool showInputSummary;

  static const _maroon = Color(0xFF6A1A21);
  static const _bg = Color(0xFFF8F7F5);
  static const _labelGray = Color(0xFF4B4B4B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNormal = record.prediction.toUpperCase() == 'NORMAL';
    final dateStr = record.createdAt != null
        ? DateFormat('MMM d, yyyy · h:mm a').format(record.createdAt!)
        : null;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: _maroon),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Analysis Result',
          style: AppTypography.screenTitle.copyWith(color: AppColors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            if (dateStr != null) ...[
              Center(
                child: Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 13,
                    color: _labelGray.withValues(alpha: 0.9),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            _ResultCard(
              prediction: record.prediction,
              probabilities: record.probabilities,
              isNormal: isNormal,
            ),
            const SizedBox(height: 24),
            if (record.probabilities != null && record.probabilities!.isNotEmpty) ...[
              _SectionTitle(title: 'Probabilities'),
              const SizedBox(height: 8),
              _ProbabilitiesCard(probabilities: record.probabilities!),
              const SizedBox(height: 24),
            ],
            if (showInputSummary && record.inputData.isNotEmpty) ...[
              _SectionTitle(title: 'Input summary'),
              const SizedBox(height: 8),
              _InputSummaryCard(inputData: record.inputData),
              const SizedBox(height: 24),
            ],
            if (record.report != null && record.report!.trim().isNotEmpty) ...[
              _SectionTitle(title: 'Wellness report'),
              const SizedBox(height: 8),
              _ReportCard(reportText: record.report!),
              const SizedBox(height: 24),
            ],
            _DownloadPdfButton(record: record),
            const SizedBox(height: 12),
            _SaveReportButton(record: record),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTypography.screenTitle.copyWith(
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.prediction,
    required this.probabilities,
    required this.isNormal,
  });

  final String prediction;
  final Map<String, double>? probabilities;
  final bool isNormal;

  static const _maroon = Color(0xFF6A1A21);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isNormal ? Icons.check_circle_rounded : Icons.info_rounded,
            size: 56,
            color: isNormal ? AppColors.success : _maroon,
          ),
          const SizedBox(height: 16),
          Text(
            'Result',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _labelGray,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            prediction,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isNormal ? AppColors.success : _maroon,
            ),
          ),
          if (probabilities != null && probabilities!.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...probabilities!.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _labelGray,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(e.value * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isNormal && e.key.toUpperCase() == 'NORMAL'
                            ? AppColors.success
                            : _maroon,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

const _cardBg = Color(0xFFFFFFFF);
const _labelGray = Color(0xFF4B4B4B);

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.reportText});

  final String reportText;

  static const _valueColor = Color(0xFF2B2B2B);

  @override
  Widget build(BuildContext context) {
    final segments = ReportFormatter.parseReport(reportText);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SelectableText.rich(
        TextSpan(
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w500,
            color: _valueColor,
          ),
          children: [
            for (final seg in segments)
              TextSpan(
                text: seg.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: seg.isBold ? FontWeight.w700 : FontWeight.w500,
                  color: _valueColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DownloadPdfButton extends StatelessWidget {
  const _DownloadPdfButton({required this.record});

  final DiagnosisRecord record;

  static const _maroon = Color(0xFF6A1A21);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          try {
            await PdfService().exportDiagnosisReport(record);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF ready to save or share'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Could not generate PDF: $e'),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.download_rounded, size: 20, color: _maroon),
        label: const Text(
          'Download PDF report',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _maroon),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: _maroon),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _SaveReportButton extends ConsumerWidget {
  const _SaveReportButton({required this.record});

  final DiagnosisRecord record;

  static const _maroon = Color(0xFF6A1A21);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ref.read(savedReportsProvider.notifier).addReport(record);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Report saved. View it in Profile → Reports.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        icon: const Icon(Icons.save_rounded, size: 20, color: _maroon),
        label: const Text(
          'Save to reports',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _maroon),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: _maroon),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _ProbabilitiesCard extends StatelessWidget {
  const _ProbabilitiesCard({required this.probabilities});

  final Map<String, double> probabilities;

  static const _maroon = Color(0xFF6A1A21);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: probabilities.entries
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _labelGray,
                        ),
                      ),
                    ),
                    Text(
                      '${(e.value * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _maroon,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _InputSummaryCard extends StatelessWidget {
  const _InputSummaryCard({required this.inputData});

  final Map<String, dynamic> inputData;

  static const _labelGray = Color(0xFF4B4B4B);
  static const _valueColor = Color(0xFF6A1A21);

  @override
  Widget build(BuildContext context) {
    final entries = inputData.entries
        .where((e) => e.value != null && e.value.toString().trim().isNotEmpty)
        .toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    String label(String key) {
      final k = key.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (m) => ' ${m.group(0)!.toLowerCase()}',
      );
      return k.isEmpty ? key : k.trim();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        label(e.key),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _labelGray,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        e.value.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _valueColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
