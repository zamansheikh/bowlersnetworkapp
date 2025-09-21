import 'package:flutter/material.dart';

/// Modern color system inspired by clean, minimal design
/// Primary brand color: Lime Green (#8BC342)
/// Design approach: Clean, accessible, modern
class AppColors {
  // ========== BRAND COLORS (Your lime green branding) ==========
  
  /// Primary brand color - Lime Green
  static const Color primaryLimeGreen = Color(0xFF8BC342);
  
  /// Primary variants for different states
  static const Color primaryLight = Color(0xFF9ED354);    // Lighter lime green
  static const Color primaryDark = Color(0xFF7AB230);     // Darker lime green
  static const Color primarySurface = Color(0xFFF0F8E8);  // Very light lime for backgrounds
  
  // ========== NEUTRAL COLORS (Modern gray scale) ==========
  
  /// Pure colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  /// Modern gray scale (inspired by Tailwind CSS)
  static const Color gray50 = Color(0xFFFAFAFA);   // Almost white - light backgrounds
  static const Color gray100 = Color(0xFFF5F5F5);  // Very light gray - card backgrounds
  static const Color gray200 = Color(0xFFEEEEEE);  // Light gray - borders
  static const Color gray300 = Color(0xFFE0E0E0);  // Medium light - disabled elements
  static const Color gray400 = Color(0xFFBDBDBD);  // Medium gray - placeholder text
  static const Color gray500 = Color(0xFF9E9E9E);  // Medium gray - secondary text
  static const Color gray600 = Color(0xFF757575);  // Dark gray - body text
  static const Color gray700 = Color(0xFF616161);  // Darker gray - primary text
  static const Color gray800 = Color(0xFF424242);  // Very dark gray - headings
  static const Color gray900 = Color(0xFF212121);  // Almost black - emphasis text

  // ========== SEMANTIC COLORS (Modern, accessible) ==========
  
  /// Success color - Modern emerald green
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color successDark = Color(0xFF059669);
  
  /// Error color - Modern red
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color errorDark = Color(0xFFDC2626);
  
  /// Warning color - Modern amber
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);
  
  /// Info color - Modern blue
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFEBF4FF);
  static const Color infoDark = Color(0xFF2563EB);

  // ========== SURFACE COLORS (For cards, backgrounds) ==========
  
  /// Surface colors for modern layering
  static const Color surface = Color(0xFFFFFFFF);           // Card backgrounds
  static const Color surfaceVariant = Color(0xFFF8F9FA);    // Alternative surface
  static const Color background = Color(0xFFFAFAFA);        // Main background
  static const Color backgroundSecondary = Color(0xFFF5F5F5); // Secondary background
  
  /// On-surface colors (text on surfaces)
  static const Color onSurface = Color(0xFF212121);         // Primary text on surfaces
  static const Color onSurfaceVariant = Color(0xFF616161);  // Secondary text on surfaces
  static const Color onBackground = Color(0xFF212121);      // Text on background
  
  /// Primary surface colors (lime green surfaces)
  static const Color onPrimary = Color(0xFFFFFFFF);         // White text on lime green
  static const Color onPrimaryContainer = Color(0xFF1B5E20); // Dark text on light lime

  // ========== INTERACTIVE COLORS (For buttons, links) ==========
  
  /// Button states
  static const Color buttonPrimary = primaryLimeGreen;
  static const Color buttonPrimaryHover = Color(0xFF7AB230);
  static const Color buttonPrimaryPressed = Color(0xFF689922);
  static const Color buttonSecondary = Color(0xFFF5F5F5);
  static const Color buttonSecondaryHover = Color(0xFFEEEEEE);
  
  /// Link colors
  static const Color link = primaryLimeGreen;
  static const Color linkHover = primaryDark;
  static const Color linkVisited = Color(0xFF6B7280);

  // ========== BORDER COLORS ==========
  
  /// Border colors for modern, subtle borders
  static const Color border = Color(0xFFE5E7EB);          // Default border
  static const Color borderLight = Color(0xFFF3F4F6);     // Light border
  static const Color borderFocus = primaryLimeGreen;       // Focus state border
  static const Color borderError = error;                  // Error state border
  static const Color borderSuccess = success;              // Success state border

  // ========== SHADOW COLORS ==========
  
  /// Shadow colors for depth and elevation
  static const Color shadow = Color(0x1A000000);           // 10% black
  static const Color shadowLight = Color(0x0F000000);      // 6% black
  static const Color shadowStrong = Color(0x33000000);     // 20% black
  
  /// Colored shadows for lime green elements
  static const Color shadowPrimary = Color(0x1A8BC342);    // 10% lime green

  // ========== GRADIENTS (For modern visual appeal) ==========
  
  /// Primary gradient using lime green
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryLight, primaryLimeGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Background gradient for screens
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [white, gray50],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  /// Surface gradient for cards
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [white, Color(0xFFFDFDFD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Success gradient
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ========== ALPHA VARIANTS (For overlays and transparency) ==========
  
  /// Semi-transparent overlays
  static const Color overlay = Color(0x80000000);          // 50% black
  static const Color overlayLight = Color(0x40000000);     // 25% black
  static const Color overlayStrong = Color(0xB3000000);    // 70% black
  
  /// Semi-transparent lime green
  static const Color primaryAlpha10 = Color(0x1A8BC342);   // 10% lime green
  static const Color primaryAlpha20 = Color(0x338BC342);   // 20% lime green
  static const Color primaryAlpha30 = Color(0x4D8BC342);   // 30% lime green

  // ========== LEGACY SUPPORT (Backward compatibility) ==========
  
  /// Legacy colors for gradual migration
  static const Color lightGray = gray100;
  static const Color gray = gray500;
  static const Color darkGray = gray700;
  static const Color cardBackground = surface;
  static const Color cardShadow = shadow;
  static const Color outline = border;
}
