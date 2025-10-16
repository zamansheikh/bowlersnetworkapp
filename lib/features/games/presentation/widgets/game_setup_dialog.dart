import 'package:flutter/material.dart';

import '../../domain/entities/game_type.dart';
import '../../domain/entities/lane_condition.dart';
import '../../domain/entities/oil_pattern.dart';

class GameSetupData {
  final OilPattern oilPattern;
  final LaneCondition laneCondition;
  final GameType gameType;
  final String? laneNumber;

  GameSetupData({
    required this.oilPattern,
    required this.laneCondition,
    required this.gameType,
    this.laneNumber,
  });
}

class GameSetupDialog extends StatefulWidget {
  const GameSetupDialog({super.key});

  @override
  State<GameSetupDialog> createState() => _GameSetupDialogState();
}

class _GameSetupDialogState extends State<GameSetupDialog> {
  OilPattern _selectedOilPattern = OilPattern.house;
  LaneCondition _selectedLaneCondition = LaneCondition.medium;
  GameType _selectedGameType = GameType.practice;
  final TextEditingController _laneNumberController = TextEditingController();

  @override
  void dispose() {
    _laneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFAFAFA), Color(0xFFF5F5F5)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8BC342), Color(0xFF7AB233)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF8BC342,
                            ).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.settings_suggest,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Game Setup',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Configure your game environment',
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
                const SizedBox(height: 28),

                // Oil Pattern
                _buildSectionHeader(
                  '🛢️ Oil Pattern',
                  'How slick is the lane?',
                ),
                const SizedBox(height: 12),
                _buildOilPatternSelector(),
                const SizedBox(height: 24),

                // Lane Condition
                _buildSectionHeader(
                  '💧 Lane Condition',
                  'How wet is the lane?',
                ),
                const SizedBox(height: 12),
                _buildLaneConditionSelector(),
                const SizedBox(height: 24),

                // Game Type
                _buildSectionHeader('🎯 Game Type', 'What kind of game?'),
                const SizedBox(height: 12),
                _buildGameTypeSelector(),
                const SizedBox(height: 24),

                // Lane Number (Optional)
                _buildSectionHeader('🎳 Lane Number', 'Optional'),
                const SizedBox(height: 12),
                TextField(
                  controller: _laneNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g., 12 or Lane 5',
                    prefixIcon: const Icon(
                      Icons.pin_drop,
                      color: Color(0xFF8BC342),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF8BC342),
                        width: 2.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3F4F6),
                          foregroundColor: const Color(0xFF6B7280),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final data = GameSetupData(
                            oilPattern: _selectedOilPattern,
                            laneCondition: _selectedLaneCondition,
                            gameType: _selectedGameType,
                            laneNumber:
                                _laneNumberController.text.trim().isEmpty
                                ? null
                                : _laneNumberController.text.trim(),
                          );
                          Navigator.of(context).pop(data);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8BC342),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                          shadowColor: const Color(
                            0xFF8BC342,
                          ).withValues(alpha: 0.5),
                        ),
                        child: const Text(
                          '🎳 Start Game',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildOilPatternSelector() {
    return Column(
      children: OilPattern.values.map((pattern) {
        final isSelected = _selectedOilPattern == pattern;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => setState(() => _selectedOilPattern = pattern),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF8BC342).withValues(alpha: 0.12)
                    : const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF8BC342)
                      : const Color(0xFFE5E7EB),
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF8BC342).withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF8BC342)
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF9CA3AF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pattern.displayName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? const Color(0xFF8BC342)
                                : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          pattern.description,
                          style: const TextStyle(
                            fontSize: 12,
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
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLaneConditionSelector() {
    return Row(
      children: LaneCondition.values.map((condition) {
        final isSelected = _selectedLaneCondition == condition;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: condition != LaneCondition.values.last ? 10 : 0,
            ),
            child: InkWell(
              onTap: () => setState(() => _selectedLaneCondition = condition),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 18),
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
                        : const Color(0xFFE5E7EB),
                    width: isSelected ? 2.5 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF8BC342,
                            ).withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      condition.displayName.split(' ').first,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      condition.displayName.split(' ').last,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? Colors.white70
                            : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGameTypeSelector() {
    return Row(
      children: GameType.values.map((type) {
        final isSelected = _selectedGameType == type;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: type != GameType.values.last ? 10 : 0,
            ),
            child: InkWell(
              onTap: () => setState(() => _selectedGameType = type),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 18),
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
                        : const Color(0xFFE5E7EB),
                    width: isSelected ? 2.5 : 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF8BC342,
                            ).withValues(alpha: 0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  type.displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF111827),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
