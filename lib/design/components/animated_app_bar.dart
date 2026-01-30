import 'package:flutter/material.dart';
import '../design_system.dart';

/// Анимированный AppBar с Glassmorphism эффектом
class AnimatedAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final double? toolbarHeight;
  final double? leadingWidth;

  const AnimatedAppBar({
    Key? key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation,
    this.backgroundColor,
    this.showBackButton = false,
    this.onBackPressed,
    this.flexibleSpace,
    this.bottom,
    this.toolbarHeight,
    this.leadingWidth,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(
    (toolbarHeight ?? kToolbarHeight) + 
    (bottom?.preferredSize.height ?? 0),
  );

  @override
  State<AnimatedAppBar> createState() => _AnimatedAppBarState();
}

class _AnimatedAppBarState extends State<AnimatedAppBar>
    with TickerProviderStateMixin {
  late AnimationController _scrollController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;
  late ScrollController _scrollControllerListener;

  @override
  void initState() {
    super.initState();
    _scrollController = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scrollController,
      curve: TravelKZDesign.easeOut,
    ));

    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _scrollController,
      curve: TravelKZDesign.easeOut,
    ));

    _scrollControllerListener = ScrollController();
    _scrollControllerListener.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollControllerListener.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollControllerListener.offset;
    if (offset > 50) {
      _scrollController.forward();
    } else {
      _scrollController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DesignUtils.isDarkMode(context);
    
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        return AppBar(
          title: widget.title != null
              ? Text(
                  widget.title!,
                  style: TravelKZDesign.h3.copyWith(
                    color: DesignUtils.getTextColor(context),
                  ),
                )
              : null,
          actions: widget.actions,
          leading: widget.leading ?? 
              (widget.showBackButton
                  ? IconButton(
                      onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: DesignUtils.getTextColor(context),
                      ),
                    )
                  : null),
          centerTitle: widget.centerTitle,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: widget.flexibleSpace ?? 
              _buildGlassmorphicSpace(isDark),
          bottom: widget.bottom,
          toolbarHeight: widget.toolbarHeight,
          leadingWidth: widget.leadingWidth,
        );
      },
    );
  }

  Widget _buildGlassmorphicSpace(bool isDark) {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: (isDark 
                ? TravelKZDesign.darkSurface
                : TravelKZDesign.lightSurface).withOpacity(
              _opacityAnimation.value * 0.9,
            ),
            boxShadow: _opacityAnimation.value > 0.5
                ? TravelKZDesign.shadowMedium
                : null,
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _blurAnimation.value,
                sigmaY: _blurAnimation.value,
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
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

/// Плавающий AppBar с градиентным фоном
class FloatingAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Gradient? gradient;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final bool showShadow;

  const FloatingAppBar({
    Key? key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.gradient,
    this.margin,
    this.borderRadius,
    this.showShadow = true,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<FloatingAppBar> createState() => _FloatingAppBarState();
}

class _FloatingAppBarState extends State<FloatingAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: TravelKZDesign.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DesignUtils.isDarkMode(context);
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: widget.margin ?? const EdgeInsets.all(TravelKZDesign.spacing16),
            decoration: BoxDecoration(
              gradient: widget.gradient ?? TravelKZDesign.primaryGradient,
              borderRadius: BorderRadius.circular(
                widget.borderRadius ?? TravelKZDesign.radiusLarge,
              ),
              boxShadow: widget.showShadow
                  ? TravelKZDesign.shadowLarge
                  : null,
            ),
            child: AppBar(
              title: widget.title != null
                  ? Text(
                      widget.title!,
                      style: TravelKZDesign.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
              actions: widget.actions,
              leading: widget.leading,
              centerTitle: widget.centerTitle,
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
            ),
          ),
        );
      },
    );
  }
}

/// AppBar с анимированным поиском
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? hintText;
  final void Function(String)? onSearchChanged;
  final VoidCallback? onSearchTap;
  final List<Widget>? actions;
  final Widget? leading;
  final bool isSearchActive;
  final VoidCallback? onSearchToggle;

  const SearchAppBar({
    Key? key,
    this.hintText,
    this.onSearchChanged,
    this.onSearchTap,
    this.actions,
    this.leading,
    this.isSearchActive = false,
    this.onSearchToggle,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar>
    with TickerProviderStateMixin {
  late AnimationController _searchController;
  late Animation<double> _searchAnimation;
  late Animation<double> _titleAnimation;
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _searchController = AnimationController(
      duration: TravelKZDesign.animationMedium,
      vsync: this,
    );
    
    _searchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: TravelKZDesign.easeOut,
    ));

    _titleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: TravelKZDesign.easeOut,
    ));

    _textController = TextEditingController();
    _focusNode = FocusNode();

    if (widget.isSearchActive) {
      _searchController.forward();
    }
  }

  @override
  void didUpdateWidget(SearchAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSearchActive != oldWidget.isSearchActive) {
      if (widget.isSearchActive) {
        _searchController.forward();
        _focusNode.requestFocus();
      } else {
        _searchController.reverse();
        _focusNode.unfocus();
        _textController.clear();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DesignUtils.isDarkMode(context);
    
    return AnimatedBuilder(
      animation: _searchController,
      builder: (context, child) {
        return AppBar(
          leading: widget.leading,
          actions: [
            // Search field
            Expanded(
              child: AnimatedContainer(
                duration: TravelKZDesign.animationMedium,
                curve: TravelKZDesign.easeOut,
                margin: EdgeInsets.only(
                  right: _searchAnimation.value * TravelKZDesign.spacing16,
                ),
                child: Opacity(
                  opacity: _searchAnimation.value,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark 
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(TravelKZDesign.radiusLarge),
                    ),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      onChanged: widget.onSearchChanged,
                      onTap: widget.onSearchTap,
                      style: TravelKZDesign.bodyMedium.copyWith(
                        color: DesignUtils.getTextColor(context),
                      ),
                      decoration: InputDecoration(
                        hintText: widget.hintText ?? 'Поиск...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: TravelKZDesign.spacing16,
                          vertical: TravelKZDesign.spacing8,
                        ),
                        hintStyle: TravelKZDesign.bodyMedium.copyWith(
                          color: DesignUtils.getSecondaryTextColor(context),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: DesignUtils.getSecondaryTextColor(context),
                          size: 20,
                        ),
                        suffixIcon: _textController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _textController.clear();
                                  widget.onSearchChanged?.call('');
                                },
                                icon: Icon(
                                  Icons.clear,
                                  color: DesignUtils.getSecondaryTextColor(context),
                                  size: 20,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Search toggle button
            IconButton(
              onPressed: widget.onSearchToggle,
              icon: AnimatedRotation(
                turns: _searchAnimation.value * 0.5,
                duration: TravelKZDesign.animationMedium,
                child: Icon(
                  widget.isSearchActive ? Icons.close : Icons.search,
                  color: DesignUtils.getTextColor(context),
                ),
              ),
            ),
            
            // Other actions
            ...?widget.actions,
          ],
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Opacity(
            opacity: _titleAnimation.value,
            child: Text(
              'TravelKZ',
              style: TravelKZDesign.h3.copyWith(
                color: DesignUtils.getTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
