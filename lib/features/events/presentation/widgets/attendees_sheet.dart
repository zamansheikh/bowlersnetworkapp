import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/network_badge.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';

/// Which attendee list to render — drives both the title + which
/// repository method gets called.
enum AttendeesKind { interested, going }

/// Opens the bottom-sheet for the given [kind] of attendees on
/// [eventUid]. Paginated; tap any row to jump to that user's profile.
Future<void> showAttendeesSheet(
  BuildContext context, {
  required String eventUid,
  required AttendeesKind kind,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => _AttendeesSheet(uid: eventUid, kind: kind),
  );
}

class _AttendeesSheet extends StatefulWidget {
  const _AttendeesSheet({required this.uid, required this.kind});
  final String uid;
  final AttendeesKind kind;

  @override
  State<_AttendeesSheet> createState() => _AttendeesSheetState();
}

class _AttendeesSheetState extends State<_AttendeesSheet> {
  final _repository = getIt<EventsRepository>();
  final _scroll = ScrollController();
  List<EventOrganiser> _users = const [];
  int _page = 1;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load(page: 1, replace: true);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients || !_hasMore || _loadingMore || _loading) return;
    final remaining =
        _scroll.position.maxScrollExtent - _scroll.position.pixels;
    if (remaining < 400) _load(page: _page + 1);
  }

  Future<void> _load({required int page, bool replace = false}) async {
    if (!mounted) return;
    setState(() {
      if (replace) {
        _loading = true;
      } else {
        _loadingMore = true;
      }
    });
    final res = widget.kind == AttendeesKind.interested
        ? await _repository.getInterestedUsers(uid: widget.uid, page: page)
        : await _repository.getGoingUsers(uid: widget.uid, page: page);
    if (!mounted) return;
    res.fold(
      (f) => setState(() {
        _loading = false;
        _loadingMore = false;
        _error = f.messages.isEmpty ? 'Something went wrong.' : f.messages.first;
      }),
      (result) => setState(() {
        _loading = false;
        _loadingMore = false;
        _users = replace ? result.users : [..._users, ...result.users];
        _page = page;
        _hasMore = result.hasMore;
      }),
    );
  }

  String get _title => switch (widget.kind) {
        AttendeesKind.interested => 'Interested',
        AttendeesKind.going => 'Going',
      };

  IconData get _emptyIcon => switch (widget.kind) {
        AttendeesKind.interested => LucideIcons.heart,
        AttendeesKind.going => LucideIcons.users,
      };

  String get _emptyTitle => switch (widget.kind) {
        AttendeesKind.interested => 'No one interested yet',
        AttendeesKind.going => 'No one going yet',
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
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
                  Icon(
                    widget.kind == AttendeesKind.interested
                        ? LucideIcons.heart
                        : LucideIcons.users,
                    size: 16,
                    color: colors.accent,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _title,
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: colors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
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
                  : _users.isEmpty
                      ? Padding(
                          padding:
                              const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                          child: EmptyState(
                            icon: _emptyIcon,
                            title: _emptyTitle,
                            hint: _error,
                          ),
                        )
                      : ListView.separated(
                          controller: _scroll,
                          padding:
                              const EdgeInsets.all(AppSpacing.base),
                          itemCount:
                              _users.length + (_loadingMore ? 1 : 0),
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.xs),
                          itemBuilder: (_, i) {
                            if (i >= _users.length) {
                              return Padding(
                                padding:
                                    const EdgeInsets.all(AppSpacing.sm),
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
                            return _UserRow(user: _users[i]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user});
  final EventOrganiser user;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.smAll,
        onTap: () {
          Navigator.of(context).pop();
          context.push('/u/${user.username}');
        },
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: AppSpacing.sm),
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
              Icon(LucideIcons.chevronRight,
                  size: 14, color: colors.textTertiary),
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
