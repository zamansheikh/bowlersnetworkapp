import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, ghost, destructive }

enum AppButtonSize { small, regular, large }

/// The single source of button styling across the app.
///
/// Mirrors the web frontend exactly:
/// - `h-9 / h-11 / h-12` heights
/// - `rounded-[10px]` corners
/// - `active:scale-[0.98]` press animation
/// - `shadow-[0_4px_16px_rgba(139,195,66,0.25)]` accent glow on primary CTA
/// - Focus/disabled states matched 1-for-1
class AppButton extends StatefulWidget {
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

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  double get _height => switch (widget.size) {
        AppButtonSize.small => 36,
        AppButtonSize.regular => 44,
        AppButtonSize.large => 48,
      };

  double get _fontSize => switch (widget.size) {
        AppButtonSize.small => 12,
        AppButtonSize.regular => 13,
        AppButtonSize.large => 14,
      };

  double get _hPad => switch (widget.size) {
        AppButtonSize.small => 12,
        AppButtonSize.regular => 20,
        AppButtonSize.large => 24,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDisabled = widget.onPressed == null || widget.loading;

    final style = _resolveStyle(colors, isDisabled);

    final child = widget.loading
        ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(style.fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: _fontSize + 4, color: style.fg),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  style: AppTextStyles.buttonLabel.copyWith(
                    color: style.fg,
                    fontSize: _fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.trailingIcon != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(widget.trailingIcon, size: _fontSize + 4, color: style.fg),
              ],
            ],
          );

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: isDisabled ? null : (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1.0,
          duration: AppDurations.micro,
          curve: BNCurves.standard,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: _height,
              minWidth: widget.expand ? double.infinity : 44,
            ),
            child: AnimatedContainer(
              duration: AppDurations.micro,
              decoration: BoxDecoration(
                color: style.bg,
                borderRadius: AppRadius.mdAll,
                border: style.border != null
                    ? Border.all(color: style.border!, width: 1)
                    : null,
                boxShadow: style.shadow,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppRadius.mdAll,
                  onTap: isDisabled ? null : widget.onPressed,
                  splashColor: style.fg.withValues(alpha: 0.12),
                  highlightColor: style.fg.withValues(alpha: 0.06),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: _hPad),
                    child: Center(
                      widthFactor: widget.expand ? null : 1,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _ButtonStyleTokens _resolveStyle(dynamic colors, bool disabled) {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return _ButtonStyleTokens(
          bg: disabled ? colors.accent.withValues(alpha: 0.45) : colors.accent,
          fg: Colors.white,
          shadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: colors.accent.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
        );
      case AppButtonVariant.secondary:
        return _ButtonStyleTokens(
          bg: colors.accent.withValues(alpha: 0.08),
          fg: colors.accent,
          border: colors.accent.withValues(alpha: 0.4),
        );
      case AppButtonVariant.ghost:
        return _ButtonStyleTokens(
          bg: Colors.transparent,
          fg: disabled
              ? colors.textSecondary.withValues(alpha: 0.6)
              : colors.accent,
        );
      case AppButtonVariant.destructive:
        return _ButtonStyleTokens(
          bg: disabled ? colors.error.withValues(alpha: 0.5) : colors.error,
          fg: Colors.white,
          shadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: colors.error.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
        );
    }
  }
}

class _ButtonStyleTokens {
  _ButtonStyleTokens({
    required this.bg,
    required this.fg,
    this.border,
    this.shadow,
  });

  final Color bg;
  final Color fg;
  final Color? border;
  final List<BoxShadow>? shadow;
}
