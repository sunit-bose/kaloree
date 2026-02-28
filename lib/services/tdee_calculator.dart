/// TDEE Calculator Service
/// Implements Mifflin-St Jeor equation for BMR and TDEE calculation
/// with goal-based macro allocation

/// Gender enum for BMR calculation
enum Gender {
  male('Male'),
  female('Female');

  final String displayName;
  const Gender(this.displayName);

  static Gender fromString(String value) {
    return Gender.values.firstWhere(
      (g) => g.name.toLowerCase() == value.toLowerCase(),
      orElse: () => Gender.male,
    );
  }
}

/// Activity level with Physical Activity Level (PAL) multipliers
enum ActivityLevel {
  sedentary('Sedentary', 'Little/no exercise', 1.2),
  lightlyActive('Lightly Active', '1-3 days/week', 1.375),
  moderatelyActive('Moderately Active', '3-5 days/week', 1.55),
  veryActive('Very Active', '6-7 days/week', 1.725),
  extraActive('Extra Active', 'Physical job + training', 1.9);

  final String displayName;
  final String description;
  final double multiplier;

  const ActivityLevel(this.displayName, this.description, this.multiplier);

  static ActivityLevel fromString(String value) {
    return ActivityLevel.values.firstWhere(
      (a) => a.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ActivityLevel.sedentary,
    );
  }
}

/// Fitness goal for caloric adjustment (legacy enum kept for compatibility)
enum FitnessGoal {
  fatLoss('Fat Loss', 'Lose fat, preserve muscle', -400),
  maintenance('Maintenance', 'Maintain current weight', 0),
  muscleGain('Muscle Gain', 'Build muscle mass', 300);

  final String displayName;
  final String description;
  final int calorieAdjustment; // kcal adjustment from TDEE

  const FitnessGoal(this.displayName, this.description, this.calorieAdjustment);

  static FitnessGoal fromString(String value) {
    return FitnessGoal.values.firstWhere(
      (g) => g.name.toLowerCase() == value.toLowerCase(),
      orElse: () => FitnessGoal.maintenance,
    );
  }
  
  /// Derive fitness goal from weight difference
  static FitnessGoal fromWeightDifference(double currentWeight, double targetWeight) {
    final diff = currentWeight - targetWeight;
    if (diff > 0.5) return FitnessGoal.fatLoss;
    if (diff < -0.5) return FitnessGoal.muscleGain;
    return FitnessGoal.maintenance;
  }
}

/// User profile for TDEE calculation
class UserProfile {
  final int age;
  final double weightKg;
  final double heightCm;
  final Gender gender;
  final ActivityLevel activityLevel;
  final FitnessGoal fitnessGoal;
  final double? targetWeightKg; // New: target weight for auto-calculation

  const UserProfile({
    required this.age,
    required this.weightKg,
    required this.heightCm,
    required this.gender,
    required this.activityLevel,
    this.fitnessGoal = FitnessGoal.maintenance,
    this.targetWeightKg,
  });

  /// Create a default profile
  factory UserProfile.defaultProfile() {
    return const UserProfile(
      age: 30,
      weightKg: 70.0,
      heightCm: 170.0,
      gender: Gender.male,
      activityLevel: ActivityLevel.sedentary,
      fitnessGoal: FitnessGoal.maintenance,
      targetWeightKg: null,
    );
  }

  UserProfile copyWith({
    int? age,
    double? weightKg,
    double? heightCm,
    Gender? gender,
    ActivityLevel? activityLevel,
    FitnessGoal? fitnessGoal,
    double? targetWeightKg,
  }) {
    return UserProfile(
      age: age ?? this.age,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
    );
  }
  
  /// Calculate calorie adjustment based on target weight
  /// Returns the daily calorie adjustment needed to reach target weight
  /// Uses safe rate: ~50 kcal per kg difference, capped at ±500 kcal
  int get calorieAdjustmentFromTargetWeight {
    if (targetWeightKg == null) return 0;
    final weightDiff = weightKg - targetWeightKg!;
    
    // Calculate adjustment: ~50 kcal per kg difference
    // Positive diff = need to lose weight = negative calories
    // Negative diff = need to gain weight = positive calories
    int adjustment = (weightDiff * 50).round();
    
    // Cap at safe limits: -500 for fat loss, +400 for muscle gain
    if (adjustment > 500) adjustment = 500;
    if (adjustment < -400) adjustment = -400;
    
    return adjustment;
  }
  
  /// Get the derived fitness goal based on target weight
  FitnessGoal get derivedFitnessGoal {
    if (targetWeightKg == null) return fitnessGoal;
    return FitnessGoal.fromWeightDifference(weightKg, targetWeightKg!);
  }
  
  /// Estimated weeks to reach target (at safe rate of 0.5kg/week)
  int? get weeksToTarget {
    if (targetWeightKg == null) return null;
    final diff = (weightKg - targetWeightKg!).abs();
    return (diff / 0.5).ceil();
  }
}

/// Calculated nutrition targets
class NutritionTargets {
  final int bmr;
  final int tdee;
  final int dailyCalories;
  final double proteinGrams;
  final double fatGrams;
  final double carbsGrams;
  final double fiberGrams;
  final int calorieAdjustment; // +/- from TDEE
  final int? weeksToTarget; // Estimated weeks to reach target weight
  final String goalType; // 'Fat Loss', 'Maintenance', 'Muscle Gain'

