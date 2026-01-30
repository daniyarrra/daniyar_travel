/// Модель данных для статьи бюджета
/// Содержит информацию о расходах в путешествии
class BudgetItem {
  final String id;                    // Уникальный идентификатор статьи
  final String category;              // Категория расхода (транспорт, жилье, еда и т.д.)
  final double amount;                // Сумма расхода
  final String currency;              // Валюта (KZT, USD, EUR)
  final String description;           // Описание расхода
  final DateTime date;                // Дата расхода
  final bool isPaid;                  // Оплачен ли расход
  final String? notes;                // Дополнительные заметки

  const BudgetItem({
    required this.id,
    required this.category,
    required this.amount,
    this.currency = 'KZT',
    this.description = '',
    required this.date,
    this.isPaid = false,
    this.notes,
  });

  /// Создание объекта BudgetItem из JSON
  factory BudgetItem.fromJson(Map<String, dynamic> json) {
    return BudgetItem(
      id: json['id'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'KZT',
      description: json['description'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      isPaid: json['is_paid'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  /// Преобразование объекта BudgetItem в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'currency': currency,
      'description': description,
      'date': date.toIso8601String(),
      'is_paid': isPaid,
      'notes': notes,
    };
  }

  /// Создание копии объекта с измененными полями
  BudgetItem copyWith({
    String? id,
    String? category,
    double? amount,
    String? currency,
    String? description,
    DateTime? date,
    bool? isPaid,
    String? notes,
  }) {
    return BudgetItem(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      date: date ?? this.date,
      isPaid: isPaid ?? this.isPaid,
      notes: notes ?? this.notes,
    );
  }

  /// Получение отформатированной суммы с валютой
  String getFormattedAmount() {
    return '${amount.toStringAsFixed(0)} $currency';
  }

  /// Получение отформатированной даты
  String getFormattedDate() {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  @override
  String toString() {
    return 'BudgetItem(id: $id, category: $category, amount: $amount $currency, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Перечисление категорий расходов
enum BudgetCategory {
  transport('Транспорт', 'Көлік'),
  accommodation('Жилье', 'Тұрғын үй'),
  food('Еда', 'Тамақ'),
  entertainment('Развлечения', 'Ойын-сауық'),
  shopping('Покупки', 'Сатып алу'),
  activities('Активности', 'Белсенділік'),
  other('Прочее', 'Басқа');

  const BudgetCategory(this.nameRu, this.nameKk);

  final String nameRu;
  final String nameKk;

  /// Получение названия категории на текущем языке
  String getName(String languageCode) {
    return languageCode == 'kk' ? nameKk : nameRu;
  }
}
