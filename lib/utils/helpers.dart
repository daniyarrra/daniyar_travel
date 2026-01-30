import 'package:intl/intl.dart';

/// Утилиты и вспомогательные функции для приложения TravelKZ

class AppHelpers {
  /// Форматирование даты в читаемый вид
  /// Пример: "15 октября 2024"
  static String formatDate(DateTime date, String languageCode) {
    final locale = languageCode == 'kk' ? 'kk_KZ' : 'ru_RU';
    final formatter = DateFormat('d MMMM yyyy', locale);
    return formatter.format(date);
  }

  /// Форматирование даты в короткий вид
  /// Пример: "15.10.2024"
  static String formatDateShort(DateTime date) {
    final formatter = DateFormat('dd.MM.yyyy');
    return formatter.format(date);
  }

  /// Форматирование времени
  /// Пример: "14:30"
  static String formatTime(DateTime time) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(time);
  }

  /// Форматирование суммы с валютой
  /// Пример: "1 000 000 ₸"
  static String formatCurrency(double amount, String currency) {
    final formatter = NumberFormat('#,##0', 'ru_RU');
    final formattedAmount = formatter.format(amount);
    
    switch (currency) {
      case 'KZT':
        return '$formattedAmount ₸';
      case 'USD':
        return '\$$formattedAmount';
      case 'EUR':
        return '€$formattedAmount';
      case 'RUB':
        return '$formattedAmount ₽';
      default:
        return '$formattedAmount $currency';
    }
  }

  /// Форматирование рейтинга
  /// Пример: "4.5 ★"
  static String formatRating(double rating) {
    return '${rating.toStringAsFixed(1)} ★';
  }

  /// Получение относительного времени
  /// Пример: "2 дня назад", "через 3 часа"
  static String getRelativeTime(DateTime dateTime, String languageCode) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (languageCode == 'kk') {
      if (difference.inDays > 0) {
        return '${difference.inDays} күн бұрын';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} сағат бұрын';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} минут бұрын';
      } else {
        return 'Жаңа ғана';
      }
    } else {
      if (difference.inDays > 0) {
        return '${difference.inDays} дней назад';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} часов назад';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} минут назад';
      } else {
        return 'Только что';
      }
    }
  }

  /// Получение прогресса в процентах
  /// Пример: "75%"
  static String formatProgress(double progress) {
    return '${(progress * 100).round()}%';
  }

  /// Получение продолжительности в читаемом виде
  /// Пример: "3 дня 2 часа"
  static String formatDuration(Duration duration, String languageCode) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (languageCode == 'kk') {
      if (days > 0 && hours > 0) {
        return '$days күн $hours сағат';
      } else if (days > 0) {
        return '$days күн';
      } else if (hours > 0) {
        return '$hours сағат';
      } else {
        return '$minutes минут';
      }
    } else {
      if (days > 0 && hours > 0) {
        return '$days дня $hours часов';
      } else if (days > 0) {
        return '$days дня';
      } else if (hours > 0) {
        return '$hours часов';
      } else {
        return '$minutes минут';
      }
    }
  }

  /// Валидация email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Валидация телефона
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(phone.replaceAll(' ', ''));
  }

  /// Генерация уникального ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Получение инициалов из имени
  static String getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  /// Обрезка текста с многоточием
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Получение цвета по категории
  static int getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'горы':
      case 'таулар':
        return 0xFF4CAF50; // Зеленый
      case 'города':
      case 'қалалар':
        return 0xFF2196F3; // Синий
      case 'пляжи':
      case 'пляждар':
        return 0xFF00BCD4; // Голубой
      case 'озера':
      case 'көлдер':
        return 0xFF03A9F4; // Светло-синий
      case 'парки':
      case 'парктер':
        return 0xFF8BC34A; // Светло-зеленый
      case 'музеи':
      case 'мұражайлар':
        return 0xFF9C27B0; // Фиолетовый
      case 'исторические места':
      case 'тарихи орындар':
        return 0xFFFF9800; // Оранжевый
      case 'природа':
      case 'табиғат':
        return 0xFF4CAF50; // Зеленый
      case 'религиозные места':
      case 'діни орындар':
        return 0xFF795548; // Коричневый
      case 'развлечения':
      case 'ойын-сауық':
        return 0xFFE91E63; // Розовый
      default:
        return 0xFF607D8B; // Серо-синий
    }
  }

  /// Получение иконки по категории
  static String getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'горы':
      case 'таулар':
        return '🏔️';
      case 'города':
      case 'қалалар':
        return '🏙️';
      case 'пляжи':
      case 'пляждар':
        return '🏖️';
      case 'озера':
      case 'көлдер':
        return '🏞️';
      case 'парки':
      case 'парктер':
        return '🌳';
      case 'музеи':
      case 'мұражайлар':
        return '🏛️';
      case 'исторические места':
      case 'тарихи орындар':
        return '🏺';
      case 'природа':
      case 'табиғат':
        return '🌿';
      case 'религиозные места':
      case 'діни орындар':
        return '🕌';
      case 'развлечения':
      case 'ойын-сауық':
        return '🎢';
      default:
        return '📍';
    }
  }

  /// Проверка, является ли дата сегодняшней
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Проверка, является ли дата завтрашней
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && 
           date.month == tomorrow.month && 
           date.day == tomorrow.day;
  }

  /// Получение дня недели на русском языке
  static String getWeekdayName(DateTime date, String languageCode) {
    if (languageCode == 'kk') {
      const weekdays = ['Дүйсенбі', 'Сейсенбі', 'Сәрсенбі', 'Бейсенбі', 'Жұма', 'Сенбі', 'Жексенбі'];
      return weekdays[date.weekday - 1];
    } else {
      const weekdays = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
      return weekdays[date.weekday - 1];
    }
  }
}
