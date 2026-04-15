import 'dart:ui' show Locale;

/// Supported locales for BowlersNetwork.
///
/// ## Adding a new language
///
/// 1. Add a new entry to this enum (e.g. `es(...)`, `bn(...)`).
/// 2. Create `lib/l10n/app_<code>.arb` with the same keys as `app_en.arb`
///    translated to the new language.
/// 3. Run `flutter gen-l10n` (or `flutter run` — it generates automatically).
///
/// Nothing else changes. [AppLocale.values] is the single source of truth for
/// `supportedLocales` in [MaterialApp.router] and for the language picker.
enum AppLocale {
  en(
    code: 'en',
    countryCode: null,
    nativeName: 'English',
    englishName: 'English',
    flagEmoji: '🇬🇧',
  );

  const AppLocale({
    required this.code,
    required this.countryCode,
    required this.nativeName,
    required this.englishName,
    required this.flagEmoji,
  });

  final String code;
  final String? countryCode;
  final String nativeName;
  final String englishName;
  final String flagEmoji;

  Locale get locale =>
      countryCode == null ? Locale(code) : Locale(code, countryCode);

  static AppLocale fromCode(String? code) {
    if (code == null || code.isEmpty) return AppLocale.en;
    for (final l in AppLocale.values) {
      if (l.code == code) return l;
    }
    return AppLocale.en;
  }

  static List<Locale> get supportedLocales =>
      AppLocale.values.map((e) => e.locale).toList(growable: false);
}
