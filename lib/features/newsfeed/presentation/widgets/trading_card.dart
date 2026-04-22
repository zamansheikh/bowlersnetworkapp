import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_spacing.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// TradingCard — Flutter port of `@bowlersnetwork/trading-cards` TradingCard.
///
/// Pixel-parity with the web component:
///   * Fixed 300 × 420 canvas (web constants CARD_WIDTH / CARD_HEIGHT)
///   * 3D Y-axis flip (1100ms, cubic-bezier(0.45, 0.05, 0.25, 1))
///   * Front: photo w/ accent frame, player name, quote, XP / LVL badges,
///     date, BN logo watermark. Accent corner stripes at all 4 corners.
///   * Back: 3 tabs (INFO / BRANDS / SHOTS) over a backdrop-blurred panel.
///     - InfoPanel: 7 stat rows
///     - BrandsPanel: "FAVORITE BRANDS" header + logo list
///     - ShotsCarousel: image/video carousel, arrows + dots, swipe gestures
///
/// The card does not support all 8 web "designs" (Obsidian / Cyberpunk / …).
/// We render the common Obsidian look — a sufficient default since every
/// design ultimately inherits the same structural chrome.
/// ─────────────────────────────────────────────────────────────────────────────
class TradingCard extends StatefulWidget {
  const TradingCard({
    super.key,
    required this.typeData,
    this.scale = 1,
  });

  /// Raw `type_data` from the backend's `CardSharePost` — `{card, info, brands}`.
  final Map<String, dynamic> typeData;

  /// Matches web's `scale` prop (0..1+). Useful when embedding in a feed.
  final double scale;

  static const double cardWidth = 300;
  static const double cardHeight = 420;

  @override
  State<TradingCard> createState() => _TradingCardState();
}

