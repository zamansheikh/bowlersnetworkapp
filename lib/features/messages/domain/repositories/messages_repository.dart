import 'dart:io';
import '../../data/models/chat_rooms_response_model.dart';
import '../../data/models/message_model.dart';
import '../../data/models/available_member_model.dart';
import '../../data/models/conversation_model.dart';

abstract class MessagesRepository {
  Future<ChatRoomsResponseModel> getChatRooms();
  Future<List<MessageModel>> getMessages(int roomId);
  Future<MessageModel> sendMessage(
    int roomId,
    String text, {
    List<File>? mediaFiles,
  });
  Future<ConversationModel> createConversation(String otherUsername);
  Future<List<AvailableMemberModel>> getAvailableMembers();
}
