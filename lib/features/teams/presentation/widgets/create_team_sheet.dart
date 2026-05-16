import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../messages/domain/entities/conversation.dart' as msg;
import '../../../messages/domain/repositories/messages_repository.dart';
import '../../domain/entities/team.dart';
import '../../domain/repositories/teams_repository.dart';

/// Opens the create-team flow. Returns the freshly-created [Team] on
/// success or null if the user backed out. Caller is responsible for
/// dispatching `TeamCreated` to the bloc.
Future<Team?> showCreateTeamSheet(BuildContext context) {
  return showModalBottomSheet<Team>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => const _CreateTeamSheet(),
  );
}

enum _CreateStep { name, invite }

class _CreateTeamSheet extends StatefulWidget {
  const _CreateTeamSheet();
  @override
  State<_CreateTeamSheet> createState() => _CreateTeamSheetState();
}

class _CreateTeamSheetState extends State<_CreateTeamSheet> {
  final _teamsRepo = getIt<TeamsRepository>();

  /// Reused for user search — same endpoint /api/users/search.
  final _messagesRepo = getIt<MessagesRepository>();

  final _nameCtl = TextEditingController();
  final _maxSizeCtl = TextEditingController(text: '5');
  final _queryCtl = TextEditingController();

  Timer? _nameDebounce;
  Timer? _searchDebounce;

  _CreateStep _step = _CreateStep.name;

  // Name-validation state. `_nameStatus` only matters when non-null +
  // current — null means "no signal yet". `_validatingName` shows the
  // inline spinner.
  bool _validatingName = false;
  TeamNameAvailability? _nameStatus;

  bool _creating = false;
  List<String> _errors = const [];

  // Invite picker state
  bool _searching = false;
  List<msg.SearchUser> _results = const [];
  final List<msg.SearchUser> _selected = [];

  @override
  void dispose() {
    _nameDebounce?.cancel();
    _searchDebounce?.cancel();
    _nameCtl.dispose();
    _maxSizeCtl.dispose();
    _queryCtl.dispose();
    super.dispose();
  }

  bool get _nameValid {
    final trimmed = _nameCtl.text.trim();
    if (trimmed.isEmpty) return false;
    final status = _nameStatus;
    if (status == null) return true;
    return status.available;
  }

  int get _maxSize {
    final parsed = int.tryParse(_maxSizeCtl.text.trim());
    if (parsed == null || parsed < 1) return 5;
    return parsed;
  }

