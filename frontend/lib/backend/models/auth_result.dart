/// Result of auth operations (Supabase will provide real user id).
class AuthResult {
  const AuthResult({required this.userId});
  final String userId;
}
