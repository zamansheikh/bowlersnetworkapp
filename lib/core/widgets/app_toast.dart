import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum ToastVariant { info, success, error, warning }

/// Custom toast shown above the bottom navigation bar. Prefer this over raw
/// [SnackBar] so variant styling stays consistent.
void showAppToast(
  BuildContext context, {
  required String message,
  ToastVariant variant = ToastVariant.info,
  Duration duration = const Duration(seconds: 4),
}) {
  final messenger = ScaffoldMessenger.of(context);
  final colors = context.colors;

  final Color accent = switch (variant) {
    ToastVariant.info => colors.accent,
    ToastVariant.success => colors.success,
    ToastVariant.error => colors.error,
    ToastVariant.warning => colors.warning,
  };

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.only(
          left: AppSpacing.base,
          right: AppSpacing.base,
          bottom: AppSpacing.base,
        ),
        content: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.bgSurfaceElevated,
            borderRadius: AppRadius.mdAll,
            border: Border(left: BorderSide(color: accent, width: 3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Text(
              message,
              style: AppTextStyles.body.copyWith(color: colors.textPrimary),
            ),
          ),
        ),
      ),
    );
}
