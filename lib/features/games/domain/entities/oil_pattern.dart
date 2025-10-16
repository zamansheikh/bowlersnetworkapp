enum OilPattern {
  house,
  sport,
  challenge;

  String get displayName {
    switch (this) {
      case OilPattern.house:
        return 'House Pattern';
      case OilPattern.sport:
        return 'Sport Pattern';
      case OilPattern.challenge:
        return 'Challenge Pattern';
    }
  }

  String get description {
    switch (this) {
      case OilPattern.house:
        return 'Easy pocket hit, more forgiving';
      case OilPattern.sport:
        return 'Challenging, less forgiving';
      case OilPattern.challenge:
        return 'Most difficult pattern';
    }
  }

  String toJson() => name;

  static OilPattern fromJson(String json) {
    switch (json) {
      case 'house':
        return OilPattern.house;
      case 'sport':
        return OilPattern.sport;
      case 'challenge':
        return OilPattern.challenge;
      default:
        return OilPattern.house; // Default
    }
  }
}
