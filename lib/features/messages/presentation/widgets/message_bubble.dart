import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/conversation.dart';

/// Single chat bubble. Own messages float right with an accent bg; others
/// float left with a surface bg + avatar. Deleted messages render as a
/// muted italicised "This message was deleted" pill.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.showAvatar,
    required this.isGroup,
  });

  final ChatMessage message;
  final bool showAvatar;
  final bool isGroup;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final own = message.isOwn;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment:
            own ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!own)
            SizedBox(
              width: 32,
              child: showAvatar
                  ? _Avatar(
                      url: message.sender.profilePictureUrl,
                      fallback: message.sender.displayName,
                    )
                  : null,
            ),
          if (!own) const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  own ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!own && showAvatar && isGroup)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      bottom: 2,
                    ),
                    child: Text(
                      message.sender.displayName,
                      style: AppTextStyles.micro.copyWith(
                        color: colors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.sizeOf(context).width * 0.72,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm + 1,
                    ),
                    decoration: BoxDecoration(
                      color: message.isDeleted
                          ? colors.bgSurfaceHover.withValues(alpha: 0.4)
                          : own
                              ? colors.accent
                              : colors.bgSurface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(AppRadius.xl),
                        topRight: const Radius.circular(AppRadius.xl),
                        bottomLeft: Radius.circular(own ? AppRadius.xl : 4),
                        bottomRight: Radius.circular(own ? 4 : AppRadius.xl),
                      ),
                      border: own
                          ? null
                          : Border.all(color: colors.borderDefault),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.media.isNotEmpty)
                          _MediaPreview(media: message.media, own: own),
                        if (message.text.isNotEmpty)
                          Text(
                            message.text,
                            style: AppTextStyles.body.copyWith(
                              color: message.isDeleted
                                  ? colors.textTertiary
                                  : own
                                      ? Colors.white
                                      : colors.textPrimary,
                              fontStyle: message.isDeleted
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              height: 1.4,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (message.createdAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2, left: 6, right: 6),
                    child: Text(
                      DateFormat.jm().format(message.createdAt!),
                      style: AppTextStyles.nano.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.fallback});
  final String? url;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial =
        fallback.isEmpty ? '?' : fallback.characters.first.toUpperCase();
    final placeholder = Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.micro.copyWith(
          color: colors.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    if (url == null || url!.isEmpty) return placeholder;
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url!,
        width: 28,
        height: 28,
        fit: BoxFit.cover,
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) => placeholder,
      ),
    );
  }
}

class _MediaPreview extends StatelessWidget {
  const _MediaPreview({required this.media, required this.own});
  final List<MessageMedia> media;
  final bool own;

  @override
  Widget build(BuildContext context) {
    final first = media.first;
    switch (first.type) {
      case 'image':
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: ClipRRect(
            borderRadius: AppRadius.mdAll,
            child: CachedNetworkImage(
              imageUrl: first.url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
            ),
          ),
        );
      case 'video':
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: AppRadius.mdAll,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: Colors.black),
                  Center(
                    child: Icon(
                      LucideIcons.play,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      default:
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Icon(
                LucideIcons.paperclip,
                size: 14,
                color: own ? Colors.white : context.colors.textSecondary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Attachment',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: own ? Colors.white : context.colors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
