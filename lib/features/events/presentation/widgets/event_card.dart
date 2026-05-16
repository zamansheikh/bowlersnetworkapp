import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/event.dart';

/// One event row in /events list. Tap the card to open the detail
/// screen; tap the heart to flip interest. Same widget can later be
/// reused on the home preview if/when we collapse the two.
class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onInterestTap,
  });

  final Event event;
  final VoidCallback onTap;
  final VoidCallback onInterestTap;

  static const _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final d = event.eventDate;

    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (event.flyerUrl != null && event.flyerUrl!.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: event.flyerUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: colors.bgSurfaceHover),
                    errorWidget: (_, _, _) =>
                        Container(color: colors.bgSurfaceHover),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DateBadge(date: d),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (event.eventType != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.accentSubtle,
                                  borderRadius: AppRadius.smAll,
                                ),
                                child: Text(
                                  event.eventType!.name,
                                  style: AppTextStyles.nano.copyWith(
                                    color: colors.accent,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            if (event.isOnline) ...[
                              if (event.eventType != null)
                                const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.info.withValues(alpha: 0.12),
                                  borderRadius: AppRadius.smAll,
                                ),
                                child: Text(
                                  'ONLINE',
                                  style: AppTextStyles.nano.copyWith(
                                    color: colors.info,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.cardTitle.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(LucideIcons.mapPin,
                                size: 11, color: colors.textTertiary),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                event.isOnline
                                    ? 'Online'
                                    : (event.location?.displayLabel ??
                                        'TBA'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.nano.copyWith(
                                  color: colors.textTertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            _Metric(
                              icon: LucideIcons.users,
                              label: '${event.goingCount} going',
                            ),
                            const SizedBox(width: AppSpacing.md),
                            _Metric(
                              icon: LucideIcons.heart,
                              label: '${event.interestedCount}',
                            ),
                            const Spacer(),
                            _InterestButton(
                              active: event.isInterested == true,
                              onTap: event.isCreator == true
                                  ? null
                                  : onInterestTap,
                            ),
                          ],
                        ),
                      ],
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

class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.date});
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: colors.bgSurfaceHover,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: colors.borderDefault),
      ),
      alignment: Alignment.center,
      child: date == null
          ? Icon(LucideIcons.calendar, size: 18, color: colors.textTertiary)
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  EventCard._months[date!.month - 1],
                  style: AppTextStyles.nano.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
                Text(
                  '${date!.day}',
                  style: AppTextStyles.numberLarge.copyWith(
                    color: colors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: colors.textTertiary),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTextStyles.nano.copyWith(
            color: colors.textTertiary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _InterestButton extends StatelessWidget {
  const _InterestButton({required this.active, required this.onTap});
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = active ? colors.accent : colors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.fullAll,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: AppRadius.fullAll,
          color:
              active ? colors.accent.withValues(alpha: 0.12) : Colors.transparent,
          border: Border.all(
            color: active ? colors.accent : colors.borderDefault,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.heart, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              active ? 'Interested' : 'Interest',
              style: AppTextStyles.nano.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
