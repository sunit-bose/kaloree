import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/camera/camera_screen.dart';
import '../features/insights/merged_insights_screen.dart';
import '../features/workouts/workouts_screen.dart';

/// 🎨 Vibrant Gen Z Main Scaffold with bottom navigation
/// V3 Layout: 3 tabs - Home, Insights, Workouts
/// Settings accessible via hamburger menu on Home screen
class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0; // Start on Home (Camera) screen

  final _screens = const [
    CameraScreen(),           // Home - Snap meals with AI
    MergedInsightsScreen(),   // Insights - Daily log + Analytics + Wearables
    WorkoutsScreen(),         // Workouts - Exercise splits + Wearables
  ];

  // 🎨 Color-coded colors for each tab
  static const _tabColors = [
    Color(0xFF7C3AED), // Purple for Home
    Color(0xFFEC4899), // Pink for Insights
    Color(0xFFFF6B35), // Orange for Workouts
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.camera_alt, 'Home', _tabColors[0]),
              _buildNavItem(1, Icons.insights, 'Insights', _tabColors[1]),
              _buildNavItem(2, Icons.fitness_center, 'Workouts', _tabColors[2]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color color) {
    final isSelected = _currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 16 : 8,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey.shade400,
                size: isSelected ? 26 : 24,
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
