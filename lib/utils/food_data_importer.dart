import '../services/database_service.dart';
import 'csv_parser.dart';
import 'package:drift/drift.dart';

/// Food Data Importer - Handles bulk import of nutrition data from various sources
class FoodDataImporter {
  final AppDatabase _database;

  FoodDataImporter(this._database);

  /// Import foods from Kaggle Indian Food Nutrition dataset
  /// Expected CSV columns: Dish Name, Calories (kcal), Protein (g), Carbohydrates (g), Fats (g), Fibre (g)
  Future<int> importKaggleIndianFood(String csvPath) async {
    print('📥 Importing Indian Food Nutrition dataset from: $csvPath');
    
    try {
      final data = await CSVParser.parseAsset(csvPath);
      print('📊 Found ${data.length} rows in CSV');
      int imported = 0;
      int skipped = 0;

      for (final row in data) {
        try {
          // Support both formats: "Dish Name" and "Food"
          final name = CSVParser.cleanFoodName(
            row['Dish Name'] ?? row['dish name'] ??
            row['Food'] ?? row['food'] ?? ''
          );
          
          if (name.isEmpty) {
            skipped++;
            continue;
          }

          // Parse calories - support both "Calories (kcal)" and "Calories"
          // CSV has decimal values like 16.14, so parse as double then round to int
          final caloriesStr = row['Calories (kcal)'] ?? row['calories (kcal)'] ??
                             row['Calories'] ?? row['calories'] ?? '0';
          final caloriesDouble = CSVParser.parseDouble(caloriesStr, defaultValue: 0.0);
          final calories = caloriesDouble.round();

          // Parse protein - support both "Protein (g)" and "Protein"
          final proteinStr = row['Protein (g)'] ?? row['protein (g)'] ??
                            row['Protein'] ?? row['protein'] ?? '0';
          final protein = CSVParser.parseDouble(proteinStr, defaultValue: 0.0);

          // Parse carbs - support multiple column names
          final carbsStr = row['Carbohydrates (g)'] ?? row['carbohydrates (g)'] ??
                          row['Carbs'] ?? row['carbs'] ??
                          row['Carbohydrates'] ?? row['carbohydrates'] ?? '0';
          final carbs = CSVParser.parseDouble(carbsStr, defaultValue: 0.0);

          // Parse fats - support both "Fats (g)" and "Fat"
          final fatsStr = row['Fats (g)'] ?? row['fats (g)'] ??
                         row['Fat'] ?? row['fat'] ?? '0';
          final fats = CSVParser.parseDouble(fatsStr, defaultValue: 0.0);

          // Parse fiber - support both "Fibre (g)" and "Fiber"
          final fiberStr = row['Fibre (g)'] ?? row['fibre (g)'] ??
                          row['Fiber'] ?? row['fiber'] ?? '0';
          final fiber = CSVParser.parseDouble(fiberStr, defaultValue: 0.0);

          // Serving size defaults to 100g if not provided
          final servingSize = row['Serving_Size'] ?? row['serving_size'] ?? '100g';
          final servingGrams = CSVParser.parseInt(
            row['Serving_Grams'] ?? row['serving_grams'],
            defaultValue: 100
          );

          await _database.into(_database.indianFoods).insert(
            IndianFoodsCompanion.insert(
              name: name,
              aliases: Value(null),
              category: _categorizeFood(name),
              region: 'All India',
              servingSize: servingSize,
              servingGrams: servingGrams,
              calories: calories,
              protein: protein,
              carbs: carbs,
              fat: fats,
              fiber: fiber,
            ),
            mode: InsertMode.insertOrIgnore,
          );
          imported++;
          
          // Log progress every 100 items
          if (imported % 100 == 0) {
            print('📦 Imported $imported foods...');
          }
        } catch (e) {
          skipped++;
          print('⚠️ Error importing row: $e - Row data: ${row.keys.take(3).join(", ")}');
        }
      }

      print('✅ Successfully imported $imported foods (skipped $skipped)');
      return imported;
    } catch (e) {
      print('❌ Failed to import CSV: $e');
      return 0;
    }
  }

  /// Import foods from IFCT 2017 (Indian Food Composition Tables)
  /// Expected CSV columns: name, energy, protein, fat, carbohydrate, fiber
  Future<int> importIFCT2017(String csvPath) async {
    print('📥 Importing IFCT 2017 dataset...');
    
    final data = await CSVParser.parseAsset(csvPath);
    int imported = 0;

    for (final row in data) {
      try {
        final name = CSVParser.cleanFoodName(row['name'] ?? row['Food Item'] ?? '');
        if (name.isEmpty) continue;

        await _database.into(_database.indianFoods).insert(
          IndianFoodsCompanion.insert(
            name: name,
            aliases: Value(null),
            category: _categorizeFood(name),
            region: 'All India',
            servingSize: '100g',
            servingGrams: 100,
            calories: CSVParser.parseDouble(row['energy'] ?? row['Energy']).round(),
            protein: CSVParser.parseDouble(row['protein'] ?? row['Protein']),
            carbs: CSVParser.parseDouble(row['carbohydrate'] ?? row['Carbohydrate']),
            fat: CSVParser.parseDouble(row['fat'] ?? row['Fat']),
            fiber: CSVParser.parseDouble(row['fiber'] ?? row['Fiber'], defaultValue: 0.0),
          ),
          mode: InsertMode.insertOrIgnore,
        );
        imported++;
      } catch (e) {
        print('⚠️ Error importing row: $e');
      }
    }

    print('✅ Imported $imported foods from IFCT 2017');
    return imported;
  }

