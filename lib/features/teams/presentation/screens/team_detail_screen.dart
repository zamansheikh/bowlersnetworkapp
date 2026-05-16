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
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../domain/entities/team.dart';
import '../bloc/team_detail_bloc.dart';
import '../bloc/teams_bloc.dart';
import '../widgets/invite_members_sheet.dart';

/// /teams/:id — full team detail. Members list with role chips,
/// per-row actions for the creator (set role / jersey / remove), and
/// a footer action bar (Invite + Delete for the creator; Leave for
/// regular members). Listens for the bloc's `exited` flag to pop back
/// to the list after Leave / Delete.
class TeamDetailScreen extends StatelessWidget {
  const TeamDetailScreen({super.key, required this.teamId});
  final int teamId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TeamDetailBloc>(
      create: (_) =>
          getIt<TeamDetailBloc>()..add(TeamDetailLoadRequested(teamId)),
      child: _TeamDetailView(teamId: teamId),
    );
  }
}

class _TeamDetailView extends StatelessWidget {
  const _TeamDetailView({required this.teamId});
  final int teamId;

  /// Best-effort viewer id from ProfileBloc — null if profile hasn't
  /// loaded yet (the screen falls back to "not the creator" in that
  /// case, which is the safe default).
  int? _viewerId(BuildContext context) =>
      context.read<ProfileBloc>().state.profile?.user.id;

  Future<void> _onInvite(BuildContext context, Team team) async {
    final detailBloc = context.read<TeamDetailBloc>();
    final existing = team.members.map((m) => m.user.id).toSet();
    final result = await showInviteMembersSheet(
      context,
      teamId: team.id,
      existingMemberIds: existing,
    );
    if (result == null || !context.mounted) return;
    detailBloc.add(const TeamInvitationsAfterSend());
    final lines = <String>[];
    if (result.sent.isNotEmpty) lines.add('Sent ${result.sent.length}');
    if (result.skipped.isNotEmpty) {
      lines.add('Skipped ${result.skipped.length}');
    }
    if (lines.isNotEmpty) {
      showAppToast(
        context,
        message: lines.join(' · '),
        variant: result.skipped.isEmpty
            ? ToastVariant.success
            : ToastVariant.info,
      );
    }
  }

  Future<void> _onLeave(BuildContext context, Team team) async {
    final ok = await _confirm(
      context,
      title: 'Leave "${team.name}"?',
      body: "You'll lose access to the team chat and have to be re-invited.",
      confirmLabel: 'Leave',
      destructive: true,
    );
    if (ok != true || !context.mounted) return;
    context.read<TeamDetailBloc>().add(const TeamLeftByViewer());
  }

