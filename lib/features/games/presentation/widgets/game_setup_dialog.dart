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
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8BC342).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.settings_suggest,
                      size: 28,
                      color: Color(0xFF8BC342),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Game Setup',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Set up your bowling environment for better analytics',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Oil Pattern
              _buildSectionLabel('Oil Pattern'),
              const SizedBox(height: 8),
              _buildOilPatternSelector(),
              const SizedBox(height: 20),

              // Lane Condition
              _buildSectionLabel('Lane Condition'),
              const SizedBox(height: 8),
              _buildLaneConditionSelector(),
              const SizedBox(height: 20),

              // Game Type
              _buildSectionLabel('Game Type'),
              const SizedBox(height: 8),
              _buildGameTypeSelector(),
              const SizedBox(height: 20),

              // Lane Number (Optional)
              _buildSectionLabel('Lane Number (Optional)'),
              const SizedBox(height: 8),
              TextField(
                controller: _laneNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g., 12',
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF8BC342),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
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
                          laneNumber: _laneNumberController.text.trim().isEmpty
                              ? null
                              : _laneNumberController.text.trim(),
                        );
                        Navigator.of(context).pop(data);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8BC342),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Start Game',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _buildOilPatternSelector() {
    return Column(
      children: OilPattern.values.map((pattern) {
        final isSelected = _selectedOilPattern == pattern;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => setState(() => _selectedOilPattern = pattern),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF8BC342).withValues(alpha: 0.1)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF8BC342)
                      : const Color(0xFFE5E7EB),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? const Color(0xFF8BC342)
                        : const Color(0xFF9CA3AF),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pattern.displayName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFF8BC342)
                                : const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pattern.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
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
              right: condition != LaneCondition.values.last ? 8 : 0,
            ),
            child: InkWell(
              onTap: () => setState(() => _selectedLaneCondition = condition),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF8BC342)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF8BC342)
                        : const Color(0xFFE5E7EB),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      condition.displayName.split(' ').first,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      condition.displayName.split(' ').last,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? Colors.white70
                            : const Color(0xFF6B7280),
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
              right: type != GameType.values.last ? 12 : 0,
            ),
            child: InkWell(
              onTap: () => setState(() => _selectedGameType = type),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF8BC342)
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF8BC342)
                        : const Color(0xFFE5E7EB),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  type.displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
