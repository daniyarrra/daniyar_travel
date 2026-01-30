import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/places_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/place_card.dart';
import '../widgets/empty_state.dart';
import '../utils/constants.dart';
import 'place_detail_screen.dart';

/// Экран избранных мест
/// Показывает все места, добавленные пользователем в избранное
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Загружаем избранные места при инициализации экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlacesProvider>().loadFavoritePlaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final placesProvider = context.watch<PlacesProvider>();
    
    return Scaffold(
      backgroundColor: themeProvider.getBackgroundColor(),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await placesProvider.loadFavoritePlaces();
        },
        child: _buildBody(placesProvider.favoritePlaces),
      ),
    );
  }

  /// Создание AppBar
  PreferredSizeWidget _buildAppBar() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final placesProvider = context.watch<PlacesProvider>();
    
    return AppBar(
      backgroundColor: themeProvider.getAppBarColor(),
      elevation: 0,
      title: Text(
        languageProvider.getLocalizedText(
          'Избранное',
          'Таңдаулы'
        ),
        style: TextStyle(
          color: themeProvider.getTextColor(),
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (placesProvider.favoritePlaces.isNotEmpty)
          IconButton(
            icon: Icon(
              Icons.clear_all,
              color: themeProvider.getIconColor(),
            ),
            onPressed: _showClearAllDialog,
          ),
      ],
    );
  }

  /// Создание тела экрана
  Widget _buildBody(List favoritePlaces) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    if (favoritePlaces.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        title: languageProvider.getLocalizedText(
          'Нет избранных мест',
          'Таңдаулы орындар жоқ'
        ),
        subtitle: languageProvider.getLocalizedText(
          'Добавьте места в избранное, нажав на сердечко',
          'Жүрекше басып орындарды таңдаулыға қосыңыз'
        ),
      );
    }
    
    return Column(
      children: [
        _buildStatsSection(favoritePlaces),
        Expanded(
          child: _buildPlacesList(favoritePlaces),
        ),
      ],
    );
  }

  /// Секция статистики
  Widget _buildStatsSection(List favoritePlaces) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.favorite,
              title: languageProvider.getLocalizedText(
                'Всего мест',
                'Барлық орындар'
              ),
              value: favoritePlaces.length.toString(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.star,
              title: languageProvider.getLocalizedText(
                'Средний рейтинг',
                'Орташа рейтинг'
              ),
              value: _calculateAverageRating(favoritePlaces),
            ),
          ),
        ],
      ),
    );
  }

  /// Карточка статистики
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.getCardColor(),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: themeProvider.getBorderColor(),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: themeProvider.getPrimaryColor(),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.getTextColor(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.getSecondaryTextColor(),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Список избранных мест
  Widget _buildPlacesList(List favoritePlaces) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      itemCount: favoritePlaces.length,
      itemBuilder: (context, index) {
        final place = favoritePlaces[index];
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
            onFavoriteTap: () {
              _removeFromFavorites(place);
            },
          ),
        );
      },
    );
  }

  /// Удаление из избранного
  Future<void> _removeFromFavorites(place) async {
    try {
      await context.read<PlacesProvider>().removeFromFavorites(place);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<LanguageProvider>().getLocalizedText(
                'Удалено из избранного',
                'Таңдаулыдан алынып тасталды'
              ),
            ),
            backgroundColor: context.read<ThemeProvider>().getSnackBarColor(),
            action: SnackBarAction(
              label: context.read<LanguageProvider>().getLocalizedText(
                'Отменить',
                'Болдырмау'
              ),
              onPressed: () {
                context.read<PlacesProvider>().addToFavorites(place);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: context.read<ThemeProvider>().getErrorColor(),
          ),
        );
      }
    }
  }

  /// Диалог очистки всех избранных
  void _showClearAllDialog() {
    final languageProvider = context.read<LanguageProvider>();
    final themeProvider = context.read<ThemeProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.getDialogColor(),
        title: Text(
          languageProvider.getLocalizedText(
            'Очистить избранное',
            'Таңдаулыны тазалау'
          ),
          style: TextStyle(
            color: themeProvider.getDialogTitleColor(),
          ),
        ),
        content: Text(
          languageProvider.getLocalizedText(
            'Вы уверены, что хотите удалить все места из избранного?',
            'Барлық орындарды таңдаулыдан жойғыңыз келе ме?'
          ),
          style: TextStyle(
            color: themeProvider.getDialogContentColor(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              languageProvider.getLocalizedText(
                'Отмена',
                'Болдырмау'
              ),
              style: TextStyle(
                color: themeProvider.getDialogButtonTextColor(),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllFavorites();
            },
            child: Text(
              languageProvider.getLocalizedText(
                'Очистить',
                'Тазалау'
              ),
              style: TextStyle(
                color: themeProvider.getErrorColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Очистка всех избранных мест
  Future<void> _clearAllFavorites() async {
    try {
      final placesProvider = context.read<PlacesProvider>();
      final favoritePlaces = List.from(placesProvider.favoritePlaces);
      
      for (final place in favoritePlaces) {
        await placesProvider.removeFromFavorites(place);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.read<LanguageProvider>().getLocalizedText(
                'Все места удалены из избранного',
                'Барлық орындар таңдаулыдан алынып тасталды'
              ),
            ),
            backgroundColor: context.read<ThemeProvider>().getSnackBarColor(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: context.read<ThemeProvider>().getErrorColor(),
          ),
        );
      }
    }
  }

  /// Вычисление среднего рейтинга
  String _calculateAverageRating(List places) {
    if (places.isEmpty) return '0.0';
    
    final totalRating = places.fold(0.0, (sum, place) => sum + place.rating);
    final averageRating = totalRating / places.length;
    
    return averageRating.toStringAsFixed(1);
  }
}
