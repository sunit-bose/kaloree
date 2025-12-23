import 'package:flutter/material.dart';
import '../features/meal_info/meal_info_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/settings_screen.dart';
import '../models/meal_analysis.dart';

// Simple navigation helper - no complex router needed for this app
class AppNavigator {
  static void toMealInfo(BuildContext context, MealAnalysis analysis) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MealInfoScreen(analysis: analysis),
      ),
    );
  }

  static void toSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SearchScreen(),
      ),
    );
  }

  static void toSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }
}
