extension StringExtensions on String {
  String get capitalize => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get capitalizeWords =>
      split(' ').map((word) => word.capitalize).join(' ');

  bool get isValidEmail =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);

  bool get isValidUsername =>
      RegExp(r'^[a-zA-Z0-9_]{3,30}$').hasMatch(this);

  bool get isStrongPassword =>
      length >= 8 &&
      contains(RegExp(r'[A-Z]')) &&
      contains(RegExp(r'[a-z]')) &&
      contains(RegExp(r'[0-9]'));

  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  String get initials {
    final words = trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}