  void _onNameChanged(String value) {
    _nameDebounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _nameStatus = null;
        _validatingName = false;
      });
      return;
    }
    _nameDebounce = Timer(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      setState(() => _validatingName = true);
      final res = await _teamsRepo.validateName(trimmed);
      if (!mounted) return;
      // Stale-response guard — if the user has typed again, ignore.
      if (_nameCtl.text.trim() != trimmed) return;
      res.fold(
        (_) => setState(() {
          _validatingName = false;
          _nameStatus = null;
        }),
        (status) => setState(() {
          _validatingName = false;
          _nameStatus = status;
        }),
      );
    });
  }

  void _onQueryChanged(String value) {
    _searchDebounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      setState(() {
        _results = const [];
        _searching = false;
      });
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 250), () async {
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
    setState(() {
      final idx = _selected.indexWhere((s) => s.id == u.id);
      if (idx >= 0) {
        _selected.removeAt(idx);
      } else {
        _selected.add(u);
      }
    });
  }

  Future<void> _createAndMaybeInvite() async {
    final name = _nameCtl.text.trim();
    if (name.isEmpty) {
      setState(() => _errors = const ['Enter a team name.']);
      return;
    }
    setState(() {
      _creating = true;
      _errors = const [];
    });
    final createRes = await _teamsRepo.createTeam(
      name: name,
      maxSize: _maxSize,
    );
    if (!mounted) return;
    await createRes.fold(
      (f) async {
        setState(() {
          _creating = false;
          _errors = f.messages.isEmpty
              ? const ['Failed to create team.']
              : f.messages;
        });
      },
      (team) async {
        // If there are invitees queued, fire them off before closing.
        // Failures here are non-fatal — the team exists, we just toast
        // the partial errors.
        if (_selected.isNotEmpty) {
          final inviteRes = await _teamsRepo.sendInvitations(
            teamId: team.id,
            userIds: _selected.map((s) => s.id).toList(growable: false),
          );
          if (!mounted) return;
          inviteRes.fold(
            (f) {
              // Soft error — close anyway, surface via toast in caller.
              Navigator.of(context).pop(team);
            },
            (_) => Navigator.of(context).pop(team),
          );
        } else {
          Navigator.of(context).pop(team);
        }
      },
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
            _GrabHandle(color: colors.borderStrong),
            _SheetHeader(
              title: _step == _CreateStep.name
                  ? 'Create team'
                  : 'Invite members',
              onClose: () => Navigator.of(context).pop(),
              leading: _step == _CreateStep.invite
                  ? IconButton(
                      icon: Icon(LucideIcons.chevronLeft,
                          color: colors.textSecondary),
                      onPressed: () => setState(() => _step = _CreateStep.name),
                    )
                  : null,
            ),
            if (_step == _CreateStep.name)
              Flexible(child: _buildNameStep(colors))
            else
              Flexible(child: _buildInviteStep(colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildNameStep(AppThemeColors colors) {
    final status = _nameStatus;
    Color? hintColor;
    String? hintText;
    if (_validatingName) {
      hintColor = colors.textTertiary;
      hintText = 'Checking…';
    } else if (status != null) {
      hintColor = status.available ? colors.success : colors.error;
      hintText = status.available
          ? 'Name is available'
          : (status.reason.isEmpty
              ? 'Name unavailable'
              : status.reason);
    }
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.base,
      ),
      children: [
        Text(
          'Team name',
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        _TextField(
          controller: _nameCtl,
          hint: 'e.g. Strike Force',
          autofocus: true,
          onChanged: _onNameChanged,
          suffix: _validatingName
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.accent,
                  ),
                )
              : status == null
                  ? null
                  : Icon(
                      status.available
                          ? LucideIcons.circleCheck
                          : LucideIcons.circleAlert,
                      size: 16,
                      color: status.available ? colors.success : colors.error,
                    ),
        ),
        if (hintText != null) ...[
          const SizedBox(height: 6),
          Text(
            hintText,
            style: AppTextStyles.nano.copyWith(color: hintColor),
          ),
        ],
        const SizedBox(height: AppSpacing.base),
        Text(
          'Max members',
          style: AppTextStyles.bodySmall.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        _TextField(
          controller: _maxSizeCtl,
          hint: '5',
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 6),
        Text(
          'Defaults to 5. You can change this later.',
          style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
        ),
        if (_errors.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _ErrorBox(messages: _errors, color: colors.error),
        ],
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Skip invites',
                variant: AppButtonVariant.secondary,
                onPressed: !_nameValid || _creating
                    ? null
                    : _createAndMaybeInvite,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppButton(
                label: 'Invite people',
                icon: LucideIcons.userPlus,
                onPressed: !_nameValid || _creating
                    ? null
                    : () => setState(() => _step = _CreateStep.invite),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInviteStep(AppThemeColors colors) {
    return Column(
      children: [
        if (_selected.isNotEmpty)
          _SelectedChips(users: _selected, onRemove: _toggleSelect),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.sm,
          ),
          child: _TextField(
            controller: _queryCtl,
            hint: 'Search people…',
            autofocus: true,
            onChanged: _onQueryChanged,
            prefix: Icon(LucideIcons.search,
                size: 16, color: colors.textTertiary),
            suffix: _searching
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.accent,
                    ),
                  )
                : null,
          ),
        ),
        Flexible(
          child: _ResultsList(
            results: _results,
            query: _queryCtl.text.trim(),
            searching: _searching,
            selected: _selected.map((u) => u.id).toSet(),
            onPick: _toggleSelect,
          ),
        ),
        if (_errors.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: _ErrorBox(messages: _errors, color: colors.error),
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
                  ? 'Create team'
                  : 'Create + invite ${_selected.length}',
              expand: true,
              size: AppButtonSize.large,
              loading: _creating,
              onPressed: _creating ? null : _createAndMaybeInvite,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared bits
// ─────────────────────────────────────────────────────────────────────────────

class _GrabHandle extends StatelessWidget {
  const _GrabHandle({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.fullAll,
          ),
        ),
      );
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({
    required this.title,
    required this.onClose,
    this.leading,
  });
  final String title;
  final VoidCallback onClose;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Row(
        children: [
          leading ??
              IconButton(
                icon: Icon(LucideIcons.x,
                    size: 20, color: colors.textSecondary),
                onPressed: onClose,
                visualDensity: VisualDensity.compact,
              ),
          Expanded(
            child: Center(
              child: Text(
                title,
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
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    this.onChanged,
    this.autofocus = false,
    this.keyboardType,
    this.prefix,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colors.borderStrong),
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: AppTextStyles.body.copyWith(color: colors.textPrimary),
        cursorColor: colors.accent,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: AppTextStyles.body
              .copyWith(color: colors.textTertiary, fontSize: 13),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          prefixIcon: prefix,
          prefixIconConstraints: const BoxConstraints(minWidth: 36),
          suffixIcon: suffix == null
              ? null
              : Padding(padding: const EdgeInsets.all(12), child: suffix),
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
    required this.selected,
    required this.onPick,
  });

  final List<msg.SearchUser> results;
  final String query;
  final bool searching;
  final Set<int> selected;
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
        final isSelected = selected.contains(u.id);
        return _UserRow(
          user: u,
          selected: isSelected,
          onTap: () => onPick(u),
        );
      },
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.selected,
    required this.onTap,
  });

  final msg.SearchUser user;
  final bool selected;
  final VoidCallback onTap;

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
                      user.rankDisplay == null
                          ? '@${user.username}'
                          : '@${user.username} · ${user.rankDisplay}',
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

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.messages, required this.color});
  final List<String> messages;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(
        messages.join('\n'),
        style: AppTextStyles.bodySmall.copyWith(color: color),
      ),
    );
  }
}
