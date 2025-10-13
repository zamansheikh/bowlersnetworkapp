import 'package:flutter/material.dart';

class ShortcutButton extends StatelessWidget {
  const ShortcutButton({
    super.key,
    required this.label,
    required this.textColor,
    required this.borderColor,
    required this.onTap,
    this.backgroundColor,
  });

  final String label;
  final Color textColor;
  final Color borderColor;
  final Color? backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          height: 54,
          child: OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              backgroundColor: backgroundColor ?? Colors.white,
              side: BorderSide(color: borderColor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
