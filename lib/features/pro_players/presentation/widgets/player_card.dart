import 'package:flutter/material.dart';
import '../../domain/entities/pro_player.dart';

class PlayerCard extends StatelessWidget {
  final ProPlayer player;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onFollow;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  const PlayerCard({
    super.key,
    required this.player,
    required this.onTap,
    required this.onFollow,
    this.isLoading = false,
    this.primaryColor = const Color(0xFF8BC342),
    this.secondaryColor = const Color(0xFF385019),
    this.accentColor = const Color(0xFF75B11D),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 320,
        height: 480,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, primaryColor.withValues(alpha: 0.05)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withValues(alpha: 0.05),
                ),
              ),
            ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture and Level
                  Stack(
                    children: [
                      // Profile Picture
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryColor, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: player.profilePictureUrl.isNotEmpty
                              ? Image.network(
                                  player.profilePictureUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: primaryColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        size: 60,
                                        color: primaryColor,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: primaryColor,
                                  ),
                                ),
                        ),
                      ),

                      // Level Badge
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            'LV ${player.level}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Player Name
                  Text(
                    player.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Pro Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'PRO PLAYER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stats Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Stats Row 1
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _StatItem(
                              label: 'AVG',
                              value: player.stats.averageScore.toStringAsFixed(
                                1,
                              ),
                              color: primaryColor,
                            ),
                            _StatItem(
                              label: 'HIGH',
                              value: player.stats.highGame.toString(),
                              color: accentColor,
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Stats Row 2
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _StatItem(
                              label: 'XP',
                              value: _formatNumber(player.xp),
                              color: secondaryColor,
                            ),
                            _StatItem(
                              label: 'FOLLOWERS',
                              value: _formatNumber(player.followerCount),
                              color: primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Follow Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: player.isFollowed
                            ? Colors.grey[400]
                            : primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: primaryColor.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  player.isFollowed
                                      ? Icons.check_circle
                                      : Icons.add_circle_outline,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  player.isFollowed ? 'Following' : 'Follow',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
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

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
