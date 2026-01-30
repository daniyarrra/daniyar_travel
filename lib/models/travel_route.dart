import 'place.dart';

/// Модель данных для маршрута путешествия
/// Содержит информацию о планируемом путешествии
class TravelRoute {
  final String id;                    // Уникальный идентификатор маршрута
  final String name;                  // Название маршрута
  final List<Place> places;           // Список мест в маршруте
  final DateTime startDate;           // Дата начала путешествия
  final DateTime endDate;             // Дата окончания путешествия
  final double budget;                // Бюджет на путешествие
  final String currency;              // Валюта (KZT, USD, EUR)
  final String description;           // Описание маршрута
  final bool isCompleted;             // Завершен ли маршрут
  final DateTime createdAt;           // Дата создания маршрута
  final DateTime updatedAt;           // Дата последнего обновления

  const TravelRoute({
    required this.id,
    required this.name,
    required this.places,
    required this.startDate,
    required this.endDate,
    required this.budget,
    this.currency = 'KZT',
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Создание объекта TravelRoute из JSON
  factory TravelRoute.fromJson(Map<String, dynamic> json) {
    return TravelRoute(
      id: json['id'] as String,
      name: json['name'] as String,
      places: (json['places'] as List)
          .map((placeJson) => Place.fromJson(placeJson as Map<String, dynamic>))
          .toList(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      budget: (json['budget'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'KZT',
      description: json['description'] as String? ?? '',
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Преобразование объекта TravelRoute в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'places': places.map((place) => place.toJson()).toList(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'budget': budget,
      'currency': currency,
      'description': description,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Создание копии объекта с измененными полями
  TravelRoute copyWith({
    String? id,
    String? name,
    List<Place>? places,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    String? currency,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TravelRoute(
      id: id ?? this.id,
      name: name ?? this.name,
      places: places ?? this.places,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Получение продолжительности путешествия в днях
  int getDuration() {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Получение общего количества мест в маршруте
  int getPlacesCount() {
    return places.length;
  }

  /// Проверка, началось ли путешествие
  bool get hasStarted {
    return DateTime.now().isAfter(startDate);
  }

  /// Проверка, закончилось ли путешествие
  bool get hasEnded {
    return DateTime.now().isAfter(endDate);
  }

  /// Получение прогресса путешествия (0.0 - 1.0)
  double getProgress() {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0.0;
    if (now.isAfter(endDate)) return 1.0;
    
    final totalDuration = endDate.difference(startDate).inDays;
    final passedDays = now.difference(startDate).inDays;
    return passedDays / totalDuration;
  }

  /// Получение оставшихся дней до начала путешествия
  int getDaysUntilStart() {
    final now = DateTime.now();
    if (now.isAfter(startDate)) return 0;
    return startDate.difference(now).inDays;
  }

  /// Получение оставшихся дней до окончания путешествия
  int getDaysUntilEnd() {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  @override
  String toString() {
    return 'TravelRoute(id: $id, name: $name, places: ${places.length}, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TravelRoute && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
