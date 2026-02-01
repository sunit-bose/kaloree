import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/camera/camera_screen.dart';
import '../features/daily_log/daily_log_screen.dart';
import '../features/analytics/analytics_screen.dart';
import '../features/settings/settings_screen.dart';
import '../app/theme.dart';

/// 🎨 Vibrant Gen Z Main Scaffold with bottom navigation
class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key});

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _currentIndex = 0;

  final _screens = const [
    CameraScreen(),
    DailyLogScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  // 🎨 Color-coded colors for each tab
  static const _tabColors = [
    Color(0xFF7C3AED), // Purple for Camera
    Color(0xFFEC4899), // Pink for Today
    Color(0xFF3B82F6), // Blue for Insights
    Color(0xFFFBBF24), // Yellow for Settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
              _buildNavItem(0, Icons.camera_alt, 'Snap', _tabColors[0]),
              _buildNavItem(1, Icons.restaurant, 'Today', _tabColors[1]),
              _buildNavItem(2, Icons.insights, 'Insights', _tabColors[2]),
              _buildNavItem(3, Icons.settings, 'Settings', _tabColors[3]),
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
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey.shade400,
                size: isSelected ? 28 : 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

