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

  // Address autocomplete
  List<Map<String, dynamic>> _addressSuggestions = [];
  bool _showSuggestions = false;
  String? _selectedLat;
  String? _selectedLong;
  final _addressFocusNode = FocusNode();

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
    _addressFocusNode.dispose();
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

              // Address with Autocomplete
              Text(
                'Address *',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray800,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Column(
                children: [
                  TextFormField(
                    controller: _addressController,
                    focusNode: _addressFocusNode,
                    maxLines: 2,
                    decoration: _buildInputDecoration(
                      'Enter tournament address',
                    ),
                    onChanged: _onAddressChanged,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Address is required';
                      }
                      return null;
                    },
                  ),
                  if (_showSuggestions && _addressSuggestions.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.gray300),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _addressSuggestions.length,
                        itemBuilder: (context, index) {
                          final suggestion = _addressSuggestions[index];
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.location_on,
                              color: AppColors.gray500,
                              size: 16,
                            ),
                            title: Text(
                              suggestion['description'] ?? '',
                              style: AppTextStyles.bodySmall,
                            ),
                            onTap: () => _selectAddress(suggestion),
                          );
                        },
                      ),
                    ),
                ],
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

              // Average Field (only for Handicap)
              if (_selectedTournamentType == 'Handicap') ...[
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
                    if (_selectedTournamentType == 'Handicap') {
                      if (value?.isEmpty ?? true) {
                        return 'Average is required for Handicap tournaments';
                      }
                      final average = double.tryParse(value!);
                      if (average == null || average < 0 || average > 300) {
                        return 'Enter a valid average (0-300)';
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: AppSpacing.md),
              ],

              // Percentage Field (for both Handicap and Scratch)
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
                  if (value?.isEmpty ?? true) {
                    return 'Percentage is required';
                  }
                  final percentage = double.tryParse(value!);
                  if (percentage == null ||
                      percentage < 0 ||
                      percentage > 100) {
                    return 'Enter a valid percentage (0-100)';
                  }
                  return null;
                },
              ),

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
      initialValue: _selectedAccessType,
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
      // Prepare average and percentage based on tournament type
      double? average;
      double? percentage;

      if (_selectedTournamentType == 'Handicap') {
        // Handicap: both average and percentage are required
        average = _averageController.text.isNotEmpty
            ? double.tryParse(_averageController.text)
            : null;
        percentage = _percentageController.text.isNotEmpty
            ? double.tryParse(_percentageController.text)
            : null;
      } else {
        // Scratch: only percentage is required
        average = null;
        percentage = _percentageController.text.isNotEmpty
            ? double.tryParse(_percentageController.text)
            : null;
      }

      await context.read<TournamentCubit>().createNewTournament(
        name: _nameController.text.trim(),
        startDate: _startDate!.toIso8601String(),
        regDeadline: _regDeadline!.toIso8601String(),
        regFee: _regFeeController.text.trim(),
        address: _addressController.text.trim(),
        lat: _selectedLat, // Use selected coordinates from address autocomplete
        long:
            _selectedLong, // Use selected coordinates from address autocomplete
        format: _selectedFormat,
        participantsCount: _participantsCount,
        accessType: _selectedAccessType,
        tournamentType: _selectedTournamentType,
        average: average,
        percentage: percentage,
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
              margin: EdgeInsets.only(
                right: type == _tournamentTypes.last ? 0 : 8.w,
              ),
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryLimeGreen.withValues(alpha: 0.1)
                    : AppColors.gray50,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryLimeGreen
                      : AppColors.gray200,
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
                      color: isSelected
                          ? AppColors.primaryLimeGreen
                          : AppColors.gray700,
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
        return 'Uses average and handicap system with percentage';
      case 'Scratch':
        return 'Uses average system only';
      default:
        return '';
    }
  }

  void _selectTournamentType(String type) {
    setState(() {
      _selectedTournamentType = type;
      // Clear fields when switching tournament types
      if (type == 'Scratch') {
        _averageController.clear(); // Clear average for Scratch
      } else {
        // Handicap - keep both fields
      }
    });
  }

  void _onAddressChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _addressSuggestions.clear();
      });
      return;
    }

    // Simulate address suggestions (replace with actual API call)
    setState(() {
      _showSuggestions = true;
      _addressSuggestions =
          [
                {
                  'description': 'New York, NY, USA',
                  'lat': '40.7128',
                  'long': '-74.0060',
                },
                {
                  'description': 'Los Angeles, CA, USA',
                  'lat': '34.0522',
                  'long': '-118.2437',
                },
                {
                  'description': 'Chicago, IL, USA',
                  'lat': '41.8781',
                  'long': '-87.6298',
                },
                {
                  'description': 'Houston, TX, USA',
                  'lat': '29.7604',
                  'long': '-95.3698',
                },
                {
                  'description': 'Phoenix, AZ, USA',
                  'lat': '33.4484',
                  'long': '-112.0740',
                },
              ]
              .where(
                (suggestion) => suggestion['description']!
                    .toLowerCase()
                    .contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  void _selectAddress(Map<String, dynamic> suggestion) {
    setState(() {
      _addressController.text = suggestion['description'] ?? '';
      _selectedLat = suggestion['lat'];
      _selectedLong = suggestion['long'];
      _showSuggestions = false;
      _addressSuggestions.clear();
    });
    _addressFocusNode.unfocus();
  }
}
