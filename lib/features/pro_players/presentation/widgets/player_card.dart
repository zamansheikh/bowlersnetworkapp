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
    return Container(
      height: 540,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [widget.primaryColor, widget.secondaryColor],
        ),
        border: Border.all(
          color: widget.primaryColor.withValues(alpha: 00.4),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 00.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                        setState(() => _currentPage = i);
                        _pageController.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ---- Player name + meta + Follow / Collect--------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildPlayerNameSection()),
                  const SizedBox(width: 12),
                  _buildActionColumn(),
                ],
              ),
            ],
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
        Row(
          children: [
            Expanded(
              child: Text(
                widget.player.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _currentPage == 0
              ? Row(
                  children: [
                    Text(
                      key: const ValueKey('level-meta'),
                      levelText,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      key: const ValueKey('shots-meta'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: widget.accentColor,
                      ),
                      child: Text(
                        "Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey('stats-meta'),
                  children: [
                    Icon(Icons.bolt, size: 16, color: widget.accentColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          value: _levelProgress(widget.player.xp),
                          minHeight: 6,
                          backgroundColor: Colors.white.withValues(alpha: 00.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.accentColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------------------
  Widget _buildActionColumn() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildFollowButton(),
          const SizedBox(height: 12),
          _buildCollectButton(),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    final isFollowed = widget.player.isFollowed;
    return SizedBox(
      height: 22, // slightly smaller
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onFollow,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.accentColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: widget.isLoading
            ? const SizedBox(
                height: 8,
                width: 8,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, size: 10),
                  const SizedBox(width: 6),
                  Text(
                    isFollowed ? 'Following' : 'Follow',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCollectButton() {
    return SizedBox(
      height: 22,
      child: ElevatedButton(
        onPressed: widget.onCollect ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 00.18),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          minimumSize: const Size(0, 36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.favorite_border, size: 10),
            SizedBox(width: 6),
            Text(
              'Collect',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10),
            ),
          ],
        ),
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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(fit: StackFit.expand, children: [_buildShotsImage()]),
          ),
        );
      },
    );
  }

  Widget _buildShotsImage() {
    if (player.profilePictureUrl.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          gradient: LinearGradient(
            colors: [
              primaryColor.withValues(alpha: 0.65),
              accentColor.withValues(alpha: 0.45),
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
          errorBuilder: (_, _, _) => DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.65),
                  accentColor.withValues(alpha: 0.45),
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
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.35),
                ],
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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 00.5),
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image (same as profile)
                if (currentPage == 1) _buildShotsImage(),

                // Content (StatsView)
                if (currentPage == 2)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48),
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
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: _segmentControl(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShotsImage() {
    if (player.profilePictureUrl.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          gradient: LinearGradient(
            colors: [
              primaryColor.withValues(alpha: 0.65),
              accentColor.withValues(alpha: 0.45),
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
                  primaryColor.withValues(alpha: 00.65),
                  accentColor.withValues(alpha: 00.45),
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
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 00.35),
                ],
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
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: 0.2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [_segmentButton('Shots', 1), _segmentButton('States', 2)],
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
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isActive
                  ? primaryColor.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.75),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          const SizedBox(height: 8),

          // ---- Info cards -------------------------------------------------
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  title: 'Home Center',
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 16,
                    ),
                    child: Text(
                      'The Goodnight',
                      style: const TextStyle(
                        color: Color(0xFF2D3E1F),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoCard(
                  title: 'Favorite Brands',
                  child: favoriteBrands.isEmpty
                      ? _BrandTag(label: 'Storm', accentColor: accentColor)
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            spacing: 4,
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
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ---- Metric tiles grid -------------------------------------------
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Tournament',
                  value: '25',
                  icon: Icons.emoji_events_outlined,
                  accentColor: accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: 'Win',
                  value: '21',
                  icon: Icons.military_tech_outlined,
                  accentColor: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Rank',
                  value: '12',
                  icon: Icons.star_border,
                  accentColor: accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: 'Win Rate',
                  value: '95%',
                  icon: Icons.speed,
                  accentColor: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Best Score',
                  value: bestScore,
                  icon: Icons.scoreboard_outlined,
                  accentColor: accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricTile(
                  label: 'Streak',
                  value: '15',
                  icon: Icons.local_fire_department_outlined,
                  accentColor: accentColor,
                ),
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
    return Column(
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
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 00.8),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
      ],
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
    return (logoUrl != null && logoUrl!.isNotEmpty)
        ? Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Image.network(
              logoUrl!,
              height: 48,
              width: 48,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const SizedBox(width: 48, height: 48),
            ),
          )
        : const SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: Text(
                "No Fav Brand",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
            ),
          );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),

                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    Icon(icon, color: accentColor, size: 22),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
