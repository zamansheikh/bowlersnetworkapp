class DashboardDataModel {
  final int userId;
  final int likes;
  final int comments;
  final int shares;
  final int views;
  final int followerCount;
  final int onboardedUserCount;
  final int freeUsers;
  final int premiumUserCount;
  final double conversionRate;
  final double weightedIndex;

  DashboardDataModel({
    required this.userId,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.views,
    required this.followerCount,
    required this.onboardedUserCount,
    required this.freeUsers,
    required this.premiumUserCount,
    required this.conversionRate,
    required this.weightedIndex,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    return DashboardDataModel(
      userId: json['user_id'] ?? 0,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      shares: json['shares'] ?? 0,
      views: json['views'] ?? 0,
      followerCount: json['follower_count'] ?? 0,
      onboardedUserCount: json['onboarded_user_count'] ?? 0,
      freeUsers: json['free_users'] ?? 0,
      premiumUserCount: json['premium_user_count'] ?? 0,
      conversionRate: (json['conversion_rate'] ?? 0.0).toDouble(),
      weightedIndex: (json['weighted_index'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'views': views,
      'follower_count': followerCount,
      'onboarded_user_count': onboardedUserCount,
      'free_users': freeUsers,
      'premium_user_count': premiumUserCount,
      'conversion_rate': conversionRate,
      'weighted_index': weightedIndex,
    };
  }
}
