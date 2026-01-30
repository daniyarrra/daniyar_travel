import 'package:flutter/material.dart';
import '../design_system.dart';

/// Компонент пустого состояния с анимациями
class EmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Widget? customIcon;
  final double? iconSize;
  final Gradient? iconGradient;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionText,
    this.onActionPressed,
    this.customIcon,
    this.iconSize,
    this.iconGradient,
  }) : super(key: key);

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState>
    with TickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _contentController;
  late Animation<double> _iconAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _iconController = AnimationController(
      duration: TravelKZDesign.animationSlow,
      vsync: this,
    );
    
    _contentController = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );

    _iconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: TravelKZDesign.easeOut,
    ));

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: TravelKZDesign.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: TravelKZDesign.elasticOut,
    ));

    // Start animations with delay
    _iconController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _contentController.forward();
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TravelKZDesign.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon
            AnimatedBuilder(
              animation: _iconController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _iconAnimation.value,
                    child: _buildIcon(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: TravelKZDesign.spacing32),
            
            // Content
            AnimatedBuilder(
              animation: _contentController,
              builder: (context, child) {
                return Opacity(
                  opacity: _contentAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _contentAnimation.value)),
                    child: Column(
                      children: [
                        Text(
                          widget.title,
                          style: TravelKZDesign.h2.copyWith(
                            color: DesignUtils.getTextColor(context),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: TravelKZDesign.spacing16),
                        
                        Text(
                          widget.description,
                          style: TravelKZDesign.bodyLarge.copyWith(
                            color: DesignUtils.getSecondaryTextColor(context),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        if (widget.actionText != null) ...[
                          const SizedBox(height: TravelKZDesign.spacing32),
                          
                          GradientButton(
                            text: widget.actionText!,
                            onPressed: widget.onActionPressed,
                            gradient: TravelKZDesign.primaryGradient,
                            icon: Icons.explore,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (widget.customIcon != null) {
      return widget.customIcon!;
    }

    final iconSize = widget.iconSize ?? 80.0;
    final gradient = widget.iconGradient ?? TravelKZDesign.primaryGradient;

    return Container(
      width: iconSize + 40,
      height: iconSize + 40,
      decoration: BoxDecoration(
        gradient: gradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        widget.icon,
        color: Colors.white,
        size: iconSize,
      ),
    );
  }
}

/// Специализированные пустые состояния для разных экранов
class SearchEmptyState extends StatelessWidget {
  final String query;
  final VoidCallback? onClearSearch;

  const SearchEmptyState({
    Key? key,
    required this.query,
    this.onClearSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.search_off,
      title: 'Ничего не найдено',
      description: 'По запросу "$query" ничего не найдено. Попробуйте изменить поисковый запрос.',
      actionText: 'Очистить поиск',
      onActionPressed: onClearSearch,
      iconGradient: TravelKZDesign.secondaryGradient,
    );
  }
}

class RoutesEmptyState extends StatelessWidget {
  final VoidCallback? onCreateRoute;

  const RoutesEmptyState({
    Key? key,
    this.onCreateRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.route,
      title: 'Нет маршрутов',
      description: 'Создайте свой первый маршрут путешествия по Казахстану',
      actionText: 'Создать маршрут',
      onActionPressed: onCreateRoute,
      iconGradient: TravelKZDesign.accentGradient,
    );
  }
}

class NetworkErrorState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorState({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.wifi_off,
      title: 'Нет подключения',
      description: 'Проверьте подключение к интернету и попробуйте снова',
      actionText: 'Повторить',
      onActionPressed: onRetry,
      iconGradient: TravelKZDesign.accentGradient,
    );
  }
}

class LoadingState extends StatelessWidget {
  final String message;

  const LoadingState({
    Key? key,
    this.message = 'Загрузка...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                TravelKZDesign.primaryGradient.colors.first,
              ),
            ),
          ),
          const SizedBox(height: TravelKZDesign.spacing24),
          Text(
            message,
            style: TravelKZDesign.bodyLarge.copyWith(
              color: DesignUtils.getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
