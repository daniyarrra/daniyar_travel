import 'package:flutter/foundation.dart';
import '../models/checklist_item.dart';
import '../services/checklist_service.dart';

/// Provider для управления чек-листом путешествия
/// Отвечает за создание, редактирование и выполнение задач
class ChecklistProvider with ChangeNotifier {
  // Список всех задач чек-листа
  List<ChecklistItem> _checklistItems = [];
  
  // Текущий маршрут для чек-листа
  String? _currentRouteId;
  
  // Состояние загрузки
  bool _isLoading = false;
  
  // Ошибка загрузки
  String? _error;

  // Геттеры для доступа к данным
  List<ChecklistItem> get checklistItems => _checklistItems;
  String? get currentRouteId => _currentRouteId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Сервис для работы с данными чек-листа
  final ChecklistService _checklistService = ChecklistService();

  /// Инициализация Provider'а
  Future<void> initialize() async {
    await loadChecklistItems();
  }

  /// Установка текущего маршрута для чек-листа
  void setCurrentRoute(String? routeId) {
    _currentRouteId = routeId;
    notifyListeners();
  }

  /// Загрузка задач чек-листа
  Future<void> loadChecklistItems() async {
    if (_currentRouteId == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _checklistItems = await _checklistService.loadChecklistItems(_currentRouteId!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка загрузки чек-листа: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Добавление новой задачи
  Future<void> addChecklistItem({
    required String title,
    String? description,
    required String category,
    int priority = 3,
  }) async {
    try {
      final newItem = ChecklistItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        category: category,
        priority: priority,
        createdAt: DateTime.now(),
      );

      await _checklistService.saveChecklistItem(_currentRouteId!, newItem);
      _checklistItems.add(newItem);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка добавления задачи: $e');
    }
  }

  /// Обновление задачи
  Future<void> updateChecklistItem(ChecklistItem item) async {
    try {
      await _checklistService.saveChecklistItem(_currentRouteId!, item);
      
      final index = _checklistItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _checklistItems[index] = item;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка обновления задачи: $e');
    }
  }

  /// Удаление задачи
  Future<void> deleteChecklistItem(String itemId) async {
    try {
      await _checklistService.deleteChecklistItem(_currentRouteId!, itemId);
      _checklistItems.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка удаления задачи: $e');
    }
  }

  /// Отметка задачи как выполненной
  Future<void> markAsCompleted(String itemId) async {
    try {
      final item = _checklistItems.firstWhere((i) => i.id == itemId);
      final updatedItem = item.markAsCompleted();
      await updateChecklistItem(updatedItem);
    } catch (e) {
      debugPrint('Ошибка отметки как выполненной: $e');
    }
  }

  /// Отметка задачи как невыполненной
  Future<void> markAsIncomplete(String itemId) async {
    try {
      final item = _checklistItems.firstWhere((i) => i.id == itemId);
      final updatedItem = item.markAsIncomplete();
      await updateChecklistItem(updatedItem);
    } catch (e) {
      debugPrint('Ошибка отметки как невыполненной: $e');
    }
  }

  /// Переключение статуса выполнения задачи
  Future<void> toggleCompletion(String itemId) async {
    try {
      final item = _checklistItems.firstWhere((i) => i.id == itemId);
      if (item.isCompleted) {
        await markAsIncomplete(itemId);
      } else {
        await markAsCompleted(itemId);
      }
    } catch (e) {
      debugPrint('Ошибка переключения статуса: $e');
    }
  }

  /// Получение выполненных задач
  List<ChecklistItem> get completedItems {
    return _checklistItems.where((item) => item.isCompleted).toList();
  }

  /// Получение невыполненных задач
  List<ChecklistItem> get incompleteItems {
    return _checklistItems.where((item) => !item.isCompleted).toList();
  }

  /// Получение задач по категории
  List<ChecklistItem> getItemsByCategory(String category) {
    return _checklistItems.where((item) => item.category == category).toList();
  }

  /// Получение задач по приоритету
  List<ChecklistItem> getItemsByPriority(int priority) {
    return _checklistItems.where((item) => item.priority == priority).toList();
  }

  /// Получение задач с высоким приоритетом
  List<ChecklistItem> getHighPriorityItems() {
    return _checklistItems.where((item) => item.priority >= 4).toList();
  }

  /// Получение задач с низким приоритетом
  List<ChecklistItem> getLowPriorityItems() {
    return _checklistItems.where((item) => item.priority <= 2).toList();
  }

  /// Получение задач, созданных за последние N дней
  List<ChecklistItem> getRecentItems(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _checklistItems.where((item) => item.createdAt.isAfter(cutoffDate)).toList();
  }

  /// Получение задач, выполненных за последние N дней
  List<ChecklistItem> getRecentlyCompletedItems(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _checklistItems.where((item) {
      return item.isCompleted && 
             item.completedAt != null && 
             item.completedAt!.isAfter(cutoffDate);
    }).toList();
  }

  /// Получение прогресса выполнения (0.0 - 1.0)
  double get completionProgress {
    if (_checklistItems.isEmpty) return 0.0;
    return completedItems.length / _checklistItems.length;
  }

  /// Получение прогресса по категориям
  Map<String, double> getCategoryProgress() {
    final progress = <String, double>{};
    
    for (final category in ChecklistCategory.values) {
      final categoryItems = getItemsByCategory(category.nameRu);
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
  Map<String, dynamic> getChecklistStatistics() {
    final totalItems = _checklistItems.length;
    final completedItems = this.completedItems.length;
    final incompleteItems = this.incompleteItems.length;
    
    // Статистика по приоритетам
    final priorityStats = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      priorityStats[i] = getItemsByPriority(i).length;
    }
    
    // Статистика по категориям
    final categoryStats = <String, int>{};
    for (final category in ChecklistCategory.values) {
      categoryStats[category.nameRu] = getItemsByCategory(category.nameRu).length;
    }
    
    // Средний приоритет
    final averagePriority = _checklistItems.isNotEmpty
        ? _checklistItems.map((item) => item.priority).reduce((a, b) => a + b) / _checklistItems.length
        : 0.0;
    
    return {
      'totalItems': totalItems,
      'completedItems': completedItems,
      'incompleteItems': incompleteItems,
      'completionProgress': completionProgress,
      'priorityStats': priorityStats,
      'categoryStats': categoryStats,
      'averagePriority': averagePriority,
    };
  }

  /// Получение уникальных категорий
  List<String> get categories {
    return _checklistItems.map((item) => item.category).toSet().toList();
  }

  /// Получение задач, отсортированных по приоритету
  List<ChecklistItem> getItemsSortedByPriority() {
    final sorted = List<ChecklistItem>.from(_checklistItems);
    sorted.sort((a, b) => b.priority.compareTo(a.priority));
    return sorted;
  }

  /// Получение задач, отсортированных по дате создания
  List<ChecklistItem> getItemsSortedByDate() {
    final sorted = List<ChecklistItem>.from(_checklistItems);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  /// Получение задач, отсортированных по статусу выполнения
  List<ChecklistItem> getItemsSortedByStatus() {
    final sorted = List<ChecklistItem>.from(_checklistItems);
    sorted.sort((a, b) {
      if (a.isCompleted == b.isCompleted) {
        return b.priority.compareTo(a.priority);
      }
      return a.isCompleted ? 1 : -1;
    });
    return sorted;
  }

  /// Создание предустановленных задач для нового путешествия
  Future<void> createDefaultChecklist() async {
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
      await addChecklistItem(
        title: task['title'] as String,
        description: task['description'] as String,
        category: task['category'] as String,
        priority: task['priority'] as int,
      );
    }
  }

  /// Очистка всех задач
  Future<void> clearAllItems() async {
    try {
      await _checklistService.clearChecklistItems(_currentRouteId!);
      _checklistItems.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка очистки чек-листа: $e');
    }
  }

  /// Экспорт чек-листа в JSON
  Map<String, dynamic> exportChecklist() {
    return {
      'routeId': _currentRouteId,
      'items': _checklistItems.map((item) => item.toJson()).toList(),
      'totalItems': _checklistItems.length,
      'completedItems': completedItems.length,
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  /// Импорт чек-листа из JSON
  Future<void> importChecklist(Map<String, dynamic> checklistData) async {
    try {
      final items = (checklistData['items'] as List)
          .map((itemData) => ChecklistItem.fromJson(itemData as Map<String, dynamic>))
          .toList();
      
      for (final item in items) {
        await _checklistService.saveChecklistItem(_currentRouteId!, item);
      }
      
      _checklistItems.addAll(items);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка импорта чек-листа: $e');
    }
  }
}
