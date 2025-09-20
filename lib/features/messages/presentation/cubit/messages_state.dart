import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';
import '../../data/models/available_member_model.dart';

abstract class MessagesState {}

class MessagesInitial extends MessagesState {}

class MessagesLoading extends MessagesState {}

class MessagesLoaded extends MessagesState {
  final List<ConversationModel> conversations;
  final ConversationModel? selectedConversation;
  final List<MessageModel> messages;
  final String searchQuery;
  final String filterType; // 'all', 'private', 'group'

  MessagesLoaded({
    required this.conversations,
    this.selectedConversation,
    required this.messages,
    this.searchQuery = '',
    this.filterType = 'all',
  });

  MessagesLoaded copyWith({
    List<ConversationModel>? conversations,
    ConversationModel? selectedConversation,
    List<MessageModel>? messages,
    String? searchQuery,
    String? filterType,
    bool clearSelectedConversation = false,
  }) {
    return MessagesLoaded(
      conversations: conversations ?? this.conversations,
      selectedConversation: clearSelectedConversation
          ? null
          : (selectedConversation ?? this.selectedConversation),
      messages: messages ?? this.messages,
      searchQuery: searchQuery ?? this.searchQuery,
      filterType: filterType ?? this.filterType,
    );
  }

  List<ConversationModel> get filteredConversations {
    var filtered = conversations.where((conversation) {
      // Search filter
      final lastMessageText = conversation.lastMessage?.message.text ?? '';
      final matchesSearch =
          conversation.displayName.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ||
          lastMessageText.toLowerCase().contains(searchQuery.toLowerCase());

      // Type filter
      final matchesFilter =
          filterType == 'all' ||
          (filterType == 'private' && conversation.type == 'private') ||
          (filterType == 'group' && conversation.type == 'group');

      return matchesSearch && matchesFilter;
    }).toList();

    // Sort by last activity
    filtered.sort((a, b) {
      // Put conversations with unread messages first
      if (a.unreadCount > 0 && b.unreadCount == 0) return -1;
      if (a.unreadCount == 0 && b.unreadCount > 0) return 1;

      // Then sort by last activity (for now just by room ID as proxy)
      return b.roomId.compareTo(a.roomId);
    });

    return filtered;
  }
}

class MessagesError extends MessagesState {
  final String message;

  MessagesError(this.message);
}

class MessagesSending extends MessagesState {
  final List<ConversationModel> conversations;
  final ConversationModel? selectedConversation;
  final List<MessageModel> messages;
  final String searchQuery;
  final String filterType;

  MessagesSending({
    required this.conversations,
    this.selectedConversation,
    required this.messages,
    this.searchQuery = '',
    this.filterType = 'all',
  });
}

class MessagesNewConversationLoading extends MessagesState {
  final List<AvailableMemberModel> availableMembers;
  final bool isLoadingMembers;

  MessagesNewConversationLoading({
    this.availableMembers = const [],
    this.isLoadingMembers = false,
  });

  MessagesNewConversationLoading copyWith({
    List<AvailableMemberModel>? availableMembers,
    bool? isLoadingMembers,
  }) {
    return MessagesNewConversationLoading(
      availableMembers: availableMembers ?? this.availableMembers,
      isLoadingMembers: isLoadingMembers ?? this.isLoadingMembers,
    );
  }
}
