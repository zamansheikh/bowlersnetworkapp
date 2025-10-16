import 'package:shared_preferences/shared_preferences.dart';

import '../entities/hand_preference.dart';

class GameSettingsService {
  GameSettingsService(this._prefs);

  static const String _handPreferenceKey = 'hand_preference';
  static const String _hasSetHandPreferenceKey = 'has_set_hand_preference';

  final SharedPreferences _prefs;

  /// Get the default hand preference for new games
  HandPreference get defaultHandPreference {
    final value = _prefs.getString(_handPreferenceKey);
    if (value == null) {
      return HandPreference.right; // Default to right-handed
    }
    return HandPreference.fromJson(value);
  }

  /// Set the default hand preference for new games
  Future<void> setDefaultHandPreference(HandPreference preference) async {
    await _prefs.setString(_handPreferenceKey, preference.toJson());
    await _prefs.setBool(_hasSetHandPreferenceKey, true);
  }

  /// Check if user has set their hand preference before
  bool get hasSetHandPreference =>
      _prefs.getBool(_hasSetHandPreferenceKey) ?? false;
}
