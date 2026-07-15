import 'health_alert.dart';

// Meal Analysis - Response from LLM
class MealAnalysis {
  final List<FoodItem> items;
  final String confidence;
  final String source; // 'ai', 'search', 'manual'

  MealAnalysis({
    required this.items,
    required this.confidence,
    required this.source,
  });

  int get totalCalories => items.fold(0, (sum, item) => sum + item.calories);
  double get totalProtein => items.fold(0.0, (sum, item) => sum + item.protein);
  double get totalCarbs => items.fold(0.0, (sum, item) => sum + item.carbs);
  double get totalFat => items.fold(0.0, (sum, item) => sum + item.fat);
  double get totalFiber => items.fold(0.0, (sum, item) => sum + item.fiber);

  /// Get all health alerts across all food items
  List<HealthAlert> get allHealthAlerts =>
      items.expand((item) => item.healthAlerts).toList();

  /// Get all active (non-dismissed) alerts across all items
  List<HealthAlert> get activeHealthAlerts =>
      items.expand((item) => item.activeAlerts).toList();

  /// Check if any item has active health alerts
  bool get hasActiveAlerts => items.any((item) => item.hasActiveAlerts);

  /// Get count of all active alerts
  int get activeAlertCount =>
      items.fold(0, (sum, item) => sum + item.activeAlertCount);

  /// Get only critical alerts across all items
  List<HealthAlert> get criticalAlerts =>
      items.expand((item) => item.criticalAlerts).toList();

  factory MealAnalysis.fromJson(Map<String, dynamic> json, String source) {
    return MealAnalysis(
      items: (json['items'] as List)
          .map((item) => FoodItem.fromJson(item))
          .toList(),
      confidence: json['confidence'] ?? 'medium',
      source: source,
    );
  }

  factory MealAnalysis.empty() {
    return MealAnalysis(items: [], confidence: 'low', source: 'manual');
  }
}

// Individual food item
class FoodItem {
  final String name;
  final String portion;
  final int portionGrams;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final bool isEdited;

  // Health indicators from AI analysis
  final HealthIndicators? healthIndicators;

  // Triggered health alerts for this item
  final List<HealthAlert> healthAlerts;

  FoodItem({
    required this.name,
    required this.portion,
    required this.portionGrams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    this.isEdited = false,
    this.healthIndicators,
    this.healthAlerts = const [],
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] ?? 'Unknown',
      portion: json['portion'] ?? '1 serving',
      portionGrams: (json['portion_grams'] ?? json['portionGrams'] ?? 100).toInt(),
      calories: (json['calories'] ?? 0).toInt(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      fiber: (json['fiber'] ?? 0).toDouble(),
      healthIndicators: json['healthIndicators'] != null
          ? HealthIndicators.fromJson(json['healthIndicators'] as Map<String, dynamic>)
          : null,
      healthAlerts: (json['healthAlerts'] as List<dynamic>?)
              ?.map((e) => HealthAlert.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'portion': portion,
      'portion_grams': portionGrams,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'healthIndicators': healthIndicators?.toJson(),
      'healthAlerts': healthAlerts.map((e) => e.toJson()).toList(),
    };
  }

  /// Check if this food item has any active (non-dismissed) alerts
  bool get hasActiveAlerts => healthAlerts.any((alert) => !alert.isDismissed);

  /// Get only the active (non-dismissed) alerts
  List<HealthAlert> get activeAlerts =>
      healthAlerts.where((alert) => !alert.isDismissed).toList();

  /// Get critical alerts only
  List<HealthAlert> get criticalAlerts =>
      healthAlerts.where((alert) => alert.isCritical && !alert.isDismissed).toList();

  /// Count of active alerts
  int get activeAlertCount => activeAlerts.length;

  FoodItem copyWith({
    String? name,
    String? portion,
    int? portionGrams,
    int? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    bool? isEdited,
    HealthIndicators? healthIndicators,
    List<HealthAlert>? healthAlerts,
  }) {
    return FoodItem(
      name: name ?? this.name,
      portion: portion ?? this.portion,
      portionGrams: portionGrams ?? this.portionGrams,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      isEdited: isEdited ?? this.isEdited,
      healthIndicators: healthIndicators ?? this.healthIndicators,
      healthAlerts: healthAlerts ?? this.healthAlerts,
    );
  }
}

// User daily goals
class DailyGoals {
  final int calorieGoal;
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;
  final double fiberGoal;

  DailyGoals({
    required this.calorieGoal,
    required this.proteinGoal,
    required this.carbsGoal,
    required this.fatGoal,
    this.fiberGoal = 25, // Default fiber goal
  });

  factory DailyGoals.defaultGoals() {
    return DailyGoals(
      calorieGoal: 2000,
      proteinGoal: 60,
      carbsGoal: 250,
      fatGoal: 65,
      fiberGoal: 25,
    );
  }
}

// Meal type enum
enum MealType {
  breakfast('Breakfast'),
  lunch('Lunch'),
  dinner('Dinner'),
  snack('Snack');

  final String displayName;
  const MealType(this.displayName);
}

// Analytics time range
enum TimeRange {
  day('Today'),
  week('Week'),
  month('Month'),
  year('Year');

  final String displayName;
  const TimeRange(this.displayName);
}

// Daily summary for analytics
class DailySummary {
  final DateTime date;
  final int totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final int mealCount;

  DailySummary({
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.mealCount,
  });
}