class _TradingCardState extends State<TradingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipCtl;
  bool _isFlipped = false;

  // Web timings: front hides at 440ms, back shows at 560ms (total 1100ms).
  static const _rotation = Duration(milliseconds: 1100);

  @override
  void initState() {
    super.initState();
    _flipCtl = AnimationController(vsync: this, duration: _rotation);
  }

  @override
  void dispose() {
    _flipCtl.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    if (_flipCtl.isAnimating) return;
    setState(() => _isFlipped = !_isFlipped);
    if (_isFlipped) {
      _flipCtl.forward();
    } else {
      _flipCtl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = (widget.typeData['card'] as Map<String, dynamic>?) ?? const {};
    final info = (widget.typeData['info'] as Map<String, dynamic>?) ?? const {};
    final brands =
        ((widget.typeData['brands'] as List?) ?? const [])
            .cast<Map<String, dynamic>>();

    final accentHue = (card['accent_hue'] as num?)?.toDouble() ?? 140;
    final theme = _ThemeVars.from(
      hue: accentHue,
      theme: (card['design'] as Map<String, dynamic>?)?['theme']
          as Map<String, dynamic>?,
    );

    return Center(
      child: SizedBox(
        width: TradingCard.cardWidth * widget.scale,
        height: TradingCard.cardHeight * widget.scale,
        child: FittedBox(
          fit: BoxFit.contain,
          child: GestureDetector(
            onTap: _toggleFlip,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: TradingCard.cardWidth,
              height: TradingCard.cardHeight,
              child: AnimatedBuilder(
                animation: _flipCtl,
                builder: (context, _) {
                  final t = CurvedAnimation(
                    parent: _flipCtl,
                    curve: const Cubic(0.45, 0.05, 0.25, 1),
                  ).value;
                  final angle = t * 3.14159265;
                  final showingFront = angle < 1.5707963;

                  final transform = Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // perspective
                    ..rotateY(angle);

                  return Transform(
                    alignment: Alignment.center,
                    transform: transform,
                    child: showingFront
                        ? _Face(
                            theme: theme,
                            child: _CardFront(card: card, theme: theme),
                          )
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(3.14159265),
                            child: _Face(
                              theme: theme,
                              child: _CardBack(
                                card: card,
                                info: info,
                                brands: brands,
                                theme: theme,
                              ),
                            ),
                          ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Theme variables (mirrors `computeThemeVars` in the web package)
// =============================================================================
class _ThemeVars {
  _ThemeVars({
    required this.hue,
    required this.sat,
    required this.c1, // main accent
    required this.c2, // mid accent
    required this.c3, // deep accent
    required this.cdark, // very dark accent
    required this.cglow, // glow color
    required this.faceBg,
  });

  final double hue;
  final double sat;
  final Color c1;
  final Color c2;
  final Color c3;
  final Color cdark;
  final Color cglow;
  final Color faceBg;

  static _ThemeVars from({
    required double hue,
    Map<String, dynamic>? theme,
  }) {
    final accentHsl = theme?['accent_hsl'] as String?;
    final sat = _parseSat(accentHsl);
    final ratio = sat / 55;
    final faceBgHex = theme?['face_bg'] as String?;

    Color hsl(double h, double s, double l) =>
        HSLColor.fromAHSL(1, h % 360, (s / 100).clamp(0.0, 1.0),
                (l / 100).clamp(0.0, 1.0))
            .toColor();

    return _ThemeVars(
      hue: hue,
      sat: sat,
      c1: hsl(hue, sat, 55),
      c2: hsl(hue + 15, 70 * ratio, 45),
      c3: hsl(hue - 10, 90 * ratio, 35),
      cdark: hsl(hue, 15 * ratio, 4),
      cglow: hsl(hue, 80 * ratio, 50),
      faceBg: _parseHex(faceBgHex) ?? hsl(hue, 8, 4),
    );
  }

  static double _parseSat(String? hsl) {
    if (hsl == null) return 55;
    final m = RegExp(r'hsl\(\s*[\d.]+\s*,\s*([\d.]+)%').firstMatch(hsl);
    if (m == null) return 55;
    return double.tryParse(m.group(1)!) ?? 55;
  }

  static Color? _parseHex(String? hex) {
    if (hex == null) return null;
    var s = hex.replaceAll('#', '');
    if (s.length == 6) s = 'FF$s';
    final n = int.tryParse(s, radix: 16);
    return n == null ? null : Color(n);
  }
}

// =============================================================================
// Face — shared frame + corner stripes + hue-tinted gradient background
// =============================================================================
class _Face extends StatelessWidget {
  const _Face({required this.child, required this.theme});

  final Widget child;
  final _ThemeVars theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSLColor.fromAHSL(1, theme.hue, 0.10, 0.07).toColor(),
            HSLColor.fromAHSL(1, theme.hue, 0.08, 0.03).toColor(),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.9),
            blurRadius: 80,
            offset: const Offset(0, 30),
          ),
          BoxShadow(
            color: theme.c3.withValues(alpha: 0.45),
            blurRadius: 40,
            spreadRadius: -15,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Accent diagonal "geo slash" decoration (mirrors obsidian design)
          IgnorePointer(
            child: CustomPaint(
              painter: _GeoSlashPainter(theme: theme),
            ),
          ),
          // Corner stripes at each of the 4 corners
          const IgnorePointer(child: _CornerStripes()),
          // Accent top-line pulse
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    theme.c3.withValues(alpha: 0.6),
                    theme.c1.withValues(alpha: 0.7),
                    theme.c3.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                ),
              ),
            ),
          ),
          // Content
          child,
          // Inner subtle top highlight
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          // Thin inner ring
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerStripes extends StatelessWidget {
  const _CornerStripes();

  @override
  Widget build(BuildContext context) {
    return const _CornerLayer();
  }
}

class _CornerLayer extends StatelessWidget {
  const _CornerLayer();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand();
  }
}

class _GeoSlashPainter extends CustomPainter {
  _GeoSlashPainter({required this.theme});
  final _ThemeVars theme;

  @override
  void paint(Canvas canvas, Size size) {
    // Big diagonal slash — mirrors web's `.tc-cl-geoSlash` gradient
    final slashPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.c3.withValues(alpha: 0.18),
          theme.c1.withValues(alpha: 0.10),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.6);
    canvas.rotate(-0.4); // ~-23 degrees
    canvas.translate(-size.width * 0.9, 0);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width * 2, 120),
      slashPaint,
    );
    canvas.restore();

    // Secondary thinner slash at bottom
    final slash2 = Paint()
      ..color = theme.c1.withValues(alpha: 0.09);
    canvas.save();
    canvas.translate(size.width * 0.2, size.height * 0.85);
    canvas.rotate(-0.35);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * 1.8, 40), slash2);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GeoSlashPainter old) =>
      old.theme.hue != theme.hue;
}

// =============================================================================
// CARD FRONT
// =============================================================================
class _CardFront extends StatelessWidget {
  const _CardFront({required this.card, required this.theme});

  final Map<String, dynamic> card;
  final _ThemeVars theme;

