# Dataset Import - Quick Start Guide

## ✅ What's Been Set Up

Your NutriSnap app now has a complete infrastructure for importing Indian food nutrition data from CSV files:

1. ✅ CSV parser utility ([`lib/utils/csv_parser.dart`](lib/utils/csv_parser.dart))
2. ✅ Food data importer ([`lib/utils/food_data_importer.dart`](lib/utils/food_data_importer.dart))
3. ✅ Database import methods ([`lib/services/database_service.dart`](lib/services/database_service.dart))
4. ✅ Sample CSV with 50 Indian foods ([`assets/data/sample_indian_foods.csv`](assets/data/sample_indian_foods.csv))
5. ✅ Assets configured in [`pubspec.yaml`](pubspec.yaml)

## 🚀 How to Import the Sample Data (Test)

### Option 1: Automatic Import on First Launch

Uncomment line 100 in [`lib/services/database_service.dart`](lib/services/database_service.dart:100):

```dart
// Change this:
// await importFoodsFromCSV('assets/data/sample_indian_foods.csv');

// To this:
await importFoodsFromCSV('assets/data/sample_indian_foods.csv');
```

Then run the app:
```bash
flutter run
```

On first launch, it will automatically import all 50 foods from the sample CSV.

### Option 2: Manual Import via Settings Screen

You can add a "Import Foods" button in the settings screen that calls:

```dart
final database = ref.watch(databaseProvider);
final imported = await database.importFoodsFromCSV('assets/data/sample_indian_foods.csv');
print('✅ Imported $imported foods');
```

## 📊 Verify the Import Worked

1. **Open the Search screen** - You should now see 93 total foods (43 seed + 50 from CSV)
2. **Search for items** - Try searching for "Gulab Jamun", "Naan", "Lassi"
3. **Check the count** - Popular Foods section should show "93 foods available"

## 📥 Importing Larger Datasets

### Step 1: Download a Dataset

**Recommended sources:**
- **Kaggle Indian Food Nutrition**: https://www.kaggle.com/datasets/batthulavinay/indian-food-nutrition
- **IFCT 2017 (GitHub)**: https://github.com/stevenpur/food-nutrition-data

### Step 2: Place CSV in Project

```bash
# Example: Download and place Kaggle CSV
cp ~/Downloads/indian_food_nutrition.csv assets/data/
```

### Step 3: Import the Data

Update line 100 in [`database_service.dart`](lib/services/database_service.dart:100):

```dart
await importFoodsFromCSV('assets/data/indian_food_nutrition.csv');
```

### Step 4: Run the App

```bash
flutter run
```

Check the console for import progress:
```
📥 Importing Kaggle Indian Food dataset...
✅ Imported 523 foods from Kaggle dataset
📊 Total foods in database: 566
```

## 🔧 Advanced: Custom CSV Format

If your CSV has different column names, use the custom importer:

```dart
final importer = FoodDataImporter(database);
await importer.importCustomCSV(
  'assets/data/my_foods.csv',
  nameColumn: 'FoodName',
  caloriesColumn: 'Energy',
  proteinColumn: 'Protein_g',
  carbsColumn: 'Carbohydrates_g',
  fatColumn: 'Fat_g',
  fiberColumn: 'Fiber_g',  // optional
);
```

## 📝 CSV Format Requirements

Your CSV must have these columns (names can vary):

**Required:**
- Food name (e.g., "Food", "name", "FoodName")
- Calories (e.g., "Calories", "energy", "Energy_kcal")
- Protein in grams (e.g., "Protein", "protein_g")
- Carbs in grams (e.g., "Carbs", "carbohydrate")
- Fat in grams (e.g., "Fat", "fat_g")

**Optional:**
- Fiber (defaults to 0.0 if missing)
- Serving_Size (defaults to "100g")
- Serving_Grams (defaults to 100)

**Example CSV:**
```csv
Food,Calories,Protein,Carbs,Fat,Fiber,Serving_Size,Serving_Grams
Idli,78,2.0,16.0,0.4,0.8,2 pieces,80
Dosa,168,4.0,28.0,4.5,1.0,1 piece,100
```

## ⚠️ Important Notes

### 1. One-Time Import
After importing, **comment out** the import line to prevent duplicate imports:

```dart
// ALREADY IMPORTED - commented to avoid duplicates
// await importFoodsFromCSV('assets/data/sample_indian_foods.csv');
```

### 2. Handling Duplicates
The importer uses `InsertMode.insertOrIgnore`, so:
- Foods with the same name won't be imported twice
- You'll see warnings in console: `⚠️ Error importing row`
- This is normal and expected

### 3. Database Size
- Sample CSV (50 foods): ~5 KB
- Kaggle dataset (500 foods): ~50 KB  
- IFCT 2017 (1000+ foods): ~100 KB
- No performance impact on SQLite

### 4. Clearing Data
To re-import from scratch:

**Android:**
```bash
flutter run --clear-cache
# Then uninstall and reinstall the app
```

**iOS:**
```bash
# Delete app from simulator/device
# Reinstall
```

## 🎯 Current Database State

**Before import:**
- 43 seed foods (North Indian, South Indian, etc.)

**After sample CSV import:**
- 93 total foods (43 + 50)

**After Kaggle import:**
- 500+ foods

**After IFCT 2017 import:**
- 1500+ foods 🎉

## 🧪 Testing Checklist

- [ ] CSV file exists in `assets/data/`
- [ ] Uncommented import line in database_service.dart
- [ ] Run `flutter pub get`
- [ ] Run `flutter run`
- [ ] Check console for "✅ Imported X foods"
- [ ] Open Search screen
- [ ] Verify food count increased
- [ ] Search for a few foods from CSV
- [ ] Comment out import line after success

## 📚 Related Files

- **CSV Parser**: [`lib/utils/csv_parser.dart`](lib/utils/csv_parser.dart)
- **Food Importer**: [`lib/utils/food_data_importer.dart`](lib/utils/food_data_importer.dart)
- **Database Service**: [`lib/services/database_service.dart`](lib/services/database_service.dart)
- **Sample CSV**: [`assets/data/sample_indian_foods.csv`](assets/data/sample_indian_foods.csv)
- **Detailed Guide**: [`README_DATASET_INTEGRATION.md`](README_DATASET_INTEGRATION.md)

## 🐛 Troubleshooting

### Error: CSV file not found
```
FileSystemException: Cannot open file
```
**Solution**: Verify file is in `assets/data/` and run `flutter pub get`

### Error: Column not found
```
Error importing row: Column 'Calories' not found
```
**Solution**: Check CSV headers match expected names (case-sensitive)

### No foods imported
```
✅ Imported 0 foods
```
**Solution**: CSV may be empty or have formatting issues. Check first few lines.

### App crashes on launch
```
Unhandled Exception: FormatException
```
**Solution**: CSV has invalid data (e.g., text in numeric column). Validate CSV format.

## 💡 Pro Tips

1. **Test with sample first** - Verify import works with the included `sample_indian_foods.csv` before downloading large datasets

2. **Check console logs** - Monitor import progress and catch errors early

3. **Spot-check data** - After import, search for a few random foods to verify accuracy

4. **Keep backups** - Save a copy of your enriched database after successful imports

5. **Incremental imports** - Import datasets one at a time, verify each before adding more

## 🎉 Success!

Once imported, your users can:
- Search from 100s or 1000s of Indian foods
- Get accurate nutrition data
- Enjoy lazy loading and infinite scroll
- Track their meals with comprehensive food database

Happy tracking! 🍛📊
