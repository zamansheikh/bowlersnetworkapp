import 'package:flutter/material.dart';
import '../../domain/entities/pro_player.dart';

class PlayerCard extends StatefulWidget {
  final ProPlayer player;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onFollow;
  final VoidCallback? onCollect;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  const PlayerCard({
    super.key,
    required this.player,
    required this.onTap,
    required this.onFollow,
    this.onCollect,
    this.isLoading = false,
    this.primaryColor = const Color(0xFF385019),
    this.secondaryColor = const Color(0xFF113108),
    this.accentColor = const Color(0xFFE1C348),
  });

  @override
  State<PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<PlayerCard> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cardWidth = 322.0;
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.primaryColor.withValues(alpha: 0.92),
            widget.secondaryColor.withValues(alpha: 0.96),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.primaryColor.withOpacity(0.35),
                widget.secondaryColor.withOpacity(0.75),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---- PageView -------------------------------------------------
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      _ProfileView(
                        player: widget.player,
                        primaryColor: widget.primaryColor,
                        accentColor: widget.accentColor,
                      ),
                      _ShotsAndStatesView(
                        player: widget.player,
                        primaryColor: widget.primaryColor,
                        accentColor: widget.accentColor,
                        secondaryColor: widget.secondaryColor,
                        numberFormatter: _formatNumber,
                        currentPage: _currentPage,
                        onPageChanged: (i) {
                          print('Changing to page $i');
                          setState(() => _currentPage = i);
                          _pageController.animateToPage(
                            i + 1,
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ---- Player name + meta --------------------------------------
                _buildPlayerNameSection(),
                const SizedBox(height: 16),

                // ---- Follow / Collect ----------------------------------------
                _buildActionRow(),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  Widget _buildPlayerNameSection() {
    final levelText = 'Level ${widget.player.level}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.player.name.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _currentPage == 0
              ? Row(
                  key: const ValueKey('shots-meta'),
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white.withOpacity(0.12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.24),
                        ),
                      ),
                      child: Text(
                        levelText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: widget.accentColor.withOpacity(0.15),
                          border: Border.all(
                            color: widget.accentColor.withOpacity(0.45),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: widget.accentColor,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Details',
                              style: TextStyle(
                                color: widget.accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey('stats-meta'),
                  children: [
                    Icon(Icons.bolt, size: 18, color: widget.accentColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: _levelProgress(widget.player.xp),
                          minHeight: 10,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.accentColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      levelText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------------------
  Widget _buildActionRow() {
    return Row(
      children: [
        Expanded(child: _buildFollowButton()),
        const SizedBox(width: 12),
        Expanded(child: _buildCollectButton()),
      ],
    );
  }

  Widget _buildFollowButton() {
    final isFollowed = widget.player.isFollowed;
    return ElevatedButton(
      onPressed: widget.isLoading ? null : widget.onFollow,
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowed
            ? widget.accentColor.withOpacity(0.35)
            : widget.accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: widget.isLoading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isFollowed ? Icons.check : Icons.person_add_alt_1,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isFollowed ? 'Following' : 'Follow',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCollectButton() {
    return OutlinedButton(
      onPressed: widget.onCollect ?? () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withOpacity(0.55)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.collections_bookmark_outlined, size: 18),
          SizedBox(width: 8),
          Text(
            'Collect',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  String _formatNumber(int number) {
    if (number >= 1_000_000) {
      return '${(number / 1_000_000).toStringAsFixed(1)}M';
    }
    if (number >= 1_000) {
      return '${(number / 1_000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  double _levelProgress(int xp) {
    final normalized = (xp % 1000) / 1000;
    return normalized.clamp(0.2, 0.95);
  }
}

// --------------------------------------------------------------------------
// Profile view (page 0)
// --------------------------------------------------------------------------
class _ProfileView extends StatelessWidget {
  const _ProfileView({
    required this.player,
    required this.primaryColor,
    required this.accentColor,
  });

  final ProPlayer player;
  final Color primaryColor;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [_buildPrimaryImage()],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrimaryImage() {
    if (player.profilePictureUrl.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor.withOpacity(0.65),
              accentColor.withOpacity(0.45),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(Icons.person_outline, color: Colors.white, size: 88),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          player.profilePictureUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.65),
                  accentColor.withOpacity(0.45),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(Icons.person_outline, color: Colors.white, size: 88),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.35)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------------------------------
// Shots & Stats view (page 1)
// --------------------------------------------------------------------------
class _ShotsAndStatesView extends StatelessWidget {
  final ProPlayer player;
  final Color primaryColor;
  final Color accentColor;
  final Color secondaryColor;
  final String Function(int) numberFormatter;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const _ShotsAndStatesView({
    required this.player,
    required this.primaryColor,
    required this.accentColor,
    required this.secondaryColor,
    required this.numberFormatter,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image (same as profile)
                if (currentPage == 0) _buildPrimaryImage(),

                // Content (StatsView)
                if (currentPage == 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 64),
                    child: StatsView(
                      player: player,
                      primaryColor: primaryColor,
                      secondaryColor: secondaryColor,
                      accentColor: accentColor,
                      numberFormatter: numberFormatter,
                    ),
                  ),

                // Segment control at the bottom
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 22,
                  child: _segmentControl(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrimaryImage() {
    if (player.profilePictureUrl.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor.withOpacity(0.65),
              accentColor.withOpacity(0.45),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(Icons.person_outline, color: Colors.white, size: 88),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          player.profilePictureUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.65),
                  accentColor.withOpacity(0.45),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(Icons.person_outline, color: Colors.white, size: 88),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.35)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _segmentControl() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(0.2),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Row(
        children: [_segmentButton('Shots', 0), _segmentButton('Stats', 1)],
      ),
    );
  }

  Widget _segmentButton(String label, int index) {
    final isActive = currentPage == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onPageChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isActive ? primaryColor : Colors.white.withOpacity(0.85),
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// Stats view (the actual stats list)
// --------------------------------------------------------------------------
class StatsView extends StatelessWidget {
  final ProPlayer player;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final String Function(int) numberFormatter;

  const StatsView({
    super.key,
    required this.player,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.numberFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final followers = numberFormatter(player.followerCount);
    final hasContents = player.engagement.views > 0;
    final contents = hasContents
        ? numberFormatter(player.engagement.views)
        : '170';
    final bestScore = player.stats.highGame.toString();
    final favoriteBrands = player.favoriteBrands.take(3).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- Summary row ------------------------------------------------
          Row(
            children: [
              Expanded(
                child: _StatSummaryTile(
                  label: 'Contents',
                  value: contents,
                  alignRight: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatSummaryTile(
                  label: 'Followers',
                  value: followers,
                  alignRight: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ---- Info cards -------------------------------------------------
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  title: 'Home Center',
                  child: Text(
                    'The Goodnight',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  title: 'Favorite Brands',
                  child: favoriteBrands.isEmpty
                      ? Row(
                          children: [
                            _BrandTag(label: 'Storm', accentColor: accentColor),
                            const SizedBox(width: 6),
                            _BrandTag(
                              label: 'Brunswick',
                              accentColor: accentColor,
                            ),
                          ],
                        )
                      : Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: favoriteBrands
                              .map(
                                (b) => _BrandTag(
                                  label: b.name,
                                  accentColor: accentColor,
                                  logoUrl: b.logoUrl,
                                ),
                              )
                              .toList(),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ---- Metric tiles ------------------------------------------------
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricTile(
                label: 'Tournament',
                value: '25',
                icon: Icons.emoji_events_outlined,
              ),
              _MetricTile(
                label: 'Win',
                value: '21',
                icon: Icons.military_tech_outlined,
              ),
              _MetricTile(label: 'Rank', value: '12', icon: Icons.star_border),
              _MetricTile(label: 'Win Rate', value: '95%', icon: Icons.speed),
              _MetricTile(
                label: 'Best Score',
                value: bestScore,
                icon: Icons.scoreboard_outlined,
              ),
              _MetricTile(
                label: 'Streak',
                value: '15',
                icon: Icons.local_fire_department_outlined,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// Helper widgets (unchanged, only minor const tweaks)
// --------------------------------------------------------------------------
class _StatSummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final bool alignRight;

  const _StatSummaryTile({
    required this.label,
    required this.value,
    required this.alignRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.24)),
      ),
      child: Column(
        crossAxisAlignment: alignRight
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.74),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _BrandTag extends StatelessWidget {
  final String label;
  final Color accentColor;
  final String? logoUrl;

  const _BrandTag({
    required this.label,
    required this.accentColor,
    this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (logoUrl != null && logoUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Image.network(
                logoUrl!,
                height: 16,
                width: 16,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.brightness_1, size: 10, color: accentColor),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(Icons.brightness_1, size: 10, color: accentColor),
            ),
          Text(
            label,
            style: TextStyle(
              color: accentColor.darken(0.15),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.85), size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// Color helper (unchanged)
// --------------------------------------------------------------------------
extension on Color {
  Color darken(double amount) {
    final factor = 1 - amount;
    return Color.fromARGB(
      alpha,
      (red * factor).round().clamp(0, 255),
      (green * factor).round().clamp(0, 255),
      (blue * factor).round().clamp(0, 255),
    );
  }
}
