import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/conversation.dart';

abstract class MessagesRepository {
  Future<Either<Failure, List<ConversationListItem>>> getConversations({
    int? page,
    int pageSize = 20,
  });

  Future<Either<Failure, List<ChatMessage>>> getMessages(
    String conversationUid, {
    int? page,
    int pageSize = 30,
  });

  Future<Either<Failure, ChatMessage>> sendMessage({
    required String conversationUid,
    required String text,
    List<MessageMedia> media = const [],
  });

  Future<Either<Failure, Unit>> markRead(String conversationUid);

  /// Parse a raw WebSocket message payload into the app's [ChatMessage]
  /// entity. Factored out of the repo so blocs don't need DTO imports.
  ChatMessage parseSocketMessage(Map<String, dynamic> raw);

  // ── New DM / group creation ────────────────────────────────────────────────
  Future<Either<Failure, List<SearchUser>>> searchUsers(String q);

  Future<Either<Failure, ConversationListItem>> createPrivateConversation(
    int userId,
  );

  Future<Either<Failure, ConversationListItem>> createGroupConversation({
    required List<int> userIds,
    required String name,
  });

  // ── Message delete ─────────────────────────────────────────────────────────
  Future<Either<Failure, Unit>> deleteMessage(String messageUid);

  // ── Conversation management ────────────────────────────────────────────────
  /// Returns the new mute state.
  Future<Either<Failure, bool>> toggleMute(String conversationUid);

  Future<Either<Failure, Unit>> leaveGroup(String conversationUid);

  Future<Either<Failure, Unit>> deleteConversation(String conversationUid);

  Future<Either<Failure, ConversationDetail>> getConversationDetail(
    String conversationUid,
  );

  Future<Either<Failure, ConversationDetail>> updateGroupName({
    required String conversationUid,
    required String name,
  });

  Future<Either<Failure, ConversationDetail>> addMembers({
    required String conversationUid,
    required List<int> userIds,
  });

  Future<Either<Failure, Unit>> removeMember({
    required String conversationUid,
    required int userId,
  });
}
