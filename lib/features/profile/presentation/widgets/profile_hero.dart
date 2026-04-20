import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/profile.dart';

/// Cover + overlapping avatar + name + username. Rendered edge-to-edge;
/// the rest of the profile content sits below with standard padding.
class ProfileHero extends StatelessWidget {
  const ProfileHero({
    super.key,
    required this.profile,
    required this.isSelf,
    this.onEditCover,
    this.onToggleFollow,
    this.onEditName,
  });

  final Profile profile;
  final bool isSelf;
  final VoidCallback? onEditCover;
  final VoidCallback? onToggleFollow;
  final VoidCallback? onEditName;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final cover = profile.coverPictureUrl;

    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          // Cover image
          Positioned.fill(
            child: cover != null && cover.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: cover,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        _gradientFallback(colors),
                    errorWidget: (_, _, _) =>
                        _gradientFallback(colors),
                  )
                : _gradientFallback(colors),
          ),
          // Gradient overlays — bottom darken + left tint
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    colors.bgPrimary.withValues(alpha: 0.15),
                    colors.bgPrimary.withValues(alpha: 0.85),
                  ],
                  stops: const [0.2, 0.55, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    colors.bgPrimary.withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Top-right action button
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.base,
            child: isSelf
                ? _GlassButton(
                    icon: LucideIcons.camera,
                    label: 'Edit Cover',
                    onTap: onEditCover,
                  )
                : _GlassIconButton(
                    icon: profile.isFollowing == true
                        ? LucideIcons.userMinus
                        : LucideIcons.userPlus,
                    onTap: onToggleFollow,
                  ),
          ),
          // Bottom: avatar + name
          Positioned(
            left: AppSpacing.base,
            right: AppSpacing.base,
            bottom: AppSpacing.base,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _GradientAvatar(
                  url: profile.profilePictureUrl,
                  fallback: profile.user.displayName,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              profile.user.displayName,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.pageTitle.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                                shadows: [
                                  Shadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (profile.user.isPro) ...[
                            const SizedBox(width: AppSpacing.sm),
                            const _ProBadge(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${profile.user.username}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradientFallback(dynamic colors) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.accent.withValues(alpha: 0.28),
              colors.bgSurface,
              colors.bgSurfaceElevated,
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
class _GradientAvatar extends StatelessWidget {
  const _GradientAvatar({required this.url, required this.fallback});

  final String? url;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const size = 92.0;
    final initial =
        fallback.isEmpty ? '?' : fallback.characters.first.toUpperCase();

    return Container(
      width: size + 6,
      height: size + 6,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.accent,
            colors.accent.withValues(alpha: 0.6),
            colors.accent.withValues(alpha: 0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.accent.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.bgSurface,
          border: Border.all(color: colors.bgPrimary, width: 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: url != null && url!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    _initialFallback(colors, initial, size),
                errorWidget: (_, _, _) =>
                    _initialFallback(colors, initial, size),
              )
            : _initialFallback(colors, initial, size),
      ),
    );
  }

  Widget _initialFallback(dynamic colors, String initial, double size) =>
      Container(
        color: colors.accentSubtle,
        alignment: Alignment.center,
        child: Text(
          initial,
          style: AppTextStyles.pageTitle.copyWith(
            color: colors.accent,
            fontSize: size * 0.36,
          ),
        ),
      );
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.9)),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _ProBadge extends StatelessWidget {
  const _ProBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          colors: [Color(0x99EAB308), Color(0x99F97316)],
        ),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
