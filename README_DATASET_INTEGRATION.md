# Indian Food Nutrition Dataset Integration Guide

## 📚 Overview

This guide explains how to enrich your NutriSnap app with comprehensive Indian food nutrition databases from multiple sources.

## 🎯 Supported Data Sources

### 1. **Kaggle Indian Food Nutrition Dataset**
- **Source**: https://www.kaggle.com/datasets/batthulavinay/indian-food-nutrition
- **Content**: ~500+ Indian food items
- **Columns**: Food name, Calories, Protein, Carbs, Fat, Fiber, Serving size

### 2. **IFCT 2017 (Indian Food Composition Tables)**
- **Source**: https://github.com/stevenpur/food-nutrition-data
- **Content**: 1000+ Indian food items (Government of India data)
- **Columns**: Food name, Energy, Protein, Fat, Carbohydrate, Fiber

### 3. **Custom CSV Files**
- Support for any CSV with nutrition data
- Flexible column mapping

## 📥 Step-by-Step Integration

### Phase 1: Download Datasets

#### Option A: Kaggle Dataset
```bash
# Install Kaggle CLI (if not already installed)
pip install kaggle

# Configure Kaggle API (get API key from kaggle.com/account)
# Place kaggle.json in ~/.kaggle/

# Download the dataset
kaggle datasets download -d batthulavinay/indian-food-nutrition

# Extract
unzip indian-food-nutrition.zip
```

#### Option B: IFCT 2017 from GitHub
```bash
# Clone the repository
git clone https://github.com/stevenpur/food-nutrition-data.git

# CSV should be in: food-nutrition-data/ifct2017.csv
```

#### Option C: Manual Download
1. Visit the dataset URLs above
2. Download CSV files manually
3. Save to a convenient location

### Phase 2: Prepare CSV Files

Create the data directory:
```bash
mkdir -p assets/data/nutrition
```

Copy your CSV files:
```bash
# Example: Copy Kaggle dataset
cp ~/Downloads/indian_food_nutrition.csv assets/data/nutrition/

# Example: Copy IFCT 2017
cp ~/Downloads/ifct2017.csv assets/data/nutrition/
```

### Phase 3: Update pubspec.yaml

Ensure assets are configured (already done):
```yaml
flutter:
  assets:
    - assets/data/
    - assets/data/nutrition/  # Add this if not present
```

### Phase 4: Import Data (One-Time Setup)

Add to your `main.dart` initialization:

```dart
import 'utils/food_data_importer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... existing code ...
  
  // Initialize database
  final database = AppDatabase();
  await database.initializeDefaultData();
  
  // IMPORT DATASETS (run once, then comment out)
  final importer = FoodDataImporter(database);
  
  // Option 1: Import Kaggle data
  await importer.importKaggleIndianFood('assets/data/nutrition/indian_food_nutrition.csv');
  
  // Option 2: Import IFCT 2017
  await importer.importIFCT2017('assets/data/nutrition/ifct2017.csv');
  
  // Option 3: Import custom CSV
  await importer.importCustomCSV(
    'assets/data/nutrition/my_custom_foods.csv',
    nameColumn: 'FoodName',
    caloriesColumn: 'Calories',
    proteinColumn: 'Protein',
    carbsColumn: 'Carbs',
    fatColumn: 'Fat',
    fiberColumn: 'Fiber', // optional
  );
  
  // Check stats
  final stats = await importer.getImportStats();
  print('📊 Total foods in database: ${stats['total']}');
  print('📊 Categories: ${stats['categories']}');
  
  runApp(/* ... */);
}
```

### Phase 5: Run and Verify

```bash
# Get dependencies
flutter pub get

# Run the app (import happens on first launch)
flutter run

# Check console for import messages:
# 📥 Importing Kaggle Indian Food dataset...
# ✅ Imported 500 foods from Kaggle dataset
# 📊 Total foods in database: 543
```

### Phase 6: Clean Up

**IMPORTANT**: After successful import, comment out the import code:

```dart
// ALREADY IMPORTED - commented out to avoid duplicates
// await importer.importKaggleIndianFood('...');
// await importer.importIFCT2017('...');
```

## 📊 Expected CSV Formats

