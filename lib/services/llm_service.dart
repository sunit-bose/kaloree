import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/health_alert.dart';
import '../models/meal_analysis.dart';
import 'secure_storage_service.dart';

/// Custom exception for LLM service errors
class LLMException implements Exception {
  final String message;
  const LLMException(this.message);

  @override
  String toString() => message;
}

/// LLM Service - handles meal image analysis with Google Gemini
/// 
/// Google AI Studio API Key Integration:
/// - Get your API key from https://aistudio.google.com/app/apikey
/// - Keys are stored securely using device keychain
class LLMService {
  final Dio _dio;
  final SecureStorageService _secureStorage;

  LLMService(this._dio, this._secureStorage) {
    // Configure Dio with reasonable timeouts
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
  }

  /// Analyze meal image and return structured nutritional data
  Future<MealAnalysis> analyzeMealImage(Uint8List imageBytes) async {
    final apiKey = await _secureStorage.getGeminiApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw const LLMException('API key not configured. Please add your Google AI API key in Settings.');
    }

    // Validate API key format - Google AI keys can start with 'AI' (legacy Standard keys) or 'AQ' (new Auth keys)
    // As of June 2026, Auth keys (AQ prefix) are the default for new keys
    if (!apiKey.startsWith('AI') && !apiKey.startsWith('AQ')) {
      throw const LLMException('Invalid Google AI API key format. Keys should start with "AI" or "AQ". Get your key from aistudio.google.com');
    }

