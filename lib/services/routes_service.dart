import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/travel_route.dart';
import '../utils/constants.dart';

/// Сервис для работы с данными маршрутов путешествий
/// Отвечает за сохранение, загрузку и управление маршрутами
class RoutesService {
  /// Загрузка всех маршрутов из SharedPreferences
  Future<List<TravelRoute>> loadRoutes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final routesJson = prefs.getStringList(AppConstants.keyRoutes) ?? [];
      
      return routesJson.map((jsonString) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return TravelRoute.fromJson(json);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Сохранение маршрута в SharedPreferences
  Future<void> saveRoute(TravelRoute route) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final routes = await loadRoutes();
      
      // Удаляем старую версию маршрута, если она есть
      routes.removeWhere((r) => r.id == route.id);
      
      // Добавляем новый маршрут
      routes.add(route);
      
      // Сохраняем все маршруты
      final routesJson = routes.map((r) => jsonEncode(r.toJson())).toList();
      await prefs.setStringList(AppConstants.keyRoutes, routesJson);
    } catch (e) {
      throw Exception('Ошибка сохранения маршрута: $e');
    }
  }

  /// Удаление маршрута из SharedPreferences
  Future<void> deleteRoute(String routeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final routes = await loadRoutes();
      
      // Удаляем маршрут
      routes.removeWhere((route) => route.id == routeId);
      
      // Сохраняем обновленный список
      final routesJson = routes.map((r) => jsonEncode(r.toJson())).toList();
      await prefs.setStringList(AppConstants.keyRoutes, routesJson);
    } catch (e) {
      throw Exception('Ошибка удаления маршрута: $e');
    }
  }

  /// Получение маршрута по ID
  Future<TravelRoute?> getRouteById(String id) async {
    try {
      final routes = await loadRoutes();
      return routes.firstWhere((route) => route.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Получение активных маршрутов
  Future<List<TravelRoute>> getActiveRoutes() async {
    final routes = await loadRoutes();
    return routes.where((route) => !route.isCompleted).toList();
  }

  /// Получение завершенных маршрутов
  Future<List<TravelRoute>> getCompletedRoutes() async {
    final routes = await loadRoutes();
    return routes.where((route) => route.isCompleted).toList();
  }

  /// Получение маршрутов по дате
  Future<List<TravelRoute>> getRoutesByDate(DateTime date) async {
    final routes = await loadRoutes();
    return routes.where((route) {
      return route.startDate.year == date.year &&
             route.startDate.month == date.month &&
             route.startDate.day == date.day;
    }).toList();
  }

  /// Получение маршрутов по городу
  Future<List<TravelRoute>> getRoutesByCity(String city) async {
    final routes = await loadRoutes();
    return routes.where((route) {
      return route.places.any((place) => place.city == city);
    }).toList();
  }

  /// Получение маршрутов по бюджету
  Future<List<TravelRoute>> getRoutesByBudget(double minBudget, double maxBudget) async {
    final routes = await loadRoutes();
    return routes.where((route) {
      return route.budget >= minBudget && route.budget <= maxBudget;
    }).toList();
  }

  /// Получение статистики маршрутов
  Future<Map<String, dynamic>> getRoutesStatistics() async {
    final routes = await loadRoutes();
    
    final totalRoutes = routes.length;
    final completedRoutes = routes.where((r) => r.isCompleted).length;
    final activeRoutes = routes.where((r) => !r.isCompleted).length;
    
    double totalBudget = 0;
    int totalPlaces = 0;
    int totalDays = 0;
    
    for (final route in routes) {
      totalBudget += route.budget;
      totalPlaces += route.places.length;
      totalDays += route.getDuration();
    }
    
    return {
      'totalRoutes': totalRoutes,
      'completedRoutes': completedRoutes,
      'activeRoutes': activeRoutes,
      'totalBudget': totalBudget,
      'totalPlaces': totalPlaces,
      'totalDays': totalDays,
      'averageBudget': totalRoutes > 0 ? totalBudget / totalRoutes : 0,
      'averagePlaces': totalRoutes > 0 ? totalPlaces / totalRoutes : 0,
      'averageDays': totalRoutes > 0 ? totalDays / totalRoutes : 0,
    };
  }

  /// Экспорт маршрута в JSON
  Future<Map<String, dynamic>?> exportRoute(String routeId) async {
    final route = await getRouteById(routeId);
    return route?.toJson();
  }

  /// Импорт маршрута из JSON
  Future<void> importRoute(Map<String, dynamic> routeData) async {
    try {
      final route = TravelRoute.fromJson(routeData);
      await saveRoute(route);
    } catch (e) {
      throw Exception('Ошибка импорта маршрута: $e');
    }
  }

  /// Очистка всех маршрутов
  Future<void> clearAllRoutes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyRoutes);
    } catch (e) {
      throw Exception('Ошибка очистки маршрутов: $e');
    }
  }

  /// Создание резервной копии маршрутов
  Future<Map<String, dynamic>> createBackup() async {
    final routes = await loadRoutes();
    return {
      'routes': routes.map((r) => r.toJson()).toList(),
      'backupDate': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }

  /// Восстановление из резервной копии
  Future<void> restoreFromBackup(Map<String, dynamic> backupData) async {
    try {
      final routesData = backupData['routes'] as List;
      final routes = routesData.map((data) => TravelRoute.fromJson(data)).toList();
      
      final prefs = await SharedPreferences.getInstance();
      final routesJson = routes.map((r) => jsonEncode(r.toJson())).toList();
      await prefs.setStringList(AppConstants.keyRoutes, routesJson);
    } catch (e) {
      throw Exception('Ошибка восстановления из резервной копии: $e');
    }
  }
}
