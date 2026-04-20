import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Matches the web's `/(https?:\/\/[^\s<]+[^\s<.,;:!?)}\]'"])/` regex.
/// Written as a raw string so Dart doesn't need to escape the special chars.
final RegExp _urlRegex = RegExp(
  r'''(https?:\/\/[^\s<]+[^\s<.,;:!?)}\]'"])''',
);

/// Matches all YouTube URL variants the web supports: watch, short, embed,
/// shorts, live. Returns the 11-char video ID or null.
String? extractYouTubeId(String url) {
  final patterns = <RegExp>[
    RegExp(
      r'(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/|youtube\.com\/shorts\/)([a-zA-Z0-9_-]{11})',
    ),
    RegExp(r'youtube\.com\/live\/([a-zA-Z0-9_-]{11})'),
  ];
  for (final p in patterns) {
    final m = p.firstMatch(url);
    if (m != null) return m.group(1);
  }
  return null;
}

/// Pull all URLs from text, dedupe while preserving order.
List<String> extractUrls(String text) {
  final matches = _urlRegex.allMatches(text);
  final seen = <String>{};
  final out = <String>[];
  for (final m in matches) {
    final url = m.group(0)!;
    if (seen.add(url)) out.add(url);
  }
  return out;
}

/// Renders rich previews for every URL in [text] — YouTube thumbnail with
/// play button for YouTube links, favicon + hostname card for everything
/// else. Mirrors the web's `<LinkPreviews />`.
class PostLinkPreviews extends StatelessWidget {
  const PostLinkPreviews({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final urls = extractUrls(text);
    if (urls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final url in urls)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: () {
              final ytId = extractYouTubeId(url);
              if (ytId != null) {
                return _YouTubePreview(videoId: ytId, url: url);
              }
              return _GenericLinkPreview(url: url);
            }(),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _YouTubePreview extends StatelessWidget {
  const _YouTubePreview({required this.videoId, required this.url});

  final String videoId;
  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: () => _openUrl(url),
        child: ClipRRect(
          borderRadius: AppRadius.lgAll,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Thumbnail — fall back from maxres → hqdefault on 404.
                CachedNetworkImage(
                  imageUrl: 'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(color: Colors.black),
                  errorWidget: (_, _, _) => CachedNetworkImage(
                    imageUrl:
                        'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(color: Colors.black),
                    errorWidget: (_, _, _) => Container(
                      color: colors.bgSurfaceHover,
                      alignment: Alignment.center,
                      child: Icon(
                        LucideIcons.imageOff,
                        color: colors.textTertiary,
                      ),
                    ),
                  ),
                ),
                // Dim overlay
                Container(color: Colors.black.withValues(alpha: 0.14)),
                // Red play button
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF0000),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(
                        LucideIcons.play,
                        size: 26,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // YouTube chip bottom-left
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: AppRadius.smAll,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.play,
                          size: 10,
                          color: Color(0xFFFF0000),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'YouTube',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
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
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _GenericLinkPreview extends StatelessWidget {
  const _GenericLinkPreview({required this.url});

  final String url;

  String get _hostname {
    try {
      final host = Uri.parse(url).host;
      return host.startsWith('www.') ? host.substring(4) : host;
    } catch (_) {
      return url;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final host = _hostname;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: () => _openUrl(url),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: colors.bgSurfaceHover.withValues(alpha: 0.4),
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: colors.borderDefault),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.bgSurfaceHover,
                  borderRadius: AppRadius.smAll,
                ),
                alignment: Alignment.center,
                child: CachedNetworkImage(
                  imageUrl:
                      'https://www.google.com/s2/favicons?sz=64&domain=$host',
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                  placeholder: (_, _) => Icon(
                    LucideIcons.link,
                    size: 16,
                    color: colors.textTertiary,
                  ),
                  errorWidget: (_, _, _) => Icon(
                    LucideIcons.link,
                    size: 16,
                    color: colors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      host,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      url,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.secondary.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                LucideIcons.externalLink,
                size: 14,
                color: colors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _openUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
