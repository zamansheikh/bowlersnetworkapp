import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Floating action button that uses the **web's accent gradient** instead
/// of Flutter's flat primary color.
///
/// Flutter's [FloatingActionButton] ignores [ThemeData.extensions], so even
/// after wiring the gradient into [AppThemeColors] every FAB across the
/// app still rendered as a solid lime fill. This widget is the canonical
/// replacement — drop it in anywhere you'd otherwise use
/// `FloatingActionButton.extended` or `FloatingActionButton(...)`.
///
/// Visual contract matches the web's `.accent-gradient` Button:
///   • Linear left-to-right `accentFrom → accentTo`
///   • `0 4px 18px var(--accent-glow)` shadow
///   • Rounded 14px (FAB) / 10px (button), white label, w600
///   • Press scales to 0.97 (web uses 0.98 — slightly more haptic on touch)
class AppFab extends StatefulWidget {
  /// Extended FAB (icon + label) — the default Games-tab "New session" shape.
  const AppFab.extended({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
  })  : _circle = false,
        _child = null;

  /// Compact circular FAB — the icon-only floating button used by Messages.
  const AppFab.circle({
    super.key,
    required this.onPressed,
    required Widget child,
  })  : _circle = true,
        _child = child,
        icon = null,
        label = null;

  final VoidCallback? onPressed;
  final IconData? icon;
  final String? label;
  final bool _circle;
  final Widget? _child;

  @override
  State<AppFab> createState() => _AppFabState();
}

class _AppFabState extends State<AppFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final disabled = widget.onPressed == null;
    final radius = widget._circle ? 28.0 : 14.0;

    return Semantics(
      button: true,
      enabled: !disabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              gradient: disabled ? null : colors.accentGradient,
              color: disabled
                  ? colors.accent.withValues(alpha: 0.45)
                  : null,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: disabled
                  ? null
                  : [
                      BoxShadow(
                        color: colors.accentGlow,
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(radius),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onPressed,
                splashColor: Colors.white.withValues(alpha: 0.12),
                highlightColor: Colors.white.withValues(alpha: 0.06),
                child: widget._circle
                    ? SizedBox(
                        width: 56,
                        height: 56,
                        child: Center(
                          child: IconTheme(
                            data: const IconThemeData(
                              color: Colors.white,
                              size: 22,
                            ),
                            child: widget._child!,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.base,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.icon,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              widget.label!,
                              style: AppTextStyles.buttonLabel.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
