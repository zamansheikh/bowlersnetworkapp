import 'package:json_annotation/json_annotation.dart';
import 'message_model.dart';

part 'conversation_model.g.dart';

@JsonSerializable()
class ConversationModel {
  @JsonKey(name: 'room_id')
  final int roomId;
  final String name;
  @JsonKey(name: 'display_name')
  final String displayName;
  @JsonKey(name: 'display_image_url')
  final String? displayImageUrl; // Can be null, use fallback
  final String? type; // 'private' or 'group' - optional, can be inferred
  @JsonKey(name: 'last_activity')
  final String? lastActivity; // Can be null in API response
  @JsonKey(name: 'last_message')
  final MessageModel? lastMessage;
  final int unreadCount; // Local calculated field

  const ConversationModel({
    required this.roomId,
    required this.name,
    required this.displayName,
    this.displayImageUrl,
    this.type,
    this.lastActivity,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);

  ConversationModel copyWith({
    int? roomId,
    String? name,
    String? displayName,
    String? displayImageUrl,
    String? type,
    String? lastActivity,
    MessageModel? lastMessage,
    int? unreadCount,
  }) {
    return ConversationModel(
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      displayImageUrl: displayImageUrl ?? this.displayImageUrl,
      type: type ?? this.type,
      lastActivity: lastActivity ?? this.lastActivity,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationModel &&
          runtimeType == other.runtimeType &&
          roomId == other.roomId;

  @override
  int get hashCode => roomId.hashCode;
}
