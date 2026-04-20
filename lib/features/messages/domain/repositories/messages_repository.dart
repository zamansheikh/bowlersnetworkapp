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
}
