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
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/team.dart';
import '../bloc/teams_bloc.dart';
import '../widgets/create_team_sheet.dart';

/// /teams — viewer's teams + pending invitations. Two action surfaces:
/// 1. Tap a team card → /teams/:id (detail screen, batch 2)
/// 2. Tap Create → bottom sheet with a name + optional invitee picker
class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TeamsBloc>(
      create: (_) => getIt<TeamsBloc>()..add(const TeamsLoadRequested()),
      child: const _TeamsView(),
    );
  }
}

class _TeamsView extends StatelessWidget {
  const _TeamsView();

  Future<void> _openCreate(BuildContext context) async {
    final bloc = context.read<TeamsBloc>();
    final team = await showCreateTeamSheet(context);
    if (team != null) {
      bloc.add(TeamCreated(team));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        title: const Text('Teams'),
        leading: const AppBackButton(),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.plus, color: colors.accent),
            tooltip: 'Create team',
            onPressed: () => _openCreate(context),
          ),
        ],
      ),
      body: BlocConsumer<TeamsBloc, TeamsState>(
        listenWhen: (p, n) => p.errors != n.errors && n.errors.isNotEmpty,
        listener: (context, state) {
          showAppToast(
            context,
            message: state.errors.join('\n'),
            variant: ToastVariant.error,
          );
        },
        builder: (context, state) {
          if (state.loading && state.teams.isEmpty &&
              state.invitations.received.isEmpty) {
            return const _TeamsSkeleton();
          }

          final hasAnything = state.teams.isNotEmpty ||
              state.invitations.received.isNotEmpty ||
              state.invitations.sent.isNotEmpty;

          if (!hasAnything) {
            return RefreshIndicator(
              color: colors.accent,
              onRefresh: () async {
                context.read<TeamsBloc>().add(const TeamsRefreshRequested());
                await context
                    .read<TeamsBloc>()
                    .stream
                    .firstWhere((s) => !s.refreshing);
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 64),
                  EmptyState(
                    icon: LucideIcons.users,
                    title: 'No teams yet',
                    hint:
                        'Create a team to start bowling with your crew.',
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: AppButton(
                      label: 'Create team',
                      icon: LucideIcons.plus,
                      expand: true,
                      onPressed: () => _openCreate(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: colors.accent,
            onRefresh: () async {
              context.read<TeamsBloc>().add(const TeamsRefreshRequested());
              await context
                  .read<TeamsBloc>()
                  .stream
                  .firstWhere((s) => !s.refreshing);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.sm,
                AppSpacing.base,
                AppSpacing.xl,
              ),
              children: [
                if (state.invitations.received.isNotEmpty) ...[
                  _SectionTitle(
                    icon: LucideIcons.mailPlus,
                    label:
                        'Pending invitations (${state.invitations.received.length})',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final inv in state.invitations.received)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _ReceivedInvitationCard(
                        invitation: inv,
                        busy: state.isInvitationBusy(inv.id),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.base),
                ],
                _SectionTitle(
                  icon: LucideIcons.users,
                  label: 'My teams (${state.teams.length})',
                ),
                const SizedBox(height: AppSpacing.sm),
                if (state.teams.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    child: Text(
                      "You aren't in any teams yet.",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  for (final t in state.teams)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _TeamCard(team: t),
                    ),
                if (state.invitations.sent.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.base),
                  _SectionTitle(
                    icon: LucideIcons.send,
                    label:
                        'Sent invitations (${state.invitations.sent.length})',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final inv in state.invitations.sent)
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: _SentInvitationRow(
                        invitation: inv,
                        busy: state.isInvitationBusy(inv.id),
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(icon, size: 14, color: colors.accent),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard({required this.team});
  final Team team;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.bgSurface,
      borderRadius: AppRadius.lgAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/teams/${team.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Row(
            children: [
              _TeamLogo(url: team.logoUrl, fallback: team.name),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      team.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Created by @${team.createdBy.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.nano.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              _MemberPill(count: team.memberCount, max: team.maxSize),
              const SizedBox(width: 6),
              Icon(LucideIcons.chevronRight,
                  size: 16, color: colors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberPill extends StatelessWidget {
  const _MemberPill({required this.count, required this.max});
  final int count;
  final int max;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.bgSurfaceHover,
        borderRadius: AppRadius.fullAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.user, size: 11, color: colors.textSecondary),
          const SizedBox(width: 4),
          Text(
            '$count/$max',
            style: AppTextStyles.nano.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceivedInvitationCard extends StatelessWidget {
  const _ReceivedInvitationCard({
    required this.invitation,
    required this.busy,
  });
  final TeamInvitation invitation;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final inviter = invitation.invitedBy;
    return Material(
      color: colors.bgSurface,
      borderRadius: AppRadius.lgAll,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _TeamLogo(
                  url: invitation.team.logoUrl,
                  fallback: invitation.team.name,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        invitation.team.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        inviter == null
                            ? 'You were invited to join'
                            : 'Invited by @${inviter.username}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.nano.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Decline',
                    variant: AppButtonVariant.secondary,
                    onPressed: busy
                        ? null
                        : () => context.read<TeamsBloc>().add(
                              TeamInvitationDeclineRequested(invitation.id),
                            ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: 'Accept',
                    loading: busy,
                    onPressed: busy
                        ? null
                        : () => context.read<TeamsBloc>().add(
                              TeamInvitationAcceptRequested(invitation.id),
                            ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SentInvitationRow extends StatelessWidget {
  const _SentInvitationRow({
    required this.invitation,
    required this.busy,
  });
  final TeamInvitation invitation;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.bgSurface,
      borderRadius: AppRadius.mdAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '@${invitation.invitedUser.username}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'to ${invitation.team.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.nano.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: busy
                  ? null
                  : () => context.read<TeamsBloc>().add(
                        TeamInvitationCancelRequested(invitation.id),
                      ),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              child: Text(
                busy ? 'Cancelling…' : 'Cancel',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamLogo extends StatelessWidget {
  const _TeamLogo({required this.url, required this.fallback});
  final String url;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = fallback.isEmpty ? '?' : fallback[0].toUpperCase();
    final placeholder = Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.accentSubtle,
        borderRadius: AppRadius.mdAll,
      ),
      child: Text(
        initial,
        style: AppTextStyles.body.copyWith(
          color: colors.accent,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    if (url.isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: AppRadius.mdAll,
      child: SizedBox(
        width: 44,
        height: 44,
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

class _TeamsSkeleton extends StatelessWidget {
  const _TeamsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, _) => const SkeletonBox(height: 72),
    );
  }
}
