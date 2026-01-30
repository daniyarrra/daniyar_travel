import 'package:flutter/foundation.dart';
import '../models/travel_route.dart';
import '../models/place.dart';
import '../services/routes_service.dart';

/// Provider для управления маршрутами путешествий
/// Отвечает за создание, редактирование и удаление маршрутов
class RoutesProvider with ChangeNotifier {
  // Список всех маршрутов
  List<TravelRoute> _routes = [];
  
  // Текущий редактируемый маршрут
  TravelRoute? _currentRoute;
  
  // Состояние загрузки
  bool _isLoading = false;
  
  // Ошибка загрузки
  String? _error;

  // Геттеры для доступа к данным
  List<TravelRoute> get routes => _routes;
  TravelRoute? get currentRoute => _currentRoute;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Сервис для работы с данными маршрутов
  final RoutesService _routesService = RoutesService();

  /// Инициализация Provider'а
  Future<void> initialize() async {
    await loadRoutes();
  }

  /// Загрузка всех маршрутов
  Future<void> loadRoutes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _routes = await _routesService.loadRoutes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка загрузки маршрутов: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Создание нового маршрута
  Future<void> createRoute({
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    required double budget,
    String currency = 'KZT',
    String description = '',
  }) async {
    try {
      final newRoute = TravelRoute(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        places: [],
        startDate: startDate,
        endDate: endDate,
        budget: budget,
        currency: currency,
        description: description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _routesService.saveRoute(newRoute);
      _routes.add(newRoute);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка создания маршрута: $e');
    }
  }

  /// Обновление маршрута
  Future<void> updateRoute(TravelRoute route) async {
    try {
      final updatedRoute = route.copyWith(updatedAt: DateTime.now());
      
      await _routesService.saveRoute(updatedRoute);
      
      final index = _routes.indexWhere((r) => r.id == route.id);
      if (index != -1) {
        _routes[index] = updatedRoute;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка обновления маршрута: $e');
    }
  }

  /// Удаление маршрута
  Future<void> deleteRoute(String routeId) async {
    try {
      await _routesService.deleteRoute(routeId);
      _routes.removeWhere((route) => route.id == routeId);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка удаления маршрута: $e');
    }
  }

  /// Установка текущего маршрута для редактирования
  void setCurrentRoute(TravelRoute? route) {
    _currentRoute = route;
    notifyListeners();
  }

  /// Добавление места в маршрут
  Future<void> addPlaceToRoute(String routeId, Place place) async {
    try {
      final route = _routes.firstWhere((r) => r.id == routeId);
      
      // Проверяем, не добавлено ли уже это место
      if (route.places.any((p) => p.id == place.id)) {
        return;
      }

      final updatedPlaces = List<Place>.from(route.places)..add(place);
      final updatedRoute = route.copyWith(places: updatedPlaces);
      
      await updateRoute(updatedRoute);
    } catch (e) {
      debugPrint('Ошибка добавления места в маршрут: $e');
    }
  }

  /// Удаление места из маршрута
  Future<void> removePlaceFromRoute(String routeId, String placeId) async {
    try {
      final route = _routes.firstWhere((r) => r.id == routeId);
      final updatedPlaces = route.places.where((p) => p.id != placeId).toList();
      final updatedRoute = route.copyWith(places: updatedPlaces);
      
      await updateRoute(updatedRoute);
    } catch (e) {
      debugPrint('Ошибка удаления места из маршрута: $e');
    }
  }

  /// Перемещение места в маршруте (изменение порядка)
  Future<void> reorderPlacesInRoute(String routeId, int oldIndex, int newIndex) async {
    try {
      final route = _routes.firstWhere((r) => r.id == routeId);
      final updatedPlaces = List<Place>.from(route.places);
      
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      
      final place = updatedPlaces.removeAt(oldIndex);
      updatedPlaces.insert(newIndex, place);
      
      final updatedRoute = route.copyWith(places: updatedPlaces);
      await updateRoute(updatedRoute);
    } catch (e) {
      debugPrint('Ошибка изменения порядка мест: $e');
    }
  }

  /// Отметка маршрута как завершенного
  Future<void> completeRoute(String routeId) async {
    try {
      final route = _routes.firstWhere((r) => r.id == routeId);
      final updatedRoute = route.copyWith(isCompleted: true);
      await updateRoute(updatedRoute);
    } catch (e) {
      debugPrint('Ошибка завершения маршрута: $e');
    }
  }

  /// Получение маршрута по ID
  TravelRoute? getRouteById(String id) {
    try {
      return _routes.firstWhere((route) => route.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Получение активных маршрутов (не завершенных)
  List<TravelRoute> get activeRoutes {
    return _routes.where((route) => !route.isCompleted).toList();
  }

  /// Получение завершенных маршрутов
  List<TravelRoute> get completedRoutes {
    return _routes.where((route) => route.isCompleted).toList();
  }

  /// Получение маршрутов, которые начинаются в ближайшие дни
  List<TravelRoute> get upcomingRoutes {
    final now = DateTime.now();
    final upcoming = _routes.where((route) {
      return !route.isCompleted && 
             route.startDate.isAfter(now) && 
             route.startDate.difference(now).inDays <= 30;
    }).toList();
    
    upcoming.sort((a, b) => a.startDate.compareTo(b.startDate));
    return upcoming;
  }

  /// Получение маршрутов, которые проходят сейчас
  List<TravelRoute> get currentRoutes {
    final now = DateTime.now();
    return _routes.where((route) {
      return !route.isCompleted && 
             route.startDate.isBefore(now) && 
             route.endDate.isAfter(now);
    }).toList();
  }

  /// Получение маршрутов по дате
  List<TravelRoute> getRoutesByDate(DateTime date) {
    return _routes.where((route) {
      return route.startDate.year == date.year &&
             route.startDate.month == date.month &&
             route.startDate.day == date.day;
    }).toList();
  }

  /// Получение маршрутов по городу
  List<TravelRoute> getRoutesByCity(String city) {
    return _routes.where((route) {
      return route.places.any((place) => place.city == city);
    }).toList();
  }

  /// Получение маршрутов по бюджету
  List<TravelRoute> getRoutesByBudget(double minBudget, double maxBudget) {
    return _routes.where((route) {
      return route.budget >= minBudget && route.budget <= maxBudget;
    }).toList();
  }

  /// Получение статистики маршрутов
  Map<String, dynamic> getRoutesStatistics() {
    final totalRoutes = _routes.length;
    final completedRoutesCount = completedRoutes.length;
    final activeRoutesCount = activeRoutes.length;
    final upcomingRoutesCount = upcomingRoutes.length;
    
    double totalBudget = 0;
    int totalPlaces = 0;
    int totalDays = 0;
    
    for (final route in _routes) {
      totalBudget += route.budget;
      totalPlaces += route.places.length;
      totalDays += route.getDuration();
    }
    
    return {
      'totalRoutes': totalRoutes,
      'completedRoutes': completedRoutesCount,
      'activeRoutes': activeRoutesCount,
      'upcomingRoutes': upcomingRoutesCount,
      'totalBudget': totalBudget,
      'totalPlaces': totalPlaces,
      'totalDays': totalDays,
      'averageBudget': totalRoutes > 0 ? totalBudget / totalRoutes : 0,
      'averagePlaces': totalRoutes > 0 ? totalPlaces / totalRoutes : 0,
      'averageDays': totalRoutes > 0 ? totalDays / totalRoutes : 0,
    };
  }

  /// Клонирование маршрута
  Future<void> cloneRoute(String routeId) async {
    try {
      final originalRoute = _routes.firstWhere((r) => r.id == routeId);
      final clonedRoute = originalRoute.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '${originalRoute.name} (копия)',
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _routesService.saveRoute(clonedRoute);
      _routes.add(clonedRoute);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка клонирования маршрута: $e');
    }
  }

  /// Экспорт маршрута в JSON
  Map<String, dynamic> exportRoute(String routeId) {
    final route = _routes.firstWhere((r) => r.id == routeId);
    return route.toJson();
  }

  /// Импорт маршрута из JSON
  Future<void> importRoute(Map<String, dynamic> routeData) async {
    try {
      final route = TravelRoute.fromJson(routeData);
      await _routesService.saveRoute(route);
      _routes.add(route);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка импорта маршрута: $e');
    }
  }
}
