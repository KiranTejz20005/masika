import '../models/auth_result.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../../shared/models/doctor_profile.dart';

/// Doctor Repository (Supabase-backed when configured)
class DoctorRepository {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  Future<DoctorProfile?> getCurrentDoctorProfile() async {
    final uid = _authService.currentUserId;
    if (uid == null) return null;
    return getDoctorProfile(uid);
  }

  Future<DoctorProfile?> getDoctorProfile(String uid) async {
    try {
      final data = await _dbService.getDoctorProfile(uid);
      if (data == null) return null;
      return DoctorProfile.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveDoctorProfile(DoctorProfile profile) async {
    await _dbService.saveDoctorProfile(profile.id, profile.toJson());
  }

  Future<void> updateDoctorProfile(String uid, Map<String, dynamic> data) async {
    await _dbService.saveDoctorProfile(uid, data);
  }

  Future<AuthResult> registerDoctor({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? specialty,
    String? clinic,
    String? experience,
  }) async {
    final exists = await _dbService.isDoctorEmailRegistered(email);
    if (exists) throw Exception('An account with this email already exists');
    if (phone != null && phone.isNotEmpty) {
      final phoneExists = await _dbService.isDoctorPhoneRegistered(phone);
      if (phoneExists) throw Exception('An account with this phone number already exists');
    }

    final result = await _authService.registerWithEmail(
      email: email,
      password: password,
      name: name,
      phone: phone,
    );

    final profile = DoctorProfile(
      id: result.userId,
      name: name,
      email: email,
      phone: phone ?? '',
      specialty: specialty ?? '',
      clinic: clinic ?? '',
      experience: experience ?? '',
    );
    await saveDoctorProfile(profile);
    return result;
  }

  Future<AuthResult> loginDoctor({
    required String email,
    required String password,
  }) async {
    return _authService.loginWithEmail(email: email, password: password);
  }

  bool get isLoggedIn => _authService.isAuthenticated;
  String? get currentDoctorId => _authService.currentUserId;

  Future<void> signOut() async => _authService.signOut();
  Future<void> sendPasswordReset(String email) async =>
      _authService.sendPasswordResetEmail(email);
  Future<bool> checkEmailExists(String email) async =>
      _dbService.isDoctorEmailRegistered(email);
  Future<bool> checkPhoneExists(String phone) async =>
      _dbService.isDoctorPhoneRegistered(phone);

  Future<List<DoctorProfile>> getAllDoctors() async {
    try {
      final data = await _dbService.getAllDoctors();
      return data.map((doc) => DoctorProfile.fromJson(doc)).toList();
    } catch (e) {
      return [];
    }
  }
}
