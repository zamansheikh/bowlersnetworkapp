import 'package:json_annotation/json_annotation.dart';

part 'message_sender_model.g.dart';

@JsonSerializable()
class MessageSenderModel {
  @JsonKey(name: 'user_id')
  final int userId;
  final String username;
  final String name;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String email;
  @JsonKey(name: 'profile_picture_url')
  final String profilePictureUrl;

  const MessageSenderModel({
    required this.userId,
    required this.username,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profilePictureUrl,
  });

  factory MessageSenderModel.fromJson(Map<String, dynamic> json) =>
      _$MessageSenderModelFromJson(json);

  Map<String, dynamic> toJson() => _$MessageSenderModelToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageSenderModel &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}