  @override
  Widget build(BuildContext context) {
    final displayName = card['display_name'] as String? ?? '';
    final quote = card['quote'] as String? ?? '';
    final heroImage = _heroImage(card);
    final dateStr = card['created_at'] as String? ?? '';
    final owner = (card['owner'] as Map<String, dynamic>?) ?? const {};
    final level = (owner['level'] as num?)?.toInt() ?? 1;
    final totalXp = (owner['total_xp'] as num?)?.toInt() ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Photo wrap with accent frame + gradient darken + name overlay
          Expanded(
            child: _AccentFramedPhoto(
              heroImage: heroImage,
              displayName: displayName,
              quote: quote,
              theme: theme,
            ),
          ),
          const SizedBox(height: 10),
          // Front bottom: XP / LVL badges + date + BN logo
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _StatBadge(label: 'XP', value: _formatNum(totalXp), theme: theme),
              const SizedBox(width: 8),
              Container(width: 1, height: 28, color: theme.c1.withValues(alpha: 0.10)),
              const SizedBox(width: 8),
              _StatBadge(label: 'LVL', value: '$level', theme: theme),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (dateStr.isNotEmpty)
                    Text(
                      dateStr,
                      style: const TextStyle(
                        color: Colors.white24,
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                      ),
                    ),
                  const SizedBox(height: 4),
                  ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      0.8, 0, 0, 0, 0,
                      0, 0.8, 0, 0, 0,
                      0, 0, 0.8, 0, 0,
                      0, 0, 0, 1, 0,
                    ]),
                    child: Image.asset(
                      'assets/icon/icon.png',
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _heroImage(Map<String, dynamic> card) {
    final shots = ((card['shots'] as List?) ?? const [])
        .cast<Map<String, dynamic>>();
    for (final s in shots) {
      if (s['media_type'] == 'image') return s['url'] as String?;
    }
    final fallback = card['display_image_url'] as String?;
    if (fallback != null && fallback.isNotEmpty) return fallback;
    return null;
  }
}

class _AccentFramedPhoto extends StatelessWidget {
  const _AccentFramedPhoto({
    required this.heroImage,
    required this.displayName,
    required this.quote,
    required this.theme,
  });

  final String? heroImage;
  final String displayName;
  final String quote;
  final _ThemeVars theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.cdark,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Hero image
          if (heroImage != null)
            ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.95, 0, 0, 0, 0,
                0, 0.95, 0, 0, 0,
                0, 0, 0.95, 0, 0,
                0, 0, 0, 1, 0,
              ]),
              child: CachedNetworkImage(
                imageUrl: heroImage!,
                fit: BoxFit.cover,
                placeholder: (_, _) => const SizedBox(),
                errorWidget: (_, _, _) => const SizedBox(),
              ),
            ),
          // Bottom darken gradient → name is legible
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      theme.cdark.withValues(alpha: 0.92),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Accent frame — subtle glow on top edge + bottom-right corner
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.c1.withValues(alpha: 0.22),
                      Colors.transparent,
                      theme.c2.withValues(alpha: 0.22),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                  backgroundBlendMode: BlendMode.overlay,
                ),
              ),
            ),
          ),
          // Name block at bottom
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
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
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    height: 1.1,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
                if (quote.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    quote,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.c1.withValues(alpha: 0.85),
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.value,
    required this.theme,
  });

  final String label;
  final String value;
  final _ThemeVars theme;

  @override
  Widget build(BuildContext context) {
    // Stacked: label on top, number below. Matches web .tc-badge structure.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: theme.c1.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white30,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: theme.c1,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CARD BACK
// =============================================================================
class _CardBack extends StatefulWidget {
  const _CardBack({
    required this.card,
    required this.info,
    required this.brands,
    required this.theme,
  });

  final Map<String, dynamic> card;
  final Map<String, dynamic> info;
  final List<Map<String, dynamic>> brands;
  final _ThemeVars theme;

  @override
  State<_CardBack> createState() => _CardBackState();
}

class _CardBackState extends State<_CardBack> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final owner =
        (widget.card['owner'] as Map<String, dynamic>?) ?? const {};
    final displayName = widget.card['display_name'] as String? ?? '';
    final dateStr = widget.card['created_at'] as String? ?? '';
    final level = (owner['level'] as num?)?.toInt() ?? 1;
    final totalXp = (owner['total_xp'] as num?)?.toInt() ?? 0;
    final shots = ((widget.card['shots'] as List?) ?? const [])
        .cast<Map<String, dynamic>>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TabBar(
            active: _tabIndex,
            theme: widget.theme,
            onTap: (i) => setState(() => _tabIndex = i),
          ),
          const SizedBox(height: 9),
          Expanded(
            child: _Panel(
              theme: widget.theme,
              child: _tabContent(shots),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
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
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    _BackSub(
                      totalXp: totalXp,
                      level: level,
                      dateStr: dateStr,
                      theme: widget.theme,
                    ),
                  ],
                ),
              ),
              ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.8, 0, 0, 0, 0,
                  0, 0.8, 0, 0, 0,
                  0, 0, 0.8, 0, 0,
                  0, 0, 0, 1, 0,
                ]),
                child: Image.asset(
                  'assets/icon/icon.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabContent(List<Map<String, dynamic>> shots) {
    switch (_tabIndex) {
      case 0:
        return _InfoPanel(info: widget.info, theme: widget.theme);
      case 1:
        return _BrandsPanel(brands: widget.brands, theme: widget.theme);
      case 2:
        return _ShotsCarousel(shots: shots, theme: widget.theme);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _BackSub extends StatelessWidget {
  const _BackSub({
    required this.totalXp,
    required this.level,
    required this.dateStr,
    required this.theme,
  });

  final int totalXp;
  final int level;
  final String dateStr;
  final _ThemeVars theme;

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: const TextStyle(
          color: Colors.white24,
          fontSize: 10,
          letterSpacing: 1,
        ),
        children: [
          const TextSpan(text: 'XP '),
          TextSpan(
            text: _formatNum(totalXp),
            style: TextStyle(color: theme.c1, fontWeight: FontWeight.w700),
          ),
          const TextSpan(text: '  ·  LVL '),
          TextSpan(
            text: '$level',
            style: TextStyle(color: theme.c1, fontWeight: FontWeight.w700),
          ),
          TextSpan(text: '  ·  $dateStr'),
        ],
      ),
    );
  }
}

