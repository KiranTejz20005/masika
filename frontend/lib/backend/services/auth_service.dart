import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auth_result.dart';

/// Supabase Authentication: sign up, sign in, sign out.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  String? get currentUserId => _client.auth.currentUser?.id;
  bool get isAuthenticated => currentUserId != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    String? name,
    String? phone,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final res = await _client.auth.signUp(
        email: normalizedEmail,
        password: password,
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
        },
      );
      if (res.user == null) {
        throw Exception('Sign up failed. Please try again.');
      }
      return AuthResult(userId: res.user!.id);
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('already') && msg.contains('registered') ||
          msg.contains('email') && msg.contains('already')) {
        throw Exception('This email is already registered. Please log in instead.');
      }
      throw Exception(e.message);
    }
  }

  Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final res = await _client.auth.signInWithPassword(
        email: normalizedEmail,
        password: password,
      );
      if (res.user == null) {
        throw Exception('Login failed. Please try again.');
      }
      return AuthResult(userId: res.user!.id);
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid') && msg.contains('credential')) {
        throw Exception(
          'No account found with this email. Please register first to create an account.',
        );
      }
      throw Exception(e.message);
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> updateProfile({String? displayName, String? phone}) async {
    if (currentUserId == null) throw Exception('No user logged in');
    await _client.auth.updateUser(
      UserAttributes(
        data: {
          if (displayName != null) 'name': displayName,
          if (phone != null) 'phone': phone,
        },
      ),
    );
  }

  Future<void> deleteAccount() async {
    if (currentUserId == null) throw Exception('No user logged in');
    await _client.auth.signOut();
    // Actual user deletion may require Edge Function or admin API.
  }
}
