/// Модель данных для места/достопримечательности
/// Содержит информацию о месте, которое можно посетить
class Place {
  final String id;                    // Уникальный идентификатор места
  final String nameRu;                // Название на русском языке
  final String nameKk;                // Название на казахском языке
  final String descriptionRu;         // Описание на русском языке
  final String descriptionKk;         // Описание на казахском языке
  final String imageUrl;              // URL изображения места
  final double rating;                // Рейтинг места (0.0 - 5.0)
  final String city;                  // Город, где находится место
  final String category;              // Категория места (горы, города, пляжи и т.д.)
  final bool isFavorite;              // Добавлено ли в избранное
  final double latitude;              // Широта для карты
  final double longitude;             // Долгота для карты
  final List<String> imageUrls;       // Дополнительные изображения
  final String priceRange;            // Диапазон цен (бесплатно, $, $$, $$$)
  final List<String> tags;            // Теги для поиска

  const Place({
    required this.id,
    required this.nameRu,
    required this.nameKk,
    required this.descriptionRu,
    required this.descriptionKk,
    required this.imageUrl,
    required this.rating,
    required this.city,
    required this.category,
    this.isFavorite = false,
    required this.latitude,
    required this.longitude,
    this.imageUrls = const [],
    this.priceRange = 'бесплатно',
    this.tags = const [],
  });

  /// Создание объекта Place из JSON
  /// Используется при загрузке данных из файла или API
  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'].toString(),
      nameRu: (json['name_ru'] ?? json['title'] ?? 'Без названия').toString(),
      nameKk: (json['name_kk'] ?? json['title'] ?? 'Атауы жоқ').toString(),
      descriptionRu: (json['description_ru'] ?? json['description'] ?? '').toString(),
      descriptionKk: (json['description_kk'] ?? json['description'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
      rating: json['rating'] is String 
          ? double.tryParse(json['rating']) ?? 0.0 
          : (json['rating'] as num?)?.toDouble() ?? 0.0,
      city: (json['city'] ?? 'Казахстан').toString(),
      category: (json['category'] ?? 'Разное').toString(),
      isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,
      latitude: json['latitude'] is String 
          ? double.tryParse(json['latitude']) ?? 0.0 
          : (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: json['longitude'] is String 
          ? double.tryParse(json['longitude']) ?? 0.0 
          : (json['longitude'] as num?)?.toDouble() ?? 0.0,
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      priceRange: (json['price_range'] ?? 'бесплатно').toString(),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  /// Преобразование объекта Place в JSON
  /// Используется для сохранения данных
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ru': nameRu,
      'name_kk': nameKk,
      'description_ru': descriptionRu,
      'description_kk': descriptionKk,
      'image_url': imageUrl,
      'rating': rating,
      'city': city,
      'category': category,
      'is_favorite': isFavorite,
      'latitude': latitude,
      'longitude': longitude,
      'image_urls': imageUrls,
      'price_range': priceRange,
      'tags': tags,
    };
  }

  /// Создание копии объекта с измененными полями
  /// Полезно для обновления состояния в Provider
  Place copyWith({
    String? id,
    String? nameRu,
    String? nameKk,
    String? descriptionRu,
    String? descriptionKk,
    String? imageUrl,
    double? rating,
    String? city,
    String? category,
    bool? isFavorite,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
    String? priceRange,
    List<String>? tags,
  }) {
    return Place(
      id: id ?? this.id,
      nameRu: nameRu ?? this.nameRu,
      nameKk: nameKk ?? this.nameKk,
      descriptionRu: descriptionRu ?? this.descriptionRu,
      descriptionKk: descriptionKk ?? this.descriptionKk,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      city: city ?? this.city,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
      priceRange: priceRange ?? this.priceRange,
      tags: tags ?? this.tags,
    );
  }

  /// Получение названия места на текущем языке
  String getName(String languageCode) {
    return languageCode == 'kk' ? nameKk : nameRu;
  }

  /// Получение описания места на текущем языке
  String getDescription(String languageCode) {
    return languageCode == 'kk' ? descriptionKk : descriptionRu;
  }

  @override
  String toString() {
    return 'Place(id: $id, nameRu: $nameRu, nameKk: $nameKk, city: $city, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Place && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
