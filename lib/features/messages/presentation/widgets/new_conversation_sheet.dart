import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/repositories/messages_repository.dart';

/// Opens a chooser for "New message" / "New group". Returns the created
/// conversation (via inner sheet) or `null` if the user cancels.
Future<ConversationListItem?> showNewConversationChooser(
  BuildContext context,
) async {
  return showModalBottomSheet<ConversationListItem>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) {
      final colors = sheetCtx.colors;
      return SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: colors.bgSurfaceElevated,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(LucideIcons.user, color: colors.accent, size: 20),
                title: Text('New message',
                    style: AppTextStyles.body.copyWith(
                      color: colors.textPrimary,
                    )),
                subtitle: Text('Direct message to one person',
                    style: AppTextStyles.secondary.copyWith(
                      color: colors.textTertiary,
                    )),
                onTap: () async {
                  Navigator.of(sheetCtx).pop();
                  final created = await showNewDmSheet(context);
                  if (created != null && context.mounted) {
                    Navigator.of(context).pop(created);
                  }
                },
              ),
              ListTile(
                leading:
                    Icon(LucideIcons.users, color: colors.accent, size: 20),
                title: Text('New group',
                    style: AppTextStyles.body.copyWith(
                      color: colors.textPrimary,
                    )),
                subtitle: Text('Start a group chat with friends',
                    style: AppTextStyles.secondary.copyWith(
                      color: colors.textTertiary,
                    )),
                onTap: () async {
                  Navigator.of(sheetCtx).pop();
                  final created = await showNewGroupSheet(context);
                  if (created != null && context.mounted) {
                    Navigator.of(context).pop(created);
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// NEW DM
// ═══════════════════════════════════════════════════════════════════════════
Future<ConversationListItem?> showNewDmSheet(BuildContext context) {
  return showModalBottomSheet<ConversationListItem>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => const _NewDmSheet(),
  );
}

class _NewDmSheet extends StatefulWidget {
  const _NewDmSheet();

  @override
  State<_NewDmSheet> createState() => _NewDmSheetState();
}

class _NewDmSheetState extends State<_NewDmSheet> {
  final _repo = getIt<MessagesRepository>();
  final _queryCtl = TextEditingController();
  Timer? _debounce;
  List<SearchUser> _results = const [];
  bool _searching = false;
  bool _creating = false;
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
      setState(() => _searching = true);
      final res = await _repo.searchUsers(trimmed);
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

  Future<void> _startDm(SearchUser user) async {
    setState(() {
      _creating = true;
      _errors = const [];
    });
    final res = await _repo.createPrivateConversation(user.id);
    if (!mounted) return;
    res.fold(
      (f) => setState(() {
        _creating = false;
        _errors = f.messages;
      }),
      (conv) => Navigator.of(context).pop(conv),
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
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
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
              title: 'New message',
              onClose: () => Navigator.of(context).pop(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: _SearchField(
                controller: _queryCtl,
                searching: _searching,
                onChanged: _onQueryChanged,
              ),
            ),
            Flexible(
              child: _ResultsList(
                results: _results,
                query: _queryCtl.text.trim(),
                searching: _searching,
                disabled: _creating,
                onPick: _startDm,
              ),
            ),
            if (_errors.isNotEmpty)
              _ErrorBox(messages: _errors, color: colors.error),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NEW GROUP
// ═══════════════════════════════════════════════════════════════════════════
Future<ConversationListItem?> showNewGroupSheet(BuildContext context) {
  return showModalBottomSheet<ConversationListItem>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => const _NewGroupSheet(),
  );
}

enum _GroupStep { members, details }

class _NewGroupSheet extends StatefulWidget {
  const _NewGroupSheet();

  @override
  State<_NewGroupSheet> createState() => _NewGroupSheetState();
}

class _NewGroupSheetState extends State<_NewGroupSheet> {
  final _repo = getIt<MessagesRepository>();
  final _queryCtl = TextEditingController();
  final _nameCtl = TextEditingController();
  Timer? _debounce;
  List<SearchUser> _results = const [];
  final List<SearchUser> _selected = [];
  bool _searching = false;
  bool _creating = false;
  _GroupStep _step = _GroupStep.members;
  List<String> _errors = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _queryCtl.dispose();
    _nameCtl.dispose();
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
      setState(() => _searching = true);
      final res = await _repo.searchUsers(trimmed);
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

  void _toggleSelect(SearchUser u) {
    setState(() {
      final idx = _selected.indexWhere((s) => s.id == u.id);
      if (idx >= 0) {
        _selected.removeAt(idx);
      } else {
        _selected.add(u);
      }
    });
  }

  Future<void> _create() async {
    final name = _nameCtl.text.trim();
    if (name.isEmpty) {
      setState(() => _errors = const ['Enter a group name.']);
      return;
    }
    setState(() {
      _creating = true;
      _errors = const [];
    });
    final res = await _repo.createGroupConversation(
      userIds: _selected.map((s) => s.id).toList(growable: false),
      name: name,
    );
    if (!mounted) return;
    res.fold(
      (f) => setState(() {
        _creating = false;
        _errors = f.messages;
      }),
      (conv) => Navigator.of(context).pop(conv),
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
              title:
                  _step == _GroupStep.members ? 'Add members' : 'Group details',
              onClose: () => Navigator.of(context).pop(),
              leading: _step == _GroupStep.details
                  ? IconButton(
                      icon: Icon(LucideIcons.chevronLeft,
                          color: colors.textSecondary),
                      onPressed: () =>
                          setState(() => _step = _GroupStep.members),
                    )
                  : null,
            ),
            if (_step == _GroupStep.members) ...[
              if (_selected.isNotEmpty)
                _SelectedChips(
                  users: _selected,
                  onRemove: _toggleSelect,
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.sm,
                ),
                child: _SearchField(
                  controller: _queryCtl,
                  searching: _searching,
                  onChanged: _onQueryChanged,
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
                        : 'Next (${_selected.length})',
                    expand: true,
                    size: AppButtonSize.large,
                    onPressed: _selected.isEmpty
                        ? null
                        : () => setState(() => _step = _GroupStep.details),
                  ),
                ),
              ),
            ] else
              Expanded(
                child: _GroupDetailsStep(
                  nameCtl: _nameCtl,
                  memberCount: _selected.length,
                  creating: _creating,
                  errors: _errors,
                  onCreate: _create,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Shared bits
// ═══════════════════════════════════════════════════════════════════════════
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
  const _SheetHeader({required this.title, required this.onClose, this.leading});
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

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.searching,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool searching;
  final ValueChanged<String> onChanged;

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
        autofocus: true,
        onChanged: onChanged,
        style: AppTextStyles.body.copyWith(color: colors.textPrimary),
        cursorColor: colors.accent,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: 'Search people…',
          hintStyle: AppTextStyles.body
              .copyWith(color: colors.textTertiary, fontSize: 13),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          prefixIcon: Icon(LucideIcons.search,
              size: 16, color: colors.textTertiary),
          prefixIconConstraints: const BoxConstraints(minWidth: 36),
          suffixIcon: searching
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
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({
    required this.results,
    required this.query,
    required this.searching,
    required this.onPick,
    this.disabled = false,
    this.selected,
  });

  final List<SearchUser> results;
  final String query;
  final bool searching;
  final bool disabled;
  final Set<int>? selected;
  final ValueChanged<SearchUser> onPick;

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
        final isSelected = selected?.contains(u.id) ?? false;
        return _UserRow(
          user: u,
          selected: isSelected,
          multiSelect: selected != null,
          onTap: disabled ? null : () => onPick(u),
        );
      },
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({
    required this.user,
    required this.selected,
    required this.multiSelect,
    required this.onTap,
  });

  final SearchUser user;
  final bool selected;
  final bool multiSelect;
  final VoidCallback? onTap;

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
              if (multiSelect)
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
                )
              else
                Icon(LucideIcons.send,
                    size: 16, color: colors.textTertiary),
            ],
          ),
        ),
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
    final initial =
        fallback.isEmpty ? '?' : fallback.characters.first.toUpperCase();
    final placeholder = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
      ),
      alignment: Alignment.center,
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

