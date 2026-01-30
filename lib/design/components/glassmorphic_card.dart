import 'package:flutter/material.dart';
import '../design_system.dart';

/// Glassmorphic карточка с эффектом стекла и анимациями
class GlassmorphicCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool enableHover;
  final double borderRadius;
  final Color? backgroundColor;
  final double blurRadius;
  final double opacity;

  const GlassmorphicCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.enableHover = true,
    this.borderRadius = 20.0,
    this.backgroundColor,
    this.blurRadius = 10.0,
    this.opacity = 0.1,
  }) : super(key: key);

  @override
  State<GlassmorphicCard> createState() => _GlassmorphicCardState();
}

class _GlassmorphicCardState extends State<GlassmorphicCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: TravelKZDesign.easeOut,
    ));

    _shadowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: TravelKZDesign.easeOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHoverEnter() {
    if (widget.enableHover) {
      setState(() => _isHovered = true);
      _hoverController.forward();
    }
  }

  void _onHoverExit() {
    if (widget.enableHover) {
      setState(() => _isHovered = false);
      _hoverController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DesignUtils.isDarkMode(context);
    
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _onHoverEnter(),
            onExit: (_) => _onHoverExit(),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: widget.width,
                height: widget.height,
                margin: widget.margin,
                decoration: BoxDecoration(
                  color: widget.backgroundColor?.withOpacity(widget.opacity) ??
                      (isDark 
                          ? Colors.white.withOpacity(widget.opacity)
                          : Colors.black.withOpacity(widget.opacity * 0.1)),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1 + (0.1 * _shadowAnimation.value)),
                      offset: Offset(0, 4 + (4 * _shadowAnimation.value)),
                      blurRadius: 12 + (8 * _shadowAnimation.value),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: widget.blurRadius,
                      sigmaY: widget.blurRadius,
                    ),
                    child: Padding(
                      padding: widget.padding ?? const EdgeInsets.all(TravelKZDesign.spacing16),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Карточка места с изображением и градиентным оверлеем
class PlaceCard extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String location;
  final double rating;
  final int reviewCount;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final String? description;

  const PlaceCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.rating,
    required this.reviewCount,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
    this.description,
  }) : super(key: key);

  @override
  State<PlaceCard> createState() => _PlaceCardState();
}

class _PlaceCardState extends State<PlaceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _favoriteController;
  late Animation<double> _favoriteAnimation;

  @override
  void initState() {
    super.initState();
    _favoriteController = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );
    _favoriteAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _favoriteController,
      curve: TravelKZDesign.elasticOut,
    ));

    if (widget.isFavorite) {
      _favoriteController.forward();
    }
  }

  @override
  void didUpdateWidget(PlaceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite) {
      if (widget.isFavorite) {
        _favoriteController.forward();
      } else {
        _favoriteController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _favoriteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      onTap: widget.onTap,
      enableHover: true,
      borderRadius: TravelKZDesign.radiusXLarge,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          children: [
            // Background image
            ClipRRect(
              borderRadius: BorderRadius.circular(TravelKZDesign.radiusXLarge),
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: TravelKZDesign.primaryGradient,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 48,
                      ),
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
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
            
            // Rating badge
            Positioned(
              top: TravelKZDesign.spacing12,
              right: TravelKZDesign.spacing12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: TravelKZDesign.spacing8,
                  vertical: TravelKZDesign.spacing4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(TravelKZDesign.radiusMedium),
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
                      widget.rating.toString(),
                      style: TravelKZDesign.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Favorite button
            Positioned(
              top: TravelKZDesign.spacing12,
              left: TravelKZDesign.spacing12,
              child: GestureDetector(
                onTap: widget.onFavoriteTap,
                child: AnimatedBuilder(
                  animation: _favoriteAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (0.2 * _favoriteAnimation.value),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: widget.isFavorite ? Colors.red : Colors.white,
                          size: 20,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(TravelKZDesign.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: TravelKZDesign.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: TravelKZDesign.spacing4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: TravelKZDesign.spacing4),
                        Expanded(
                          child: Text(
                            widget.location,
                            style: TravelKZDesign.bodySmall.copyWith(
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${widget.reviewCount} отзывов',
                          style: TravelKZDesign.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    if (widget.description != null) ...[
                      const SizedBox(height: TravelKZDesign.spacing8),
                      Text(
                        widget.description!,
                        style: TravelKZDesign.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Карточка маршрута с горизонтальным макетом
class RouteCard extends StatefulWidget {
  final String title;
  final String dateRange;
  final int placesCount;
  final double budget;
  final double progress;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RouteCard({
    Key? key,
    required this.title,
    required this.dateRange,
    required this.placesCount,
    required this.budget,
    required this.progress,
    this.imageUrl,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  State<RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: TravelKZDesign.animationSlow,
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: TravelKZDesign.easeOut,
    ));
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DesignUtils.isDarkMode(context);
    
    return GlassmorphicCard(
      onTap: widget.onTap,
      margin: const EdgeInsets.only(bottom: TravelKZDesign.spacing16),
      child: Row(
        children: [
          // Image or icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TravelKZDesign.radiusMedium),
              gradient: TravelKZDesign.secondaryGradient,
            ),
            child: widget.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(TravelKZDesign.radiusMedium),
                    child: Image.network(
                      widget.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.route,
                          color: Colors.white,
                          size: 32,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.route,
                    color: Colors.white,
                    size: 32,
                  ),
          ),
          
          const SizedBox(width: TravelKZDesign.spacing16),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TravelKZDesign.h3.copyWith(
                    color: DesignUtils.getTextColor(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: TravelKZDesign.spacing4),
                Text(
                  widget.dateRange,
                  style: TravelKZDesign.bodyMedium.copyWith(
                    color: DesignUtils.getSecondaryTextColor(context),
                  ),
                ),
                const SizedBox(height: TravelKZDesign.spacing8),
                Row(
                  children: [
                    Icon(
                      Icons.place,
                      size: 16,
                      color: DesignUtils.getSecondaryTextColor(context),
                    ),
                    const SizedBox(width: TravelKZDesign.spacing4),
                    Text(
                      '${widget.placesCount} мест',
                      style: TravelKZDesign.bodySmall.copyWith(
                        color: DesignUtils.getSecondaryTextColor(context),
                      ),
                    ),
                    const SizedBox(width: TravelKZDesign.spacing16),
                    Icon(
                      Icons.account_balance_wallet,
                      size: 16,
                      color: DesignUtils.getSecondaryTextColor(context),
                    ),
                    const SizedBox(width: TravelKZDesign.spacing4),
                    Text(
                      '${widget.budget.toStringAsFixed(0)} ₸',
                      style: TravelKZDesign.bodySmall.copyWith(
                        color: DesignUtils.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TravelKZDesign.spacing12),
                
                // Progress bar
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Прогресс',
                              style: TravelKZDesign.bodySmall.copyWith(
                                color: DesignUtils.getSecondaryTextColor(context),
                              ),
                            ),
                            Text(
                              '${(_progressAnimation.value * 100).toInt()}%',
                              style: TravelKZDesign.bodySmall.copyWith(
                                color: DesignUtils.getSecondaryTextColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: TravelKZDesign.spacing4),
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark 
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progressAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: TravelKZDesign.primaryGradient,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Action buttons
          Column(
            children: [
              IconButton(
                onPressed: widget.onEdit,
                icon: Icon(
                  Icons.edit,
                  color: DesignUtils.getSecondaryTextColor(context),
                ),
              ),
              IconButton(
                onPressed: widget.onDelete,
                icon: Icon(
                  Icons.delete,
                  color: TravelKZDesign.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
