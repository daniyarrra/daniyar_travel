import 'package:flutter/foundation.dart';
import '../models/place.dart';
import '../services/places_service.dart';

/// Provider для управления списком мест и достопримечательностей
/// Отвечает за загрузку, фильтрацию и поиск мест
class PlacesProvider with ChangeNotifier {
  // Список всех мест
  List<Place> _places = [];
  
  // Список избранных мест
  List<Place> _favoritePlaces = [];
  
  // Текущий поисковый запрос
  String _searchQuery = '';
  
  // Выбранная категория для фильтрации
  String _selectedCategory = '';
  
  // Выбранный город для фильтрации
  String _selectedCity = '';
  
  // Состояние загрузки
  bool _isLoading = false;
  
  // Ошибка загрузки
  String? _error;

  // Геттеры для доступа к данным
  List<Place> get places => _places;
  List<Place> get favoritePlaces => _favoritePlaces;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedCity => _selectedCity;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Сервис для работы с данными мест
  final PlacesService _placesService = PlacesService();

  /// Инициализация Provider'а
  /// Загружает данные при первом запуске
  Future<void> initialize() async {
    await loadPlaces();
    await loadFavoritePlaces();
  }

  /// Загрузка всех мест
  Future<void> loadPlaces() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _places = await _placesService.loadPlaces();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка загрузки мест: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Загрузка избранных мест
  Future<void> loadFavoritePlaces() async {
    try {
      _favoritePlaces = await _placesService.loadFavoritePlaces();
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка загрузки избранных мест: $e');
    }
  }

  /// Поиск мест по запросу
  void searchPlaces(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Фильтрация по категории
  void filterByCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Фильтрация по городу
  void filterByCity(String city) {
    _selectedCity = city;
    notifyListeners();
  }

  /// Очистка всех фильтров
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    _selectedCity = '';
    notifyListeners();
  }

  /// Получение отфильтрованного списка мест
  List<Place> get filteredPlaces {
    List<Place> filtered = List.from(_places);

    // Фильтрация по поисковому запросу
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((place) {
        return place.nameRu.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               place.nameKk.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               place.descriptionRu.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               place.descriptionKk.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               place.city.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               place.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // Фильтрация по категории
    if (_selectedCategory.isNotEmpty) {
      filtered = filtered.where((place) => place.category == _selectedCategory).toList();
    }

    // Фильтрация по городу
    if (_selectedCity.isNotEmpty) {
      filtered = filtered.where((place) => place.city == _selectedCity).toList();
    }

    return filtered;
  }

  /// Получение мест по категории
  List<Place> getPlacesByCategory(String category) {
    return _places.where((place) => place.category == category).toList();
  }

  /// Получение мест по городу
  List<Place> getPlacesByCity(String city) {
    return _places.where((place) => place.city == city).toList();
  }

  /// Получение популярных мест (с высоким рейтингом)
  List<Place> get popularPlaces {
    final sorted = List<Place>.from(_places);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(10).toList();
  }

  /// Получение недавно добавленных мест
  List<Place> get recentPlaces {
    // В реальном приложении здесь была бы сортировка по дате добавления
    return _places.take(10).toList();
  }

  /// Добавление места в избранное
  Future<void> addToFavorites(Place place) async {
    try {
      await _placesService.addToFavorites(place);
      _favoritePlaces.add(place);
      
      // Обновляем место в основном списке
      final index = _places.indexWhere((p) => p.id == place.id);
      if (index != -1) {
        _places[index] = place.copyWith(isFavorite: true);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка добавления в избранное: $e');
    }
  }

  /// Удаление места из избранного
  Future<void> removeFromFavorites(Place place) async {
    try {
      await _placesService.removeFromFavorites(place);
      _favoritePlaces.removeWhere((p) => p.id == place.id);
      
      // Обновляем место в основном списке
      final index = _places.indexWhere((p) => p.id == place.id);
      if (index != -1) {
        _places[index] = place.copyWith(isFavorite: false);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка удаления из избранного: $e');
    }
  }

  /// Переключение статуса избранного
  Future<void> toggleFavorite(Place place) async {
    if (place.isFavorite) {
      await removeFromFavorites(place);
    } else {
      await addToFavorites(place);
    }
  }

  /// Проверка, добавлено ли место в избранное
  bool isFavorite(Place place) {
    return _favoritePlaces.any((p) => p.id == place.id);
  }

  /// Получение места по ID
  Place? getPlaceById(String id) {
    try {
      return _places.firstWhere((place) => place.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Получение уникальных категорий
  List<String> get categories {
    final categories = _places.map((place) => place.category).toSet().toList();
    categories.sort();
    return categories;
  }

  /// Получение уникальных городов
  List<String> get cities {
    final cities = _places.map((place) => place.city).toSet().toList();
    cities.sort();
    return cities;
  }

  /// Обновление рейтинга места
  Future<void> updatePlaceRating(Place place, double newRating) async {
    try {
      final updatedPlace = place.copyWith(rating: newRating);
      
      // Обновляем в основном списке
      final index = _places.indexWhere((p) => p.id == place.id);
      if (index != -1) {
        _places[index] = updatedPlace;
      }
      
      // Обновляем в избранном, если есть
      final favoriteIndex = _favoritePlaces.indexWhere((p) => p.id == place.id);
      if (favoriteIndex != -1) {
        _favoritePlaces[favoriteIndex] = updatedPlace;
      }
      
      await _placesService.updatePlace(updatedPlace);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка обновления рейтинга: $e');
    }
  }

  /// Обновление данных места
  Future<void> updatePlace(Place place) async {
    try {
      // Обновляем в основном списке
      final index = _places.indexWhere((p) => p.id == place.id);
      if (index != -1) {
        _places[index] = place;
      }
      
      // Обновляем в избранном, если есть
      final favoriteIndex = _favoritePlaces.indexWhere((p) => p.id == place.id);
      if (favoriteIndex != -1) {
        _favoritePlaces[favoriteIndex] = place;
      }
      
      await _placesService.updatePlace(place);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка обновления места: $e');
    }
  }

  /// Добавление нового места
  Future<void> addPlace(Place place) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _placesService.addPlace(place);
      
      // Перезагружаем список мест, чтобы получить правильный ID от базы
      await loadPlaces();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка добавления места: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
