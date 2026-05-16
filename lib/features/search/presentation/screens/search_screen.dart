import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/search_result.dart';
import '../bloc/search_bloc.dart';

/// Universal search screen — mirrors the web's `<SearchOverlay>`. Single
/// text field at the top, then grouped result sections (Users, Posts,
/// Discussions, Centers, Brands, Events, Videos, Splits, Cards) in the
/// same order the web shows them.
///
/// Debounce lives in the widget (250ms) so typing fires one network call
/// per pause, not per keystroke. Out-of-order responses are dropped by
/// the bloc's request-token guard.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SearchBloc>(
      create: (_) => getIt<SearchBloc>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Auto-focus the field so the keyboard pops on entry (web matches).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    setState(() {/* refresh trailing icon */});
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      context.read<SearchBloc>().add(SearchQueryChanged(value));
    });
  }

  void _onClear() {
    _debounce?.cancel();
    _controller.clear();
    context.read<SearchBloc>().add(const SearchCleared());
    setState(() {});
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        title: const Text('Search'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              0,
              AppSpacing.base,
              AppSpacing.sm,
            ),
            child: _SearchField(
              controller: _controller,
              focusNode: _focusNode,
              hasText: _controller.text.isNotEmpty,
              onChanged: _onChanged,
              onClear: _onClear,
            ),
          ),
        ),
      ),
      body: BlocConsumer<SearchBloc, SearchState>(
        listenWhen: (p, n) => p.errors != n.errors && n.errors.isNotEmpty,
        listener: (context, state) {
          showAppToast(
            context,
            message: state.errors.join('\n'),
            variant: ToastVariant.error,
          );
        },
        builder: (context, state) => _SearchBody(state: state),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.hasText,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.fullAll,
        border: Border.all(color: colors.borderDefault),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Icon(LucideIcons.search, size: 18, color: colors.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.body.copyWith(
                color: colors.textPrimary,
                fontSize: 14,
              ),
              cursorColor: colors.accent,
              decoration: InputDecoration(
                hintText: 'Search people, posts, discussions…',
                hintStyle: AppTextStyles.body.copyWith(
                  color: colors.textTertiary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (hasText)
            InkWell(
              onTap: onClear,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  LucideIcons.x,
                  size: 16,
                  color: colors.textTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchBody extends StatelessWidget {
  const _SearchBody({required this.state});
  final SearchState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Three states:
    //   ① no query yet → invitation splash
    //   ② query + loading + no prior results → top progress bar
    //   ③ query + finished + empty → "No results" empty state
    //   ④ results available → grouped list (loading indicator still shows
    //      at the top while a refresh is in flight)
    if (!state.hasQuery) {
      return const _StartTypingState();
    }
    if (state.isEmpty) {
      return _NoResultsState(query: state.query);
    }
    return Column(
      children: [
        if (state.loading)
          LinearProgressIndicator(
            minHeight: 2,
            backgroundColor: colors.bgSurface,
            valueColor: AlwaysStoppedAnimation(colors.accent),
          ),
        Expanded(child: _ResultsList(results: state.results)),
      ],
    );
  }
}

class _StartTypingState extends StatelessWidget {
  const _StartTypingState();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.search, size: 40, color: colors.textTertiary),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Find anyone or anything',
              style: AppTextStyles.sectionTitle.copyWith(
                color: colors.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Search across people, posts, discussions,\nevents, brands, centers and more.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResultsState extends StatelessWidget {
  const _NoResultsState({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.searchX, size: 40, color: colors.textTertiary),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No results for "$query"',
              style: AppTextStyles.sectionTitle.copyWith(
                color: colors.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try different keywords.',
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.results});
  final SearchResults results;

  void _notImplemented(BuildContext context, String label) {
    showAppToast(
      context,
      message: '$label preview is not available on mobile yet.',
      variant: ToastVariant.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = results;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.xl,
      ),
      children: [
        if (r.users.isNotEmpty)
          _Section(
            title: 'People',
            icon: LucideIcons.users,
            children: [
              for (final u in r.users)
                _UserRow(
                  user: u,
                  onTap: () => _notImplemented(context, 'Profile'),
                ),
            ],
          ),
        if (r.posts.isNotEmpty)
          _Section(
            title: 'Posts',
            icon: LucideIcons.fileText,
            children: [
              for (final p in r.posts)
                _PostRow(
                  post: p,
                  onTap: () => _notImplemented(context, 'Post'),
                ),
            ],
          ),
        if (r.discussions.isNotEmpty)
          _Section(
            title: 'Discussions',
            icon: LucideIcons.messageSquare,
            children: [
              for (final d in r.discussions)
                _DiscussionRow(
                  discussion: d,
                  onTap: () => _notImplemented(context, 'Discussion'),
                ),
            ],
          ),
        if (r.events.isNotEmpty)
          _Section(
            title: 'Events',
            icon: LucideIcons.calendar,
            children: [
              for (final e in r.events)
                _EventRow(
                  event: e,
                  onTap: () => _notImplemented(context, 'Event'),
                ),
            ],
          ),
        if (r.videos.isNotEmpty)
          _Section(
            title: 'Videos',
            icon: LucideIcons.video,
            children: [
              for (final v in r.videos)
                _MediaRow(
                  uid: v.uid,
                  title: v.title,
                  subtitle: v.authorName ?? '',
                  thumbnailUrl: v.thumbnailUrl,
                  trailing: v.durationSeconds == null
                      ? null
                      : _formatDuration(v.durationSeconds!),
                  onTap: () => _notImplemented(context, 'Video'),
                ),
            ],
          ),
        if (r.splits.isNotEmpty)
          _Section(
            title: 'Splits',
            icon: LucideIcons.target,
            children: [
              for (final s in r.splits)
                _MediaRow(
                  uid: s.uid,
                  title: s.caption.isEmpty ? 'Split' : s.caption,
                  subtitle: s.authorName ?? '',
                  thumbnailUrl: s.thumbnailUrl,
                  onTap: () => _notImplemented(context, 'Split'),
                ),
            ],
          ),
        if (r.cards.isNotEmpty)
          _Section(
            title: 'Trading Cards',
            icon: LucideIcons.creditCard,
            children: [
              for (final c in r.cards)
                _CardRow(
                  card: c,
                  onTap: () => _notImplemented(context, 'Trading card'),
                ),
            ],
          ),
        if (r.centers.isNotEmpty)
          _Section(
            title: 'Centers',
            icon: LucideIcons.mapPin,
            children: [
              for (final c in r.centers) _CenterRow(center: c),
            ],
          ),
        if (r.brands.isNotEmpty)
          _Section(
            title: 'Brands',
            icon: LucideIcons.tag,
            children: [
              for (final b in r.brands) _BrandRow(brand: b),
            ],
          ),
      ],
    );
  }
}

String _formatDuration(int seconds) {
  final m = seconds ~/ 60;
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

// ── Section wrapper ─────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 4,
              bottom: 6,
            ),
            child: Row(
              children: [
                Icon(icon, size: 13, color: colors.textTertiary),
                const SizedBox(width: 6),
                Text(
                  title.toUpperCase(),
                  style: AppTextStyles.label.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      color: colors.borderDefault,
                    ),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Row primitive ───────────────────────────────────────────────────────────

class _Row extends StatelessWidget {
  const _Row({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DefaultTextStyle.merge(
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      child: title,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      DefaultTextStyle.merge(
                        style: AppTextStyles.nano,
                        child: subtitle!,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.sm),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tiny avatar / thumb ─────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({this.url, this.fallback});
  final String? url;
  final IconData? fallback;

  static const double _size = 36;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final placeholder = Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.bgSurfaceHover,
      ),
      child: Icon(
        fallback ?? LucideIcons.user,
        size: _size * 0.5,
        color: colors.textTertiary,
      ),
    );
    if (url == null || url!.isEmpty) return placeholder;
    return ClipOval(
      child: SizedBox(
        width: _size,
        height: _size,
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

class _Thumb extends StatelessWidget {
  const _Thumb({this.url, this.fallback = LucideIcons.image});
  final String? url;
  final IconData fallback;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const w = 56.0;
    const h = 40.0;
    final placeholder = Container(
      width: w,
      height: h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.bgSurfaceHover,
        borderRadius: AppRadius.smAll,
      ),
      child: Icon(fallback, size: 16, color: colors.textTertiary),
    );
    if (url == null || url!.isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: AppRadius.smAll,
      child: SizedBox(
        width: w,
        height: h,
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

// ── Per-type rows ───────────────────────────────────────────────────────────

class _UserRow extends StatelessWidget {
  const _UserRow({required this.user, required this.onTap});
  final UserSearchResult user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _Row(
      leading: _Avatar(url: user.profilePictureUrl),
      title: Row(
        children: [
          Flexible(
            child: Text(
              user.fullName.isEmpty ? user.username : user.fullName,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (user.isPro) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: colors.accentSubtle,
                borderRadius: AppRadius.smAll,
              ),
              child: Text(
                'PRO',
                style: AppTextStyles.nano.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        '@${user.username}',
        style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
      ),
      trailing: Icon(LucideIcons.chevronRight,
          size: 14, color: colors.textTertiary),
      onTap: onTap,
    );
  }
}

class _PostRow extends StatelessWidget {
  const _PostRow({required this.post, required this.onTap});
  final PostSearchResult post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _Row(
      leading: _Avatar(
        url: post.authorProfilePictureUrl,
        fallback: LucideIcons.fileText,
      ),
      title: Text(
        post.caption.isEmpty ? 'Untitled post' : post.caption,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyMedium.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Row(
        children: [
          Text(
            post.authorName,
            style: AppTextStyles.nano.copyWith(color: colors.textSecondary),
          ),
          if (post.likesCount > 0) ...[
            Text(
              '  •  ',
              style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
            ),
            Icon(LucideIcons.heart, size: 11, color: colors.textTertiary),
            const SizedBox(width: 3),
            Text(
              '${post.likesCount}',
              style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
            ),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}

class _DiscussionRow extends StatelessWidget {
  const _DiscussionRow({required this.discussion, required this.onTap});
  final DiscussionSearchResult discussion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _Row(
      leading: _Avatar(
        fallback: LucideIcons.messageSquare,
      ),
      title: Text(
        discussion.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyMedium.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Row(
        children: [
          if (discussion.topicName.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: colors.bgSurfaceHover,
                borderRadius: AppRadius.smAll,
              ),
              child: Text(
                discussion.topicName,
                style: AppTextStyles.nano.copyWith(color: colors.textSecondary),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Icon(LucideIcons.arrowUp, size: 11, color: colors.textTertiary),
          const SizedBox(width: 3),
          Text('${discussion.upvoteCount}',
              style: AppTextStyles.nano.copyWith(color: colors.textTertiary)),
          const SizedBox(width: 8),
          Icon(LucideIcons.messageCircle,
              size: 11, color: colors.textTertiary),
          const SizedBox(width: 3),
          Text('${discussion.opinionCount}',
              style: AppTextStyles.nano.copyWith(color: colors.textTertiary)),
          if (discussion.isResolved) ...[
            const SizedBox(width: 8),
            Icon(LucideIcons.circleCheck, size: 11, color: colors.success),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.onTap});
  final EventSearchResult event;
  final VoidCallback onTap;

  static const _months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final d = event.eventDate;
    final dateBadge = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colors.bgSurfaceHover,
        borderRadius: AppRadius.smAll,
      ),
      alignment: Alignment.center,
      child: d == null
          ? Icon(LucideIcons.calendar, size: 18, color: colors.textTertiary)
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
    );
    return _Row(
      leading: dateBadge,
      title: Text(
        event.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyMedium.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        [
          event.eventTypeName,
          if (event.isOnline) 'Online' else event.address,
        ].where((s) => s.isNotEmpty).join('  •  '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
      ),
      onTap: onTap,
    );
  }
}

class _MediaRow extends StatelessWidget {
  const _MediaRow({
    required this.uid,
    required this.title,
    required this.subtitle,
    required this.thumbnailUrl,
    this.trailing,
    required this.onTap,
  });

  final String uid;
  final String title;
  final String subtitle;
  final String? thumbnailUrl;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _Row(
      leading: _Thumb(url: thumbnailUrl, fallback: LucideIcons.video),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyMedium.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
      ),
      trailing: trailing == null
          ? null
          : Text(
              trailing!,
              style: AppTextStyles.nano.copyWith(
                color: colors.textTertiary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
      onTap: onTap,
    );
  }
}

class _CardRow extends StatelessWidget {
  const _CardRow({required this.card, required this.onTap});
  final CardSearchResult card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _Row(
      leading: _Thumb(
        url: card.displayImageUrl,
        fallback: LucideIcons.creditCard,
      ),
      title: Text(
        card.displayName ?? 'Trading card',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyMedium.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        [
          if (card.cardType != null && card.cardType!.isNotEmpty) card.cardType!,
          if (card.ownerFullName != null && card.ownerFullName!.isNotEmpty)
            card.ownerFullName!,
        ].join('  •  '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
      ),
      onTap: onTap,
    );
  }
}

class _CenterRow extends StatelessWidget {
  const _CenterRow({required this.center});
  final CenterSearchResult center;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _Row(
      leading: _Avatar(url: center.logo, fallback: LucideIcons.mapPin),
      title: Text(
        center.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyMedium.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        center.address,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({required this.brand});
  final BrandSearchResult brand;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _Row(
      leading: _Avatar(url: brand.logoUrl, fallback: LucideIcons.tag),
      title: Text(
        brand.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.bodyMedium.copyWith(
          color: colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        [
          if (brand.brandType.isNotEmpty) brand.brandType,
          if (brand.formalName.isNotEmpty) brand.formalName,
        ].join('  •  '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
      ),
    );
  }
}

