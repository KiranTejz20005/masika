import '../../../shared/models/user_profile.dart';

/// Local/sync user profile (Supabase will replace remote write when configured).
class UserRepository {
  Future<void> saveProfile(UserProfile profile) async {
    // TODO: Supabase - save to users table (AppCollections.users)
  }
}
