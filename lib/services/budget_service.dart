import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/budget_item.dart';
import '../utils/constants.dart';

/// Сервис для работы с данными бюджета путешествия
/// Отвечает за сохранение, загрузку и управление статьями бюджета
class BudgetService {
  /// Загрузка статей бюджета для маршрута
  Future<List<BudgetItem>> loadBudgetItems(String routeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final budgetKey = '${AppConstants.keyBudget}_$routeId';
      final budgetJson = prefs.getStringList(budgetKey) ?? [];
      
      return budgetJson.map((jsonString) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return BudgetItem.fromJson(json);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Сохранение статьи бюджета
  Future<void> saveBudgetItem(String routeId, BudgetItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final budgetKey = '${AppConstants.keyBudget}_$routeId';
      final items = await loadBudgetItems(routeId);
      
      // Удаляем старую версию статьи, если она есть
      items.removeWhere((i) => i.id == item.id);
      
      // Добавляем новую статью
      items.add(item);
      
      // Сохраняем все статьи
      final itemsJson = items.map((i) => jsonEncode(i.toJson())).toList();
      await prefs.setStringList(budgetKey, itemsJson);
    } catch (e) {
      throw Exception('Ошибка сохранения статьи бюджета: $e');
    }
  }

  /// Удаление статьи бюджета
  Future<void> deleteBudgetItem(String routeId, String itemId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final budgetKey = '${AppConstants.keyBudget}_$routeId';
      final items = await loadBudgetItems(routeId);
      
      // Удаляем статью
      items.removeWhere((item) => item.id == itemId);
      
      // Сохраняем обновленный список
      final itemsJson = items.map((i) => jsonEncode(i.toJson())).toList();
      await prefs.setStringList(budgetKey, itemsJson);
    } catch (e) {
      throw Exception('Ошибка удаления статьи бюджета: $e');
    }
  }