class _SelectedChips extends StatelessWidget {
  const _SelectedChips({required this.users, required this.onRemove});
  final List<SearchUser> users;
  final ValueChanged<SearchUser> onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final u in users)
            InputChip(
              label: Text(
                u.displayName,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              backgroundColor: colors.accentSubtle,
              side: BorderSide(color: colors.accent.withValues(alpha: 0.3)),
              deleteIcon:
                  Icon(LucideIcons.x, size: 14, color: colors.textSecondary),
              onDeleted: () => onRemove(u),
            ),
        ],
      ),
    );
  }
}

class _GroupDetailsStep extends StatelessWidget {
  const _GroupDetailsStep({
    required this.nameCtl,
    required this.memberCount,
    required this.creating,
    required this.errors,
    required this.onCreate,
  });

  final TextEditingController nameCtl;
  final int memberCount;
  final bool creating;
  final List<String> errors;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.md),
          Text(
            'GROUP NAME',
            style: AppTextStyles.label.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: colors.bgSurface,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: colors.borderStrong),
            ),
            child: TextField(
              controller: nameCtl,
              autofocus: true,
              maxLength: 80,
              textCapitalization: TextCapitalization.words,
              style: AppTextStyles.body.copyWith(color: colors.textPrimary),
              cursorColor: colors.accent,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'My bowling crew',
                hintStyle: AppTextStyles.body.copyWith(
                  color: colors.textTertiary,
                  fontSize: 13,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                counterStyle: AppTextStyles.nano.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '$memberCount member${memberCount == 1 ? '' : 's'} selected',
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _ErrorBox(messages: errors, color: colors.error),
          ],
          const Spacer(),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.base),
              child: AppButton(
                label: creating ? 'Creating…' : 'Create group',
                loading: creating,
                expand: true,
                size: AppButtonSize.large,
                onPressed: creating ? null : onCreate,
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final m in messages)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.circleAlert, size: 13, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      m,
                      style: AppTextStyles.bodySmall.copyWith(color: color),
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