  const NutritionTargets({
    required this.bmr,
    required this.tdee,
    required this.dailyCalories,
    required this.proteinGrams,
    required this.fatGrams,
    required this.carbsGrams,
    required this.fiberGrams,
    this.calorieAdjustment = 0,
    this.weeksToTarget,
    this.goalType = 'Maintenance',
  });

  /// Get macros as percentage of daily calories
  double get proteinPercent => (proteinGrams * 4 / dailyCalories) * 100;
  double get fatPercent => (fatGrams * 9 / dailyCalories) * 100;
  double get carbsPercent => (carbsGrams * 4 / dailyCalories) * 100;

  @override
  String toString() {
    return '''
NutritionTargets:
  BMR: $bmr kcal
  TDEE: $tdee kcal
  Daily Calories: $dailyCalories kcal
  Protein: ${proteinGrams.toStringAsFixed(0)}g (${proteinPercent.toStringAsFixed(0)}%)
  Fat: ${fatGrams.toStringAsFixed(0)}g (${fatPercent.toStringAsFixed(0)}%)
  Carbs: ${carbsGrams.toStringAsFixed(0)}g (${carbsPercent.toStringAsFixed(0)}%)
  Fiber: ${fiberGrams.toStringAsFixed(0)}g
''';
  }
}

/// TDEE Calculator implementing Mifflin-St Jeor equation
class TDEECalculator {
  const TDEECalculator();

  /// Calculate BMR using Mifflin-St Jeor Equation
  /// 
  /// Male: BMR = (10 × weight in kg) + (6.25 × height in cm) - (5 × age in years) + 5
  /// Female: BMR = (10 × weight in kg) + (6.25 × height in cm) - (5 × age in years) - 161
  int calculateBMR(UserProfile profile) {
    final weightComponent = 10 * profile.weightKg;
    final heightComponent = 6.25 * profile.heightCm;
    final ageComponent = 5 * profile.age;

    double bmr;
    if (profile.gender == Gender.male) {
      bmr = weightComponent + heightComponent - ageComponent + 5;
    } else {
      bmr = weightComponent + heightComponent - ageComponent - 161;
    }

    return bmr.round();
  }

  /// Calculate TDEE by applying activity multiplier to BMR
  int calculateTDEE(UserProfile profile) {
    final bmr = calculateBMR(profile);
    return (bmr * profile.activityLevel.multiplier).round();
  }

  /// Calculate daily calorie target based on target weight (or fitness goal fallback)
  int calculateDailyCalories(UserProfile profile) {
    final tdee = calculateTDEE(profile);
    
    // Use target weight-based adjustment if available, otherwise use fitness goal
    if (profile.targetWeightKg != null) {
      return tdee - profile.calorieAdjustmentFromTargetWeight;
    }
    return tdee + profile.fitnessGoal.calorieAdjustment;
  }

  /// Calculate macro allocation based on body weight
  /// 
  /// Protein: 2.0g per kg body weight (essential for muscle repair)
  /// Fat: 0.8g per kg body weight (hormonal health)
  /// Carbs: Remaining calories after protein and fat
  /// Fiber: 14g per 1000 kcal (recommended)
  NutritionTargets calculateNutritionTargets(UserProfile profile) {
    final bmr = calculateBMR(profile);
    final tdee = calculateTDEE(profile);
    final dailyCalories = calculateDailyCalories(profile);
    
    // Calculate calorie adjustment (positive = surplus, negative = deficit)
    final calorieAdjustment = dailyCalories - tdee;
    
    // Determine goal type
    final goalType = profile.derivedFitnessGoal.displayName;

    // Protein: 2.0g per kg body weight
    final proteinGrams = profile.weightKg * 2.0;
    final proteinCalories = proteinGrams * 4;

    // Fat: 0.8g per kg body weight
    final fatGrams = profile.weightKg * 0.8;
    final fatCalories = fatGrams * 9;

    // Carbs: Remaining calories
    final remainingCalories = dailyCalories - proteinCalories - fatCalories;
    final carbsGrams = remainingCalories > 0 ? remainingCalories / 4 : 0;

    // Fiber: 14g per 1000 kcal (recommended minimum)
    final fiberGrams = (dailyCalories / 1000) * 14;

    return NutritionTargets(
      bmr: bmr,
      tdee: tdee,
      dailyCalories: dailyCalories,
      proteinGrams: proteinGrams,
      fatGrams: fatGrams,
      carbsGrams: carbsGrams.toDouble(),
      fiberGrams: fiberGrams,
      calorieAdjustment: calorieAdjustment,
      weeksToTarget: profile.weeksToTarget,
      goalType: goalType,
    );
  }

  /// Quick calculation for display purposes (with target weight support)
  static NutritionTargets quickCalculate({
    required int age,
    required double weightKg,
    required double heightCm,
    required Gender gender,
    required ActivityLevel activityLevel,
    double? targetWeightKg,
    FitnessGoal fitnessGoal = FitnessGoal.maintenance,
  }) {
    final profile = UserProfile(
      age: age,
      weightKg: weightKg,
      heightCm: heightCm,
      gender: gender,
      activityLevel: activityLevel,
      fitnessGoal: fitnessGoal,
      targetWeightKg: targetWeightKg,
    );
    return const TDEECalculator().calculateNutritionTargets(profile);
  }
}
