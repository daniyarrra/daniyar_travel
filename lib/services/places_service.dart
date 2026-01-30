import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/place.dart';
import '../utils/constants.dart';
import 'postgres_service.dart';

/// Сервис для работы с данными мест и достопримечательностей
/// Отвечает за загрузку, сохранение и управление данными о местах
class PlacesService {
  // Кэш для загруженных мест
  List<Place>? _cachedPlaces;
  
  // Кэш для избранных мест
  List<Place>? _cachedFavorites;

  /// Загрузка всех мест из JSON файла
  /// В реальном приложении здесь был бы API запрос
  final PostgresService _postgresService = PostgresService();

  /// Загрузка всех мест из Postgres
  Future<List<Place>> loadPlaces() async {
    try {
      final data = await _postgresService.getPlaces();
      _cachedPlaces = data.map((json) => Place.fromJson(json)).toList();
      return _cachedPlaces!;
    } catch (e) {
      debugPrint('Ошибка загрузки из Postgres: $e');
      return _cachedPlaces ?? [];
    }
  }

  /// Загрузка избранных мест
  Future<List<Place>> loadFavoritePlaces() async {
    if (_cachedFavorites != null) {
      return _cachedFavorites!;
    }

    final allPlaces = await loadPlaces();
    _cachedFavorites = allPlaces.where((place) => place.isFavorite).toList();
    
    return _cachedFavorites!;
  }

  /// Добавление места в избранное
  Future<void> addToFavorites(Place place) async {
    final updatedPlace = place.copyWith(isFavorite: true);
    
    if (_cachedPlaces != null) {
      final index = _cachedPlaces!.indexWhere((p) => p.id == place.id);
      if (index != -1) {
        _cachedPlaces![index] = updatedPlace;
      }
    }
    
    if (_cachedFavorites != null) {
      _cachedFavorites!.add(updatedPlace);
    }
  }

  /// Удаление места из избранного
  Future<void> removeFromFavorites(Place place) async {
    final updatedPlace = place.copyWith(isFavorite: false);
    
    if (_cachedPlaces != null) {
      final index = _cachedPlaces!.indexWhere((p) => p.id == place.id);
      if (index != -1) {
        _cachedPlaces![index] = updatedPlace;
      }
    }
    
    if (_cachedFavorites != null) {
      _cachedFavorites!.removeWhere((p) => p.id == place.id);
    }
  }

  /// Обновление места
  Future<void> updatePlace(Place place) async {
    // В реальном приложении здесь было бы обновление в БД
    // Но методы редактирования уже реализованы в PostgresService, здесь просто обновляем кэш
    if (_cachedPlaces != null) {
      final index = _cachedPlaces!.indexWhere((p) => p.id == place.id);
      if (index != -1) {
        _cachedPlaces![index] = place;
      }
    }
    
    if (_cachedFavorites != null) {
      final index = _cachedFavorites!.indexWhere((p) => p.id == place.id);
      if (index != -1) {
        _cachedFavorites![index] = place;
      }
    }
  }

