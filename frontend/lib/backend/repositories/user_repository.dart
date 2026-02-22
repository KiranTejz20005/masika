import '../models/auth_result.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../../shared/models/user_profile.dart';

/// User Repository (Supabase-backed when configured)
class UserRepository {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  Future<UserProfile?> getCurrentUserProfile() async {
    final uid = _authService.currentUserId;
    if (uid == null) return null;
    return getUserProfile(uid);
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final data = await _dbService.getUserProfile(uid);
      if (data == null) return null;
      return UserProfile.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _dbService.saveUserProfile(profile.id, profile.toJson());
  }

  /// Partial update: only the given fields are updated (e.g. name, avatarUrl). Other columns are unchanged.
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    if (data.isEmpty) return;
    await _dbService.updatePatient(uid, data);
  }

  Future<AuthResult> registerUser({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPhone = phone?.trim();
    final exists = await _dbService.isPatientEmailRegistered(normalizedEmail);
    if (exists) throw Exception('An account with this email already exists');
    if (normalizedPhone != null && normalizedPhone.isNotEmpty) {
      final phoneExists = await _dbService.isPatientPhoneRegistered(normalizedPhone);
      if (phoneExists) throw Exception('An account with this phone number already exists');
    }

    final result = await _authService.registerWithEmail(
      email: normalizedEmail,
      password: password,
      name: name.trim(),
      phone: normalizedPhone,
    );

    final profile = UserProfile(
      id: result.userId,
      name: name.trim(),
      age: 25,
      languageCode: 'en',
      cycleLength: 28,
      periodDuration: 5,
      email: normalizedEmail,
      phone: normalizedPhone,
    );
    await saveUserProfile(profile);
    return result;
  }

  Future<AuthResult> loginUser({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    return _authService.loginWithEmail(email: normalizedEmail, password: password);
  }

  bool get isLoggedIn => _authService.isAuthenticated;
  String? get currentUserId => _authService.currentUserId;

  Future<void> signOut() async => _authService.signOut();
  Future<void> sendPasswordReset(String email) async =>
      _authService.sendPasswordResetEmail(email);
  Future<bool> checkEmailExists(String email) async =>
      _dbService.isPatientEmailRegistered(email);
  Future<bool> checkPhoneExists(String phone) async =>
      _dbService.isPatientPhoneRegistered(phone);
}
