import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../bloc/signup_cubit.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();

  // Parent information controllers
  final _parentFirstNameCtrl = TextEditingController();
  final _parentLastNameCtrl = TextEditingController();
  final _parentEmailCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isUSBCYouthBowler = false;
  bool _isUSBCYouthCoach = false;
  DateTime? _selectedBirthDate;

  // Age validation states
  bool get _isUnder13 {
    if (_selectedBirthDate == null) return false;
    final age = DateTime.now().difference(_selectedBirthDate!).inDays / 365.25;
    return age < 13;
  }

  bool get _isMinor {
    if (_selectedBirthDate == null) return false;
    final age = DateTime.now().difference(_selectedBirthDate!).inDays / 365.25;
    return age >= 13 && age < 18;
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _birthDateCtrl.dispose();
    _parentFirstNameCtrl.dispose();
    _parentLastNameCtrl.dispose();
    _parentEmailCtrl.dispose();
    super.dispose();
  }

  void _validateSignupData() {
    if (_isUnder13) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You must be at least 13 years old to create an account.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      context.read<SignupCubit>().validateData(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: BlocConsumer<SignupCubit, SignupState>(
              listener: (context, state) {
                if (state is SignupDataValid) {
                  // Navigate to email verification
                  context.go(
                    '/signup/email-verification',
                    extra: {
                      'email': _emailCtrl.text.trim(),
                      'firstName': _firstNameCtrl.text.trim(),
                      'lastName': _lastNameCtrl.text.trim(),
                      'username': _usernameCtrl.text.trim(),
                      'password': _passwordCtrl.text.trim(),
                      'birthDate': _birthDateCtrl.text.trim(),
                    },
                  );
                } else if (state is SignupError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                return Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),

                      // Header
                      Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryLimeGreen.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_add,
                              size: 36,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Create Account',
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join the bowling community today',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColors.gray),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // First Name
                      _buildTextField(
                        controller: _firstNameCtrl,
                        label: 'First Name',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Last Name
                      _buildTextField(
                        controller: _lastNameCtrl,
                        label: 'Last Name',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Username
                      _buildTextField(
                        controller: _usernameCtrl,
                        label: 'Username',
                        icon: Icons.alternate_email,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a username';
                          }
                          if (value.trim().length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Email
                      _buildTextField(
                        controller: _emailCtrl,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value.trim())) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Password
                      _buildTextField(
                        controller: _passwordCtrl,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.trim().length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Birth Date
                      GestureDetector(
                        onTap: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().subtract(
                              const Duration(days: 18 * 365),
                            ),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: Theme.of(context).colorScheme
                                      .copyWith(
                                        primary: AppColors.primaryLimeGreen,
                                        surface: AppColors.white,
                                      ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (selectedDate != null) {
                            setState(() {
                              _selectedBirthDate = selectedDate;
                              _birthDateCtrl.text =
                                  '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _birthDateCtrl,
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'Birth Date',
                              prefixIcon: const Icon(Icons.calendar_today),
                              fillColor: AppColors.white,
                              suffixIcon: const Icon(Icons.arrow_drop_down),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please select your birth date';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Age restriction warnings and parent information
                      if (_isUnder13) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.error,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Age Restriction',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.error,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'You must be at least 13 years old to create an account on this platform.',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (_isMinor) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.family_restroom,
                                    color: Colors.blue.shade700,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Parent/Guardian Information Required',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Since you are under 18, we need your parent or guardian\'s information for account verification and safety purposes.',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Parent's information section
                        Text(
                          'Parent\'s Information',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                        ),

                        const SizedBox(height: 16),

                        // Parent's First and Last Name
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _parentFirstNameCtrl,
                                label: 'Parent\'s First Name',
                                icon: Icons.person_outline,
                                validator: (value) {
                                  if (_isMinor &&
                                      (value == null || value.trim().isEmpty)) {
                                    return 'Parent\'s first name is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                controller: _parentLastNameCtrl,
                                label: 'Parent\'s Last Name',
                                icon: Icons.person_outline,
                                validator: (value) {
                                  if (_isMinor &&
                                      (value == null || value.trim().isEmpty)) {
                                    return 'Parent\'s last name is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Parent's Email
                        _buildTextField(
                          controller: _parentEmailCtrl,
                          label: 'Parent\'s Email Address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (_isMinor) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Parent\'s email is required';
                              }
                              final emailRegExp = RegExp(
                                r'^[\w\.-]+@[\w\.-]+\.\w+$',
                              );
                              if (!emailRegExp.hasMatch(value.trim())) {
                                return 'Please enter a valid email address';
                              }
                            }
                            return null;
                          },
                        ),
                      ],

                      // USBC Youth Bowler checkbox (for 13-18 year olds)
                      if (_isMinor) ...[
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _isUSBCYouthBowler
                                  ? AppColors.primaryLimeGreen
                                  : AppColors.outline,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CheckboxListTile(
                            value: _isUSBCYouthBowler,
                            onChanged: (value) {
                              setState(() {
                                _isUSBCYouthBowler = value ?? false;
                              });
                            },
                            title: const Text(
                              'I am a USBC youth bowler',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: const Text(
                              'Optional - Check if you participate in USBC youth programs',
                              style: TextStyle(fontSize: 12),
                            ),
                            activeColor: AppColors.primaryLimeGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],

                      // USBC Youth Coach checkbox (for all ages)
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isUSBCYouthCoach
                                ? AppColors.primaryLimeGreen
                                : AppColors.outline,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CheckboxListTile(
                          value: _isUSBCYouthCoach,
                          onChanged: (value) {
                            setState(() {
                              _isUSBCYouthCoach = value ?? false;
                            });
                          },
                          title: const Text(
                            'I am a USBC youth coach',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: const Text(
                            'Optional - Check if you coach youth bowling programs',
                            style: TextStyle(fontSize: 12),
                          ),
                          activeColor: AppColors.primaryLimeGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Validation errors
                      if (state is SignupDataInvalid) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Please fix the following errors:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...state.errors.map(
                                (error) => Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    bottom: 4,
                                  ),
                                  child: Text(
                                    '• $error',
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Submit button
                      if (state is SignupLoading)
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: AppColors.primaryGradient,
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: _isUnder13
                                ? LinearGradient(
                                    colors: [AppColors.gray, AppColors.gray],
                                  )
                                : AppColors.primaryGradient,
                            boxShadow: _isUnder13
                                ? []
                                : [
                                    BoxShadow(
                                      color: AppColors.primaryLimeGreen
                                          .withValues(alpha: 0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isUnder13 ? null : _validateSignupData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              _isUnder13
                                  ? 'Age Requirement Not Met'
                                  : 'Continue',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _isUnder13
                                    ? AppColors.gray
                                    : AppColors.white,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.gray),
                          ),
                          TextButton(
                            onPressed: () => context.go('/signin'),
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: AppColors.primaryLimeGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          fillColor: AppColors.white,
          suffixIcon: suffixIcon,
        ),
        validator: validator,
      ),
    );
  }
}
