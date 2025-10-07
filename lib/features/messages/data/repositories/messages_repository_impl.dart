import 'dart:io';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/messages_repository.dart';
import '../datasources/messages_remote_data_source.dart';
import '../models/chat_rooms_response_model.dart';
import '../models/message_model.dart';
import '../models/available_member_model.dart';
import '../models/conversation_model.dart';

@LazySingleton(as: MessagesRepository)
class MessagesRepositoryImpl implements MessagesRepository {
  final MessagesRemoteDataSource _remoteDataSource;

  MessagesRepositoryImpl(this._remoteDataSource);

  @override
  Future<ChatRoomsResponseModel> getChatRooms() async {
    try {
      return await _remoteDataSource.getChatRooms();
    } catch (e) {
      debugPrint('Repository Error fetching chat rooms: $e');
      rethrow;
    }
  }

  @override
  Future<List<MessageModel>> getMessages(int roomId) async {
    try {
      return await _remoteDataSource.getMessages(roomId);
    } catch (e) {
      debugPrint('Repository Error fetching messages for room $roomId: $e');
      rethrow;
    }
  }

  @override
  Future<MessageModel> sendMessage(
    int roomId,
    String text, {
    List<File>? mediaFiles,
  }) async {
    try {
      return await _remoteDataSource.sendMessage(
        roomId,
        text,
        mediaFiles: mediaFiles,
      );
    } catch (e) {
      debugPrint('Repository Error sending message: $e');
      rethrow;
    }
  }

  @override
  Future<ConversationModel> createConversation(String otherUsername) async {
    try {
      return await _remoteDataSource.createConversation(otherUsername);
    } catch (e) {
      debugPrint('Repository Error creating conversation: $e');
      rethrow;
    }
  }

  @override
  Future<List<AvailableMemberModel>> getAvailableMembers() async {
    try {
      return await _remoteDataSource.getAvailableMembers();
    } catch (e) {
      debugPrint('Repository Error fetching available members: $e');
      rethrow;
    }
  }
}
