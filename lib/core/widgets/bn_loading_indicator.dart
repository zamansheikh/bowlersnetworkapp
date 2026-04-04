import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class BnLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const BnLoadingIndicator({
    super.key,
    this.size = 36,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
        ),
      ),
    );
  }
}
