# Руководство по разработке TravelKZ

## Обзор архитектуры

TravelKZ построен с использованием архитектуры MVVM (Model-View-ViewModel) с Provider для управления состоянием.

## Структура проекта

```
lib/
├── models/              # Модели данных
│   ├── place.dart
│   ├── travel_route.dart
│   ├── budget_item.dart
│   └── checklist_item.dart
├── providers/           # Provider'ы для состояния
│   ├── places_provider.dart
│   ├── routes_provider.dart
│   ├── budget_provider.dart
│   ├── checklist_provider.dart
│   ├── language_provider.dart
│   └── theme_provider.dart
├── services/            # Сервисы для данных
│   ├── places_service.dart
│   ├── routes_service.dart
│   ├── budget_service.dart
│   └── checklist_service.dart
├── screens/             # Экраны приложения
│   ├── home_screen.dart
│   ├── search_screen.dart
│   ├── place_detail_screen.dart
│   ├── favorites_screen.dart
│   ├── routes_screen.dart
│   ├── create_route_screen.dart
│   └── settings_screen.dart
├── widgets/             # Переиспользуемые виджеты
│   ├── place_card.dart
│   ├── category_chip.dart
│   ├── rating_stars.dart
│   ├── custom_button.dart
│   └── empty_state.dart
├── utils/               # Утилиты
│   ├── constants.dart
│   └── helpers.dart
└── main.dart           # Точка входа
```

## Принципы разработки

### 1. Управление состоянием

Используется Provider для управления состоянием:

```dart
// Чтение состояния
final provider = context.watch<PlacesProvider>();

// Изменение состояния
context.read<PlacesProvider>().addPlace(place);
```

### 2. Модели данных

Все модели должны иметь:
- `fromJson` и `toJson` методы
- `copyWith` метод для обновления
- Неизменяемые поля (final)

```dart
class Place {
  final String id;
  final String nameRu;
  final String nameKk;
  // ... другие поля

  const Place({
    required this.id,
    required this.nameRu,
    required this.nameKk,
    // ... другие параметры
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    // Реализация
  }

  Map<String, dynamic> toJson() {
    // Реализация
  }

  Place copyWith({
    String? id,
    String? nameRu,
    String? nameKk,
    // ... другие параметры
  }) {
    // Реализация
  }
}
```

### 3. Provider'ы

Provider'ы должны:
- Наследоваться от `ChangeNotifier`
- Содержать бизнес-логику
- Уведомлять слушателей об изменениях
- Обрабатывать ошибки

```dart
class PlacesProvider extends ChangeNotifier {
  List<Place> _places = [];
  bool _isLoading = false;
  String? _error;

  List<Place> get places => _places;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPlaces() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _places = await PlacesService.loadPlaces();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

### 4. Сервисы

Сервисы должны:
- Содержать логику работы с данными
- Быть статическими или синглтонами
- Обрабатывать ошибки
- Возвращать Future для асинхронных операций

```dart
class PlacesService {
  static Future<List<Place>> loadPlaces() async {
    try {
      // Загрузка данных
      return places;
    } catch (e) {
      throw Exception('Ошибка загрузки мест: $e');
    }
  }
}
```

### 5. Виджеты

Виджеты должны:
- Быть переиспользуемыми
- Принимать параметры через конструктор
- Использовать Provider для доступа к состоянию
- Обрабатывать ошибки

```dart
class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback? onTap;

  const PlaceCard({
    super.key,
    required this.place,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          color: themeProvider.getCardColor(),
          child: // ... реализация
        );
      },
    );
  }
}
```

## Работа с данными

### Локальное хранение

Используется Hive для локального хранения:

```dart
// Инициализация
await Hive.initFlutter();
await Hive.openBox<Place>('places');

// Сохранение
final box = Hive.box<Place>('places');
await box.put(place.id, place);

// Загрузка
final place = box.get(placeId);
```

### Настройки

Используется SharedPreferences для настроек:

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('language', 'ru');
final language = prefs.getString('language') ?? 'ru';
```

## Интернационализация

### Добавление нового языка

1. Создайте новый Provider для языка
2. Добавьте переводы в `LanguageProvider`
3. Обновите UI для поддержки нового языка

```dart
class LanguageProvider extends ChangeNotifier {
  String _currentLanguage = 'ru';

  String get currentLanguage => _currentLanguage;

  String getLocalizedText(String russian, String kazakh) {
    switch (_currentLanguage) {
      case 'kk':
        return kazakh;
      default:
        return russian;
    }
  }
}
```

## Темы

### Добавление новой темы

1. Расширьте `ThemeProvider`
2. Добавьте новые цвета и стили
3. Обновите UI компоненты

```dart
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  Color getPrimaryColor() {
    return _isDarkMode ? Colors.blue[800]! : Colors.blue[600]!;
  }
}
```

## Тестирование

### Unit тесты

Создайте тесты для Provider'ов и сервисов:

```dart
void main() {
  group('PlacesProvider', () {
    test('should load places successfully', () async {
      // Тест
    });
  });
}
```

### Widget тесты

Создайте тесты для виджетов:

```dart
void main() {
  testWidgets('PlaceCard displays place information', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PlaceCard(place: testPlace),
      ),
    );

    expect(find.text(testPlace.nameRu), findsOneWidget);
  });
}
```

## Отладка

### Логирование

Используйте `print` или `debugPrint` для отладки:

```dart
debugPrint('Loading places...');
```

### Обработка ошибок

Всегда обрабатывайте ошибки:

```dart
try {
  await someAsyncOperation();
} catch (e) {
  debugPrint('Error: $e');
  // Обработка ошибки
}
```

## Производительность

### Оптимизация изображений

Используйте `cached_network_image` для кэширования:

```dart
CachedNetworkImage(
  imageUrl: place.imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### Ленивая загрузка

Используйте `ListView.builder` для больших списков:

```dart
ListView.builder(
  itemCount: places.length,
  itemBuilder: (context, index) {
    return PlaceCard(place: places[index]);
  },
)
```

## Развертывание

### Android

1. Создайте keystore
2. Настройте `android/app/build.gradle`
3. Запустите `flutter build apk`

### iOS

1. Настройте сертификаты
2. Запустите `flutter build ios`

### Web

1. Запустите `flutter build web`
2. Разместите файлы на веб-сервере

## Лучшие практики

1. **Именование**: Используйте описательные имена
2. **Комментарии**: Комментируйте сложную логику
3. **Константы**: Выносите магические числа в константы
4. **Ошибки**: Всегда обрабатывайте ошибки
5. **Тесты**: Покрывайте код тестами
6. **Производительность**: Оптимизируйте производительность
7. **Безопасность**: Не храните чувствительные данные в коде

## Полезные ресурсы

- [Flutter документация](https://flutter.dev/docs)
- [Provider документация](https://pub.dev/packages/provider)
- [Hive документация](https://pub.dev/packages/hive)
- [Material Design](https://material.io/design)
