import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_system.dart';

/// Поле ввода с градиентной границей и анимациями
class GradientInputField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool enabled;
  final String? initialValue;

  const GradientInputField({
    Key? key,
    this.hintText,
    this.labelText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.onSubmitted,
    this.focusNode,
    this.enabled = true,
    this.initialValue,
  }) : super(key: key);

  @override
  State<GradientInputField> createState() => _GradientInputFieldState();
}

class _GradientInputFieldState extends State<GradientInputField>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<double> _borderAnimation;
  late Animation<double> _scaleAnimation;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );
    
    _borderAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: TravelKZDesign.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: TravelKZDesign.easeOut,
    ));

    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _focusController.forward();
    } else {
      _focusController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DesignUtils.isDarkMode(context);
    
    return AnimatedBuilder(
      animation: _focusController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: widget.maxLines == 1 ? TravelKZDesign.inputHeight : null,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TravelKZDesign.radiusLarge),
              gradient: _isFocused
                  ? TravelKZDesign.primaryGradient
                  : null,
              color: _isFocused
                  ? null
                  : (isDark 
                      ? TravelKZDesign.darkSurface
                      : TravelKZDesign.lightSurface),
              boxShadow: _isFocused
                  ? TravelKZDesign.shadowMedium
                  : TravelKZDesign.shadowSmall,
            ),
            child: Container(
              margin: EdgeInsets.all(_isFocused ? 2 : 0),
              decoration: BoxDecoration(
                color: isDark 
                    ? TravelKZDesign.darkSurface
                    : TravelKZDesign.lightSurface,
                borderRadius: BorderRadius.circular(
                  _isFocused 
                      ? TravelKZDesign.radiusLarge - 2
                      : TravelKZDesign.radiusLarge,
                ),
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                readOnly: widget.readOnly,
                enabled: widget.enabled,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                textInputAction: widget.textInputAction,
                onChanged: widget.onChanged,
                onTap: widget.onTap,
                onFieldSubmitted: widget.onSubmitted,
                initialValue: widget.initialValue,
                style: TravelKZDesign.bodyMedium.copyWith(
                  color: DesignUtils.getTextColor(context),
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  labelText: widget.labelText,
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: TravelKZDesign.spacing16,
                    vertical: TravelKZDesign.spacing16,
                  ),
                  hintStyle: TravelKZDesign.bodyMedium.copyWith(
                    color: DesignUtils.getSecondaryTextColor(context),
                  ),
                  labelStyle: TravelKZDesign.bodyMedium.copyWith(
                    color: DesignUtils.getSecondaryTextColor(context),
                  ),
                  counterStyle: TravelKZDesign.bodySmall.copyWith(
                    color: DesignUtils.getSecondaryTextColor(context),
                  ),
                ),
                validator: widget.validator,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Поисковая строка с анимацией
class AnimatedSearchField extends StatefulWidget {
  final String? hintText;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final TextEditingController? controller;
  final bool isExpanded;
  final Widget? leading;
  final Widget? trailing;

  const AnimatedSearchField({
    Key? key,
    this.hintText,
    this.onChanged,
    this.onTap,
    this.controller,
    this.isExpanded = false,
    this.leading,
    this.trailing,
  }) : super(key: key);

  @override
  State<AnimatedSearchField> createState() => _AnimatedSearchFieldState();
}

class _AnimatedSearchFieldState extends State<AnimatedSearchField>
    with SingleTickerProviderStateMixin {
  late AnimationController _expandController;
  late Animation<double> _widthAnimation;
  late Animation<double> _opacityAnimation;
  late FocusNode _focusNode;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );
    
    _widthAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: TravelKZDesign.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _expandController,
      curve: TravelKZDesign.easeOut,
    ));

    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _expandController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isExpanded = _focusNode.hasFocus || widget.isExpanded;
    });
    
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DesignUtils.isDarkMode(context);
    
    return AnimatedBuilder(
      animation: _expandController,
      builder: (context, child) {
        return Container(
          height: TravelKZDesign.inputHeight,
          decoration: BoxDecoration(
            color: isDark 
                ? TravelKZDesign.darkSurface
                : TravelKZDesign.lightSurface,
            borderRadius: BorderRadius.circular(TravelKZDesign.radiusLarge),
            boxShadow: TravelKZDesign.shadowSmall,
          ),
          child: Row(
            children: [
              if (widget.leading != null) ...[
                Padding(
                  padding: const EdgeInsets.only(left: TravelKZDesign.spacing16),
                  child: widget.leading!,
                ),
                const SizedBox(width: TravelKZDesign.spacing8),
              ],
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
                  onTap: widget.onTap,
                  style: TravelKZDesign.bodyMedium.copyWith(
                    color: DesignUtils.getTextColor(context),
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? 'Поиск мест...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: TravelKZDesign.spacing16,
                      vertical: TravelKZDesign.spacing16,
                    ),
                    hintStyle: TravelKZDesign.bodyMedium.copyWith(
                      color: DesignUtils.getSecondaryTextColor(context),
                    ),
                  ),
                ),
              ),
              if (widget.trailing != null) ...[
                Padding(
                  padding: const EdgeInsets.only(right: TravelKZDesign.spacing16),
                  child: widget.trailing!,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Чип категории с градиентным фоном
class CategoryChip extends StatefulWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? selectedColor;
  final Color? unselectedColor;

  const CategoryChip({
    Key? key,
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
    this.selectedColor,
    this.unselectedColor,
  }) : super(key: key);

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _selectionController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _selectionController = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: TravelKZDesign.easeOut,
    ));

    _colorAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: TravelKZDesign.easeOut,
    ));

    if (widget.isSelected) {
      _selectionController.forward();
    }
  }

  @override
  void didUpdateWidget(CategoryChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectionController.forward();
      } else {
        _selectionController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _selectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DesignUtils.isDarkMode(context);
    
    return AnimatedBuilder(
      animation: _selectionController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: TravelKZDesign.spacing16,
                vertical: TravelKZDesign.spacing8,
              ),
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? TravelKZDesign.primaryGradient
                    : null,
                color: widget.isSelected
                    ? null
                    : (isDark 
                        ? TravelKZDesign.darkSurface
                        : TravelKZDesign.lightSurface),
                borderRadius: BorderRadius.circular(TravelKZDesign.radiusLarge),
                border: widget.isSelected
                    ? null
                    : Border.all(
                        color: DesignUtils.getSecondaryTextColor(context).withOpacity(0.3),
                        width: 1,
                      ),
                boxShadow: widget.isSelected
                    ? TravelKZDesign.shadowMedium
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 16,
                      color: widget.isSelected
                          ? Colors.white
                          : DesignUtils.getSecondaryTextColor(context),
                    ),
                    const SizedBox(width: TravelKZDesign.spacing8),
                  ],
                  Text(
                    widget.label,
                    style: TravelKZDesign.bodyMedium.copyWith(
                      color: widget.isSelected
                          ? Colors.white
                          : DesignUtils.getTextColor(context),
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
