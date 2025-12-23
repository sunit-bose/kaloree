import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../models/meal_analysis.dart';
import '../../app/theme.dart';
import '../meal_info/meal_info_screen.dart';

/// Daily Log Screen - shows meals for the day with goal progress
class DailyLogScreen extends ConsumerStatefulWidget {
  const DailyLogScreen({super.key});

  @override
  ConsumerState<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends ConsumerState<DailyLogScreen> {
  DateTime _selectedDate = DateTime.now();

  String get _dateString => DateFormat('yyyy-MM-dd').format(_selectedDate);
  String get _displayDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (selected == today) return 'Today';
    if (selected == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('EEE, MMM d').format(_selectedDate);
  }

  void _previousDay() {
    setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
  }

  void _nextDay() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    if (_selectedDate.isBefore(tomorrow)) {
      setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final database = ref.watch(databaseProvider);
    // Watch the refresh trigger to auto-refresh when meals are added
    ref.watch(diaryRefreshProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Log'),
      ),
      body: Column(
        children: [
          // Date selector - Pill style
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGradient.colors[0].withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousDay,
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _selectedDate = picked);
                    },
                    child: Center(
                      child: Text(
                        '📅 $_displayDate',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _nextDay,
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: FutureBuilder(
              future: Future.wait([
                database.getDailySummary(_dateString),
                database.getMealsForDate(_dateString),
                database.getGoals(),
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final data = snapshot.data!;
                final summary = data[0] as DailySummary;
                final meals = data[1] as List<Meal>;
                final goals = data[2] as DailyGoals;

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: meals.isEmpty
                      ? _EmptyState()
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _GoalProgressCard(summary: summary, goals: goals),
                            const SizedBox(height: 24),
                            Text('Meals', style: theme.textTheme.titleLarge),
                            const SizedBox(height: 12),
                            ...meals.map((meal) => _MealCard(
                              meal: meal,
                              onTypeChanged: (type) async {
                                await database.updateMealType(meal.id, type);
                                setState(() {});
                              },
                              onDelete: () async {
                                await database.deleteMeal(meal.id);
                                setState(() {});
                              },
                            )),
                          ],
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalProgressCard extends StatelessWidget {
  final DailySummary summary;
  final DailyGoals goals;

  const _GoalProgressCard({required this.summary, required this.goals});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final caloriePercent = (summary.totalCalories / goals.calorieGoal).clamp(0.0, 1.0);
    final proteinPercent = (summary.totalProtein / goals.proteinGoal).clamp(0.0, 1.0);
    final carbsPercent = (summary.totalCarbs / goals.carbsGoal).clamp(0.0, 1.0);
    final fatPercent = (summary.totalFat / goals.fatGoal).clamp(0.0, 1.0);

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
          _MacroProgressBar(label: 'Protein 💪', current: summary.totalProtein, goal: goals.proteinGoal, color: AppTheme.proteinColor),
          const SizedBox(height: 16),
          _MacroProgressBar(label: 'Carbs ⚡', current: summary.totalCarbs, goal: goals.carbsGoal, color: AppTheme.carbsColor),
          const SizedBox(height: 16),
          _MacroProgressBar(label: 'Fat 🥑', current: summary.totalFat, goal: goals.fatGoal, color: AppTheme.fatColor),
        ],
      ),
    );
  }
}

class _MacroProgressBar extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final Color color;

  const _MacroProgressBar({
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

class _MealCard extends StatelessWidget {
  final Meal meal;
  final Function(MealType) onTypeChanged;
  final VoidCallback onDelete;

  const _MealCard({
    required this.meal,
    required this.onTypeChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = DateTime.fromMillisecondsSinceEpoch(meal.timestamp);
    final timeStr = DateFormat('h:mm a').format(time);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
    );
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

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          Text(
            'No meals logged yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the camera icon to log your first meal 📸',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
