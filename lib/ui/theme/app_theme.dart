import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color accentColor = Color(0xFF03DAC6);
  
  // Light theme colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);
  static const Color lightOnSurface = Color(0xFF1C1B1F);
  static const Color lightOnSurfaceVariant = Color(0xFF49454F);
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2D2D2D);
  static const Color darkOnSurface = Color(0xFFE6E1E5);
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);
  
  // Glass effect colors
  static const Color glassLight = Color(0x88FFFFFF);
  static const Color glassDark = Color(0x88000000);
  
  // Sticky note colors
  static const List<Color> stickyColors = [
    Color(0xFFFFF3E0), // Amber 50
    Color(0xFFF3E5F5), // Purple 50
    Color(0xFFE8F5E8), // Green 50
    Color(0xFFE3F2FD), // Blue 50
    Color(0xFFFCE4EC), // Pink 50
    Color(0xFFF1F8E9), // Light Green 50
    Color(0xFFFFF8E1), // Yellow 50
    Color(0xFFE0F2F1), // Teal 50
    Color(0xFFEDE7F6), // Deep Purple 50
    Color(0xFFE8EAF6), // Indigo 50
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        background: lightBackground,
        surface: lightSurface,
        surfaceVariant: lightSurfaceVariant,
        onSurface: lightOnSurface,
        onSurfaceVariant: lightOnSurfaceVariant,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: lightSurface.withOpacity(0.9),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: lightOnSurface,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurfaceVariant.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dividerTheme: DividerThemeData(
        color: lightOnSurfaceVariant.withOpacity(0.2),
        thickness: 1,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: darkSurface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        background: darkBackground,
        surface: darkSurface,
        surfaceVariant: darkSurfaceVariant,
        onSurface: darkOnSurface,
        onSurfaceVariant: darkOnSurfaceVariant,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: darkSurface.withOpacity(0.9),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: darkOnSurface,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceVariant.withOpacity(0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dividerTheme: DividerThemeData(
        color: darkOnSurfaceVariant.withOpacity(0.2),
        thickness: 1,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: lightSurface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(color: Colors.black, fontSize: 12),
      ),
    );
  }

  // Glass effect decoration
  static BoxDecoration glassDecoration(BuildContext context, {double opacity = 0.8}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: (isDark ? glassDark : glassLight).withOpacity(opacity),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
        width: 1,
      ),
    );
  }

  // Frosted glass decoration
  static BoxDecoration frostedGlassDecoration(BuildContext context, {double opacity = 0.9}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: (isDark ? darkSurface : lightSurface).withOpacity(opacity),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: (isDark ? Colors.black : Colors.grey).withOpacity(0.2),
          blurRadius: 20,
          spreadRadius: -5,
        ),
      ],
    );
  }

  // Status indicator colors
  static Color getStatusColor(bool isActive) {
    return isActive ? accentColor : Colors.grey;
  }

  // Get random sticky color
  static Color getRandomStickyColor() {
    return stickyColors[(DateTime.now().millisecondsSinceEpoch) % stickyColors.length];
  }

  // Text styles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
}
