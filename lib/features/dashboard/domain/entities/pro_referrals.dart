import 'package:equatable/equatable.dart';

import 'pro_audience.dart';

class ProReferrals extends Equatable {
  const ProReferrals({
    this.windowDays = 7,
    this.clicks = const ReferralClicks(),
    this.referrals = const ReferralTotals(),
    this.proAttribution,
  });

  final int windowDays;
  final ReferralClicks clicks;
  final ReferralTotals referrals;

  /// Null when the viewer doesn't have a `Pro` profile yet.
  final ProAttribution? proAttribution;

  @override
  List<Object?> get props =>
      [windowDays, clicks, referrals, proAttribution];
}

class ReferralClicks extends Equatable {
  const ReferralClicks({
    this.totalClicks = 0,
    this.windowClicks = 0,
    this.convertedWindow = 0,
    this.conversionRate = 0,
    this.dailyClicks = const [],
    this.topCountries = const [],
    this.deviceMix = const [],
  });

  final int totalClicks;
  final int windowClicks;
  final int convertedWindow;
  final double conversionRate;
  final List<DailyCount> dailyClicks;
  final List<KeyLabelCount> topCountries;
  final List<KeyLabelCount> deviceMix;

  @override
  List<Object?> get props => [
        totalClicks,
        windowClicks,
        convertedWindow,
        conversionRate,
        dailyClicks,
        topCountries,
        deviceMix,
      ];
}

class ReferralTotals extends Equatable {
  const ReferralTotals({this.total = 0, this.inWindow = 0});
  final int total;
  final int inWindow;
  @override
  List<Object?> get props => [total, inWindow];
}

class ProAttribution extends Equatable {
  const ProAttribution({
    this.trueCount = 0,
    this.secondaryCount = 0,
    this.shadowCount = 0,
    this.totalCount = 0,
    this.windowCount = 0,
    this.weightedScore = 0,
    this.weightMap = const ProAttributionWeights(),
  });

  final int trueCount;
  final int secondaryCount;
  final int shadowCount;
  final int totalCount;
  final int windowCount;
  final double weightedScore;
  final ProAttributionWeights weightMap;

  @override
  List<Object?> get props => [
        trueCount,
        secondaryCount,
        shadowCount,
        totalCount,
        windowCount,
        weightedScore,
        weightMap,
      ];
}

class ProAttributionWeights extends Equatable {
  const ProAttributionWeights({
    this.trueWeight = 0,
    this.secondaryWeight = 0,
    this.shadowWeight = 0,
  });
  final double trueWeight;
  final double secondaryWeight;
  final double shadowWeight;
  @override
  List<Object?> get props => [trueWeight, secondaryWeight, shadowWeight];
}
