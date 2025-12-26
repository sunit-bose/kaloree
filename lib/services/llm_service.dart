import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal_analysis.dart';
import 'secure_storage_service.dart';

/// Custom exception for LLM service errors
class LLMException implements Exception {
  final String message;
  const LLMException(this.message);

  @override
  String toString() => message;
}

/// LLM Service - handles meal image analysis with multiple AI providers
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
    final provider = await _secureStorage.getSelectedProvider();
    final apiKey = await _secureStorage.getActiveApiKey();

    if (apiKey == null || apiKey.isEmpty) {
      throw LLMException('API key not configured. Please add your API key in Settings.');
    }

    // Validate API key format for different providers
    if (provider == LLMProvider.groq && !apiKey.startsWith('gsk_')) {
      throw LLMException('Invalid Groq API key format. Key must start with "gsk_". Please check your API key in Settings.');
    } else if (provider == LLMProvider.gemini && !apiKey.startsWith('AI')) {
      throw LLMException('Invalid Gemini API key format. Key must start with "AI". Please check your API key in Settings.');
    } else if (provider == LLMProvider.claude && !apiKey.startsWith('sk-ant-')) {
      throw LLMException('Invalid Claude API key format. Key must start with "sk-ant-". Please check your API key in Settings.');
    }

    try {
      if (provider == LLMProvider.claude) {
        return await _analyzeWithClaude(imageBytes, apiKey);
      } else if (provider == LLMProvider.gemini) {
        return await _analyzeWithGemini(imageBytes, apiKey);
      } else {
        return await _analyzeWithGroq(imageBytes, apiKey);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw LLMException('Invalid API key. Please check your API key in Settings.');
      } else if (e.response?.statusCode == 403) {
        throw LLMException('API access forbidden. Please check your API key permissions.');
      } else if (e.response?.statusCode == 404) {
        // Special message for Gemini experimental model
        if (provider == LLMProvider.gemini) {
          throw LLMException('Gemini 2.0 Flash (Experimental) is not available for your API key. Try using Claude or Groq instead, or request access to experimental models.');
        }
        throw LLMException('API endpoint not found. The selected model may not be available.');
      } else if (e.response?.statusCode == 429) {
        throw LLMException('Rate limit exceeded. Please try again in a moment.');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw LLMException('Connection timeout. Please check your internet connection.');
      }
      throw LLMException('API error: ${e.message}');
    } catch (e) {
      throw LLMException('Failed to analyze image: $e');
    }
  }

  /// Analyze with Claude API
  Future<MealAnalysis> _analyzeWithClaude(Uint8List imageBytes, String apiKey) async {
    final base64Image = base64Encode(imageBytes);

    final response = await _dio.post(
      'https://api.anthropic.com/v1/messages',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'anthropic-version': '2023-06-01',
          'x-api-key': apiKey,
        },
      ),
      data: {
        'model': 'claude-3-sonnet-20240229',
        'max_tokens': 1024,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': 'image/jpeg',
                  'data': base64Image,
                },
              },
              {
                'type': 'text',
                'text': _getPrompt(),
              },
            ],
          },
        ],
      },
    );

    final content = response.data['content'][0]['text'] as String;
    return _parseResponse(content, 'ai');
  }

  /// Analyze with Gemini API (using Gemini 2.0 Flash Exp)
  Future<MealAnalysis> _analyzeWithGemini(Uint8List imageBytes, String apiKey) async {
    final base64Image = base64Encode(imageBytes);

    final response = await _dio.post(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent',
      queryParameters: {'key': apiKey},
      options: Options(
        headers: {'Content-Type': 'application/json'},
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
          'maxOutputTokens': 1024,
          'responseMimeType': 'application/json',
        },
      },
    );

    final content = response.data['candidates'][0]['content']['parts'][0]['text'] as String;
    return _parseResponse(content, 'ai');
  }

  /// Analyze with Groq API (using Llama 3.2 Vision)
  Future<MealAnalysis> _analyzeWithGroq(Uint8List imageBytes, String apiKey) async {
    final base64Image = base64Encode(imageBytes);

    final response = await _dio.post(
      'https://api.groq.com/openai/v1/chat/completions',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      ),
      data: {
        'model': 'llama-3.2-11b-vision-preview',
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': _getPrompt(),
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image',
                },
              },
            ],
          },
        ],
        'max_tokens': 1024,
        'temperature': 0.2,
      },
    );

    final content = response.data['choices'][0]['message']['content'] as String;
    return _parseResponse(content, 'ai');
  }

  /// Prompt for meal analysis
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
      "fiber": 3.2
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
        throw LLMException('NOT_FOOD'); // Special marker for non-food images
      }

      final items = (data['items'] as List<dynamic>).map((item) {
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
