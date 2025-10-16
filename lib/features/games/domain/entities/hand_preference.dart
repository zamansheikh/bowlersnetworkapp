enum HandPreference {
  left,
  right;

  String get displayName {
    switch (this) {
      case HandPreference.left:
        return 'Left Handed';
      case HandPreference.right:
        return 'Right Handed';
    }
  }

  String toJson() => name;

  static HandPreference fromJson(String json) {
    switch (json) {
      case 'left':
        return HandPreference.left;
      case 'right':
        return HandPreference.right;
      default:
        return HandPreference.right; // Default to right
    }
  }
}
