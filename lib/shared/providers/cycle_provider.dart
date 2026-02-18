import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_providers.dart';
import '../models/cycle_log.dart';

/// Computed cycle data used across the app
class CycleData {
  final int cycleDay;
  final int cycleLength;
  final int periodDuration;
  final String phase;       // menstrual, follicular, ovulation, luteal
  final String phaseLabel;  // MENSTRUAL, FOLLICULAR, OVULATION, LUTEAL
  final int daysUntilNextPeriod;
  final DateTime? nextPeriodDate;
  final DateTime? lastPeriodStart;
  final DateTime? lastPeriodEnd;
  final double progress;    // 0.0 to 1.0
  final bool hasData;
  final String mood;
  final String flow;
  final List<String> symptoms;
  final String coachMessage;
  final String energyLevel;
  final List<String> scheduleRecommendations;

  const CycleData({
    this.cycleDay = 1,
    this.cycleLength = 28,
    this.periodDuration = 5,
    this.phase = 'follicular',
    this.phaseLabel = 'FOLLICULAR',
    this.daysUntilNextPeriod = 14,
    this.nextPeriodDate,
    this.lastPeriodStart,
    this.lastPeriodEnd,
    this.progress = 0.0,
    this.hasData = false,
    this.mood = 'calm',
    this.flow = 'medium',
    this.symptoms = const [],
    this.coachMessage = '',
    this.energyLevel = 'moderate',
    this.scheduleRecommendations = const [],
  });
}

/// Determines cycle phase from cycle day
String _getPhase(int cycleDay, int cycleLength, int periodDuration) {
  if (cycleDay <= periodDuration) return 'menstrual';
  if (cycleDay <= (cycleLength * 0.5).round()) return 'follicular';
  if (cycleDay <= (cycleLength * 0.57).round()) return 'ovulation';
  return 'luteal';
}

String _getPhaseLabel(String phase) {
  switch (phase) {
    case 'menstrual': return 'MENSTRUAL';
    case 'follicular': return 'FOLLICULAR';
    case 'ovulation': return 'OVULATION';
    case 'luteal': return 'LUTEAL';
    default: return 'FOLLICULAR';
  }
}

String _getEnergyLevel(String phase) {
  switch (phase) {
    case 'menstrual': return 'low';
    case 'follicular': return 'rising';
    case 'ovulation': return 'peak';
    case 'luteal': return 'moderate';
    default: return 'moderate';
  }
}

String _getCoachMessage(String phase, int cycleDay, String userName) {
  final name = userName.isNotEmpty ? userName : 'there';
  switch (phase) {
    case 'menstrual':
      return '"Good morning, $name. You\'re on day $cycleDay of your cycle. Your body needs rest and care. Focus on gentle activities and stay hydrated."';
    case 'follicular':
      return '"Good morning, $name. Based on your data, you might feel more energetic today. Your follicular phase is the perfect time for challenging workouts!"';
    case 'ovulation':
      return '"Hey $name! You\'re at peak energy in your ovulation phase. This is your power window — tackle big tasks and intense workouts today!"';
    case 'luteal':
      return '"Hi $name. You\'re in your luteal phase. You may feel calmer. Focus on steady routines, balanced nutrition, and quality sleep."';
    default:
      return '"Good morning, $name. Log your period to get personalized cycle insights tailored just for you."';
  }
}

List<String> _getScheduleRecommendations(String phase) {
  switch (phase) {
    case 'menstrual':
      return ['Gentle Yoga', 'Iron-Rich Meals', 'Rest & Hydrate', 'Warm Compress'];
    case 'follicular':
      return ['Morning Stretch', 'Iron-Rich Lunch', 'High Intensity HIIT', 'Take Supplements'];
    case 'ovulation':
      return ['HIIT Workout', 'Protein-Rich Meals', 'Strength Training', 'Social Activities'];
    case 'luteal':
      return ['Light Cardio', 'Balanced Diet', 'Meditation', 'Evening Walk'];
    default:
      return ['Morning Stretch', 'Healthy Lunch', 'Evening Walk', 'Hydration'];
  }
}

