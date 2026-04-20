import 'package:flutter/material.dart';

/// Stub card widget to show wearables integration placeholder
/// Used in MergedInsightsScreen and WorkoutsScreen
class WearablesStubCard extends StatelessWidget {
  const WearablesStubCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.teal.shade50,
            Colors.cyan.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.teal.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.watch,
                  color: Colors.teal.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wearables',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                    Text(
                      'Connect your fitness devices',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.teal.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Coming Soon badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Wearable device icons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _WearableIcon(
                icon: Icons.watch,
                label: 'Apple Watch',
                color: Colors.grey.shade700,
              ),
              _WearableIcon(
                icon: Icons.fitness_center,
                label: 'Fitbit',
                color: Colors.teal.shade600,
              ),
              _WearableIcon(
                icon: Icons.watch_outlined,
                label: 'Garmin',
                color: Colors.blue.shade600,
              ),
              _WearableIcon(
                icon: Icons.health_and_safety,
                label: 'Health',
                color: Colors.red.shade400,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Description
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Colors.teal.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sync your steps, calories burned, and workouts automatically',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual wearable device icon widget
class _WearableIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _WearableIcon({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
