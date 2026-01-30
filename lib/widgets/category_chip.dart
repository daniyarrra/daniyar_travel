import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';

/// Чип категории для фильтрации мест
/// Поддерживает выбранное и невыбранное состояние
class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const CategoryChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? themeProvider.getSelectedChipColor()
              : themeProvider.getChipColor(),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? themeProvider.getSelectedChipColor()
                : themeProvider.getBorderColor(),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected 
                    ? themeProvider.getSelectedChipTextColor()
                    : themeProvider.getChipTextColor(),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected 
                    ? themeProvider.getSelectedChipTextColor()
                    : themeProvider.getChipTextColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
