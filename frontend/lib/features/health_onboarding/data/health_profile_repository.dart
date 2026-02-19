import '../../../core/constants/hive_keys.dart';
import '../../../core/services/hive_service.dart';
import '../../../shared/models/user_health_profile.dart';

/// Health profile: local Hive + remote when Supabase is configured.
class HealthProfileRepository {
  Future<UserHealthProfile?> getLocal(String userId) async {
    final cached = HiveService.getValue<Map>(HiveKeys.userHealthProfile);
    if (cached == null) return null;
    final profile =
        UserHealthProfile.fromJson(Map<String, dynamic>.from(cached));
    if (profile.userId != userId) return null;
    return profile;
  }

  Future<void> saveLocal(UserHealthProfile profile) async {
    await HiveService.setValue(HiveKeys.userHealthProfile, profile.toJson());
  }

  Future<UserHealthProfile?> getRemote(String userId) async {
    // TODO: Supabase - fetch from health_profiles
    return null;
  }

  Future<void> saveRemote(UserHealthProfile profile) async {
    // TODO: Supabase - upsert health_profiles
  }

  Future<void> save(UserHealthProfile profile) async {
    await saveLocal(profile);
    await saveRemote(profile);
  }
}
