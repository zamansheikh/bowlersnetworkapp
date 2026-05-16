import 'package:equatable/equatable.dart';

class ProAudience extends Equatable {
  const ProAudience({
    this.windowDays = 7,
    this.totalFollowers = 0,
    this.newFollowersWindow = 0,
    this.dailyAcquisition = const [],
    this.ageDistribution = const [],
    this.genderDistribution = const [],
    this.skillDistribution = const [],
    this.topCenters = const [],
  });

  final int windowDays;
  final int totalFollowers;
  final int newFollowersWindow;
  final List<DailyCount> dailyAcquisition;
  final List<KeyLabelCount> ageDistribution;
  final List<KeyLabelCount> genderDistribution;
  final List<KeyLabelCount> skillDistribution;
  final List<ProCenterCount> topCenters;

  @override
  List<Object?> get props => [
        windowDays,
        totalFollowers,
        newFollowersWindow,
        dailyAcquisition,
        ageDistribution,
        genderDistribution,
        skillDistribution,
        topCenters,
      ];
}

class DailyCount extends Equatable {
  const DailyCount({required this.date, this.count = 0});
  final String date;
  final int count;
  @override
  List<Object?> get props => [date, count];
}

class KeyLabelCount extends Equatable {
  const KeyLabelCount({
    required this.key,
    this.label = '',
    this.count = 0,
  });
  final String key;
  final String label;
  final int count;
  @override
  List<Object?> get props => [key, label, count];
}

class ProCenterCount extends Equatable {
  const ProCenterCount({
    required this.centerId,
    this.name = '',
    this.count = 0,
  });
  final String centerId;
  final String name;
  final int count;
  @override
  List<Object?> get props => [centerId, name, count];
}
