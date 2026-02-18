import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/ai_insight_service.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../shared/models/health_insight.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/primary_button.dart';

class HealthInsightScreen extends ConsumerStatefulWidget {
  const HealthInsightScreen({super.key});

  @override
  ConsumerState<HealthInsightScreen> createState() =>
      _HealthInsightScreenState();
}

class _HealthInsightScreenState extends ConsumerState<HealthInsightScreen> {
  final _hbController = TextEditingController();
  HealthInsight? _insight;

  @override
  void dispose() {
    _hbController.dispose();
    super.dispose();
  }

  void _generate() {
    final profile = ref.read(userProfileProvider);
    if (profile == null) return;
    final healthProfile = ref.read(healthProfileProvider);
    final cycles = ref.read(cycleLogsProvider);
    final hb = int.tryParse(_hbController.text);
    final t = AppLocalizations.of(context);
    final service = AiInsightService();
    final effectiveProfile = healthProfile != null
        ? profile.copyWith(
            cycleLength: healthProfile.cycleLength,
            periodDuration: healthProfile.periodDuration,
          )
        : profile;
    setState(() {
      _insight = service.generateInsight(
        profile: effectiveProfile,
        cycles: cycles,
        symptoms: cycles.isNotEmpty ? cycles.last.symptoms : [],
        hemoglobin: hb,
        copy: {
          'insight_summary_irregular': t.t('insight_summary_irregular'),
          'insight_summary_normal': t.t('insight_summary_normal'),
          'insight_cause_stress': t.t('insight_cause_stress'),
          'insight_cause_hormonal': t.t('insight_cause_hormonal'),
          'insight_cause_low_iron': t.t('insight_cause_low_iron'),
          'insight_cause_normal': t.t('insight_cause_normal'),
          'insight_what_means': t.t('insight_what_means'),
          'insight_what_to_do': t.t('insight_what_to_do'),
          'insight_when_consult_lowhb': t.t('insight_when_consult_lowhb'),
          'insight_when_consult_default': t.t('insight_when_consult_default'),
          'disclaimer_text': t.t('disclaimer_text'),
          'symptom_severe': t.t('symptom_severe_cramps'),
        },
      );
    });
  }

  Future<void> _exportPdf() async {
    final profile = ref.read(userProfileProvider);
    final healthProfile = ref.read(healthProfileProvider);
    final insight = _insight;
    if (profile == null || insight == null) return;
    final t = AppLocalizations.of(context);
    final effectiveProfile = healthProfile != null
        ? profile.copyWith(
            cycleLength: healthProfile.cycleLength,
            periodDuration: healthProfile.periodDuration,
          )
        : profile;
    await PdfService().exportInsightSummarized(
      profile: effectiveProfile,
      insight: insight,
      healthProfile: healthProfile,
      labels: {
        'title': t.t('report_title'),
        'name': t.t('name'),
        'age': t.t('age'),
        'cycle_length': t.t('cycle_length'),
        'period_duration': t.t('period_duration'),
        'days': t.t('days'),
        'summary': t.t('summary'),
        'possible_causes': t.t('possible_causes'),
        'what_to_do': t.t('what_to_do'),
        'when_to_consult': t.t('when_to_consult'),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.t('health_insights'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.t('hemoglobin_optional')),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _hbController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: t.t('hemoglobin')),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(label: t.t('generate_insight'), onPressed: _generate),
                ],
              ),
            ),
            if (_insight != null)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.t('summary'),
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(_insight!.summary),
                    const SizedBox(height: 12),
                    Text(t.t('possible_causes'),
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(_insight!.possibleCauses.join(', ')),
                    const SizedBox(height: 12),
                    Text(t.t('what_this_means'),
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(_insight!.whatThisMeans),
                    const SizedBox(height: 12),
                    Text(t.t('what_to_do'),
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(_insight!.whatToDo),
                    const SizedBox(height: 12),
                    Text(t.t('when_to_consult'),
                        style: Theme.of(context).textTheme.titleMedium),
                    Text(_insight!.whenToConsult),
                    const SizedBox(height: 12),
                    Text(_insight!.disclaimer),
                    const SizedBox(height: 12),
                    PrimaryButton(label: t.t('export_pdf'), onPressed: _exportPdf),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
