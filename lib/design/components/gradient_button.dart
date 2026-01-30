import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system.dart';

/// Современная градиентная кнопка с микроанимациями
class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool isLoading;
  final ButtonType type;
  final EdgeInsetsGeometry? padding;

  const GradientButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.width,
    this.height,
    this.icon,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.padding,
  }) : super(key: key);

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

enum ButtonType { primary, secondary, tertiary }

class _GradientButtonState extends State<GradientButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: TravelKZDesign.animationFast,
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: TravelKZDesign.easeOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: TravelKZDesign.easeOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _scaleController.forward();
      _rippleController.forward();
      
      // Haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DesignUtils.isDarkMode(context);
    
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _rippleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onPressed != null && !widget.isLoading
                ? () {
                    _rippleController.reset();
                    widget.onPressed!();
                  }
                : null,
            child: Container(
              width: widget.width,
              height: widget.height ?? TravelKZDesign.buttonHeight,
              decoration: _getButtonDecoration(isDark),
              child: Stack(
                children: [
                  // Ripple effect
                  if (_rippleAnimation.value > 0)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            widget.type == ButtonType.tertiary ? 0 : TravelKZDesign.radiusLarge,
                          ),
                          color: Colors.white.withOpacity(0.1 * _rippleAnimation.value),
                        ),
                      ),
                    ),
                  
                  // Button content
                  Center(
                    child: _buildButtonContent(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _getButtonDecoration(bool isDark) {
    switch (widget.type) {
      case ButtonType.primary:
        return TravelKZDesign.gradientButtonDecoration(
          gradient: widget.gradient ?? TravelKZDesign.primaryGradient,
        );
      case ButtonType.secondary:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(TravelKZDesign.radiusLarge),
          border: Border.all(
            color: (widget.gradient ?? TravelKZDesign.primaryGradient).colors.first,
            width: 2,
          ),
        );
      case ButtonType.tertiary:
        return const BoxDecoration(
          color: Colors.transparent,
        );
    }
  }

  Widget _buildButtonContent() {
    if (widget.isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.type == ButtonType.primary ? Colors.white : TravelKZDesign.primaryGradient.colors.first,
          ),
        ),
      );
    }

    final textColor = widget.type == ButtonType.primary 
        ? Colors.white 
        : (widget.gradient ?? TravelKZDesign.primaryGradient).colors.first;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(
            widget.icon,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: TravelKZDesign.spacing8),
        ],
        Text(
          widget.text,
          style: TravelKZDesign.bodyMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Кнопка с иконкой и градиентным фоном
class GradientIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final double size;
  final String? tooltip;

  const GradientIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.gradient,
    this.size = 48,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(TravelKZDesign.radiusLarge),
          child: Container(
            width: size,
            height: size,
            decoration: TravelKZDesign.gradientButtonDecoration(
              gradient: gradient ?? TravelKZDesign.primaryGradient,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// Плавающая кнопка действия с градиентом
class GradientFAB extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final String? tooltip;

  const GradientFAB({
    Key? key,
    required this.icon,
    this.onPressed,
    this.gradient,
    this.tooltip,
  }) : super(key: key);

  @override
  State<GradientFAB> createState() => _GradientFABState();
}

class _GradientFABState extends State<GradientFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: 56,
                height: 56,
                decoration: TravelKZDesign.gradientButtonDecoration(
                  gradient: widget.gradient ?? TravelKZDesign.accentGradient,
                ),
                child: Icon(
                  widget.icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
