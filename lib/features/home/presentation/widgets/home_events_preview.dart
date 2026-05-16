import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/home_previews.dart';
import 'home_section_card.dart';

/// Web's "Upcoming Events" bento — a date badge on the left + title +
/// event-type chip + location row on the right.
class HomeEventsPreview extends StatelessWidget {
  const HomeEventsPreview({
    super.key,
    required this.events,
    required this.onViewAll,
    required this.onTap,
  });

  final List<EventPreview> events;
  final VoidCallback onViewAll;
  final ValueChanged<EventPreview> onTap;

  static const _orange = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return HomeSectionCard(
      icon: LucideIcons.calendar,
      title: 'Upcoming Events',
      iconTint: _orange,
      onViewAll: onViewAll,
      child: events.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'No upcoming events.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall
                    .copyWith(color: colors.textTertiary),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < events.length; i++) ...[
                  _Row(event: events[i], onTap: () => onTap(events[i])),
                  if (i < events.length - 1)
                    Divider(
                      height: 1,
                      color: colors.borderDefault.withValues(alpha: 0.4),
                    ),
                ],
              ],
            ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.event, required this.onTap});
  final EventPreview event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final date = event.eventDate;
    final monthLabel =
        date == null ? '' : DateFormat.MMM().format(date).toUpperCase();
    final dayLabel = date == null ? '' : '${date.day}';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              // ── Date badge ────────────────────────────────────────────────
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.mdAll,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors.accent.withValues(alpha: 0.18),
                      colors.accent.withValues(alpha: 0.06),
                    ],
                  ),
                  border: Border.all(
                    color: colors.accent.withValues(alpha: 0.18),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      monthLabel,
                      style: AppTextStyles.nano.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                    Text(
                      dayLabel,
                      style: AppTextStyles.numberLarge.copyWith(
                        color: colors.accent,
                        fontSize: 20,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // ── Title + meta ─────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            event.title,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (event.eventTypeName.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: colors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: colors.accent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              event.eventTypeName,
                              style: AppTextStyles.nano.copyWith(
                                color: colors.accent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.mapPin,
                          size: 11,
                          color: colors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.locationLabel,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.nano.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                        ),
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
}
