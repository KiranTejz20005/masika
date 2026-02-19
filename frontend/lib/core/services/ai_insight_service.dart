import '../../shared/models/health_insight.dart';
import '../../shared/models/user_profile.dart';
import '../../shared/models/cycle_log.dart';

class AiInsightService {
  HealthInsight generateInsight({
    required UserProfile profile,
    required List<CycleLog> cycles,
    required List<String> symptoms,
    required int? hemoglobin,
    required Map<String, String> copy,
  }) {
    final cycleLength =
        cycles.isNotEmpty ? cycles.last.cycleLengthDays : profile.cycleLength;
    final hasIrregular = cycleLength < 21 || cycleLength > 35;
    final lowHb = hemoglobin != null && hemoglobin < 12;

    final summary = hasIrregular
        ? copy['insight_summary_irregular'] ?? ''
        : copy['insight_summary_normal'] ?? '';
    final causes = [
      if (hasIrregular) copy['insight_cause_stress'] ?? '',
      if (symptoms.contains(copy['symptom_severe'] ?? ''))
        copy['insight_cause_hormonal'] ?? '',
      if (lowHb) copy['insight_cause_low_iron'] ?? '',
      if (!hasIrregular && !lowHb) copy['insight_cause_normal'] ?? '',
    ];
    final filteredCauses = causes.where((item) => item.isNotEmpty).toList();

    return HealthInsight(
      summary: summary,
      possibleCauses: filteredCauses,
      whatThisMeans: copy['insight_what_means'] ?? '',
      whatToDo: copy['insight_what_to_do'] ?? '',
      whenToConsult: lowHb
          ? copy['insight_when_consult_lowhb'] ?? ''
          : copy['insight_when_consult_default'] ?? '',
      disclaimer: copy['disclaimer_text'] ?? '',
    );
  }
}
