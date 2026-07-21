import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// OnDeviceAIService - Flutter Platform Channel Bridge
///
/// Communicates with the native RunAnywhere VLM plugin for on-device
/// food image analysis. All processing happens locally on the device.
///
/// Features:
/// - On-device VLM inference using SmolVLM-256M
/// - No network required for analysis
/// - Complete privacy - images never leave the device
/// - ~3-5 second inference time on modern devices
class OnDeviceAIService {
  static const MethodChannel _channel = MethodChannel('com.kaloree.app/vlm');

  static OnDeviceAIService? _instance;

  /// Singleton instance
  static OnDeviceAIService get instance {
    _instance ??= OnDeviceAIService._();
    return _instance!;
  }

  OnDeviceAIService._();

  bool _isInitialized = false;
  bool _isInitializing = false;

  /// Whether the on-device AI is available on this platform
  bool get isAvailable => Platform.isAndroid;

  /// Whether the model is initialized and ready for inference
  bool get isReady => _isInitialized;

  /// Initialize the on-device VLM model.
  ///
  /// This should be called early in the app lifecycle (e.g., main.dart)
  /// to pre-load the model. Loading takes ~2-5 seconds.
  ///
  /// Returns true if initialization was successful.
  Future<bool> initialize() async {
    if (!isAvailable) {
      debugPrint('OnDeviceAI: Not available on this platform');
      return false;
    }

    if (_isInitialized) {
      debugPrint('OnDeviceAI: Already initialized');
      return true;
    }

    if (_isInitializing) {
      debugPrint('OnDeviceAI: Initialization already in progress');
      // Wait for ongoing initialization
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _isInitialized;
    }

    _isInitializing = true;

    try {
      debugPrint('OnDeviceAI: Initializing VLM model...');
      final startTime = DateTime.now();

      final result = await _channel.invokeMethod<Map>('initialize');

      final duration = DateTime.now().difference(startTime);
      debugPrint('OnDeviceAI: Initialization completed in ${duration.inMilliseconds}ms');

      if (result != null && result['success'] == true) {
        _isInitialized = true;
        debugPrint('OnDeviceAI: ${result['message']}');
        return true;
      } else {
        debugPrint('OnDeviceAI: Initialization failed');
        return false;
      }
    } on PlatformException catch (e) {
      debugPrint('OnDeviceAI: Platform error during initialization: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('OnDeviceAI: Error during initialization: $e');
      return false;
    } finally {
      _isInitializing = false;
    }
  }

  /// Analyze a food image and return nutritional information.
  ///
  /// [imageBytes] - Raw image bytes (JPEG or PNG)
  ///
  /// Returns a [FoodAnalysisResult] with nutritional data, or throws
  /// an exception if analysis fails.
  Future<FoodAnalysisResult> analyzeFood(Uint8List imageBytes) async {
    if (!isAvailable) {
      throw PlatformException(
        code: 'UNAVAILABLE',
        message: 'On-device AI is not available on this platform',
      );
    }

    if (!_isInitialized) {
      // Try to initialize if not already done
      final initialized = await initialize();
      if (!initialized) {
        throw PlatformException(
          code: 'NOT_INITIALIZED',
          message: 'Failed to initialize on-device AI model',
        );
      }
    }

    try {
      debugPrint('OnDeviceAI: Analyzing food image (${imageBytes.length} bytes)...');
      final startTime = DateTime.now();

      final result = await _channel.invokeMethod<Map>('analyzeFood', {
        'imageBytes': imageBytes,
      });

      final duration = DateTime.now().difference(startTime);
      debugPrint('OnDeviceAI: Analysis completed in ${duration.inMilliseconds}ms');

      if (result == null) {
        throw PlatformException(
          code: 'NULL_RESPONSE',
          message: 'Received null response from VLM',
        );
      }

      if (result['success'] != true) {
        throw PlatformException(
          code: 'ANALYSIS_FAILED',
          message: result['error']?.toString() ?? 'Analysis failed',
        );
      }

      final jsonData = result['data'] as String;
      return FoodAnalysisResult.fromJson(jsonData, duration);
    } on PlatformException {
      rethrow;
    } catch (e) {
      throw PlatformException(
        code: 'ANALYSIS_ERROR',
        message: 'Error during food analysis: $e',
      );
    }
  }

  /// Check if the model is ready for inference.
  Future<bool> checkReady() async {
    if (!isAvailable) return false;

    try {
      final result = await _channel.invokeMethod<bool>('isReady');
      _isInitialized = result ?? false;
      return _isInitialized;
    } catch (e) {
      debugPrint('OnDeviceAI: Error checking ready state: $e');
      return false;
    }
  }

  /// Get information about the loaded model.
  Future<Map<String, dynamic>?> getModelInfo() async {
    if (!isAvailable) return null;

    try {
      final result = await _channel.invokeMethod<Map>('getModelInfo');
      return result?.cast<String, dynamic>();
    } catch (e) {
      debugPrint('OnDeviceAI: Error getting model info: $e');
      return null;
    }
  }

  /// Release the model from memory.
  ///
  /// Call this when the app goes to background or is being closed
  /// to free up memory.
  Future<void> release() async {
    if (!isAvailable || !_isInitialized) return;

    try {
      await _channel.invokeMethod('release');
      _isInitialized = false;
      debugPrint('OnDeviceAI: Model released');
    } catch (e) {
      debugPrint('OnDeviceAI: Error releasing model: $e');
    }
  }
}

/// Result of on-device food analysis.
class FoodAnalysisResult {
  final String foodName;
  final double confidence;
  final String servingSize;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double sugarG;
  final int sodiumMg;
  final List<String> ingredients;
  final List<String> healthNotes;
  final bool isHealthy;
  final Duration inferenceTime;
  final bool isOnDevice;
  final String rawJson;

