import 'package:flutter/material.dart';

/// Compact chip displaying a nutrient value with colored background
/// 
/// Used in:
/// - SearchScreen food cards
/// - FavoritesScreen food cards
/// - Potentially MealInfoScreen (Phase 2B)
/// 
/// Example:
/// ```dart
/// NutrientChip(value: '25g P', color: AppTheme.proteinColor)
/// ```
class NutrientChip extends StatelessWidget {
  /// The display value (e.g., "25g P", "30g C", "10g F")
  final String value;
  
  /// The color for text and background tint
  final Color color;
  
  /// Font size (default: 10)
  final double fontSize;

  const NutrientChip({
    super.key,
    required this.value,
    required this.color,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
