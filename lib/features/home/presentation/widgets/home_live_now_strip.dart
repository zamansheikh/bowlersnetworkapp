import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/home_previews.dart';

/// Web's "Live now from people you follow" horizontal strip. Renders
/// nothing when the list is empty (matches web's `loading || empty → null`).
class HomeLiveNowStrip extends StatelessWidget {
  const HomeLiveNowStrip({
    super.key,
    required this.broadcasts,
    required this.onViewAll,
    required this.onTap,
  });

  final List<LiveBroadcastPreview> broadcasts;
  final VoidCallback onViewAll;
  final ValueChanged<LiveBroadcastPreview> onTap;

  static const _rose = Color(0xFFE11D48);

  @override
  Widget build(BuildContext context) {
    if (broadcasts.isEmpty) return const SizedBox.shrink();
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const _PulsingDot(color: _rose),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'LIVE NOW FROM PEOPLE YOU FOLLOW',
                  style: AppTextStyles.nano.copyWith(
                    color: colors.textTertiary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onViewAll,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    child: Text(
                      'See all →',
                      style: AppTextStyles.nano.copyWith(
                        color: colors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 124,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            itemCount: broadcasts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final b = broadcasts[i];
              return _LiveCard(broadcast: b, onTap: () => onTap(b));
            },
          ),
        ),
      ],
    );
  }
}

class _LiveCard extends StatelessWidget {
  const _LiveCard({required this.broadcast, required this.onTap});
  final LiveBroadcastPreview broadcast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 240,
      child: Material(
        color: colors.bgSurface,
        borderRadius: AppRadius.xlAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: AppRadius.xlAll,
              border: Border.all(
                color: HomeLiveNowStrip._rose.withValues(alpha: 0.25),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  HomeLiveNowStrip._rose.withValues(alpha: 0.08),
                  colors.bgSurface,
                  colors.bgSurface,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _Avatar(author: broadcast.user),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            broadcast.user?.firstName.isNotEmpty == true
                                ? broadcast.user!.firstName
                                : (broadcast.user?.username ?? 'Someone'),
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (broadcast.user?.username != null)
                            Text(
                              '@${broadcast.user!.username}',
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.nano.copyWith(
                                color: colors.textTertiary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      LucideIcons.radio,
                      size: 14,
                      color: HomeLiveNowStrip._rose,
                    ),
                  ],
                ),
                if (broadcast.title.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    broadcast.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
                const Spacer(),
                Row(
                  children: [
                    Icon(LucideIcons.users,
                        size: 11, color: colors.textTertiary),
                    const SizedBox(width: 3),
                    Text(
                      '${broadcast.viewerCount}',
                      style: AppTextStyles.nano.copyWith(
                        color: colors.textTertiary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      '  ·  ',
                      style: AppTextStyles.nano
                          .copyWith(color: colors.textTertiary),
                    ),
                    Flexible(
                      child: Text(
                        '${broadcast.interactionsCount} interactions',
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.nano.copyWith(
                          color: colors.textTertiary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.author});
  final PreviewAuthor? author;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = (author?.firstName.isNotEmpty ?? false)
        ? author!.firstName.substring(0, 1).toUpperCase()
        : '?';
    final placeholder = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.bodySmall.copyWith(
          color: colors.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    final url = author?.profilePictureUrl;
    if (url == null || url.isEmpty) return placeholder;
    return ClipOval(
      child: SizedBox(
        width: 32,
        height: 32,
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

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});
  final Color color;
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 10,
      height: 10,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ctl,
            builder: (_, _) {
              final t = _ctl.value;
              return Opacity(
                opacity: (1 - t) * 0.7,
                child: Container(
                  width: 10 + (t * 6),
                  height: 10 + (t * 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color,
                  ),
                ),
              );
            },
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        ],
      ),
    );
  }
}
