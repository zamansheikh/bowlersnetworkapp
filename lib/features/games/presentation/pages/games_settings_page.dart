import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/hand_preference.dart';
import '../../domain/services/game_settings_service.dart';
import '../../domain/services/pin_settings_service.dart';

class GamesSettingsPage extends StatefulWidget {
  const GamesSettingsPage({super.key});

  @override
  State<GamesSettingsPage> createState() => _GamesSettingsPageState();
}

class _GamesSettingsPageState extends State<GamesSettingsPage> {
  final _gameSettingsService = getIt<GameSettingsService>();
  final _pinSettingsService = getIt<PinSettingsService>();

  late HandPreference _handPreference;
  late bool _pinsKnockedByDefault;

  @override
  void initState() {
    super.initState();
    _handPreference = _gameSettingsService.defaultHandPreference;
    _pinsKnockedByDefault = _pinSettingsService.pinsKnockedByDefault;
  }

  Future<void> _updateHandPreference(HandPreference preference) async {
    await _gameSettingsService.setDefaultHandPreference(preference);
    setState(() {
      _handPreference = preference;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hand preference updated to ${preference.displayName}'),
          backgroundColor: const Color(0xFF8BC342),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _updatePinDefault(bool value) async {
    await _pinSettingsService.setPinsKnockedByDefault(value);
    setState(() {
      _pinsKnockedByDefault = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF212121)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Game Settings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Player Settings'),
          const SizedBox(height: 12),
          _buildHandPreferenceCard(),
          const SizedBox(height: 24),
          _buildSectionHeader('Pin Deck Settings'),
          const SizedBox(height: 12),
          _buildPinDefaultCard(),
          const SizedBox(height: 24),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6B7280),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildHandPreferenceCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8BC342).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.back_hand,
                    color: Color(0xFF8BC342),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hand Preference',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Choose your dominant hand',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildHandOption(
                    HandPreference.left,
                    Icons.keyboard_arrow_left,
                    'Left',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHandOption(
                    HandPreference.right,
                    Icons.keyboard_arrow_right,
                    'Right',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandOption(
    HandPreference preference,
    IconData icon,
    String label,
  ) {
    final isSelected = _handPreference == preference;

    return GestureDetector(
      onTap: () => _updateHandPreference(preference),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8BC342) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8BC342)
                : const Color(0xFFE5E7EB),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDefaultCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF8BC342).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.location_pin,
                color: Color(0xFF8BC342),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Default Pin State',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pins knocked down by default',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            Switch(
              value: _pinsKnockedByDefault,
              onChanged: _updatePinDefault,
              activeColor: const Color(0xFF8BC342),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF0284C7), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About Settings',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0C4A6E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'These settings will be applied to all new games you create. Existing games will retain their original settings.',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF0C4A6E).withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
