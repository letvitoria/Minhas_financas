import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();
  static const orange = Color(0xFFFF6B00);
  static const orangeLight = Color(0xFFFF8A33);
  static const ink = Color(0xFF171717);
  static const darkSurface = Color(0xFF242424);
  static const darkBackground = Color(0xFF111111);
  static const green = Color(0xFF16A36A);
  static const red = Color(0xFFE25454);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      brightness: brightness,
      primary: AppColors.orange,
      secondary: AppColors.green,
      surface: isDark ? AppColors.darkSurface : Colors.white,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF6F6F6),
      textTheme: GoogleFonts.interTextTheme(ThemeData(brightness: brightness).textTheme),
    );
    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF6F6F6),
        foregroundColor: isDark ? Colors.white : AppColors.ink,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF303030) : const Color(0xFFF2F2F2),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        indicatorColor: AppColors.orange.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
        )),
      ),
      dividerColor: isDark ? Colors.white12 : Colors.black12,
    );
  }
}
