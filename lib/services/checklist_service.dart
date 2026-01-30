import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/checklist_item.dart';
import '../utils/constants.dart';

/// Сервис для работы с данными чек-листа путешествия
/// Отвечает за сохранение, загрузку и управление задачами чек-листа
class ChecklistService {
  /// Загрузка задач чек-листа для маршрута
  Future<List<ChecklistItem>> loadChecklistItems(String routeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final checklistKey = '${AppConstants.keyChecklist}_$routeId';
      final checklistJson = prefs.getStringList(checklistKey) ?? [];
      
      return checklistJson.map((jsonString) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return ChecklistItem.fromJson(json);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Сохранение задачи чек-листа
  Future<void> saveChecklistItem(String routeId, ChecklistItem item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final checklistKey = '${AppConstants.keyChecklist}_$routeId';
      final items = await loadChecklistItems(routeId);
      
      // Удаляем старую версию задачи, если она есть
      items.removeWhere((i) => i.id == item.id);
      
      // Добавляем новую задачу
      items.add(item);
      
      // Сохраняем все задачи
      final itemsJson = items.map((i) => jsonEncode(i.toJson())).toList();
      await prefs.setStringList(checklistKey, itemsJson);
    } catch (e) {
      throw Exception('Ошибка сохранения задачи чек-листа: $e');
    }
  }

  /// Удаление задачи чек-листа
  Future<void> deleteChecklistItem(String routeId, String itemId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final checklistKey = '${AppConstants.keyChecklist}_$routeId';
      final items = await loadChecklistItems(routeId);
      
      // Удаляем задачу
      items.removeWhere((item) => item.id == itemId);
      
      // Сохраняем обновленный список
      final itemsJson = items.map((i) => jsonEncode(i.toJson())).toList();
      await prefs.setStringList(checklistKey, itemsJson);
    } catch (e) {
      throw Exception('Ошибка удаления задачи чек-листа: $e');
    }
  }

