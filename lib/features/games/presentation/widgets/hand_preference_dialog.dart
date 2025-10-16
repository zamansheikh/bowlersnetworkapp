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
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF8BC342).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.back_hand,
                size: 48,
                color: Color(0xFF8BC342),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome! 🎳',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Before you start scoring, let us know your bowling hand preference.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'I bowl with my:',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildHandOption(
                    HandPreference.left,
                    Icons.keyboard_arrow_left,
                    'Left Hand',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHandOption(
                    HandPreference.right,
                    Icons.keyboard_arrow_right,
                    'Right Hand',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You can change this later in settings',
              style: TextStyle(fontSize: 13, color: const Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandOption(
    HandPreference preference,
    IconData icon,
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8BC342).withValues(alpha: 0.1)
              : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8BC342)
                : const Color(0xFFE5E7EB),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF8BC342)
                  : const Color(0xFF6B7280),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF8BC342)
                    : const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
