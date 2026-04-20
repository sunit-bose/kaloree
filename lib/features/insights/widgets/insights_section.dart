import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../services/database_service.dart';
import '../../../models/meal_analysis.dart';
import '../../../app/theme.dart';

/// Time range options for analytics
enum TimeRange {
  day,
  week,
  month,
  year;

  String get displayName {
    switch (this) {
      case TimeRange.day:
        return 'Day';
      case TimeRange.week:
        return 'Week';
      case TimeRange.month:
        return 'Month';
      case TimeRange.year:
        return 'Year';
    }
  }
}

/// Insights Section - Shows charts and statistics
/// Extracted from AnalyticsScreen for use in MergedInsightsScreen
class InsightsSection extends ConsumerStatefulWidget {
  final DateTime selectedDate;

  const InsightsSection({
    super.key,
    required this.selectedDate,
  });

  @override
  ConsumerState<InsightsSection> createState() => _InsightsSectionState();
}

class _InsightsSectionState extends ConsumerState<InsightsSection> {
  TimeRange _selectedRange = TimeRange.week;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final database = ref.watch(databaseProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Analytics',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Time range selector
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: TimeRange.values.map((range) {
              final isSelected = _selectedRange == range;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedRange = range),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.primaryColor : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          range.displayName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Charts
        FutureBuilder<List<DailySummary>>(
          future: _getDataForRange(database),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            }

            final summaries = snapshot.data!;
            if (summaries.every((s) => s.totalCalories == 0)) {
              return _EmptyAnalytics();
            }

            return FutureBuilder<DailyGoals>(
              future: database.getGoals(),
              builder: (context, goalsSnapshot) {
                final goals = goalsSnapshot.data ?? DailyGoals.defaultGoals();

                return Column(
                  children: [
                    CalorieChart(
                      summaries: summaries,
                      goal: goals.calorieGoal,
                      range: _selectedRange,
                    ),
                    const SizedBox(height: 16),
                    MacroBreakdownCard(summaries: summaries),
                    const SizedBox(height: 16),
                    StatsCard(summaries: summaries, goals: goals),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Future<List<DailySummary>> _getDataForRange(AppDatabase database) async {
    switch (_selectedRange) {
      case TimeRange.day:
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final meals = await database.getMealsForDate(today);

        if (meals.isEmpty) {
          return [await database.getDailySummary(today)];
        }

        return meals.map((meal) {
          return DailySummary(
            date: DateTime.fromMillisecondsSinceEpoch(meal.timestamp),
            totalCalories: meal.totalCalories,
            totalProtein: meal.totalProtein,
            totalCarbs: meal.totalCarbs,
            totalFat: meal.totalFat,
            mealCount: 1,
          );
        }).toList();
      case TimeRange.week:
        return database.getWeeklySummary();
      case TimeRange.month:
        return database.getMonthlySummary();
      case TimeRange.year:
        return database.getMonthlySummary();
    }
  }
}

/// Calorie Chart - Bar chart showing calorie intake over time
class CalorieChart extends StatelessWidget {
  final List<DailySummary> summaries;
  final int goal;
  final TimeRange range;

  const CalorieChart({
    super.key,
    required this.summaries,
    required this.goal,
    required this.range,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Calorie Intake', style: theme.textTheme.titleMedium),
                  Text(
                    'Goal: $goal kcal',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (goal * 1.5).toDouble(),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.toInt()} kcal',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < summaries.length) {
                              final date = summaries[index].date;
                              String label;
                              if (range == TimeRange.week) {
                                label = DateFormat('E').format(date);
                              } else if (range == TimeRange.month) {
                                label = index % 5 == 0 ? DateFormat('d').format(date) : '';
                              } else {
                                label = DateFormat('ha').format(date);
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35,
                          getTitlesWidget: (value, meta) {
                            if (value == 0 || value == goal.toDouble()) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: goal.toDouble(),
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: value == goal.toDouble()
                            ? theme.primaryColor.withOpacity(0.5)
                            : Colors.grey.shade200,
                        strokeWidth: value == goal.toDouble() ? 2 : 1,
                        dashArray: value == goal.toDouble() ? [5, 5] : null,
                      ),
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: summaries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final summary = entry.value;
                      final isOverGoal = summary.totalCalories > goal;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: summary.totalCalories.toDouble(),
                            color: isOverGoal ? Colors.red.shade400 : theme.primaryColor,
                            width: range == TimeRange.month ? 6 : 16,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Macro Breakdown Card - Pie chart showing macro distribution
class MacroBreakdownCard extends StatelessWidget {
  final List<DailySummary> summaries;

  const MacroBreakdownCard({super.key, required this.summaries});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalProtein = summaries.fold(0.0, (sum, s) => sum + s.totalProtein);
    final totalCarbs = summaries.fold(0.0, (sum, s) => sum + s.totalCarbs);
    final totalFat = summaries.fold(0.0, (sum, s) => sum + s.totalFat);
    final total = totalProtein + totalCarbs + totalFat;

    if (total == 0) {
      return const SizedBox.shrink();
    }

    final proteinPercent = (totalProtein / total * 100);
    final carbsPercent = (totalCarbs / total * 100);
    final fatPercent = (totalFat / total * 100);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Macro Breakdown', style: theme.textTheme.titleMedium),
              const SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 25,
                        sections: [
                          PieChartSectionData(
                            value: totalProtein,
                            color: AppTheme.proteinColor,
                            title: '',
                            radius: 22,
                          ),
                          PieChartSectionData(
                            value: totalCarbs,
                            color: AppTheme.carbsColor,
                            title: '',
                            radius: 22,
                          ),
                          PieChartSectionData(
                            value: totalFat,
                            color: AppTheme.fatColor,
                            title: '',
                            radius: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        _MacroLegendItem(
                          label: 'Protein',
                          value: '${totalProtein.toStringAsFixed(0)}g',
                          percent: '${proteinPercent.toStringAsFixed(0)}%',
                          color: AppTheme.proteinColor,
                        ),
                        const SizedBox(height: 10),
                        _MacroLegendItem(
                          label: 'Carbs',
                          value: '${totalCarbs.toStringAsFixed(0)}g',
                          percent: '${carbsPercent.toStringAsFixed(0)}%',
                          color: AppTheme.carbsColor,
                        ),
                        const SizedBox(height: 10),
                        _MacroLegendItem(
                          label: 'Fat',
                          value: '${totalFat.toStringAsFixed(0)}g',
                          percent: '${fatPercent.toStringAsFixed(0)}%',
                          color: AppTheme.fatColor,
                        ),
                      ],
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
}

class _MacroLegendItem extends StatelessWidget {
  final String label;
  final String value;
  final String percent;
  final Color color;

  const _MacroLegendItem({
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(width: 6),
        Text(percent, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      ],
    );
  }
}

/// Stats Card - Shows summary statistics
class StatsCard extends StatelessWidget {
  final List<DailySummary> summaries;
  final DailyGoals goals;

  const StatsCard({super.key, required this.summaries, required this.goals});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalCalories = summaries.fold(0, (sum, s) => sum + s.totalCalories);
    final avgCalories = summaries.isEmpty ? 0 : totalCalories ~/ summaries.length;
    final daysOnGoal = summaries.where((s) => s.totalCalories <= goals.calorieGoal && s.totalCalories > 0).length;
    final daysTracked = summaries.where((s) => s.totalCalories > 0).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Statistics', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      label: 'Avg Daily',
                      value: '$avgCalories',
                      unit: 'kcal',
                      color: theme.primaryColor,
                    ),
                  ),
                  Expanded(
                    child: _StatItem(
                      label: 'Days Tracked',
                      value: '$daysTracked',
                      unit: 'days',
                      color: Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _StatItem(
                      label: 'On Goal',
                      value: '$daysOnGoal',
                      unit: 'days',
                      color: Colors.green,
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
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}

class _EmptyAnalytics extends StatelessWidget {
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
          Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No data yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start logging meals to see analytics',
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
