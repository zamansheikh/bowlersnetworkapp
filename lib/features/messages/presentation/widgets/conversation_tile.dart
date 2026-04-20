import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/conversation.dart';

/// Single conversation row with avatar, name, last-message preview, and
/// timestamp. Unread = accent dot on the right.
class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    this.onTap,
  });

  final ConversationListItem conversation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final last = conversation.lastMessage;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              _Avatar(
                url: conversation.imageUrl,
                fallback: conversation.name,
                isGroup: conversation.isGroup,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colors.textPrimary,
                              fontWeight: conversation.hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        if (conversation.isMuted) ...[
                          const SizedBox(width: 6),
                          Icon(
                            LucideIcons.bellOff,
                            size: 12,
                            color: colors.textTertiary,
                          ),
                        ],
                        if (last?.createdAt != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            timeago.format(
                              last!.createdAt!,
                              locale: 'en_short',
                            ),
                            style: AppTextStyles.micro.copyWith(
                              color: conversation.hasUnread
                                  ? colors.accent
                                  : colors.textTertiary,
                              fontWeight: conversation.hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _previewText(last, conversation.isGroup),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: conversation.hasUnread
                                  ? colors.textPrimary
                                  : colors.textSecondary,
                              fontWeight: conversation.hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (conversation.hasUnread) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _previewText(LastMessagePreview? p, bool isGroup) {
    if (p == null) return 'No messages yet';
    if (isGroup && p.senderName.isNotEmpty) {
      return '${p.senderName.split(' ').first}: ${p.text}';
    }
    return p.text;
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
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
    const size = 48.0;
    final initial =
        fallback.isEmpty ? '?' : fallback.characters.first.toUpperCase();

    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
      ),
      alignment: Alignment.center,
      child: isGroup
          ? Icon(LucideIcons.users, color: colors.accent, size: 20)
          : Text(
              initial,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.accent,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
    );

    if (url.isEmpty) return placeholder;

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) => placeholder,
      ),
    );
  }
}
