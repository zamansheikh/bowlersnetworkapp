import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';

/// Modern, clean theme configuration inspired by minimal design principles
/// Primary color: Lime Green (#8BC342)
/// Design approach: Clean, accessible, modern with card-based layouts
class AppTheme {
  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      // ========== BASIC THEME CONFIGURATION ==========
      useMaterial3: true,
      brightness: Brightness.light,

      // ========== COLOR SCHEME ==========
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryLimeGreen,
        brightness: Brightness.light,
        primary: AppColors.primaryLimeGreen,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.gray600,
        onSecondary: AppColors.white,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
        onError: AppColors.white,
        outline: AppColors.border,
        outlineVariant: AppColors.borderLight,
      ),

      // ========== TYPOGRAPHY ==========
      textTheme: TextTheme(
        // Display styles
        displayLarge: AppTextStyles.displayLarge.copyWith(
          color: AppColors.gray900,
        ),
        displayMedium: AppTextStyles.displayMedium.copyWith(
          color: AppColors.gray900,
        ),
        displaySmall: AppTextStyles.displaySmall.copyWith(
          color: AppColors.gray800,
        ),

        // Headlines
        headlineLarge: AppTextStyles.headlineLarge.copyWith(
          color: AppColors.gray800,
        ),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.gray800,
        ),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.gray700,
        ),

        // Titles
        titleLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.gray800),
        titleMedium: AppTextStyles.titleMedium.copyWith(
          color: AppColors.gray700,
        ),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: AppColors.gray600),

        // Body text
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.gray700),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray600),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.gray500),

        // Labels
        labelLarge: AppTextStyles.labelLarge.copyWith(color: AppColors.gray700),
        labelMedium: AppTextStyles.labelMedium.copyWith(
          color: AppColors.gray600,
        ),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: AppColors.gray500),
      ),

      // ========== APP BAR THEME ==========
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        shadowColor: AppColors.shadow,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: AppColors.gray900,
          fontWeight: FontWeight.w600,
        ),
        toolbarHeight: 56,
        centerTitle: false,
      ),

      // ========== CARD THEME ==========
      cardTheme: CardThemeData(
        color: AppColors.surface,
        shadowColor: AppColors.shadow,
        elevation: AppSpacing.elevationSM,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: AppSpacing.screenMargin,
          vertical: AppSpacing.cardSpacing,
        ),
      ),

      // ========== ELEVATED BUTTON THEME ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLimeGreen,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.gray300,
          disabledForegroundColor: AppColors.gray500,
          elevation: AppSpacing.buttonElevation,
          shadowColor: AppColors.shadowPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          textStyle: AppTextStyles.button.copyWith(color: AppColors.onPrimary),
          minimumSize: const Size(64, 48),
        ),
      ),

      // ========== OUTLINED BUTTON THEME ==========
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLimeGreen,
          disabledForegroundColor: AppColors.gray400,
          side: const BorderSide(color: AppColors.primaryLimeGreen, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          textStyle: AppTextStyles.button.copyWith(
            color: AppColors.primaryLimeGreen,
          ),
          minimumSize: const Size(64, 48),
        ),
      ),

      // ========== TEXT BUTTON THEME ==========
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLimeGreen,
          disabledForegroundColor: AppColors.gray400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: AppTextStyles.labelLarge.copyWith(
            color: AppColors.primaryLimeGreen,
          ),
          minimumSize: const Size(48, 40),
        ),
      ),

      // ========== INPUT DECORATION THEME ==========
      inputDecorationTheme: InputDecorationTheme(
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
          borderSide: const BorderSide(color: AppColors.borderFocus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.borderError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.borderError, width: 2),
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray600),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray400),
        errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
        helperStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.gray500),
        prefixIconColor: AppColors.gray500,
        suffixIconColor: AppColors.gray500,
      ),

      // ========== CHECKBOX THEME ==========
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLimeGreen;
          }
          return AppColors.surface;
        }),
        checkColor: WidgetStateProperty.all(AppColors.onPrimary),
        overlayColor: WidgetStateProperty.all(AppColors.primaryAlpha10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXS),
        ),
      ),

      // ========== RADIO THEME ==========
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty .resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLimeGreen;
          }
          return AppColors.gray400;
        }),
        overlayColor: WidgetStateProperty.all(AppColors.primaryAlpha10),
      ),

      // ========== SWITCH THEME ==========
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLimeGreen;
          }
          return AppColors.gray400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryAlpha30;
          }
          return AppColors.gray200;
        }),
        overlayColor: WidgetStateProperty.all(AppColors.primaryAlpha10),
      ),

      // ========== DIVIDER THEME ==========
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // ========== LIST TILE THEME ==========
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
        ),
        tileColor: AppColors.surface,
        selectedTileColor: AppColors.primarySurface,
        selectedColor: AppColors.primaryLimeGreen,
        iconColor: AppColors.gray500,
        textColor: AppColors.gray700,
        titleTextStyle: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.gray700,
        ),
        subtitleTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.gray500,
        ),
      ),

      // ========== BOTTOM NAVIGATION BAR THEME ==========
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primaryLimeGreen,
        unselectedItemColor: AppColors.gray400,
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primaryLimeGreen,
        ),
        unselectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.gray400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: AppSpacing.elevationMD,
      ),

      // ========== PROGRESS INDICATOR THEME ==========
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryLimeGreen,
        linearTrackColor: AppColors.gray200,
        circularTrackColor: AppColors.gray200,
      ),

      // ========== SNACK BAR THEME ==========
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.gray800,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
        ),
        actionTextColor: AppColors.primaryLimeGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
        ),
        elevation: AppSpacing.elevationMD,
      ),

      // ========== DIALOG THEME ==========
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: AppSpacing.elevationLG,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.modalRadius),
        ),
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.gray900,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.gray700,
        ),
      ),

      // ========== FLOATING ACTION BUTTON THEME ==========
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLimeGreen,
        foregroundColor: AppColors.onPrimary,
        elevation: AppSpacing.elevationMD,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        ),
      ),

      // ========== SCAFFOLD BACKGROUND ==========
      scaffoldBackgroundColor: AppColors.background,

      // ========== GENERAL CONFIGURATIONS ==========
      splashColor: AppColors.primaryAlpha10,
      highlightColor: AppColors.primaryAlpha10,
      focusColor: AppColors.primaryAlpha10,
      hoverColor: AppColors.primaryAlpha10,
    );
  }

  /// Dark theme configuration (for future implementation)
  static ThemeData get darkTheme {
    // TODO: Implement dark theme with same design principles
    return lightTheme; // Placeholder
  }
}

/// Helper class for theme-related utilities
class ThemeUtils {
  /// Get text color based on background
  static Color getTextColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? AppColors.gray900
        : AppColors.white;
  }

  /// Get contrast color for primary
  static Color getContrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? AppColors.gray900 : AppColors.white;
  }

  /// Apply theme to system UI overlay
  static SystemUiOverlayStyle getSystemUiOverlayStyle({bool isDark = false}) {
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: isDark ? AppColors.gray900 : AppColors.white,
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    );
  }
}