// =============================================================================
// Tab bar
// =============================================================================
class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.active,
    required this.onTap,
    required this.theme,
  });

  final int active;
  final ValueChanged<int> onTap;
  final _ThemeVars theme;

  static const _labels = ['INFO', 'BRANDS', 'SHOTS'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          for (var i = 0; i < _labels.length; i++) ...[
            Expanded(
              child: _TabButton(
                label: _labels[i],
                active: active == i,
                onTap: () => onTap(i),
                theme: theme,
              ),
            ),
            if (i < _labels.length - 1) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final _ThemeVars theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        height: 30,
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [theme.c3, theme.c1],
                )
              : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: active
                ? Colors.transparent
                : theme.c1.withValues(alpha: 0.08),
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: theme.cglow.withValues(alpha: 0.35),
                    blurRadius: 18,
                    spreadRadius: -5,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white30,
            fontSize: 11,
            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Panel (shared container for all 3 tab views)
// =============================================================================
class _Panel extends StatelessWidget {
  const _Panel({required this.child, required this.theme});
  final Widget child;
  final _ThemeVars theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.c1.withValues(alpha: 0.06),
        ),
      ),
      child: child,
    );
  }
}

// =============================================================================
// INFO PANEL — 7 stat rows
// =============================================================================
class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.info, required this.theme});

  final Map<String, dynamic> info;
  final _ThemeVars theme;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('Home Center', _str(info['home_center'])),
      ('Average', _str(info['average'])),
      ('High Game', _str(info['high_game'])),
      ('High Series', _str(info['high_series'])),
      ('Experience', _yrs(info['experience'])),
      ('Gender', _str(info['gender'])),
      ('Age', _str(info['age'])),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < rows.length; i++)
            _StatRow(
              label: rows[i].$1,
              value: rows[i].$2,
              isFirst: i == 0,
              isLast: i == rows.length - 1,
              theme: theme,
            ),
        ],
      ),
    );
  }

  static String _str(dynamic v) {
    if (v == null) return '—';
    final s = v.toString();
    return s.isEmpty ? '—' : s;
  }

  static String _yrs(dynamic v) {
    if (v == null) return '—';
    final s = v.toString();
    if (s.isEmpty) return '—';
    if (s.toLowerCase().contains('yr')) return s;
    return '$s Yrs';
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.isFirst,
    required this.isLast,
    required this.theme,
  });

  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;
  final _ThemeVars theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(8) : Radius.zero,
          bottom: isLast ? const Radius.circular(8) : Radius.zero,
        ),
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: theme.c1,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// BRANDS PANEL — "FAVORITE BRANDS" header + logo list
// =============================================================================
class _BrandsPanel extends StatelessWidget {
  const _BrandsPanel({required this.brands, required this.theme});

  final List<Map<String, dynamic>> brands;
  final _ThemeVars theme;

