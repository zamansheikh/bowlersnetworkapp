import 'package:flutter/material.dart';

class CircularIconButton extends StatelessWidget {
  const CircularIconButton({super.key, 
    required this.icon,
    required this.onTap,
    this.isEnabled = true,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final effectiveBackground = isEnabled
        ? Colors.white
        : const Color(0xFFF3F4F6);
    final effectiveBorder = isEnabled
        ? const Color(0xFF8BC342)
        : const Color(0xFFD1D5DB);
    final effectiveIcon = isEnabled
        ? const Color(0xFF8BC342)
        : const Color(0xFF9CA3AF);

    final shadows = isEnabled
        ? [
            BoxShadow(
              color: const Color(0xFF8BC342).withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
        : <BoxShadow>[];

    return IgnorePointer(
      ignoring: !isEnabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isEnabled ? 1 : 0.45,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: effectiveBackground,
              shape: BoxShape.circle,
              border: Border.all(color: effectiveBorder, width: 2),
              boxShadow: shadows,
            ),
            child: Icon(icon, color: effectiveIcon, size: 22),
          ),
        ),
      ),
    );
  }
}
