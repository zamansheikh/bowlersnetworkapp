import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_spacing.dart';
import 'app_text_styles.dart';
import 'app_theme_colors.dart';

/// Builds the [ThemeData] for light and dark modes.
///
/// All semantic colors are exposed via the [AppThemeColors] extension. Widgets
/// should read colors through `context.colors` rather than `Theme.of(context)`.
class AppTheme {
  AppTheme._();

  static ThemeData get dark => _build(AppThemeColors.dark, Brightness.dark);
  static ThemeData get light => _build(AppThemeColors.light, Brightness.light);

  static ThemeData _build(AppThemeColors tokens, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: tokens.accent,
      onPrimary: Colors.white,
      secondary: tokens.accent,
      onSecondary: Colors.white,
      error: tokens.error,
      onError: Colors.white,
      surface: tokens.bgSurface,
      onSurface: tokens.textPrimary,
      surfaceContainerHighest: tokens.bgSurfaceElevated,
      outline: tokens.borderStrong,
      outlineVariant: tokens.borderDefault,
    );

    final textTheme = AppTextStyles.textTheme(tokens.textPrimary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.bgPrimary,
      canvasColor: tokens.bgPrimary,
      dividerColor: tokens.borderDefault,
      splashColor: tokens.accent.withValues(alpha: 0.08),
      highlightColor: tokens.accent.withValues(alpha: 0.04),
      textTheme: textTheme,
      extensions: [tokens],
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.bgPrimary,
        foregroundColor: tokens.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: AppSpacing.appBarHeight,
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                systemNavigationBarColor: tokens.bgPrimary,
                systemNavigationBarIconBrightness: Brightness.light,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                systemNavigationBarColor: tokens.bgPrimary,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
        titleTextStyle: AppTextStyles.sectionTitle.copyWith(
          color: tokens.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: tokens.bgSurface,
        selectedItemColor: tokens.accent,
        unselectedItemColor: tokens.textTertiary,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.bgSurfaceElevated,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: tokens.bgSurfaceElevated,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.lg),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: tokens.bgSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: tokens.borderDefault),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.bgSurfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(color: tokens.borderDefault),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: tokens.borderDefault,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: tokens.textSecondary, size: 20),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.bgSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTextStyles.body.copyWith(color: tokens.textTertiary),
        labelStyle: AppTextStyles.label.copyWith(color: tokens.textSecondary),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: tokens.borderStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: tokens.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: tokens.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: tokens.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdAll,
          borderSide: BorderSide(color: tokens.error, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: tokens.bgSurfaceElevated,
        contentTextStyle: AppTextStyles.body.copyWith(color: tokens.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        elevation: 0,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: tokens.bgSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(AppRadius.lg)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: tokens.accent,
        linearTrackColor: tokens.bgSurfaceHover,
        circularTrackColor: tokens.bgSurfaceHover,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        },
      ),
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