### Kaggle Indian Food Nutrition
```csv
Food,Calories,Protein,Carbs,Fat,Fiber,Serving_Size,Serving_Grams
Idli,78,2.0,16.0,0.4,0.8,2 pieces,80
Dosa,168,4.0,28.0,4.5,1.0,1 piece,100
```

### IFCT 2017
```csv
name,energy,protein,fat,carbohydrate,fiber
Rice (raw),345,6.8,0.5,78.2,0.2
Wheat flour,341,11.8,1.5,69.4,12.5
```

### Custom CSV (Flexible)
```csv
FoodName,Calories,Protein,Carbs,Fat
Samosa,260,4.0,28.0,15.0
Pakora,280,6.0,24.0,18.0
```

## 🔧 Advanced Usage

### Import with Progress Tracking

```dart
final importer = FoodDataImporter(database);
int total = 0;

// Import multiple sources
total += await importer.importKaggleIndianFood('...');
total += await importer.importIFCT2017('...');

print('✅ Total imported: $total foods');
```

### Custom Categorization

The importer automatically categorizes foods based on name keywords:
- Breakfast: idli, dosa, upma, poha, paratha
- Rice: rice, biryani, pulao
- Bread: roti, naan, chapati
- Snacks: samosa, pakora, vada
- Desserts: sweet, halwa, kheer, gulab jamun
- Beverages: tea, chai, coffee, lassi
- Side Dishes: raita, chutney, pickle

### Handling Duplicates

The importer uses `InsertMode.insertOrIgnore` to prevent duplicates.
Foods with the same name won't be imported twice.

## 📈 Database Growth

**Current (43 seed foods)**:
- North Indian: 7
- South Indian: 8
- Rice dishes: 5
- Snacks: 4
- Sweets: 4
- Others: 15

**After Kaggle Import (~500 foods)**:
- Comprehensive coverage of Indian cuisine
- Regional specialties
- Restaurant dishes
- Home-cooked meals

**After IFCT 2017 Import (~1000+ foods)**:
- Government-verified nutrition data
- Raw ingredients
- Cooked preparations
- Regional variations

**Total Potential: 1500+ foods** 🎉

## 🐛 Troubleshooting

### Import Error: File Not Found
```
Error: CSV file not found
```
**Solution**: Verify CSV file is in `assets/data/nutrition/` and pubspec.yaml includes the path.

### Import Error: Column Not Found
```
Error: Column 'Calories' not found
```
**Solution**: Check CSV headers match expected column names (case-sensitive).

### Duplicate Foods
Importer automatically skips duplicates. Check console:
```
⚠️ Error importing row: UNIQUE constraint failed
```

### Memory Issues (Large Datasets)
For very large CSV files (10,000+ rows), import in batches:
```dart
// Split CSV into smaller files
// Import one at a time
```

## 📱 Testing

### Verify Import
1. Open app
2. Go to Search screen
3. Should see many more foods in Popular Foods
4. Search for specific items (e.g., "biryani", "dal", "roti")
5. Verify nutrition data is accurate

### Check Database Size
```dart
final stats = await importer.getImportStats();
print('Total: ${stats['total']}'); // Should be 500-1500+
```

## 🔄 Re-importing Data

If you need to re-import (e.g., updated CSV):

1. Delete existing database:
```bash
# Android
adb shell rm /data/data/com.example.calorie_tracker/app_flutter/nutrisnap.sqlite

# iOS
# Delete app and reinstall
```

2. Uncomment import code in `main.dart`
3. Run app again

## 🌐 Additional Data Sources

### Open Food Facts API (Future)
- Barcode scanning for packaged foods
- API: https://world.openfoodfacts.org/api/v0/product/{barcode}.json
- Requires internet connection

### Anuvaad INDB (Cooked Meals)
- Source: https://anuvaad.co.in/
- Cooked meal database
- Restaurant menu items

## 📝 Best Practices

1. **One-time import**: Import datasets once during initial setup
2. **Comment after import**: Prevent duplicate imports on app restart
3. **Verify data quality**: Spot-check nutrition values for accuracy
4. **Regular updates**: Update CSV files periodically for new foods
5. **Backup database**: Keep a copy of enriched database

## 🎯 Next Steps

After successful import:
1. Test search functionality with enriched database
2. Verify all nutrition values are reasonable
3. Add more custom foods as needed
4. Consider adding barcode scanning (Open Food Facts API)
5. Implement meal suggestions based on available foods
