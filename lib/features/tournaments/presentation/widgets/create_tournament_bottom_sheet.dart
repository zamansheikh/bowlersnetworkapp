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
  State<CreateTournamentBottomSheet> createState() => _CreateTournamentBottomSheetState();
}

class _CreateTournamentBottomSheetState extends State<CreateTournamentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _regFeeController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _regDeadline;
  String _selectedFormat = 'Singles';
  String _selectedAccessType = 'Open';
  int _participantsCount = 1;
  bool _isCreating = false;

  final List<String> _formats = ['Singles', 'Doubles', 'Teams'];
  final List<String> _accessTypes = ['Open', 'Invite Only', 'Premium'];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _regFeeController.dispose();
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
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

              // Access Type
              Text(
                'Access Type',
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
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
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
                      color: isSelected ? AppColors.white.withValues(alpha: 0.8) : AppColors.gray500,
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
                value != null 
                    ? DateFormat('MMM dd, yyyy').format(value) 
                    : hint,
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
        return DropdownMenuItem(
          value: type,
          child: Text(type),
        );
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
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primaryLimeGreen,
            ),
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
}