import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/hive_keys.dart';
import '../../../../core/services/hive_service.dart';

/// Persistent flag so onboarding shows only on first launch (or after app version bump).
class OnboardingStorage {
  static Future<bool> isCompleted() async {
    final value = HiveService.getValue<bool>(HiveKeys.onboardingCompleted);
    return value == true;
  }

  static Future<void> setCompleted() async {
    await HiveService.setValue(HiveKeys.onboardingCompleted, true);
  }

  /// Call at app launch: if app version changed, clear onboarding so user sees it again.
  static Future<void> ensureOnboardingShownForCurrentVersion() async {
    final stored = HiveService.getValue<String>(HiveKeys.appVersionAtLaunch);
    if (stored == AppConstants.appVersion) return;
    await HiveService.remove(HiveKeys.onboardingCompleted);
    await HiveService.setValue(HiveKeys.appVersionAtLaunch, AppConstants.appVersion);
  }
}
