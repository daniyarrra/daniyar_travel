import 'package:flutter/material.dart';
import '../design_system.dart';
import '../components/glassmorphic_card.dart';
import '../components/gradient_button.dart';
import '../components/gradient_input_field.dart';
import '../components/animated_app_bar.dart';
import '../components/animated_bottom_nav.dart';

/// Главный экран приложения с современным дизайном
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _bannerController;
  late AnimationController _categoriesController;
  late AnimationController _placesController;
  late Animation<double> _bannerAnimation;
  late Animation<double> _categoriesAnimation;
  late Animation<double> _placesAnimation;
  
  int _currentBannerIndex = 0;
  int _selectedCategoryIndex = 0;
  final PageController _bannerController_page = PageController();
  
  final List<String> _categories = [
    'Горы',
    'Города', 
    'Пляжи',
    'Озёра',
    'История',
    'Культура',
    'Природа',
    'Активный отдых',
  ];

  final List<IconData> _categoryIcons = [
    Icons.landscape,
    Icons.location_city,
    Icons.beach_access,
    Icons.water,
    Icons.museum,
    Icons.theater_comedy,
    Icons.park,
    Icons.directions_run,
  ];

  final List<Map<String, dynamic>> _featuredPlaces = [
    {
      'title': 'Алматы',
      'location': 'Южный Казахстан',
      'rating': 4.8,
      'reviews': 1250,
      'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
      'description': 'Культурная столица Казахстана с богатой историей',
    },
    {
      'title': 'Астана',
      'location': 'Северный Казахстан',
      'rating': 4.6,
      'reviews': 980,
      'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
      'description': 'Современная столица с футуристической архитектурой',
    },
    {
      'title': 'Шымкент',
      'location': 'Южный Казахстан',
      'rating': 4.5,
      'reviews': 750,
      'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
      'description': 'Древний город с многовековой историей',
    },
  ];

  final List<Map<String, dynamic>> _popularPlaces = [
    {
      'title': 'Медео',
      'location': 'Алматы',
      'rating': 4.9,
      'reviews': 2100,
      'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
      'isFavorite': true,
    },
    {
      'title': 'Боровое',
      'location': 'Акмолинская область',
      'rating': 4.7,
      'reviews': 1800,
      'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
      'isFavorite': false,
    },
    {
      'title': 'Чарынский каньон',
      'location': 'Алматинская область',
      'rating': 4.8,
      'reviews': 1650,
      'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
      'isFavorite': true,
    },
    {
      'title': 'Байконур',
      'location': 'Кызылординская область',
      'rating': 4.6,
      'reviews': 1200,
      'image': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
      'isFavorite': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startBannerAnimation();
  }

  void _initializeAnimations() {
    _bannerController = AnimationController(
      duration: TravelKZDesign.animationSlow,
      vsync: this,
    );
    
    _categoriesController = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );
    
    _placesController = AnimationController(
      duration: TravelKZDesign.animationSlow,
      vsync: this,
    );

    _bannerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bannerController,
      curve: TravelKZDesign.easeOut,
    ));

    _categoriesAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _categoriesController,
      curve: TravelKZDesign.easeOut,
    ));

    _placesAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _placesController,
      curve: TravelKZDesign.easeOut,
    ));

    // Start animations with delay
    Future.delayed(const Duration(milliseconds: 200), () {
      _bannerController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 400), () {
      _categoriesController.forward();
    });
    
    Future.delayed(const Duration(milliseconds: 600), () {
      _placesController.forward();
    });
  }

  void _startBannerAnimation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % _featuredPlaces.length;
        });
        _bannerController_page.animateToPage(
          _currentBannerIndex,
          duration: TravelKZDesign.animationMedium,
          curve: TravelKZDesign.easeInOut,
        );
        _startBannerAnimation();
      }
    });
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _categoriesController.dispose();
    _placesController.dispose();
    _bannerController_page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DesignUtils.isDarkMode(context);
    
    return Scaffold(
      backgroundColor: DesignUtils.getBackgroundColor(context),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: _buildAppBar(isDark),
          ),
          
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(TravelKZDesign.spacing16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Search Bar
                _buildSearchSection(),
                
                const SizedBox(height: TravelKZDesign.spacing24),
                
                // Featured Banner
                _buildFeaturedBanner(),
                
                const SizedBox(height: TravelKZDesign.spacing24),
                
                // Categories
                _buildCategoriesSection(),
                
                const SizedBox(height: TravelKZDesign.spacing24),
                
                // Popular Places
                _buildPopularPlacesSection(),
                
                const SizedBox(height: TravelKZDesign.spacing32),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: 0,
        items: TravelKZBottomNavItems.defaultItems,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return AnimatedBuilder(
      animation: _bannerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: TravelKZDesign.primaryGradient,
            boxShadow: TravelKZDesign.shadowMedium,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(TravelKZDesign.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Greeting
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Привет, путешественник!',
                              style: TravelKZDesign.h2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: TravelKZDesign.spacing4),
                            Text(
                              'Откройте красоту Казахстана',
                              style: TravelKZDesign.bodyMedium.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Notification icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(TravelKZDesign.radiusLarge),
                        ),
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchSection() {
    return AnimatedSearchField(
      hintText: 'Поиск мест в Казахстане...',
      onSearchChanged: (query) {
        // Handle search
      },
      onTap: () {
        // Navigate to search screen
      },
      leading: Icon(
        Icons.search,
        color: DesignUtils.getSecondaryTextColor(context),
        size: 20,
      ),
    );
  }

  Widget _buildFeaturedBanner() {
    return AnimatedBuilder(
      animation: _bannerAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _bannerAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _bannerAnimation.value)),
            child: SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _bannerController_page,
                onPageChanged: (index) {
                  setState(() {
                    _currentBannerIndex = index;
                  });
                },
                itemCount: _featuredPlaces.length,
                itemBuilder: (context, index) {
                  final place = _featuredPlaces[index];
                  return _buildBannerCard(place);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBannerCard(Map<String, dynamic> place) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: TravelKZDesign.spacing8),
      child: Stack(
        children: [
          // Background image
          ClipRRect(
            borderRadius: BorderRadius.circular(TravelKZDesign.radiusXLarge),
            child: Image.network(
              place['image'],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: TravelKZDesign.primaryGradient,
                  ),
                );
              },
            ),
          ),
          
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TravelKZDesign.radiusXLarge),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          
          // Content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(TravelKZDesign.spacing20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place['title'],
                    style: TravelKZDesign.h2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: TravelKZDesign.spacing4),
                  Text(
                    place['location'],
                    style: TravelKZDesign.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: TravelKZDesign.spacing8),
                  Text(
                    place['description'],
                    style: TravelKZDesign.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          
          // Rating badge
          Positioned(
            top: TravelKZDesign.spacing16,
            right: TravelKZDesign.spacing16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: TravelKZDesign.spacing12,
                vertical: TravelKZDesign.spacing6,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(TravelKZDesign.radiusLarge),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: TravelKZDesign.spacing4),
                  Text(
                    place['rating'].toString(),
                    style: TravelKZDesign.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  Widget _buildCategoriesSection() {
    return AnimatedBuilder(
      animation: _categoriesAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _categoriesAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _categoriesAnimation.value)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Категории',
                  style: TravelKZDesign.h3.copyWith(
                    color: DesignUtils.getTextColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: TravelKZDesign.spacing16),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: TravelKZDesign.spacing12),
                        child: CategoryChip(
                          label: _categories[index],
                          icon: _categoryIcons[index],
                          isSelected: index == _selectedCategoryIndex,
                          onTap: () {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopularPlacesSection() {
    return AnimatedBuilder(
      animation: _placesAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _placesAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _placesAnimation.value)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Популярные места',
                      style: TravelKZDesign.h3.copyWith(
                        color: DesignUtils.getTextColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to all places
                      },
                      child: Text(
                        'Все места',
                        style: TravelKZDesign.bodyMedium.copyWith(
                          color: TravelKZDesign.primaryGradient.colors.first,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TravelKZDesign.spacing16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: TravelKZDesign.spacing16,
                    mainAxisSpacing: TravelKZDesign.spacing16,
                  ),
                  itemCount: _popularPlaces.length,
                  itemBuilder: (context, index) {
                    final place = _popularPlaces[index];
                    return PlaceCard(
                      imageUrl: place['image'],
                      title: place['title'],
                      location: place['location'],
                      rating: place['rating'],
                      reviewCount: place['reviews'],
                      isFavorite: place['isFavorite'],
                      onTap: () {
                        // Navigate to place detail
                      },
                      onFavoriteTap: () {
                        setState(() {
                          _popularPlaces[index]['isFavorite'] = 
                              !_popularPlaces[index]['isFavorite'];
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
