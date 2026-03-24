import 'dart:typed_data';
import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// ML Kit Food Detection Service
/// Uses on-device image labeling to quickly determine if an image contains food
/// before making expensive LLM API calls
class MLKitFoodDetector {
  static const double _confidenceThreshold = 0.6; // 60% threshold for better food detection

  /// Food-related label keywords that indicate the presence of food
  static const Set<String> _foodLabels = {
    // Direct food labels
    'food',
    'meal',
    'dish',
    'cuisine',
    'ingredient',
    
    // Food categories
    'fruit',
    'vegetable',
    'meat',
    'seafood',
    'dairy',
    'baked goods',
    'dessert',
    'snack',
    'fast food',
    'breakfast',
    'lunch',
    'dinner',
    
    // Food context
    'plate',
    'bowl',
    'tableware',
    'recipe',
    'cooking',
    'restaurant',
    
    // Specific food types
    'bread',
    'rice',
    'pasta',
    'salad',
    'soup',
    'sandwich',
    'pizza',
    'burger',
    'sushi',
    'noodle',
  };

  late ImageLabeler _imageLabeler;

  MLKitFoodDetector() {
    _imageLabeler = ImageLabeler(
      options: ImageLabelerOptions(
        confidenceThreshold: _confidenceThreshold,
      ),
    );
  }

  /// Analyzes image bytes to determine if they contain food
  /// Returns true if food is detected with sufficient confidence
  Future<bool> isFoodImage(Uint8List imageBytes) async {
    File? tempFile;
    try {
      // Write bytes to temporary file (ML Kit works better with file paths for JPEG)
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      tempFile = File(path.join(tempDir.path, 'mlkit_temp_$timestamp.jpg'));
      await tempFile.writeAsBytes(imageBytes);

      // Create InputImage from file path
      final inputImage = InputImage.fromFilePath(tempFile.path);

      // Get image labels
      final labels = await _imageLabeler.processImage(inputImage);

      // Debug: Print labels to see what ML Kit detects
      print('ML Kit detected ${labels.length} labels:');
      for (final label in labels) {
        print('  - ${label.label}: ${label.confidence}');
      }

      // Check if any label matches food categories with confidence > threshold
      for (final label in labels) {
        final labelText = label.label.toLowerCase();
        final confidence = label.confidence;

        // Check if label matches any food-related keyword
        for (final foodKeyword in _foodLabels) {
          if (labelText.contains(foodKeyword)) {
            print('  ✓ Food match: "$labelText" contains "$foodKeyword" (confidence: $confidence)');
            if (confidence >= _confidenceThreshold) {
              // Food detected with high confidence
              return true;
            }
          }
        }
      }

      // No food labels found with sufficient confidence
      print('  ✗ No food detected above threshold $_confidenceThreshold');
      return false;
    } catch (e) {
      // If ML Kit fails, default to allowing the image
      // (better to have false positive than block legitimate food)
      print('ML Kit error: $e - defaulting to allowing image');
      return true;
    } finally {
      // Clean up temporary file
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (e) {
          print('Failed to delete temp file: $e');
        }
      }
    }
  }

  /// Clean up resources
  void dispose() {
    _imageLabeler.close();
  }
}

/// Provider for ML Kit food detector
final mlKitFoodDetectorProvider = Provider<MLKitFoodDetector>((ref) {
  final detector = MLKitFoodDetector();
  
  // Dispose when provider is disposed
  ref.onDispose(() {
    detector.dispose();
  });
  
  return detector;
});
