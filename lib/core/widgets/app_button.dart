import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, ghost, destructive }

enum AppButtonSize { small, regular, large }

/// The single source of button styling. Never use raw [ElevatedButton] or
/// [TextButton] with custom styles — use this instead.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.regular,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool loading;
  final bool expand;

  double get _height => switch (size) {
        AppButtonSize.small => 36,
        AppButtonSize.regular => 44,
        AppButtonSize.large => 48,
      };

  double get _fontSize => switch (size) {
        AppButtonSize.small => 12,
        AppButtonSize.regular => 13,
        AppButtonSize.large => 14,
      };

  double get _hPad => switch (size) {
        AppButtonSize.small => AppSpacing.md,
        AppButtonSize.regular => AppSpacing.base,
        AppButtonSize.large => AppSpacing.lg,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDisabled = onPressed == null || loading;

    final (Color bg, Color fg, Color? border, List<BoxShadow>? shadow) =
        switch (variant) {
      AppButtonVariant.primary => (
          isDisabled ? colors.accent.withValues(alpha: 0.5) : colors.accent,
          Colors.white,
          null,
          isDisabled
              ? null
              : [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
      AppButtonVariant.secondary => (
          Colors.transparent,
          colors.accent,
          colors.accent,
          null,
        ),
      AppButtonVariant.ghost => (
          Colors.transparent,
          colors.accent,
          null,
          null,
        ),
      AppButtonVariant.destructive => (
          isDisabled ? colors.error.withValues(alpha: 0.5) : colors.error,
          Colors.white,
          null,
          null,
        ),
    };

    final child = loading
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: _fontSize + 4, color: fg),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.buttonLabel.copyWith(
                    color: fg,
                    fontSize: _fontSize,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(trailingIcon, size: _fontSize + 4, color: fg),
              ],
            ],
          );

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: label,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: _height,
          minWidth: expand ? double.infinity : 44,
        ),
        child: AnimatedContainer(
          duration: AppDurations.micro,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadius.mdAll,
            border: border != null ? Border.all(color: border) : null,
            boxShadow: shadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadius.mdAll,
              onTap: isDisabled ? null : onPressed,
              splashColor: fg.withValues(alpha: 0.1),
              highlightColor: fg.withValues(alpha: 0.05),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: _hPad),
                child: Center(widthFactor: expand ? null : 1, child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
