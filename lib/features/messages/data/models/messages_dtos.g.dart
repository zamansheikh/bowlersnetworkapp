// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationsPageDto _$ConversationsPageDtoFromJson(
  Map<String, dynamic> json,
) => ConversationsPageDto(
  conversations: (json['conversations'] as List<dynamic>)
      .map((e) => ConversationListItemDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

ConversationListItemDto _$ConversationListItemDtoFromJson(
  Map<String, dynamic> json,
) => ConversationListItemDto(
  uid: json['uid'] as String,
  name: json['name'] as String,
  isGroup: json['is_group'] as bool? ?? false,
  imageUrl: json['image_url'] as String? ?? '',
  hasUnread: json['has_unread'] as bool? ?? false,
  lastMessage: json['last_message'] == null
      ? null
      : LastMessagePreviewDto.fromJson(
          json['last_message'] as Map<String, dynamic>,
        ),
  memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
  isMuted: json['is_muted'] as bool? ?? false,
);

LastMessagePreviewDto _$LastMessagePreviewDtoFromJson(
  Map<String, dynamic> json,
) => LastMessagePreviewDto(
  senderName: json['sender_name'] as String,
  text: json['text'] as String,
  createdAt: json['created_at'] as String?,
);

MessagesPageDto _$MessagesPageDtoFromJson(Map<String, dynamic> json) =>
    MessagesPageDto(
      messages: (json['messages'] as List<dynamic>)
          .map((e) => MessageDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

MessageDto _$MessageDtoFromJson(Map<String, dynamic> json) => MessageDto(
  uid: json['uid'] as String,
  sender: MessageSenderDto.fromJson(json['sender'] as Map<String, dynamic>),
  text: json['text'] as String? ?? '',
  media:
      (json['media'] as List<dynamic>?)
          ?.map((e) => MessageMediaDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  isDeleted: json['is_deleted'] as bool? ?? false,
  isOwn: json['is_own'] as bool? ?? false,
  createdAt: json['created_at'] as String?,
);

MessageSenderDto _$MessageSenderDtoFromJson(Map<String, dynamic> json) =>
    MessageSenderDto(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      profilePictureUrl: json['profile_picture_url'] as String?,
    );

MessageMediaDto _$MessageMediaDtoFromJson(Map<String, dynamic> json) =>
    MessageMediaDto(url: json['url'] as String, type: json['type'] as String);

ConversationDetailDto _$ConversationDetailDtoFromJson(
  Map<String, dynamic> json,
) => ConversationDetailDto(
  uid: json['uid'] as String,
  name: json['name'] as String,
  isGroup: json['is_group'] as bool? ?? false,
  imageUrl: json['image_url'] as String? ?? '',
  memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
  members:
      (json['members'] as List<dynamic>?)
          ?.map(
            (e) => ConversationMemberDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      const [],
  createdAt: json['created_at'] as String?,
);

ConversationMemberDto _$ConversationMemberDtoFromJson(
  Map<String, dynamic> json,
) => ConversationMemberDto(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  firstName: json['first_name'] as String? ?? '',
  lastName: json['last_name'] as String? ?? '',
  profilePictureUrl: json['profile_picture_url'] as String?,
);
