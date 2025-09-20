class PerformanceDataModel {
  final String label;
  final int score;
  final String date;

  PerformanceDataModel({
    required this.label,
    required this.score,
    required this.date,
  });

  factory PerformanceDataModel.fromJson(Map<String, dynamic> json) {
    return PerformanceDataModel(
      label: json['label'] ?? '',
      score: json['score'] ?? 0,
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'label': label, 'score': score, 'date': date};
  }
}
