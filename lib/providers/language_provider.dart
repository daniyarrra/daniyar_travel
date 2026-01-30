import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// Provider для управления языком приложения
/// Отвечает за переключение между русским и казахским языками
class LanguageProvider with ChangeNotifier {
  // Текущий язык приложения
  String _currentLanguage = AppConstants.defaultLanguage;
  
  // Состояние загрузки
  bool _isLoading = false;

  // Геттеры для доступа к данным
  String get currentLanguage => _currentLanguage;
  bool get isLoading => _isLoading;
  
  // Проверка, является ли текущий язык казахским
  bool get isKazakh => _currentLanguage == 'kk';
  
  // Проверка, является ли текущий язык русским
  bool get isRussian => _currentLanguage == 'ru';

  /// Инициализация Provider'а
  /// Загружает сохраненный язык из SharedPreferences
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString(AppConstants.keyLanguage) ?? AppConstants.defaultLanguage;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка загрузки языка: $e');
      _currentLanguage = AppConstants.defaultLanguage;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Изменение языка приложения
  Future<void> changeLanguage(String languageCode) async {
    if (!AppConstants.supportedLanguages.contains(languageCode)) {
      debugPrint('Неподдерживаемый язык: $languageCode');
      return;
    }

    if (_currentLanguage == languageCode) return;

    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyLanguage, languageCode);
      
      _currentLanguage = languageCode;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка сохранения языка: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Переключение на казахский язык
  Future<void> switchToKazakh() async {
    await changeLanguage('kk');
  }

  /// Переключение на русский язык
  Future<void> switchToRussian() async {
    await changeLanguage('ru');
  }

  /// Переключение языка (между русским и казахским)
  Future<void> toggleLanguage() async {
    if (_currentLanguage == 'ru') {
      await switchToKazakh();
    } else {
      await switchToRussian();
    }
  }

  /// Получение локализованного текста
  /// Принимает русский и казахский текст, возвращает нужный
  String getLocalizedText(String russianText, String kazakhText) {
    return _currentLanguage == 'kk' ? kazakhText : russianText;
  }

  /// Получение названия языка на самом языке
  String getLanguageName() {
    return _currentLanguage == 'kk' ? 'Қазақша' : 'Русский';
  }

  /// Получение названия языка на русском
  String getLanguageNameRu() {
    return _currentLanguage == 'kk' ? 'Казахский' : 'Русский';
  }

  /// Получение кода языка для API
  String getLanguageCode() {
    return _currentLanguage;
  }

  /// Получение локали для форматирования дат
  String getLocale() {
    return _currentLanguage == 'kk' ? 'kk_KZ' : 'ru_RU';
  }

  /// Проверка, поддерживается ли язык
  bool isLanguageSupported(String languageCode) {
    return AppConstants.supportedLanguages.contains(languageCode);
  }

  /// Получение списка поддерживаемых языков
  List<Map<String, String>> getSupportedLanguages() {
    return [
      {
        'code': 'ru',
        'name': 'Русский',
        'nativeName': 'Русский',
      },
      {
        'code': 'kk',
        'name': 'Казахский',
        'nativeName': 'Қазақша',
      },
    ];
  }

  /// Получение направления текста (LTR/RTL)
  String getTextDirection() {
    return 'ltr'; // И русский, и казахский используют LTR
  }

  /// Получение формата даты для текущего языка
  String getDateFormat() {
    return _currentLanguage == 'kk' ? 'dd.MM.yyyy' : 'dd.MM.yyyy';
  }

  /// Получение формата времени для текущего языка
  String getTimeFormat() {
    return 'HH:mm'; // 24-часовой формат для обоих языков
  }

  /// Получение формата валюты для текущего языка
  String getCurrencyFormat() {
    return _currentLanguage == 'kk' ? '#,##0.00 ₸' : '#,##0.00 ₸';
  }

  /// Получение названий месяцев на текущем языке
  List<String> getMonthNames() {
    if (_currentLanguage == 'kk') {
      return [
        'Қаңтар', 'Ақпан', 'Наурыз', 'Сәуір',
        'Мамыр', 'Маусым', 'Шілде', 'Тамыз',
        'Қыркүйек', 'Қазан', 'Қараша', 'Желтоқсан'
      ];
    } else {
      return [
        'Январь', 'Февраль', 'Март', 'Апрель',
        'Май', 'Июнь', 'Июль', 'Август',
        'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
      ];
    }
  }

  /// Получение названий дней недели на текущем языке
  List<String> getWeekdayNames() {
    if (_currentLanguage == 'kk') {
      return [
        'Дүйсенбі', 'Сейсенбі', 'Сәрсенбі', 'Бейсенбі',
        'Жұма', 'Сенбі', 'Жексенбі'
      ];
    } else {
      return [
        'Понедельник', 'Вторник', 'Среда', 'Четверг',
        'Пятница', 'Суббота', 'Воскресенье'
      ];
    }
  }

  /// Получение сокращенных названий дней недели
  List<String> getShortWeekdayNames() {
    if (_currentLanguage == 'kk') {
      return ['Дс', 'Сс', 'Ср', 'Бс', 'Жм', 'Сб', 'Жк'];
    } else {
      return ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    }
  }

  /// Получение сокращенных названий месяцев
  List<String> getShortMonthNames() {
    if (_currentLanguage == 'kk') {
      return [
        'Қаң', 'Ақп', 'Нау', 'Сәу', 'Мам', 'Мау',
        'Шіл', 'Там', 'Қыр', 'Қаз', 'Қар', 'Жел'
      ];
    } else {
      return [
        'Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн',
        'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек'
      ];
    }
  }

  /// Сброс языка к значению по умолчанию
  Future<void> resetToDefault() async {
    await changeLanguage(AppConstants.defaultLanguage);
  }

  /// Получение информации о текущем языке
  Map<String, dynamic> getLanguageInfo() {
    return {
      'code': _currentLanguage,
      'name': getLanguageNameRu(),
      'nativeName': getLanguageName(),
      'locale': getLocale(),
      'direction': getTextDirection(),
      'dateFormat': getDateFormat(),
      'timeFormat': getTimeFormat(),
      'currencyFormat': getCurrencyFormat(),
    };
  }
}
