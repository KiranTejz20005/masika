import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../../core/constants/hive_keys.dart';
import '../../../core/services/hive_service.dart';
import '../../../shared/models/user_health_profile.dart';

class HealthProfileRepository {
  FirebaseFirestore? get _firestore {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  Future<UserHealthProfile?> getLocal(String userId) async {
    final cached = HiveService.getValue<Map>(HiveKeys.userHealthProfile);
    if (cached == null) return null;
    final profile = UserHealthProfile.fromJson(Map<String, dynamic>.from(cached));
    if (profile.userId != userId) return null;
    return profile;
  }

  Future<void> saveLocal(UserHealthProfile profile) async {
    await HiveService.setValue(HiveKeys.userHealthProfile, profile.toJson());
  }

  Future<UserHealthProfile?> getRemote(String userId) async {
    final fs = _firestore;
    if (fs == null) return null;
    try {
      final doc = await fs
          .collection(FirestoreCollections.healthProfiles)
          .doc(userId)
          .get();
      if (doc.exists && doc.data() != null) {
        return UserHealthProfile.fromJson(
            Map<String, dynamic>.from(doc.data()!));
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveRemote(UserHealthProfile profile) async {
    final fs = _firestore;
    if (fs == null) return;
    try {
      await fs
          .collection(FirestoreCollections.healthProfiles)
          .doc(profile.userId)
          .set(profile.toJson(), SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> save(UserHealthProfile profile) async {
    await saveLocal(profile);
    await saveRemote(profile);
  }
}
