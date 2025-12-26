import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../models/meal_analysis.dart';
import '../../app/theme.dart';

/// Analytics Screen - visualizes nutrition data over time
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  TimeRange _selectedRange = TimeRange.week;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final database = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: Column(
        children: [
          // Time range selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: TimeRange.values.map((range) {
                final isSelected = _selectedRange == range;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRange = range),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

          // Charts
          Expanded(
            child: FutureBuilder<List<DailySummary>>(
              future: _getDataForRange(database),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final summaries = snapshot.data!;
                if (summaries.every((s) => s.totalCalories == 0)) {
                  return _EmptyAnalytics();
                }

                return FutureBuilder<DailyGoals>(
                  future: database.getGoals(),
                  builder: (context, goalsSnapshot) {
                    final goals = goalsSnapshot.data ?? DailyGoals.defaultGoals();

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _GoalAchievementCard(summaries: summaries, goal: goals.calorieGoal),
                        const SizedBox(height: 24),
                        _CalorieChart(summaries: summaries, goal: goals.calorieGoal, range: _selectedRange),
                        const SizedBox(height: 24),
                        _MacroBreakdownCard(summaries: summaries),
                        const SizedBox(height: 24),
                        _StatsCard(summaries: summaries, goals: goals),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<DailySummary>> _getDataForRange(AppDatabase database) async {
    switch (_selectedRange) {
      case TimeRange.day:
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        return [await database.getDailySummary(today)];
      case TimeRange.week:
        return database.getWeeklySummary();
      case TimeRange.month:
        return database.getMonthlySummary();
      case TimeRange.year:
        // For year, get monthly aggregates (simplified)
        return database.getMonthlySummary();
    }
  }
}

class _GoalAchievementCard extends StatelessWidget {
  final List<DailySummary> summaries;
  final int goal;

  const _GoalAchievementCard({
    required this.summaries,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final trackedDays = summaries.where((s) => s.totalCalories > 0).toList();
    if (trackedDays.isEmpty) return const SizedBox.shrink();

    final achieved = trackedDays.where((s) =>
      GoalStatus.fromCalories(s.totalCalories, goal) == GoalStatus.achieved
    ).length;
    final exceeded = trackedDays.where((s) =>
      GoalStatus.fromCalories(s.totalCalories, goal) == GoalStatus.exceeded
    ).length;
    final under = trackedDays.where((s) =>
      GoalStatus.fromCalories(s.totalCalories, goal) == GoalStatus.under
    ).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎯 Goal Achievement', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _AchievementItem(
                    status: GoalStatus.achieved,
                    count: achieved,
                    total: trackedDays.length,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AchievementItem(
                    status: GoalStatus.exceeded,
                    count: exceeded,
                    total: trackedDays.length,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AchievementItem(
                    status: GoalStatus.under,
                    count: under,
                    total: trackedDays.length,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Daily status indicators
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: summaries.map((summary) {
                if (summary.totalCalories == 0) {
                  return Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        DateFormat('d').format(summary.date),
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                      ),
                    ),
                  );
                }
                final status = GoalStatus.fromCalories(summary.totalCalories, goal);
                final color = status == GoalStatus.achieved ? Colors.green :
                             status == GoalStatus.exceeded ? Colors.red : Colors.orange;
                return Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    border: Border.all(color: color, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      status.emoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementItem extends StatelessWidget {
  final GoalStatus status;
  final int count;
  final int total;
  final Color color;

  const _AchievementItem({
    required this.status,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            status.emoji,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            status.displayName,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CalorieChart extends StatelessWidget {
  final List<DailySummary> summaries;
  final int goal;
  final TimeRange range;

  const _CalorieChart({
    required this.summaries,
    required this.goal,
    required this.range,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calorie Intake', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Goal: $goal kcal/day', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (goal * 1.5).toDouble(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()} kcal',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
                              child: Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value == goal.toDouble()) {
                            return Text(
                              value.toInt().toString(),
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
                      color: value == goal.toDouble() ? theme.primaryColor.withOpacity(0.5) : Colors.grey.shade200,
                      strokeWidth: value == goal.toDouble() ? 2 : 1,
                      dashArray: value == goal.toDouble() ? [5, 5] : null,
                    ),
                    drawVerticalLine: false,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: summaries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final summary = entry.value;
                    final status = GoalStatus.fromCalories(summary.totalCalories, goal);
                    final color = status == GoalStatus.achieved ? Colors.green :
                                 status == GoalStatus.exceeded ? Colors.red : Colors.orange;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: summary.totalCalories.toDouble(),
                          color: summary.totalCalories == 0 ? Colors.grey.shade300 : color,
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
    );
  }
}

class _MacroBreakdownCard extends StatelessWidget {
  final List<DailySummary> summaries;

  const _MacroBreakdownCard({required this.summaries});

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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Macro Breakdown', style: theme.textTheme.titleLarge),
            const SizedBox(height: 24),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: [
                        PieChartSectionData(
                          value: totalProtein,
                          color: AppTheme.proteinColor,
                          title: '',
                          radius: 25,
                        ),
                        PieChartSectionData(
                          value: totalCarbs,
                          color: AppTheme.carbsColor,
                          title: '',
                          radius: 25,
                        ),
                        PieChartSectionData(
                          value: totalFat,
                          color: AppTheme.fatColor,
                          title: '',
                          radius: 25,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      _MacroLegendItem(
                        label: 'Protein',
                        value: '${totalProtein.toStringAsFixed(0)}g',
                        percent: '${proteinPercent.toStringAsFixed(0)}%',
                        color: AppTheme.proteinColor,
                      ),
                      const SizedBox(height: 12),
                      _MacroLegendItem(
                        label: 'Carbs',
                        value: '${totalCarbs.toStringAsFixed(0)}g',
                        percent: '${carbsPercent.toStringAsFixed(0)}%',
                        color: AppTheme.carbsColor,
                      ),
                      const SizedBox(height: 12),
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Text(percent, style: TextStyle(color: Colors.grey.shade500)),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final List<DailySummary> summaries;
  final DailyGoals goals;

  const _StatsCard({required this.summaries, required this.goals});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalCalories = summaries.fold(0, (sum, s) => sum + s.totalCalories);
    final avgCalories = summaries.isEmpty ? 0 : totalCalories ~/ summaries.length;
    final daysOnGoal = summaries.where((s) => s.totalCalories <= goals.calorieGoal && s.totalCalories > 0).length;
    final daysTracked = summaries.where((s) => s.totalCalories > 0).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistics', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: 'Avg Daily',
                    value: '$avgCalories',
                    unit: 'kcal',
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'Days Tracked',
                    value: '$daysTracked',
                    unit: 'days',
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    label: 'On Goal',
                    value: '$daysOnGoal',
                    unit: 'days',
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const _StatItem({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, color: theme.primaryColor)),
        Text(unit, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _EmptyAnalytics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No data yet', style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          Text('Start logging meals to see analytics', style: TextStyle(color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}