  /// Получение статьи бюджета по ID
  Future<BudgetItem?> getBudgetItemById(String routeId, String itemId) async {
    try {
      final items = await loadBudgetItems(routeId);
      return items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  /// Получение статей по категории
  Future<List<BudgetItem>> getItemsByCategory(String routeId, String category) async {
    final items = await loadBudgetItems(routeId);
    return items.where((item) => item.category == category).toList();
  }

  /// Получение статей по валюте
  Future<List<BudgetItem>> getItemsByCurrency(String routeId, String currency) async {
    final items = await loadBudgetItems(routeId);
    return items.where((item) => item.currency == currency).toList();
  }

  /// Получение статей по дате
  Future<List<BudgetItem>> getItemsByDate(String routeId, DateTime date) async {
    final items = await loadBudgetItems(routeId);
    return items.where((item) {
      return item.date.year == date.year &&
             item.date.month == date.month &&
             item.date.day == date.day;
    }).toList();
  }

  /// Получение статей за период
  Future<List<BudgetItem>> getItemsByDateRange(String routeId, DateTime startDate, DateTime endDate) async {
    final items = await loadBudgetItems(routeId);
    return items.where((item) {
      return item.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             item.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Получение оплаченных статей
  Future<List<BudgetItem>> getPaidItems(String routeId) async {
    final items = await loadBudgetItems(routeId);
    return items.where((item) => item.isPaid).toList();
  }

  /// Получение неоплаченных статей
  Future<List<BudgetItem>> getUnpaidItems(String routeId) async {
    final items = await loadBudgetItems(routeId);
    return items.where((item) => !item.isPaid).toList();
  }

  /// Получение общей суммы бюджета
  Future<double> getTotalBudget(String routeId) async {
    final items = await loadBudgetItems(routeId);
    return items.fold<double>(0.0, (sum, item) => sum + item.amount);
  }

  /// Получение суммы оплаченных статей
  Future<double> getPaidAmount(String routeId) async {
    final paidItems = await getPaidItems(routeId);
    return paidItems.fold<double>(0.0, (sum, item) => sum + item.amount);
  }

  /// Получение суммы неоплаченных статей
  Future<double> getUnpaidAmount(String routeId) async {
    final unpaidItems = await getUnpaidItems(routeId);
    return unpaidItems.fold<double>(0.0, (sum, item) => sum + item.amount);
  }

  /// Получение статистики по категориям
  Future<Map<String, Map<String, double>>> getCategoryStatistics(String routeId) async {
    final items = await loadBudgetItems(routeId);
    final statistics = <String, Map<String, double>>{};
    
    for (final category in BudgetCategory.values) {
      final categoryItems = items.where((item) => item.category == category.nameRu).toList();
      final totalAmount = categoryItems.fold(0.0, (sum, item) => sum + item.amount);
      final paidAmount = categoryItems
          .where((item) => item.isPaid)
          .fold(0.0, (sum, item) => sum + item.amount);
      
      statistics[category.nameRu] = {
        'total': totalAmount,
        'paid': paidAmount,
        'unpaid': totalAmount - paidAmount,
        'percentage': 0.0, // Будет вычислено отдельно
      };
    }
    
    // Вычисляем проценты
    final totalBudget = await getTotalBudget(routeId);
    if (totalBudget > 0) {
      for (final category in statistics.keys) {
        final categoryTotal = statistics[category]!['total']!;
        statistics[category]!['percentage'] = (categoryTotal / totalBudget) * 100;
      }
    }
    
    return statistics;
  }

  /// Получение статистики по валютам
  Future<Map<String, double>> getCurrencyStatistics(String routeId) async {
    final items = await loadBudgetItems(routeId);
    final statistics = <String, double>{};
    
    for (final item in items) {
      statistics[item.currency] = (statistics[item.currency] ?? 0) + item.amount;
    }
    
    return statistics;
  }

  /// Получение статистики по месяцам
  Future<Map<String, double>> getMonthlyStatistics(String routeId) async {
    final items = await loadBudgetItems(routeId);
    final statistics = <String, double>{};
    
    for (final item in items) {
      final monthKey = '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}';
      statistics[monthKey] = (statistics[monthKey] ?? 0) + item.amount;
    }
    
    return statistics;
  }

  /// Получение самых дорогих статей
  Future<List<BudgetItem>> getMostExpensiveItems(String routeId, {int limit = 5}) async {
    final items = await loadBudgetItems(routeId);
    final sorted = List<BudgetItem>.from(items);
    sorted.sort((a, b) => b.amount.compareTo(a.amount));
    return sorted.take(limit).toList();
  }

  /// Получение самых дешевых статей
  Future<List<BudgetItem>> getCheapestItems(String routeId, {int limit = 5}) async {
    final items = await loadBudgetItems(routeId);
    final sorted = List<BudgetItem>.from(items);
    sorted.sort((a, b) => a.amount.compareTo(b.amount));
    return sorted.take(limit).toList();
  }

  /// Получение среднего размера статьи
  Future<double> getAverageItemAmount(String routeId) async {
    final items = await loadBudgetItems(routeId);
    if (items.isEmpty) return 0.0;
    
    final totalAmount = items.fold(0.0, (sum, item) => sum + item.amount);
    return totalAmount / items.length;
  }

  /// Очистка всех статей бюджета для маршрута
  Future<void> clearBudgetItems(String routeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final budgetKey = '${AppConstants.keyBudget}_$routeId';
      await prefs.remove(budgetKey);
    } catch (e) {
      throw Exception('Ошибка очистки бюджета: $e');
    }
  }

  /// Экспорт бюджета в JSON
  Future<Map<String, dynamic>> exportBudget(String routeId) async {
    final items = await loadBudgetItems(routeId);
    final totalBudget = await getTotalBudget(routeId);
    final paidAmount = await getPaidAmount(routeId);
    final unpaidAmount = await getUnpaidAmount(routeId);
    
    return {
      'routeId': routeId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalBudget': totalBudget,
      'paidAmount': paidAmount,
      'unpaidAmount': unpaidAmount,
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  /// Импорт бюджета из JSON
  Future<void> importBudget(String routeId, Map<String, dynamic> budgetData) async {
    try {
      final itemsData = budgetData['items'] as List;
      final items = itemsData.map((data) => BudgetItem.fromJson(data)).toList();
      
      for (final item in items) {
        await saveBudgetItem(routeId, item);
      }
    } catch (e) {
      throw Exception('Ошибка импорта бюджета: $e');
    }
  }

  /// Создание резервной копии бюджета
  Future<Map<String, dynamic>> createBackup(String routeId) async {
    final items = await loadBudgetItems(routeId);
    return {
      'routeId': routeId,
      'items': items.map((item) => item.toJson()).toList(),
      'backupDate': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }

  /// Восстановление из резервной копии
  Future<void> restoreFromBackup(String routeId, Map<String, dynamic> backupData) async {
    try {
      final itemsData = backupData['items'] as List;
      final items = itemsData.map((data) => BudgetItem.fromJson(data)).toList();
      
      for (final item in items) {
        await saveBudgetItem(routeId, item);
      }
    } catch (e) {
      throw Exception('Ошибка восстановления из резервной копии: $e');
    }
  }
}
