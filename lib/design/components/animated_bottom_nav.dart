import 'package:flutter/material.dart';
import '../design_system.dart';

/// Анимированная нижняя навигация с Glassmorphism эффектом
class AnimatedBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final List<BottomNavItem> items;
  final Color? backgroundColor;
  final bool showLabels;
  final double? height;

  const AnimatedBottomNav({
    Key? key,
    required this.currentIndex,
    this.onTap,
    required this.items,
    this.backgroundColor,
    this.showLabels = true,
    this.height,
  }) : super(key: key);

  @override
  State<AnimatedBottomNav> createState() => _AnimatedBottomNavState();
}

class BottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final Color? color;
  final Gradient? gradient;

  const BottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.color,
    this.gradient,
  });
}

class _AnimatedBottomNavState extends State<AnimatedBottomNav>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _bubbleAnimations;
  late AnimationController _labelController;
  late Animation<double> _labelAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: TravelKZDesign.animationMedium,
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 1.0,
        end: 1.2,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: TravelKZDesign.easeOut,
      ));
    }).toList();

    _bubbleAnimations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: TravelKZDesign.easeOut,
      ));
    }).toList();

    _labelController = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );

    _labelAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _labelController,
      curve: TravelKZDesign.easeOut,
    ));

    // Start with current index selected
    _controllers[widget.currentIndex].forward();
    if (widget.showLabels) {
      _labelController.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controllers[oldWidget.currentIndex].reverse();
      _controllers[widget.currentIndex].forward();
    }

    if (oldWidget.showLabels != widget.showLabels) {
      if (widget.showLabels) {
        _labelController.forward();
      } else {
        _labelController.reverse();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DesignUtils.isDarkMode(context);
    
    return Container(
      height: widget.height ?? 80,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? 
            (isDark 
                ? TravelKZDesign.darkSurface.withOpacity(0.9)
                : TravelKZDesign.lightSurface.withOpacity(0.9)),
        boxShadow: TravelKZDesign.shadowLarge,
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == widget.currentIndex;

              return Expanded(
                child: _buildNavItem(
                  context,
                  index,
                  item,
                  isSelected,
                  isDark,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    BottomNavItem item,
    bool isSelected,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => widget.onTap?.call(index),
      child: AnimatedBuilder(
        animation: _controllers[index],
        builder: (context, child) {
          return Container(
            height: widget.height ?? 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bubble animation
                if (isSelected)
                  AnimatedBuilder(
                    animation: _bubbleAnimations[index],
                    builder: (context, child) {
                      return Container(
                        width: 40 + (20 * _bubbleAnimations[index].value),
                        height: 40 + (20 * _bubbleAnimations[index].value),
                        decoration: BoxDecoration(
                          gradient: item.gradient ?? TravelKZDesign.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (item.gradient?.colors.first ?? TravelKZDesign.primaryGradient.colors.first)
                                  .withOpacity(0.3 * _bubbleAnimations[index].value),
                              blurRadius: 8 * _bubbleAnimations[index].value,
                              spreadRadius: 2 * _bubbleAnimations[index].value,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Transform.scale(
                            scale: _scaleAnimations[index].value,
                            child: Icon(
                              isSelected && item.activeIcon != null
                                  ? item.activeIcon!
                                  : item.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                else
                  // Regular icon
                  Container(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: Icon(
                        item.icon,
                        color: item.color ?? DesignUtils.getSecondaryTextColor(context),
                        size: 20,
                      ),
                    ),
                  ),

                // Label
                if (widget.showLabels) ...[
                  const SizedBox(height: TravelKZDesign.spacing4),
                  AnimatedBuilder(
                    animation: _labelAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _labelAnimation.value,
                        child: Text(
                          item.label,
                          style: TravelKZDesign.bodySmall.copyWith(
                            color: isSelected
                                ? (item.gradient?.colors.first ?? TravelKZDesign.primaryGradient.colors.first)
                                : DesignUtils.getSecondaryTextColor(context),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Предустановленные элементы навигации для TravelKZ
class TravelKZBottomNavItems {
  static const List<BottomNavItem> defaultItems = [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Главная',
      gradient: TravelKZDesign.primaryGradient,
    ),
    BottomNavItem(
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: 'Поиск',
      gradient: TravelKZDesign.secondaryGradient,
    ),
    BottomNavItem(
      icon: Icons.route_outlined,
      activeIcon: Icons.route,
      label: 'Маршруты',
      gradient: TravelKZDesign.accentGradient,
    ),
    BottomNavItem(
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
      label: 'Избранное',
      gradient: TravelKZDesign.accentGradient,
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Профиль',
      gradient: TravelKZDesign.primaryGradient,
    ),
  ];
}

/// Плавающая кнопка навигации
class FloatingNavButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final String? tooltip;
  final double size;

  const FloatingNavButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.gradient,
    this.tooltip,
    this.size = 56,
  }) : super(key: key);

  @override
  State<FloatingNavButton> createState() => _FloatingNavButtonState();
}

class _FloatingNavButtonState extends State<FloatingNavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: TravelKZDesign.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: TravelKZDesign.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip ?? '',
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    gradient: widget.gradient ?? TravelKZDesign.accentGradient,
                    shape: BoxShape.circle,
                    boxShadow: TravelKZDesign.shadowLarge,
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: widget.size * 0.5,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
