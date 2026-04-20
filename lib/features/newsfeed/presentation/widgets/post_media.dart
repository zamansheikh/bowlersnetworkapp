import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Photo gallery sized per photo count, matching the web:
/// - 1 photo: full-width, max aspect 4:3
/// - 2 photos: side-by-side square
/// - 3 photos: first col-span-2 on top, two squares below
/// - 4+ photos: 2×2 grid, 4th cell shows "+N" overlay
class PostPhotoGallery extends StatelessWidget {
  const PostPhotoGallery({super.key, required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: switch (urls.length) {
        1 => _single(urls.first),
        2 => _two(),
        3 => _three(),
        _ => _fourOrMore(),
      },
    );
  }

  Widget _single(String url) => AspectRatio(
        aspectRatio: 4 / 3,
        child: _Image(url: url),
      );

  Widget _two() => AspectRatio(
        aspectRatio: 2 / 1,
        child: Row(
          children: [
            Expanded(child: _Image(url: urls[0])),
            const SizedBox(width: 2),
            Expanded(child: _Image(url: urls[1])),
          ],
        ),
      );

  Widget _three() => AspectRatio(
        aspectRatio: 1.1,
        child: Column(
          children: [
            Expanded(flex: 3, child: _Image(url: urls[0])),
            const SizedBox(height: 2),
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(child: _Image(url: urls[1])),
                  const SizedBox(width: 2),
                  Expanded(child: _Image(url: urls[2])),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _fourOrMore() {
    final extra = urls.length - 4;
    return AspectRatio(
      aspectRatio: 1,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _Image(url: urls[0])),
                const SizedBox(width: 2),
                Expanded(child: _Image(url: urls[1])),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _Image(url: urls[2])),
                const SizedBox(width: 2),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _Image(url: urls[3]),
                      if (extra > 0)
                        Container(
                          color: Colors.black.withValues(alpha: 0.55),
                          alignment: Alignment.center,
                          child: Text(
                            '+$extra',
                            style: AppTextStyles.numberLarge.copyWith(
                              color: Colors.white,
                              fontSize: 28,
                            ),
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
    );
  }
}

class _Image extends StatelessWidget {
  const _Image({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => Container(color: colors.bgSurfaceHover),
      errorWidget: (_, _, _) => Container(
        color: colors.bgSurfaceHover,
        alignment: Alignment.center,
        child: Icon(
          LucideIcons.imageOff,
          color: colors.textTertiary,
          size: 22,
        ),
      ),
    );
  }
}

/// Score card for post_type = "score". Gradient-bordered panel with the
/// total score on the left and strike% + splits on the right.
class PostScoreCard extends StatelessWidget {
  const PostScoreCard({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = (data['total_score'] as num?)?.toInt() ?? 0;
    final gameType = (data['game_type'] as String? ?? '').toUpperCase();
    final strikeRaw = data['strike_percentage'];
    final strikePct = strikeRaw is num ? (strikeRaw * 100).toInt() : null;
    final splitCount = (data['split_count'] as num?)?.toInt();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgAll,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.accent.withValues(alpha: 0.12),
            colors.accent.withValues(alpha: 0.02),
          ],
        ),
        border: Border.all(color: colors.accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (gameType.isNotEmpty)
                  Text(
                    gameType,
                    style: AppTextStyles.label.copyWith(color: colors.accent),
                  ),
                const SizedBox(height: 2),
                Text(
                  '$total',
                  style: AppTextStyles.numberLarge.copyWith(
                    color: colors.textPrimary,
                    fontSize: 40,
                    height: 1,
                  ),
                ),
                Text(
                  'Total Score',
                  style: AppTextStyles.secondary
                      .copyWith(color: colors.textTertiary),
                ),
              ],
            ),
          ),
          if (strikePct != null || splitCount != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (strikePct != null) ...[
                  Text(
                    '$strikePct%',
                    style: AppTextStyles.numberLarge.copyWith(
                      color: colors.accent,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Strikes',
                    style: AppTextStyles.micro
                        .copyWith(color: colors.textTertiary),
                  ),
                ],
                if (splitCount != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '$splitCount',
                    style: AppTextStyles.numberLarge.copyWith(
                      color: colors.textPrimary,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Splits',
                    style: AppTextStyles.micro
                        .copyWith(color: colors.textTertiary),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

/// Poll card with animated fill bars + vote count + expiry countdown.
class PostPollCard extends StatelessWidget {
  const PostPollCard({super.key, required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final question = data['question'] as String? ?? '';
    final options = (data['options'] as List?) ?? const [];
    final hasVoted = data['has_voted'] as bool? ?? false;
    final totalVotes = (data['total_votes'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: colors.borderDefault),
        color: colors.bgSurface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (question.isNotEmpty)
            Text(
              question,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textPrimary,
                fontSize: 15,
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          for (final o in options)
            _PollOption(data: o as Map<String, dynamic>, voted: hasVoted),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$totalVotes ${totalVotes == 1 ? 'vote' : 'votes'}',
            style: AppTextStyles.micro.copyWith(color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _PollOption extends StatelessWidget {
  const _PollOption({required this.data, required this.voted});
  final Map<String, dynamic> data;
  final bool voted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = data['text'] as String? ?? '';
    final votes = (data['votes'] as num?)?.toInt() ?? 0;
    final pct = (data['percentage'] as num?)?.toDouble() ?? 0;
    final isMine = data['is_mine'] as bool? ?? false;

    final label = Text(
      text,
      style: AppTextStyles.bodySmall.copyWith(
        color: isMine ? colors.accent : colors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: voted
          ? Stack(
              children: [
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.mdAll,
                    color: colors.bgSurfaceHover.withValues(alpha: 0.4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (pct / 100).clamp(0.0, 1.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.mdAll,
                      color: isMine
                          ? colors.accent.withValues(alpha: 0.16)
                          : colors.borderDefault.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Expanded(child: label),
                        Text(
                          '${pct.toStringAsFixed(0)}%',
                          style: AppTextStyles.number.copyWith(
                            color: isMine
                                ? colors.accent
                                : colors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (votes > 0)
                  Positioned(
                    right: AppSpacing.md,
                    bottom: 2,
                    child: Text(
                      '$votes',
                      style: AppTextStyles.micro.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ),
              ],
            )
          : Container(
              height: 44,
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: AppRadius.mdAll,
                border: Border.all(color: colors.borderStrong),
              ),
              alignment: Alignment.centerLeft,
              child: label,
            ),
    );
  }
}

/// Video preview with play button overlay (actual playback lands later).
class PostVideoPreview extends StatelessWidget {
  const PostVideoPreview({super.key, this.thumbnailUrl});

  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (thumbnailUrl != null)
              CachedNetworkImage(
                imageUrl: thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: colors.bgSurfaceHover),
                errorWidget: (_, _, _) =>
                    Container(color: colors.bgSurfaceHover),
              )
            else
              Container(color: colors.bgSurfaceHover),
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.55),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.24),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(
                    LucideIcons.play,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
