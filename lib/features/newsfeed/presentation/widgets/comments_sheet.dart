import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/newsfeed_repository.dart';
import '../bloc/comments_bloc.dart';

/// Opens the comments bottom-sheet for [postUid]. Parent should know if
/// the viewer is the post author — that unlocks pin / hide on each comment.
Future<void> showCommentsSheet(
  BuildContext context, {
  required String postUid,
  required bool isPostAuthor,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => BlocProvider<CommentsBloc>(
      create: (_) => CommentsBloc(
        repository: getIt<NewsfeedRepository>(),
        postUid: postUid,
      )..add(const CommentsLoadRequested()),
      child: _CommentsSheet(isPostAuthor: isPostAuthor),
    ),
  );
}

// =============================================================================
class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({required this.isPostAuthor});
  final bool isPostAuthor;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final _inputCtl = TextEditingController();
  final _inputFocus = FocusNode();

  /// When non-null, the composer is in reply-mode for this parent comment.
  Comment? _replyingTo;

  @override
  void dispose() {
    _inputCtl.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _startReply(Comment parent) {
    setState(() => _replyingTo = parent);
    _inputFocus.requestFocus();
  }

  void _cancelReply() {
    setState(() => _replyingTo = null);
  }

  void _submit() {
    final text = _inputCtl.text.trim();
    if (text.isEmpty) return;
    final bloc = context.read<CommentsBloc>();
    if (_replyingTo == null) {
      bloc.add(CommentCreated(text));
    } else {
      bloc.add(CommentReplyCreated(
        parentId: _replyingTo!.id,
        text: text,
      ));
    }
    _inputCtl.clear();
    _cancelReply();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: BoxDecoration(
          color: colors.bgSurfaceElevated,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.borderStrong,
                borderRadius: AppRadius.fullAll,
              ),
            ),
            _Header(onClose: () => Navigator.of(context).pop()),
            Flexible(
              child: BlocBuilder<CommentsBloc, CommentsState>(
                builder: (context, state) {
                  if (state.loading && state.comments.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(AppSpacing.xl2),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (state.comments.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl2),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.messageCircle,
                              size: 32,
                              color: colors.textTertiary,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'No comments yet. Be the first!',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: colors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                      vertical: AppSpacing.md,
                    ),
                    itemCount: state.comments.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, i) {
                      final c = state.comments[i];
                      return _CommentTile(
                        comment: c,
                        isPostAuthor: widget.isPostAuthor,
                        onReply: () => _startReply(c),
                      );
                    },
                  );
                },
              ),
            ),
            _ComposerBar(
              controller: _inputCtl,
              focusNode: _inputFocus,
              replyingTo: _replyingTo,
              onCancelReply: _cancelReply,
              onSend: _submit,
              sending: context.select<CommentsBloc, bool>(
                (b) => b.state.sending,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
class _Header extends StatelessWidget {
  const _Header({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(LucideIcons.x, size: 20, color: colors.textSecondary),
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: Center(
              child: Text(
                'Comments',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: colors.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

// =============================================================================
class _CommentTile extends StatefulWidget {
  const _CommentTile({
    required this.comment,
    required this.isPostAuthor,
    required this.onReply,
    this.isReply = false,
  });

  final Comment comment;
  final bool isPostAuthor;
  final VoidCallback onReply;
  final bool isReply;

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  bool _editing = false;
  late final TextEditingController _editCtl =
      TextEditingController(text: widget.comment.text);

  @override
  void didUpdateWidget(covariant _CommentTile old) {
    super.didUpdateWidget(old);
    if (old.comment.text != widget.comment.text && !_editing) {
      _editCtl.text = widget.comment.text;
    }
  }

  @override
  void dispose() {
    _editCtl.dispose();
    super.dispose();
  }

  void _saveEdit() {
    final text = _editCtl.text.trim();
    if (text.isEmpty || text == widget.comment.text) {
      setState(() => _editing = false);
      return;
    }
    context.read<CommentsBloc>().add(
          CommentEdited(commentId: widget.comment.id, text: text),
        );
    setState(() => _editing = false);
  }

  Future<void> _showActions() async {
    final c = widget.comment;
    final canManage = c.isMine || widget.isPostAuthor;
    if (!canManage) return;

    final colors = context.colors;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: colors.bgSurfaceElevated,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (c.isMine && !widget.isReply)
                ListTile(
                  leading:
                      Icon(LucideIcons.squarePen, size: 18, color: colors.textSecondary),
                  title: Text('Edit', style: AppTextStyles.body.copyWith(color: colors.textPrimary)),
                  onTap: () {
                    Navigator.of(sheetCtx).pop();
                    setState(() => _editing = true);
                  },
                ),
              if (widget.isPostAuthor && !widget.isReply)
                ListTile(
                  leading: Icon(
                    c.isPinned ? LucideIcons.pinOff : LucideIcons.pin,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                  title: Text(
                    c.isPinned ? 'Unpin comment' : 'Pin comment',
                    style: AppTextStyles.body.copyWith(color: colors.textPrimary),
                  ),
                  onTap: () {
                    Navigator.of(sheetCtx).pop();
                    context.read<CommentsBloc>().add(CommentPinToggled(c.id));
                  },
                ),
              if (widget.isPostAuthor)
                ListTile(
                  leading: Icon(
                    c.isHidden ? LucideIcons.eye : LucideIcons.eyeOff,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                  title: Text(
                    c.isHidden ? 'Unhide comment' : 'Hide comment',
                    style: AppTextStyles.body.copyWith(color: colors.textPrimary),
                  ),
                  onTap: () {
                    Navigator.of(sheetCtx).pop();
                    context.read<CommentsBloc>().add(CommentHideToggled(c.id));
                  },
                ),
              ListTile(
                leading: Icon(LucideIcons.trash2, size: 18, color: colors.error),
                title: Text('Delete',
                    style: AppTextStyles.body.copyWith(color: colors.error)),
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  context.read<CommentsBloc>().add(CommentDeleted(c.id));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final c = widget.comment;

    return Opacity(
      opacity: c.isHidden ? 0.5 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(
                url: c.author.profilePictureUrl,
                fallback: c.author.displayName,
                size: widget.isReply ? 24 : 32,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (c.isPinned)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.pin,
                                size: 10, color: colors.accent),
                            const SizedBox(width: 4),
                            Text(
                              'Pinned',
                              style: AppTextStyles.nano.copyWith(
                                color: colors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Bubble
                    GestureDetector(
                      onLongPress: _showActions,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: c.isPinned
                              ? colors.accent.withValues(alpha: 0.06)
                              : colors.bgSurfaceHover.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(14),
                          border: c.isPinned
                              ? Border.all(
                                  color:
                                      colors.accent.withValues(alpha: 0.15))
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    c.author.displayName,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                if (c.isEdited) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '(edited)',
                                    style: AppTextStyles.nano.copyWith(
                                      color: colors.textTertiary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            if (_editing)
                              _InlineEditor(
                                controller: _editCtl,
                                onSave: _saveEdit,
                                onCancel: () =>
                                    setState(() => _editing = false),
                              )
                            else
                              Text(
                                c.text,
                                style: AppTextStyles.body.copyWith(
                                  color: colors.textPrimary,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Action row: time · Reply · Like
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 4,
                        top: 4,
                      ),
                      child: Row(
                        children: [
                          Text(
                            timeago.format(c.createdAt, locale: 'en_short'),
                            style: AppTextStyles.nano.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (!widget.isReply)
                            _ActionLink(
                              label: 'Reply',
                              onTap: widget.onReply,
                            ),
                          const Spacer(),
                          _LikeCount(comment: c),
                        ],
                      ),
                    ),
                    // Replies: expand / collapse + nested list
                    if (!widget.isReply && c.replyCount > 0) ...[
                      const SizedBox(height: 6),
                      _RepliesToggle(comment: c),
                      if (c.repliesExpanded) ...[
                        const SizedBox(height: 8),
                        for (final r in c.replies) ...[
                          _CommentTile(
                            comment: r,
                            isPostAuthor: widget.isPostAuthor,
                            onReply: widget.onReply,
                            isReply: true,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineEditor extends StatelessWidget {
  const _InlineEditor({
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          autofocus: true,
          maxLines: null,
          style: AppTextStyles.body.copyWith(
            color: colors.textPrimary,
            fontSize: 13,
          ),
          cursorColor: colors.accent,
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintStyle: AppTextStyles.body.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                foregroundColor: colors.textTertiary,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Cancel'),
            ),
            const Spacer(),
            TextButton(
              onPressed: onSave,
              style: TextButton.styleFrom(
                foregroundColor: colors.accent,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionLink extends StatelessWidget {
  const _ActionLink({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        style: AppTextStyles.nano.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _LikeCount extends StatelessWidget {
  const _LikeCount({required this.comment});
  final Comment comment;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final liked = comment.hasLiked;
    return GestureDetector(
      onTap: () =>
          context.read<CommentsBloc>().add(CommentLikeToggled(comment.id)),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.heart,
            size: 13,
            color: liked ? const Color(0xFFEF4444) : colors.textTertiary,
          ),
          if (comment.likesCount > 0) ...[
            const SizedBox(width: 4),
            Text(
              '${comment.likesCount}',
              style: AppTextStyles.nano.copyWith(
                color: liked ? const Color(0xFFEF4444) : colors.textTertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RepliesToggle extends StatelessWidget {
  const _RepliesToggle({required this.comment});
  final Comment comment;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: () => context
          .read<CommentsBloc>()
          .add(CommentRepliesToggled(comment.id)),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 1,
              color: colors.borderDefault,
            ),
            const SizedBox(width: 8),
            if (comment.loadingReplies)
              const SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(strokeWidth: 1.2),
              )
            else
              Icon(
                comment.repliesExpanded
                    ? LucideIcons.chevronUp
                    : LucideIcons.chevronDown,
                size: 12,
                color: colors.textSecondary,
              ),
            const SizedBox(width: 4),
            Text(
              comment.repliesExpanded
                  ? 'Hide replies'
                  : 'View ${comment.replyCount} '
                      '${comment.replyCount == 1 ? 'reply' : 'replies'}',
              style: AppTextStyles.nano.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
class _ComposerBar extends StatelessWidget {
  const _ComposerBar({
    required this.controller,
    required this.focusNode,
    required this.replyingTo,
    required this.onCancelReply,
    required this.onSend,
    required this.sending,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Comment? replyingTo;
  final VoidCallback onCancelReply;
  final VoidCallback onSend;
  final bool sending;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: colors.bgSurface,
          border: Border(top: BorderSide(color: colors.borderDefault)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyingTo != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: 6,
                ),
                color: colors.accent.withValues(alpha: 0.06),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.cornerDownRight,
                      size: 12,
                      color: colors.accent,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Replying to ${replyingTo!.author.displayName}',
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.micro.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onCancelReply,
                      behavior: HitTestBehavior.opaque,
                      child: Icon(
                        LucideIcons.x,
                        size: 13,
                        color: colors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _ViewerAvatar(),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 36,
                        maxHeight: 120,
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
                        focusNode: focusNode,
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (_) => onSend(),
                        style: AppTextStyles.body.copyWith(
                          color: colors.textPrimary,
                          fontSize: 13,
                        ),
                        cursorColor: colors.accent,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'Write a comment…',
                          hintStyle: AppTextStyles.body.copyWith(
                            color: colors.textTertiary,
                            fontSize: 13,
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
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colors.accent,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: sending
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                LucideIcons.send,
                                size: 15,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewerAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      buildWhen: (p, n) =>
          p.profile?.profilePictureUrl != n.profile?.profilePictureUrl,
      builder: (context, state) {
        final url = state.profile?.profilePictureUrl;
        final fallback = state.profile?.user.displayName ?? 'You';
        return _Avatar(url: url, fallback: fallback, size: 32);
      },
    );
  }
}

// =============================================================================
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.url,
    required this.fallback,
    required this.size,
  });

  final String? url;
  final String fallback;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial =
        fallback.isEmpty ? '?' : fallback.characters.first.toUpperCase();
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
        border: Border.all(color: colors.borderStrong),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.micro.copyWith(
          color: colors.accent,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.4,
        ),
      ),
    );
    if (url == null || url!.isEmpty) return placeholder;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.borderStrong),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: url!,
        fit: BoxFit.cover,
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) => placeholder,
      ),
    );
  }
}
