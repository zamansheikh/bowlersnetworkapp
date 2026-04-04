import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class LocalStorageService {
  final SharedPreferencesAsync _prefs;

  LocalStorageService() : _prefs = SharedPreferencesAsync();

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    return await _prefs.getBool(key) ?? defaultValue;
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
