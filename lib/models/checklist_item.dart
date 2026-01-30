/// Модель данных для элемента чек-листа
/// Содержит информацию о задаче для подготовки к путешествию
class ChecklistItem {
  final String id;                    // Уникальный идентификатор элемента
  final String title;                 // Название задачи
  final String? description;          // Описание задачи
  final bool isCompleted;             // Выполнена ли задача
  final DateTime? completedAt;        // Дата выполнения
  final String category;              // Категория задачи
  final int priority;                 // Приоритет (1-5, где 5 - самый высокий)
  final DateTime createdAt;           // Дата создания задачи

  const ChecklistItem({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.completedAt,
    required this.category,
    this.priority = 3,
    required this.createdAt,
  });

  /// Создание объекта ChecklistItem из JSON
  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      category: json['category'] as String,
      priority: json['priority'] as int? ?? 3,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Преобразование объекта ChecklistItem в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'category': category,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Создание копии объекта с измененными полями
  ChecklistItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? completedAt,
    String? category,
    int? priority,
    DateTime? createdAt,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Отметить задачу как выполненную
  ChecklistItem markAsCompleted() {
    return copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
  }

  /// Отметить задачу как невыполненную
  ChecklistItem markAsIncomplete() {
    return copyWith(
      isCompleted: false,
      completedAt: null,
    );
  }

  /// Получение приоритета в виде строки
  String getPriorityText() {
    switch (priority) {
      case 1:
        return 'Очень низкий';
      case 2:
        return 'Низкий';
      case 3:
        return 'Средний';
      case 4:
        return 'Высокий';
      case 5:
        return 'Очень высокий';
      default:
        return 'Средний';
    }
  }

  /// Получение приоритета в виде строки на казахском языке
  String getPriorityTextKk() {
    switch (priority) {
      case 1:
        return 'Өте төмен';
      case 2:
        return 'Төмен';
      case 3:
        return 'Орташа';
      case 4:
        return 'Жоғары';
      case 5:
        return 'Өте жоғары';
      default:
        return 'Орташа';
    }
  }

  @override
  String toString() {
    return 'ChecklistItem(id: $id, title: $title, isCompleted: $isCompleted, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChecklistItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Перечисление категорий задач чек-листа
enum ChecklistCategory {
  documents('Документы', 'Құжаттар'),
  packing('Сборы', 'Жапсыру'),
  transport('Транспорт', 'Көлік'),
  accommodation('Жилье', 'Тұрғын үй'),
  money('Деньги', 'Ақша'),
  health('Здоровье', 'Денсаулық'),
  communication('Связь', 'Байланыс'),
  other('Прочее', 'Басқа');

  const ChecklistCategory(this.nameRu, this.nameKk);

  final String nameRu;
  final String nameKk;

  /// Получение названия категории на текущем языке
  String getName(String languageCode) {
    return languageCode == 'kk' ? nameKk : nameRu;
  }
}
