enum LaneCondition {
  oily,
  dry,
  medium;

  String get displayName {
    switch (this) {
      case LaneCondition.oily:
        return 'Oily Lane';
      case LaneCondition.dry:
        return 'Dry Lane';
      case LaneCondition.medium:
        return 'Medium Oil';
    }
  }

  String get description {
    switch (this) {
      case LaneCondition.oily:
        return 'Less slide, more backend';
      case LaneCondition.dry:
        return 'Ball hooks earlier';
      case LaneCondition.medium:
        return 'Balanced reaction';
    }
  }

  String toJson() => name;

  static LaneCondition fromJson(String json) {
    switch (json) {
      case 'oily':
        return LaneCondition.oily;
      case 'dry':
        return LaneCondition.dry;
      case 'medium':
        return LaneCondition.medium;
      default:
        return LaneCondition.medium; // Default
    }
  }
}
