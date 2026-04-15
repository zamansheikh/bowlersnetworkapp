import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Styled text field matching the web frontend's Input.tsx exactly:
/// - `h-11` (44dp) default, `h-12` (48dp) with [large]
/// - `rounded-[10px]` corners
/// - `text-[14px]` input, `text-[11px] uppercase tracking-[0.04em]` label
/// - Focus: 3px accent-glow spread shadow + accent border
/// - Error: red border + single error line below (no reserved space unless
///   there's an actual error — web parity)
///
/// Important: the field renders its own error label OUTSIDE of
/// TextFormField's built-in errorText, so neighbouring fields in a Row stay
/// vertically aligned regardless of error line-count.
class AppInput extends StatefulWidget {
  const AppInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.helper,
    this.prefixIcon,
    this.suffixIcon,
    this.trailing,
    this.onChanged,
    this.onSubmitted,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.validator,
    this.focusNode,
    this.large = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helper;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  /// A trailing widget rendered INSIDE the field on the right. Unlike
  /// [suffixIcon] this won't be padded like an icon — use for live status
  /// indicators (e.g. a green check when a username format is valid).
  final Widget? trailing;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool autofocus;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  /// Larger variant (h-12) for hero/login fields.
  final bool large;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (_isFocused != _focusNode.hasFocus) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final isSingleLine = widget.maxLines == 1;
    final height = widget.large ? 48.0 : 44.0;

    final borderColor = hasError
        ? colors.error
        : (_isFocused ? colors.accent : colors.borderStrong);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!.toUpperCase(),
            style: AppTextStyles.label.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: AppDurations.micro,
          curve: BNCurves.standard,
          height: isSingleLine ? height : null,
          decoration: BoxDecoration(
            color: colors.bgSurface,
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: borderColor, width: 1),
            boxShadow: _isFocused && !hasError
                ? [
                    BoxShadow(
                      color: colors.accentGlow,
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : hasError && _isFocused
                    ? [
                        BoxShadow(
                          color: colors.error.withValues(alpha: 0.15),
                          blurRadius: 0,
                          spreadRadius: 3,
                        ),
                      ]
                    : null,
          ),
          child: Row(
            crossAxisAlignment: isSingleLine
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              if (widget.prefixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 14, right: 8),
                  child: widget.prefixIcon,
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: widget.prefixIcon == null ? 14 : 0,
                    right: (widget.suffixIcon == null && widget.trailing == null)
                        ? 14
                        : 0,
                    top: isSingleLine ? 0 : 12,
                    bottom: isSingleLine ? 0 : 12,
                  ),
                  child: TextFormField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    autofocus: widget.autofocus,
                    obscureText: widget.obscure,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    onChanged: widget.onChanged,
                    onFieldSubmitted: widget.onSubmitted,
                    validator: widget.validator,
                    maxLines: widget.obscure ? 1 : widget.maxLines,
                    minLines: widget.minLines,
                    maxLength: widget.maxLength,
                    inputFormatters: widget.inputFormatters,
                    style: AppTextStyles.body.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    cursorColor: colors.accent,
                    cursorWidth: 1.5,
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: AppTextStyles.body.copyWith(
                        color: colors.textTertiary,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      counterText: '',
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      // Suppress built-in error rendering — we show it below.
                      errorStyle: const TextStyle(
                        fontSize: 0,
                        height: 0,
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.trailing != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: widget.trailing,
                ),
              if (widget.suffixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: widget.suffixIcon,
                ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: AppTextStyles.secondary.copyWith(color: colors.error),
          ),
        ] else if (widget.helper != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.helper!,
            style: AppTextStyles.secondary.copyWith(color: colors.textTertiary),
          ),
        ],
      ],
    );
  }
}
