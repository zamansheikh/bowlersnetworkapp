import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'post_media.dart';

// =============================================================================
// SHARED POST — repost of another post
// =============================================================================
/// Renders a nested post preview for `post_type == 'shared'`. `typeData` has
/// `{original: { author, post_type, caption, type_data, ... }}` — matches the
/// backend's `SharedPost.to_dict()`.
class SharedPostBlock extends StatelessWidget {
  const SharedPostBlock({super.key, required this.typeData});

  final Map<String, dynamic> typeData;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final original = typeData['original'] as Map<String, dynamic>?;
    if (original == null) return const SizedBox.shrink();

    final author = original['author'] as Map<String, dynamic>?;
    final caption = original['caption'] as String? ?? '';
    final origType = original['post_type'] as String? ?? 'text';
    final origData = original['type_data'] as Map<String, dynamic>?;
    final createdAt = original['created_at'] as String?;

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: colors.borderDefault),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (author != null) _NestedAuthorRow(author: author, createdAt: createdAt),
          if (caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                0,
                AppSpacing.base,
                AppSpacing.sm,
              ),
              child: Text(
                caption,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          _NestedMedia(type: origType, data: origData),
        ],
      ),
    );
  }
}

class _NestedAuthorRow extends StatelessWidget {
  const _NestedAuthorRow({required this.author, this.createdAt});

  final Map<String, dynamic> author;
  final String? createdAt;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final firstName = author['first_name'] as String? ?? '';
    final lastName = author['last_name'] as String? ?? '';
    final username = author['username'] as String? ?? '';
    final avatar = author['profile_picture_url'] as String?;
    final isPro = author['is_pro'] as bool? ?? false;
    final display = '$firstName $lastName'.trim().isEmpty
        ? username
        : '$firstName $lastName'.trim();

