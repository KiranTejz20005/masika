import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../core/constants/firestore_collections.dart';
import '../../../shared/models/cycle_log.dart';

class CycleRepository {
  FirebaseFirestore? get _firestore {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  Future<void> saveLog(String userId, CycleLog log) async {
    try {
      final fs = _firestore;
      if (fs == null) return;
      await fs
          .collection(FirestoreCollections.cycles)
          .doc(userId)
          .collection('logs')
          .doc(log.id)
          .set(log.toJson(), SetOptions(merge: true));
    } catch (_) {
      // Offline or Firebase not configured; keep local cache.
    }
  }
}
