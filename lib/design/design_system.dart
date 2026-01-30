import 'package:flutter/material.dart';

/// TravelKZ Design System
/// Современная система дизайна с Glassmorphism, градиентами и микроанимациями
class TravelKZDesign {
  // ========== ЦВЕТОВАЯ ПАЛИТРА ==========
  
  /// Основные градиенты
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );
  
  static const Gradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
  );
  
  static const Gradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
  );
  
  /// Темная тема
  static const Color darkBackgroundPrimary = Color(0xFF0F0F1F);
  static const Color darkBackgroundSecondary = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF16213E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  
  /// Светлая тема
  static const Color lightBackgroundPrimary = Color(0xFFFAFAFE);
  static const Color lightBackgroundSecondary = Color(0xFFF5F5FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF656E82);
  
  /// Акцентные цвета
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // ========== ТИПОГРАФИКА ==========
  
  /// Семейства шрифтов
  static const String fontFamilyPrimary = 'Poppins';
  static const String fontFamilySecondary = 'Inter';
  
  /// Стили заголовков
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  /// Стили текста
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );
  
  // ========== РАЗМЕРЫ И ОТСТУПЫ ==========
  
  /// Базовые отступы (8dp grid system)
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing40 = 40.0;
  static const double spacing48 = 48.0;
  
  /// Радиусы закругления
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusXXLarge = 24.0;
  
  /// Высота компонентов
  static const double buttonHeight = 56.0;
  static const double inputHeight = 52.0;
  static const double cardHeight = 200.0;
  
  // ========== ТЕНИ ==========
  
  /// Уровни теней (Material Design elevation)
  static const List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 1),
      blurRadius: 3,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Color(0x15000000),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
  
  static const List<BoxShadow> shadowXLarge = [
    BoxShadow(
      color: Color(0x15000000),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];
  
  // ========== АНИМАЦИИ ==========
  
  /// Длительность анимаций
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  /// Кривые анимаций
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elasticOut = Curves.elasticOut;
  
  // ========== GLASSMORPHISM ==========
  
  /// Эффект стекла для карточек
  static BoxDecoration glassmorphismDecoration({
    Color? backgroundColor,
    double blurRadius = 10.0,
    double opacity = 0.1,
  }) {
    return BoxDecoration(
      color: backgroundColor?.withOpacity(opacity) ?? Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radiusXLarge),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1,
      ),
      boxShadow: shadowLarge,
    );
  }
  
  // ========== ГРАДИЕНТНЫЕ КНОПКИ ==========
  
  /// Стиль для градиентных кнопок
  static BoxDecoration gradientButtonDecoration({
    required Gradient gradient,
    double borderRadius = radiusLarge,
  }) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: shadowMedium,
    );
  }
  
  // ========== ТЕМЫ ==========
  
  /// Темная тема
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF667EEA),
      scaffoldBackgroundColor: darkBackgroundPrimary,
      cardColor: darkSurface,
      textTheme: const TextTheme(
        headlineLarge: h1,
        headlineMedium: h2,
        headlineSmall: h3,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
      ).apply(
        bodyColor: darkTextPrimary,
        displayColor: darkTextPrimary,
      ),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF667EEA),
        secondary: Color(0xFFF093FB),
        surface: darkSurface,
        background: darkBackgroundPrimary,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onBackground: darkTextPrimary,
      ),
    );
  }
  
  /// Светлая тема
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF667EEA),
      scaffoldBackgroundColor: lightBackgroundPrimary,
      cardColor: lightSurface,
      textTheme: const TextTheme(
        headlineLarge: h1,
        headlineMedium: h2,
        headlineSmall: h3,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
      ).apply(
        bodyColor: lightTextPrimary,
        displayColor: lightTextPrimary,
      ),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF667EEA),
        secondary: Color(0xFFF093FB),
        surface: lightSurface,
        background: lightBackgroundPrimary,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        onBackground: lightTextPrimary,
      ),
    );
  }
}

/// Утилиты для работы с дизайн-системой
class DesignUtils {
  /// Проверка темной темы
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  /// Получение цвета фона в зависимости от темы
  static Color getBackgroundColor(BuildContext context) {
    return isDarkMode(context) 
        ? TravelKZDesign.darkBackgroundPrimary 
        : TravelKZDesign.lightBackgroundPrimary;
  }
  
  /// Получение цвета поверхности в зависимости от темы
  static Color getSurfaceColor(BuildContext context) {
    return isDarkMode(context) 
        ? TravelKZDesign.darkSurface 
        : TravelKZDesign.lightSurface;
  }
  
  /// Получение цвета текста в зависимости от темы
  static Color getTextColor(BuildContext context) {
    return isDarkMode(context) 
        ? TravelKZDesign.darkTextPrimary 
        : TravelKZDesign.lightTextPrimary;
  }
  
  /// Получение вторичного цвета текста в зависимости от темы
  static Color getSecondaryTextColor(BuildContext context) {
    return isDarkMode(context) 
        ? TravelKZDesign.darkTextSecondary 
        : TravelKZDesign.lightTextSecondary;
  }
}
