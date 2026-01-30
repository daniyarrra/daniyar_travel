import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/places_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/place_card.dart';
import '../utils/constants.dart';
import 'place_detail_screen.dart';

/// Экран поиска мест и достопримечательностей
/// Позволяет искать места по названию, описанию и тегам
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Автоматически фокусируемся на поле поиска
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final placesProvider = context.watch<PlacesProvider>();
    
    return Scaffold(
      backgroundColor: themeProvider.getBackgroundColor(),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchField(),
          _buildFiltersSection(),
          Expanded(
            child: _buildSearchResults(placesProvider.filteredPlaces),
          ),
        ],
      ),
    );
  }

  /// Создание AppBar
  PreferredSizeWidget _buildAppBar() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return AppBar(
      backgroundColor: themeProvider.getAppBarColor(),
      elevation: 0,
      title: Text(
        languageProvider.getLocalizedText(
          'Поиск',
          'Іздеу'
        ),
        style: TextStyle(
          color: themeProvider.getTextColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: themeProvider.getIconColor(),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  /// Поле поиска
  Widget _buildSearchField() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final placesProvider = context.watch<PlacesProvider>();
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: languageProvider.getLocalizedText(
            'Поиск мест...',
            'Орындарды іздеу...'
          ),
          hintStyle: TextStyle(
            color: themeProvider.getHintColor(),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: themeProvider.getIconColor(),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: themeProvider.getIconColor(),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    placesProvider.searchPlaces('');
                  },
                )
              : null,
          filled: true,
          fillColor: themeProvider.getInputFieldColor(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            borderSide: BorderSide(
              color: themeProvider.getInputFieldBorderColor(),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            borderSide: BorderSide(
              color: themeProvider.getInputFieldBorderColor(),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            borderSide: BorderSide(
              color: themeProvider.getInputFieldFocusColor(),
              width: 2,
            ),
          ),
        ),
        style: TextStyle(
          color: themeProvider.getTextColor(),
          fontSize: 16,
        ),
        onChanged: (value) {
          placesProvider.searchPlaces(value);
        },
      ),
    );
  }

  /// Секция фильтров
  Widget _buildFiltersSection() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final placesProvider = context.watch<PlacesProvider>();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                languageProvider.getLocalizedText(
                  'Фильтры',
                  'Сүзгілер'
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.getTextColor(),
                ),
              ),
              if (placesProvider.selectedCategory.isNotEmpty || 
                  placesProvider.selectedCity.isNotEmpty)
                TextButton(
                  onPressed: () {
                    placesProvider.clearFilters();
                  },
                  child: Text(
                    languageProvider.getLocalizedText(
                      'Очистить',
                      'Тазалау'
                    ),
                    style: TextStyle(
                      color: themeProvider.getPrimaryColor(),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCategoryFilters(),
          const SizedBox(height: 12),
          _buildCityFilters(),
        ],
      ),
    );
  }

  /// Фильтры по категориям
  Widget _buildCategoryFilters() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final placesProvider = context.watch<PlacesProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.getLocalizedText(
            'Категории',
            'Санаттар'
          ),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: themeProvider.getSecondaryTextColor(),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.placeCategories.length,
            itemBuilder: (context, index) {
              final category = AppConstants.placeCategories[index];
              final categoryKk = AppConstants.placeCategoriesKk[index];
              final isSelected = placesProvider.selectedCategory == category;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    languageProvider.getLocalizedText(category, categoryKk),
                    style: TextStyle(
                      color: isSelected 
                          ? themeProvider.getSelectedChipTextColor()
                          : themeProvider.getChipTextColor(),
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      placesProvider.filterByCategory(category);
                    } else {
                      placesProvider.filterByCategory('');
                    }
                  },
                  backgroundColor: themeProvider.getChipColor(),
                  selectedColor: themeProvider.getSelectedChipColor(),
                  checkmarkColor: themeProvider.getSelectedChipTextColor(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Фильтры по городам
  Widget _buildCityFilters() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final placesProvider = context.watch<PlacesProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.getLocalizedText(
            'Города',
            'Қалалар'
          ),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: themeProvider.getSecondaryTextColor(),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.popularCities.length,
            itemBuilder: (context, index) {
              final city = AppConstants.popularCities[index];
              final isSelected = placesProvider.selectedCity == city;
              
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    city,
                    style: TextStyle(
                      color: isSelected 
                          ? themeProvider.getSelectedChipTextColor()
                          : themeProvider.getChipTextColor(),
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      placesProvider.filterByCity(city);
                    } else {
                      placesProvider.filterByCity('');
                    }
                  },
                  backgroundColor: themeProvider.getChipColor(),
                  selectedColor: themeProvider.getSelectedChipColor(),
                  checkmarkColor: themeProvider.getSelectedChipTextColor(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Результаты поиска
  Widget _buildSearchResults(List places) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    if (places.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
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

  /// Пустое состояние
  Widget _buildEmptyState() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: themeProvider.getSecondaryTextColor(),
            ),
            const SizedBox(height: 16),
            Text(
              languageProvider.getLocalizedText(
                'Ничего не найдено',
                'Ештеңе табылмады'
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
              languageProvider.getLocalizedText(
                'Попробуйте изменить поисковый запрос или фильтры',
                'Іздеу сұрауын немесе сүзгілерді өзгертіп көріңіз'
              ),
              style: TextStyle(
                color: themeProvider.getSecondaryTextColor(),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
