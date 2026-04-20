import 'package:json_annotation/json_annotation.dart';

part 'messages_dtos.g.dart';

// ──────────────────────────────────────────────────────────────────────────────
// GET /api/messages/conversations
// ──────────────────────────────────────────────────────────────────────────────
@JsonSerializable(createToJson: false)
class ConversationsPageDto {
  const ConversationsPageDto({required this.conversations});
  final List<ConversationListItemDto> conversations;

  factory ConversationsPageDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationsPageDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ConversationListItemDto {
  const ConversationListItemDto({
    required this.uid,
    required this.name,
    this.isGroup = false,
    this.imageUrl = '',
    this.hasUnread = false,
    this.lastMessage,
    this.memberCount = 0,
    this.isMuted = false,
  });

  final String uid;
  @JsonKey(name: 'is_group', defaultValue: false)
  final bool isGroup;
  final String name;
  @JsonKey(name: 'image_url', defaultValue: '')
  final String imageUrl;
  @JsonKey(name: 'has_unread', defaultValue: false)
  final bool hasUnread;
  @JsonKey(name: 'last_message')
  final LastMessagePreviewDto? lastMessage;
  @JsonKey(name: 'member_count', defaultValue: 0)
  final int memberCount;
  @JsonKey(name: 'is_muted', defaultValue: false)
  final bool isMuted;

  factory ConversationListItemDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationListItemDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class LastMessagePreviewDto {
  const LastMessagePreviewDto({
    required this.senderName,
    required this.text,
    this.createdAt,
  });

  @JsonKey(name: 'sender_name')
  final String senderName;
  final String text;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  factory LastMessagePreviewDto.fromJson(Map<String, dynamic> json) =>
      _$LastMessagePreviewDtoFromJson(json);
}

// ──────────────────────────────────────────────────────────────────────────────
// GET /api/messages/conversations/<uid>/messages
// ──────────────────────────────────────────────────────────────────────────────
@JsonSerializable(createToJson: false)
class MessagesPageDto {
  const MessagesPageDto({required this.messages});
  final List<MessageDto> messages;

  factory MessagesPageDto.fromJson(Map<String, dynamic> json) =>
      _$MessagesPageDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class MessageDto {
  const MessageDto({
    required this.uid,
    required this.sender,
    this.text = '',
    this.media = const [],
    this.isDeleted = false,
    this.isOwn = false,
    this.createdAt,
  });

  final String uid;
  final MessageSenderDto sender;
  @JsonKey(defaultValue: '')
  final String text;
  @JsonKey(defaultValue: [])
  final List<MessageMediaDto> media;
  @JsonKey(name: 'is_deleted', defaultValue: false)
  final bool isDeleted;
  @JsonKey(name: 'is_own', defaultValue: false)
  final bool isOwn;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class MessageSenderDto {
  const MessageSenderDto({
    required this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
  });

  final int id;
  final String username;
  @JsonKey(name: 'first_name', defaultValue: '')
  final String firstName;
  @JsonKey(name: 'last_name', defaultValue: '')
  final String lastName;
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;

  factory MessageSenderDto.fromJson(Map<String, dynamic> json) =>
      _$MessageSenderDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class MessageMediaDto {
  const MessageMediaDto({required this.url, required this.type});
  final String url;
  final String type;

  factory MessageMediaDto.fromJson(Map<String, dynamic> json) =>
      _$MessageMediaDtoFromJson(json);
}

// ──────────────────────────────────────────────────────────────────────────────
// GET /api/messages/conversations/<uid>
// ──────────────────────────────────────────────────────────────────────────────
@JsonSerializable(createToJson: false)
class ConversationDetailDto {
  const ConversationDetailDto({
    required this.uid,
    required this.name,
    this.isGroup = false,
    this.imageUrl = '',
    this.memberCount = 0,
    this.members = const [],
    this.createdAt,
  });

  final String uid;
  final String name;
  @JsonKey(name: 'is_group', defaultValue: false)
  final bool isGroup;
  @JsonKey(name: 'image_url', defaultValue: '')
  final String imageUrl;
  @JsonKey(name: 'member_count', defaultValue: 0)
  final int memberCount;
  final List<ConversationMemberDto> members;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  factory ConversationDetailDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationDetailDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ConversationMemberDto {
  const ConversationMemberDto({
    required this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
  });

  final int id;
  final String username;
  @JsonKey(name: 'first_name', defaultValue: '')
  final String firstName;
  @JsonKey(name: 'last_name', defaultValue: '')
  final String lastName;
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;

  factory ConversationMemberDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationMemberDtoFromJson(json);
}
