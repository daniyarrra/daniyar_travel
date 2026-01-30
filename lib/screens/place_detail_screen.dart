import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/place.dart';
import '../providers/places_provider.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/rating_stars.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// Экран детальной информации о месте
/// Показывает полную информацию, фотографии, карту и позволяет добавить в избранное
class PlaceDetailScreen extends StatefulWidget {
  final Place place;

  const PlaceDetailScreen({
    super.key,
    required this.place,
  });

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  late Place _place;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _place = widget.place;
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Scaffold(
      backgroundColor: themeProvider.getBackgroundColor(),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageGallery(),
                _buildPlaceInfo(),
                _buildDescription(),
                _buildLocationInfo(),
                _buildTags(),
                _buildActionButtons(),
                const SizedBox(height: 100), // Отступ для FAB
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Создание AppBar с изображением
  Widget _buildAppBar() {
    final themeProvider = context.watch<ThemeProvider>();
    
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: themeProvider.getAppBarColor(),
      flexibleSpace: FlexibleSpaceBar(
        background: _place.imageUrl.startsWith('http')
            ? CachedNetworkImage(
                imageUrl: _place.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: themeProvider.getSurfaceColor(),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: themeProvider.getPrimaryColor(),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: themeProvider.getSurfaceColor(),
                  child: Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: themeProvider.getSecondaryTextColor(),
                  ),
                ),
              )
            : Image.file(
                File(_place.imageUrl),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: themeProvider.getSurfaceColor(),
                  child: Icon(
                    Icons.broken_image,
                    size: 64,
                    color: themeProvider.getSecondaryTextColor(),
                  ),
                ),
              ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              _place.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _place.isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ),
      ],
    );
  }

  /// Галерея изображений
  Widget _buildImageGallery() {
    final themeProvider = context.watch<ThemeProvider>();
    
    if (_place.imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      height: 100,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _place.imageUrls.length,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              image: DecorationImage(
                image: CachedNetworkImageProvider(_place.imageUrls[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Информация о месте
  Widget _buildPlaceInfo() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _place.getName(languageProvider.currentLanguage),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.getTextColor(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: themeProvider.getSecondaryTextColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _place.city,
                          style: TextStyle(
                            fontSize: 16,
                            color: themeProvider.getSecondaryTextColor(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RatingStars(rating: _place.rating),
                  const SizedBox(height: 4),
                  Text(
                    AppHelpers.formatRating(_place.rating),
                    style: TextStyle(
                      fontSize: 14,
                      color: themeProvider.getSecondaryTextColor(),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                icon: Icons.category,
                label: languageProvider.getLocalizedText(
                  _place.category,
                  _place.category, // В реальном приложении здесь был бы перевод
                ),
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                icon: Icons.attach_money,
                label: _place.priceRange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Информационный чип
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: themeProvider.getChipColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: themeProvider.getChipTextColor(),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.getChipTextColor(),
            ),
          ),
        ],
      ),
    );
  }

  /// Описание места
  Widget _buildDescription() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languageProvider.getLocalizedText(
              'Описание',
              'Сипаттама'
            ),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.getTextColor(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _place.getDescription(languageProvider.currentLanguage),
            style: TextStyle(
              fontSize: 16,
              color: themeProvider.getTextColor(),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Информация о местоположении
  Widget _buildLocationInfo() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languageProvider.getLocalizedText(
              'Местоположение',
              'Орналасқан жері'
            ),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.getTextColor(),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: themeProvider.getSurfaceColor(),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: themeProvider.getBorderColor(),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 48,
                    color: themeProvider.getSecondaryTextColor(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    languageProvider.getLocalizedText(
                      'Карта будет здесь',
                      'Карта осы жерде болады'
                    ),
                    style: TextStyle(
                      color: themeProvider.getSecondaryTextColor(),
                    ),
                  ),
                  Text(
                    '${_place.latitude.toStringAsFixed(4)}, ${_place.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.getSecondaryTextColor(),
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

  /// Теги места
  Widget _buildTags() {
    final themeProvider = context.watch<ThemeProvider>();
    
    if (_place.tags.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Теги',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.getTextColor(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _place.tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: themeProvider.getChipColor(),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '#$tag',
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.getChipTextColor(),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Кнопки действий
  Widget _buildActionButtons() {
    final languageProvider = context.watch<LanguageProvider>();
    
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: languageProvider.getLocalizedText(
                'Добавить в маршрут',
                'Маршрутқа қосу'
              ),
              onPressed: _addToRoute,
              isOutlined: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              text: languageProvider.getLocalizedText(
                'Поделиться',
                'Бөлісу'
              ),
              onPressed: _sharePlace,
            ),
          ),
        ],
      ),
    );
  }

  /// Floating Action Button
  Widget _buildFloatingActionButton() {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return FloatingActionButton(
      onPressed: _toggleFavorite,
      backgroundColor: themeProvider.getFloatingActionButtonColor(),
      child: Icon(
        _place.isFavorite ? Icons.favorite : Icons.favorite_border,
        color: Colors.white,
      ),
    );
  }

  /// Переключение избранного
  Future<void> _toggleFavorite() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await context.read<PlacesProvider>().toggleFavorite(_place);
      setState(() {
        _place = _place.copyWith(isFavorite: !_place.isFavorite);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _place.isFavorite 
                  ? 'Добавлено в избранное'
                  : 'Удалено из избранного',
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Добавление в маршрут
  void _addToRoute() {
    // TODO: Реализовать добавление в маршрут
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Функция добавления в маршрут будет реализована'),
      ),
    );
  }

  /// Поделиться местом
  void _sharePlace() {
    // TODO: Реализовать функцию поделиться
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Функция поделиться будет реализована'),
      ),
    );
  }
}
