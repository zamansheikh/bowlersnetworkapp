import 'package:flutter/material.dart';
import '../../domain/entities/hand_preference.dart';

class HandPreferenceDialog extends StatefulWidget {
  const HandPreferenceDialog({super.key});

  @override
  State<HandPreferenceDialog> createState() => _HandPreferenceDialogState();
}

class _HandPreferenceDialogState extends State<HandPreferenceDialog> {
  HandPreference _selectedPreference = HandPreference.right;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFAFAFA), Color(0xFFF5F5F5)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 40,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated welcome icon
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8BC342), Color(0xFF7AB233)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8BC342).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.back_hand,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 28),

              // Welcome text
              const Text(
                'Welcome to Bowling! 🎳',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              const Text(
                'Tell us your bowling hand so we can personalize your experience',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              // Hand preference label
              const Text(
                'I bowl with my:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 18),

              // Hand options
              Row(
                children: [
                  Expanded(
                    child: _buildHandOption(
                      HandPreference.left,
                      '👈',
                      'Left Hand',
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildHandOption(
                      HandPreference.right,
                      '👉',
                      'Right Hand',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(_selectedPreference);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8BC342),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    shadowColor: const Color(0xFF8BC342).withValues(alpha: 0.4),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Help text
              const Text(
                '💡 You can change this later in settings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandOption(
    HandPreference preference,
    String emoji,
    String label,
  ) {
    final isSelected = _selectedPreference == preference;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPreference = preference;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF8BC342), Color(0xFF7AB233)],
                )
              : null,
          color: isSelected ? null : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8BC342)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF8BC342).withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF111827),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 6),
              Text(
                'Selected',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
