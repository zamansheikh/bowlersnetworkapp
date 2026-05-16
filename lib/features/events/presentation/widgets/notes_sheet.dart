import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';
import '../bloc/notes_bloc.dart';

/// Opens the Q&A sheet for [eventUid]. The viewer can post notes; only
/// the [isCreator] viewer sees reply inputs + can delete any note
/// (others can only delete their own).
Future<void> showNotesSheet(
  BuildContext context, {
  required String eventUid,
  required bool isCreator,
  required int? viewerId,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => BlocProvider<NotesBloc>(
      create: (_) => NotesBloc(
        repository: getIt<EventsRepository>(),
        uid: eventUid,
      )..add(const NotesLoadRequested()),
      child: _NotesSheet(isCreator: isCreator, viewerId: viewerId),
    ),
  );
}

class _NotesSheet extends StatefulWidget {
  const _NotesSheet({required this.isCreator, required this.viewerId});
  final bool isCreator;
  final int? viewerId;
  @override
  State<_NotesSheet> createState() => _NotesSheetState();
}

class _NotesSheetState extends State<_NotesSheet> {
  final _composer = TextEditingController();
  final _composerFocus = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _composer.addListener(_onChanged);
  }

  void _onChanged() {
    final hasText = _composer.text.trim().isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    _composer.removeListener(_onChanged);
    _composer.dispose();
    _composerFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _composer.text.trim();
    if (text.isEmpty) return;
    context.read<NotesBloc>().add(NotesNoteSubmitted(text));
    _composer.clear();
    _composerFocus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
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
              Padding(
                padding: const EdgeInsets.all(AppSpacing.base),
                child: Row(
                  children: [
                    Icon(LucideIcons.messageCircle,
                        size: 16, color: colors.accent),
                    const SizedBox(width: 6),
                    Text(
                      'Q&A',
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: colors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(LucideIcons.x,
                          size: 18, color: colors.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: colors.borderDefault),
              Flexible(
                child: BlocConsumer<NotesBloc, NotesState>(
                  listenWhen: (p, n) =>
                      p.errors != n.errors && n.errors.isNotEmpty,
                  listener: (context, state) {
                    showAppToast(
                      context,
                      message: state.errors.join('\n'),
                      variant: ToastVariant.error,
                    );
                  },
                  builder: (context, state) {
                    if (state.loading && state.notes.isEmpty) {
                      return const _NotesSkeleton();
                    }
                    if (state.notes.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.xl,
                        ),
                        child: EmptyState(
                          icon: LucideIcons.messageCircleQuestionMark,
                          title: 'No questions yet',
                          hint: 'Be the first to ask.',
                        ),
                      );
                    }
                    return RefreshIndicator(
                      color: colors.accent,
                      onRefresh: () async {
                        context
                            .read<NotesBloc>()
                            .add(const NotesRefreshRequested());
                        await context
                            .read<NotesBloc>()
                            .stream
                            .firstWhere((s) => !s.refreshing);
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppSpacing.base),
                        itemCount:
                            state.notes.length + (state.hasMore ? 1 : 0),
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (_, i) {
                          if (i >= state.notes.length) {
                            return Padding(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              child: Center(
                                child: state.loadingMore
                                    ? SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colors.accent,
                                        ),
                                      )
                                    : TextButton(
                                        onPressed: () => context
                                            .read<NotesBloc>()
                                            .add(
                                              const NotesNextPageRequested(),
                                            ),
                                        child: const Text('Load more'),
                                      ),
                              ),
                            );
                          }
                          final note = state.notes[i];
                          final canReply = widget.isCreator && !note.hasReply;
                          final canDelete = widget.isCreator ||
                              (widget.viewerId != null &&
                                  note.author?.id == widget.viewerId);
                          return _NoteCard(
                            note: note,
                            canReply: canReply,
                            canDelete: canDelete,
                            replyBusy: state.replyBusyIds.contains(note.id),
                            deleteBusy:
                                state.deleteBusyIds.contains(note.id),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Divider(height: 1, color: colors.borderDefault),
              BlocBuilder<NotesBloc, NotesState>(
                buildWhen: (p, n) => p.posting != n.posting,
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 120),
                            decoration: BoxDecoration(
                              color: colors.bgSurface,
                              borderRadius: AppRadius.mdAll,
                              border:
                                  Border.all(color: colors.borderDefault),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 4,
                            ),
                            child: TextField(
                              controller: _composer,
                              focusNode: _composerFocus,
                              maxLines: 4,
                              minLines: 1,
                              style: AppTextStyles.body.copyWith(
                                color: colors.textPrimary,
                                fontSize: 14,
                              ),
                              cursorColor: colors.accent,
                              decoration: InputDecoration(
                                hintText: 'Ask a question…',
                                hintStyle: AppTextStyles.body.copyWith(
                                  color: colors.textTertiary,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppButton(
                          label: 'Post',
                          icon: LucideIcons.send,
                          size: AppButtonSize.regular,
                          loading: state.posting,
                          onPressed: _hasText && !state.posting ? _submit : null,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteCard extends StatefulWidget {
  const _NoteCard({
    required this.note,
    required this.canReply,
    required this.canDelete,
    required this.replyBusy,
    required this.deleteBusy,
  });

  final EventNote note;
  final bool canReply;
  final bool canDelete;
  final bool replyBusy;
  final bool deleteBusy;

  @override
  State<_NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<_NoteCard> {
  final _reply = TextEditingController();
  bool _showingReply = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  void _sendReply() {
    final text = _reply.text.trim();
    if (text.isEmpty) return;
    context
        .read<NotesBloc>()
        .add(NotesReplySubmitted(noteId: widget.note.id, content: text));
    _reply.clear();
    setState(() => _showingReply = false);
  }

  Future<void> _confirmDelete() async {
    final colors = context.colors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.bgSurfaceElevated,
        title: const Text('Delete this note?'),
        content: const Text("This can't be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(color: colors.error),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    context.read<NotesBloc>().add(NotesNoteDeleted(widget.note.id));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final note = widget.note;
    final author = note.author;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colors.borderDefault),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _NoteAvatar(author: author),
                const SizedBox(width: AppSpacing.sm),
                if (author != null)
                  Flexible(
                    child: InkWell(
                      onTap: () =>
                          context.push('/u/${author.username}'),
                      child: Text(
                        author.displayName,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (note.isByCreator) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.14),
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Text(
                      'HOST',
                      style: AppTextStyles.nano.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (widget.canDelete)
                  IconButton(
                    tooltip: 'Delete',
                    visualDensity: VisualDensity.compact,
                    icon: widget.deleteBusy
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.textTertiary,
                            ),
                          )
                        : Icon(LucideIcons.trash2,
                            size: 14, color: colors.textTertiary),
                    onPressed: widget.deleteBusy ? null : _confirmDelete,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              note.content,
              style: AppTextStyles.body.copyWith(
                color: colors.textPrimary,
                height: 1.4,
              ),
            ),
            if (note.hasReply) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.08),
                  borderRadius: AppRadius.smAll,
                  border: Border.all(
                    color: colors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(LucideIcons.cornerDownRight,
                            size: 12, color: colors.accent),
                        const SizedBox(width: 4),
                        Text(
                          'HOST REPLIED',
                          style: AppTextStyles.nano.copyWith(
                            color: colors.accent,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      note.reply,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (widget.canReply) ...[
              const SizedBox(height: AppSpacing.sm),
              if (!_showingReply)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(() => _showingReply = true),
                    icon: const Icon(LucideIcons.reply, size: 14),
                    label: const Text('Reply'),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _reply,
                        autofocus: true,
                        maxLines: 3,
                        minLines: 1,
                        style: AppTextStyles.body.copyWith(
                          color: colors.textPrimary,
                          fontSize: 14,
                        ),
                        cursorColor: colors.accent,
                        decoration: InputDecoration(
                          hintText: 'Reply as host…',
                          hintStyle: AppTextStyles.body.copyWith(
                            color: colors.textTertiary,
                            fontSize: 14,
                          ),
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppRadius.smAll,
                            borderSide: BorderSide(
                              color: colors.borderDefault,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppRadius.smAll,
                            borderSide: BorderSide(color: colors.accent),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppButton(
                      label: 'Send',
                      size: AppButtonSize.small,
                      loading: widget.replyBusy,
                      onPressed: widget.replyBusy ? null : _sendReply,
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NoteAvatar extends StatelessWidget {
  const _NoteAvatar({required this.author});
  final EventOrganiser? author;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = author?.firstName.isNotEmpty == true
        ? author!.firstName.substring(0, 1).toUpperCase()
        : author?.username.isNotEmpty == true
            ? author!.username.substring(0, 1).toUpperCase()
            : '?';
    final placeholder = Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
      ),
      child: Text(
        initial,
        style: AppTextStyles.nano.copyWith(
          color: colors.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    final url = author?.profilePictureUrl;
    if (url == null || url.isEmpty) return placeholder;
    return ClipOval(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, _) => placeholder,
          errorWidget: (_, _, _) => placeholder,
        ),
      ),
    );
  }
}

class _NotesSkeleton extends StatelessWidget {
  const _NotesSkeleton();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, _) => const SkeletonBox(height: 90),
    );
  }
}