/// Main provider — computes cycle data from logged cycles
final cycleDataProvider = Provider<CycleData>((ref) {
  final logs = ref.watch(cycleLogsProvider);
  final profile = ref.watch(userProfileProvider);
  final healthProfile = ref.watch(healthProfileProvider);

  final userName = profile?.name ?? '';
  // Prefer health onboarding profile for cycle defaults when available
  final defaultCycleLength = healthProfile?.cycleLength ??
      profile?.cycleLength ??
      28;
  final defaultPeriodDuration = healthProfile?.periodDuration ??
      profile?.periodDuration ??
      5;

  if (logs.isEmpty) {
    // No data logged yet — return defaults
    final phase = 'follicular';
    return CycleData(
      cycleDay: 1,
      cycleLength: defaultCycleLength,
      periodDuration: defaultPeriodDuration,
      phase: phase,
      phaseLabel: _getPhaseLabel(phase),
      daysUntilNextPeriod: defaultCycleLength,
      nextPeriodDate: null,
      lastPeriodStart: null,
      lastPeriodEnd: null,
      progress: 0.0,
      hasData: false,
      mood: 'calm',
      flow: 'medium',
      symptoms: [],
      coachMessage: _getCoachMessage('none', 1, userName),
      energyLevel: 'moderate',
      scheduleRecommendations: _getScheduleRecommendations('follicular'),
    );
  }

  // Sort logs by start date descending
  final sortedLogs = List<CycleLog>.from(logs)
    ..sort((a, b) => b.startDate.compareTo(a.startDate));
  final latestLog = sortedLogs.first;

  // Calculate average cycle length from multiple logs
  int avgCycleLength = defaultCycleLength;
  if (sortedLogs.length >= 2) {
    int totalGap = 0;
    int gaps = 0;
    for (int i = 0; i < sortedLogs.length - 1; i++) {
      final gap = sortedLogs[i].startDate.difference(sortedLogs[i + 1].startDate).inDays;
      if (gap > 15 && gap < 60) {
        totalGap += gap;
        gaps++;
      }
    }
    if (gaps > 0) avgCycleLength = (totalGap / gaps).round();
  }

  final periodDuration = latestLog.endDate.difference(latestLog.startDate).inDays + 1;
  final today = DateTime.now();
  final daysSinceStart = today.difference(latestLog.startDate).inDays + 1;

  // Determine current cycle day (wrapping if beyond cycle length)
  int cycleDay;
  if (daysSinceStart <= 0) {
    cycleDay = 1;
  } else if (daysSinceStart > avgCycleLength) {
    // Period might be late — show as day beyond cycle
    cycleDay = daysSinceStart;
  } else {
    cycleDay = daysSinceStart;
  }

  final daysUntilNext = (avgCycleLength - cycleDay + 1).clamp(0, avgCycleLength);
  final nextPeriod = latestLog.startDate.add(Duration(days: avgCycleLength));
  final phase = _getPhase(cycleDay.clamp(1, avgCycleLength), avgCycleLength, periodDuration.clamp(1, 10));
  final progress = (cycleDay / avgCycleLength).clamp(0.0, 1.0);

  return CycleData(
    cycleDay: cycleDay.clamp(1, 99),
    cycleLength: avgCycleLength,
    periodDuration: periodDuration.clamp(1, 15),
    phase: phase,
    phaseLabel: _getPhaseLabel(phase),
    daysUntilNextPeriod: daysUntilNext,
    nextPeriodDate: nextPeriod,
    lastPeriodStart: latestLog.startDate,
    lastPeriodEnd: latestLog.endDate,
    progress: progress,
    hasData: true,
    mood: latestLog.mood,
    flow: latestLog.flow,
    symptoms: latestLog.symptoms,
    coachMessage: _getCoachMessage(phase, cycleDay.clamp(1, 99), userName),
    energyLevel: _getEnergyLevel(phase),
    scheduleRecommendations: _getScheduleRecommendations(phase),
  );
});
