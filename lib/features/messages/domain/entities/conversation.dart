import 'package:equatable/equatable.dart';

class LastMessagePreview extends Equatable {
  const LastMessagePreview({
    required this.senderName,
    required this.text,
    this.createdAt,
  });

  final String senderName;
  final String text;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [senderName, text, createdAt];
}

class ConversationListItem extends Equatable {
  const ConversationListItem({
    required this.uid,
    required this.name,
    required this.isGroup,
    this.imageUrl = '',
    this.hasUnread = false,
    this.lastMessage,
    this.memberCount = 0,
    this.isMuted = false,
  });

  final String uid;
  final String name;
  final bool isGroup;
  final String imageUrl;
  final bool hasUnread;
  final LastMessagePreview? lastMessage;
  final int memberCount;
  final bool isMuted;

  ConversationListItem copyWith({
    bool? hasUnread,
    LastMessagePreview? lastMessage,
  }) {
    return ConversationListItem(
      uid: uid,
      name: name,
      isGroup: isGroup,
      imageUrl: imageUrl,
      hasUnread: hasUnread ?? this.hasUnread,
      lastMessage: lastMessage ?? this.lastMessage,
      memberCount: memberCount,
      isMuted: isMuted,
    );
  }

  @override
  List<Object?> get props =>
      [uid, name, isGroup, imageUrl, hasUnread, lastMessage, memberCount, isMuted];
}

class MessageSender extends Equatable {
  const MessageSender({
    required this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;

  String get displayName =>
      '$firstName $lastName'.trim().isEmpty ? username : '$firstName $lastName'.trim();

  @override
  List<Object?> get props =>
      [id, username, firstName, lastName, profilePictureUrl];
}

class MessageMedia extends Equatable {
  const MessageMedia({required this.url, required this.type});
  final String url;
  final String type;

  @override
  List<Object?> get props => [url, type];
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.uid,
    required this.sender,
    required this.text,
    this.media = const [],
    this.isDeleted = false,
    this.isOwn = false,
    this.createdAt,
  });

  final String uid;
  final MessageSender sender;
  final String text;
  final List<MessageMedia> media;
  final bool isDeleted;
  final bool isOwn;
  final DateTime? createdAt;

  @override
  List<Object?> get props =>
      [uid, sender, text, media, isDeleted, isOwn, createdAt];
}
