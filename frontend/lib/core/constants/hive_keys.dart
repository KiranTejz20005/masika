/// Centralized Hive cache key names. Single source of truth for storage keys.
abstract final class HiveKeys {
  HiveKeys._();

  static const userProfile = 'user_profile';
  static const doctorProfile = 'doctor_profile';
  static const cycleLogs = 'cycle_logs';
  static const onboardingCompleted = 'onboarding_completed';
  static const userHealthProfile = 'user_health_profile';
  static const appVersionAtLaunch = 'app_version_at_launch';
  static const appointments = 'appointments';
  static const savedAnalysisReports = 'saved_analysis_reports';
}