  @override
  Widget build(BuildContext context) {
    if (brands.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 24),
          child: Text(
            'No brands added',
            style: TextStyle(
              color: Colors.white24,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10, left: 2),
            child: Text(
              'FAVORITE BRANDS',
              style: TextStyle(
                color: Colors.white24,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
              ),
            ),
          ),
          for (final b in brands) ...[
            _BrandRow(
              name: b['name'] as String? ?? '',
              logoUrl: b['logo_url'] as String? ?? '',
              theme: theme,
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow({
    required this.name,
    required this.logoUrl,
    required this.theme,
  });

  final String name;
  final String logoUrl;
  final _ThemeVars theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.c1.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: CachedNetworkImage(
                imageUrl: logoUrl,
                fit: BoxFit.contain,
                placeholder: (_, _) => const SizedBox.shrink(),
                errorWidget: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SHOTS CAROUSEL — image/video carousel with arrows + dots
// =============================================================================
class _ShotsCarousel extends StatefulWidget {
  const _ShotsCarousel({required this.shots, required this.theme});

  final List<Map<String, dynamic>> shots;
  final _ThemeVars theme;

  @override
  State<_ShotsCarousel> createState() => _ShotsCarouselState();
}

class _ShotsCarouselState extends State<_ShotsCarousel> {
  int _index = 0;

  void _goTo(int n) {
    final len = widget.shots.length;
    if (len == 0) return;
    setState(() => _index = (n + len) % len);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shots.isEmpty) {
      return const Center(
        child: Text(
          'No shots added',
          style: TextStyle(
            color: Colors.white24,
            fontSize: 12,
            letterSpacing: 1,
          ),
        ),
      );
    }

    final current = widget.shots[_index];
    final isVideo = current['media_type'] == 'video';
    final url = current['url'] as String? ?? '';

    return GestureDetector(
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity ?? 0;
        if (v.abs() < 200) return;
        if (v < 0) {
          _goTo(_index + 1);
        } else {
          _goTo(_index - 1);
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Media
          if (isVideo)
            _ShotVideo(url: url, key: ValueKey(url))
          else
            CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, _) => const SizedBox(),
              errorWidget: (_, _, _) => const SizedBox(),
            ),

          // Bottom overlay gradient
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Prev / Next arrows
          if (widget.shots.length > 1) ...[
            Positioned(
              left: 7,
              top: 0,
              bottom: 0,
              child: Center(
                child: _NavArrow(
                  icon: LucideIcons.chevronLeft,
                  onTap: () => _goTo(_index - 1),
                  theme: widget.theme,
                ),
              ),
            ),
            Positioned(
              right: 7,
              top: 0,
              bottom: 0,
              child: Center(
                child: _NavArrow(
                  icon: LucideIcons.chevronRight,
                  onTap: () => _goTo(_index + 1),
                  theme: widget.theme,
                ),
              ),
            ),
          ],

          // Dots
          if (widget.shots.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 9,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < widget.shots.length; i++) ...[
                    GestureDetector(
                      onTap: () => _goTo(i),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: i == _index ? 8 : 5,
                        height: i == _index ? 8 : 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _index
                              ? widget.theme.c1
                              : Colors.white24,
                          boxShadow: i == _index
                              ? [
                                  BoxShadow(
                                    color: widget.theme.cglow
                                        .withValues(alpha: 0.6),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                    if (i < widget.shots.length - 1) const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({
    required this.icon,
    required this.onTap,
    required this.theme,
  });

  final IconData icon;
  final VoidCallback onTap;
  final _ThemeVars theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.5),
          border: Border.all(
            color: theme.c1.withValues(alpha: 0.15),
          ),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 14, color: theme.c1),
      ),
    );
  }
}

/// Single video player that auto-disposes when swiped away.
class _ShotVideo extends StatefulWidget {
  const _ShotVideo({super.key, required this.url});
  final String url;

  @override
  State<_ShotVideo> createState() => _ShotVideoState();
}

class _ShotVideoState extends State<_ShotVideo> {
  VideoPlayerController? _ctl;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final c = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    try {
      await c.initialize();
      await c.setLooping(true);
      await c.setVolume(0);
      await c.play();
    } catch (_) {
      await c.dispose();
      return;
    }
    if (!mounted) {
      await c.dispose();
      return;
    }
    setState(() => _ctl = c);
  }

  @override
  void dispose() {
    _ctl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _ctl;
    if (c == null || !c.value.isInitialized) {
      return const ColoredBox(color: Colors.black);
    }
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: c.value.size.width,
        height: c.value.size.height,
        child: VideoPlayer(c),
      ),
    );
  }
}

// =============================================================================
// Helpers
// =============================================================================
String _formatNum(int n) {
  if (n < 1000) return '$n';
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

// Silence unused lint — AppSpacing may be referenced by future polish.
// ignore: unused_element
const _keep = AppSpacing.xs;
