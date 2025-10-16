enum GameType {
  practice,
  tournament;

  String get displayName {
    switch (this) {
      case GameType.practice:
        return 'Practice';
      case GameType.tournament:
        return 'Tournament';
    }
  }

  String toJson() => name;

  static GameType fromJson(String json) {
    switch (json) {
      case 'practice':
        return GameType.practice;
      case 'tournament':
        return GameType.tournament;
      default:
        return GameType.practice; // Default
    }
  }
}
