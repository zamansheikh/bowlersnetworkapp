import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/messages_repository.dart';
import '../bloc/thread_bloc.dart';
import '../widgets/message_bubble.dart';

class ThreadScreen extends StatelessWidget {
  const ThreadScreen({super.key, required this.conversation});

  final ConversationListItem conversation;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThreadBloc>(
      create: (_) => ThreadBloc(
        repository: getIt<MessagesRepository>(),
        conversationUid: conversation.uid,
      )..add(const ThreadLoadRequested()),
      child: _ThreadView(conversation: conversation),
    );
  }
}

class _ThreadView extends StatefulWidget {
  const _ThreadView({required this.conversation});
  final ConversationListItem conversation;

  @override
  State<_ThreadView> createState() => _ThreadViewState();
}

class _ThreadViewState extends State<_ThreadView> {
  final _textCtl = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _textCtl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  void _send() {
    final text = _textCtl.text.trim();
    if (text.isEmpty) return;
    context.read<ThreadBloc>().add(ThreadMessageSent(text: text));
    _textCtl.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final c = widget.conversation;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            _HeaderAvatar(url: c.imageUrl, fallback: c.name, isGroup: c.isGroup),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    c.name,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  if (c.isGroup)
                    Text(
                      '${c.memberCount} members',
                      style: AppTextStyles.micro.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.phone, size: 18),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(LucideIcons.ellipsisVertical, size: 18),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<ThreadBloc, ThreadState>(
                listenWhen: (p, n) =>
                    p.messages.length != n.messages.length,
                listener: (_, _) => _scrollToBottom(),
                builder: (context, state) {
                  if (state.loading && state.messages.isEmpty) {
                    return const _ThreadSkeleton();
                  }
                  if (state.messages.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          'Say hi 👋',
                          style: AppTextStyles.body.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: state.messages.length,
                    itemBuilder: (_, i) {
                      final m = state.messages[i];
                      final prev = i == 0 ? null : state.messages[i - 1];
                      final showAvatar = prev == null ||
                          prev.sender.id != m.sender.id ||
                          prev.isOwn != m.isOwn;
                      return MessageBubble(
                        message: m,
                        showAvatar: showAvatar,
                        isGroup: c.isGroup,
                      );
                    },
                  );
                },
              ),
            ),
            _Composer(
              controller: _textCtl,
              onSend: _send,
              sending: context.select<ThreadBloc, bool>(
                (b) => b.state.sending,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({
    required this.url,
    required this.fallback,
    required this.isGroup,
  });

  final String url;
  final String fallback;
  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial =
        fallback.isEmpty ? '?' : fallback.characters.first.toUpperCase();
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
      ),
      alignment: Alignment.center,
      child: isGroup
          ? Icon(LucideIcons.users, color: colors.accent, size: 16)
          : Text(
              initial,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.onSend,
    required this.sending,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool sending;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.bgSurface,
          border: Border(top: BorderSide(color: colors.borderDefault)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(LucideIcons.plus, size: 20, color: colors.textSecondary),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 40,
                  maxHeight: 140,
                ),
                decoration: BoxDecoration(
                  color: colors.bgSurfaceHover,
                  borderRadius: AppRadius.fullAll,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 8,
                ),
                child: TextField(
                  controller: controller,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => onSend(),
                  style: AppTextStyles.body.copyWith(color: colors.textPrimary),
                  cursorColor: colors.accent,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Message…',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: sending ? null : onSend,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.accent,
                  ),
                  alignment: Alignment.center,
                  child: sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          LucideIcons.send,
                          size: 18,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreadSkeleton extends StatelessWidget {
  const _ThreadSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: 6,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Align(
          alignment: i.isEven ? Alignment.centerLeft : Alignment.centerRight,
          child: SkeletonBox(
            height: 36,
            width: 160 + (i * 18).toDouble(),
            borderRadius: AppRadius.xlAll,
          ),
        ),
      ),
    );
  }
}
