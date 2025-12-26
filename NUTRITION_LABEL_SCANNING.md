# Nutrition Label Scanning Feature

## Overview

Kaloree now supports scanning nutrition facts labels from packaged foods! This feature uses ML Kit Text Recognition (OCR) to extract nutritional information directly from food packaging.

## How It Works

### Processing Flow

When you take a picture with the camera, Kaloree follows this intelligent decision tree:

```
1. Check API Key Configuration
   ↓
2. ML Kit Food Detection
   ├─ IS FOOD → Send to AI for detailed analysis ✨
   │
   └─ NOT FOOD → Check if Nutrition Label 🏷️
       ├─ IS NUTRITION LABEL → Extract nutrition info via OCR 📊
       │   └─ Navigate to meal entry screen with data
       │
       └─ NOT NUTRITION LABEL → Show "Not valid image" error ❌
```

### What Gets Extracted

The nutrition label scanner attempts to extract:

- **Product Name**: Identified from text before nutrition facts section
- **Serving Size**: E.g., "1 serving (100g)"
- **Calories**: Primary energy value
- **Protein**: In grams
- **Carbohydrates**: Total carbs in grams
- **Fat**: Total fat in grams
- **Fiber**: Dietary fiber in grams

## Supported Label Formats

The scanner works best with standard nutrition facts labels that include:

- Clear "Nutrition Facts" or "Nutritional Information" heading
- Serving size information
- Calorie count (in kcal or cal)
- Macronutrient breakdown (protein, carbs, fat)

### Examples of Supported Formats

✅ **Indian FSSAI Labels**
- "Nutrition Information per 100g"
- Energy, Protein, Carbohydrates, Fat

✅ **US Nutrition Facts**
- "Nutrition Facts"
- Serving Size, Calories, Total Fat, Protein, etc.

✅ **European Labels**
- "Nutritional Information"
- Per 100g/100ml format

## Usage Instructions

### For Users

1. **Open Camera**: Launch Kaloree
2. **Point at Nutrition Label**: Focus on the nutrition facts table
3. **Take Picture**: Click the camera button
4. **Review Preview**: Check the captured image
5. **Continue**: The app will:
   - First check if it's a meal (sends to AI)
   - If not a meal, check if it's a nutrition label
   - Extract nutrition data automatically
6. **Edit if Needed**: Review and adjust values in the meal entry screen

### Tips for Best Results

📸 **Photography Tips**:
- Ensure good lighting
- Keep label flat and clearly visible
- Center the nutrition facts table in frame
- Avoid reflections or shadows
- Hold phone steady

🎯 **Label Requirements**:
- Text should be clear and legible
- All nutrition values visible
- Standard format (not handwritten)

## Technical Implementation

### Components

1. **ML Kit Text Recognition** (`google_mlkit_text_recognition`)
   - On-device OCR
   - No internet required for text extraction
   - Privacy-focused (no data sent to servers)

2. **Nutrition Label Scanner Service** ([`lib/services/nutrition_label_scanner.dart`](lib/services/nutrition_label_scanner.dart))
   - Keyword detection for nutrition labels
   - Pattern matching for nutritional values
   - Intelligent parsing of OCR text

3. **Updated Camera Flow** ([`lib/features/camera/camera_screen.dart`](lib/features/camera/camera_screen.dart))
   - Sequential checking: food → nutrition label → error
   - Seamless integration with existing AI analysis

### Detection Logic

The scanner identifies nutrition labels by looking for:

**Keywords** (needs at least 3):
- "nutrition facts"
- "nutritional information"
- "serving size"
- "calories"
- "protein"
- "carbohydrate"
- "total fat"
- "energy"
- "per 100g/per 100ml"

**Numerical Patterns**:
- "250 kcal" or "250 cal"
- "10g" (grams)
- "15mg" (milligrams)
- "20%" (daily value percentages)

### Parsing Strategy

The service uses multiple regex patterns to extract values:

```dart
// Example patterns
calories:  /calories:\s*(\d+)/i
protein:   /protein:\s*(\d+\.?\d*)\s*g/i
carbs:     /carbohydrate:\s*(\d+\.?\d*)\s*g/i
fat:       /fat:\s*(\d+\.?\d*)\s*g/i
```

## Privacy & Security

✅ **On-Device Processing**: All OCR happens locally
✅ **No Image Storage**: Images processed in memory only
✅ **No Cloud Upload**: Nutrition data extraction is 100% offline
✅ **Minimal Permissions**: Only camera access required

## Limitations

⚠️ **Current Limitations**:

1. **OCR Accuracy**: Depends on image quality and text clarity
2. **Format Variations**: Some custom label formats may not parse correctly
3. **Handwritten Labels**: Not supported
4. **Damaged Labels**: Torn or worn labels may not scan properly
5. **Language Support**: Optimized for English labels

## Fallback Options

If nutrition label scanning fails:

1. **Manual Entry**: Use the search function to find similar foods
2. **Retry**: Take another picture with better lighting/angle
3. **Edit Values**: After extraction, manually adjust any incorrect values

## Error Handling

The app provides clear feedback for different scenarios:

- **✅ Success**: Navigates to meal entry with extracted data
- **⚠️ Partial Data**: Fills in what it found, you can complete the rest
- **❌ Failed**: Shows error message with option to retry or enter manually

## Future Enhancements

Planned improvements for nutrition label scanning:

- [ ] Multi-language support (Hindi, regional Indian languages)
- [ ] Barcode scanning integration
- [ ] Product database lookup
- [ ] Batch scanning (multiple products)
- [ ] Improved accuracy for Indian regional labels
- [ ] Support for more label formats worldwide

## Testing

### Test Cases

1. **Standard FSSAI Label**: Should extract all fields correctly
2. **US Nutrition Facts**: Should parse calories and macros
3. **Partial Label**: Should extract available data
4. **Non-Label Text**: Should reject and show error
5. **Food Image**: Should send to AI instead of OCR

### Debug Mode

The scanner includes extensive logging:

```
🔍 OCR Text extracted: [first 200 chars]
📊 Has nutrition keywords: true/false
📊 Has nutritional values: true/false
🏷️ Nutrition label detected: true/false
📝 Full OCR text: [complete text]
✅ Parsed nutrition data: {calories, protein, ...}
```

Check console output for detailed scanning information.

## Code Examples

### Using the Scanner Directly

```dart
final scanner = ref.read(nutritionLabelScannerProvider);

// Check if image is a nutrition label
bool isLabel = await scanner.isNutritionLabel(imageBytes);

// Extract nutrition information
MealAnalysis? analysis = await scanner.extractNutritionInfo(imageBytes);

if (analysis != null) {
  // Use the extracted data
  print('Calories: ${analysis.items.first.calories}');
}
```

## Support

If you encounter issues with nutrition label scanning:

1. Check image quality and lighting
2. Ensure label is in English
3. Try different angles/positions
4. Use manual entry as fallback
5. Report persistent issues with example images

## Dependencies

- **google_mlkit_text_recognition**: ^0.13.0
- **google_mlkit_image_labeling**: ^0.12.0 (existing)

Both are on-device ML Kit plugins with no server dependencies.

---

**Happy Scanning! 📸🏷️**
