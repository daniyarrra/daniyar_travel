import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system.dart';

/// Коллекция микроинтераций для TravelKZ
class MicroInteractions {
  
  /// Анимация лайка с частицами
  static Widget likeAnimation({
    required bool isLiked,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return _LikeAnimationWidget(
      isLiked: isLiked,
      onTap: onTap,
      child: child,
    );
  }

  /// Анимация добавления в маршрут с галочкой
  static Widget addToRouteAnimation({
    required bool isAdded,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return _AddToRouteAnimationWidget(
      isAdded: isAdded,
      onTap: onTap,
      child: child,
    );
  }

  /// Анимация навигационных табов с пузырьком
  static Widget tabAnimation({
    required bool isSelected,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return _TabAnimationWidget(
      isSelected: isSelected,
      onTap: onTap,
      child: child,
    );
  }

  /// Анимация поисковой строки с расширением
  static Widget searchAnimation({
    required bool isExpanded,
    required Widget child,
  }) {
    return _SearchAnimationWidget(
      isExpanded: isExpanded,
      child: child,
    );
  }

  /// Анимация карточки при нажатии
  static Widget cardTapAnimation({
    required Widget child,
    VoidCallback? onTap,
  }) {
    return _CardTapAnimationWidget(
      onTap: onTap,
      child: child,
    );
  }

  /// Анимация удаления элемента списка
  static Widget swipeToDeleteAnimation({
    required Widget child,
    required VoidCallback onDelete,
    String? deleteText,
  }) {
    return _SwipeToDeleteAnimationWidget(
      onDelete: onDelete,
      deleteText: deleteText,
      child: child,
    );
  }

  /// Анимация появления FAB при скролле
  static Widget scrollToTopFAB({
    required ScrollController scrollController,
    required Widget child,
  }) {
    return _ScrollToTopFABWidget(
      scrollController: scrollController,
      child: child,
    );
  }

  /// Анимация загрузки с shimmer эффектом
  static Widget shimmerLoading({
    required Widget child,
    bool isLoading = true,
  }) {
    return _ShimmerLoadingWidget(
      isLoading: isLoading,
      child: child,
    );
  }

  /// Анимация появления элементов списка
  static Widget staggeredListAnimation({
    required List<Widget> children,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    return _StaggeredListAnimationWidget(
      children: children,
      delay: delay,
    );
  }
}

/// Виджет анимации лайка
class _LikeAnimationWidget extends StatefulWidget {
  final bool isLiked;
  final Widget child;
  final VoidCallback? onTap;

  const _LikeAnimationWidget({
    required this.isLiked,
    required this.child,
    this.onTap,
  });

  @override
  State<_LikeAnimationWidget> createState() => _LikeAnimationWidgetState();
}

class _LikeAnimationWidgetState extends State<_LikeAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _colorAnimation;
  late Animation<double> _particleAnimation;
  List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: TravelKZDesign.elasticOut,
    ));

    _colorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: TravelKZDesign.easeOut,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: TravelKZDesign.easeOut,
    ));

    if (widget.isLiked) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_LikeAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked != oldWidget.isLiked) {
      if (widget.isLiked) {
        _createParticles();
        _controller.forward();
        _particleController.forward();
        HapticFeedback.mediumImpact();
      } else {
        _controller.reverse();
      }
    }
  }

  void _createParticles() {
    _particles.clear();
    for (int i = 0; i < 8; i++) {
      _particles.add(Particle());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_controller, _particleController]),
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Particles
              if (_particles.isNotEmpty)
                ..._particles.map((particle) {
                  final progress = _particleAnimation.value;
                  final angle = particle.angle + (progress * 2 * 3.14159);
                  final distance = particle.distance * progress;
                  final opacity = (1.0 - progress).clamp(0.0, 1.0);
                  
                  return Positioned(
                    left: 20 + (distance * cos(angle)),
                    top: 20 + (distance * sin(angle)),
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              
              // Main icon
              Transform.scale(
                scale: _scaleAnimation.value,
                child: widget.child,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Виджет анимации добавления в маршрут
class _AddToRouteAnimationWidget extends StatefulWidget {
  final bool isAdded;
  final Widget child;
  final VoidCallback? onTap;

  const _AddToRouteAnimationWidget({
    required this.isAdded,
    required this.child,
    this.onTap,
  });

  @override
  State<_AddToRouteAnimationWidget> createState() => _AddToRouteAnimationWidgetState();
}

class _AddToRouteAnimationWidgetState extends State<_AddToRouteAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkmarkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: TravelKZDesign.easeOut,
    ));

    _checkmarkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: TravelKZDesign.elasticOut,
    ));

    if (widget.isAdded) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_AddToRouteAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAdded != oldWidget.isAdded) {
      if (widget.isAdded) {
        _controller.forward();
        HapticFeedback.lightImpact();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: _scaleAnimation.value,
                child: widget.child,
              ),
              
              // Checkmark overlay
              if (widget.isAdded)
                Opacity(
                  opacity: _checkmarkAnimation.value,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: TravelKZDesign.success,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Виджет анимации табов
class _TabAnimationWidget extends StatefulWidget {
  final bool isSelected;
  final Widget child;
  final VoidCallback? onTap;

  const _TabAnimationWidget({
    required this.isSelected,
    required this.child,
    this.onTap,
  });

  @override
  State<_TabAnimationWidget> createState() => _TabAnimationWidgetState();
}

class _TabAnimationWidgetState extends State<_TabAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bubbleAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );

    _bubbleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: TravelKZDesign.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: TravelKZDesign.easeOut,
    ));

    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_TabAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Bubble background
              if (widget.isSelected)
                Transform.scale(
                  scale: _bubbleAnimation.value,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: TravelKZDesign.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: TravelKZDesign.primaryGradient.colors.first.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Tab content
              Transform.scale(
                scale: _scaleAnimation.value,
                child: widget.child,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Виджет анимации поиска
class _SearchAnimationWidget extends StatefulWidget {
  final bool isExpanded;
  final Widget child;

  const _SearchAnimationWidget({
    required this.isExpanded,
    required this.child,
  });

  @override
  State<_SearchAnimationWidget> createState() => _SearchAnimationWidgetState();
}

class _SearchAnimationWidgetState extends State<_SearchAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );

    _widthAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: TravelKZDesign.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: TravelKZDesign.easeOut,
    ));

    if (widget.isExpanded) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(_SearchAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scaleX: _widthAnimation.value,
            scaleY: 1.0,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Виджет анимации нажатия карточки
class _CardTapAnimationWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _CardTapAnimationWidget({
    required this.child,
    this.onTap,
  });

  @override
  State<_CardTapAnimationWidget> createState() => _CardTapAnimationWidgetState();
}

