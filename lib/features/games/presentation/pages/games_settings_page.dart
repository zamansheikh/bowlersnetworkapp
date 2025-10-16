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
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8BC342),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Game Settings ⚙️',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('👤 Player Settings'),
          const SizedBox(height: 14),
          _buildHandPreferenceCard(),
          const SizedBox(height: 28),
          _buildSectionHeader('🎯 Pin Deck Settings'),
          const SizedBox(height: 14),
          _buildPinDefaultCard(),
          const SizedBox(height: 28),
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
          fontWeight: FontWeight.w800,
          color: Color(0xFF374151),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildHandPreferenceCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFAFAFA), Color(0xFFF5F5F5)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8BC342), Color(0xFF7AB233)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8BC342).withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.back_hand,
                    color: Colors.white,
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
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Choose your dominant hand',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildHandOption(HandPreference.left, '👈', 'Left'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHandOption(HandPreference.right, '👉', 'Right'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHandOption(
    HandPreference preference,
    String emoji,
    String label,
  ) {
    final isSelected = _handPreference == preference;

    return GestureDetector(
      onTap: () => _updateHandPreference(preference),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF8BC342), Color(0xFF7AB233)],
                )
              : null,
          color: isSelected ? null : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8BC342)
                : Colors.grey.withValues(alpha: 0.1),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF8BC342).withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
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
        gradient: const LinearGradient(
          colors: [Color(0xFFFAFAFA), Color(0xFFF5F5F5)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_pin,
                color: Colors.white,
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
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pins knocked down by default',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _pinsKnockedByDefault,
              onChanged: _updatePinDefault,
              activeColor: const Color(0xFF8BC342),
              activeTrackColor: const Color(0xFF8BC342).withValues(alpha: 0.3),
              inactiveTrackColor: Colors.grey.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFECF9FF).withValues(alpha: 0.6),
            const Color(0xFFE0F2FE).withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF0284C7).withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Color(0xFF0284C7),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About Settings 💡',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0C4A6E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'These settings will be applied to all new games you create. Existing games will retain their original settings.',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF0C4A6E).withValues(alpha: 0.8),
                    height: 1.6,
                    fontWeight: FontWeight.w500,
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
