import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/app_text_styles.dart';

class BnAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const BnAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.actions,
    this.leading,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null
          ? Text(title!, style: AppTextStyles.h4)
          : null,
      leading: leading ??
          (showBackButton && Navigator.of(context).canPop()
              ? IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                )
              : null),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}
