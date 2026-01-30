/// Константы приложения TravelKZ
/// Содержит все основные константы, используемые в приложении

class AppConstants {
  // Название приложения
  static const String appName = 'TravelKZ';
  static const String appVersion = '1.0.0';

  // Поддерживаемые языки
  static const String defaultLanguage = 'ru';
  static const List<String> supportedLanguages = ['ru', 'kk'];

  // Цвета приложения
  static const int primaryColorValue = 0xFF2196F3;      // Синий
  static const int secondaryColorValue = 0xFFFF9800;     // Оранжевый
  static const int accentColorValue = 0xFF4CAF50;        // Зеленый
  static const int errorColorValue = 0xFFF44336;         // Красный
  static const int warningColorValue = 0xFFFFC107;       // Желтый

  // Размеры и отступы
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Размеры карточек
  static const double cardHeight = 200.0;
  static const double cardWidth = 160.0;
  static const double imageHeight = 120.0;

  // Анимации
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // API и данные
  static const String baseImageUrl = 'https://images.unsplash.com/photo-';
  static const String placeholderImage = 'assets/images/placeholder.jpg';
  static const String logoImage = 'assets/images/logo.png';

  // Ключи для SharedPreferences
  static const String keyLanguage = 'language';
  static const String keyTheme = 'theme';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyFavorites = 'favorites';
  static const String keyRoutes = 'routes';
  static const String keyBudget = 'budget';
  static const String keyChecklist = 'checklist';

  // Категории мест
  static const List<String> placeCategories = [
    'Горы',
    'Города',
    'Пляжи',
    'Озера',
    'Парки',
    'Музеи',
    'Исторические места',
    'Природа',
    'Религиозные места',
    'Развлечения'
  ];

  // Категории мест на казахском языке
  static const List<String> placeCategoriesKk = [
    'Таулар',
    'Қалалар',
    'Пляждар',
    'Көлдер',
    'Парктер',
    'Мұражайлар',
    'Тарихи орындар',
    'Табиғат',
    'Діни орындар',
    'Ойын-сауық'
  ];

  // Популярные города Казахстана
  static const List<String> popularCities = [
    'Алматы',
    'Астана',
    'Шымкент',
    'Актобе',
    'Тараз',
    'Павлодар',
    'Семей',
    'Усть-Каменогорск',
    'Караганда',
    'Костанай',
    'Кызылорда',
    'Атырау',
    'Актау',
    'Туркестан',
    'Кокшетау'
  ];

  // Валюты
  static const List<String> currencies = ['KZT', 'USD', 'EUR', 'RUB'];

  // Размеры экранов для адаптивности
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Лимиты
  static const int maxPlacesInRoute = 20;
  static const int maxImageUrls = 10;
  static const int maxTags = 5;
  static const int maxDescriptionLength = 500;

  // Сообщения об ошибках
  static const String errorNetwork = 'Ошибка сети. Проверьте подключение к интернету.';
  static const String errorGeneric = 'Произошла ошибка. Попробуйте еще раз.';
  static const String errorNotFound = 'Данные не найдены.';
  static const String errorPermission = 'Недостаточно прав для выполнения операции.';

  // Сообщения об ошибках на казахском языке
  static const String errorNetworkKk = 'Желі қатесі. Интернет байланысын тексеріңіз.';
  static const String errorGenericKk = 'Қате орын алды. Қайталап көріңіз.';
  static const String errorNotFoundKk = 'Деректер табылмады.';
  static const String errorPermissionKk = 'Операцияны орындау үшін жеткілікті құқық жоқ.';

  /// Получение сообщения об ошибке на текущем языке
  static String getErrorMessage(String errorType, String languageCode) {
    if (languageCode == 'kk') {
      switch (errorType) {
        case 'network':
          return errorNetworkKk;
        case 'not_found':
          return errorNotFoundKk;
        case 'permission':
          return errorPermissionKk;
        default:
          return errorGenericKk;
      }
    } else {
      switch (errorType) {
        case 'network':
          return errorNetwork;
        case 'not_found':
          return errorNotFound;
        case 'permission':
          return errorPermission;
        default:
          return errorGeneric;
      }
    }
  }

  /// Получение категорий мест на текущем языке
  static List<String> getPlaceCategories(String languageCode) {
    return languageCode == 'kk' ? placeCategoriesKk : placeCategories;
  }
}
