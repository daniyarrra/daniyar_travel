import 'package:flutter/foundation.dart';
import '../models/budget_item.dart';
import '../services/budget_service.dart';

/// Provider для управления бюджетом путешествия
/// Отвечает за добавление, редактирование и удаление статей бюджета
class BudgetProvider with ChangeNotifier {
  // Список всех статей бюджета
  List<BudgetItem> _budgetItems = [];
  
  // Текущий маршрут для бюджета
  String? _currentRouteId;
  
  // Состояние загрузки
  bool _isLoading = false;
  
  // Ошибка загрузки
  String? _error;

  // Геттеры для доступа к данным
  List<BudgetItem> get budgetItems => _budgetItems;
  String? get currentRouteId => _currentRouteId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Сервис для работы с данными бюджета
  final BudgetService _budgetService = BudgetService();

  /// Инициализация Provider'а
  Future<void> initialize() async {
    await loadBudgetItems();
  }

  /// Установка текущего маршрута для бюджета
  void setCurrentRoute(String? routeId) {
    _currentRouteId = routeId;
    notifyListeners();
  }

  /// Загрузка статей бюджета
  Future<void> loadBudgetItems() async {
    if (_currentRouteId == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _budgetItems = await _budgetService.loadBudgetItems(_currentRouteId!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Ошибка загрузки бюджета: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Добавление новой статьи бюджета
  Future<void> addBudgetItem({
    required String category,
    required double amount,
    String currency = 'KZT',
    String description = '',
    DateTime? date,
    String? notes,
  }) async {
    try {
      final newItem = BudgetItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: category,
        amount: amount,
        currency: currency,
        description: description,
        date: date ?? DateTime.now(),
        notes: notes,
      );

      await _budgetService.saveBudgetItem(_currentRouteId!, newItem);
      _budgetItems.add(newItem);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка добавления статьи бюджета: $e');
    }
  }

  /// Обновление статьи бюджета
  Future<void> updateBudgetItem(BudgetItem item) async {
    try {
      await _budgetService.saveBudgetItem(_currentRouteId!, item);
      
      final index = _budgetItems.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _budgetItems[index] = item;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка обновления статьи бюджета: $e');
    }
  }

  /// Удаление статьи бюджета
  Future<void> deleteBudgetItem(String itemId) async {
    try {
      await _budgetService.deleteBudgetItem(_currentRouteId!, itemId);
      _budgetItems.removeWhere((item) => item.id == itemId);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка удаления статьи бюджета: $e');
    }
  }

  /// Отметка статьи как оплаченной
  Future<void> markAsPaid(String itemId) async {
    try {
      final item = _budgetItems.firstWhere((i) => i.id == itemId);
      final updatedItem = item.copyWith(isPaid: true);
      await updateBudgetItem(updatedItem);
    } catch (e) {
      debugPrint('Ошибка отметки как оплаченной: $e');
    }
  }

  /// Отметка статьи как неоплаченной
  Future<void> markAsUnpaid(String itemId) async {
    try {
      final item = _budgetItems.firstWhere((i) => i.id == itemId);
      final updatedItem = item.copyWith(isPaid: false);
      await updateBudgetItem(updatedItem);
    } catch (e) {
      debugPrint('Ошибка отметки как неоплаченной: $e');
    }
  }

  /// Получение общей суммы бюджета
  double get totalBudget {
    return _budgetItems.fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Получение суммы оплаченных статей
  double get paidAmount {
    return _budgetItems
        .where((item) => item.isPaid)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Получение суммы неоплаченных статей
  double get unpaidAmount {
    return _budgetItems
        .where((item) => !item.isPaid)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Получение оставшегося бюджета
  double get remainingBudget {
    return totalBudget - paidAmount;
  }

  /// Получение прогресса оплаты (0.0 - 1.0)
  double get paymentProgress {
    if (totalBudget == 0) return 0.0;
    return paidAmount / totalBudget;
  }

  /// Получение статей по категории
  List<BudgetItem> getItemsByCategory(String category) {
    return _budgetItems.where((item) => item.category == category).toList();
  }

  /// Получение суммы по категории
  double getAmountByCategory(String category) {
    return _budgetItems
        .where((item) => item.category == category)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Получение оплаченной суммы по категории
  double getPaidAmountByCategory(String category) {
    return _budgetItems
        .where((item) => item.category == category && item.isPaid)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Получение статистики по категориям
  Map<String, Map<String, double>> getCategoryStatistics() {
    final statistics = <String, Map<String, double>>{};
    
    for (final category in BudgetCategory.values) {
      final items = getItemsByCategory(category.nameRu);
      final totalAmount = items.fold(0.0, (sum, item) => sum + item.amount);
      final paidAmount = items
          .where((item) => item.isPaid)
          .fold(0.0, (sum, item) => sum + item.amount);
      
      statistics[category.nameRu] = {
        'total': totalAmount,
        'paid': paidAmount,
        'unpaid': totalAmount - paidAmount,
        'percentage': totalBudget > 0 ? (totalAmount / totalBudget) * 100 : 0,
      };
    }
    
    return statistics;
  }

  /// Получение статей по дате
  List<BudgetItem> getItemsByDate(DateTime date) {
    return _budgetItems.where((item) {
      return item.date.year == date.year &&
             item.date.month == date.month &&
             item.date.day == date.day;
    }).toList();
  }

  /// Получение статей за период
  List<BudgetItem> getItemsByDateRange(DateTime startDate, DateTime endDate) {
    return _budgetItems.where((item) {
      return item.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
             item.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Получение статей по валюте
  List<BudgetItem> getItemsByCurrency(String currency) {
    return _budgetItems.where((item) => item.currency == currency).toList();
  }

  /// Получение уникальных валют
  List<String> get currencies {
    return _budgetItems.map((item) => item.currency).toSet().toList();
  }

  /// Получение уникальных категорий
  List<String> get categories {
    return _budgetItems.map((item) => item.category).toSet().toList();
  }

  /// Получение статей по статусу оплаты
  List<BudgetItem> getPaidItems() {
    return _budgetItems.where((item) => item.isPaid).toList();
  }

  /// Получение неоплаченных статей
  List<BudgetItem> getUnpaidItems() {
    return _budgetItems.where((item) => !item.isPaid).toList();
  }

  /// Получение статей с высоким приоритетом (дорогие)
  List<BudgetItem> getHighPriorityItems() {
    final sorted = List<BudgetItem>.from(_budgetItems);
    sorted.sort((a, b) => b.amount.compareTo(a.amount));
    return sorted.take(5).toList();
  }

  /// Получение статистики по валютам
  Map<String, double> getCurrencyStatistics() {
    final statistics = <String, double>{};
    
    for (final currency in currencies) {
      final amount = _budgetItems
          .where((item) => item.currency == currency)
          .fold(0.0, (sum, item) => sum + item.amount);
      statistics[currency] = amount;
    }
    
    return statistics;
  }

  /// Получение среднего размера статьи
  double get averageItemAmount {
    if (_budgetItems.isEmpty) return 0.0;
    return totalBudget / _budgetItems.length;
  }

  /// Получение самой дорогой статьи
  BudgetItem? get mostExpensiveItem {
    if (_budgetItems.isEmpty) return null;
    return _budgetItems.reduce((a, b) => a.amount > b.amount ? a : b);
  }

  /// Получение самой дешевой статьи
  BudgetItem? get cheapestItem {
    if (_budgetItems.isEmpty) return null;
    return _budgetItems.reduce((a, b) => a.amount < b.amount ? a : b);
  }

  /// Получение статей за последние N дней
  List<BudgetItem> getRecentItems(int days) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _budgetItems.where((item) => item.date.isAfter(cutoffDate)).toList();
  }

  /// Очистка всех статей бюджета
  Future<void> clearAllItems() async {
    try {
      await _budgetService.clearBudgetItems(_currentRouteId!);
      _budgetItems.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка очистки бюджета: $e');
    }
  }

  /// Экспорт бюджета в JSON
  Map<String, dynamic> exportBudget() {
    return {
      'routeId': _currentRouteId,
      'items': _budgetItems.map((item) => item.toJson()).toList(),
      'totalBudget': totalBudget,
      'paidAmount': paidAmount,
      'unpaidAmount': unpaidAmount,
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  /// Импорт бюджета из JSON
  Future<void> importBudget(Map<String, dynamic> budgetData) async {
    try {
      final items = (budgetData['items'] as List)
          .map((itemData) => BudgetItem.fromJson(itemData as Map<String, dynamic>))
          .toList();
      
      for (final item in items) {
        await _budgetService.saveBudgetItem(_currentRouteId!, item);
      }
      
      _budgetItems.addAll(items);
      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка импорта бюджета: $e');
    }
  }
}
