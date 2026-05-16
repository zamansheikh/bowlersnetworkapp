import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../messages/domain/entities/conversation.dart' as msg;
import '../../../messages/domain/repositories/messages_repository.dart';
import '../../domain/entities/team.dart';
import '../../domain/repositories/teams_repository.dart';

/// Opens the invite-members sheet for [teamId]. Returns the
/// [TeamInviteResult] (sent + skipped) so the caller can toast both
/// outcomes. Returns null if the user backs out without sending.
Future<TeamInviteResult?> showInviteMembersSheet(
  BuildContext context, {
  required int teamId,

  /// User ids already on the team — pre-selected & disabled so the user
  /// can't pick them again.
  required Set<int> existingMemberIds,
}) {
  return showModalBottomSheet<TeamInviteResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => _InviteMembersSheet(
      teamId: teamId,
      existingMemberIds: existingMemberIds,
    ),
  );
}

class _InviteMembersSheet extends StatefulWidget {
  const _InviteMembersSheet({
    required this.teamId,
    required this.existingMemberIds,
  });
  final int teamId;
  final Set<int> existingMemberIds;

  @override
  State<_InviteMembersSheet> createState() => _InviteMembersSheetState();
}

class _InviteMembersSheetState extends State<_InviteMembersSheet> {
  final _teamsRepo = getIt<TeamsRepository>();
  final _messagesRepo = getIt<MessagesRepository>();
  final _queryCtl = TextEditingController();
  Timer? _debounce;

  bool _searching = false;
  bool _sending = false;
  List<msg.SearchUser> _results = const [];
  final List<msg.SearchUser> _selected = [];
  List<String> _errors = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _queryCtl.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      setState(() {
        _results = const [];
        _searching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      if (!mounted) return;
      setState(() => _searching = true);
      final res = await _messagesRepo.searchUsers(trimmed);
      if (!mounted) return;
      res.fold(
        (_) => setState(() {
          _searching = false;
          _results = const [];
        }),
        (list) => setState(() {
          _searching = false;
          _results = list;
        }),
      );
    });
  }

  void _toggleSelect(msg.SearchUser u) {
    if (widget.existingMemberIds.contains(u.id)) return;
    setState(() {
      final idx = _selected.indexWhere((s) => s.id == u.id);
      if (idx >= 0) {
        _selected.removeAt(idx);
      } else {
        _selected.add(u);
      }
    });
  }

  Future<void> _send() async {
    if (_selected.isEmpty) return;
    setState(() {
      _sending = true;
      _errors = const [];
    });
    final res = await _teamsRepo.sendInvitations(
      teamId: widget.teamId,
      userIds: _selected.map((s) => s.id).toList(growable: false),
    );
    if (!mounted) return;
    res.fold(
      (f) => setState(() {
        _sending = false;
        _errors = f.messages.isEmpty
            ? const ['Failed to send invitations.']
            : f.messages;
      }),
      (result) => Navigator.of(context).pop(result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
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
                  IconButton(
                    icon: Icon(LucideIcons.x,
                        size: 20, color: colors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Invite members',
                        style: AppTextStyles.sectionTitle.copyWith(
                          color: colors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            if (_selected.isNotEmpty)
              _SelectedChips(users: _selected, onRemove: _toggleSelect),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.bgSurface,
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(color: colors.borderStrong),
                ),
                child: TextField(
                  controller: _queryCtl,
                  autofocus: true,
                  onChanged: _onQueryChanged,
                  style: AppTextStyles.body.copyWith(color: colors.textPrimary),
                  cursorColor: colors.accent,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'Search people…',
                    hintStyle: AppTextStyles.body
                        .copyWith(color: colors.textTertiary, fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    prefixIcon: Icon(LucideIcons.search,
                        size: 16, color: colors.textTertiary),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 36),
                    suffixIcon: _searching
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.accent,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            Flexible(
              child: _ResultsList(
                results: _results,
                query: _queryCtl.text.trim(),
                searching: _searching,
                existingIds: widget.existingMemberIds,
                selectedIds: _selected.map((u) => u.id).toSet(),
                onPick: _toggleSelect,
              ),
            ),
            if (_errors.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  _errors.join('\n'),
                  style: AppTextStyles.bodySmall.copyWith(color: colors.error),
                ),
              ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  AppSpacing.base,
                ),
                child: AppButton(
                  label: _selected.isEmpty
                      ? 'Select at least one'
                      : 'Send invitations (${_selected.length})',
                  expand: true,
                  size: AppButtonSize.large,
                  loading: _sending,
                  onPressed: _selected.isEmpty || _sending ? null : _send,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({
    required this.results,
    required this.query,
    required this.searching,
    required this.existingIds,
    required this.selectedIds,
    required this.onPick,
  });

  final List<msg.SearchUser> results;
  final String query;
  final bool searching;
  final Set<int> existingIds;
  final Set<int> selectedIds;
  final ValueChanged<msg.SearchUser> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (results.isEmpty && query.length >= 2 && !searching) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Text(
            'No users found',
            style:
                AppTextStyles.bodySmall.copyWith(color: colors.textTertiary),
          ),
        ),
      );
    }
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Text(
            'Start typing to search',
            style:
                AppTextStyles.bodySmall.copyWith(color: colors.textTertiary),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: results.length,
      itemBuilder: (_, i) {
        final u = results[i];
        final alreadyMember = existingIds.contains(u.id);
        final isSelected = selectedIds.contains(u.id);
        return _UserRow(
          user: u,
          selected: isSelected,
          disabled: alreadyMember,
          subtitle: alreadyMember ? 'Already on team' : null,
          onTap: alreadyMember ? null : () => onPick(u),
        );
      },
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.selected,
    required this.disabled,
    required this.onTap,
    this.subtitle,
  });

  final msg.SearchUser user;
  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Opacity(
            opacity: disabled ? 0.5 : 1.0,
            child: Row(
              children: [
                _Avatar(url: user.profilePictureUrl, fallback: user.displayName),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user.displayName,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle ??
                            (user.rankDisplay == null
                                ? '@${user.username}'
                                : '@${user.username} · ${user.rankDisplay}'),
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.secondary
                            .copyWith(color: colors.textTertiary),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? colors.accent : Colors.transparent,
                    border: Border.all(
                      color: selected ? colors.accent : colors.borderStrong,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: selected
                      ? const Icon(LucideIcons.check,
                          size: 13, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedChips extends StatelessWidget {
  const _SelectedChips({required this.users, required this.onRemove});
  final List<msg.SearchUser> users;
  final ValueChanged<msg.SearchUser> onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: users.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final u = users[i];
          return Material(
            color: colors.accentSubtle,
            borderRadius: AppRadius.fullAll,
            child: InkWell(
              borderRadius: AppRadius.fullAll,
              onTap: () => onRemove(u),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '@${u.username}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(LucideIcons.x, size: 12, color: colors.accent),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.fallback});
  final String? url;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = fallback.isEmpty ? '?' : fallback[0].toUpperCase();
    final placeholder = Container(
      width: 36,
      height: 36,
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
    if (url == null || url!.isEmpty) return placeholder;
    return ClipOval(
      child: SizedBox(
        width: 36,
        height: 36,
        child: CachedNetworkImage(
          imageUrl: url!,
          fit: BoxFit.cover,
          placeholder: (_, _) => placeholder,
          errorWidget: (_, _, _) => placeholder,
        ),
      ),
    );
  }
}
