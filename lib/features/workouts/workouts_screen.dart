import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../wearables/wearables_stub_card.dart';

/// Workouts Screen - Shows 4 workout split cards with wearables integration
class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.orange.shade600,
                      Colors.deepOrange.shade700,
                    ],
                  ),
                ),
              ),
              titlePadding: EdgeInsets.zero,
            ),
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('💪', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text('Workouts'),
              ],
            ),
            centerTitle: true,
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Workout Splits Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Workout Splits',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Coming Soon',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Choose a workout split to get started',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4 Workout Split Cards
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: WorkoutSplitCard(
                          title: 'Push',
                          emoji: '🏋️',
                          description: 'Chest, Shoulders, Triceps',
                          color: Colors.red,
                          exercises: ['Bench Press', 'Shoulder Press', 'Tricep Dips'],
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: WorkoutSplitCard(
                          title: 'Pull',
                          emoji: '💪',
                          description: 'Back, Biceps, Rear Delts',
                          color: Colors.blue,
                          exercises: ['Pull-ups', 'Rows', 'Bicep Curls'],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: WorkoutSplitCard(
                          title: 'Legs',
                          emoji: '🦵',
                          description: 'Quads, Hamstrings, Glutes',
                          color: Colors.green,
                          exercises: ['Squats', 'Lunges', 'Deadlifts'],
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: WorkoutSplitCard(
                          title: 'Core',
                          emoji: '🔥',
                          description: 'Abs, Obliques, Lower Back',
                          color: Colors.orange,
                          exercises: ['Planks', 'Crunches', 'Russian Twists'],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Quick Log Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Quick Log',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Activity Cards Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _QuickLogCard(
                        icon: Icons.directions_walk,
                        label: 'Walking',
                        color: Colors.teal,
                        onTap: () => _showComingSoon(context, 'Walking'),
                      ),
                      const SizedBox(width: 12),
                      _QuickLogCard(
                        icon: Icons.directions_run,
                        label: 'Running',
                        color: Colors.purple,
                        onTap: () => _showComingSoon(context, 'Running'),
                      ),
                      const SizedBox(width: 12),
                      _QuickLogCard(
                        icon: Icons.pool,
                        label: 'Swimming',
                        color: Colors.blue,
                        onTap: () => _showComingSoon(context, 'Swimming'),
                      ),
                      const SizedBox(width: 12),
                      _QuickLogCard(
                        icon: Icons.pedal_bike,
                        label: 'Cycling',
                        color: Colors.green,
                        onTap: () => _showComingSoon(context, 'Cycling'),
                      ),
                      const SizedBox(width: 12),
                      _QuickLogCard(
                        icon: Icons.self_improvement,
                        label: 'Yoga',
                        color: Colors.pink,
                        onTap: () => _showComingSoon(context, 'Yoga'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Wearables Section
                const WearablesStubCard(),

                const SizedBox(height: 32),

                // Motivational Quote
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.purple.shade100,
                        Colors.indigo.shade100,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '"The only bad workout is the one that didn\'t happen"',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '— Keep Moving! 💪',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String activity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$activity tracking coming soon! 🏃'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.orange.shade700,
      ),
    );
  }
}

/// Workout Split Card - Shows a workout category
class WorkoutSplitCard extends StatelessWidget {
  final String title;
  final String emoji;
  final String description;
  final Color color;
  final List<String> exercises;

  const WorkoutSplitCard({
    super.key,
    required this.title,
    required this.emoji,
    required this.description,
    required this.color,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showWorkoutDetails(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkoutDetails(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title workout coming soon! $emoji'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: color,
      ),
    );
  }
}

class _QuickLogCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickLogCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