  /// Import custom CSV with flexible column mapping
  Future<int> importCustomCSV(
    String csvPath, {
    required String nameColumn,
    required String caloriesColumn,
    required String proteinColumn,
    required String carbsColumn,
    required String fatColumn,
    String? fiberColumn,
    String? servingSizeColumn,
    String? servingGramsColumn,
    String? categoryColumn,
    String? regionColumn,
  }) async {
    print('📥 Importing custom CSV dataset...');
    
    final data = await CSVParser.parseAsset(csvPath);
    int imported = 0;

    for (final row in data) {
      try {
        final name = CSVParser.cleanFoodName(row[nameColumn] ?? '');
        if (name.isEmpty) continue;

        await _database.into(_database.indianFoods).insert(
          IndianFoodsCompanion.insert(
            name: name,
            aliases: Value(null),
            category: categoryColumn != null ? (row[categoryColumn] ?? _categorizeFood(name)) : _categorizeFood(name),
            region: regionColumn != null ? (row[regionColumn] ?? 'All India') : 'All India',
            servingSize: servingSizeColumn != null ? (row[servingSizeColumn] ?? '100g') : '100g',
            servingGrams: servingGramsColumn != null 
                ? CSVParser.parseInt(row[servingGramsColumn], defaultValue: 100)
                : 100,
            calories: CSVParser.parseDouble(row[caloriesColumn]).round(),
            protein: CSVParser.parseDouble(row[proteinColumn]),
            carbs: CSVParser.parseDouble(row[carbsColumn]),
            fat: CSVParser.parseDouble(row[fatColumn]),
            fiber: fiberColumn != null 
                ? CSVParser.parseDouble(row[fiberColumn], defaultValue: 0.0)
                : 0.0,
          ),
          mode: InsertMode.insertOrIgnore,
        );
        imported++;
      } catch (e) {
        print('⚠️ Error importing row: $e');
      }
    }

    print('✅ Imported $imported foods from custom CSV');
    return imported;
  }

  /// Categorize food based on name keywords
  String _categorizeFood(String name) {
    final lowercaseName = name.toLowerCase();

    // Breakfast items
    if (lowercaseName.contains('idli') ||
        lowercaseName.contains('dosa') ||
        lowercaseName.contains('upma') ||
        lowercaseName.contains('poha') ||
        lowercaseName.contains('paratha')) {
      return 'Breakfast';
    }

    // Rice dishes
    if (lowercaseName.contains('rice') ||
        lowercaseName.contains('biryani') ||
        lowercaseName.contains('pulao')) {
      return 'Rice';
    }

    // Bread
    if (lowercaseName.contains('roti') ||
        lowercaseName.contains('naan') ||
        lowercaseName.contains('chapati') ||
        lowercaseName.contains('bread')) {
      return 'Bread';
    }

    // Snacks
    if (lowercaseName.contains('samosa') ||
        lowercaseName.contains('pakora') ||
        lowercaseName.contains('vada') ||
        lowercaseName.contains('bhaji')) {
      return 'Snack';
    }

    // Desserts
    if (lowercaseName.contains('sweet') ||
        lowercaseName.contains('halwa') ||
        lowercaseName.contains('kheer') ||
        lowercaseName.contains('gulab') ||
        lowercaseName.contains('ladoo') ||
        lowercaseName.contains('barfi')) {
      return 'Dessert';
    }

    // Beverages
    if (lowercaseName.contains('tea') ||
        lowercaseName.contains('chai') ||
        lowercaseName.contains('coffee') ||
        lowercaseName.contains('lassi') ||
        lowercaseName.contains('juice')) {
      return 'Beverage';
    }

    // Side dishes
    if (lowercaseName.contains('raita') ||
        lowercaseName.contains('chutney') ||
        lowercaseName.contains('pickle') ||
        lowercaseName.contains('papad')) {
      return 'Side Dish';
    }

    // Default to main course
    return 'Main Course';
  }

  /// Get import statistics
  Future<Map<String, int>> getImportStats() async {
    final totalFoods = await (_database.selectOnly(_database.indianFoods)
          ..addColumns([_database.indianFoods.id.count()]))
        .getSingle();

    final categories = await (_database.selectOnly(_database.indianFoods)
          ..addColumns([_database.indianFoods.category])
          ..groupBy([_database.indianFoods.category]))
        .get();

    return {
      'total': totalFoods.read(_database.indianFoods.id.count()) ?? 0,
      'categories': categories.length,
    };
  }
}
