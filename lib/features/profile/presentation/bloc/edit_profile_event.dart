part of 'edit_profile_bloc.dart';

/// Identifies which section is currently saving. The bloc tracks an
/// active set so multiple sections can save concurrently without
/// blocking each other.
enum EditableField {
  nickname,
  bio,
  gender,
  birthdate,
  ballHandling,
  gameStats,
  address,
  homeCenter,
}

sealed class EditProfileEvent extends Equatable {
  const EditProfileEvent();
  @override
  List<Object?> get props => const [];
}

class EditProfileNicknameSubmitted extends EditProfileEvent {
  const EditProfileNicknameSubmitted(this.name);
  final String name;
  @override
  List<Object?> get props => [name];
}

class EditProfileBioSubmitted extends EditProfileEvent {
  const EditProfileBioSubmitted(this.content);
  final String content;
  @override
  List<Object?> get props => [content];
}

/// [value] must be `'Male'` or `'Female'` — enforced by the backend.
class EditProfileGenderSubmitted extends EditProfileEvent {
  const EditProfileGenderSubmitted(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

/// [isoDate] in `YYYY-MM-DD`. [parentEmail] is forwarded only when the
/// computed age implies the user is under 13 (backend requirement).
class EditProfileBirthdateSubmitted extends EditProfileEvent {
  const EditProfileBirthdateSubmitted({
    required this.isoDate,
    this.parentEmail,
  });
  final String isoDate;
  final String? parentEmail;
  @override
  List<Object?> get props => [isoDate, parentEmail];
}

class EditProfileBallHandlingSubmitted extends EditProfileEvent {
  const EditProfileBallHandlingSubmitted({
    required this.handedness,
    required this.ballCarry,
    required this.grip,
  });
  final String handedness;
  final String ballCarry;
  final String grip;
  @override
  List<Object?> get props => [handedness, ballCarry, grip];
}

class EditProfileGameStatsSubmitted extends EditProfileEvent {
  const EditProfileGameStatsSubmitted({
    this.average,
    this.highGame,
    this.highSeries,
    this.experience,
  });
  final num? average;
  final int? highGame;
  final int? highSeries;
  final int? experience;
  @override
  List<Object?> get props => [average, highGame, highSeries, experience];
}

class EditProfileAddressSubmitted extends EditProfileEvent {
  const EditProfileAddressSubmitted({
    required this.address,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
  });
  final String address;
  final String zipCode;
  final double latitude;
  final double longitude;
  @override
  List<Object?> get props => [address, zipCode, latitude, longitude];
}

class EditProfileHomeCenterSubmitted extends EditProfileEvent {
  const EditProfileHomeCenterSubmitted({
    required this.centerId,
    required this.centerName,
  });
  final int centerId;
  final String centerName;
  @override
  List<Object?> get props => [centerId, centerName];
}