class _CardTapAnimationWidgetState extends State<_CardTapAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TravelKZDesign.animationFast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: TravelKZDesign.easeOut,
    ));

    _shadowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Виджет анимации свайпа для удаления
class _SwipeToDeleteAnimationWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;
  final String? deleteText;

  const _SwipeToDeleteAnimationWidget({
    required this.child,
    required this.onDelete,
    this.deleteText,
  });

  @override
  State<_SwipeToDeleteAnimationWidget> createState() => _SwipeToDeleteAnimationWidgetState();
}

class _SwipeToDeleteAnimationWidgetState extends State<_SwipeToDeleteAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: TravelKZDesign.easeOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: TravelKZDesign.error,
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
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx < -10) {
          _controller.forward();
        } else if (details.delta.dx > 10) {
          _controller.reverse();
        }
      },
      onPanEnd: (details) {
        if (_controller.value > 0.5) {
          widget.onDelete();
        } else {
          _controller.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Background
              Container(
                color: _colorAnimation.value,
                child: Center(
                  child: Text(
                    widget.deleteText ?? 'Удалить',
                    style: TravelKZDesign.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              // Sliding content
              Transform.translate(
                offset: Offset(-100 * _slideAnimation.value, 0),
                child: widget.child,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Виджет FAB при скролле
class _ScrollToTopFABWidget extends StatefulWidget {
  final ScrollController scrollController;
  final Widget child;

  const _ScrollToTopFABWidget({
    required this.scrollController,
    required this.child,
  });

  @override
  State<_ScrollToTopFABWidget> createState() => _ScrollToTopFABWidgetState();
}

class _ScrollToTopFABWidgetState extends State<_ScrollToTopFABWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: TravelKZDesign.easeOut,
    ));

    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final offset = widget.scrollController.offset;
    final shouldShow = offset > 200;
    
    if (shouldShow != _isVisible) {
      setState(() {
        _isVisible = shouldShow;
      });
      
      if (_isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Виджет shimmer загрузки
class _ShimmerLoadingWidget extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const _ShimmerLoadingWidget({
    required this.child,
    required this.isLoading,
  });

  @override
  State<_ShimmerLoadingWidget> createState() => _ShimmerLoadingWidgetState();
}

class _ShimmerLoadingWidgetState extends State<_ShimmerLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(_ShimmerLoadingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Виджет анимации списка с задержкой
class _StaggeredListAnimationWidget extends StatefulWidget {
  final List<Widget> children;
  final Duration delay;

  const _StaggeredListAnimationWidget({
    required this.children,
    required this.delay,
  });

  @override
  State<_StaggeredListAnimationWidget> createState() => _StaggeredListAnimationWidgetState();
}

class _StaggeredListAnimationWidgetState extends State<_StaggeredListAnimationWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = widget.children.map((child) {
      return AnimationController(
        duration: TravelKZDesign.animationMedium,
        vsync: this,
      );
    }).toList();

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: TravelKZDesign.easeOut,
      ));
    }).toList();

    // Start animations with delay
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(widget.delay * i, () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, _) {
            return Opacity(
              opacity: _animations[index].value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - _animations[index].value)),
                child: child,
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

/// Класс частицы для анимации лайка
class Particle {
  final double angle;
  final double distance;
  final double speed;

  Particle({
    double? angle,
    double? distance,
    double? speed,
  }) : angle = angle ?? (Random().nextDouble() * 2 * 3.14159),
       distance = distance ?? (Random().nextDouble() * 50 + 20),
       speed = speed ?? (Random().nextDouble() * 0.5 + 0.5);
}

/// Утилиты для математических операций
import 'dart:math' as math;

double cos(double radians) => math.cos(radians);
double sin(double radians) => math.sin(radians);
Random() => math.Random();