  /// Создание тестовых данных о местах в Казахстане
  List<Place> _createSamplePlaces() {
    return [
      // Алматы
      Place(
        id: '1',
        nameRu: 'Медео',
        nameKk: 'Медео',
        descriptionRu: 'Высокогорный спортивный комплекс и каток в горах Заилийского Алатау. Расположен на высоте 1691 метр над уровнем моря.',
        descriptionKk: 'Заилий Алатауының биік таулы спорт кешені мен мұз айдыны. Теңіз деңгейінен 1691 метр биіктікте орналасқан.',
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        rating: 4.8,
        city: 'Алматы',
        category: 'Горы',
        latitude: 43.1525,
        longitude: 77.0572,
        imageUrls: [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        ],
        priceRange: '\$\$',
        tags: ['спорт', 'горы', 'зима', 'каток'],
      ),
      
      Place(
        id: '2',
        nameRu: 'Шымбулак',
        nameKk: 'Шымбұлақ',
        descriptionRu: 'Горнолыжный курорт в горах Заилийского Алатау. Один из лучших горнолыжных курортов в Центральной Азии.',
        descriptionKk: 'Заилий Алатауының таулы шаңғы курорты. Орталық Азиядағы ең жақсы таулы шаңғы курорттарының бірі.',
        imageUrl: 'https://images.unsplash.com/photo-1551524164-6cf77bb2c7e8?w=800',
        rating: 4.7,
        city: 'Алматы',
        category: 'Горы',
        latitude: 43.1667,
        longitude: 77.0833,
        imageUrls: [
          'https://images.unsplash.com/photo-1551524164-6cf77bb2c7e8?w=800',
        ],
        priceRange: '\$\$\$',
        tags: ['горы', 'лыжи', 'зима', 'спорт'],
      ),
      
      Place(
        id: '3',
        nameRu: 'Кок-Тобе',
        nameKk: 'Көк-Төбе',
        descriptionRu: 'Гора в Алматы с телебашней и парком развлечений. Отличное место для обзора города.',
        descriptionKk: 'Алматыдағы телебашнясы мен ойын-сауық паркі бар тау. Қаланы көру үшін керемет орын.',
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        rating: 4.5,
        city: 'Алматы',
        category: 'Парки',
        latitude: 43.2500,
        longitude: 76.9500,
        imageUrls: [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        ],
        priceRange: '\$',
        tags: ['парк', 'обзор', 'развлечения', 'семья'],
      ),

      // Астана
      Place(
        id: '4',
        nameRu: 'Байтерек',
        nameKk: 'Бәйтерек',
        descriptionRu: 'Монумент и смотровая площадка в центре Астаны. Символ независимости Казахстана.',
        descriptionKk: 'Астананың орталығындағы монумент пен көзқарас алаңы. Қазақстан тәуелсіздігінің символы.',
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        rating: 4.6,
        city: 'Астана',
        category: 'Исторические места',
        latitude: 51.1284,
        longitude: 71.4304,
        imageUrls: [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        ],
        priceRange: 'бесплатно',
        tags: ['монумент', 'символ', 'история', 'обзор'],
      ),
      
      Place(
        id: '5',
        nameRu: 'Хан Шатыр',
        nameKk: 'Хан Шатыр',
        descriptionRu: 'Торгово-развлекательный центр с уникальной архитектурой. Внутри есть пляж и аквапарк.',
        descriptionKk: 'Бірегей сәулетпен салынған сауда-ойын-сауық орталығы. Ішінде пляж мен аквапарк бар.',
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        rating: 4.4,
        city: 'Астана',
        category: 'Развлечения',
        latitude: 51.1333,
        longitude: 71.4333,
        imageUrls: [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        ],
        priceRange: '\$\$\$',
        tags: ['торговля', 'развлечения', 'пляж', 'аквапарк'],
      ),

      // Шымкент
      Place(
        id: '6',
        nameRu: 'Парк имени Кена Баба',
        nameKk: 'Кен Баба атындағы парк',
        descriptionRu: 'Центральный парк Шымкента с красивыми аллеями и фонтанами. Отличное место для прогулок.',
        descriptionKk: 'Шымкенттің орталық паркі, әдемі аллеялар мен фонтаналармен. Серуендеу үшін керемет орын.',
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        rating: 4.3,
        city: 'Шымкент',
        category: 'Парки',
        latitude: 42.3000,
        longitude: 69.6000,
        imageUrls: [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        ],
        priceRange: 'бесплатно',
        tags: ['парк', 'прогулки', 'семья', 'природа'],
      ),

      // Туркестан
      Place(
        id: '7',
        nameRu: 'Мавзолей Ходжи Ахмеда Ясави',
        nameKk: 'Қожа Ахмет Ясауи кесенесі',
        descriptionRu: 'Исторический мавзолей и музей. Один из важнейших памятников исламской архитектуры в Казахстане.',
        descriptionKk: 'Тарихи кесене және мұражай. Қазақстандағы ислам сәулетінің ең маңызды ескерткіштерінің бірі.',
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        rating: 4.9,
        city: 'Туркестан',
        category: 'Религиозные места',
        latitude: 43.3000,
        longitude: 68.2500,
        imageUrls: [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        ],
        priceRange: 'бесплатно',
        tags: ['история', 'религия', 'архитектура', 'музей'],
      ),

      // Алтын-Эмель
      Place(
        id: '8',
        nameRu: 'Поющий бархан',
        nameKk: 'Ән шығаратын бархан',
        descriptionRu: 'Уникальная песчаная дюна, которая издает звуки при ветре. Природное чудо Казахстана.',
        descriptionKk: 'Жел соғғанда дыбыс шығаратын бірегей құмды дюна. Қазақстанның табиғи кереметі.',
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        rating: 4.8,
        city: 'Алтын-Эмель',
        category: 'Природа',
        latitude: 44.0000,
        longitude: 78.0000,
        imageUrls: [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        ],
        priceRange: '\$',
        tags: ['природа', 'пустыня', 'уникально', 'звуки'],
      ),

      // Боровое
      Place(
        id: '9',
        nameRu: 'Озеро Боровое',
        nameKk: 'Боровое көлі',
        descriptionRu: 'Красивое горное озеро с чистой водой. Популярное место для отдыха и рыбалки.',
        descriptionKk: 'Таза суы бар әдемі таулы көл. Демалыс пен балық аулау үшін танымал орын.',
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        rating: 4.7,
        city: 'Боровое',
        category: 'Озера',
        latitude: 53.0000,
        longitude: 70.0000,
        imageUrls: [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        ],
        priceRange: '\$',
        tags: ['озеро', 'природа', 'отдых', 'рыбалка'],
      ),

      // Чарынский каньон
      Place(
        id: '10',
        nameRu: 'Чарынский каньон',
        nameKk: 'Шарын шатқалы',
        descriptionRu: 'Уникальный каньон с красными скалами. Часто называют "Казахстанским Гранд-Каньоном".',
        descriptionKk: 'Қызыл жартастармен бірегей шатқал. Көбінесе "Қазақстан Гранд-Каньоны" деп аталады.',
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        rating: 4.9,
        city: 'Чарын',
        category: 'Природа',
        latitude: 43.5000,
        longitude: 79.0000,
        imageUrls: [
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        ],
        priceRange: '\$',
        tags: ['каньон', 'природа', 'скалы', 'уникально'],
      ),
    ];
  }