  Future<void> _onDelete(BuildContext context, Team team) async {
    final ok = await _confirm(
      context,
      title: 'Delete "${team.name}"?',
      body:
          "This permanently removes the team for everyone. This can't be undone.",
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (ok != true || !context.mounted) return;
    context.read<TeamDetailBloc>().add(const TeamDeletedByCreator());
  }

  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
    bool destructive = false,
  }) {
    final colors = context.colors;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.bgSurfaceElevated,
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: destructive ? colors.error : colors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocConsumer<TeamDetailBloc, TeamDetailState>(
      listenWhen: (p, n) =>
          (p.errors != n.errors && n.errors.isNotEmpty) ||
          (!p.exited && n.exited),
      listener: (context, state) {
        if (state.errors.isNotEmpty) {
          showAppToast(
            context,
            message: state.errors.join('\n'),
            variant: ToastVariant.error,
          );
        }
        if (state.exited) {
          // Tell the list bloc to drop the team, then pop back.
          try {
            context.read<TeamsBloc>().add(TeamRemovedLocally(teamId));
          } catch (_) {
            // List bloc isn't in scope (e.g. deep link) — just navigate.
          }
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/teams');
          }
        }
      },
      builder: (context, state) {
        final team = state.team;
        return Scaffold(
          backgroundColor: colors.bgPrimary,
          appBar: AppBar(
            title: const Text('Team'),
            leading: const AppBackButton(fallbackRoute: '/teams'),
          ),
          body: team == null
              ? state.loading
                  ? const _DetailSkeleton()
                  : EmptyState(
                      icon: LucideIcons.users,
                      title: 'Team unavailable',
                      hint: state.errors.isEmpty ? null : state.errors.first,
                    )
              : RefreshIndicator(
                  color: colors.accent,
                  onRefresh: () async {
                    context
                        .read<TeamDetailBloc>()
                        .add(const TeamDetailRefreshRequested());
                    await context
                        .read<TeamDetailBloc>()
                        .stream
                        .firstWhere((s) => !s.refreshing);
                  },
                  child: _DetailBody(
                    team: team,
                    viewerId: _viewerId(context),
                    busyMemberIds: state.busyMemberIds,
                    processingExit: state.processingExit,
                    onInvite: () => _onInvite(context, team),
                    onLeave: () => _onLeave(context, team),
                    onDelete: () => _onDelete(context, team),
                  ),
                ),
        );
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.team,
    required this.viewerId,
    required this.busyMemberIds,
    required this.processingExit,
    required this.onInvite,
    required this.onLeave,
    required this.onDelete,
  });

  final Team team;
  final int? viewerId;
  final Set<int> busyMemberIds;
  final bool processingExit;
  final VoidCallback onInvite;
  final VoidCallback onLeave;
  final VoidCallback onDelete;

  bool get _isCreator => viewerId != null && team.createdBy.id == viewerId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.xl,
      ),
      children: [
        _Header(team: team),
        const SizedBox(height: AppSpacing.lg),
        _ActionBar(
          team: team,
          isCreator: _isCreator,
          processingExit: processingExit,
          onInvite: onInvite,
          onLeave: onLeave,
          onDelete: onDelete,
        ),
        const SizedBox(height: AppSpacing.xl),
        _MembersSection(
          team: team,
          isCreator: _isCreator,
          viewerId: viewerId,
          busyMemberIds: busyMemberIds,
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.team});
  final Team team;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _LargeLogo(url: team.logoUrl, fallback: team.name),
        const SizedBox(height: AppSpacing.md),
        Text(
          team.name,
          textAlign: TextAlign.center,
          style: AppTextStyles.sectionTitle.copyWith(
            color: colors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Created by @${team.createdBy.username}',
          style: AppTextStyles.bodySmall.copyWith(color: colors.textTertiary),
        ),
        if (team.description.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            team.description,
            textAlign: TextAlign.center,
            style:
                AppTextStyles.bodySmall.copyWith(color: colors.textSecondary),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colors.bgSurfaceHover,
            borderRadius: AppRadius.fullAll,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.users, size: 12, color: colors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${team.memberCount} / ${team.maxSize} members',
                style: AppTextStyles.nano.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.team,
    required this.isCreator,
    required this.processingExit,
    required this.onInvite,
    required this.onLeave,
    required this.onDelete,
  });

  final Team team;
  final bool isCreator;
  final bool processingExit;
  final VoidCallback onInvite;
  final VoidCallback onLeave;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final hasConversation = team.conversationUid.isNotEmpty;
    return Column(
      children: [
        if (hasConversation)
          AppButton(
            label: 'Open team chat',
            icon: LucideIcons.messageCircle,
            variant: AppButtonVariant.secondary,
            expand: true,
            onPressed: () => context.push(
              '/messages/${team.conversationUid}',
            ),
          ),
        if (isCreator) ...[
          if (hasConversation) const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: team.isFull ? 'Team is full' : 'Invite members',
            icon: LucideIcons.userPlus,
            expand: true,
            onPressed: team.isFull || processingExit ? null : onInvite,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Delete team',
            icon: LucideIcons.trash2,
            variant: AppButtonVariant.destructive,
            expand: true,
            loading: processingExit,
            onPressed: processingExit ? null : onDelete,
          ),
        ] else ...[
          if (hasConversation) const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Leave team',
            icon: LucideIcons.logOut,
            variant: AppButtonVariant.destructive,
            expand: true,
            loading: processingExit,
            onPressed: processingExit ? null : onLeave,
          ),
        ],
      ],
    );
  }
}

