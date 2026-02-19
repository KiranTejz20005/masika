import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration and initialization.
class SupabaseService {
  static bool _initialized = false;

  static String? get supabaseUrl => dotenv.env['SUPABASE_URL'];
  static String? get anonKey => dotenv.env['SUPABASE_ANON_KEY'];
  static String? get serviceRoleKey => dotenv.env['SUPABASE_SERVICE_ROLE_KEY'];

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await dotenv.load(fileName: '.env');
      final url = supabaseUrl;
      final anonKey = SupabaseService.anonKey;
      if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
        throw Exception('SUPABASE_URL and SUPABASE_ANON_KEY must be set in .env');
      }
      await Supabase.initialize(url: url, anonKey: anonKey);
      _initialized = true;
    } catch (e) {
      rethrow;
    }
  }
}
