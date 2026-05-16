import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/network_badge.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';
import '../bloc/event_detail_bloc.dart';
import '../widgets/attendees_sheet.dart';
import '../widgets/notes_sheet.dart';
import '../widgets/send_invitations_sheet.dart';

/// /events/:uid — single event view with hero, organiser, location,
/// description, and the interest toggle CTA at the bottom.
class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EventDetailBloc>(
      create: (_) => EventDetailBloc(
        repository: getIt<EventsRepository>(),
        uid: uid,
      )..add(const EventDetailLoadRequested()),
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView();

  Future<void> _confirmDelete(BuildContext context, Event event) async {
    final colors = context.colors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.bgSurfaceElevated,
        title: Text('Delete "${event.title}"?'),
        content: const Text(
          "This permanently removes the event for everyone. This can't be undone.",
        ),
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
    if (ok != true || !context.mounted) return;
    final repo = getIt<EventsRepository>();
    final res = await repo.deleteEvent(event.uid);
    if (!context.mounted) return;
    res.fold(
      (f) => showAppToast(
        context,
        message: f.messages.join('\n'),
        variant: ToastVariant.error,
      ),
      (_) {
        showAppToast(
          context,
          message: 'Event deleted.',
          variant: ToastVariant.success,
        );
        // Drop the now-stale detail off the stack and head to /events.
        context.go('/events');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocConsumer<EventDetailBloc, EventDetailState>(
      listenWhen: (p, n) => p.errors != n.errors && n.errors.isNotEmpty,
      listener: (context, state) {
        showAppToast(
          context,
          message: state.errors.join('\n'),
          variant: ToastVariant.error,
        );
      },
      builder: (context, state) {
        final event = state.event;
        final isCreator = event?.isCreator == true;
        return Scaffold(
          backgroundColor: colors.bgPrimary,
          appBar: AppBar(
            title: const Text('Event'),
            leading: const AppBackButton(fallbackRoute: '/events'),
            actions: [
              if (event != null)
                IconButton(
                  tooltip: 'Q&A',
                  icon: const Icon(LucideIcons.messageCircle),
                  onPressed: () => showNotesSheet(
                    context,
                    eventUid: event.uid,
                    isCreator: isCreator,
                    viewerId: event.creator?.id != null && isCreator
                        ? event.creator!.id
                        : null,
                  ),
                ),
              if (isCreator && event != null)
                PopupMenuButton<_HostAction>(
                  tooltip: 'Host actions',
                  icon: const Icon(LucideIcons.ellipsisVertical),
                  onSelected: (action) {
                    switch (action) {
                      case _HostAction.invite:
                        showSendInvitationsSheet(
                          context,
                          eventUid: event.uid,
                        ).then((count) {
                          if (count != null && count > 0 && context.mounted) {
                            showAppToast(
                              context,
                              message:
                                  'Invited $count ${count == 1 ? "person" : "people"}.',
                              variant: ToastVariant.success,
                            );
                          }
                        });
                      case _HostAction.edit:
                        context.push(
                          '/events/${event.uid}/edit',
                          extra: event,
                        );
                      case _HostAction.delete:
                        _confirmDelete(context, event);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: _HostAction.invite,
                      child: Row(
                        children: [
                          Icon(LucideIcons.userPlus, size: 16),
                          SizedBox(width: 8),
                          Text('Invite people'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _HostAction.edit,
                      child: Row(
                        children: [
                          Icon(LucideIcons.pencil, size: 16),
                          SizedBox(width: 8),
                          Text('Edit event'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _HostAction.delete,
                      child: Row(
                        children: [
                          Icon(LucideIcons.trash2, size: 16),
                          SizedBox(width: 8),
                          Text('Delete event'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, EventDetailState state) {
    final colors = context.colors;
    if (state.loading && state.event == null) {
      return const _DetailSkeleton();
    }
    final event = state.event;
    if (event == null) {
      return Center(
        child: EmptyState(
          icon: LucideIcons.calendarX,
          title: 'Event not found',
          hint: state.errors.isNotEmpty ? state.errors.join('\n') : null,
          action: AppButton(
            label: 'Retry',
            onPressed: () => context
                .read<EventDetailBloc>()
                .add(const EventDetailLoadRequested()),
          ),
        ),
      );
    }
    return Builder(
      builder: (context) {
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: colors.accent,
                  onRefresh: () async {
                    context
                        .read<EventDetailBloc>()
                        .add(const EventDetailRefreshRequested());
                    await context
                        .read<EventDetailBloc>()
                        .stream
                        .firstWhere((s) => !s.refreshing);
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      0,
                      0,
                      AppSpacing.xl,
                    ),
                    children: [
                      if (event.flyerUrl != null && event.flyerUrl!.isNotEmpty)
                        _FlyerHero(url: event.flyerUrl!),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.base),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _BadgeRow(event: event),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              event.title,
                              style: AppTextStyles.pageTitle.copyWith(
                                color: colors.textPrimary,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _DateRow(date: event.eventDate),
                            const SizedBox(height: AppSpacing.sm),
                            _LocationRow(event: event),
                            if (event.creator != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              _OrganiserCard(creator: event.creator!),
                            ],
                            const SizedBox(height: AppSpacing.md),
                            _MetricsRow(event: event),
                            if (event.description.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.md),
                              _DescriptionCard(text: event.description),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _ActionBar(
                event: event,
                busy: state.interestBusy,
                onInterest: () => context
                    .read<EventDetailBloc>()
                    .add(const EventDetailInterestToggled()),
              ),
            ],
          );
        },
    );
  }
}

/// Picks the menu action the host tapped in the detail screen's
/// 3-dot menu.
enum _HostAction { invite, edit, delete }

// ─────────────────────────────────────────────────────────────────────────────
// Hero
// ─────────────────────────────────────────────────────────────────────────────
class _FlyerHero extends StatelessWidget {
  const _FlyerHero({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, _) => Container(color: colors.bgSurfaceHover),
        errorWidget: (_, _, _) => Container(color: colors.bgSurfaceHover),
      ),
    );
  }
}

class _BadgeRow extends StatelessWidget {
  const _BadgeRow({required this.event});
  final Event event;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (event.eventType != null)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
        if (event.isOnline)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colors.info.withValues(alpha: 0.12),
              borderRadius: AppRadius.smAll,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.video, size: 11, color: colors.info),
                const SizedBox(width: 3),
                Text(
                  'ONLINE',
                  style: AppTextStyles.nano.copyWith(
                    color: colors.info,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        if (event.isCreator == true)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colors.success.withValues(alpha: 0.12),
              borderRadius: AppRadius.smAll,
            ),
            child: Text(
              'YOU\'RE THE HOST',
              style: AppTextStyles.nano.copyWith(
                color: colors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.date});
  final DateTime? date;

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const _weekdays = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  String _formatDate(DateTime d) {
    final w = _weekdays[d.weekday - 1];
    final m = _months[d.month - 1];
    return '$w, $m ${d.day}, ${d.year}';
  }

  String _formatTime(DateTime d) {
    final hour12 = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
    final minute = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    return '$hour12:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (date == null) {
      return Row(
        children: [
          Icon(LucideIcons.calendar, size: 14, color: colors.textTertiary),
          const SizedBox(width: 6),
          Text(
            'Date TBA',
            style: AppTextStyles.bodySmall
                .copyWith(color: colors.textTertiary),
          ),
        ],
      );
    }
    final local = date!.toLocal();
    return Row(
      children: [
        Icon(LucideIcons.calendar, size: 14, color: colors.accent),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDate(local),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                _formatTime(local),
                style: AppTextStyles.nano
                    .copyWith(color: colors.textTertiary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.event});
  final Event event;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final loc = event.location;
    final primary = event.isOnline
        ? 'Online event'
        : (loc?.center?.name.isNotEmpty == true
            ? loc!.center!.name
            : (loc?.address.isNotEmpty == true ? loc!.address : 'TBA'));
    final secondary = !event.isOnline && loc?.center != null
        ? loc!.address
        : null;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(LucideIcons.mapPin, size: 14, color: colors.accent),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                primary,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (secondary != null && secondary.isNotEmpty)
                Text(
                  secondary,
                  style: AppTextStyles.nano
                      .copyWith(color: colors.textTertiary),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrganiserCard extends StatelessWidget {
  const _OrganiserCard({required this.creator});
  final EventOrganiser creator;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: InkWell(
        onTap: () => context.push('/u/${creator.username}'),
        borderRadius: AppRadius.mdAll,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _OrganiserAvatar(organiser: creator),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HOSTED BY',
                      style: AppTextStyles.nano
                          .copyWith(color: colors.textTertiary),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            creator.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (creator.badgeIconUrl != null) ...[
                          const SizedBox(width: 4),
                          NetworkBadge(url: creator.badgeIconUrl, size: 14),
                        ],
                      ],
                    ),
                    if (creator.rankDisplay != null &&
                        creator.rankDisplay!.isNotEmpty)
                      Text(
                        creator.rankDisplay!,
                        style: AppTextStyles.nano
                            .copyWith(color: colors.textTertiary),
                      ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight,
                  size: 14, color: colors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrganiserAvatar extends StatelessWidget {
  const _OrganiserAvatar({required this.organiser});
  final EventOrganiser organiser;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = organiser.firstName.isNotEmpty
        ? organiser.firstName.substring(0, 1).toUpperCase()
        : organiser.username.isNotEmpty
            ? organiser.username.substring(0, 1).toUpperCase()
            : '?';
    final placeholder = Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
      ),
      child: Text(
        initial,
        style: AppTextStyles.bodyMedium.copyWith(
          color: colors.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    final url = organiser.profilePictureUrl;
    if (url == null || url.isEmpty) return placeholder;
    return ClipOval(
      child: SizedBox(
        width: 40,
        height: 40,
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

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.event});
  final Event event;

  @override
  Widget build(BuildContext context) {
    final isCreator = event.isCreator == true;
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            icon: LucideIcons.users,
            label: 'Going',
            value: event.goingCount,
            // Only the host can see the full going list (backend gates
            // it on creator-only). Others tap → noop.
            onTap: isCreator
                ? () => showAttendeesSheet(
                      context,
                      eventUid: event.uid,
                      kind: AttendeesKind.going,
                    )
                : null,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MetricTile(
            icon: LucideIcons.heart,
            label: 'Interested',
            value: event.interestedCount,
            onTap: () => showAttendeesSheet(
              context,
              eventUid: event.uid,
              kind: AttendeesKind.interested,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MetricTile(
            icon: LucideIcons.messageCircle,
            label: 'Notes',
            value: event.notesCount,
            onTap: () => showNotesSheet(
              context,
              eventUid: event.uid,
              isCreator: isCreator,
              viewerId: event.creator?.id != null && isCreator
                  ? event.creator!.id
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final int value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 14, color: colors.accent),
              const SizedBox(height: 4),
              Text(
                '$value',
                style: AppTextStyles.numberLarge.copyWith(
                  color: colors.textPrimary,
                  fontSize: 18,
                  height: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label.toUpperCase(),
                style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.fileText, size: 14, color: colors.accent),
              const SizedBox(width: 6),
              Text(
                'ABOUT',
                style: AppTextStyles.label
                    .copyWith(color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: colors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.event,
    required this.busy,
    required this.onInterest,
  });

  final Event event;
  final bool busy;
  final VoidCallback onInterest;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final interested = event.isInterested == true;
    final isCreator = event.isCreator == true;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        border: Border(top: BorderSide(color: colors.borderDefault)),
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          label: isCreator
              ? "You're hosting this event"
              : interested
                  ? 'Interested'
                  : "I'm interested",
          icon: interested ? LucideIcons.heart : LucideIcons.heart,
          variant: interested
              ? AppButtonVariant.secondary
              : AppButtonVariant.primary,
          size: AppButtonSize.large,
          expand: true,
          loading: busy,
          onPressed: isCreator ? null : onInterest,
        ),
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [
        SkeletonBox(height: 200, borderRadius: BorderRadius.zero),
        Padding(
          padding: EdgeInsets.all(AppSpacing.base),
          child: Column(
            children: [
              SkeletonBox(height: 28),
              SizedBox(height: AppSpacing.sm),
              SkeletonBox(height: 16),
              SizedBox(height: AppSpacing.md),
              SkeletonBox(height: 80),
              SizedBox(height: AppSpacing.md),
              SkeletonBox(height: 120),
            ],
          ),
        ),
      ],
    );
  }
}
