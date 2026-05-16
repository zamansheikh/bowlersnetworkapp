import 'package:equatable/equatable.dart';

/// A person shown in a followers / followings list. Mirrors backend's
/// `user_minimal` payload (id/name/pic/pro/rank) plus the viewer-relative
/// `isFollowing` flag.
class FollowUser extends Equatable {
  const FollowUser({
    required this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.isPro = false,
    this.level,
    this.rankDisplay,
    this.badgeIconUrl,
    this.isFollowing = false,
    this.followedAt,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;
  final bool isPro;
  final int? level;
  final String? rankDisplay;
  final String? badgeIconUrl;
  final bool isFollowing;
  final DateTime? followedAt;

  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? username : full;
  }

  FollowUser copyWith({bool? isFollowing}) => FollowUser(
        id: id,
        username: username,
        firstName: firstName,
        lastName: lastName,
        profilePictureUrl: profilePictureUrl,
        isPro: isPro,
        level: level,
        rankDisplay: rankDisplay,
        badgeIconUrl: badgeIconUrl,
        isFollowing: isFollowing ?? this.isFollowing,
        followedAt: followedAt,
      );

  @override
  List<Object?> get props => [
        id,
        username,
        firstName,
        lastName,
        profilePictureUrl,
        isPro,
        level,
        rankDisplay,
        badgeIconUrl,
        isFollowing,
        followedAt,
      ];
}

/// Result of a follow-toggle call — backend tells us whether we are now
/// following and what the target's new follower-count is.
class FollowToggleResult extends Equatable {
  const FollowToggleResult({
    required this.isFollowing,
    required this.followerCount,
  });

  final bool isFollowing;
  final int followerCount;

  @override
  List<Object?> get props => [isFollowing, followerCount];
}
