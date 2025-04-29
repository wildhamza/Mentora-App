import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF3F51B5); // Indigo
  static const Color accentColor = Color(0xFF4CAF50); // Green
  static const Color secondaryColor = Color(0xFFFFC107); // Amber
  
  static const Color studentPrimaryColor = Color(0xFF3F51B5); // Indigo
  static const Color teacherPrimaryColor = Color(0xFF009688); // Teal
  static const Color adminPrimaryColor = Color(0xFF673AB7); // Deep Purple
  
  static const Color errorColor = Color(0xFFF44336); // Red
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color warningColor = Color(0xFFFF9800); // Orange
  static const Color infoColor = Color(0xFF2196F3); // Blue
  
  static const Color textPrimaryColor = Color(0xFF212121); // Near black
  static const Color textSecondaryColor = Color(0xFF757575); // Medium gray
  static const Color dividerColor = Color(0xFFBDBDBD); // Light gray
  static const Color backgroundColor = Color(0xFFF5F5F5); // Off-white
  static const Color cardColor = Colors.white;
  
  // Dark theme colors
  static const Color darkPrimaryColor = Color(0xFF303F9F); // Darker Indigo
  static const Color darkBackgroundColor = Color(0xFF121212); // Near black
  static const Color darkCardColor = Color(0xFF1E1E1E); // Dark gray
  static const Color darkTextPrimaryColor = Color(0xFFEEEEEE); // Off-white
  static const Color darkTextSecondaryColor = Color(0xFFB0B0B0); // Light gray
  
  // Font sizes
  static const double fontSizeXSmall = 12.0;
  static const double fontSizeSmall = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 22.0;
  static const double fontSizeXXLarge = 26.0;
  
  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  
  // Border radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 12.0;
  static const double borderRadiusXLarge = 16.0;
  
  // Elevation
  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;
  
  // Animation durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 350);
  static const Duration animationDurationLong = Duration(milliseconds: 500);
  
  // Theme data
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      error: errorColor,
      background: backgroundColor,
      surface: cardColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    dividerColor: dividerColor,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: fontSizeXXLarge,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      displayMedium: TextStyle(
        fontSize: fontSizeXLarge,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      displaySmall: TextStyle(
        fontSize: fontSizeLarge,
        fontWeight: FontWeight.bold,
        color: textPrimaryColor,
      ),
      headlineMedium: TextStyle(
        fontSize: fontSizeMedium,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
      ),
      bodyLarge: TextStyle(
        fontSize: fontSizeMedium,
        color: textPrimaryColor,
      ),
      bodyMedium: TextStyle(
        fontSize: fontSizeSmall,
        color: textPrimaryColor,
      ),
      bodySmall: TextStyle(
        fontSize: fontSizeXSmall,
        color: textSecondaryColor,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: elevationSmall,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: fontSizeLarge,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      padding: const EdgeInsets.symmetric(vertical: spacingMedium, horizontal: spacingLarge),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        padding: const EdgeInsets.symmetric(vertical: spacingMedium, horizontal: spacingLarge),
      ),
    ),
    cardTheme: CardTheme(
      color: cardColor,
      elevation: elevationSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.all(spacingMedium),
    ),
  );
  
  static final ThemeData darkTheme = ThemeData(
    primaryColor: darkPrimaryColor,
    colorScheme: ColorScheme.dark(
      primary: darkPrimaryColor,
      secondary: accentColor,
      error: errorColor,
      background: darkBackgroundColor,
      surface: darkCardColor,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
    cardColor: darkCardColor,
    dividerColor: dividerColor,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: fontSizeXXLarge,
        fontWeight: FontWeight.bold,
        color: darkTextPrimaryColor,
      ),
      displayMedium: TextStyle(
        fontSize: fontSizeXLarge,
        fontWeight: FontWeight.bold,
        color: darkTextPrimaryColor,
      ),
      displaySmall: TextStyle(
        fontSize: fontSizeLarge,
        fontWeight: FontWeight.bold,
        color: darkTextPrimaryColor,
      ),
      headlineMedium: TextStyle(
        fontSize: fontSizeMedium,
        fontWeight: FontWeight.w500,
        color: darkTextPrimaryColor,
      ),
      bodyLarge: TextStyle(
        fontSize: fontSizeMedium,
        color: darkTextPrimaryColor,
      ),
      bodyMedium: TextStyle(
        fontSize: fontSizeSmall,
        color: darkTextPrimaryColor,
      ),
      bodySmall: TextStyle(
        fontSize: fontSizeXSmall,
        color: darkTextSecondaryColor,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkPrimaryColor,
      elevation: elevationSmall,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: fontSizeLarge,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
      padding: const EdgeInsets.symmetric(vertical: spacingMedium, horizontal: spacingLarge),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        padding: const EdgeInsets.symmetric(vertical: spacingMedium, horizontal: spacingLarge),
      ),
    ),
    cardTheme: CardTheme(
      color: darkCardColor,
      elevation: elevationSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.all(spacingMedium),
    ),
  );
  
  // Helper methods to get role-specific colors
  static Color getPrimaryColorForRole(String role) {
    switch (role) {
      case 'ADMIN':
        return adminPrimaryColor;
      case 'TEACHER':
        return teacherPrimaryColor;
      case 'STUDENT':
        return studentPrimaryColor;
      default:
        return primaryColor;
    }
  }
}
