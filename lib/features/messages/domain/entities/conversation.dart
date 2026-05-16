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
    String? name,
    String? imageUrl,
    bool? hasUnread,
    LastMessagePreview? lastMessage,
    int? memberCount,
    bool? isMuted,
  }) {
    return ConversationListItem(
      uid: uid,
      name: name ?? this.name,
      isGroup: isGroup,
      imageUrl: imageUrl ?? this.imageUrl,
      hasUnread: hasUnread ?? this.hasUnread,
      lastMessage: lastMessage ?? this.lastMessage,
      memberCount: memberCount ?? this.memberCount,
      isMuted: isMuted ?? this.isMuted,
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

  ChatMessage copyWith({bool? isDeleted, String? text, bool? isOwn}) =>
      ChatMessage(
        uid: uid,
        sender: sender,
        text: text ?? this.text,
        media: media,
        isDeleted: isDeleted ?? this.isDeleted,
        isOwn: isOwn ?? this.isOwn,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props =>
      [uid, sender, text, media, isDeleted, isOwn, createdAt];
}

/// Full conversation detail from GET `/api/messages/conversations/<uid>` —
/// carries fields not in the list payload (members, isCreator, isMuted).
class ConversationDetail extends Equatable {
  const ConversationDetail({
    required this.uid,
    required this.name,
    required this.isGroup,
    required this.imageUrl,
    required this.memberCount,
    required this.isCreator,
    required this.isMuted,
    this.members = const [],
    this.createdAt,
  });

  final String uid;
  final String name;
  final bool isGroup;
  final String imageUrl;
  final int memberCount;
  final bool isCreator;
  final bool isMuted;
  final List<ConversationMember> members;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        uid,
        name,
        isGroup,
        imageUrl,
        memberCount,
        isCreator,
        isMuted,
        members,
        createdAt,
      ];
}

class ConversationMember extends Equatable {
  const ConversationMember({
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

  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? username : full;
  }

  @override
  List<Object?> get props =>
      [id, username, firstName, lastName, profilePictureUrl];
}

/// Person returned by `/api/users/search` — shown in the new-DM /
/// new-group pickers.
class SearchUser extends Equatable {
  const SearchUser({
    required this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.rankDisplay,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;
  final String? rankDisplay;

  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? username : full;
  }

  @override
  List<Object?> get props =>
      [id, username, firstName, lastName, profilePictureUrl, rankDisplay];
}
