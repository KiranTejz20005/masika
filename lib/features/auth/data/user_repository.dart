import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../../shared/models/user_profile.dart';

class UserRepository {
  FirebaseFirestore? get _firestore {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  Future<void> saveProfile(UserProfile profile) async {
    try {
      final fs = _firestore;
      if (fs == null) return;
      await fs
          .collection(FirestoreCollections.users)
          .doc(profile.id)
          .set(profile.toJson(), SetOptions(merge: true));
    } catch (_) {
      // Offline or Firebase not configured; keep local cache.
    }
  }
}
