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

  @override
  void initState() {
    super.initState();
    // Load conversations when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessagesCubit>().loadConversations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messagesScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_messagesScrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _messagesScrollController.animateTo(
          _messagesScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _showNewMessageModalDialog() async {
    setState(() {
      _loadingMembers = true;
    });

    final members = await context.read<MessagesCubit>().loadAvailableMembers();

    setState(() {
      _availableMembers = members;
      _loadingMembers = false;
    });

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => NewMessageModal(
          availableMembers: _availableMembers,
          isLoading: _loadingMembers,
          onMemberSelected: (member) {
            Navigator.of(context).pop();
            context.read<MessagesCubit>().createConversation(member.username);
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<MessagesCubit, MessagesState>(
          listener: (context, state) {
            if (state is MessagesLoaded && state.messages.isNotEmpty) {
              _scrollToBottom();
            }
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
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MessagesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Something went wrong',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<MessagesCubit>().loadConversations();
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            if (state is MessagesLoaded) {
              return Row(
                children: [
                  // Conversations sidebar
                  Container(
                    width: MediaQuery.of(context).size.width * 0.35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        right: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header with search and filters
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Title and new message button
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    onPressed: _showNewMessageModalDialog,
                                    icon: const Icon(Icons.add),
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          AppColors.primaryLimeGreen,
                                      foregroundColor: Colors.white,
                                      fixedSize: const Size(32, 32),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Search bar
                              TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search messages...',
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    size: 20,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                      color: AppColors.primaryLimeGreen,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                onChanged: (value) {
                                  context
                                      .read<MessagesCubit>()
                                      .updateSearchQuery(value);
                                },
                              ),

                              const SizedBox(height: 12),

                              // Filter chips
                              Row(
                                children: ['all', 'private', 'group'].map((
                                  filter,
                                ) {
                                  final isSelected = _selectedFilter == filter;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(
                                        filter.capitalize(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey[600],
                                        ),
                                      ),
                                      selected: isSelected,
                                      onSelected: (selected) {
                                        setState(() {
                                          _selectedFilter = filter;
                                        });
                                        context
                                            .read<MessagesCubit>()
                                            .updateFilterType(filter);
                                      },
                                      selectedColor: AppColors.primaryLimeGreen,
                                      backgroundColor: Colors.grey[100],
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
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
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No conversations found',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: state.filteredConversations.length,
                                  itemBuilder: (context, index) {
                                    final conversation =
                                        state.filteredConversations[index];
                                    return ConversationListItem(
                                      conversation: conversation,
                                      isSelected:
                                          state.selectedConversation?.roomId ==
                                          conversation.roomId,
                                      onTap: () {
                                        context
                                            .read<MessagesCubit>()
                                            .selectConversation(conversation);
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),

                  // Messages area
                  Expanded(
                    child: state.selectedConversation == null
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
                                  'Select a conversation to start messaging',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              // Chat header
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(
                                        state
                                            .selectedConversation!
                                            .displayImageUrl,
                                      ),
                                      backgroundColor: Colors.grey[300],
                                      onBackgroundImageError: (_, __) {},
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            state
                                                .selectedConversation!
                                                .displayName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            state.selectedConversation!.type ==
                                                    'group'
                                                ? 'Group conversation'
                                                : 'Private conversation',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.message_outlined,
                                              size: 64,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(height: 16),
                                            Text(
                                              'No messages yet',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              'Start the conversation!',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        controller: _messagesScrollController,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        itemCount: state.messages.length,
                                        itemBuilder: (context, index) {
                                          final message = state.messages[index];
                                          return MessageBubble(
                                            message: message,
                                            showGroupInfo:
                                                state
                                                    .selectedConversation!
                                                    .type ==
                                                'group',
                                          );
                                        },
                                      ),
                              ),

                              // Message input
                              MessageInput(
                                conversationName:
                                    state.selectedConversation!.displayName,
                                isLoading: state is MessagesSending,
                                onSendMessage: (text, mediaFiles) {
                                  context.read<MessagesCubit>().sendMessage(
                                    text,
                                    mediaFiles: mediaFiles,
                                  );
                                },
                              ),
                            ],
                          ),
                  ),
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
