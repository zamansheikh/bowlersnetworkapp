import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String profilePictureUrl;
  final String introVideoUrl;
  final String coverPhotoUrl;
  final int xp;
  final int level;
  final bool isPro;
  final int followerCount;
  final int followingCount;
  final String? bio;
  final String? gender;
  final String? birthDate;
  final int? age;
  final String? address;
  final String? homeCenter;
  final String? ballHandling;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl = '',
    this.introVideoUrl = '',
    this.coverPhotoUrl = '',
    this.xp = 0,
    this.level = 0,
    this.isPro = false,
    this.followerCount = 0,
    this.followingCount = 0,
    this.bio,
    this.gender,
    this.birthDate,
    this.age,
    this.address,
    this.homeCenter,
    this.ballHandling,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    username,
    firstName,
    lastName,
    profilePictureUrl,
    introVideoUrl,
    coverPhotoUrl,
    xp,
    level,
    isPro,
    followerCount,
    followingCount,
    bio,
    gender,
    birthDate,
    age,
    address,
    homeCenter,
    ballHandling,
  ];
}
