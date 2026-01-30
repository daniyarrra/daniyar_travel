import 'package:flutter/material.dart';
import '../design_system.dart';
import '../components/glassmorphic_card.dart';
import '../components/animated_app_bar.dart';
import '../components/empty_state.dart';

/// Экран избранных мест с анимациями
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  late AnimationController _listController;
  late AnimationController _emptyController;
  late Animation<double> _listAnimation;
  late Animation<double> _emptyAnimation;
  
  List<Map<String, dynamic>> _favorites = [
    {
      'id': '1',
      'title': 'Медео',
      'location': 'Алматы',
      'rating': 4.9,
      'reviews': 2100,
      'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
      'description': 'Высокогорный каток и спортивный комплекс',
      'isFavorite': true,
    },
    {
      'id': '2',
      'title': 'Чарынский каньон',
      'location': 'Алматинская область',
      'rating': 4.8,
      'reviews': 1650,
      'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
      'description': 'Уникальный природный памятник',
      'isFavorite': true,
    },
    {
      'id': '3',
      'title': 'Боровое',
      'location': 'Акмолинская область',
      'rating': 4.7,
      'reviews': 1800,
      'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
      'description': 'Красивое озеро и горы',
      'isFavorite': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _listController = AnimationController(
      duration: TravelKZDesign.animationSlow,
      vsync: this,
    );
    
    _emptyController = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );

    _listAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listController,
      curve: TravelKZDesign.easeOut,
    ));

    _emptyAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _emptyController,
      curve: TravelKZDesign.easeOut,
    ));

    // Start animation
    if (_favorites.isNotEmpty) {
      _listController.forward();
    } else {
      _emptyController.forward();
    }
  }

  @override
  void dispose() {
    _listController.dispose();
    _emptyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignUtils.getBackgroundColor(context),
      appBar: AnimatedAppBar(
        title: 'Избранное',
        showBackButton: false,
        actions: [
          IconButton(
            onPressed: () {
              // Search functionality
            },
            icon: Icon(
              Icons.search,
              color: DesignUtils.getTextColor(context),
            ),
          ),
          IconButton(
            onPressed: () {
              // Filter functionality
            },
            icon: Icon(
              Icons.filter_list,
              color: DesignUtils.getTextColor(context),
            ),
          ),
        ],
      ),
      body: _favorites.isEmpty ? _buildEmptyState() : _buildFavoritesList(),
    );
  }

  Widget _buildEmptyState() {
    return AnimatedBuilder(
      animation: _emptyAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _emptyAnimation.value,
          child: Transform.scale(
            scale: 0.9 + (0.1 * _emptyAnimation.value),
            child: EmptyState(
              icon: Icons.favorite_border,
              title: 'Нет избранных мест',
              description: 'Добавьте места в избранное, чтобы они появились здесь',
              actionText: 'Найти места',
              onActionPressed: () {
                // Navigate to search
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoritesList() {
    return AnimatedBuilder(
      animation: _listAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _listAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _listAnimation.value)),
            child: ListView.builder(
              padding: const EdgeInsets.all(TravelKZDesign.spacing16),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                return _buildFavoriteItem(_favorites[index], index);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteItem(Map<String, dynamic> place, int index) {
    return Dismissible(
      key: Key(place['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: TravelKZDesign.spacing16),
        decoration: BoxDecoration(
          color: TravelKZDesign.error,
          borderRadius: BorderRadius.circular(TravelKZDesign.radiusXLarge),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: TravelKZDesign.spacing24),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(place);
      },
      onDismissed: (direction) {
        _removeFavorite(place['id']);
      },
      child: AnimatedContainer(
        duration: TravelKZDesign.animationMedium,
        margin: const EdgeInsets.only(bottom: TravelKZDesign.spacing16),
        child: PlaceCard(
          imageUrl: place['image'],
          title: place['title'],
          location: place['location'],
          rating: place['rating'],
          reviewCount: place['reviews'],
          isFavorite: place['isFavorite'],
          description: place['description'],
          onTap: () {
            // Navigate to place detail
          },
          onFavoriteTap: () {
            _removeFavorite(place['id']);
          },
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(Map<String, dynamic> place) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TravelKZDesign.radiusXLarge),
          ),
          title: Text(
            'Удалить из избранного?',
            style: TravelKZDesign.h3.copyWith(
              color: DesignUtils.getTextColor(context),
            ),
          ),
          content: Text(
            'Вы уверены, что хотите удалить "${place['title']}" из избранного?',
            style: TravelKZDesign.bodyMedium.copyWith(
              color: DesignUtils.getSecondaryTextColor(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Отмена',
                style: TravelKZDesign.bodyMedium.copyWith(
                  color: DesignUtils.getSecondaryTextColor(context),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Удалить',
                style: TravelKZDesign.bodyMedium.copyWith(
                  color: TravelKZDesign.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _removeFavorite(String id) {
    setState(() {
      _favorites.removeWhere((place) => place['id'] == id);
    });

    if (_favorites.isEmpty) {
      _listController.reverse();
      _emptyController.forward();
    }

    // Show undo snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Место удалено из избранного'),
        action: SnackBarAction(
          label: 'Отменить',
          onPressed: () {
            // Add back to favorites
            // This would require storing the removed item
          },
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TravelKZDesign.radiusMedium),
        ),
      ),
    );
  }
}

/// Пустое состояние для избранного
class FavoritesEmptyState extends StatelessWidget {
  final VoidCallback? onExplorePressed;

  const FavoritesEmptyState({
    Key? key,
    this.onExplorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TravelKZDesign.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated heart icon
            TweenAnimationBuilder<double>(
              duration: TravelKZDesign.animationSlow,
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: TravelKZDesign.accentGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: TravelKZDesign.accentGradient.colors.first.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: TravelKZDesign.spacing32),
            
            Text(
              'Нет избранных мест',
              style: TravelKZDesign.h2.copyWith(
                color: DesignUtils.getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: TravelKZDesign.spacing16),
            
            Text(
              'Добавьте места в избранное, нажав на сердечко, и они появятся здесь',
              style: TravelKZDesign.bodyLarge.copyWith(
                color: DesignUtils.getSecondaryTextColor(context),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: TravelKZDesign.spacing32),
            
            GradientButton(
              text: 'Найти места',
              onPressed: onExplorePressed,
              gradient: TravelKZDesign.primaryGradient,
              icon: Icons.explore,
            ),
          ],
        ),
      ),
    );
  }
}
