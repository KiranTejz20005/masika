import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const _cacheBox = 'masika_cache';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox(_cacheBox);
  }

  static Box<dynamic> get _box => Hive.box(_cacheBox);

  static Future<void> setValue(String key, dynamic value) async {
    await _box.put(key, value);
  }

  static T? getValue<T>(String key) => _box.get(key) as T?;

  static Future<void> remove(String key) async {
    await _box.delete(key);
  }
}
