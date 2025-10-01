import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../bloc/tournament_cubit.dart';

class CreateTournamentBottomSheet extends StatefulWidget {
  const CreateTournamentBottomSheet({super.key});

  @override
  State<CreateTournamentBottomSheet> createState() =>
      _CreateTournamentBottomSheetState();
}

class _CreateTournamentBottomSheetState
    extends State<CreateTournamentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _regFeeController = TextEditingController();
  final _averageController = TextEditingController();
  final _percentageController = TextEditingController();

  DateTime? _startDate;
  DateTime? _regDeadline;
  String _selectedFormat = 'Singles';
  String _selectedAccessType = 'Open';
  String _selectedTournamentType = 'Handicap';
  int _participantsCount = 1;
  bool _isCreating = false;

  final List<String> _formats = ['Singles', 'Doubles', 'Teams'];
  final List<String> _accessTypes = ['Open', 'Invitational'];
  final List<String> _tournamentTypes = ['Handicap', 'Scratch'];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _regFeeController.dispose();
    _averageController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              SizedBox(height: AppSpacing.md),

              // Header
              Text(
                'Create Tournament',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray900,
                ),
              ),

              SizedBox(height: AppSpacing.lg),

              // Tournament Name
              Text(
                'Tournament Name *',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray800,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration('Enter tournament name'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Tournament name is required';
                  }
                  return null;
                },
              ),

              SizedBox(height: AppSpacing.md),

              // Format Selection
              Text(
                'Format *',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray800,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              _buildFormatSelection(),

              SizedBox(height: AppSpacing.md),

              // Date Fields Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Date *',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray800,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        _buildDateField(
                          value: _startDate,
                          onTap: () => _selectDate(true),
                          hint: 'Select date',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Registration Deadline *',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray800,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        _buildDateField(
                          value: _regDeadline,
                          onTap: () => _selectDate(false),
                          hint: 'Select date',
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.md),

              // Registration Fee
              Text(
                'Registration Fee (\$) *',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray800,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _regFeeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _buildInputDecoration('0.00'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Registration fee is required';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),

              SizedBox(height: AppSpacing.md),

              // Address
              Text(
                'Address *',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray800,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: _buildInputDecoration('Enter tournament address'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Address is required';
                  }
                  return null;
                },
              ),

              SizedBox(height: AppSpacing.md),

              // Tournament Type
              Text(
                'Tournament Type *',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray800,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              _buildTournamentTypeSelection(),

              SizedBox(height: AppSpacing.md),

              // Average Field (for both types)
              Text(
                'Average *',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray800,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              TextFormField(
                controller: _averageController,
                keyboardType: TextInputType.number,
                decoration: _buildInputDecoration('Enter average score'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Average is required';
                  }
                  final average = double.tryParse(value!);
                  if (average == null || average < 0 || average > 300) {
                    return 'Enter a valid average (0-300)';
                  }
                  return null;
                },
              ),

              // Percentage Field (only for Scratch)
              if (_selectedTournamentType == 'Scratch') ...[
                SizedBox(height: AppSpacing.md),
                Text(
                  'Percentage *',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray800,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _percentageController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration('Enter percentage'),
                  validator: (value) {
                    if (_selectedTournamentType == 'Scratch') {
                      if (value?.isEmpty ?? true) {
                        return 'Percentage is required for Scratch tournaments';
                      }
                      final percentage = double.tryParse(value!);
                      if (percentage == null || percentage < 0 || percentage > 100) {
                        return 'Enter a valid percentage (0-100)';
                      }
                    }
                    return null;
                  },
                ),
              ],

              SizedBox(height: AppSpacing.md),

              // Access Type
              Text(
                'Access Type *',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray800,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              _buildAccessTypeDropdown(),

              SizedBox(height: AppSpacing.xl),

              // Create Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _createTournament,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLimeGreen,
                    disabledBackgroundColor: AppColors.gray300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isCreating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Create Tournament',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray500),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gray300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryLimeGreen),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    );
  }

  Widget _buildFormatSelection() {
    return Row(
      children: _formats.map((format) {
        final isSelected = _selectedFormat == format;

        return Expanded(
          child: GestureDetector(
            onTap: () => _selectFormat(format),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryLimeGreen
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryLimeGreen
                      : AppColors.gray300,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    format,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? AppColors.white : AppColors.gray700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    _getFormatDescription(format),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? AppColors.white.withValues(alpha: 0.8)
                          : AppColors.gray500,
                      fontSize: 10.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateField({
    required DateTime? value,
    required VoidCallback onTap,
    required String hint,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value != null ? DateFormat('MMM dd, yyyy').format(value) : hint,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: value != null ? AppColors.gray900 : AppColors.gray500,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today,
              size: 20,
              color: AppColors.gray500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedAccessType,
      decoration: _buildInputDecoration('Select access type'),
      items: _accessTypes.map((type) {
        return DropdownMenuItem(value: type, child: Text(type));
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedAccessType = value;
          });
        }
      },
    );
  }

  String _getFormatDescription(String format) {
    switch (format) {
      case 'Singles':
        return '1 player';
      case 'Doubles':
        return '2 players';
      case 'Teams':
        return '10 players';
      default:
        return '';
    }
  }

  void _selectFormat(String format) {
    setState(() {
      _selectedFormat = format;

      // Update participants count based on format
      switch (format) {
        case 'Singles':
          _participantsCount = 1;
          break;
        case 'Doubles':
          _participantsCount = 2;
          break;
        case 'Teams':
          _participantsCount = 10;
          break;
      }
    });
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primaryLimeGreen),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _regDeadline = picked;
        }
      });
    }
  }

  Future<void> _createTournament() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_startDate == null || _regDeadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start date and registration deadline'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_regDeadline!.isAfter(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration deadline must be before start date'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      await context.read<TournamentCubit>().createNewTournament(
        name: _nameController.text.trim(),
        startDate: _startDate!.toIso8601String(),
        regDeadline: _regDeadline!.toIso8601String(),
        regFee: _regFeeController.text.trim(),
        address: _addressController.text.trim(),
        format: _selectedFormat,
        participantsCount: _participantsCount,
        accessType: _selectedAccessType,
        tournamentType: _selectedTournamentType,
        average: _averageController.text.isNotEmpty 
            ? double.tryParse(_averageController.text) 
            : null,
        percentage: _selectedTournamentType == 'Scratch' && _percentageController.text.isNotEmpty 
            ? double.tryParse(_percentageController.text) 
            : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tournament created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create tournament: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Widget _buildTournamentTypeSelection() {
    return Row(
      children: _tournamentTypes.map((type) {
        final isSelected = _selectedTournamentType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () => _selectTournamentType(type),
            child: Container(
              margin: EdgeInsets.only(right: type == _tournamentTypes.last ? 0 : 8.w),
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryLimeGreen.withOpacity(0.1) : AppColors.gray50,
                border: Border.all(
                  color: isSelected ? AppColors.primaryLimeGreen : AppColors.gray200,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primaryLimeGreen : AppColors.gray700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _getTournamentTypeDescription(type),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray600,
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

  String _getTournamentTypeDescription(String type) {
    switch (type) {
      case 'Handicap':
        return 'Uses average and handicap system';
      case 'Scratch':
        return 'Uses average and percentage system';
      default:
        return '';
    }
  }

  void _selectTournamentType(String type) {
    setState(() {
      _selectedTournamentType = type;
      // Clear percentage when switching from Scratch to Handicap
      if (type == 'Handicap') {
        _percentageController.clear();
      }
    });
  }
}