  /// Поиск мест по запросу
  Future<List<Place>> searchPlaces(String query) async {
    final allPlaces = await loadPlaces();
    return allPlaces.where((place) {
      return place.nameRu.toLowerCase().contains(query.toLowerCase()) ||
             place.nameKk.toLowerCase().contains(query.toLowerCase()) ||
             place.descriptionRu.toLowerCase().contains(query.toLowerCase()) ||
             place.descriptionKk.toLowerCase().contains(query.toLowerCase()) ||
             place.city.toLowerCase().contains(query.toLowerCase()) ||
             place.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  /// Получение мест по категории
  Future<List<Place>> getPlacesByCategory(String category) async {
    final allPlaces = await loadPlaces();
    return allPlaces.where((place) => place.category == category).toList();
  }

  /// Получение мест по городу
  Future<List<Place>> getPlacesByCity(String city) async {
    final allPlaces = await loadPlaces();
    return allPlaces.where((place) => place.city == city).toList();
  }

  /// Добавление нового места в Postgres
  Future<void> addPlace(Place place) async {
    try {
      await _postgresService.addPlace(
        place.nameRu,
        place.descriptionRu,
        place.imageUrl,
        place.category,
      );
          
      // После добавления сбрасываем кэш, чтобы при следующем запросе подтянулись новые данные с ID
      _cachedPlaces = null;
    } catch (e) {
      debugPrint('Ошибка добавления места: $e');
      rethrow;
    }
  }

  /// Получение популярных мест
  Future<List<Place>> getPopularPlaces() async {
    final allPlaces = await loadPlaces();
    final sorted = List<Place>.from(allPlaces);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(10).toList();
  }

  /// Получение места по ID
  Future<Place?> getPlaceById(String id) async {
    final allPlaces = await loadPlaces();
    try {
      return allPlaces.firstWhere((place) => place.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Очистка кэша
  void clearCache() {
    _cachedPlaces = null;
    _cachedFavorites = null;
  }
}
