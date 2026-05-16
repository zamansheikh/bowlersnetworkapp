import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/network_badge.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';

/// Creator-only sheet for inviting users to [eventUid]. Loads
/// suggestions from `/invite/discover` (server caps at 50, excludes
/// already-invited + creator). The user can multi-select then send;
/// the sheet returns the count actually invited.
Future<int?> showSendInvitationsSheet(
  BuildContext context, {
  required String eventUid,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => _SendInvitationsSheet(uid: eventUid),
  );
}

class _SendInvitationsSheet extends StatefulWidget {
  const _SendInvitationsSheet({required this.uid});
  final String uid;
  @override
  State<_SendInvitationsSheet> createState() => _SendInvitationsSheetState();
}

class _SendInvitationsSheetState extends State<_SendInvitationsSheet> {
  final _repository = getIt<EventsRepository>();
  List<EventOrganiser> _candidates = const [];
  final Set<int> _selected = {};
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await _repository.discoverInviteCandidates(widget.uid);
    if (!mounted) return;
    res.fold(
      (f) => setState(() {
        _loading = false;
        _error =
            f.messages.isEmpty ? 'Something went wrong.' : f.messages.first;
      }),
      (list) => setState(() {
        _loading = false;
        _candidates = list;
      }),
    );
  }

  Future<void> _send() async {
    if (_selected.isEmpty || _sending) return;
    setState(() => _sending = true);
    final res = await _repository.sendInvitations(
      uid: widget.uid,
      userIds: _selected.toList(growable: false),
    );
    if (!mounted) return;
    res.fold(
      (f) {
        setState(() => _sending = false);
        showAppToast(
          context,
          message: f.messages.join('\n'),
          variant: ToastVariant.error,
        );
      },
      (count) {
        Navigator.of(context).pop(count);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      top: false,
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
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.borderStrong,
                borderRadius: AppRadius.fullAll,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Row(
                children: [
                  Icon(LucideIcons.userPlus, size: 16, color: colors.accent),
                  const SizedBox(width: 6),
                  Text(
                    'Invite people',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: colors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  if (_selected.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.14),
                          borderRadius: AppRadius.smAll,
                        ),
                        child: Text(
                          '${_selected.length}',
                          style: AppTextStyles.nano.copyWith(
                            color: colors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  IconButton(
                    icon: Icon(LucideIcons.x,
                        size: 18, color: colors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.borderDefault),
            Flexible(
              child: _loading
                  ? const _Skeleton()
                  : _candidates.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xl,
                          ),
                          child: EmptyState(
                            icon: LucideIcons.users,
                            title: 'No one to invite',
                            hint: _error ??
                                "Everyone you'd see here has already been invited.",
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          itemCount: _candidates.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.xs),
                          itemBuilder: (_, i) {
                            final u = _candidates[i];
                            final picked = _selected.contains(u.id);
                            return _CandidateRow(
                              user: u,
                              selected: picked,
                              onTap: () => setState(() {
                                if (picked) {
                                  _selected.remove(u.id);
                                } else {
                                  _selected.add(u.id);
                                }
                              }),
                            );
                          },
                        ),
            ),
            Divider(height: 1, color: colors.borderDefault),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: AppButton(
                label: _selected.isEmpty
                    ? 'Pick people to invite'
                    : 'Invite ${_selected.length} ${_selected.length == 1 ? "person" : "people"}',
                icon: LucideIcons.send,
                size: AppButtonSize.large,
                expand: true,
                loading: _sending,
                onPressed: _selected.isEmpty || _sending ? null : _send,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CandidateRow extends StatelessWidget {
  const _CandidateRow({
    required this.user,
    required this.selected,
    required this.onTap,
  });

  final EventOrganiser user;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: selected ? colors.accent.withValues(alpha: 0.08) : Colors.transparent,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              _Avatar(user: user),
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (user.badgeIconUrl != null) ...[
                          const SizedBox(width: 4),
                          NetworkBadge(url: user.badgeIconUrl, size: 12),
                        ],
                      ],
                    ),
                    Text(
                      '@${user.username}',
                      style: AppTextStyles.nano.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? LucideIcons.circleCheck
                    : LucideIcons.circle,
                size: 20,
                color: selected ? colors.accent : colors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});
  final EventOrganiser user;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = user.firstName.isNotEmpty
        ? user.firstName.substring(0, 1).toUpperCase()
        : user.username.isNotEmpty
            ? user.username.substring(0, 1).toUpperCase()
            : '?';
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
    final url = user.profilePictureUrl;
    if (url == null || url.isEmpty) return placeholder;
    return ClipOval(
      child: SizedBox(
        width: 36,
        height: 36,
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

class _Skeleton extends StatelessWidget {
  const _Skeleton();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
      itemBuilder: (_, _) => const SkeletonBox(height: 56),
    );
  }
}