  /// Получение задачи по ID
  Future<ChecklistItem?> getChecklistItemById(String routeId, String itemId) async {
    try {
      final items = await loadChecklistItems(routeId);
      return items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  /// Получение задач по категории
  Future<List<ChecklistItem>> getItemsByCategory(String routeId, String category) async {
    final items = await loadChecklistItems(routeId);
    return items.where((item) => item.category == category).toList();
  }

  /// Получение задач по приоритету
  Future<List<ChecklistItem>> getItemsByPriority(String routeId, int priority) async {
    final items = await loadChecklistItems(routeId);
    return items.where((item) => item.priority == priority).toList();
  }

  /// Получение выполненных задач
  Future<List<ChecklistItem>> getCompletedItems(String routeId) async {
    final items = await loadChecklistItems(routeId);
    return items.where((item) => item.isCompleted).toList();
  }

  /// Получение невыполненных задач
  Future<List<ChecklistItem>> getIncompleteItems(String routeId) async {
    final items = await loadChecklistItems(routeId);
    return items.where((item) => !item.isCompleted).toList();
  }

  /// Получение задач с высоким приоритетом
  Future<List<ChecklistItem>> getHighPriorityItems(String routeId) async {
    final items = await loadChecklistItems(routeId);
    return items.where((item) => item.priority >= 4).toList();
  }

  /// Получение задач с низким приоритетом
  Future<List<ChecklistItem>> getLowPriorityItems(String routeId) async {
    final items = await loadChecklistItems(routeId);
    return items.where((item) => item.priority <= 2).toList();
  }

  /// Получение задач, созданных за последние N дней
  Future<List<ChecklistItem>> getRecentItems(String routeId, int days) async {
    final items = await loadChecklistItems(routeId);
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return items.where((item) => item.createdAt.isAfter(cutoffDate)).toList();
  }

  /// Получение задач, выполненных за последние N дней
  Future<List<ChecklistItem>> getRecentlyCompletedItems(String routeId, int days) async {
    final items = await loadChecklistItems(routeId);
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return items.where((item) {
      return item.isCompleted && 
             item.completedAt != null && 
             item.completedAt!.isAfter(cutoffDate);
    }).toList();
  }

  /// Получение прогресса выполнения
  Future<double> getCompletionProgress(String routeId) async {
    final items = await loadChecklistItems(routeId);
    if (items.isEmpty) return 0.0;
    
    final completedCount = items.where((item) => item.isCompleted).length;
    return completedCount / items.length;
  }

  /// Получение прогресса по категориям
  Future<Map<String, double>> getCategoryProgress(String routeId) async {
    final items = await loadChecklistItems(routeId);
    final progress = <String, double>{};
    
    for (final category in ChecklistCategory.values) {
      final categoryItems = items.where((item) => item.category == category.nameRu).toList();
      if (categoryItems.isNotEmpty) {
        final completedCount = categoryItems.where((item) => item.isCompleted).length;
        progress[category.nameRu] = completedCount / categoryItems.length;
      } else {
        progress[category.nameRu] = 0.0;
      }
    }
    
    return progress;
  }

  /// Получение статистики чек-листа
  Future<Map<String, dynamic>> getChecklistStatistics(String routeId) async {
    final items = await loadChecklistItems(routeId);
    final totalItems = items.length;
    final completedItems = items.where((item) => item.isCompleted).length;
    final incompleteItems = totalItems - completedItems;
    
    // Статистика по приоритетам
    final priorityStats = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      priorityStats[i] = items.where((item) => item.priority == i).length;
    }
    
    // Статистика по категориям
    final categoryStats = <String, int>{};
    for (final category in ChecklistCategory.values) {
      categoryStats[category.nameRu] = items.where((item) => item.category == category.nameRu).length;
    }
    
    // Средний приоритет
    final averagePriority = items.isNotEmpty
        ? items.map((item) => item.priority).reduce((a, b) => a + b) / items.length
        : 0.0;
    
    return {
      'totalItems': totalItems,
      'completedItems': completedItems,
      'incompleteItems': incompleteItems,
      'completionProgress': totalItems > 0 ? completedItems / totalItems : 0.0,
      'priorityStats': priorityStats,
      'categoryStats': categoryStats,
      'averagePriority': averagePriority,
    };
  }

  /// Получение задач, отсортированных по приоритету
  Future<List<ChecklistItem>> getItemsSortedByPriority(String routeId) async {
    final items = await loadChecklistItems(routeId);
    final sorted = List<ChecklistItem>.from(items);
    sorted.sort((a, b) => b.priority.compareTo(a.priority));
    return sorted;
  }

  /// Получение задач, отсортированных по дате создания
  Future<List<ChecklistItem>> getItemsSortedByDate(String routeId) async {
    final items = await loadChecklistItems(routeId);
    final sorted = List<ChecklistItem>.from(items);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  /// Получение задач, отсортированных по статусу выполнения
  Future<List<ChecklistItem>> getItemsSortedByStatus(String routeId) async {
    final items = await loadChecklistItems(routeId);
    final sorted = List<ChecklistItem>.from(items);
    sorted.sort((a, b) {
      if (a.isCompleted == b.isCompleted) {
        return b.priority.compareTo(a.priority);
      }
      return a.isCompleted ? 1 : -1;
    });
    return sorted;
  }

  /// Создание предустановленных задач для нового путешествия
  Future<void> createDefaultChecklist(String routeId) async {
    final defaultTasks = [
      {
        'title': 'Проверить паспорт',
        'description': 'Убедиться, что паспорт действителен',
        'category': ChecklistCategory.documents.nameRu,
        'priority': 5,
      },
      {
        'title': 'Забронировать билеты',
        'description': 'Купить билеты на транспорт',
        'category': ChecklistCategory.transport.nameRu,
        'priority': 5,
      },
      {
        'title': 'Забронировать жилье',
        'description': 'Найти и забронировать отель/хостел',
        'category': ChecklistCategory.accommodation.nameRu,
        'priority': 4,
      },
      {
        'title': 'Собрать чемодан',
        'description': 'Подготовить вещи для путешествия',
        'category': ChecklistCategory.packing.nameRu,
        'priority': 3,
      },
      {
        'title': 'Обменять валюту',
        'description': 'Подготовить местную валюту',
        'category': ChecklistCategory.money.nameRu,
        'priority': 4,
      },
      {
        'title': 'Проверить здоровье',
        'description': 'Посетить врача при необходимости',
        'category': ChecklistCategory.health.nameRu,
        'priority': 3,
      },
    ];

    for (final task in defaultTasks) {
      final item = ChecklistItem(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_${task['title']}',
        title: task['title'] as String,
        description: task['description'] as String,
        category: task['category'] as String,
        priority: task['priority'] as int,
        createdAt: DateTime.now(),
      );
      
      await saveChecklistItem(routeId, item);
    }
  }

  /// Очистка всех задач чек-листа для маршрута
  Future<void> clearChecklistItems(String routeId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final checklistKey = '${AppConstants.keyChecklist}_$routeId';
      await prefs.remove(checklistKey);
    } catch (e) {
      throw Exception('Ошибка очистки чек-листа: $e');
    }
  }

  /// Экспорт чек-листа в JSON
  Future<Map<String, dynamic>> exportChecklist(String routeId) async {
    final items = await loadChecklistItems(routeId);
    final completedItems = await getCompletedItems(routeId);
    
    return {
      'routeId': routeId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalItems': items.length,
      'completedItems': completedItems.length,
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  /// Импорт чек-листа из JSON
  Future<void> importChecklist(String routeId, Map<String, dynamic> checklistData) async {
    try {
      final itemsData = checklistData['items'] as List;
      final items = itemsData.map((data) => ChecklistItem.fromJson(data)).toList();
      
      for (final item in items) {
        await saveChecklistItem(routeId, item);
      }
    } catch (e) {
      throw Exception('Ошибка импорта чек-листа: $e');
    }
  }

  /// Создание резервной копии чек-листа
  Future<Map<String, dynamic>> createBackup(String routeId) async {
    final items = await loadChecklistItems(routeId);
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
      final items = itemsData.map((data) => ChecklistItem.fromJson(data)).toList();
      
      for (final item in items) {
        await saveChecklistItem(routeId, item);
      }
    } catch (e) {
      throw Exception('Ошибка восстановления из резервной копии: $e');
    }
  }
}
