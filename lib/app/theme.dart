import 'package:flutter/material.dart';

class AppTheme {
  // 🔥 Kaloree Official Brand Colors (From Logo)
  static const Color kaloreePurple = Color(0xFF3B0A5A); // Royal Purple - Primary Background
  static const Color flameOrange = Color(0xFFFF8A00); // Flame top - Highlights, CTAs
  static const Color flamePink = Color(0xFFFF2E7A); // Flame base - Accents, gradients
  static const Color textOrange = Color(0xFFFF7A18); // Warm Orange - Text gradient
  static const Color textRose = Color(0xFFFF3D81); // Magenta Rose - Emphasis elements
  
  // Legacy aliases for backwards compatibility
  static const Color _primaryPurple = kaloreePurple;
  static const Color _secondaryPink = flamePink;
  static const Color _accentBlue = Color(0xFF3B82F6); // Electric Blue (kept for charts)
  static const Color _accentYellow = flameOrange;
  static const Color _accentMint = Color(0xFF34D399); // Fresh Mint (kept for fiber)
  static const Color _surfaceWhite = Color(0xFFFFFFFF); // Pure White
  static const Color _surfaceLight = Color(0xFFFAFAFA); // Soft White
  static const Color _textPrimary = Color(0xFF1A1A1A); // Deep Charcoal
  static const Color _textSecondary = Color(0xFF64748B); // Cool Gray
  static const Color _textMuted = Color(0xFF94A3B8); // Light Gray

  // 🌈 Macro colors - Kaloree branded
  static const Color proteinColor = kaloreePurple; // Purple 💪
  static const Color carbsColor = flameOrange; // Flame Orange ⚡
  static const Color fatColor = flamePink; // Flame Pink 🥑
  static const Color fiberColor = Color(0xFF34D399); // Mint 🥬

  // 🔥 Kaloree Brand Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [kaloreePurple, Color(0xFF5A1A7A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient flameGradient = LinearGradient(
    colors: [flameOrange, flamePink],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient textGradient = LinearGradient(
    colors: [textOrange, textRose],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = flameGradient;

  static const LinearGradient accentGradient = LinearGradient(
    colors: [flameOrange, Color(0xFFFF9D33)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintGradient = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF6EE7B7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🎨 Glass morphism effect colors
  static const Color glassBackground = Color(0xCCFFFFFF);
  static const Color glassBorder = Color(0xFFEDE9FE);

  // 🌟 Only light theme - vibrant Gen Z style!
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: _primaryPurple,
    scaffoldBackgroundColor: _surfaceWhite,

    colorScheme: ColorScheme.light(
      primary: _primaryPurple,
      secondary: _secondaryPink,
      tertiary: _accentYellow,
      surface: _surfaceWhite,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _textPrimary,
      outline: _textMuted,
    ),

    // 🎭 Typography - Bold and modern for Gen Z
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        color: _textPrimary,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        color: _textPrimary,
        height: 1.2,
      ),
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: _textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        color: _textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: _textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _textPrimary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _textSecondary,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: _textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.25,
        color: _textMuted,
      ),
    ),

    // 🎨 Card theme - Extra rounded with soft shadows
    cardTheme: CardThemeData(
      color: _surfaceWhite,
      elevation: 0,
      shadowColor: _primaryPurple.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
    ),

    // 🎯 App bar - Clean and vibrant
    appBarTheme: AppBarTheme(
      backgroundColor: _surfaceWhite,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: _textPrimary, size: 24),
      toolbarHeight: 64,
    ),

    // 🧭 Bottom navigation - Pill-style with color-coded icons
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _surfaceWhite,
      selectedItemColor: _primaryPurple,
      unselectedItemColor: _textMuted,
      selectedLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),

    // 🚀 Elevated button - Gradient buttons with shadow!
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryPurple,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: _primaryPurple.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // 📝 Text button - Clean and minimal
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _primaryPurple,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.25,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),

    // 📥 Input decoration - Rounded and soft
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F5F9), // Soft gray
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _primaryPurple, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      hintStyle: TextStyle(
        color: _textMuted,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: TextStyle(
        color: _textSecondary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),

    // 🎈 Floating action button - Vibrant with shadow!
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _primaryPurple,
      foregroundColor: Colors.white,
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      sizeConstraints: const BoxConstraints.tightFor(width: 64, height: 64),
    ),

    // 📏 Divider - Subtle and clean
    dividerTheme: DividerThemeData(
      color: const Color(0xFFE2E8F0),
      thickness: 1,
      space: 0,
    ),

    // 🎨 Chip theme - Rounded and colorful
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF1F5F9),
      selectedColor: _primaryPurple.withOpacity(0.15),
      checkmarkColor: _primaryPurple,
      deleteIconColor: _textMuted,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      side: BorderSide.none,
    ),

    // 🔄 Progress indicator - Vibrant colors
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: _primaryPurple,
      linearTrackColor: _primaryPurple.withOpacity(0.2),
      circularTrackColor: _primaryPurple.withOpacity(0.2),
    ),

    // 📱 SnackBar - Modern and clean
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _textPrimary,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    ),

    // 📋 Dialog theme - Rounded and modern
    dialogTheme: DialogThemeData(
      backgroundColor: _surfaceWhite,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: _textPrimary,
        letterSpacing: -0.5,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _textSecondary,
        height: 1.5,
      ),
    ),

    // 🎛️ Switch theme - Modern toggle
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _primaryPurple;
        }
        return Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return _primaryPurple.withOpacity(0.4);
        }
        return Colors.grey.shade300;
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),

    // 📊 Slider theme - Vibrant sliders
    sliderTheme: SliderThemeData(
      activeTrackColor: _primaryPurple,
      inactiveTrackColor: _primaryPurple.withOpacity(0.2),
      thumbColor: _primaryPurple,
      overlayColor: _primaryPurple.withOpacity(0.1),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
    ),
  );

  // 🚫 No dark theme - Gen Z loves light and vibrant!
  static ThemeData get dark => light; // Return light theme for now
}
