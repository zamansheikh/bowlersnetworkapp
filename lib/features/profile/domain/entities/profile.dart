import 'package:equatable/equatable.dart';

class ProfileUser extends Equatable {
  const ProfileUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.isPro = false,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final bool isPro;

  String get fullName => '$firstName $lastName'.trim();
  String get displayName => fullName.isEmpty ? username : fullName;

  @override
  List<Object?> get props => [id, firstName, lastName, username, isPro];
}

class Profile extends Equatable {
  const Profile({
    required this.user,
    required this.completionPercentage,
    required this.isComplete,
    this.profilePictureUrl,
    this.coverPictureUrl,
    this.followerCount = 0,
    this.followingCount = 0,
  });

  final ProfileUser user;
  final int completionPercentage;
  final bool isComplete;
  final String? profilePictureUrl;
  final String? coverPictureUrl;
  final int followerCount;
  final int followingCount;

  @override
  List<Object?> get props => [
        user,
        completionPercentage,
        isComplete,
        profilePictureUrl,
        coverPictureUrl,
        followerCount,
        followingCount,
      ];
}

class ProfileCompletion extends Equatable {
  const ProfileCompletion({
    required this.completionPercentage,
    required this.isComplete,
  });

  final int completionPercentage;
  final bool isComplete;

  @override
  List<Object?> get props => [completionPercentage, isComplete];
}
