import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/messages_cubit.dart';
import '../cubit/messages_state.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../../data/models/conversation_model.dart';
import '../../../../core/constants/colors.dart';

class ConversationDetailPage extends StatefulWidget {
  final ConversationModel conversation;

  const ConversationDetailPage({super.key, required this.conversation});

  @override
  State<ConversationDetailPage> createState() => _ConversationDetailPageState();
}

class _ConversationDetailPageState extends State<ConversationDetailPage> {
  final ScrollController _messagesScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load messages for this conversation
    context.read<MessagesCubit>().selectConversation(widget.conversation);
  }

  @override
  void dispose() {
    _messagesScrollController.dispose();
    super.dispose();
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
                        context.read<MessagesCubit>().selectConversation(
                          widget.conversation,
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is MessagesLoaded) {
              return _buildChatView(state);
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildChatView(MessagesLoaded state) {
    return Container(
      color: Colors.white,
      height: double.infinity,
      child: Column(
        children: [
          // Custom Header
          _buildFigmaHeader(),

          // Messages
          Expanded(
            child: Container(
              color: Colors.white,
              child: state.messages.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      controller: _messagesScrollController,
                      padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        return MessageBubble(
                          message: state.messages[index],
                          showGroupInfo:
                              state.selectedConversation?.type == 'group',
                        );
                      },
                    ),
            ),
          ),

          // Message input
          MessageInput(
            conversationName: widget.conversation.displayName,
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
    );
  }

  Widget _buildFigmaHeader() {
    return Container(
      height: 72.h,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xFFE9E9E9), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.translucent,
            child: Container(
              width: 24.w,
              height: 24.h,
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_back_ios,
                size: 16.sp,
                color: const Color(0xFF111B05),
              ),
            ),
          ),

          SizedBox(width: 6.w),

          // Avatar
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: widget.conversation.displayImageUrl?.isNotEmpty == true
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: Image.network(
                      widget.conversation.displayImageUrl!,
                      width: 40.w,
                      height: 40.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildFallbackAvatar();
                      },
                    ),
                  )
                : _buildFallbackAvatar(),
          ),

          SizedBox(width: 8.w),

          // Name and Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.conversation.displayName,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: const Color(0xFF111B05),
                    height: 1.25,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Active Now',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.sp,
                    color: const Color(0xFF6D6D6D),
                    height: 1.33,
                  ),
                ),
              ],
            ),
          ),

          // More Options (3 dots menu)
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F9ED),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.more_vert,
              size: 20.sp,
              color: const Color(0xFF111B05),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[300],
      ),
      child: Center(
        child: Text(
          widget.conversation.displayName.isNotEmpty
              ? widget.conversation.displayName[0].toUpperCase()
              : '?',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message_outlined, size: 64.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              'No messages yet',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16.sp,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Start the conversation!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
