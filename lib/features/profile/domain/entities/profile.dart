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

/// Flat bundle of everything the mobile profile screen needs. Deep
/// sub-models stay as optional fields so we can render null-safe when the
/// user hasn't filled them in yet.
class Profile extends Equatable {
  const Profile({
    required this.user,
    required this.completionPercentage,
    required this.isComplete,
    this.profilePictureUrl,
    this.coverPictureUrl,
    this.introVideoUrl,
    this.bio,
    this.nickname,
    this.gender,
    this.birthdate,
    this.age,
    this.address,
    this.zipCode,
    this.homeCenter,
    this.handedness,
    this.ballCarry,
    this.grip,
    this.ballHandlingDescription,
    this.contactEmail,
    this.average,
    this.highGame,
    this.highSeries,
    this.experience,
    this.isCoach = false,
    this.followerCount = 0,
    this.followingCount = 0,
    this.isFollowing,
    this.canFollow,
  });

  final ProfileUser user;
  final int completionPercentage;
  final bool isComplete;
  final String? profilePictureUrl;
  final String? coverPictureUrl;
  final String? introVideoUrl;

  final String? bio;
  final String? nickname;
  final String? gender;
  final String? birthdate;
  final int? age;
  final String? address;
  final String? zipCode;
  final String? homeCenter;

  final String? handedness;
  final String? ballCarry;
  final String? grip;
  final String? ballHandlingDescription;

  final String? contactEmail;

  final num? average;
  final int? highGame;
  final int? highSeries;
  final int? experience;
  final bool isCoach;

  final int followerCount;
  final int followingCount;

  final bool? isFollowing;
  final bool? canFollow;

  bool get hasBallHandling =>
      handedness != null || ballCarry != null || grip != null;

  @override
  List<Object?> get props => [
        user,
        completionPercentage,
        isComplete,
        profilePictureUrl,
        coverPictureUrl,
        bio,
        nickname,
        gender,
        birthdate,
        address,
        homeCenter,
        handedness,
        ballCarry,
        grip,
        contactEmail,
        average,
        highGame,
        highSeries,
        experience,
        isCoach,
        followerCount,
        followingCount,
        isFollowing,
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