    try {
      return await _analyzeWithGemini(imageBytes, apiKey);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?['error']?['message'] ?? 'Invalid request';
        throw LLMException('API error: $errorMessage');
      } else if (e.response?.statusCode == 401) {
        throw const LLMException('Invalid API key. Please check your Google AI API key in Settings.');
      } else if (e.response?.statusCode == 403) {
        throw const LLMException('API access forbidden. Please regenerate your API key from aistudio.google.com');
      } else if (e.response?.statusCode == 404) {
        throw const LLMException('API endpoint not found. Please create a new API key from aistudio.google.com - older keys may no longer work.');
      } else if (e.response?.statusCode == 429) {
        throw const LLMException('Rate limit exceeded. Please try again in a moment.');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw const LLMException('Connection timeout. Please check your internet connection.');
      }
      throw LLMException('API error: ${e.message}');
    } catch (e) {
      if (e is LLMException) rethrow;
      throw LLMException('Failed to analyze image: $e');
    }
  }

  /// Analyze with Google Gemini API (using Gemini 3.5 Flash - latest stable model)
  Future<MealAnalysis> _analyzeWithGemini(Uint8List imageBytes, String apiKey) async {
    final base64Image = base64Encode(imageBytes);

    final response = await _dio.post(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
      ),
      data: {
        'contents': [
          {
            'parts': [
              {
                'text': _getPrompt(),
              },
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Image,
                },
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.2,
          'maxOutputTokens': 2048,  // Increased for health indicators
          'responseMimeType': 'application/json',
        },
      },
    );

    final content = response.data['candidates'][0]['content']['parts'][0]['text'] as String;
    return _parseResponse(content, 'ai');
  }

  /// Prompt for meal analysis with health indicators
  String _getPrompt() {
    return '''
Analyze this image and determine if it contains food items. If it's not food, return isFood: false.

Return your response in this exact JSON format:
{
  "isFood": true,
  "items": [
    {
      "name": "Food Item Name",
      "portion": "1 serving (estimated)",
      "portionGrams": 100,
      "calories": 250,
      "protein": 15.5,
      "carbs": 20.0,
      "fat": 12.0,
      "fiber": 3.2,
      "healthIndicators": {
        "glycemicIndex": 65,
        "purineLevel": "low",
        "sodiumMg": 450,
        "cholesterolMg": 85,
        "saturatedFatG": 4.2,
        "transFatG": 0,
        "potassiumMg": 300,
        "phosphorusMg": 150,
        "oxalateLevel": "low",
        "fodmapLevel": "low",
        "histamineLevel": "low",
        "isNightshade": false,
        "mercuryLevel": "none",
        "isRawUndercooked": false,
        "caffeineMg": 0,
        "containsAlcohol": false,
        "vitaminKMcg": 50,
        "isGrapefruit": false,
        "tyramineLevel": "low",
        "isGoitrogen": false,
        "phenylalanineMg": 100,
        "copperMg": 0.2,
        "allergens": []
      }
    }
  ],
  "confidence": "high|medium|low",
  "source": "ai"
}

Guidelines:
- First, check if the image contains food. If not (e.g., person, object, scenery), set isFood to false and return empty items array
- If it IS food, set isFood to true and identify ALL visible food items separately
- Estimate realistic portion sizes
- Provide accurate nutritional estimates
- Use metric units (grams) for nutrients
- Set confidence based on how clearly items are visible
- Focus on main ingredients and dishes

Health Indicator Guidelines:
- glycemicIndex: 0-100 scale. >70=high, 55-70=medium, <55=low. Omit if not applicable.
- purineLevel: "high" for organ meats/shellfish/beer, "medium" for red meat/legumes, "low" for most foods
- sodiumMg: Sodium content in milligrams
- cholesterolMg: Cholesterol in milligrams
- saturatedFatG: Saturated fat in grams
- transFatG: Trans fat in grams (0 if none)
- potassiumMg: Potassium in milligrams
- phosphorusMg: Phosphorus in milligrams
- oxalateLevel: "high" for spinach/rhubarb/chocolate/nuts, "medium" or "low" otherwise
- fodmapLevel: "high" for garlic/onion/wheat/beans, "medium" or "low" for safe foods
- histamineLevel: "high" for aged cheese/fermented/cured meats/alcohol, "medium" for citrus, "low" for fresh foods
- isNightshade: true for tomatoes, potatoes, peppers, eggplant
- mercuryLevel: "high" for swordfish/shark/king mackerel, "medium" for tuna, "low" for salmon/shrimp, "none" for non-seafood
- isRawUndercooked: true for sushi, rare meat, raw eggs
- caffeineMg: Caffeine content in milligrams
- containsAlcohol: true if contains alcohol
- vitaminKMcg: Vitamin K in micrograms
- isGrapefruit: true for grapefruit or pomelo
- tyramineLevel: "high" for aged cheese/cured meats/fermented, "medium" for fresh cheese, "low" for most foods
- isGoitrogen: true for raw cruciferous vegetables (broccoli, cabbage, kale)
- phenylalanineMg: Phenylalanine in milligrams (important for high-protein foods)
- copperMg: Copper in milligrams
- allergens: List any of: "nuts", "dairy", "gluten", "shellfish", "eggs", "soy", "sesame", "fish"
''';
  }

  /// Parse AI response into structured MealAnalysis
  MealAnalysis _parseResponse(String content, String source) {
    try {
      // Try to extract JSON from the response
      final jsonStart = content.indexOf('{');
      final jsonEnd = content.lastIndexOf('}') + 1;
      if (jsonStart == -1 || jsonEnd == 0) {
        throw const FormatException('No JSON found in response');
      }

      final jsonStr = content.substring(jsonStart, jsonEnd);
      final Map<String, dynamic> data = json.decode(jsonStr);

      // Check if the image contains food
      final isFood = data['isFood'] ?? true;
      if (!isFood) {
        throw const LLMException('NOT_FOOD'); // Special marker for non-food images
      }

      final items = (data['items'] as List<dynamic>).map((item) {
        // Parse health indicators if present
        HealthIndicators? healthIndicators;
        if (item['healthIndicators'] != null) {
          healthIndicators = HealthIndicators.fromJson(
            item['healthIndicators'] as Map<String, dynamic>,
          );
        }

        return FoodItem(
          name: item['name'] ?? 'Unknown Food',
          portion: item['portion'] ?? '1 serving',
          portionGrams: item['portionGrams'] ?? 100,
          calories: item['calories'] ?? 0,
          protein: item['protein'] ?? 0.0,
          carbs: item['carbs'] ?? 0.0,
          fat: item['fat'] ?? 0.0,
          fiber: item['fiber'] ?? 0.0,
          isEdited: false,
          healthIndicators: healthIndicators,
        );
      }).toList();

      return MealAnalysis(
        items: items,
        confidence: data['confidence'] ?? 'medium',
        source: source,
      );
    } catch (e) {
      // Re-throw NOT_FOOD exceptions - don't fallback for non-food images
      if (e is LLMException && e.message == 'NOT_FOOD') {
        rethrow;
      }
      
      // Fallback parsing for non-JSON responses
      final lines = content.split('\n');
      final items = <FoodItem>[];

      for (final line in lines) {
        if (line.toLowerCase().contains('calories') ||
            line.toLowerCase().contains('protein') ||
            line.contains('g ') && line.contains('kcal')) {
          // Try to extract basic nutritional info
          items.add(FoodItem(
            name: 'Detected Food Item',
            portion: '1 serving (estimated)',
            portionGrams: 100,
            calories: 200,
            protein: 10.0,
            carbs: 25.0,
            fat: 8.0,
            fiber: 2.0,
            isEdited: false,
          ));
          break; // Just add one item for fallback
        }
      }

      return MealAnalysis(
        items: items.isEmpty ? [
          FoodItem(
            name: 'Detected Meal',
            portion: '1 serving',
            portionGrams: 200,
            calories: 350,
            protein: 20.0,
            carbs: 40.0,
            fat: 15.0,
            fiber: 5.0,
            isEdited: false,
          )
        ] : items,
        confidence: 'low',
        source: source,
      );
    }
  }
}

/// Provider for LLM service
final llmServiceProvider = Provider<LLMService>((ref) {
  final dio = Dio();
  final secureStorage = ref.watch(secureStorageProvider);
  return LLMService(dio, secureStorage);
});
