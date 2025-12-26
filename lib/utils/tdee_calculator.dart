import '../models/meal_analysis.dart';

/// TDEE (Total Daily Energy Expenditure) Calculator
/// Uses Mifflin-St Jeor formula for BMR calculation
class TDEECalculator {
  /// Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor formula
  /// 
  /// Men: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(y) + 5
  /// Women: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(y) - 161
  static double calculateBMR({
    required int age,
    required double weight, // kg
    required double height, // cm
    required String gender,
  }) {
    // Validate inputs
    if (age < 10 || age > 100) {
      throw ArgumentError('Age must be between 10 and 100');
    }
    if (weight < 30 || weight > 300) {
      throw ArgumentError('Weight must be between 30 and 300 kg');
    }
    if (height < 100 || height > 250) {
      throw ArgumentError('Height must be between 100 and 250 cm');
    }

    final baseBMR = 10 * weight + 6.25 * height - 5 * age;
    
    if (gender.toLowerCase() == 'male') {
      return baseBMR + 5;
    } else if (gender.toLowerCase() == 'female') {
      return baseBMR - 161;
    } else {
      // For 'other' gender, use average
      return baseBMR - 78; // average of male and female constants
    }
  }

  /// Calculate TDEE (Total Daily Energy Expenditure)
  /// TDEE = BMR × Activity Multiplier
  static double calculateTDEE({
    required int age,
    required double weight,
    required double height,
    required String gender,
    required String activityLevel,
  }) {
    final bmr = calculateBMR(
      age: age,
      weight: weight,
      height: height,
      gender: gender,
    );

    final multiplier = ActivityLevel.fromString(activityLevel).multiplier;
    return bmr * multiplier;
  }

  /// Calculate macro distribution from TDEE
  /// Returns Map with 'protein', 'carbs', 'fat' in grams
  /// 
  /// Default split:
  /// - Protein: 30% of calories (÷4 for grams)
  /// - Carbs: 45% of calories (÷4 for grams)
  /// - Fat: 25% of calories (÷9 for grams)
  static Map<String, double> calculateMacros(double tdee, {
    double proteinPercent = 0.30,
    double carbsPercent = 0.45,
    double fatPercent = 0.25,
  }) {
    // Validate percentages sum to ~100%
    final total = proteinPercent + carbsPercent + fatPercent;
    if ((total - 1.0).abs() > 0.01) {
      throw ArgumentError('Macro percentages must sum to 100%');
    }

    return {
      'protein': (tdee * proteinPercent) / 4, // 4 cal/gram
      'carbs': (tdee * carbsPercent) / 4,     // 4 cal/gram
      'fat': (tdee * fatPercent) / 9,         // 9 cal/gram
    };
  }

  /// Calculate recommended macros from profile
  static DailyGoals calculateGoalsFromProfile(UserProfile profile) {
    final tdee = calculateTDEE(
      age: profile.age,
      weight: profile.weight,
      height: profile.height,
      gender: profile.gender,
      activityLevel: profile.activityLevel,
    );

    final macros = calculateMacros(tdee);

    return DailyGoals(
      calorieGoal: tdee.round(),
      proteinGoal: macros['protein']!,
      carbsGoal: macros['carbs']!,
      fatGoal: macros['fat']!,
    );
  }

  /// Get activity level recommendation based on lifestyle
  static String getActivityRecommendation(String lifestyle) {
    switch (lifestyle.toLowerCase()) {
      case 'desk job':
      case 'sitting':
        return 'sedentary';
      case 'light activity':
      case 'occasional exercise':
        return 'light';
      case 'regular exercise':
      case 'active lifestyle':
        return 'moderate';
      case 'daily exercise':
      case 'athlete':
        return 'very';
      case 'professional athlete':
      case 'physical job + exercise':
        return 'extra';
      default:
        return 'moderate';
    }
  }
}
