import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

/// Виджет звезд рейтинга
/// Отображает рейтинг в виде звезд (1-5)
class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final bool showNumber;
  final Color? color;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16.0,
    this.showNumber = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final starColor = color ?? Colors.amber;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final starRating = index + 1;
          final isFilled = starRating <= rating;
          final isHalfFilled = starRating - 0.5 <= rating && starRating > rating;
          
          return _buildStar(
            isFilled: isFilled,
            isHalfFilled: isHalfFilled,
            color: starColor,
          );
        }),
        if (showNumber) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.8,
              color: themeProvider.getSecondaryTextColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  /// Создание одной звезды
  Widget _buildStar({
    required bool isFilled,
    required bool isHalfFilled,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Icon(
        isFilled 
            ? Icons.star
            : isHalfFilled 
                ? Icons.star_half
                : Icons.star_border,
        size: size,
        color: isFilled || isHalfFilled ? color : color.withOpacity(0.3),
      ),
    );
  }
}
