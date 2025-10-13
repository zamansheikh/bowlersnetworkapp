import 'package:shared_preferences/shared_preferences.dart';

class PinSettingsService {
  PinSettingsService(this._prefs);

  static const String _pinsKnockedKey = 'pins_knocked_by_default';

  final SharedPreferences _prefs;

  bool get pinsKnockedByDefault =>
      _prefs.getBool(_pinsKnockedKey) ?? false; // false = standing

  Future<void> setPinsKnockedByDefault(bool value) async {
    await _prefs.setBool(_pinsKnockedKey, value);
  }
}
