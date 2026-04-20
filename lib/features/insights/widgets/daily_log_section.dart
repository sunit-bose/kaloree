import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../services/database_service.dart';
import '../../../models/meal_analysis.dart';
import '../../../app/theme.dart';

/// Daily Log Section - Shows goal progress and meals for the day
/// Extracted from DailyLogScreen for use in MergedInsightsScreen
class DailyLogSection extends ConsumerWidget {
  final DailySummary summary;
  final List<Meal> meals;
  final DailyGoals goals;
  final String dateString;
  final VoidCallback onMealUpdated;

  const DailyLogSection({
    super.key,
    required this.summary,
    required this.meals,
    required this.goals,
    required this.dateString,
    required this.onMealUpdated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Daily Progress',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Goal Progress Card
        GoalProgressCard(summary: summary, goals: goals),
        const SizedBox(height: 20),

        // Meals Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🍽️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    'Meals',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                '${meals.length} logged',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Meals List or Empty State
        if (meals.isEmpty)
          _EmptyMealsState()
        else
          ...meals.map((meal) => MealCard(
                meal: meal,
                onTypeChanged: (type) async {
                  final database = ref.read(databaseProvider);
                  await database.updateMealType(meal.id, type);
                  onMealUpdated();
                },
                onDelete: () async {
                  final database = ref.read(databaseProvider);
                  await database.deleteMeal(meal.id);
                  onMealUpdated();
                },
              )),
      ],
    );
  }
}

/// Goal Progress Card - Shows calorie and macro progress
class GoalProgressCard extends StatelessWidget {
  final DailySummary summary;
  final DailyGoals goals;

  const GoalProgressCard({
    super.key,
    required this.summary,
    required this.goals,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caloriePercent = (summary.totalCalories / goals.calorieGoal).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${summary.totalCalories}',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryGradient.colors[0],
                          height: 1,
                        ),
                      ),
                      const Text(' 🔥', style: TextStyle(fontSize: 32)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'of ${goals.calorieGoal} kcal goal',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: caloriePercent,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation(AppTheme.primaryGradient.colors[0]),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(caloriePercent * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      Text(
                        'complete',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          MacroProgressBar(
            label: 'Protein 💪',
            current: summary.totalProtein,
            goal: goals.proteinGoal,
            color: AppTheme.proteinColor,
          ),
          const SizedBox(height: 16),
          MacroProgressBar(
            label: 'Carbs ⚡',
            current: summary.totalCarbs,
            goal: goals.carbsGoal,
            color: AppTheme.carbsColor,
          ),
          const SizedBox(height: 16),
          MacroProgressBar(
            label: 'Fat 🥑',
            current: summary.totalFat,
            goal: goals.fatGoal,
            color: AppTheme.fatColor,
          ),
        ],
      ),
    );
  }
}

/// Macro Progress Bar - Shows progress for a single macro
class MacroProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final Color color;

  const MacroProgressBar({
    super.key,
    required this.label,
    required this.current,
    required this.goal,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (current / goal).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            Text(
              '${current.toStringAsFixed(1)}g / ${goal.toStringAsFixed(0)}g',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 10,
          ),
        ),
      ],
    );
  }
}

/// Meal Card - Shows a single meal with actions
class MealCard extends ConsumerWidget {
  final Meal meal;
  final Function(MealType) onTypeChanged;
  final VoidCallback onDelete;

  const MealCard({
    super.key,
    required this.meal,
    required this.onTypeChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final database = ref.watch(databaseProvider);
    final time = DateTime.fromMillisecondsSinceEpoch(meal.timestamp);
    final timeStr = DateFormat('h:mm a').format(time);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Meal ${meal.mealNumber}',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(timeStr, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      } else {
                        final type = MealType.values.firstWhere((t) => t.name == value);
                        onTypeChanged(type);
                      }
                    },
                    itemBuilder: (context) => [
                      ...MealType.values.map((type) => PopupMenuItem(
                            value: type.name,
                            child: Row(
                              children: [
                                if (meal.mealType == type.name)
                                  Icon(Icons.check, size: 18, color: theme.primaryColor),
                                if (meal.mealType != type.name) const SizedBox(width: 18),
                                const SizedBox(width: 8),
                                Text(type.displayName),
                              ],
                            ),
                          )),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (meal.mealType != null) ...[
                const SizedBox(height: 4),
                Text(
                  MealType.values.firstWhere((t) => t.name == meal.mealType).displayName,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
              // Show individual food items
              FutureBuilder<List<MealItem>>(
                future: database.getMealItems(meal.id),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final items = snapshot.data!;
                    final consolidatedNames = _consolidateItemNames(items);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        consolidatedNames,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _SmallMacro(value: '${meal.totalProtein.toStringAsFixed(0)}g', label: 'P', color: AppTheme.proteinColor),
                      const SizedBox(width: 8),
                      _SmallMacro(value: '${meal.totalCarbs.toStringAsFixed(0)}g', label: 'C', color: AppTheme.carbsColor),
                      const SizedBox(width: 8),
                      _SmallMacro(value: '${meal.totalFat.toStringAsFixed(0)}g', label: 'F', color: AppTheme.fatColor),
                    ],
                  ),
                  Text(
                    '${meal.totalCalories} kcal',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _consolidateItemNames(List<MealItem> items) {
    final Map<String, int> nameCounts = {};

    for (final item in items) {
      final name = item.name;
      nameCounts[name] = (nameCounts[name] ?? 0) + 1;
    }

    final parts = nameCounts.entries.map((entry) {
      if (entry.value > 1) {
        return '${entry.key} (x${entry.value})';
      }
      return entry.key;
    }).toList();

    return parts.join(', ');
  }
}

class _SmallMacro extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _SmallMacro({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$value $label',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _EmptyMealsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'No meals logged yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Go to Home tab to snap your first meal 📸',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
