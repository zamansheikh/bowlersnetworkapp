import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/conversation_model.dart';
import '../cubit/messages_cubit.dart';
import '../cubit/messages_state.dart';
import '../widgets/new_message_modal.dart';
import '../../data/models/available_member_model.dart';
import 'conversation_detail_page.dart';
import '../../../../core/constants/colors.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  String _selectedFilter = 'All';
  List<AvailableMemberModel> _availableMembers = [];
  bool _loadingMembers = false;

  @override
  void initState() {
    super.initState();
    // Load conversations
    context.read<MessagesCubit>().loadConversations();
  }

  @override
  void dispose() {
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
      backgroundColor: Colors.white,
      body: SafeArea(
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
              return _buildFigmaMessagesContent(state);
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildFigmaMessagesContent(MessagesLoaded state) {
    return Container(
      color: Colors.white,
      height: double.infinity,
      child: Column(
        children: [
          // Custom Header
          _buildFigmaHeader(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 16.h),

                  // Filter Tabs
                  _buildFigmaFilterTabs(),

                  SizedBox(height: 12.h),

                  // Conversations List
                  Column(
                    children: [
                      for (
                        int i = 0;
                        i < state.filteredConversations.length;
                        i++
                      )
                        _buildFigmaConversationItem(
                          state.filteredConversations[i],
                        ),
                    ],
                  ),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFigmaHeader() {
    return Container(
      height: 56.h,
      width: 375.w,
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Messages',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 20.sp,
                color: const Color(0xFF111B05),
              ),
            ),
          ),
          Container(
            width: 32.w,
            height: 32.h,
            decoration: const BoxDecoration(
              color: Color(0xFF8BC342),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _showNewMessageModalDialog,
              icon: Icon(Icons.add, size: 16.sp, color: Colors.white),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFigmaFilterTabs() {
    return Row(
      children: [
        Expanded(child: _buildFigmaFilterTab('All', _selectedFilter == 'All')),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildFigmaFilterTab('Group', _selectedFilter == 'Group'),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildFigmaFilterTab('Private', _selectedFilter == 'Private'),
        ),
      ],
    );
  }

  Widget _buildFigmaFilterTab(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
        context.read<MessagesCubit>().updateFilterType(label.toLowerCase());
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFF8BC342),
                borderRadius: BorderRadius.circular(40.r),
              )
            : BoxDecoration(
                border: Border.all(color: const Color(0xFFE8E8E8)),
                borderRadius: BorderRadius.circular(40.r),
              ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14.sp,
            color: isSelected ? const Color(0xFF101010) : Colors.grey,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildFigmaConversationItem(ConversationModel conversation) {
    // Extract unread count logic - for now, we'll simulate some conversations having unread messages
    final hasUnreadMessages =
        conversation.roomId % 3 == 0; // Simulate some unread messages
    final unreadCount = hasUnreadMessages ? (conversation.roomId % 5) + 1 : 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Navigate to conversation detail page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ConversationDetailPage(conversation: conversation),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: conversation.displayImageUrl?.isNotEmpty == true
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(24.r),
                      child: Image.network(
                        conversation.displayImageUrl!,
                        width: 48.w,
                        height: 48.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildFallbackAvatar(conversation.displayName);
                        },
                      ),
                    )
                  : _buildFallbackAvatar(conversation.displayName),
            ),

            SizedBox(width: 8.w),

            // Name and Last Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation.displayName,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      color: const Color(0xFF404040), // neutral-700
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    conversation.lastMessage?.message.text ?? 'No messages yet',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                      color: const Color(0xFF6D6D6D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Time and Unread Count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  conversation.lastActivity ?? 'Unknown',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    color: const Color(0xFF616161),
                  ),
                ),
                if (hasUnreadMessages) ...[
                  SizedBox(height: 6.h),
                  Container(
                    width: 20.w,
                    height: 20.h,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8BC342),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount.toString(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          color: const Color(0xFF111B05),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar(String displayName) {
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: Center(
        child: Text(
          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
