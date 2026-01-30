import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/places_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/place_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';
import 'dart:io';
import '../models/place.dart';
import 'place_detail_screen.dart';
import 'search_screen.dart';
import 'add_place_screen.dart';
import '../services/postgres_service.dart';

/// Главный экран приложения TravelKZ
/// Показывает популярные места, категории и поиск
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Инициализируем данные при загрузке экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlacesProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().getBackgroundColor(),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<PlacesProvider>().loadPlaces();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchSection(),
              _buildCategoriesSection(),
              _buildPopularPlacesSection(),
              _buildRecentPlacesSection(),
              const SizedBox(height: 100), // Отступ для BottomNavigationBar
            ],
          ),
        ),
      ),
    );
  }

  /// Создание AppBar с поиском и настройками
  PreferredSizeWidget _buildAppBar() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return AppBar(
      backgroundColor: themeProvider.getAppBarColor(),
      elevation: 0,
      title: Text(
        languageProvider.getLocalizedText('TravelKZ', 'TravelKZ'),
        style: TextStyle(
          color: themeProvider.getTextColor(),
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            color: themeProvider.getIconColor(),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchScreen(),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(
            Icons.language,
            color: themeProvider.getIconColor(),
          ),
          onPressed: () {
            languageProvider.toggleLanguage();
          },
        ),
        IconButton(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: themeProvider.getIconColor(),
          ),
          onPressed: () {
            themeProvider.toggleTheme();
          },
        ),
      ],
    );
  }

  /// Секция поиска
  Widget _buildSearchSection() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languageProvider.getLocalizedText(
              'Найдите идеальное место для путешествия',
              'Саяхат үшін мінсіз орынды табыңыз'
            ),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: themeProvider.getTextColor(),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: themeProvider.getInputFieldColor(),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                border: Border.all(
                  color: themeProvider.getInputFieldBorderColor(),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: themeProvider.getHintColor(),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    languageProvider.getLocalizedText(
                      'Поиск мест...',
                      'Орындарды іздеу...'
                    ),
                    style: TextStyle(
                      color: themeProvider.getHintColor(),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Секция категорий
  Widget _buildCategoriesSection() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final placesProvider = context.watch<PlacesProvider>();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languageProvider.getLocalizedText(
              'Категории',
              'Санаттар'
            ),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.getTextColor(),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.placeCategories.length,
              itemBuilder: (context, index) {
                final category = AppConstants.placeCategories[index];
                final categoryKk = AppConstants.placeCategoriesKk[index];
                final isSelected = placesProvider.selectedCategory == category;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CategoryChip(
                    label: languageProvider.getLocalizedText(category, categoryKk),
                    isSelected: isSelected,
                    onTap: () {
                      if (isSelected) {
                        placesProvider.filterByCategory('');
                      } else {
                        placesProvider.filterByCategory(category);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Секция популярных мест
  Widget _buildPopularPlacesSection() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                languageProvider.getLocalizedText(
                  'Популярные места',
                  'Танымал орындар'
                ),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.getTextColor(),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
                child: Text(
                  languageProvider.getLocalizedText(
                    'Все',
                    'Барлығы'
                  ),
                  style: TextStyle(
                    color: themeProvider.getPrimaryColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: PostgresService().getPlaces(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(child: Text('Ошибка: ${snapshot.error}'));
              }

              var places = snapshot.data ?? [];
              
              // Фильтрация по выбранной категории
              final placesProvider = context.watch<PlacesProvider>();
              if (placesProvider.selectedCategory.isNotEmpty) {
                places = places.where((place) => 
                  place['category'] == placesProvider.selectedCategory
                ).toList();
              }

              if (places.isEmpty) {
                return const Center(child: Text('Нет мест в этой категории'));
              }

              // Используем простой ListView вместо GridView для горизонтального скролла или вертикального списка
              return SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: themeProvider.getCardColor(),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () {
                          // Преобразуем Map из БД в объект Place
                          final placeObj = Place(
                            id: place['id'].toString(),
                            nameRu: place['title'] ?? 'Без названия',
                            nameKk: place['title'] ?? 'Атауы жоқ', // В идеале добавить поле title_kk в БД
                            descriptionRu: place['description'] ?? '',
                            descriptionKk: place['description'] ?? '',
                            imageUrl: place['image_url'] ?? '',
                            rating: place['rating'] is String 
                                ? double.tryParse(place['rating']) ?? 5.0 
                                : (place['rating'] as num?)?.toDouble() ?? 5.0,
                            city: 'Казахстан', // Хардкод, можно добавить в БД
                            category: place['category'] ?? 'Разное',
                            latitude: 0.0, // Нет в БД, дефолт
                            longitude: 0.0,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlaceDetailScreen(place: placeObj),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: place['image_url'] != null && place['image_url'].startsWith('http')
                                  ? Image.network(
                                      place['image_url'],
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 150,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image_not_supported, size: 50),
                                      ),
                                    )
                                  : Image.file(
                                      File(place['image_url'] ?? ''),
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 150,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.broken_image, size: 50),
                                      ),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    place['title'] ?? 'Без названия',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: themeProvider.getTextColor(),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.category, size: 14, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        place['category'] ?? 'Разное',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: themeProvider.getSecondaryTextColor(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, size: 16, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text(
                                        place['rating']?.toString() ?? '5.0',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: themeProvider.getTextColor(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Секция недавних мест
  Widget _buildRecentPlacesSection() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final placesProvider = context.watch<PlacesProvider>();
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languageProvider.getLocalizedText(
              'Недавно добавленные',
              'Жаңа қосылғандар'
            ),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.getTextColor(),
            ),
          ),
          const SizedBox(height: 16),
          _buildPlacesList(placesProvider.recentPlaces),
        ],
      ),
    );
  }

  /// Сетка мест
  Widget _buildPlacesGrid(List places) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return PlaceCard(
          place: place,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceDetailScreen(place: place),
              ),
            );
          },
        );
      },
    );
  }

  /// Список мест
  Widget _buildPlacesList(List places) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PlaceCard(
            place: place,
            isHorizontal: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaceDetailScreen(place: place),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Виджет ошибки
  Widget _buildErrorWidget() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final placesProvider = context.watch<PlacesProvider>();
    
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: themeProvider.getErrorColor(),
          ),
          const SizedBox(height: 16),
          Text(
            languageProvider.getLocalizedText(
              'Ошибка загрузки данных',
              'Деректерді жүктеу қатесі'
            ),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: themeProvider.getTextColor(),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            placesProvider.error ?? '',
            style: TextStyle(
              color: themeProvider.getSecondaryTextColor(),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: languageProvider.getLocalizedText(
              'Попробовать снова',
              'Қайталап көріңіз'
            ),
            onPressed: () {
              placesProvider.loadPlaces();
            },
          ),
        ],
      ),
    );
  }
}
