import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../bloc/signup_cubit.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  final Map<String, String> signupData;

  const EmailVerificationPage({
    super.key,
    required this.email,
    required this.signupData,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _codeControllers = List.generate(6, (index) => TextEditingController());
  final _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isCodeSent = false;

  @override
  void initState() {
    super.initState();
    // Automatically send verification code when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendVerificationCode();
    });
  }

  @override
  void dispose() {
    for (final controller in _codeControllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _sendVerificationCode() {
    context.read<SignupCubit>().sendEmailVerification(widget.email);
  }

  void _verifyCode() {
    final code = _codeControllers.map((controller) => controller.text).join();
    if (code.length == 6) {
      context.read<SignupCubit>().verifyEmailCode(
        email: widget.email,
        code: code,
      );
    }
  }

  Future<void> _handleEmailVerified() async {
    // Use the birthday that was already provided during signup
    final birthDate = widget.signupData['birthDate'];

    if (birthDate != null && birthDate.isNotEmpty && mounted) {
      context.read<SignupCubit>().createUserAccount(
        username: widget.signupData['username']!,
        firstName: widget.signupData['firstName']!,
        lastName: widget.signupData['lastName']!,
        email: widget.email,
        password: widget.signupData['password']!,
        birthDate: birthDate,
      );
    } else {
      // Fallback: if no birthday provided, show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Birth date is required. Please go back and provide your birth date.',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _onCodeChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyCode();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: BlocConsumer<SignupCubit, SignupState>(
              listener: (context, state) {
                if (state is VerificationCodeSent) {
                  setState(() => _isCodeSent = true);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                } else if (state is EmailVerified) {
                  // Navigate to user creation with birth date
                  _handleEmailVerified();
                } else if (state is SignupLoginSuccess) {
                  // Navigate to home page after successful login
                  if (mounted) {
                    context.go('/');
                  }
                } else if (state is SignupLoginIncompleteProfile) {
                  // Navigate to profile completion page
                  if (mounted) {
                    context.go('/complete-profile');
                  }
                } else if (state is UserCreated) {
                  // This shouldn't happen anymore since we auto-login
                  if (mounted) {
                    context.go('/signin');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          'Account created successfully! Please log in.',
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                } else if (state is SignupError) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.gray,
                            ),
                            onPressed: () => context.go('/signup'),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Email Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryLimeGreen.withOpacity(
                                0.3,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.email_outlined,
                          size: 48,
                          color: AppColors.white,
                        ),
                      ),

                      const SizedBox(height: 32),

                      Text(
                        'Verify Your Email',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'We sent a 6-digit verification code to:',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: AppColors.gray),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLimeGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.email,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryLimeGreen,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // OTP Input Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return Container(
                            width: 50,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _codeControllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                fillColor: AppColors.white,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primaryLimeGreen,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isEmpty && index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                } else {
                                  _onCodeChanged(value, index);
                                }
                              },
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 48),

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
                      else ...[
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: AppColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryLimeGreen.withOpacity(
                                  0.4,
                                ),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _verifyCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Verify Code',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Didn't receive the code? ",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.gray),
                            ),
                            TextButton(
                              onPressed: _isCodeSent
                                  ? _sendVerificationCode
                                  : null,
                              child: Text(
                                'Resend',
                                style: TextStyle(
                                  color: _isCodeSent
                                      ? AppColors.primaryLimeGreen
                                      : AppColors.gray,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
}
