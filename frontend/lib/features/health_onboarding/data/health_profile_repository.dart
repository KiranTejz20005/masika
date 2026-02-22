import '../../../core/constants/hive_keys.dart';
import '../../../core/services/hive_service.dart';
import '../../../shared/models/user_health_profile.dart';
import '../../../backend/services/database_service.dart';

/// Health profile: local Hive + Supabase (patients.health_profile).
class HealthProfileRepository {
  final _db = DatabaseService();

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
    try {
      final data = await _db.getHealthProfile(userId);
      if (data == null || data.isEmpty) return null;
      return UserHealthProfile.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveRemote(UserHealthProfile profile) async {
    try {
      await _db.saveHealthProfile(profile.userId, profile.toJson());
    } catch (_) {}
  }

  Future<void> save(UserHealthProfile profile) async {
    await saveLocal(profile);
    await saveRemote(profile);
  }
}
