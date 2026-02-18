import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> setValue(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getValue(String key) async {
    return _storage.read(key: key);
  }
}
