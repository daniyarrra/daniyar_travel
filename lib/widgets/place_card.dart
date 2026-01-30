import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../models/place.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// Карточка места для отображения в списках и сетках
/// Поддерживает горизонтальный и вертикальный режимы отображения
class PlaceCard extends StatelessWidget {
  final Place place;
  final bool isHorizontal;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const PlaceCard({
    super.key,
    required this.place,
    this.isHorizontal = false,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    if (isHorizontal) {
      return _buildHorizontalCard(context);
    } else {
      return _buildVerticalCard(context);
    }
  }

  /// Вертикальная карточка (для сетки)
  Widget _buildVerticalCard(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(context),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  /// Горизонтальная карточка (для списка)
  Widget _buildHorizontalCard(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Row(
          children: [
            _buildImage(context, isHorizontal: true),
            Expanded(
              child: _buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Изображение места
  Widget _buildImage(BuildContext context, {bool isHorizontal = false}) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Stack(
      children: [
        Container(
          height: isHorizontal ? 120 : AppConstants.imageHeight,
          width: isHorizontal ? 120 : double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppConstants.borderRadius),
              topRight: const Radius.circular(AppConstants.borderRadius),
              bottomLeft: isHorizontal ? const Radius.circular(AppConstants.borderRadius) : Radius.zero,
              bottomRight: isHorizontal ? const Radius.circular(AppConstants.borderRadius) : Radius.zero,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(AppConstants.borderRadius),
              topRight: const Radius.circular(AppConstants.borderRadius),
              bottomLeft: isHorizontal ? const Radius.circular(AppConstants.borderRadius) : Radius.zero,
              bottomRight: isHorizontal ? const Radius.circular(AppConstants.borderRadius) : Radius.zero,
            ),
            child: place.imageUrl.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: place.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: themeProvider.getSurfaceColor(),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: themeProvider.getPrimaryColor(),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: themeProvider.getSurfaceColor(),
                      child: Icon(
                        Icons.image_not_supported,
                        color: themeProvider.getSecondaryTextColor(),
                      ),
                    ),
                  )
                : Image.file(
                    File(place.imageUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: themeProvider.getSurfaceColor(),
                      child: Icon(
                        Icons.broken_image,
                        color: themeProvider.getSecondaryTextColor(),
                      ),
                    ),
                  ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: _buildFavoriteButton(context),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          child: _buildCategoryChip(context),
        ),
      ],
    );
  }

  /// Содержимое карточки
  Widget _buildContent(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          const SizedBox(height: 4),
          _buildLocation(context),
          const SizedBox(height: 8),
          _buildRating(context),
          const SizedBox(height: 8),
          _buildPriceRange(context),
        ],
      ),
    );
  }

  /// Название места
  Widget _buildTitle(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    return Text(
      place.getName(languageProvider.currentLanguage),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: themeProvider.getTextColor(),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Местоположение
  Widget _buildLocation(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: 14,
          color: themeProvider.getSecondaryTextColor(),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            place.city,
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.getSecondaryTextColor(),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Рейтинг
  Widget _buildRating(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Row(
      children: [
        Icon(
          Icons.star,
          size: 16,
          color: Colors.amber,
        ),
        const SizedBox(width: 4),
        Text(
          AppHelpers.formatRating(place.rating),
          style: TextStyle(
            fontSize: 12,
            color: themeProvider.getSecondaryTextColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Диапазон цен
  Widget _buildPriceRange(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: themeProvider.getChipColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        place.priceRange,
        style: TextStyle(
          fontSize: 10,
          color: themeProvider.getChipTextColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Кнопка избранного
  Widget _buildFavoriteButton(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return GestureDetector(
      onTap: onFavoriteTap ?? () {},
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          place.isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 16,
          color: place.isFavorite ? Colors.red : Colors.white,
        ),
      ),
    );
  }

  /// Чип категории
  Widget _buildCategoryChip(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        place.category,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
