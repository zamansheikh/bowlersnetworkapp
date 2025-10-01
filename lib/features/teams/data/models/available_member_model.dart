import 'package:json_annotation/json_annotation.dart';

part 'available_member_model.g.dart';

@JsonSerializable()
class AvailableMemberModel {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'username')
  final String username;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'full_name')
  final String? fullName;

  @JsonKey(name: 'profile_picture')
  final String? profilePicture;

  @JsonKey(name: 'bowling_average')
  final double? bowlingAverage;

  @JsonKey(name: 'is_premium')
  final bool isPremium;

  const AvailableMemberModel({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.profilePicture,
    this.bowlingAverage,
    required this.isPremium,
  });

  factory AvailableMemberModel.fromJson(Map<String, dynamic> json) =>
      _$AvailableMemberModelFromJson(json);

  Map<String, dynamic> toJson() => _$AvailableMemberModelToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvailableMemberModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          email == other.email &&
          fullName == other.fullName &&
          profilePicture == other.profilePicture &&
          bowlingAverage == other.bowlingAverage &&
          isPremium == other.isPremium;

  @override
  int get hashCode =>
      id.hashCode ^
      username.hashCode ^
      email.hashCode ^
      fullName.hashCode ^
      profilePicture.hashCode ^
      bowlingAverage.hashCode ^
      isPremium.hashCode;

  @override
  String toString() {
    return 'AvailableMemberModel(id: $id, username: $username, email: $email, fullName: $fullName, profilePicture: $profilePicture, bowlingAverage: $bowlingAverage, isPremium: $isPremium)';
  }
}
