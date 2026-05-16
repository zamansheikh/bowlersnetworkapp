import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/equipment.dart';

/// Compact pill that shows the ball currently being used for upcoming
/// deliveries. Inline below the pin deck (matches web's `<LoadoutPill>`).
///
/// Tap → opens the picker sheet. The pill resolves the selected ball by
/// id from the loadout list; if it's missing (deleted, not loaded yet)
/// it falls back to the "No ball" state.
class LoadoutPill extends StatelessWidget {
  const LoadoutPill({
    super.key,
    required this.balls,
    required this.selectedId,
    required this.onTap,
  });

  final List<UserBall> balls;
  final int? selectedId;
  final VoidCallback onTap;

  UserBall? get _selected => selectedId == null
      ? null
      : balls.cast<UserBall?>().firstWhere(
            (b) => b?.id == selectedId,
            orElse: () => null,
          );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final ball = _selected;
    final hasBall = ball != null;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: hasBall
                ? colors.accent.withValues(alpha: 0.08)
                : colors.bgSurface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: hasBall
                  ? colors.accent.withValues(alpha: 0.4)
                  : colors.borderDefault,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Thumb(ball: ball?.ball),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasBall ? ball.ball.name : 'No ball',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: hasBall
                            ? colors.textPrimary
                            : colors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (hasBall)
                      Text(
                        '${ball.weight} lb',
                        style: AppTextStyles.nano.copyWith(
                          color: colors.textTertiary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                LucideIcons.chevronDown,
                size: 14,
                color: colors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.ball});
  final CatalogBall? ball;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const size = 24.0;
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.bgSurfaceHover,
      ),
      alignment: Alignment.center,
      child: Icon(
        LucideIcons.circle,
        size: 12,
        color: colors.textTertiary,
      ),
    );
    final url = ball?.ballImage;
    if (url == null || url.isEmpty) return placeholder;
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
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

/// Bottom-sheet picker. Pops back the chosen [UserBall] id, or `null`
/// when the user explicitly chose "No ball".
Future<({bool changed, int? userBallId})?> showLoadoutPicker(
  BuildContext context, {
  required List<UserBall> balls,
  required int? currentId,
}) {
  return showModalBottomSheet<({bool changed, int? userBallId})>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => _LoadoutPickerSheet(balls: balls, currentId: currentId),
  );
}

class _LoadoutPickerSheet extends StatelessWidget {
  const _LoadoutPickerSheet({
    required this.balls,
    required this.currentId,
  });

  final List<UserBall> balls;
  final int? currentId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
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
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.borderStrong,
                  borderRadius: AppRadius.fullAll,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                children: [
                  Text(
                    'Pick a ball',
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
            Flexible(
              child: balls.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.circle,
                            size: 32,
                            color: colors.textTertiary,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            "You don't have any balls in your loadout yet.",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Add one from the Equipment screen.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.nano.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.sm,
                        0,
                        AppSpacing.sm,
                        AppSpacing.base,
                      ),
                      itemCount: balls.length + 1,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 4),
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          return _Row(
                            isNoBall: true,
                            selected: currentId == null,
                            onTap: () => Navigator.of(context).pop((
                              changed: currentId != null,
                              userBallId: null,
                            )),
                          );
                        }
                        final b = balls[i - 1];
                        return _Row(
                          ball: b,
                          selected: currentId == b.id,
                          onTap: () => Navigator.of(context).pop((
                            changed: currentId != b.id,
                            userBallId: b.id,
                          )),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.selected,
    required this.onTap,
    this.ball,
    this.isNoBall = false,
  });

  final bool selected;
  final VoidCallback onTap;
  final UserBall? ball;
  final bool isNoBall;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: selected
          ? colors.accent.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: AppRadius.mdAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.bgSurfaceHover,
                ),
                clipBehavior: Clip.antiAlias,
                child: isNoBall
                    ? Icon(LucideIcons.x,
                        size: 18, color: colors.textTertiary)
                    : (ball?.ball.ballImage.isNotEmpty == true
                        ? CachedNetworkImage(
                            imageUrl: ball!.ball.ballImage,
                            fit: BoxFit.cover,
                          )
                        : Icon(LucideIcons.circle,
                            size: 18, color: colors.textTertiary)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isNoBall ? 'No ball' : ball!.ball.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isNoBall)
                      Text(
                        "Throw won't be linked to equipment",
                        style: AppTextStyles.nano
                            .copyWith(color: colors.textTertiary),
                      )
                    else
                      Row(
                        children: [
                          if (ball!.ball.brand != null) ...[
                            Text(
                              ball!.ball.brand!.name,
                              style: AppTextStyles.nano.copyWith(
                                color: colors.textTertiary,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            '${ball!.weight} lb',
                            style: AppTextStyles.nano.copyWith(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              if (selected)
                Icon(LucideIcons.check, size: 16, color: colors.accent),
            ],
          ),
        ),
      ),
    );
  }
}