    final parsedTime = createdAt == null ? null : DateTime.tryParse(createdAt!);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          _MiniAvatar(url: avatar, fallback: display, size: 28),
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
                        display,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isPro) ...[
                      const SizedBox(width: 6),
                      _MiniProBadge(),
                    ],
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '@$username',
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.micro
                            .copyWith(color: colors.textTertiary),
                      ),
                    ),
                    if (parsedTime != null) ...[
                      Text(
                        '  ·  ',
                        style: AppTextStyles.micro
                            .copyWith(color: colors.textTertiary),
                      ),
                      Text(
                        timeago.format(parsedTime, locale: 'en_short'),
                        style: AppTextStyles.micro
                            .copyWith(color: colors.textTertiary),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NestedMedia extends StatelessWidget {
  const _NestedMedia({required this.type, this.data});

  final String type;
  final Map<String, dynamic>? data;

  @override
  Widget build(BuildContext context) {
    if (data == null) return const SizedBox.shrink();

    switch (type) {
      case 'photo':
        final urls =
            ((data!['media_urls'] as List?) ?? const []).cast<String>();
        if (urls.isEmpty) return const SizedBox.shrink();
        return PostPhotoGallery(urls: urls);
      case 'video':
        return PostVideoPreview(
          thumbnailUrl: data!['thumbnail_url'] as String?,
        );
      case 'score':
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: PostScoreCard(data: data!),
        );
      case 'poll':
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: PostPollCard(data: data!),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// =============================================================================
// GAME SHARE — shared game session result
// =============================================================================
class GameShareBlock extends StatelessWidget {
  const GameShareBlock({super.key, required this.typeData});

  final Map<String, dynamic> typeData;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final game = (typeData['game'] as Map<String, dynamic>?) ?? const {};
    final session = (typeData['session'] as Map<String, dynamic>?) ?? const {};
    final center = (session['center'] as Map<String, dynamic>?) ?? const {};

    final score = (game['total_score'] as num?)?.toInt() ?? 0;
    final strikes = (game['strike_count'] as num?)?.toInt() ?? 0;
    final spares = (game['spare_count'] as num?)?.toInt() ?? 0;
    final opens = (game['open_count'] as num?)?.toInt() ?? 0;
    final isPerfect = game['is_perfect'] as bool? ?? false;
    final isClean = game['is_clean'] as bool? ?? false;
    final gameContext = session['game_context'] as String? ?? '';
    final gameNumber = game['game_number'];
    final seriesTotal = (session['series_total'] as num?)?.toInt();
    final centerName = center['name'] as String?;
    final sessionName = session['name'] as String?;

    return ClipRRect(
      borderRadius: AppRadius.xlAll,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: colors.borderDefault),
          borderRadius: AppRadius.xlAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.accent.withValues(alpha: 0.14),
                    colors.accent.withValues(alpha: 0.02),
                  ],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (isPerfect)
                              _PillBadge(
                                text: 'Perfect Game',
                                bg: const Color(0xFFEAB308).withValues(alpha: 0.15),
                                fg: const Color(0xFFEAB308),
                              ),
                            if (isClean && !isPerfect)
                              _PillBadge(
                                text: 'Clean Game',
                                bg: colors.accent.withValues(alpha: 0.15),
                                fg: colors.accent,
                              ),
                            if (gameContext.isNotEmpty)
                              _PillBadge(
                                text: gameContext,
                                bg: colors.bgSurfaceHover,
                                fg: colors.textSecondary,
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '$score',
                          style: AppTextStyles.numberLarge.copyWith(
                            color: colors.textPrimary,
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        if (gameNumber != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Game $gameNumber',
                              style: AppTextStyles.micro
                                  .copyWith(color: colors.textTertiary),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _StatLine(
                        value: '$strikes',
                        label: 'strikes',
                        color: colors.accent,
                        fontSize: 18,
                      ),
                      _StatLine(
                        value: '$spares',
                        label: 'spares',
                        color: colors.textSecondary,
                        fontSize: 14,
                      ),
                      if (opens > 0)
                        _StatLine(
                          value: '$opens',
                          label: 'opens',
                          color: colors.textTertiary,
                          fontSize: 12,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.sm,
              ),
              color: colors.bgSurface,
              child: Row(
                children: [
                  if (centerName != null) ...[
                    Icon(LucideIcons.mapPin,
                        size: 11, color: colors.textTertiary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        centerName,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.secondary
                            .copyWith(color: colors.textSecondary),
                      ),
                    ),
                  ],
                  if (sessionName != null) ...[
                    Text(
                      '  ·  ',
                      style: AppTextStyles.secondary
                          .copyWith(color: colors.textTertiary),
                    ),
                    Flexible(
                      child: Text(
                        sessionName,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.secondary
                            .copyWith(color: colors.textSecondary),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (seriesTotal != null && seriesTotal > 0)
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Series: ',
                            style: AppTextStyles.micro
                                .copyWith(color: colors.textTertiary),
                          ),
                          TextSpan(
                            text: '$seriesTotal',
                            style: AppTextStyles.number.copyWith(
                              color: colors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// MEDIA SHARE — video or playlist preview
// =============================================================================
class MediaShareBlock extends StatelessWidget {
  const MediaShareBlock({super.key, required this.typeData});

  final Map<String, dynamic> typeData;

  @override
  Widget build(BuildContext context) {
    final contentType = typeData['content_type'] as String? ?? '';
    if (typeData['is_deleted'] == true) {
      return const _UnavailableBanner(
        icon: LucideIcons.imageOff,
        label: 'Media Unavailable',
        hint: 'This content may have been deleted.',
      );
    }
    if (contentType == 'video') return _VideoShare(data: typeData);
    if (contentType == 'playlist') return _PlaylistShare(data: typeData);
    return const SizedBox.shrink();
  }
}

class _VideoShare extends StatelessWidget {
  const _VideoShare({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final title = data['title'] as String? ?? 'Untitled';
    final thumb = data['thumbnail_url'] as String?;
    final duration = (data['duration_seconds'] as num?)?.toInt() ?? 0;
    final views = (data['views_count'] as num?)?.toInt() ?? 0;
    final channel = data['channel'] as Map<String, dynamic>?;
    final minutes = duration ~/ 60;
    final seconds = duration % 60;

    return ClipRRect(
      borderRadius: AppRadius.xlAll,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: colors.borderDefault),
          borderRadius: AppRadius.xlAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (thumb != null)
                    CachedNetworkImage(
                      imageUrl: thumb,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: Colors.black),
                      errorWidget: (_, _, _) =>
                          Container(color: Colors.black),
                    )
                  else
                    Container(color: Colors.black),
                  Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(left: 3),
                        child: Icon(LucideIcons.play,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                  if (duration > 0)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: AppRadius.xsAll,
                        ),
                        child: Text(
                          '$minutes:${seconds.toString().padLeft(2, '0')}',
                          style: AppTextStyles.number.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: AppRadius.xsAll,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.play,
                              size: 9, color: colors.accent),
                          const SizedBox(width: 4),
                          const Text(
                            'Video',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: colors.bgSurface,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (channel != null)
                        Flexible(
                          child: Text(
                            channel['first_name'] as String? ??
                                channel['username'] as String? ??
                                '',
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.micro.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                        ),
                      if (views > 0) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Icon(LucideIcons.eye,
                            size: 10, color: colors.textTertiary),
                        const SizedBox(width: 3),
                        Text(
                          _compactNumber(views),
                          style: AppTextStyles.micro
                              .copyWith(color: colors.textTertiary),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistShare extends StatelessWidget {
  const _PlaylistShare({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final title = data['title'] as String? ?? 'Untitled Playlist';
    final videoCount = (data['video_count'] as num?)?.toInt() ?? 0;
    final thumbnails =
        ((data['thumbnails'] as List?) ?? const []).cast<String>();
    final channel = data['channel'] as Map<String, dynamic>?;

    return ClipRRect(
      borderRadius: AppRadius.xlAll,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: colors.borderDefault),
          borderRadius: AppRadius.xlAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: thumbnails.isNotEmpty
                  ? GridView.count(
                      crossAxisCount: 2,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (final t in thumbnails.take(4))
                          CachedNetworkImage(imageUrl: t, fit: BoxFit.cover),
                      ],
                    )
                  : Container(color: colors.bgSurfaceHover),
            ),
            Container(
              color: colors.bgSurface,
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.bookmark,
                          size: 12, color: colors.accent),
                      const SizedBox(width: 4),
                      Text(
                        'Playlist · $videoCount videos',
                        style: AppTextStyles.micro.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (channel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        channel['first_name'] as String? ??
                            channel['username'] as String? ??
                            '',
                        style: AppTextStyles.micro
                            .copyWith(color: colors.textTertiary),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// CARD SHARE — trading card preview
// =============================================================================
class CardShareBlock extends StatelessWidget {
  const CardShareBlock({super.key, required this.typeData});

  final Map<String, dynamic> typeData;

  @override
  Widget build(BuildContext context) {
    final card = typeData['card'] as Map<String, dynamic>?;
    if (card == null || (card['uid'] as String?) == null) {
      return const _UnavailableBanner(
        icon: LucideIcons.sparkles,
        label: 'Trading Card Unavailable',
        hint: 'This card may have been deleted or removed by its owner.',
      );
    }

    return _TradingCardPreview(typeData: typeData);
  }
}

/// Premium trading-card preview. Renders a dark portrait card with a hero
/// shot image, accent-tinted glow ring matching the card's `accent_hue`,
/// name + quote footer, XP / Lv stat chips, and brand strip. Not a 1:1
/// reproduction of the web's `<TradingCard/>` 3D component, but faithful
/// enough that a user coming from the web recognises the card instantly.
class _TradingCardPreview extends StatelessWidget {
  const _TradingCardPreview({required this.typeData});

  final Map<String, dynamic> typeData;

  @override
  Widget build(BuildContext context) {
    final card = typeData['card'] as Map<String, dynamic>;
    final brands =
        ((typeData['brands'] as List?) ?? const []).cast<Map<String, dynamic>>();

    final displayName = card['display_name'] as String? ?? '';
    final quote = card['quote'] as String? ?? '';
    final accentHue = (card['accent_hue'] as num?)?.toDouble() ?? 140;
    final accent = HSLColor.fromAHSL(1, accentHue, 0.55, 0.55).toColor();

    final design = card['design'] as Map<String, dynamic>?;
    final theme = design?['theme'] as Map<String, dynamic>?;
    final faceBg = _parseHex(theme?['face_bg'] as String?) ?? const Color(0xFF080604);

    final owner = card['owner'] as Map<String, dynamic>? ?? const {};
    final level = (owner['level'] as num?)?.toInt() ?? 1;
    final totalXp = (owner['total_xp'] as num?)?.toInt() ?? 0;

    final shots =
        ((card['shots'] as List?) ?? const []).cast<Map<String, dynamic>>();
    final heroImage = _heroImage(shots, card['display_image_url'] as String?);

    final createdAt = card['created_at'] as String? ?? '';
    final cardType = card['card_type'] as String? ?? '';

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: AspectRatio(
          aspectRatio: 3 / 4.4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.xl2All,
              color: faceBg,
              border: Border.all(
                color: accent.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.28),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Hero image
                if (heroImage != null)
                  CachedNetworkImage(
                    imageUrl: heroImage,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const SizedBox(),
                    errorWidget: (_, _, _) => const SizedBox(),
                  )
                else
                  _StarfieldFallback(accent: accent),

                // Accent gradient glow at top-right corner
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          accent.withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom darken gradient → footer
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.xl2,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                          Colors.black.withValues(alpha: 0.95),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayName.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                        if (quote.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            quote.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: accent,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                              height: 1.3,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            _StatChip(
                              label: 'XP',
                              value: _formatNum(totalXp),
                              accent: accent,
                            ),
                            const SizedBox(width: 6),
                            _StatChip(
                              label: 'LVL',
                              value: '$level',
                              accent: accent,
                            ),
                            const Spacer(),
                            if (createdAt.isNotEmpty)
                              Text(
                                createdAt,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Top card-type chip
                if (cardType.isNotEmpty)
                  Positioned(
                    top: AppSpacing.md,
                    left: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: AppRadius.xsAll,
                        border: Border.all(
                          color: accent.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        cardType.toUpperCase(),
                        style: TextStyle(
                          color: accent,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),

                // Top-right brand strip
                if (brands.isNotEmpty)
                  Positioned(
                    top: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Row(
                      children: [
                        for (final b in brands.take(3))
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: _MiniBrandLogo(
                              logoUrl: b['logo_url'] as String? ?? '',
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _heroImage(List<Map<String, dynamic>> shots, String? fallback) {
    for (final s in shots) {
      if (s['media_type'] == 'image') return s['url'] as String?;
    }
    return fallback;
  }

  static Color? _parseHex(String? hex) {
    if (hex == null) return null;
    var s = hex.replaceAll('#', '');
    if (s.length == 6) s = 'FF$s';
    final n = int.tryParse(s, radix: 16);
    return n == null ? null : Color(n);
  }

  static String _formatNum(int n) {
    if (n < 1000) return '$n';
    final str = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(',');
      buf.write(str[i]);
    }
    return buf.toString();
  }
}

// =============================================================================
// Shared helpers
// =============================================================================

class _StarfieldFallback extends StatelessWidget {
  const _StarfieldFallback({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarfieldPainter(accent: accent),
      size: Size.infinite,
    );
  }
}

class _StarfieldPainter extends CustomPainter {
  _StarfieldPainter({required this.accent});
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFF0A0814);
    canvas.drawRect(Offset.zero & size, bg);

    final rand = math.Random(42);
    final star = Paint()..color = Colors.white.withValues(alpha: 0.6);
    for (var i = 0; i < 80; i++) {
      final dx = rand.nextDouble() * size.width;
      final dy = rand.nextDouble() * size.height;
      final r = rand.nextDouble() * 1.2 + 0.2;
      canvas.drawCircle(Offset(dx, dy), r, star);
    }

    // Nebula glow
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [accent.withValues(alpha: 0.25), Colors.transparent],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.3, size.height * 0.35),
        radius: size.width * 0.6,
      ));
    canvas.drawRect(Offset.zero & size, glow);
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter old) => false;
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: AppRadius.xsAll,
        border: Border.all(color: accent.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBrandLogo extends StatelessWidget {
  const _MiniBrandLogo({required this.logoUrl});
  final String logoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: logoUrl.isEmpty
            ? const SizedBox.shrink()
            : CachedNetworkImage(
                imageUrl: logoUrl,
                fit: BoxFit.contain,
                placeholder: (_, _) => const SizedBox(),
                errorWidget: (_, _, _) => const SizedBox(),
              ),
      ),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({
    required this.url,
    required this.fallback,
    required this.size,
  });

  final String? url;
  final String fallback;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial =
        fallback.isEmpty ? '?' : fallback.characters.first.toUpperCase();
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
        border: Border.all(color: colors.borderStrong),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.micro.copyWith(
          color: colors.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    if (url == null || url!.isEmpty) return placeholder;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.borderStrong),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: url!,
        fit: BoxFit.cover,
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) => placeholder,
      ),
    );
  }
}

class _MiniProBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: const LinearGradient(
          colors: [Color(0x33EAB308), Color(0x33F97316)],
        ),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          color: Color(0xFFEAB308),
          fontSize: 8,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({
    required this.text,
    required this.bg,
    required this.fg,
  });

  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.fullAll,
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _StatLine extends StatelessWidget {
  const _StatLine({
    required this.value,
    required this.label,
    required this.color,
    required this.fontSize,
  });

  final String value;
  final String label;
  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            value,
            style: AppTextStyles.number.copyWith(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.micro
                .copyWith(color: colors.textTertiary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _UnavailableBanner extends StatelessWidget {
  const _UnavailableBanner({
    required this.icon,
    required this.label,
    required this.hint,
  });

  final IconData icon;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border.all(color: colors.borderDefault),
        borderRadius: AppRadius.xlAll,
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: colors.textTertiary),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: AppTextStyles.secondary.copyWith(color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}

String _compactNumber(int n) {
  if (n < 1000) return '$n';
  if (n < 1000000) {
    return '${(n / 1000).toStringAsFixed(n % 1000 >= 100 ? 1 : 0)}K';
  }
  return '${(n / 1000000).toStringAsFixed(1)}M';
}
