import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../bloc/auth_cubit.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: AppSpacing.lg,
            ),
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is Authenticated) {
                  context.go('/');
                } else if (state is AuthenticatedIncompleteProfile) {
                  context.go('/complete-profile');
                }
              },
              builder: (context, state) {
                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: AppSpacing.lg),

                      // Logo and Welcome
                      Column(
                        children: [
                          // App Logo
                          Container(
                            width: 80.0,
                            height: 80.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLG,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLG,
                              ),
                              child: Image.asset(
                                'assets/icon/icon.png',
                                width: 80.0,
                                height: 80.0,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text(
                            'Welcome Back!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              height: 1.38,
                              letterSpacing: 0.72,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Sign in to continue your bowling journey',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF596050) /* Black-700 */,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.0),

                      // Username Field
                      _buildTextField(
                        controller: _userCtrl,
                        label: 'Username',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),

                      // Password Field
                      _buildTextField(
                        controller: _passCtrl,
                        label: 'Password',
                        icon: Icons.lock_outline,
                        obscureText: _obscure,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.gray500,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 24.0),

                      // Sign In Button
                      if (state is AuthLoading)
                        Container(
                          height: 56.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.buttonRadius,
                            ),
                            gradient: AppColors.primaryGradient,
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2.w,
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 56.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.buttonRadius,
                            ),
                            gradient: AppColors.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowPrimary,
                                blurRadius: AppSpacing.elevationMD,
                                offset: Offset(0, 4.h),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthCubit>().signIn(
                                  _userCtrl.text.trim(),
                                  _passCtrl.text.trim(),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.buttonRadius,
                                ),
                              ),
                            ),
                            child: Text(
                              'Sign In',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),

                      SizedBox(height: 32.0),

                      // Error Message
                      if (state is AuthError)
                        Container(
                          padding: EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSM,
                            ),
                            border: Border.all(
                              color: AppColors.borderError,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppColors.error,
                                size: 20,
                              ),
                              SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  state.message,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(height: AppSpacing.md),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.gray600,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/signup'),
                            child: Text(
                              'Sign Up',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.primaryLimeGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: AppSpacing.lg),
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
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.gray800),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.gray600,
          ),
          prefixIcon: Icon(icon, color: AppColors.gray500, size: 20),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: const BorderSide(color: AppColors.border, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: const BorderSide(color: AppColors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: const BorderSide(
              color: AppColors.borderFocus,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: const BorderSide(
              color: AppColors.borderError,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            borderSide: const BorderSide(
              color: AppColors.borderError,
              width: 2,
            ),
          ),
          errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
        ),
        validator: validator,
      ),
    );
  }
}
