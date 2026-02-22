import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase database: separate tables for patients and doctors.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static const String patientsTable = 'patients';
  static const String doctorsTable = 'doctors';
  static const String patientDiagnosesTable = 'patient_diagnoses';

  SupabaseClient get _client => Supabase.instance.client;

  // Keep old names for compatibility where used
  static const String usersCollection = patientsTable;
  static const String doctorsCollection = doctorsTable;

  static String _toSnake(String key) {
    return key.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (m) => '_${m.group(0)!.toLowerCase()}',
    );
  }

  static Map<String, dynamic> _keysToSnake(Map<String, dynamic> map) {
    return map.map((k, v) => MapEntry(_toSnake(k), v));
  }

  static String _toCamel(String key) {
    final parts = key.split('_');
    if (parts.length <= 1) return key;
    return parts.first.toLowerCase() +
        parts.skip(1).map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.length > 1 ? p.substring(1).toLowerCase() : ''}').join();
  }

  static Map<String, dynamic> _keysToCamel(Map<String, dynamic> map) {
    return map.map((k, v) => MapEntry(_toCamel(k), v));
  }

  Future<Map<String, dynamic>?> getPatient(String id) async {
    try {
      final res = await _client.from(patientsTable).select().eq('id', id).maybeSingle();
      if (res == null) return null;
      return _keysToCamel(Map<String, dynamic>.from(res as Map));
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDoctor(String id) async {
    try {
      final res = await _client.from(doctorsTable).select().eq('id', id).maybeSingle();
      if (res == null) return null;
      return _keysToCamel(Map<String, dynamic>.from(res as Map));
    } catch (_) {
      return null;
    }
  }

  Future<void> upsertPatient(String id, Map<String, dynamic> data) async {
    final row = Map<String, dynamic>.from(_keysToSnake({...data, 'id': id}));
    row['updated_at'] = DateTime.now().toUtc().toIso8601String();
    row.putIfAbsent('created_at', () => DateTime.now().toUtc().toIso8601String());
    await _client.from(patientsTable).upsert(row, onConflict: 'id');
  }

  /// Partial update: only updates the given keys (snake_case). Use for avatar_url, health_profile, etc.
  Future<void> updatePatient(String id, Map<String, dynamic> data) async {
    if (data.isEmpty) return;
    final row = Map<String, dynamic>.from(_keysToSnake(data));
    row['updated_at'] = DateTime.now().toUtc().toIso8601String();
    await _client.from(patientsTable).update(row).eq('id', id);
  }

  Future<Map<String, dynamic>?> getHealthProfile(String uid) async {
    try {
      final res = await _client.from(patientsTable).select('health_profile').eq('id', uid).maybeSingle();
      if (res == null) return null;
      final raw = (res as Map<String, dynamic>)['health_profile'];
      if (raw == null) return null;
      return Map<String, dynamic>.from(raw as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveHealthProfile(String uid, Map<String, dynamic> data) async {
    await updatePatient(uid, {'health_profile': data});
  }

  Future<void> upsertDoctor(String id, Map<String, dynamic> data) async {
    final row = Map<String, dynamic>.from(_keysToSnake({...data, 'id': id}));
    row['updated_at'] = DateTime.now().toUtc().toIso8601String();
    row.putIfAbsent('created_at', () => DateTime.now().toUtc().toIso8601String());
    await _client.from(doctorsTable).upsert(row, onConflict: 'id');
  }

  Future<bool> isPatientEmailRegistered(String email) async {
    try {
      final res = await _client.from(patientsTable).select('id').eq('email', email).maybeSingle();
      return res != null;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isPatientPhoneRegistered(String phone) async {
    try {
      final res = await _client.from(patientsTable).select('id').eq('phone', phone).maybeSingle();
      return res != null;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isDoctorEmailRegistered(String email) async {
    try {
      final res = await _client.from(doctorsTable).select('id').eq('email', email).maybeSingle();
      return res != null;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isDoctorPhoneRegistered(String phone) async {
    try {
      final res = await _client.from(doctorsTable).select('id').eq('phone', phone).maybeSingle();
      return res != null;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllDoctors() async {
    try {
      final res = await _client.from(doctorsTable).select();
      final list = res as List<dynamic>? ?? [];
      return list.map((e) => _keysToCamel(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  /// Save one AI diagnosis (from analysis API predict). patientId = auth user id.
  Future<void> insertDiagnosis({
    required String patientId,
    required Map<String, dynamic> inputData,
    required String prediction,
    Map<String, double>? probabilities,
  }) async {
    final row = <String, dynamic>{
      'patient_id': patientId,
      'input_data': inputData,
      'prediction': prediction,
      'probabilities': probabilities != null
          ? probabilities.map((k, v) => MapEntry(k, v))
          : null,
    };
    await _client.from(patientDiagnosesTable).insert(row);
  }

  /// Fetch diagnosis history for a patient, newest first.
  Future<List<Map<String, dynamic>>> getDiagnoses(String patientId) async {
    try {
      final res = await _client
          .from(patientDiagnosesTable)
          .select()
          .eq('patient_id', patientId)
          .order('created_at', ascending: false);
      final list = res as List<dynamic>? ?? [];
      return list.map((e) => _keysToCamel(Map<String, dynamic>.from(e as Map))).toList();
    } catch (_) {
      return [];
    }
  }

  // Legacy API used by repositories
  Future<Map<String, dynamic>?> getUserProfile(String uid) async => getPatient(uid);
  Future<void> saveUserProfile(String uid, Map<String, dynamic> data) async => upsertPatient(uid, data);
  Future<Map<String, dynamic>?> getDoctorProfile(String uid) async => getDoctor(uid);
  Future<void> saveDoctorProfile(String uid, Map<String, dynamic> data) async => upsertDoctor(uid, data);
  Future<List<Map<String, dynamic>>> getAllDocuments(String collection) async {
    if (collection == doctorsTable) return getAllDoctors();
    return [];
  }
}
