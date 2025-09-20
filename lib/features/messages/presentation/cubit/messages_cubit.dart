import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/messages_repository.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/available_member_model.dart';
import 'messages_state.dart';

@injectable
class MessagesCubit extends Cubit<MessagesState> {
  final MessagesRepository _repository;
  Timer? _pollingTimer;

  MessagesCubit(this._repository) : super(MessagesInitial());

  // Load initial chat rooms and conversations
  Future<void> loadConversations() async {
    emit(MessagesLoading());

    try {
      final chatRoomsResponse = await _repository.getChatRooms();
      final allConversations = [
        ...chatRoomsResponse.private.map(
          (conv) => conv.copyWith(type: 'private'),
        ),
        ...chatRoomsResponse.group.map((conv) => conv.copyWith(type: 'group')),
      ];

      emit(MessagesLoaded(conversations: allConversations, messages: []));
    } catch (e) {
      emit(MessagesError('Failed to load conversations: $e'));
    }
  }

  // Select a conversation and load its messages
  Future<void> selectConversation(ConversationModel conversation) async {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      // Update selected conversation immediately for UI responsiveness
      emit(currentState.copyWith(selectedConversation: conversation));

      try {
        final messages = await _repository.getMessages(conversation.roomId);

        // Update conversation as read (reset unread count)
        final updatedConversations = currentState.conversations
            .map(
              (conv) => conv.roomId == conversation.roomId
                  ? conv.copyWith(unreadCount: 0)
                  : conv,
            )
            .toList();

        emit(
          currentState.copyWith(
            conversations: updatedConversations,
            selectedConversation: conversation.copyWith(unreadCount: 0),
            messages: messages,
          ),
        );

        // Start polling for new messages
        _startMessagePolling(conversation.roomId);
      } catch (e) {
        emit(MessagesError('Failed to load messages: $e'));
      }
    }
  }

  // Send a message
  Future<void> sendMessage(String text, {List<File>? mediaFiles}) async {
    final currentState = state;
    if (currentState is MessagesLoaded &&
        currentState.selectedConversation != null) {
      final conversation = currentState.selectedConversation!;

      // Show sending state
      emit(
        MessagesSending(
          conversations: currentState.conversations,
          selectedConversation: currentState.selectedConversation,
          messages: currentState.messages,
          searchQuery: currentState.searchQuery,
          filterType: currentState.filterType,
        ),
      );

      try {
        final newMessage = await _repository.sendMessage(
          conversation.roomId,
          text,
          mediaFiles: mediaFiles,
        );

        // Add the new message to the list
        final updatedMessages = [...currentState.messages, newMessage];

        // Update the conversation's last message
        final updatedConversations = currentState.conversations
            .map(
              (conv) => conv.roomId == conversation.roomId
                  ? conv.copyWith(lastMessage: newMessage)
                  : conv,
            )
            .toList();

        emit(
          MessagesLoaded(
            conversations: updatedConversations,
            selectedConversation: currentState.selectedConversation,
            messages: updatedMessages,
            searchQuery: currentState.searchQuery,
            filterType: currentState.filterType,
          ),
        );
      } catch (e) {
        emit(MessagesError('Failed to send message: $e'));
      }
    }
  }

  // Create a new conversation
  Future<void> createConversation(String otherUsername) async {
    try {
      final newConversation = await _repository.createConversation(
        otherUsername,
      );

      // Refresh conversations to include the new one
      await loadConversations();

      // Select the new conversation
      await selectConversation(newConversation);
    } catch (e) {
      emit(MessagesError('Failed to create conversation: $e'));
    }
  }

  // Load available members for new conversation
  Future<List<AvailableMemberModel>> loadAvailableMembers() async {
    try {
      return await _repository.getAvailableMembers();
    } catch (e) {
      print('Failed to load available members: $e');
      return [];
    }
  }

  // Update search query
  void updateSearchQuery(String query) {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      emit(currentState.copyWith(searchQuery: query));
    }
  }

  // Update filter type
  void updateFilterType(String filterType) {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      emit(currentState.copyWith(filterType: filterType));
    }
  }

  // Start polling for new messages
  void _startMessagePolling(int roomId) {
    _stopMessagePolling();

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _pollForNewMessages(roomId);
    });
  }

  // Stop message polling
  void _stopMessagePolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // Poll for new messages
  Future<void> _pollForNewMessages(int roomId) async {
    final currentState = state;
    if (currentState is MessagesLoaded &&
        currentState.selectedConversation?.roomId == roomId) {
      try {
        final newMessages = await _repository.getMessages(roomId);

        // Only update if there are new messages
        if (newMessages.length > currentState.messages.length) {
          emit(currentState.copyWith(messages: newMessages));
        }
      } catch (e) {
        // Silent fail for polling errors
        print('Polling error: $e');
      }
    }
  }

  // Refresh conversations
  Future<void> refreshConversations() async {
    await loadConversations();
  }

  @override
  Future<void> close() {
    _stopMessagePolling();
    return super.close();
  }
}
