import 'package:flutter/material.dart';
import '../design_system.dart';
import '../components/glassmorphic_card.dart';
import '../components/gradient_button.dart';
import '../components/animated_app_bar.dart';

/// Детальный экран места с immersive дизайном
class PlaceDetailScreen extends StatefulWidget {
  final Map<String, dynamic> place;

  const PlaceDetailScreen({
    Key? key,
    required this.place,
  }) : super(key: key);

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _contentController;
  late AnimationController _likeController;
  late Animation<double> _heroAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _likeAnimation;
  
  bool _isLiked = false;
  bool _isInRoute = false;
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _scrollController.addListener(_onScroll);
  }

  void _initializeAnimations() {
    _heroController = AnimationController(
      duration: TravelKZDesign.animationSlow,
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: TravelKZDesign.animationSlow,
      vsync: this,
    );
    
    _likeController = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );

    _heroAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: TravelKZDesign.easeOut,
    ));

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: TravelKZDesign.easeOut,
    ));

    _likeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _likeController,
      curve: TravelKZDesign.elasticOut,
    ));

    // Start animations
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _contentController.forward();
    });
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final maxOffset = 200.0;
    final opacity = (offset / maxOffset).clamp(0.0, 1.0);
    
    if (opacity != _appBarOpacity) {
      setState(() {
        _appBarOpacity = opacity;
      });
    }
  }

  @override
  void dispose() {
    _heroController.dispose();
    _contentController.dispose();
    _likeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DesignUtils.isDarkMode(context);
    
    return Scaffold(
      backgroundColor: DesignUtils.getBackgroundColor(context),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Hero Image with AppBar
          SliverAppBar(
            expandedHeight: 400,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(TravelKZDesign.spacing8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(TravelKZDesign.spacing8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _isLiked = !_isLiked;
                    });
                    if (_isLiked) {
                      _likeController.forward();
                    } else {
                      _likeController.reverse();
                    }
                  },
                  icon: AnimatedBuilder(
                    animation: _likeAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (0.2 * _likeAnimation.value),
                        child: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? Colors.red : Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(TravelKZDesign.spacing8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    // Share functionality
                  },
                  icon: const Icon(
                    Icons.share,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            flexibleSpace: _buildHeroImage(),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildHeroImage() {
    return AnimatedBuilder(
      animation: _heroAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _heroAnimation.value,
          child: Transform.scale(
            scale: 0.9 + (0.1 * _heroAnimation.value),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                Image.network(
                  widget.place['image'] ?? 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: TravelKZDesign.primaryGradient,
                      ),
                    );
                  },
                ),
                
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
                
                // Title overlay
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
                          widget.place['title'] ?? 'Название места',
                          style: TravelKZDesign.h1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: TravelKZDesign.spacing8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: TravelKZDesign.spacing4),
                            Text(
                              widget.place['location'] ?? 'Местоположение',
                              style: TravelKZDesign.bodyLarge.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: TravelKZDesign.spacing12,
                                vertical: TravelKZDesign.spacing6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
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
                                    widget.place['rating']?.toString() ?? '4.5',
                                    style: TravelKZDesign.bodyMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _contentAnimation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - _contentAnimation.value)),
            child: Column(
              children: [
                // Main content card
                GlassmorphicCard(
                  margin: const EdgeInsets.all(TravelKZDesign.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      _buildDescriptionSection(),
                      
                      const SizedBox(height: TravelKZDesign.spacing24),
                      
                      // Key Facts
                      _buildKeyFactsSection(),
                      
                      const SizedBox(height: TravelKZDesign.spacing24),
                      
                      // Gallery
                      _buildGallerySection(),
                      
                      const SizedBox(height: TravelKZDesign.spacing24),
                      
                      // Map
                      _buildMapSection(),
                      
                      const SizedBox(height: TravelKZDesign.spacing24),
                      
                      // Reviews
                      _buildReviewsSection(),
                    ],
                  ),
                ),
                
                const SizedBox(height: 100), // Space for bottom actions
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Описание',
          style: TravelKZDesign.h3.copyWith(
            color: DesignUtils.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: TravelKZDesign.spacing12),
        Text(
          widget.place['description'] ?? 
          'Это удивительное место в Казахстане, которое обязательно стоит посетить. Здесь вы сможете насладиться красотой природы, познакомиться с местной культурой и получить незабываемые впечатления.',
          style: TravelKZDesign.bodyLarge.copyWith(
            color: DesignUtils.getSecondaryTextColor(context),
            height: 1.6,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget _buildKeyFactsSection() {
    final facts = [
      {'icon': Icons.height, 'label': 'Высота', 'value': '1,500 м'},
      {'icon': Icons.thermostat, 'label': 'Температура', 'value': '15-25°C'},
      {'icon': Icons.calendar_today, 'label': 'Лучший сезон', 'value': 'Май-Сентябрь'},
      {'icon': Icons.access_time, 'label': 'Время посещения', 'value': '2-3 часа'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Основная информация',
          style: TravelKZDesign.h3.copyWith(
            color: DesignUtils.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: TravelKZDesign.spacing16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: TravelKZDesign.spacing12,
            mainAxisSpacing: TravelKZDesign.spacing12,
          ),
          itemCount: facts.length,
          itemBuilder: (context, index) {
            final fact = facts[index];
            return Container(
              padding: const EdgeInsets.all(TravelKZDesign.spacing12),
              decoration: BoxDecoration(
                color: DesignUtils.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(TravelKZDesign.radiusMedium),
                border: Border.all(
                  color: DesignUtils.getSecondaryTextColor(context).withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    fact['icon'] as IconData,
                    color: TravelKZDesign.primaryGradient.colors.first,
                    size: 20,
                  ),
                  const SizedBox(width: TravelKZDesign.spacing8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          fact['label'] as String,
                          style: TravelKZDesign.bodySmall.copyWith(
                            color: DesignUtils.getSecondaryTextColor(context),
                          ),
                        ),
                        Text(
                          fact['value'] as String,
                          style: TravelKZDesign.bodyMedium.copyWith(
                            color: DesignUtils.getTextColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGallerySection() {
    final galleryImages = [
      'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
      'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
      'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
      'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Галерея',
          style: TravelKZDesign.h3.copyWith(
            color: DesignUtils.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: TravelKZDesign.spacing16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: galleryImages.length,
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: TravelKZDesign.spacing12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(TravelKZDesign.radiusMedium),
                  child: Image.network(
                    galleryImages[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: TravelKZDesign.secondaryGradient,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Расположение',
          style: TravelKZDesign.h3.copyWith(
            color: DesignUtils.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: TravelKZDesign.spacing16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: TravelKZDesign.secondaryGradient,
            borderRadius: BorderRadius.circular(TravelKZDesign.radiusMedium),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: TravelKZDesign.spacing8),
                Text(
                  'Интерактивная карта',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Отзывы',
              style: TravelKZDesign.h3.copyWith(
                color: DesignUtils.getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to all reviews
              },
              child: Text(
                'Все отзывы',
                style: TravelKZDesign.bodyMedium.copyWith(
                  color: TravelKZDesign.primaryGradient.colors.first,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: TravelKZDesign.spacing16),
        // Sample review
        Container(
          padding: const EdgeInsets.all(TravelKZDesign.spacing16),
          decoration: BoxDecoration(
            color: DesignUtils.getSurfaceColor(context),
            borderRadius: BorderRadius.circular(TravelKZDesign.radiusMedium),
            border: Border.all(
              color: DesignUtils.getSecondaryTextColor(context).withOpacity(0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: TravelKZDesign.primaryGradient.colors.first,
                    child: const Text(
                      'А',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: TravelKZDesign.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Айдар Нурланов',
                          style: TravelKZDesign.bodyMedium.copyWith(
                            color: DesignUtils.getTextColor(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TravelKZDesign.spacing12),
              Text(
                'Потрясающее место! Обязательно рекомендую посетить. Красивые виды и отличная атмосфера.',
                style: TravelKZDesign.bodyMedium.copyWith(
                  color: DesignUtils.getSecondaryTextColor(context),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(TravelKZDesign.spacing16),
      decoration: BoxDecoration(
        color: DesignUtils.getSurfaceColor(context),
        boxShadow: TravelKZDesign.shadowLarge,
        border: Border(
          top: BorderSide(
            color: DesignUtils.getSecondaryTextColor(context).withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: GradientButton(
                text: _isInRoute ? 'В маршруте' : 'Добавить в маршрут',
                onPressed: () {
                  setState(() {
                    _isInRoute = !_isInRoute;
                  });
                },
                gradient: _isInRoute 
                    ? TravelKZDesign.secondaryGradient
                    : TravelKZDesign.primaryGradient,
                icon: _isInRoute ? Icons.check : Icons.add,
              ),
            ),
            const SizedBox(width: TravelKZDesign.spacing16),
            GradientIconButton(
              icon: Icons.share,
              onPressed: () {
                // Share functionality
              },
              gradient: TravelKZDesign.accentGradient,
            ),
          ],
        ),
      ),
    );
  }
}
