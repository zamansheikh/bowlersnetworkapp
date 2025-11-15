import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap,
      child: Container(
        height: 540.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [widget.primaryColor, widget.secondaryColor],
          ),
          border: Border.all(
            color: widget.primaryColor.withValues(alpha: 00.4),
            width: 3.w,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 00.2),
              blurRadius: 20.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
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
                      _ShotsAndStatsView(
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
                SizedBox(height: 20.h),

                // ---- Player name + meta + Follow / Collect--------------------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildPlayerNameSection()),
                    SizedBox(width: 12.w),
                    _buildActionColumn(),
                  ],
                ),
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
        Row(
          children: [
            Expanded(
              child: Text(
                widget.player.name.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8.w,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
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
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      key: const ValueKey('shots-meta'),
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.r),
                        color: widget.accentColor,
                      ),
                      child: Text(
                        "Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey('stats-meta'),
                  children: [
                    Icon(Icons.bolt, size: 16.sp, color: widget.accentColor),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: LinearProgressIndicator(
                          value: _levelProgress(widget.player.xp),
                          minHeight: 6.h,
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
      padding: EdgeInsets.all(8.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildFollowButton(),
          SizedBox(height: 12.h),
          _buildCollectButton(),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    final isFollowed = widget.player.isFollowed;
    return SizedBox(
      height: 22.h,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onFollow,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.accentColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        child: widget.isLoading
            ? SizedBox(
                height: 8.h,
                width: 8.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, size: 10.sp),
                  SizedBox(width: 6.w),
                  Text(
                    isFollowed ? 'Following' : 'Follow',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCollectButton() {
    return SizedBox(
      height: 22.h,
      child: ElevatedButton(
        onPressed: widget.onCollect ?? () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 00.18),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          minimumSize: Size(0, 36.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 10.sp),
            SizedBox(width: 6.w),
            Text(
              'Collect',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10.sp),
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
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 2.w,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
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
class _ShotsAndStatsView extends StatelessWidget {
  final ProPlayer player;
  final Color primaryColor;
  final Color accentColor;
  final Color secondaryColor;
  final String Function(int) numberFormatter;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const _ShotsAndStatsView({
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
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 00.5),
              width: 2.w,
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
                    padding: EdgeInsets.only(bottom: 48.h),
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
                  left: 10.w,
                  right: 10.w,
                  bottom: 10.h,
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
      height: 38.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        color: Colors.white.withValues(alpha: 0.2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [_segmentButton('Shots', 1), _segmentButton('Stats', 2)],
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
          margin: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
              SizedBox(width: 12.w),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 16.h,
                    ),
                    child: Text(
                      'The Goodnight',
                      style: TextStyle(
                        color: Color(0xFF2D3E1F),
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
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
          SizedBox(height: 18.h),

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
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 00.8),
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
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
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
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
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                logoUrl!,
                height: 42.h,
                width: 42.w,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => SizedBox(width: 42.w, height: 42.h),
              ),
            ),
          )
        : SizedBox(
            width: 42.w,
            height: 42.h,
            child: Center(
              child: Text(
                "No Fav Brand",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15.sp,
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
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(6.r)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 18.sp,
                      ),
                    ),
                    Icon(icon, color: accentColor, size: 22.sp),
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