class _MembersSection extends StatelessWidget {
  const _MembersSection({
    required this.team,
    required this.isCreator,
    required this.viewerId,
    required this.busyMemberIds,
  });

  final Team team;
  final bool isCreator;
  final int? viewerId;
  final Set<int> busyMemberIds;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.users, size: 14, color: colors.accent),
            const SizedBox(width: 6),
            Text(
              'Members (${team.members.length})',
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (team.members.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Text(
              'No members yet.',
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          for (final m in team.members)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _MemberRow(
                member: m,
                isCreatorOfTeam: m.user.id == team.createdBy.id,
                isSelf: viewerId != null && m.user.id == viewerId,
                viewerIsCreator: isCreator,
                busy: busyMemberIds.contains(m.user.id),
              ),
            ),
      ],
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.isCreatorOfTeam,
    required this.isSelf,
    required this.viewerIsCreator,
    required this.busy,
  });

  final TeamMember member;
  final bool isCreatorOfTeam;
  final bool isSelf;
  final bool viewerIsCreator;
  final bool busy;

  /// Creator can edit anyone except themselves; captains can edit roles
  /// of others but we keep the menu visible only for the creator to
  /// keep the UI simple. Self-jersey edit is still allowed via the menu.
  bool get _showActions => (viewerIsCreator && !isCreatorOfTeam) || isSelf;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final user = member.user;
    return Material(
      color: colors.bgSurface,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: () => context.push('/u/${user.username}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              _MemberAvatar(user: user),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isCreatorOfTeam) ...[
                          const SizedBox(width: 6),
                          _RoleChip(
                            label: 'CREATOR',
                            color: colors.accent,
                          ),
                        ] else
                          ...[
                            const SizedBox(width: 6),
                            _RoleChip(
                              label: member.role.label.toUpperCase(),
                              color: member.isCaptain
                                  ? colors.success
                                  : colors.textTertiary,
                            ),
                          ],
                        if (member.jerseyNumber != null) ...[
                          const SizedBox(width: 6),
                          _RoleChip(
                            label: '#${member.jerseyNumber}',
                            color: colors.textSecondary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${user.username}',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.nano.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (busy)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.accent,
                  ),
                )
              else if (_showActions)
                _MemberActionsMenu(
                  member: member,
                  viewerIsCreator: viewerIsCreator,
                  isSelf: isSelf,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberActionsMenu extends StatelessWidget {
  const _MemberActionsMenu({
    required this.member,
    required this.viewerIsCreator,
    required this.isSelf,
  });
  final TeamMember member;
  final bool viewerIsCreator;
  final bool isSelf;

  Future<void> _setRole(BuildContext context, TeamRole role) async {
    context.read<TeamDetailBloc>().add(
          TeamMemberRoleSet(userId: member.user.id, role: role),
        );
  }

  Future<void> _editJersey(BuildContext context) async {
    final number = await _promptJersey(context, member.jerseyNumber);
    if (!context.mounted) return;
    if (number == _jerseyCancelled) return;
    context.read<TeamDetailBloc>().add(
          TeamMemberJerseySet(
            userId: member.user.id,
            jerseyNumber: number,
          ),
        );
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final colors = context.colors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.bgSurfaceElevated,
        title: Text('Remove @${member.user.username}?'),
        content: const Text(
          "They'll lose access to the team chat and have to be re-invited.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Remove', style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    context.read<TeamDetailBloc>().add(TeamMemberRemoved(member.user.id));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PopupMenuButton<String>(
      icon: Icon(LucideIcons.ellipsisVertical,
          size: 18, color: colors.textTertiary),
      tooltip: 'Member actions',
      color: colors.bgSurfaceElevated,
      onSelected: (action) {
        switch (action) {
          case 'role-captain':
            _setRole(context, TeamRole.captain);
          case 'role-player':
            _setRole(context, TeamRole.player);
          case 'role-substitute':
            _setRole(context, TeamRole.substitute);
          case 'jersey':
            _editJersey(context);
          case 'remove':
            _confirmRemove(context);
        }
      },
      itemBuilder: (_) {
        final items = <PopupMenuEntry<String>>[];
        if (viewerIsCreator) {
          for (final role in TeamRole.values) {
            final selected = member.role == role;
            items.add(PopupMenuItem(
              value: 'role-${role.wire}',
              child: Row(
                children: [
                  Icon(
                    selected ? LucideIcons.check : LucideIcons.circle,
                    size: 14,
                    color: selected ? colors.accent : colors.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Text('Make ${role.label}'),
                ],
              ),
            ));
          }
          items.add(const PopupMenuDivider());
        }
        if (viewerIsCreator || isSelf) {
          items.add(PopupMenuItem(
            value: 'jersey',
            child: Row(
              children: [
                Icon(LucideIcons.shirt,
                    size: 14, color: colors.textSecondary),
                const SizedBox(width: 8),
                const Text('Set jersey number'),
              ],
            ),
          ));
        }
        if (viewerIsCreator && !isSelf) {
          items.add(const PopupMenuDivider());
          items.add(PopupMenuItem(
            value: 'remove',
            child: Row(
              children: [
                Icon(LucideIcons.userMinus, size: 14, color: colors.error),
                const SizedBox(width: 8),
                Text('Remove', style: TextStyle(color: colors.error)),
              ],
            ),
          ));
        }
        return items;
      },
    );
  }
}

/// Sentinel value the prompt dialog returns when the user cancels —
/// distinguishes "no change" from "clear the jersey number" (null).
const Object _jerseyCancelled = Object();

Future<dynamic> _promptJersey(BuildContext context, int? current) async {
  final colors = context.colors;
  final ctl = TextEditingController(
    text: current?.toString() ?? '',
  );
  final result = await showDialog<dynamic>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: colors.bgSurfaceElevated,
      title: const Text('Jersey number'),
      content: TextField(
        controller: ctl,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: 'e.g. 23'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(_jerseyCancelled),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(null),
          child: Text('Clear', style: TextStyle(color: colors.error)),
        ),
        TextButton(
          onPressed: () {
            final n = int.tryParse(ctl.text.trim());
            Navigator.of(ctx).pop(n);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
  return result;
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        label,
        style: AppTextStyles.nano.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.user});
  final TeamUser user;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = user.firstName.isNotEmpty
        ? user.firstName[0].toUpperCase()
        : user.username.isNotEmpty
            ? user.username[0].toUpperCase()
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
        style: AppTextStyles.bodySmall.copyWith(
          color: colors.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    final url = user.profilePictureUrl;
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

class _LargeLogo extends StatelessWidget {
  const _LargeLogo({required this.url, required this.fallback});
  final String url;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = fallback.isEmpty ? '?' : fallback[0].toUpperCase();
    final placeholder = Container(
      width: 88,
      height: 88,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.accentSubtle,
        borderRadius: AppRadius.lgAll,
      ),
      child: Text(
        initial,
        style: AppTextStyles.sectionTitle.copyWith(
          color: colors.accent,
          fontSize: 32,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
    if (url.isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: SizedBox(
        width: 88,
        height: 88,
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

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.base),
      children: const [
        Center(child: SkeletonBox(width: 88, height: 88)),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 24),
        SizedBox(height: AppSpacing.sm),
        SkeletonBox(height: 16),
        SizedBox(height: AppSpacing.xl),
        SkeletonBox(height: 64),
        SizedBox(height: AppSpacing.sm),
        SkeletonBox(height: 64),
        SizedBox(height: AppSpacing.sm),
        SkeletonBox(height: 64),
      ],
    );
  }
}
