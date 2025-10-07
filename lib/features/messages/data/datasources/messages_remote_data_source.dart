import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/constants.dart';
import '../models/chat_rooms_response_model.dart';
import '../models/message_model.dart';
import '../models/available_member_model.dart';
import '../models/conversation_model.dart';
import '../models/message_sender_model.dart';
import '../models/time_details_model.dart';
import '../models/message_content_model.dart';

abstract class MessagesRemoteDataSource {
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

@LazySingleton(as: MessagesRemoteDataSource)
class MessagesRemoteDataSourceImpl implements MessagesRemoteDataSource {
  late final Dio _dio;
  final SharedPreferences _prefs;

  MessagesRemoteDataSourceImpl(this._prefs) {
    _configureDio();
  }

  void _configureDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          debugPrint('Message API Error: ${error.message}');
          debugPrint('Message API Error Response: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => debugPrint('[Messages API] $object'),
      ),
    );
  }

  String? _getAuthToken() {
    final token = _prefs.getString(AppConstants.tokenKey);
    debugPrint(
      'Auth token retrieved: ${token != null ? 'Token exists (${token.length} chars)' : 'No token found'}',
    );
    return token;
  }

  @override
  Future<ChatRoomsResponseModel> getChatRooms() async {
    try {
      final response = await _dio.get('/api/chat/rooms');
      return ChatRoomsResponseModel.fromJson(response.data);
    } catch (e) {
      debugPrint('Error fetching chat rooms: $e');
      // Return mock data for development
      return _getMockChatRooms();
    }
  }

  @override
  Future<List<MessageModel>> getMessages(int roomId) async {
    try {
      final response = await _dio.get('/api/chat/room/$roomId/messages');
      final List<dynamic> messagesJson = response.data;
      return messagesJson.map((json) => MessageModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching messages for room $roomId: $e');
      // Return mock messages for development
      return _getMockMessages(roomId);
    }
  }

  @override
  Future<MessageModel> sendMessage(
    int roomId,
    String text, {
    List<File>? mediaFiles,
  }) async {
    try {
      final formData = FormData();

      // Always add text field (can be empty)
      formData.fields.add(MapEntry('text', text));

      // Add media files if provided
      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        for (final file in mediaFiles) {
          final fileName = file.path.split('/').last;
          final multipartFile = await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          );
          // Use 'media' as field name to match web implementation
          formData.files.add(MapEntry('media', multipartFile));
        }
      }

      debugPrint(
        'Sending message to room $roomId with text: "$text" and ${mediaFiles?.length ?? 0} media files',
      );

      final response = await _dio.post(
        '/api/chat/room/$roomId/messages',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          validateStatus: (status) {
            return status != null &&
                status < 500; // Accept all responses except server errors
          },
        ),
        onSendProgress: (count, total) {
          final progress = (count / total * 100).toStringAsFixed(1);
          debugPrint('Upload progress: $progress%');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Message sent successfully: ${response.data}');
        return MessageModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to send message. Status: ${response.statusCode}, Data: ${response.data}',
        );
      }
    } catch (e) {
      debugPrint('Error sending message: $e');

      // Return mock sent message for development
      return _getMockSentMessage(roomId, text, mediaFiles);
    }
  }

  @override
  Future<ConversationModel> createConversation(String otherUsername) async {
    try {
      final response = await _dio.post(
        '/api/chat/rooms',
        data: {'other_username': otherUsername},
      );
      return ConversationModel.fromJson(response.data);
    } catch (e) {
      debugPrint('Error creating conversation: $e');
      // Return mock conversation for development
      return _getMockNewConversation(otherUsername);
    }
  }

  @override
  Future<List<AvailableMemberModel>> getAvailableMembers() async {
    try {
      final response = await _dio.get('/api/user-data');
      final List<dynamic> membersJson = response.data;
      return membersJson
          .map((json) => AvailableMemberModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching available members: $e');
      // Return mock members for development
      return _getMockAvailableMembers();
    }
  }

  // Mock data methods for development/fallback
  ChatRoomsResponseModel _getMockChatRooms() {
    return const ChatRoomsResponseModel(
      private: [
        ConversationModel(
          roomId: 1,
          name: 'john_doe',
          displayName: 'John Doe',
          displayImageUrl:
              'https://api.dicebear.com/7.x/avataaars/svg?seed=john',
          type: 'private',
          lastActivity: '2 min ago',
          unreadCount: 2,
        ),
        ConversationModel(
          roomId: 2,
          name: 'jane_smith',
          displayName: 'Jane Smith',
          displayImageUrl:
              'https://api.dicebear.com/7.x/avataaars/svg?seed=jane',
          type: 'private',
          lastActivity: '1 hour ago',
          unreadCount: 0,
        ),
      ],
      group: [
        ConversationModel(
          roomId: 3,
          name: 'bowling_team',
          displayName: 'Bowling Team',
          displayImageUrl:
              'https://api.dicebear.com/7.x/avataaars/svg?seed=team',
          type: 'group',
          lastActivity: '30 min ago',
          unreadCount: 5,
        ),
      ],
    );
  }

  List<MessageModel> _getMockMessages(int roomId) {
    return [
      MessageModel(
        sentByMe: false,
        roomId: roomId,
        sender: const MessageSenderModel(
          userId: 2,
          username: 'john_doe',
          name: 'John Doe',
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          profilePictureUrl:
              'https://api.dicebear.com/7.x/avataaars/svg?seed=john',
        ),
        timeDetails: const TimeDetailsModel(
          sentAt: '2024-01-15T10:30:00Z',
          timesince: '5 min ago',
        ),
        message: const MessageContentModel(
          text: 'Hey! How did your bowling practice go today?',
          media: [],
        ),
      ),
      MessageModel(
        sentByMe: true,
        roomId: roomId,
        sender: const MessageSenderModel(
          userId: 1,
          username: 'me',
          name: 'You',
          firstName: 'You',
          lastName: '',
          email: 'me@example.com',
          profilePictureUrl:
              'https://api.dicebear.com/7.x/avataaars/svg?seed=me',
        ),
        timeDetails: const TimeDetailsModel(
          sentAt: '2024-01-15T10:32:00Z',
          timesince: '3 min ago',
        ),
        message: const MessageContentModel(
          text: 'It went great! Got a new personal best score of 185!',
          media: [],
        ),
      ),
    ];
  }

  MessageModel _getMockSentMessage(
    int roomId,
    String text,
    List<File>? mediaFiles,
  ) {
    return MessageModel(
      sentByMe: true,
      roomId: roomId,
      sender: const MessageSenderModel(
        userId: 1,
        username: 'me',
        name: 'You',
        firstName: 'You',
        lastName: '',
        email: 'me@example.com',
        profilePictureUrl: 'https://api.dicebear.com/7.x/avataaars/svg?seed=me',
      ),
      timeDetails: TimeDetailsModel(
        sentAt: DateTime.now().toIso8601String(),
        timesince: 'now',
      ),
      message: MessageContentModel(
        text: text,
        media: mediaFiles?.map((f) => f.path).toList() ?? [],
      ),
    );
  }

  ConversationModel _getMockNewConversation(String otherUsername) {
    return ConversationModel(
      roomId: DateTime.now().millisecondsSinceEpoch,
      name: otherUsername,
      displayName: otherUsername
          .replaceAll('_', ' ')
          .split(' ')
          .map(
            (word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1)
                : '',
          )
          .join(' '),
      displayImageUrl:
          'https://api.dicebear.com/7.x/avataaars/svg?seed=$otherUsername',
      type: 'private',
      lastActivity: 'now',
      unreadCount: 0,
    );
  }

  List<AvailableMemberModel> _getMockAvailableMembers() {
    return [
      const AvailableMemberModel(
        userId: 3,
        username: 'sarah_wilson',
        name: 'Sarah Wilson',
        firstName: 'Sarah',
        lastName: 'Wilson',
        email: 'sarah@example.com',
        profilePictureUrl:
            'https://api.dicebear.com/7.x/avataaars/svg?seed=sarah',
      ),
      const AvailableMemberModel(
        userId: 4,
        username: 'mike_johnson',
        name: 'Mike Johnson',
        firstName: 'Mike',
        lastName: 'Johnson',
        email: 'mike@example.com',
        profilePictureUrl:
            'https://api.dicebear.com/7.x/avataaars/svg?seed=mike',
      ),
      const AvailableMemberModel(
        userId: 5,
        username: 'lisa_brown',
        name: 'Lisa Brown',
        firstName: 'Lisa',
        lastName: 'Brown',
        email: 'lisa@example.com',
        profilePictureUrl:
            'https://api.dicebear.com/7.x/avataaars/svg?seed=lisa',
      ),
    ];
  }
}