  FoodAnalysisResult({
    required this.foodName,
    required this.confidence,
    required this.servingSize,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
    required this.sugarG,
    required this.sodiumMg,
    required this.ingredients,
    required this.healthNotes,
    required this.isHealthy,
    required this.inferenceTime,
    required this.isOnDevice,
    required this.rawJson,
  });

  factory FoodAnalysisResult.fromJson(String json, Duration inferenceTime) {
    // Parse JSON manually to handle potential malformed responses
    final Map<String, dynamic> data;
    try {
      // Using a simple JSON parser
      data = _parseJson(json);
    } catch (e) {
      // Return a fallback result if parsing fails
      return FoodAnalysisResult(
        foodName: 'Food item',
        confidence: 0.5,
        servingSize: '1 serving',
        calories: 250,
        proteinG: 10.0,
        carbsG: 30.0,
        fatG: 10.0,
        fiberG: 2.0,
        sugarG: 5.0,
        sodiumMg: 300,
        ingredients: [],
        healthNotes: ['Unable to fully analyze image'],
        isHealthy: true,
        inferenceTime: inferenceTime,
        isOnDevice: true,
        rawJson: json,
      );
    }

    return FoodAnalysisResult(
      foodName: data['food_name']?.toString() ?? 'Unknown food',
      confidence: (data['confidence'] as num?)?.toDouble() ?? 0.5,
      servingSize: data['serving_size']?.toString() ?? '1 serving',
      calories: (data['calories'] as num?)?.toInt() ?? 0,
      proteinG: (data['protein_g'] as num?)?.toDouble() ?? 0.0,
      carbsG: (data['carbs_g'] as num?)?.toDouble() ?? 0.0,
      fatG: (data['fat_g'] as num?)?.toDouble() ?? 0.0,
      fiberG: (data['fiber_g'] as num?)?.toDouble() ?? 0.0,
      sugarG: (data['sugar_g'] as num?)?.toDouble() ?? 0.0,
      sodiumMg: (data['sodium_mg'] as num?)?.toInt() ?? 0,
      ingredients: _parseStringList(data['ingredients']),
      healthNotes: _parseStringList(data['health_notes']),
      isHealthy: data['is_healthy'] as bool? ?? true,
      inferenceTime: inferenceTime,
      isOnDevice: true,
      rawJson: json,
    );
  }

  static Map<String, dynamic> _parseJson(String jsonString) {
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Convert to a format compatible with the existing MealAnalysis model.
  Map<String, dynamic> toMealAnalysisMap() {
    return {
      'meal_name': foodName,
      'calories': calories,
      'protein': proteinG,
      'carbs': carbsG,
      'fat': fatG,
      'fiber': fiberG,
      'sugar': sugarG,
      'sodium': sodiumMg,
      'serving_size': servingSize,
      'confidence': confidence,
      'ingredients': ingredients,
      'health_notes': healthNotes,
      'is_healthy': isHealthy,
      'inference_source': 'on_device',
      'inference_time_ms': inferenceTime.inMilliseconds,
    };
  }

  @override
  String toString() {
    return 'FoodAnalysisResult(foodName: $foodName, calories: $calories, '
        'protein: ${proteinG}g, carbs: ${carbsG}g, fat: ${fatG}g, '
        'inferenceTime: ${inferenceTime.inMilliseconds}ms, onDevice: $isOnDevice)';
  }
}
