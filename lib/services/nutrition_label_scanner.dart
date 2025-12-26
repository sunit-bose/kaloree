import 'dart:typed_data';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import '../models/meal_analysis.dart';

/// Nutrition Label Scanner Service
/// Uses ML Kit Text Recognition with coordinate-based parsing for accurate table extraction
class NutritionLabelScanner {
  final TextRecognizer _textRecognizer = TextRecognizer();

  /// Check if image contains a nutrition facts table
  Future<bool> isNutritionLabel(Uint8List imageBytes) async {
    File? tempFile;
    try {
      final tempDir = await getTemporaryDirectory();
      tempFile = File('${tempDir.path}/temp_nutrition_scan_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(imageBytes);

      final inputImage = InputImage.fromFile(tempFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      final String text = recognizedText.text.toLowerCase();

      final hasNutritionKeywords = _containsNutritionKeywords(text);
      final hasNutritionalValues = _containsNutritionalValues(text);

      return hasNutritionKeywords && hasNutritionalValues;
    } catch (e) {
      print('❌ Error in nutrition label detection: $e');
      return false;
    } finally {
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (e) {
          print('Warning: Could not delete temp file: $e');
        }
      }
    }
  }

  /// Extract nutrition information using coordinate-based parsing
  Future<MealAnalysis?> extractNutritionInfo(Uint8List imageBytes) async {
    File? tempFile;
    try {
      final tempDir = await getTemporaryDirectory();
      tempFile = File('${tempDir.path}/temp_nutrition_extract_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(imageBytes);

      final inputImage = InputImage.fromFile(tempFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      print('📝 OCR extracted ${recognizedText.blocks.length} text blocks');

      // Parse using coordinates
      final nutritionData = _parseWithCoordinates(recognizedText);

      if (nutritionData == null) {
        print('⚠️ Coordinate parsing failed');
        return null;
      }

      final foodItem = FoodItem(
        name: nutritionData['productName'] ?? 'Packaged Food Product',
        portion: nutritionData['servingSize'] ?? '100g',
        portionGrams: nutritionData['servingGrams'] ?? 100,
        calories: nutritionData['calories'] ?? 0,
        protein: nutritionData['protein'] ?? 0.0,
        carbs: nutritionData['carbs'] ?? 0.0,
        fat: nutritionData['fat'] ?? 0.0,
        fiber: nutritionData['fiber'] ?? 0.0,
        isEdited: false,
      );

      return MealAnalysis(
        items: [foodItem],
        confidence: 'high',
        source: 'nutrition_label',
      );
    } catch (e) {
      print('❌ Error extracting nutrition info: $e');
      return null;
    } finally {
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (e) {
          print('Warning: Could not delete temp file: $e');
        }
      }
    }
  }

  /// Parse nutrition data using coordinate-based matching
  Map<String, dynamic>? _parseWithCoordinates(RecognizedText recognizedText) {
    final nutritionData = <String, dynamic>{};

    // Extract all text elements with coordinates
    final elements = <Map<String, dynamic>>[];
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          final box = element.boundingBox;
          elements.add({
            'text': element.text,
            'x': box.left.toDouble(),
            'y': box.top.toDouble(),
            'width': box.width.toDouble(),
            'height': box.height.toDouble(),
          });
        }
      }
    }

    print('📍 Found ${elements.length} text elements');

    // Check if this is a multi-column label
    if (_isMultiColumnLabel(elements)) {
      print('⚠️ Multi-column nutrition label detected');
      print('📋 Currently only single-column labels are supported');
      throw Exception('MULTI_COLUMN_NOT_SUPPORTED');
    }

    print('✅ Single-column label detected, proceeding with parsing');
    final usedValues = <double>{}; // Track which values we've already assigned

    // Nutrient name aliases and their standardized keys
    final nutrientMap = {
      // Calories/Energy
      'energy': 'calories',
      'calories': 'calories',
      // Macronutrients (all in grams)
      'carbohydrates': 'carbs',
      'carbohydrate': 'carbs',
      'total carbohydrate': 'carbs',
      'protein': 'protein',
      'total fat': 'fat',
      'fat': 'fat',
      'dietary fibre': 'fiber',
      'dietary fiber': 'fiber',
      'fibre': 'fiber',
      'fiber': 'fiber',
    };

    // Find each nutrient and its value
    for (final entry in nutrientMap.entries) {
      final searchTerm = entry.key;
      final dataKey = entry.value;

      // Skip if we already found this nutrient
      if (nutritionData.containsKey(dataKey)) continue;

      // Find the nutrient name element
      final nutrientElement = _findNutrientElement(elements, searchTerm);
      if (nutrientElement != null) {
        final y = nutrientElement['y'] as double;
        print('📍 Found "$searchTerm" at Y=$y');

        // Find numeric value near this nutrient
        double? value;
        if (dataKey == 'calories') {
          value = _findNumericValueNearby(elements, y, usedValues: usedValues);
          // Calories are sometimes written without decimal (OCR error)
          if (value != null && value > 10000) {
            value = value / 100;
          }
        } else {
          // All other nutrients are in grams
          value = _findNumericValueNearby(elements, y, usedValues: usedValues);
        }
        
        if (value != null) {
          usedValues.add(value); // Mark this value as used
        }

        if (value != null) {
          if (dataKey == 'calories') {
            nutritionData[dataKey] = value.round();
          } else {
            nutritionData[dataKey] = value;
          }
          print('✅ Matched "$searchTerm" → $value ${dataKey == "calories" ? "kcal" : "g"}');
        } else {
          print('❌ No value found for "$searchTerm"');
        }
      }
    }

