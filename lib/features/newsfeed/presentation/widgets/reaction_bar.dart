import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/post.dart';

/// Engagement row beneath a post — mirrors the web frontend's 4-column
/// pattern: [Reactions] [Comments] [Shares] [Save].
///
/// Tap the like button to toggle `Like`. Long-press opens a floating
/// Facebook-style reaction picker anchored directly above the button —
/// matches the web's hover-to-open popup.
class ReactionBar extends StatelessWidget {
  const ReactionBar({
    super.key,
    required this.post,
    required this.onReact,
    required this.onComment,
    required this.onSave,
    required this.onShare,
  });

  final Post post;
  final ValueChanged<ReactionType> onReact;
  final VoidCallback onComment;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.borderDefault)),
      ),
      child: Row(
        children: [
          // ── Reactions column ──
          Expanded(
            child: Row(
              children: [
                _LikeButton(post: post, onReact: onReact),
                if (post.likesCount > 0) ...[
                  const SizedBox(width: 6),
                  _StackedReactions(post: post),
                  const SizedBox(width: 6),
                  Text(
                    _compactNumber(post.likesCount),
                    style: AppTextStyles.secondary.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _IconCountButton(
            icon: LucideIcons.messageCircle,
            active: false,
            activeColor: colors.accent,
            count: post.commentsCount,
            onTap: onComment,
          ),
          const SizedBox(width: AppSpacing.sm),
          _IconCountButton(
            icon: LucideIcons.share2,
            active: false,
            activeColor: colors.accent,
            count: post.sharesCount,
            onTap: onShare,
          ),
          const SizedBox(width: AppSpacing.sm),
          _IconCountButton(
            icon: LucideIcons.bookmark,
            active: post.hasSaved,
            activeColor: colors.accent,
            count: post.savesCount,
            onTap: onSave,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Like button — long-press anchors a floating reaction picker above itself.
// =============================================================================
class _LikeButton extends StatefulWidget {
  const _LikeButton({required this.post, required this.onReact});

  final Post post;
  final ValueChanged<ReactionType> onReact;

  @override
  State<_LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<_LikeButton> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _picker;

  void _togglePicker() {
    if (_picker != null) {
      _hidePicker();
      return;
    }
    HapticFeedback.mediumImpact();
    _picker = _buildPickerEntry();
    Overlay.of(context, rootOverlay: true).insert(_picker!);
  }

  void _hidePicker() {
    _picker?.remove();
    _picker = null;
  }

  OverlayEntry _buildPickerEntry() {
    return OverlayEntry(
      builder: (_) => _ReactionPickerOverlay(
        link: _link,
        onDismiss: _hidePicker,
        onPicked: (r) {
          _hidePicker();
          widget.onReact(r);
        },
      ),
    );
  }

  @override
  void dispose() {
    _hidePicker();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final r = widget.post.reaction;
    final active = r != null;

    return CompositedTransformTarget(
      link: _link,
      child: SizedBox(
        width: 40,
        height: 36,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadius.smAll,
            onTap: () => widget.onReact(r ?? ReactionType.like),
            onLongPress: _togglePicker,
            child: Center(
              child: active
                  ? Text(r.emoji, style: const TextStyle(fontSize: 20))
                  : Icon(
                      LucideIcons.heart,
                      size: 18,
                      color: colors.textSecondary,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The floating picker itself. A full-screen barrier dismisses it on
/// outside-tap; the pill anchors to the like button via
/// [CompositedTransformFollower] so it always sits just above the target.
class _ReactionPickerOverlay extends StatefulWidget {
  const _ReactionPickerOverlay({
    required this.link,
    required this.onDismiss,
    required this.onPicked,
  });

  final LayerLink link;
  final VoidCallback onDismiss;
  final ValueChanged<ReactionType> onPicked;

  @override
  State<_ReactionPickerOverlay> createState() => _ReactionPickerOverlayState();
}

class _ReactionPickerOverlayState extends State<_ReactionPickerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  )..forward();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Invisible full-screen barrier for tap-to-dismiss.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onDismiss,
          ),
        ),
        // Follower anchored above the like button.
        CompositedTransformFollower(
          link: widget.link,
          targetAnchor: Alignment.topLeft,
          followerAnchor: Alignment.bottomLeft,
          offset: const Offset(-8, -8),
          child: Material(
            color: Colors.transparent,
            child: FadeTransition(
              opacity: _anim,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.85, end: 1).animate(
                  CurvedAnimation(
                    parent: _anim,
                    curve: Curves.easeOutBack,
                  ),
                ),
                alignment: Alignment.bottomLeft,
                child: _ReactionPickerPill(
                  onPicked: widget.onPicked,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReactionPickerPill extends StatelessWidget {
  const _ReactionPickerPill({required this.onPicked});

  final ValueChanged<ReactionType> onPicked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: colors.bgSurfaceElevated,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.borderDefault),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final r in ReactionType.values)
            _PickerOption(
              type: r,
              onTap: () {
                HapticFeedback.lightImpact();
                onPicked(r);
              },
            ),
        ],
      ),
    );
  }
}

class _PickerOption extends StatefulWidget {
  const _PickerOption({required this.type, required this.onTap});

  final ReactionType type;
  final VoidCallback onTap;

  @override
  State<_PickerOption> createState() => _PickerOptionState();
}

class _PickerOptionState extends State<_PickerOption> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    // Emojis hover-scale like web's `hover:scale-125`.
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutBack,
          scale: _hovered ? 1.35 : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Tooltip(
              message: widget.type.label,
              child: Text(
                widget.type.emoji,
                style: const TextStyle(fontSize: 28, height: 1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
class _StackedReactions extends StatelessWidget {
  const _StackedReactions({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    final primary = post.reaction ?? ReactionType.like;
    return Text(
      primary.emoji,
      style: const TextStyle(fontSize: 14, height: 1),
    );
  }
}

class _IconCountButton extends StatelessWidget {
  const _IconCountButton({
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final Color activeColor;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = active ? activeColor : colors.textSecondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.smAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: color),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Text(
                  _compactNumber(count),
                  style: AppTextStyles.secondary.copyWith(color: color),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _compactNumber(int n) {
  if (n < 1000) return '$n';
  if (n < 1000000) {
    return '${(n / 1000).toStringAsFixed(n % 1000 >= 100 ? 1 : 0)}K';
  }
  return '${(n / 1000000).toStringAsFixed(1)}M';
}
