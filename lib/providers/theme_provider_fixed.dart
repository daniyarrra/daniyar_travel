import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// Provider для управления темой приложения
/// Отвечает за переключение между светлой и темной темами
class ThemeProvider with ChangeNotifier {
  // Текущая тема (true - темная, false - светлая)
  bool _isDarkMode = false;
  
  // Состояние загрузки
  bool _isLoading = false;

  // Геттеры для доступа к данным
  bool get isDarkMode => _isDarkMode;
  bool get isLightMode => !_isDarkMode;
  bool get isLoading => _isLoading;

  /// Инициализация Provider'а
  /// Загружает сохраненную тему из SharedPreferences
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(AppConstants.keyTheme) ?? false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка загрузки темы: $e');
      _isDarkMode = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Переключение темы
  Future<void> toggleTheme() async {
    await setTheme(!_isDarkMode);
  }

  /// Установка конкретной темы
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode == isDark) return;

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyTheme, isDark);
      
      _isDarkMode = isDark;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка сохранения темы: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Установка светлой темы
  Future<void> setLightTheme() async {
    await setTheme(false);
  }

  /// Установка темной темы
  Future<void> setDarkTheme() async {
    await setTheme(true);
  }

  /// Получение названия текущей темы
  String getThemeName() {
    return _isDarkMode ? 'Темная' : 'Светлая';
  }

  /// Получение названия текущей темы на казахском языке
  String getThemeNameKk() {
    return _isDarkMode ? 'Қараңғы' : 'Жарық';
  }

  /// Получение локализованного названия темы
  String getLocalizedThemeName(String languageCode) {
    return languageCode == 'kk' ? getThemeNameKk() : getThemeName();
  }

  /// Получение основного цвета темы
  Color getPrimaryColor() {
    return Color(AppConstants.primaryColorValue);
  }

  /// Получение вторичного цвета темы
  Color getSecondaryColor() {
    return Color(AppConstants.secondaryColorValue);
  }

  /// Получение цвета фона
  Color getBackgroundColor() {
    return _isDarkMode ? const Color(0xFF121212) : const Color(0xFFFFFFFF);
  }

  /// Получение цвета поверхности
  Color getSurfaceColor() {
    return _isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
  }

  /// Получение цвета карточки
  Color getCardColor() {
    return _isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFFFFFFF);
  }

  /// Получение цвета текста
  Color getTextColor() {
    return _isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  }

  /// Получение цвета вторичного текста
  Color getSecondaryTextColor() {
    return _isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF666666);
  }

  /// Получение цвета границы
  Color getBorderColor() {
    return _isDarkMode ? const Color(0xFF404040) : const Color(0xFFE0E0E0);
  }

  /// Получение цвета ошибки
  Color getErrorColor() {
    return Color(AppConstants.errorColorValue);
  }

  /// Получение цвета предупреждения
  Color getWarningColor() {
    return Color(AppConstants.warningColorValue);
  }

  /// Получение цвета успеха
  Color getSuccessColor() {
    return Color(AppConstants.accentColorValue);
  }

  /// Получение цвета тени
  Color getShadowColor() {
    return _isDarkMode ? const Color(0x80000000) : const Color(0x1A000000);
  }

  /// Получение цвета разделителя
  Color getDividerColor() {
    return _isDarkMode ? const Color(0xFF404040) : const Color(0xFFE0E0E0);
  }

  /// Получение цвета иконки
  Color getIconColor() {
    return _isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  }

  /// Получение цвета неактивной иконки
  Color getInactiveIconColor() {
    return _isDarkMode ? const Color(0xFF666666) : const Color(0xFF999999);
  }

  /// Получение цвета выделения
  Color getHighlightColor() {
    return _isDarkMode ? const Color(0xFF333333) : const Color(0xFFF5F5F5);
  }

  /// Получение цвета нажатия
  Color getRippleColor() {
    return _isDarkMode ? const Color(0x1AFFFFFF) : const Color(0x1A000000);
  }

  /// Получение цвета статус-бара
  Color getStatusBarColor() {
    return _isDarkMode ? const Color(0xFF000000) : const Color(0xFF2196F3);
  }

  /// Получение цвета навигационной панели
  Color getNavigationBarColor() {
    return _isDarkMode ? const Color(0xFF000000) : const Color(0xFFFFFFFF);
  }

  /// Получение цвета AppBar
  Color getAppBarColor() {
    return _isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFF2196F3);
  }

  /// Получение цвета BottomNavigationBar
  Color getBottomNavigationBarColor() {
    return _isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
  }

  /// Получение цвета FloatingActionButton
  Color getFloatingActionButtonColor() {
    return Color(AppConstants.primaryColorValue);
  }

  /// Получение цвета кнопки
  Color getButtonColor() {
    return Color(AppConstants.primaryColorValue);
  }

  /// Получение цвета текста кнопки
  Color getButtonTextColor() {
    return const Color(0xFFFFFFFF);
  }

  /// Получение цвета неактивной кнопки
  Color getInactiveButtonColor() {
    return _isDarkMode ? const Color(0xFF404040) : const Color(0xFFE0E0E0);
  }

  /// Получение цвета текста неактивной кнопки
  Color getInactiveButtonTextColor() {
    return _isDarkMode ? const Color(0xFF666666) : const Color(0xFF999999);
  }

  /// Получение цвета поля ввода
  Color getInputFieldColor() {
    return _isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFFFFFFF);
  }

  /// Получение цвета границы поля ввода
  Color getInputFieldBorderColor() {
    return _isDarkMode ? const Color(0xFF404040) : const Color(0xFFE0E0E0);
  }

  /// Получение цвета фокуса поля ввода
  Color getInputFieldFocusColor() {
    return Color(AppConstants.primaryColorValue);
  }

  /// Получение цвета подсказки
  Color getHintColor() {
    return _isDarkMode ? const Color(0xFF666666) : const Color(0xFF999999);
  }

  /// Получение цвета лейбла
  Color getLabelColor() {
    return _isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF666666);
  }

  /// Получение цвета чекбокса
  Color getCheckboxColor() {
    return Color(AppConstants.primaryColorValue);
  }

  /// Получение цвета переключателя
  Color getSwitchColor() {
    return Color(AppConstants.primaryColorValue);
  }

  /// Получение цвета ползунка
  Color getSliderColor() {
    return Color(AppConstants.primaryColorValue);
  }

  /// Получение цвета прогресс-бара
  Color getProgressBarColor() {
    return Color(AppConstants.primaryColorValue);
  }

  /// Получение цвета индикатора
  Color getIndicatorColor() {
    return Color(AppConstants.primaryColorValue);
  }

  /// Получение цвета чипа
  Color getChipColor() {
    return _isDarkMode ? const Color(0xFF404040) : const Color(0xFFE0E0E0);
  }

  /// Получение цвета текста чипа
  Color getChipTextColor() {
    return _isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  }

  /// Получение цвета выбранного чипа
  Color getSelectedChipColor() {
    return Color(AppConstants.primaryColorValue);
  }

  /// Получение цвета текста выбранного чипа
  Color getSelectedChipTextColor() {
    return const Color(0xFFFFFFFF);
  }

  /// Получение цвета таба
  Color getTabColor() {
    return _isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
  }

  /// Получение цвета выбранного таба
  Color getSelectedTabColor() {
    return Color(AppConstants.primaryColorValue);
  }

  /// Получение цвета невыбранного таба
  Color getUnselectedTabColor() {
    return _isDarkMode ? const Color(0xFF666666) : const Color(0xFF999999);
  }

  /// Получение цвета тултипа
  Color getTooltipColor() {
    return _isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFF424242);
  }

  /// Получение цвета текста тултипа
  Color getTooltipTextColor() {
    return _isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF);
  }

  /// Получение цвета снэкбара
  Color getSnackBarColor() {
    return _isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFF424242);
  }

  /// Получение цвета текста снэкбара
  Color getSnackBarTextColor() {
    return const Color(0xFFFFFFFF);
  }

  /// Получение цвета диалога
  Color getDialogColor() {
    return _isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFFFFFFF);
  }

  /// Получение цвета заголовка диалога
  Color getDialogTitleColor() {
    return _isDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF000000);
  }

  /// Получение цвета содержимого диалога
  Color getDialogContentColor() {
    return _isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF666666);
  }

  /// Получение цвета кнопки диалога
  Color getDialogButtonColor() {
    return Color(AppConstants.primaryColorValue);
  }

  /// Получение цвета текста кнопки диалога
  Color getDialogButtonTextColor() {
    return const Color(0xFFFFFFFF);
  }

  /// Получение информации о текущей теме
  Map<String, dynamic> getThemeInfo() {
    return {
      'isDarkMode': _isDarkMode,
      'isLightMode': !_isDarkMode,
      'name': getThemeName(),
      'nameKk': getThemeNameKk(),
      'primaryColor': getPrimaryColor(),
      'secondaryColor': getSecondaryColor(),
      'backgroundColor': getBackgroundColor(),
      'surfaceColor': getSurfaceColor(),
      'textColor': getTextColor(),
      'iconColor': getIconColor(),
    };
  }

  /// Сброс темы к значению по умолчанию
  Future<void> resetToDefault() async {
    await setTheme(false);
  }

  /// Получение цветовой схемы для графика
  List<Color> getChartColors() {
    return [
      Color(AppConstants.primaryColorValue),
      Color(AppConstants.secondaryColorValue),
      Color(AppConstants.accentColorValue),
      Color(AppConstants.warningColorValue),
      const Color(0xFF9C27B0), // Фиолетовый
      const Color(0xFF00BCD4), // Голубой
      const Color(0xFF4CAF50), // Зеленый
      const Color(0xFFFF5722), // Глубокий оранжевый
    ];
  }

  /// Получение цвета по индексу для графика
  Color getChartColor(int index) {
    final colors = getChartColors();
    return colors[index % colors.length];
  }
}