    // Set serving size
    nutritionData['servingSize'] = '100g';
    nutritionData['servingGrams'] = 100;

    // Validate we have at least calories
    if (nutritionData['calories'] == null) {
      print('⚠️ Could not extract calories');
      return null;
    }

    // Set defaults for missing values
    nutritionData['protein'] ??= 0.0;
    nutritionData['carbs'] ??= 0.0;
    nutritionData['fat'] ??= 0.0;
    nutritionData['fiber'] ??= 0.0;

    print('✅ Final parsed data: $nutritionData');
    return nutritionData;
  }

  /// Find element containing the nutrient name
  Map<String, dynamic>? _findNutrientElement(List<Map<String, dynamic>> elements, String nutrient) {
    for (final element in elements) {
      final text = element['text'].toString().toLowerCase();
      // Match if text equals nutrient or contains it (for multi-word nutrients)
      if (text == nutrient || (text.contains(nutrient) && text.length < nutrient.length + 5)) {
        return element;
      }
    }
    return null;
  }

  /// Check if label has multi-column structure (PER SERVING + PER 100G)
  bool _isMultiColumnLabel(List<Map<String, dynamic>> elements) {
    // Look for "PER SERVING" or "SERVING SIZE" indicators
    bool hasServingColumn = false;
    bool hasPer100Column = false;
    
    for (final element in elements) {
      final text = element['text'].toString().toLowerCase();
      if (text.contains('serving') && (text.contains('per') || text.contains('size'))) {
        hasServingColumn = true;
      }
      if (text.contains('per') && text.contains('100')) {
        hasPer100Column = true;
      }
    }
    
    return hasServingColumn && hasPer100Column;
  }

  /// Find a numeric value near the given Y coordinate
  /// Handles case where number and unit are separate ML Kit elements
  /// Tracks used values to prevent reusing the same number for multiple nutrients
  double? _findNumericValueNearby(
    List<Map<String, dynamic>> elements,
    double targetY, {
    Set<double>? usedValues,
  }) {
    // Look for standalone numbers (ML Kit splits "46.42 g" into "46.42" and "g")
    final numberPattern = RegExp(r'^\d+\.?\d*$');
    
    final candidates = <Map<String, dynamic>>[];
    for (final element in elements) {
      final y = element['y'] as double;
      final x = element['x'] as double;
      
      // Check vertical alignment
      if ((y - targetY).abs() <= 80) {
        final text = element['text'].toString().trim();
        final match = numberPattern.firstMatch(text);
        if (match != null) {
          try {
            final value = double.parse(text);
            
            // Skip if this value was already used for another nutrient
            if (usedValues != null && usedValues.contains(value)) {
              continue;
            }
            
            // Sanity check: nutritional values typically 0-1000 (for calories) or 0-200 (for grams)
            if (value >= 0 && value <= 1000) {
              candidates.add({
                'value': value,
                'distance': (y - targetY).abs(),
                'y': y,
                'x': x,
                'text': text,
              });
            }
          } catch (e) {
            // Skip invalid numbers
          }
        }
      }
    }

    if (candidates.isEmpty) return null;

    // Sort by vertical distance and return closest
    candidates.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    final closest = candidates.first;
    print('  💎 Found number: ${closest['text']} at Y=${(closest['y'] as double).toInt()}, X=${(closest['x'] as double).toInt()}, dist=${(closest['distance'] as double).toInt()}px');
    return closest['value'] as double;
  }

  /// Check if text contains nutrition label keywords
  bool _containsNutritionKeywords(String text) {
    final keywords = [
      'nutrition facts',
      'nutritional information',
      'calories',
      'total fat',
      'carbohydrate',
      'protein',
      'energy',
      'per 100g',
      'per 100ml',
    ];

    int matchCount = 0;
    for (final keyword in keywords) {
      if (text.contains(keyword)) matchCount++;
    }

    return matchCount >= 3;
  }

  /// Check if text contains numerical nutritional values
  bool _containsNutritionalValues(String text) {
    final patterns = [
      RegExp(r'\d+\s*(kcal|cal|calories)', caseSensitive: false),
      RegExp(r'\d+\.?\d*\s*g', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      if (pattern.hasMatch(text)) return true;
    }

    return false;
  }

  /// Dispose resources
  void dispose() {
    _textRecognizer.close();
  }
}

/// Provider for nutrition label scanner
final nutritionLabelScannerProvider = Provider<NutritionLabelScanner>((ref) {
  return NutritionLabelScanner();
});
