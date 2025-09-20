import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/messages_cubit.dart';
import '../cubit/messages_state.dart';
import '../widgets/conversation_list_item.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/new_message_modal.dart';
import '../../data/models/available_member_model.dart';
import '../../../../core/constants/colors.dart';

class MessagesPage extends StatefulWidget {
  final int? targetRoomId;

  const MessagesPage({super.key, this.targetRoomId});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _messagesScrollController = ScrollController();
  String _selectedFilter = 'all';
  List<AvailableMemberModel> _availableMembers = [];
  bool _loadingMembers = false;
  bool _showConversationsList = true; // For mobile navigation

  @override
  void initState() {
    super.initState();

    // Load conversations
    context.read<MessagesCubit>().loadConversations();

    // If there's a target room ID, we'll handle it when conversations are loaded
    if (widget.targetRoomId != null) {
      setState(() {
        _showConversationsList = false; // Jump directly to chat view on mobile
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messagesScrollController.dispose();
    super.dispose();
  }

  void _showNewMessageModalDialog() async {
    if (_availableMembers.isEmpty && !_loadingMembers) {
      setState(() {
        _loadingMembers = true;
      });

      try {
        final members = await context
            .read<MessagesCubit>()
            .loadAvailableMembers();
        setState(() {
          _availableMembers = members;
          _loadingMembers = false;
        });
      } catch (e) {
        setState(() {
          _loadingMembers = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to load members: $e')));
        }
        return;
      }
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => NewMessageModal(
          availableMembers: _availableMembers,
          isLoading: _loadingMembers,
          onMemberSelected: (member) {
            context.read<MessagesCubit>().createConversation(member.username);
            Navigator.of(context).pop();
          },
          onClose: () {
            Navigator.of(context).pop();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocConsumer<MessagesCubit, MessagesState>(
            listener: (context, state) {
              if (state is MessagesError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is MessagesLoading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.primaryLimeGreen,
                      ),
                      SizedBox(height: 16),
                      Text('Loading messages...'),
                    ],
                  ),
                );
              }

              if (state is MessagesError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.message}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<MessagesCubit>().loadConversations();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is MessagesLoaded) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Check if we're on a small screen (mobile)
                    final isSmallScreen = constraints.maxWidth < 800;

                    if (isSmallScreen) {
                      // Mobile layout: show either conversations list OR chat view
                      if (_showConversationsList ||
                          state.selectedConversation == null) {
                        return _buildConversationsList(state);
                      } else {
                        return _buildChatView(state);
                      }
                    } else {
                      // Desktop layout: show both side by side
                      return Row(
                        children: [
                          // Conversations List - wider on desktop
                          Container(
                            width: constraints.maxWidth * 0.4,
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            child: _buildConversationsList(state),
                          ),

                          // Chat Area
                          Expanded(
                            child: state.selectedConversation == null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.forum_outlined,
                                          size: 80,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Select a conversation to start messaging',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : _buildChatView(state),
                          ),
                        ],
                      );
                    }
                  },
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  Widget _buildConversationsList(MessagesLoaded state) {
    return Column(
      children: [
        // Header with search and filters
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            children: [
              // Title and new message button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.message,
                        color: AppColors.primaryLimeGreen,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Messages',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _showNewMessageModalDialog,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryLimeGreen,
                      foregroundColor: Colors.white,
                      fixedSize: const Size(36, 36),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search messages...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(
                      color: AppColors.primaryLimeGreen,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  context.read<MessagesCubit>().updateSearchQuery(value);
                },
              ),

              const SizedBox(height: 16),

              // Filter chips
              Row(
                children: ['all', 'private', 'group'].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        filter.capitalize(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                        context.read<MessagesCubit>().updateFilterType(filter);
                      },
                      selectedColor: AppColors.primaryLimeGreen,
                      backgroundColor: Colors.grey[100],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // Conversations list
        Expanded(
          child: state.filteredConversations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.message_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No conversations found',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: state.filteredConversations.length,
                  itemBuilder: (context, index) {
                    final conversation = state.filteredConversations[index];
                    return ConversationListItem(
                      conversation: conversation,
                      isSelected:
                          state.selectedConversation?.roomId ==
                          conversation.roomId,
                      onTap: () {
                        context.read<MessagesCubit>().selectConversation(
                          conversation,
                        );
                        setState(() {
                          _showConversationsList =
                              false; // Switch to chat view on mobile
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildChatView(MessagesLoaded state) {
    return Column(
      children: [
        // Chat header with back button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              // Only show back button on mobile
              if (MediaQuery.of(context).size.width < 800)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showConversationsList =
                          true; // Go back to conversations list
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (MediaQuery.of(context).size.width < 800)
                const SizedBox(width: 8),
              CircleAvatar(
                radius: 20,
                backgroundImage:
                    state.selectedConversation!.displayImageUrl.isNotEmpty
                    ? NetworkImage(state.selectedConversation!.displayImageUrl)
                    : null,
                backgroundColor: Colors.grey[300],
                onBackgroundImageError: (_, __) {
                  print(
                    'Failed to load chat header image: ${state.selectedConversation!.displayImageUrl}',
                  );
                },
                child: state.selectedConversation!.displayImageUrl.isEmpty
                    ? Text(
                        state.selectedConversation!.displayName.isNotEmpty
                            ? state.selectedConversation!.displayName[0]
                                  .toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.selectedConversation!.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      state.selectedConversation!.type == 'group'
                          ? 'Group conversation'
                          : 'Private conversation',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Show conversation options
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: state.messages.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.message_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No messages yet',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Text(
                        'Start the conversation!',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _messagesScrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    return MessageBubble(
                      message: message,
                      showGroupInfo:
                          state.selectedConversation!.type == 'group',
                    );
                  },
                ),
        ),

        // Message input
        MessageInput(
          conversationName: state.selectedConversation!.displayName,
          isLoading: state is MessagesSending,
          onSendMessage: (text, mediaFiles) {
            context.read<MessagesCubit>().sendMessage(
              text,
              mediaFiles: mediaFiles,
            );
          },
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
