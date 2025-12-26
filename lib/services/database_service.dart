import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal_analysis.dart';
import '../utils/food_data_importer.dart';

part 'database_service.g.dart';

// ============================================
// TABLE DEFINITIONS
// ============================================

class Meals extends Table {
  TextColumn get id => text()();
  TextColumn get date => text()(); // YYYY-MM-DD
  IntColumn get timestamp => integer()();
  IntColumn get mealNumber => integer()();
  TextColumn get mealType => text().nullable()(); // breakfast, lunch, dinner, snack
  TextColumn get source => text()(); // ai, search, manual
  IntColumn get totalCalories => integer()();
  RealColumn get totalProtein => real()();
  RealColumn get totalCarbs => real()();
  RealColumn get totalFat => real()();
  RealColumn get totalFiber => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class MealItems extends Table {
  TextColumn get id => text()();
  TextColumn get mealId => text().references(Meals, #id)();
  TextColumn get name => text()();
  TextColumn get portion => text()();
  IntColumn get portionGrams => integer()();
  IntColumn get calories => integer()();
  RealColumn get protein => real()();
  RealColumn get carbs => real()();
  RealColumn get fat => real()();
  RealColumn get fiber => real()();
  BoolColumn get isEdited => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class UserSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  IntColumn get calorieGoal => integer().withDefault(const Constant(2000))();
  RealColumn get proteinGoal => real().withDefault(const Constant(60))();
  RealColumn get carbsGoal => real().withDefault(const Constant(250))();
  RealColumn get fatGoal => real().withDefault(const Constant(65))();
  IntColumn get createdAt => integer()();
  
  // User Profile for TDEE calculation
  IntColumn get age => integer().nullable()();
  RealColumn get weight => real().nullable()(); // kg
  RealColumn get height => real().nullable()(); // cm
  TextColumn get gender => text().nullable()(); // male, female, other
  TextColumn get activityLevel => text().nullable()(); // sedentary, light, moderate, very, extra
  IntColumn get calculatedTDEE => integer().nullable()(); // Persisted maintenance calories

  @override
  Set<Column> get primaryKey => {id};
}

class IndianFoods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get aliases => text().nullable()();
  TextColumn get category => text()();
  TextColumn get region => text()();
  TextColumn get servingSize => text()();
  IntColumn get servingGrams => integer()();
  IntColumn get calories => integer()();
  RealColumn get protein => real()();
  RealColumn get carbs => real()();
  RealColumn get fat => real()();
  RealColumn get fiber => real()();
}

// ============================================
// DATABASE CLASS
// ============================================

@DriftDatabase(tables: [Meals, MealItems, UserSettings, IndianFoods])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from == 1) {
        // Add new profile columns to UserSettings (v1 -> v2)
        await migrator.addColumn(userSettings, userSettings.age);
        await migrator.addColumn(userSettings, userSettings.weight);
        await migrator.addColumn(userSettings, userSettings.height);
        await migrator.addColumn(userSettings, userSettings.gender);
        await migrator.addColumn(userSettings, userSettings.activityLevel);
      }
      if (from <= 2) {
        // Add calculatedTDEE column (v2 -> v3)
        await migrator.addColumn(userSettings, userSettings.calculatedTDEE);
      }
    },
  );

  // Initialize default data
  Future<void> initializeDefaultData() async {
    // Create default settings if not exists
    final existingSettings = await (select(userSettings)..limit(1)).getSingleOrNull();
    if (existingSettings == null) {
      await into(userSettings).insert(UserSettingsCompanion.insert(
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ));
    }

    // Seed Indian foods if empty
    final foodCount = await (selectOnly(indianFoods)..addColumns([indianFoods.id.count()])).getSingle();
    final currentCount = foodCount.read(indianFoods.id.count()) ?? 0;
    print('🗄️ Current food count in database: $currentCount');
    
    // Seed basic foods if database is empty
    if (currentCount == 0) {
      print('📦 Database is empty, seeding initial 43 foods...');
      await _seedIndianFoods();
    }
    
    // Import CSV dataset if we don't have enough foods (< 100 means CSV hasn't been imported)
    if (currentCount < 100) {
      print('📥 Starting CSV import of 1014 Indian food recipes...');
      final imported = await importFoodsFromCSV('assets/data/Indian_Food_Nutrition_Processed.csv');
      
      final newCount = await (selectOnly(indianFoods)..addColumns([indianFoods.id.count()])).getSingle();
      final finalCount = newCount.read(indianFoods.id.count()) ?? 0;
      print('✅ Database initialization complete. Total foods: $finalCount (imported $imported new items)');
    } else {
      print('ℹ️ Database already fully populated with $currentCount foods');
    }
  }

  // ============================================
  // MEALS CRUD
  // ============================================

  Future<void> saveMeal(MealAnalysis analysis, MealType? type, {DateTime? customDate}) async {
    final now = customDate ?? DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    // Get next meal number for today
    final todayMeals = await (select(meals)..where((m) => m.date.equals(dateStr))).get();
    final mealNumber = todayMeals.length + 1;
    
    final mealId = '${dateStr}_$mealNumber';
    
    // Insert meal
    await into(meals).insert(MealsCompanion.insert(
      id: mealId,
      date: dateStr,
      timestamp: now.millisecondsSinceEpoch,
      mealNumber: mealNumber,
      mealType: Value(type?.name),
      source: analysis.source,
      totalCalories: analysis.totalCalories,
      totalProtein: analysis.totalProtein,
      totalCarbs: analysis.totalCarbs,
      totalFat: analysis.totalFat,
      totalFiber: analysis.totalFiber,
    ));

    // Insert meal items
    for (var i = 0; i < analysis.items.length; i++) {
      final item = analysis.items[i];
      await into(mealItems).insert(MealItemsCompanion.insert(
        id: '${mealId}_$i',
        mealId: mealId,
        name: item.name,
        portion: item.portion,
        portionGrams: item.portionGrams,
        calories: item.calories,
        protein: item.protein,
        carbs: item.carbs,
        fat: item.fat,
        fiber: item.fiber,
        isEdited: Value(item.isEdited),
      ));
    }
  }

  Future<List<Meal>> getMealsForDate(String date) {
    return (select(meals)
      ..where((m) => m.date.equals(date))
      ..orderBy([(m) => OrderingTerm.asc(m.mealNumber)]))
        .get();
  }

  Future<List<MealItem>> getMealItems(String mealId) {
    return (select(mealItems)..where((m) => m.mealId.equals(mealId))).get();
  }

  Future<void> updateMealType(String mealId, MealType type) {
    return (update(meals)..where((m) => m.id.equals(mealId)))
        .write(MealsCompanion(mealType: Value(type.name)));
  }

  Future<void> deleteMeal(String mealId) async {
    await (delete(mealItems)..where((m) => m.mealId.equals(mealId))).go();
    await (delete(meals)..where((m) => m.id.equals(mealId))).go();
  }

  // ============================================
  // ANALYTICS QUERIES
  // ============================================

  Future<DailySummary> getDailySummary(String date) async {
    final result = await (select(meals)..where((m) => m.date.equals(date))).get();
    
    return DailySummary(
      date: DateTime.parse(date),
      totalCalories: result.fold(0, (sum, m) => sum + m.totalCalories),
      totalProtein: result.fold(0.0, (sum, m) => sum + m.totalProtein),
      totalCarbs: result.fold(0.0, (sum, m) => sum + m.totalCarbs),
      totalFat: result.fold(0.0, (sum, m) => sum + m.totalFat),
      mealCount: result.length,
    );
  }

  Future<List<DailySummary>> getWeeklySummary() async {
    final now = DateTime.now();
    final summaries = <DailySummary>[];
    
    for (var i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      summaries.add(await getDailySummary(dateStr));
    }
    
    return summaries;
  }

  Future<List<DailySummary>> getMonthlySummary() async {
    final now = DateTime.now();
    final summaries = <DailySummary>[];
    
    for (var i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      summaries.add(await getDailySummary(dateStr));
    }
    
    return summaries;
  }

  // ============================================
  // USER SETTINGS
  // ============================================

  Future<DailyGoals> getGoals() async {
    final settings = await (select(userSettings)..limit(1)).getSingleOrNull();
    if (settings == null) {
      return DailyGoals.defaultGoals();
    }
    return DailyGoals(
      calorieGoal: settings.calorieGoal,
      proteinGoal: settings.proteinGoal,
      carbsGoal: settings.carbsGoal,
      fatGoal: settings.fatGoal,
    );
  }

  Future<void> updateGoals(DailyGoals goals) {
    return (update(userSettings)..where((s) => s.id.equals(1))).write(
      UserSettingsCompanion(
        calorieGoal: Value(goals.calorieGoal),
        proteinGoal: Value(goals.proteinGoal),
        carbsGoal: Value(goals.carbsGoal),
        fatGoal: Value(goals.fatGoal),
      ),
    );
  }

  // ============================================
  // USER PROFILE
  // ============================================

  Future<UserProfile?> getProfile() async {
    final settings = await (select(userSettings)..limit(1)).getSingleOrNull();
    if (settings == null || settings.age == null) {
      return null;
    }
    return UserProfile(
      age: settings.age!,
      weight: settings.weight!,
      height: settings.height!,
      gender: settings.gender!,
      activityLevel: settings.activityLevel!,
    );
  }

  Future<void> saveProfile(UserProfile profile) {
    return (update(userSettings)..where((s) => s.id.equals(1))).write(
      UserSettingsCompanion(
        age: Value(profile.age),
        weight: Value(profile.weight),
        height: Value(profile.height),
        gender: Value(profile.gender),
        activityLevel: Value(profile.activityLevel),
      ),
    );
  }

  Future<int?> getCalculatedTDEE() async {
    final settings = await (select(userSettings)..limit(1)).getSingleOrNull();
    return settings?.calculatedTDEE;
  }

  Future<void> saveCalculatedTDEE(int tdee) {
    return (update(userSettings)..where((s) => s.id.equals(1))).write(
      UserSettingsCompanion(
        calculatedTDEE: Value(tdee),
      ),
    );
  }

  // ============================================
  // INDIAN FOODS SEARCH
  // ============================================

  Future<List<IndianFood>> searchFoods(String query) {
    final searchTerm = '%${query.toLowerCase()}%';
    return (select(indianFoods)
      ..where((f) => f.name.lower().like(searchTerm) | f.aliases.lower().like(searchTerm))
      ..limit(2000)) // Support large datasets - UI handles lazy loading
        .get();
  }

  // ============================================
  // CSV IMPORT
  // ============================================

  /// Import foods from CSV file using the FoodDataImporter
  Future<int> importFoodsFromCSV(String csvPath) async {
    final importer = FoodDataImporter(this);
    return await importer.importKaggleIndianFood(csvPath);
  }

  /// Get total food count for statistics
  Future<int> getTotalFoodCount() async {
    final result = await (selectOnly(indianFoods)
      ..addColumns([indianFoods.id.count()]))
        .getSingle();
    return result.read(indianFoods.id.count()) ?? 0;
  }

  // ============================================
  // SEED DATA
  // ============================================

  Future<void> _seedIndianFoods() async {
    final foods = [
      // North Indian
      {'name': 'Dal Tadka', 'aliases': 'Yellow Dal, Tadka Dal', 'category': 'Main Course', 'region': 'North Indian', 'servingSize': '1 bowl (200ml)', 'servingGrams': 200, 'calories': 180, 'protein': 9.5, 'carbs': 24.0, 'fat': 6.2, 'fiber': 4.1},
      {'name': 'Roti', 'aliases': 'Chapati, Phulka', 'category': 'Bread', 'region': 'North Indian', 'servingSize': '1 piece', 'servingGrams': 40, 'calories': 104, 'protein': 3.1, 'carbs': 20.0, 'fat': 1.0, 'fiber': 2.0},
      {'name': 'Paneer Butter Masala', 'aliases': 'Butter Paneer, Paneer Makhani', 'category': 'Main Course', 'region': 'North Indian', 'servingSize': '1 bowl (200g)', 'servingGrams': 200, 'calories': 420, 'protein': 14.0, 'carbs': 18.0, 'fat': 32.0, 'fiber': 2.5},
      {'name': 'Chole Bhature', 'aliases': 'Chana Bhatura', 'category': 'Main Course', 'region': 'North Indian', 'servingSize': '1 plate', 'servingGrams': 350, 'calories': 650, 'protein': 15.2, 'carbs': 78.5, 'fat': 32.1, 'fiber': 8.3},
      {'name': 'Rajma Chawal', 'aliases': 'Rajma Rice, Kidney Beans Rice', 'category': 'Main Course', 'region': 'North Indian', 'servingSize': '1 plate', 'servingGrams': 400, 'calories': 520, 'protein': 16.0, 'carbs': 85.0, 'fat': 12.0, 'fiber': 12.0},
      {'name': 'Aloo Paratha', 'aliases': 'Potato Paratha', 'category': 'Bread', 'region': 'North Indian', 'servingSize': '1 piece', 'servingGrams': 120, 'calories': 300, 'protein': 6.0, 'carbs': 42.0, 'fat': 12.0, 'fiber': 3.0},
      {'name': 'Palak Paneer', 'aliases': 'Saag Paneer', 'category': 'Main Course', 'region': 'North Indian', 'servingSize': '1 bowl (200g)', 'servingGrams': 200, 'calories': 280, 'protein': 12.0, 'carbs': 10.0, 'fat': 22.0, 'fiber': 4.0},
      
      // South Indian
      {'name': 'Idli', 'aliases': 'Rice Cake', 'category': 'Breakfast', 'region': 'South Indian', 'servingSize': '2 pieces', 'servingGrams': 80, 'calories': 78, 'protein': 2.0, 'carbs': 16.0, 'fat': 0.4, 'fiber': 0.8},
      {'name': 'Dosa', 'aliases': 'Plain Dosa', 'category': 'Breakfast', 'region': 'South Indian', 'servingSize': '1 piece', 'servingGrams': 100, 'calories': 168, 'protein': 4.0, 'carbs': 28.0, 'fat': 4.5, 'fiber': 1.0},
      {'name': 'Masala Dosa', 'aliases': 'Potato Dosa', 'category': 'Breakfast', 'region': 'South Indian', 'servingSize': '1 piece', 'servingGrams': 200, 'calories': 320, 'protein': 7.0, 'carbs': 48.0, 'fat': 11.0, 'fiber': 3.0},
      {'name': 'Sambar', 'aliases': 'Sambhar', 'category': 'Side Dish', 'region': 'South Indian', 'servingSize': '1 bowl (150ml)', 'servingGrams': 150, 'calories': 85, 'protein': 4.5, 'carbs': 12.0, 'fat': 2.5, 'fiber': 3.5},
      {'name': 'Uttapam', 'aliases': 'Uthappam', 'category': 'Breakfast', 'region': 'South Indian', 'servingSize': '1 piece', 'servingGrams': 150, 'calories': 200, 'protein': 5.0, 'carbs': 32.0, 'fat': 6.0, 'fiber': 2.0},
      {'name': 'Vada', 'aliases': 'Medu Vada', 'category': 'Snack', 'region': 'South Indian', 'servingSize': '2 pieces', 'servingGrams': 80, 'calories': 240, 'protein': 8.0, 'carbs': 22.0, 'fat': 14.0, 'fiber': 2.5},
      {'name': 'Upma', 'aliases': 'Uppuma', 'category': 'Breakfast', 'region': 'South Indian', 'servingSize': '1 bowl (200g)', 'servingGrams': 200, 'calories': 220, 'protein': 5.0, 'carbs': 35.0, 'fat': 7.0, 'fiber': 2.0},
      {'name': 'Pongal', 'aliases': 'Ven Pongal', 'category': 'Breakfast', 'region': 'South Indian', 'servingSize': '1 bowl (200g)', 'servingGrams': 200, 'calories': 280, 'protein': 7.0, 'carbs': 40.0, 'fat': 10.0, 'fiber': 1.5},
      
      // Rice dishes
      {'name': 'Jeera Rice', 'aliases': 'Cumin Rice', 'category': 'Rice', 'region': 'North Indian', 'servingSize': '1 bowl (150g)', 'servingGrams': 150, 'calories': 210, 'protein': 4.0, 'carbs': 42.0, 'fat': 3.0, 'fiber': 0.5},
      {'name': 'Biryani', 'aliases': 'Veg Biryani, Pulao Biryani', 'category': 'Rice', 'region': 'Hyderabadi', 'servingSize': '1 plate (300g)', 'servingGrams': 300, 'calories': 450, 'protein': 10.0, 'carbs': 65.0, 'fat': 16.0, 'fiber': 2.0},
      {'name': 'Chicken Biryani', 'aliases': 'Dum Biryani', 'category': 'Rice', 'region': 'Hyderabadi', 'servingSize': '1 plate (350g)', 'servingGrams': 350, 'calories': 550, 'protein': 25.0, 'carbs': 60.0, 'fat': 22.0, 'fiber': 2.0},
      {'name': 'Pulao', 'aliases': 'Vegetable Pulao', 'category': 'Rice', 'region': 'North Indian', 'servingSize': '1 bowl (200g)', 'servingGrams': 200, 'calories': 280, 'protein': 5.0, 'carbs': 48.0, 'fat': 8.0, 'fiber': 2.0},
      {'name': 'Lemon Rice', 'aliases': 'Chitranna', 'category': 'Rice', 'region': 'South Indian', 'servingSize': '1 bowl (200g)', 'servingGrams': 200, 'calories': 250, 'protein': 4.0, 'carbs': 45.0, 'fat': 6.0, 'fiber': 1.0},
      
      // Snacks
      {'name': 'Samosa', 'aliases': 'Aloo Samosa', 'category': 'Snack', 'region': 'North Indian', 'servingSize': '1 piece', 'servingGrams': 80, 'calories': 260, 'protein': 4.0, 'carbs': 28.0, 'fat': 15.0, 'fiber': 2.0},
      {'name': 'Pakora', 'aliases': 'Bhajiya, Pakoda', 'category': 'Snack', 'region': 'North Indian', 'servingSize': '4 pieces', 'servingGrams': 100, 'calories': 280, 'protein': 6.0, 'carbs': 24.0, 'fat': 18.0, 'fiber': 2.5},
      {'name': 'Pav Bhaji', 'aliases': 'Pao Bhaji', 'category': 'Snack', 'region': 'Maharashtrian', 'servingSize': '1 plate', 'servingGrams': 350, 'calories': 520, 'protein': 12.0, 'carbs': 70.0, 'fat': 22.0, 'fiber': 6.0},
      {'name': 'Poha', 'aliases': 'Flattened Rice', 'category': 'Breakfast', 'region': 'Maharashtrian', 'servingSize': '1 plate (200g)', 'servingGrams': 200, 'calories': 250, 'protein': 5.0, 'carbs': 42.0, 'fat': 8.0, 'fiber': 2.0},
      
      // Sweets
      {'name': 'Gulab Jamun', 'aliases': 'Gulaab Jamun', 'category': 'Dessert', 'region': 'North Indian', 'servingSize': '2 pieces', 'servingGrams': 80, 'calories': 300, 'protein': 4.0, 'carbs': 45.0, 'fat': 12.0, 'fiber': 0.5},
      {'name': 'Rasgulla', 'aliases': 'Rosogolla', 'category': 'Dessert', 'region': 'Bengali', 'servingSize': '2 pieces', 'servingGrams': 100, 'calories': 180, 'protein': 4.0, 'carbs': 38.0, 'fat': 1.5, 'fiber': 0.0},
      {'name': 'Kheer', 'aliases': 'Rice Kheer, Payasam', 'category': 'Dessert', 'region': 'North Indian', 'servingSize': '1 bowl (150g)', 'servingGrams': 150, 'calories': 220, 'protein': 5.0, 'carbs': 32.0, 'fat': 8.0, 'fiber': 0.5},
      {'name': 'Jalebi', 'aliases': 'Jilapi', 'category': 'Dessert', 'region': 'North Indian', 'servingSize': '3 pieces', 'servingGrams': 75, 'calories': 280, 'protein': 2.0, 'carbs': 50.0, 'fat': 9.0, 'fiber': 0.0},
      
      // Beverages
      {'name': 'Masala Chai', 'aliases': 'Chai, Tea', 'category': 'Beverage', 'region': 'All India', 'servingSize': '1 cup (150ml)', 'servingGrams': 150, 'calories': 80, 'protein': 2.0, 'carbs': 12.0, 'fat': 2.5, 'fiber': 0.0},
      {'name': 'Lassi', 'aliases': 'Sweet Lassi', 'category': 'Beverage', 'region': 'North Indian', 'servingSize': '1 glass (250ml)', 'servingGrams': 250, 'calories': 180, 'protein': 6.0, 'carbs': 28.0, 'fat': 5.0, 'fiber': 0.0},
      {'name': 'Buttermilk', 'aliases': 'Chaas, Mattha', 'category': 'Beverage', 'region': 'All India', 'servingSize': '1 glass (200ml)', 'servingGrams': 200, 'calories': 40, 'protein': 2.5, 'carbs': 4.0, 'fat': 1.5, 'fiber': 0.0},
      
      // Curries
      {'name': 'Butter Chicken', 'aliases': 'Murgh Makhani', 'category': 'Main Course', 'region': 'North Indian', 'servingSize': '1 bowl (200g)', 'servingGrams': 200, 'calories': 380, 'protein': 22.0, 'carbs': 12.0, 'fat': 28.0, 'fiber': 1.5},
      {'name': 'Chicken Curry', 'aliases': 'Murg Curry', 'category': 'Main Course', 'region': 'North Indian', 'servingSize': '1 bowl (200g)', 'servingGrams': 200, 'calories': 300, 'protein': 24.0, 'carbs': 8.0, 'fat': 20.0, 'fiber': 2.0},
      {'name': 'Fish Curry', 'aliases': 'Machli Curry', 'category': 'Main Course', 'region': 'Coastal', 'servingSize': '1 bowl (200g)', 'servingGrams': 200, 'calories': 250, 'protein': 22.0, 'carbs': 6.0, 'fat': 16.0, 'fiber': 1.5},
      {'name': 'Egg Curry', 'aliases': 'Anda Curry', 'category': 'Main Course', 'region': 'North Indian', 'servingSize': '2 eggs with gravy', 'servingGrams': 220, 'calories': 320, 'protein': 16.0, 'carbs': 10.0, 'fat': 24.0, 'fiber': 2.0},
      
      // Vegetables
      {'name': 'Aloo Gobi', 'aliases': 'Potato Cauliflower', 'category': 'Side Dish', 'region': 'North Indian', 'servingSize': '1 bowl (150g)', 'servingGrams': 150, 'calories': 160, 'protein': 3.5, 'carbs': 18.0, 'fat': 8.5, 'fiber': 3.0},
      {'name': 'Bhindi Masala', 'aliases': 'Okra Fry', 'category': 'Side Dish', 'region': 'North Indian', 'servingSize': '1 bowl (150g)', 'servingGrams': 150, 'calories': 120, 'protein': 3.0, 'carbs': 12.0, 'fat': 7.0, 'fiber': 4.0},
      {'name': 'Baingan Bharta', 'aliases': 'Mashed Eggplant', 'category': 'Side Dish', 'region': 'North Indian', 'servingSize': '1 bowl (150g)', 'servingGrams': 150, 'calories': 140, 'protein': 3.0, 'carbs': 14.0, 'fat': 8.0, 'fiber': 5.0},
      {'name': 'Mixed Vegetable', 'aliases': 'Mix Veg Sabzi', 'category': 'Side Dish', 'region': 'North Indian', 'servingSize': '1 bowl (150g)', 'servingGrams': 150, 'calories': 130, 'protein': 4.0, 'carbs': 15.0, 'fat': 6.0, 'fiber': 4.0},
      
      // Accompaniments
      {'name': 'Raita', 'aliases': 'Yogurt Raita', 'category': 'Side Dish', 'region': 'North Indian', 'servingSize': '1 bowl (100g)', 'servingGrams': 100, 'calories': 70, 'protein': 3.5, 'carbs': 6.0, 'fat': 3.5, 'fiber': 0.5},
      {'name': 'Pickle', 'aliases': 'Achar', 'category': 'Condiment', 'region': 'All India', 'servingSize': '1 tbsp', 'servingGrams': 15, 'calories': 25, 'protein': 0.2, 'carbs': 2.0, 'fat': 2.0, 'fiber': 0.5},
      {'name': 'Papad', 'aliases': 'Papadum', 'category': 'Side Dish', 'region': 'All India', 'servingSize': '2 pieces', 'servingGrams': 20, 'calories': 80, 'protein': 4.0, 'carbs': 10.0, 'fat': 3.0, 'fiber': 1.0},
      {'name': 'Coconut Chutney', 'aliases': 'Nariyal Chutney', 'category': 'Condiment', 'region': 'South Indian', 'servingSize': '2 tbsp', 'servingGrams': 30, 'calories': 60, 'protein': 1.0, 'carbs': 3.0, 'fat': 5.0, 'fiber': 1.5},
    ];

    for (final food in foods) {
      await into(indianFoods).insert(IndianFoodsCompanion.insert(
        name: food['name'] as String,
        aliases: Value(food['aliases'] as String?),
        category: food['category'] as String,
        region: food['region'] as String,
        servingSize: food['servingSize'] as String,
        servingGrams: food['servingGrams'] as int,
        calories: food['calories'] as int,
        protein: (food['protein'] as num).toDouble(),
        carbs: (food['carbs'] as num).toDouble(),
        fat: (food['fat'] as num).toDouble(),
        fiber: (food['fiber'] as num).toDouble(),
      ));
    }
  }
}

// Database connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'kaloree.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

// Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Database must be initialized in main()');
});
