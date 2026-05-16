import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/event.dart';
import '../bloc/invitations_bloc.dart';

/// /events/invitations — pending/responded invitations inbox.
/// Accept / decline pills sit on every still-pending row; resolved
/// invitations show their final status as a chip.
class InvitationsScreen extends StatelessWidget {
  const InvitationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InvitationsBloc>(
      create: (_) => getIt<InvitationsBloc>()
        ..add(const InvitationsLoadRequested()),
      child: const _InvitationsView(),
    );
  }
}

class _InvitationsView extends StatefulWidget {
  const _InvitationsView();
  @override
  State<_InvitationsView> createState() => _InvitationsViewState();
}

class _InvitationsViewState extends State<_InvitationsView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final remaining =
        _scroll.position.maxScrollExtent - _scroll.position.pixels;
    if (remaining < 600) {
      context.read<InvitationsBloc>().add(
            const InvitationsNextPageRequested(),
          );
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        title: const Text('Invitations'),
        leading: const AppBackButton(fallbackRoute: '/events'),
      ),
      body: BlocConsumer<InvitationsBloc, InvitationsState>(
        listenWhen: (p, n) => p.errors != n.errors && n.errors.isNotEmpty,
        listener: (context, state) {
          showAppToast(
            context,
            message: state.errors.join('\n'),
            variant: ToastVariant.error,
          );
        },
        builder: (context, state) {
          if (state.loading && state.invitations.isEmpty) {
            return const _Skeleton();
          }
          if (state.invitations.isEmpty) {
            return const EmptyState(
              icon: LucideIcons.mailQuestionMark,
              title: 'No invitations',
              hint: 'When someone invites you to an event, it shows up here.',
            );
          }
          return RefreshIndicator(
            color: colors.accent,
            onRefresh: () async {
              context
                  .read<InvitationsBloc>()
                  .add(const InvitationsRefreshRequested());
              await context
                  .read<InvitationsBloc>()
                  .stream
                  .firstWhere((s) => !s.refreshing);
            },
            child: ListView.separated(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.xl,
              ),
              itemCount: state.invitations.length +
                  (state.loadingMore ? 1 : 0),
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) {
                if (i >= state.invitations.length) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.accent,
                        ),
                      ),
                    ),
                  );
                }
                final inv = state.invitations[i];
                return _InvitationCard(
                  invitation: inv,
                  busy: state.busyIds.contains(inv.id),
                  onAccept: () => context
                      .read<InvitationsBloc>()
                      .add(InvitationRespondRequested(
                        invitationId: inv.id,
                        status: InvitationStatus.accepted,
                      )),
                  onDecline: () => context
                      .read<InvitationsBloc>()
                      .add(InvitationRespondRequested(
                        invitationId: inv.id,
                        status: InvitationStatus.declined,
                      )),
                  onTap: () => context.push('/events/${inv.eventUid}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.invitation,
    required this.busy,
    required this.onAccept,
    required this.onDecline,
    required this.onTap,
  });

  final EventInvitation invitation;
  final bool busy;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onTap;

  static const _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final d = invitation.eventDate;
    final pending = invitation.status == InvitationStatus.pending;
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.bgSurfaceHover,
                      borderRadius: AppRadius.smAll,
                      border: Border.all(color: colors.borderDefault),
                    ),
                    child: d == null
                        ? Icon(LucideIcons.calendar,
                            size: 16, color: colors.textTertiary)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _months[d.month - 1],
                                style: AppTextStyles.nano.copyWith(
                                  color: colors.accent,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9,
                                ),
                              ),
                              Text(
                                '${d.day}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOU\'RE INVITED',
                          style: AppTextStyles.nano.copyWith(
                            color: colors.textTertiary,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          invitation.eventTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.cardTitle.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (pending)
                Row(
                  children: [
                    Expanded(
                      child: _ResponseButton(
                        label: 'Decline',
                        icon: LucideIcons.x,
                        busy: busy,
                        variant: _ResponseVariant.outline,
                        onTap: onDecline,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _ResponseButton(
                        label: 'Accept',
                        icon: LucideIcons.check,
                        busy: busy,
                        variant: _ResponseVariant.filled,
                        onTap: onAccept,
                      ),
                    ),
                  ],
                )
              else
                Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusChip(status: invitation.status),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ResponseVariant { outline, filled }

class _ResponseButton extends StatelessWidget {
  const _ResponseButton({
    required this.label,
    required this.icon,
    required this.busy,
    required this.variant,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool busy;
  final _ResponseVariant variant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filled = variant == _ResponseVariant.filled;
    return Material(
      color: filled ? colors.accent : Colors.transparent,
      borderRadius: AppRadius.fullAll,
      child: InkWell(
        borderRadius: AppRadius.fullAll,
        onTap: busy ? null : onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: AppRadius.fullAll,
            border: Border.all(
              color: filled ? colors.accent : colors.borderDefault,
            ),
          ),
          child: Center(
            child: busy
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: filled ? Colors.white : colors.accent,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: filled ? Colors.white : colors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: filled ? Colors.white : colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final InvitationStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (Color tint, IconData icon, String label) = switch (status) {
      InvitationStatus.accepted => (colors.success, LucideIcons.check, 'Accepted'),
      InvitationStatus.declined => (colors.error, LucideIcons.x, 'Declined'),
      InvitationStatus.pending =>
        (colors.textTertiary, LucideIcons.clock, 'Pending'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: AppRadius.smAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: tint),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.nano.copyWith(
              color: tint,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, _) => const SkeletonBox(height: 140),
    );
  }
}
