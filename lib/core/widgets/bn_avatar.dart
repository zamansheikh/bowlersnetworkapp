import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class BnAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final bool showBorder;
  final bool isPro;

  const BnAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 48,
    this.showBorder = false,
    this.isPro = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: isPro ? AppColors.navActive : AppColors.primary,
                width: 2,
              )
            : null,
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => _buildPlaceholder(),
                errorWidget: (_, _, _) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    final initials = _getInitials();
    return Container(
      color: AppColors.primary.withValues(alpha: 0.15),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  String _getInitials() {
    if (name == null || name!.isEmpty) return '?';
    final words = name!.trim().split(RegExp(r'\s+'));
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}
