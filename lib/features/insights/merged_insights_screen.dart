import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../models/meal_analysis.dart';
import '../../app/theme.dart';
import '../wearables/wearables_stub_card.dart';
import '../meal_info/meal_info_screen.dart';
import 'widgets/daily_log_section.dart';
import 'widgets/insights_section.dart';

/// Merged Insights Screen - combines Daily Log, Analytics, and Wearables
/// Uses CustomScrollView for smooth scrolling experience
class MergedInsightsScreen extends ConsumerStatefulWidget {
  const MergedInsightsScreen({super.key});

  @override
  ConsumerState<MergedInsightsScreen> createState() => _MergedInsightsScreenState();
}

class _MergedInsightsScreenState extends ConsumerState<MergedInsightsScreen> {
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
    final database = ref.watch(databaseProvider);
    // Watch the refresh trigger to auto-refresh when meals are added
    ref.watch(diaryRefreshProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with date selector
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: _previousDay,
                              icon: const Icon(Icons.chevron_left, color: Colors.white),
                            ),
                            GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) setState(() => _selectedDate = picked);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('📅 ', style: TextStyle(fontSize: 18)),
                                  Text(
                                    _displayDate,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: _nextDay,
                              icon: const Icon(Icons.chevron_right, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              titlePadding: EdgeInsets.zero,
            ),
            title: const Text('Insights'),
            centerTitle: true,
          ),

          // Main Content
          SliverToBoxAdapter(
            child: FutureBuilder(
              future: Future.wait([
                database.getDailySummary(_dateString),
                database.getMealsForDate(_dateString),
                database.getGoals(),
              ]),
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

                final data = snapshot.data!;
                final summary = data[0] as DailySummary;
                final meals = data[1] as List<Meal>;
                final goals = data[2] as DailyGoals;

                return RefreshIndicator(
                  onRefresh: () async => setState(() {}),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      
                      // Daily Log Section (Goal Progress + Meals)
                      DailyLogSection(
                        summary: summary,
                        meals: meals,
                        goals: goals,
                        dateString: _dateString,
                        onMealUpdated: () => setState(() {}),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Wearables Section
                      const WearablesStubCard(),
                      
                      const SizedBox(height: 24),
                      
                      // Insights Section (Charts and Stats)
                      InsightsSection(
                        selectedDate: _selectedDate,
                      ),
                      
                      const SizedBox(height: 32),
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
