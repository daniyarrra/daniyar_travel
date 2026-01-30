import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

/// Кастомная кнопка с поддержкой различных стилей
/// Поддерживает обычный и outlined стили, а также состояние загрузки
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double? fontSize;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isOutlined = false,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return SizedBox(
      width: width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined 
              ? Colors.transparent
              : backgroundColor ?? themeProvider.getButtonColor(),
          foregroundColor: isOutlined 
              ? (textColor ?? themeProvider.getButtonColor())
              : (textColor ?? themeProvider.getButtonTextColor()),
          elevation: isOutlined ? 0 : 2,
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.borderRadius),
            side: isOutlined 
                ? BorderSide(
                    color: backgroundColor ?? themeProvider.getButtonColor(),
                    width: 2,
                  )
                : BorderSide.none,
          ),
          disabledBackgroundColor: themeProvider.getInactiveButtonColor(),
          disabledForegroundColor: themeProvider.getInactiveButtonTextColor(),
        ),
        child: isLoading 
            ? _buildLoadingIndicator(themeProvider)
            : _buildButtonContent(themeProvider),
      ),
    );
  }

  /// Содержимое кнопки
  Widget _buildButtonContent(ThemeProvider themeProvider) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: (fontSize ?? 16) + 4,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
    
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Индикатор загрузки
  Widget _buildLoadingIndicator(ThemeProvider themeProvider) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          isOutlined 
              ? (textColor ?? themeProvider.getButtonColor())
              : (textColor ?? themeProvider.getButtonTextColor()),
        ),
      ),
    );
  }
}
