# On-Device AI POC Implementation Plan

## Overview

This document outlines the implementation plan for migrating NutriSnap/Kaloree's food analysis from Google Gemini Cloud API to **on-device inference** using the RunAnywhere Kotlin SDK with SmolVLM 256M vision model.

### Goals

1. **Privacy-First**: Food images never leave the device
2. **Offline Capable**: Full functionality without internet
3. **Zero API Costs**: No per-request charges after model download
4. **Validate Quality**: Test SmolVLM 256M food recognition accuracy

### Scope

- **Platform**: Android-first (iOS uses existing Gemini fallback)
- **Model**: SmolVLM 256M Instruct (~365MB memory, ~350MB download)
- **Integration**: Flutter ↔ Kotlin via Platform Channels

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           FLUTTER LAYER                                 │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────┐    ┌─────────────────────────────────────┐    │
│  │   camera_screen.dart│───▶│         llm_service.dart            │    │
│  │   - Takes photo     │    │  - Platform detection               │    │
│  │   - Sends to LLM    │    │  - Android: OnDeviceAIService       │    │
│  └─────────────────────┘    │  - iOS: GeminiService (fallback)    │    │
│                             └────────────────┬────────────────────┘    │
│                                              │                          │
│  ┌───────────────────────────────────────────▼──────────────────────┐  │
│  │                  on_device_ai_service.dart                        │  │
│  │  - MethodChannel: runanywhere_vlm                                │  │
│  │  - downloadModel(), isModelReady(), analyzeImage()               │  │
│  │  - Handles streaming responses                                    │  │
│  └──────────────────────────────┬───────────────────────────────────┘  │
└─────────────────────────────────┼───────────────────────────────────────┘
                                  │ Platform Channel
┌─────────────────────────────────▼───────────────────────────────────────┐
│                          KOTLIN LAYER (Android)                         │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │               RunAnywhereVLMPlugin.kt                          │    │
│  │  - MethodChannel handler                                       │    │
│  │  - Routes Flutter calls to VLMService                          │    │
│  └────────────────────────────────┬───────────────────────────────┘    │
│                                   │                                     │
│  ┌────────────────────────────────▼───────────────────────────────┐    │
│  │                    VLMService.kt                                │    │
│  │  - RunAnywhere SDK integration                                  │    │
│  │  - Model registration and loading                               │    │
│  │  - processImageStream() for food analysis                       │    │
│  │  - JSON response parsing                                        │    │
│  └────────────────────────────────┬───────────────────────────────┘    │
│                                   │                                     │
│  ┌────────────────────────────────▼───────────────────────────────┐    │
│  │              RunAnywhere SDK (Native)                           │    │
│  │  - SmolVLM 256M model (GGUF + mmproj)                          │    │
│  │  - llama.cpp inference engine                                   │    │
│  │  - On-device processing                                         │    │
│  └────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## File Structure

```
android/
├── app/
│   ├── build.gradle.kts          # Add RunAnywhere dependencies
│   └── src/main/
│       └── kotlin/com/example/kaloree/
│           ├── MainActivity.kt    # Register plugin
│           ├── RunAnywhereVLMPlugin.kt  # Platform channel handler
│           └── VLMService.kt      # VLM processing logic

lib/
├── services/
│   ├── llm_service.dart          # Updated: Platform routing
│   ├── on_device_ai_service.dart # NEW: Platform channel bridge
│   └── gemini_service.dart       # Extracted: Cloud AI fallback
├── features/
│   └── settings/
│       └── widgets/
│           └── ai_model_settings.dart  # NEW: Model management UI
└── models/
    └── ai_model_status.dart      # NEW: Model state tracking
```

---

## Implementation Steps

### Phase 1: Android Setup

#### Step 1.1: Add RunAnywhere Dependencies

**File**: `android/app/build.gradle.kts`

```kotlin
dependencies {
    // RunAnywhere SDK
    implementation("com.runanywhere:runanywhere-core:0.16.0")
    implementation("com.runanywhere:runanywhere-llamacpp:0.16.0")
    
    // Kotlin Coroutines for Flow handling
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
}

android {
    // Increase JVM memory for native SDK compilation
    kotlinOptions {
        jvmTarget = "17"
    }
    
    // Required for native libraries
    packagingOptions {
        pickFirst("lib/*/libc++_shared.so")
    }
}
```

#### Step 1.2: Configure Gradle Properties

**File**: `android/gradle.properties`

```properties
# Increase memory for RunAnywhere SDK
org.gradle.jvmargs=-Xmx8G -XX:+HeapDumpOnOutOfMemoryError
```

---

### Phase 2: Kotlin Platform Channel

#### Step 2.1: VLM Service

**File**: `android/app/src/main/kotlin/.../VLMService.kt`

```kotlin
package com.example.kaloree

import android.content.Context
import com.runanywhere.sdk.public.RunAnywhere
import com.runanywhere.sdk.public.ModelFileDescriptor
import com.runanywhere.sdk.public.InferenceFramework
import com.runanywhere.sdk.public.ModelCategory
import com.runanywhere.sdk.public.extensions.processImageStream
import com.runanywhere.sdk.public.vlm.VLMImage
import com.runanywhere.sdk.public.vlm.VLMGenerationOptions
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import java.io.File

class VLMService(private val context: Context) {
    
    companion object {
        const val MODEL_ID = "smolvlm-256m-instruct"
        const val MODEL_NAME = "SmolVLM 256M Instruct"
        
        // HuggingFace URLs for SmolVLM
        private const val MODEL_URL = "https://huggingface.co/HuggingFaceTB/SmolVLM-256M-Instruct-GGUF/resolve/main/SmolVLM-256M-Instruct-Q8_0.gguf"
        private const val PROJECTOR_URL = "https://huggingface.co/HuggingFaceTB/SmolVLM-256M-Instruct-GGUF/resolve/main/mmproj-SmolVLM-256M-Instruct-f16.gguf"
        
        private const val MEMORY_REQUIREMENT = 365_000_000L // 365MB
    }
    
    private var isInitialized = false
    
    suspend fun initialize() {
        if (isInitialized) return
        
        RunAnywhere.initialize()
        registerModel()
        isInitialized = true
    }
    
    private fun registerModel() {
        RunAnywhere.registerMultiFileModel(
            id = MODEL_ID,
            name = MODEL_NAME,
            files = listOf(
                ModelFileDescriptor(
                    url = MODEL_URL,
                    filename = "SmolVLM-256M-Instruct-Q8_0.gguf"
                ),
                ModelFileDescriptor(
                    url = PROJECTOR_URL,
                    filename = "mmproj-SmolVLM-256M-Instruct-f16.gguf"
                )
            ),
            framework = InferenceFramework.LLAMA_CPP,
            modality = ModelCategory.MULTIMODAL,
            memoryRequirement = MEMORY_REQUIREMENT
        )
    }
    
    fun isModelDownloaded(): Boolean {
        // Check if model files exist locally
        val models = RunAnywhere.getDownloadedModelsWithInfo()
        return models.any { it.id == MODEL_ID }
    }
    
    fun isModelLoaded(): Boolean = RunAnywhere.isVLMModelLoaded
    
    suspend fun downloadModel(onProgress: (Float) -> Unit): Boolean {
        return try {
            RunAnywhere.downloadModel(MODEL_ID).collect { progress ->
                onProgress(progress.percentage)
                if (progress.state.isCompleted) return@collect
            }
            true
        } catch (e: Exception) {
            false
        }
    }
    
    suspend fun loadModel() {
        if (!isModelLoaded()) {
            RunAnywhere.loadVLMModel(MODEL_ID)
        }
    }
    
    suspend fun unloadModel() {
        if (isModelLoaded()) {
            RunAnywhere.unloadVLMModel()
        }
    }
    
    suspend fun analyzeFood(imagePath: String): String {
        val image = VLMImage.fromFilePath(imagePath)
        val options = VLMGenerationOptions(maxTokens = 512)
        
        val prompt = """
Analyze this food image and return a JSON response with nutritional information.

Return ONLY valid JSON in this exact format:
{
  "isFood": true,
  "items": [
    {
      "name": "Food Name",
      "portion": "1 serving",
      "portionGrams": 100,
      "calories": 250,
      "protein": 15.0,
      "carbs": 20.0,
      "fat": 12.0,
      "fiber": 3.0
    }
  ],
  "confidence": "high"
}

If the image is NOT food, return: {"isFood": false, "items": [], "confidence": "high"}

Analyze the image now:
        """.trimIndent()
        
        var result = ""
        RunAnywhere.processImageStream(image, prompt, options)
            .collect { token -> result += token }
        
        return result
    }
    
    fun analyzeFoodStream(imagePath: String): Flow<String> = flow {
        val image = VLMImage.fromFilePath(imagePath)
        val options = VLMGenerationOptions(maxTokens = 512)
        
        val prompt = "Analyze this food and provide nutritional information in JSON format."
        
        RunAnywhere.processImageStream(image, prompt, options)
            .collect { token -> emit(token) }
    }
}
```

#### Step 2.2: Platform Channel Plugin

**File**: `android/app/src/main/kotlin/.../RunAnywhereVLMPlugin.kt`

```kotlin
package com.example.kaloree

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.*
import java.io.File

class RunAnywhereVLMPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    
    private lateinit var methodChannel: MethodChannel
    private lateinit var progressChannel: EventChannel
    private lateinit var context: Context
    private lateinit var vlmService: VLMService
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        vlmService = VLMService(context)
        
        methodChannel = MethodChannel(binding.binaryMessenger, "runanywhere_vlm")
        methodChannel.setMethodCallHandler(this)
        
        progressChannel = EventChannel(binding.binaryMessenger, "runanywhere_vlm/progress")
    }
    
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        scope.cancel()
    }
    
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                scope.launch {
                    try {
                        vlmService.initialize()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INIT_ERROR", e.message, null)
                    }
                }
            }
            
            "isModelDownloaded" -> {
                result.success(vlmService.isModelDownloaded())
            }
            
            "isModelLoaded" -> {
                result.success(vlmService.isModelLoaded())
            }
            
            "downloadModel" -> {
                scope.launch {
                    try {
                        val success = vlmService.downloadModel { progress ->
                            // Send progress to Flutter via EventChannel
                            scope.launch(Dispatchers.Main) {
                                methodChannel.invokeMethod("onDownloadProgress", progress)
                            }
                        }
                        result.success(success)
                    } catch (e: Exception) {
                        result.error("DOWNLOAD_ERROR", e.message, null)
                    }
                }
            }
            
            "loadModel" -> {
                scope.launch {
                    try {
                        vlmService.loadModel()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("LOAD_ERROR", e.message, null)
                    }
                }
            }
            
            "unloadModel" -> {
                scope.launch {
                    try {
                        vlmService.unloadModel()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("UNLOAD_ERROR", e.message, null)
                    }
                }
            }
            
            "analyzeFood" -> {
                val imagePath = call.argument<String>("imagePath")
                if (imagePath == null) {
                    result.error("INVALID_ARGS", "imagePath required", null)
                    return
                }
                
                scope.launch {
                    try {
                        // Save image bytes to temp file if needed
                        val jsonResult = vlmService.analyzeFood(imagePath)
                        result.success(jsonResult)
                    } catch (e: Exception) {
                        result.error("ANALYZE_ERROR", e.message, null)
                    }
                }
            }
            
            "saveImageToTemp" -> {
                val bytes = call.argument<ByteArray>("bytes")
                if (bytes == null) {
                    result.error("INVALID_ARGS", "bytes required", null)
                    return
                }
                
                try {
                    val tempFile = File.createTempFile("vlm_", ".jpg", context.cacheDir)
                    tempFile.writeBytes(bytes)
                    result.success(tempFile.absolutePath)
                } catch (e: Exception) {
                    result.error("FILE_ERROR", e.message, null)
                }
            }
            
            else -> result.notImplemented()
        }
    }
}
```

#### Step 2.3: Register Plugin in MainActivity

**File**: `android/app/src/main/kotlin/.../MainActivity.kt`

```kotlin
package com.example.kaloree

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(RunAnywhereVLMPlugin())
    }
}
```

---

### Phase 3: Flutter Integration

#### Step 3.1: On-Device AI Service

**File**: `lib/services/on_device_ai_service.dart`

```dart
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for on-device AI inference using RunAnywhere VLM
class OnDeviceAIService {
  static const _channel = MethodChannel('runanywhere_vlm');
  
  final _downloadProgressController = StreamController<double>.broadcast();
  Stream<double> get downloadProgress => _downloadProgressController.stream;
  
  OnDeviceAIService() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }
  
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onDownloadProgress':
        final progress = call.arguments as double;
        _downloadProgressController.add(progress);
        break;
    }
  }
  
  /// Initialize the RunAnywhere SDK
  Future<bool> initialize() async {
    try {
      return await _channel.invokeMethod<bool>('initialize') ?? false;
    } catch (e) {
      return false;
    }
  }
  
  /// Check if the VLM model is downloaded
  Future<bool> isModelDownloaded() async {
    try {
      return await _channel.invokeMethod<bool>('isModelDownloaded') ?? false;
    } catch (e) {
      return false;
    }
  }
  
  /// Check if the VLM model is loaded into memory
  Future<bool> isModelLoaded() async {
    try {
      return await _channel.invokeMethod<bool>('isModelLoaded') ?? false;
    } catch (e) {
      return false;
    }
  }
  
  /// Download the VLM model (SmolVLM 256M)
  Future<bool> downloadModel() async {
    try {
      return await _channel.invokeMethod<bool>('downloadModel') ?? false;
    } catch (e) {
      return false;
    }
  }
  
  /// Load the model into memory for inference
  Future<bool> loadModel() async {
    try {
      return await _channel.invokeMethod<bool>('loadModel') ?? false;
    } catch (e) {
      return false;
    }
  }
  
  /// Unload model to free memory
  Future<bool> unloadModel() async {
    try {
      return await _channel.invokeMethod<bool>('unloadModel') ?? false;
    } catch (e) {
      return false;
    }
  }
  
  /// Analyze food image and return JSON result
  Future<String?> analyzeFood(Uint8List imageBytes) async {
    try {
      // First save image to temp file (VLM requires file path)
      final imagePath = await _channel.invokeMethod<String>(
        'saveImageToTemp',
        {'bytes': imageBytes},
      );
      
      if (imagePath == null) return null;
      
      // Analyze with VLM
      return await _channel.invokeMethod<String>(
        'analyzeFood',
        {'imagePath': imagePath},
      );
    } catch (e) {
      return null;
    }
  }
  
  void dispose() {
    _downloadProgressController.close();
  }
}

/// Provider for OnDeviceAIService
final onDeviceAIServiceProvider = Provider<OnDeviceAIService>((ref) {
  final service = OnDeviceAIService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// State for AI model status
enum AIModelStatus {
  notDownloaded,
  downloading,
  downloaded,
  loading,
  ready,
  error,
}

/// Provider for tracking model status
final aiModelStatusProvider = StateProvider<AIModelStatus>((ref) {
  return AIModelStatus.notDownloaded;
});

/// Provider for download progress
final downloadProgressProvider = StreamProvider<double>((ref) {
  final service = ref.watch(onDeviceAIServiceProvider);
  return service.downloadProgress;
});
```

#### Step 3.2: Updated LLM Service with Platform Routing

**File**: `lib/services/llm_service.dart` (Updated)

```dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal_analysis.dart';
import 'on_device_ai_service.dart';
import 'gemini_service.dart';

/// LLM Service with platform-aware routing
/// - Android: On-device AI (SmolVLM) with Gemini fallback
/// - iOS: Gemini Cloud API
class LLMService {
  final OnDeviceAIService? _onDeviceService;
  final GeminiService _geminiService;
  final bool _preferOnDevice;
  
  LLMService({
    OnDeviceAIService? onDeviceService,
    required GeminiService geminiService,
    bool preferOnDevice = true,
  }) : _onDeviceService = onDeviceService,
       _geminiService = geminiService,
       _preferOnDevice = preferOnDevice;
  
  /// Analyze meal image with best available AI
  Future<MealAnalysis> analyzeMealImage(Uint8List imageBytes) async {
    // Try on-device first on Android if preferred and ready
    if (Platform.isAndroid && _preferOnDevice && _onDeviceService != null) {
      final isReady = await _onDeviceService!.isModelLoaded();
      
      if (isReady) {
        try {
          final result = await _analyzeWithOnDevice(imageBytes);
          if (result != null) return result;
        } catch (e) {
          // Fall through to Gemini
        }
      }
    }
    
    // Fallback to Gemini
    return _geminiService.analyzeMealImage(imageBytes);
  }
  
  Future<MealAnalysis?> _analyzeWithOnDevice(Uint8List imageBytes) async {
    final jsonString = await _onDeviceService!.analyzeFood(imageBytes);
    if (jsonString == null) return null;
    
    return _parseResponse(jsonString, 'on-device');
  }
  
  MealAnalysis _parseResponse(String content, String source) {
    // Extract JSON from response
    final jsonStart = content.indexOf('{');
    final jsonEnd = content.lastIndexOf('}') + 1;
    if (jsonStart == -1 || jsonEnd == 0) {
      throw FormatException('No JSON found in response');
    }
    
    final jsonStr = content.substring(jsonStart, jsonEnd);
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    
    if (data['isFood'] == false) {
      throw const LLMException('NOT_FOOD');
    }
    
    final items = (data['items'] as List<dynamic>).map((item) {
      return FoodItem(
        name: item['name'] ?? 'Unknown Food',
        portion: item['portion'] ?? '1 serving',
        portionGrams: item['portionGrams'] ?? 100,
        calories: item['calories'] ?? 0,
        protein: (item['protein'] ?? 0.0).toDouble(),
        carbs: (item['carbs'] ?? 0.0).toDouble(),
        fat: (item['fat'] ?? 0.0).toDouble(),
        fiber: (item['fiber'] ?? 0.0).toDouble(),
        isEdited: false,
      );
    }).toList();
    
    return MealAnalysis(
      items: items,
      confidence: data['confidence'] ?? 'medium',
      source: source,
    );
  }
}

/// Provider for LLM service
final llmServiceProvider = Provider<LLMService>((ref) {
  final onDeviceService = Platform.isAndroid 
      ? ref.watch(onDeviceAIServiceProvider) 
      : null;
  final geminiService = ref.watch(geminiServiceProvider);
  
  return LLMService(
    onDeviceService: onDeviceService,
    geminiService: geminiService,
    preferOnDevice: true,
  );
});
```

---

### Phase 4: UI Components

#### Step 4.1: AI Model Settings Widget

**File**: `lib/features/settings/widgets/ai_model_settings.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/on_device_ai_service.dart';

class AIModelSettingsCard extends ConsumerStatefulWidget {
  const AIModelSettingsCard({super.key});

  @override
  ConsumerState<AIModelSettingsCard> createState() => _AIModelSettingsCardState();
}

class _AIModelSettingsCardState extends ConsumerState<AIModelSettingsCard> {
  bool _isDownloading = false;
  double _progress = 0.0;
  
  @override
  void initState() {
    super.initState();
    _checkModelStatus();
  }
  
  Future<void> _checkModelStatus() async {
    final service = ref.read(onDeviceAIServiceProvider);
    await service.initialize();
    
    final isDownloaded = await service.isModelDownloaded();
    final isLoaded = await service.isModelLoaded();
    
    if (isLoaded) {
      ref.read(aiModelStatusProvider.notifier).state = AIModelStatus.ready;
    } else if (isDownloaded) {
      ref.read(aiModelStatusProvider.notifier).state = AIModelStatus.downloaded;
    } else {
      ref.read(aiModelStatusProvider.notifier).state = AIModelStatus.notDownloaded;
    }
  }
  
  Future<void> _downloadModel() async {
    setState(() => _isDownloading = true);
    ref.read(aiModelStatusProvider.notifier).state = AIModelStatus.downloading;
    
    final service = ref.read(onDeviceAIServiceProvider);
    
    // Listen to progress
    service.downloadProgress.listen((progress) {
      setState(() => _progress = progress);
    });
    
    final success = await service.downloadModel();
    
    setState(() => _isDownloading = false);
    
    if (success) {
      ref.read(aiModelStatusProvider.notifier).state = AIModelStatus.downloaded;
      _showSnackBar('Model downloaded successfully!');
    } else {
      ref.read(aiModelStatusProvider.notifier).state = AIModelStatus.error;
      _showSnackBar('Failed to download model');
    }
  }
  
  Future<void> _loadModel() async {
    ref.read(aiModelStatusProvider.notifier).state = AIModelStatus.loading;
    
    final service = ref.read(onDeviceAIServiceProvider);
    final success = await service.loadModel();
    
    if (success) {
      ref.read(aiModelStatusProvider.notifier).state = AIModelStatus.ready;
      _showSnackBar('Model ready for inference!');
    } else {
      ref.read(aiModelStatusProvider.notifier).state = AIModelStatus.error;
      _showSnackBar('Failed to load model');
    }
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final status = ref.watch(aiModelStatusProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.smart_toy, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'On-Device AI',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                _buildStatusChip(status),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'SmolVLM 256M - Private food analysis without internet',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            if (status == AIModelStatus.notDownloaded)
              _buildDownloadSection(),
              
            if (status == AIModelStatus.downloading)
              _buildProgressSection(),
              
            if (status == AIModelStatus.downloaded)
              _buildLoadSection(),
              
            if (status == AIModelStatus.ready)
              _buildReadySection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(AIModelStatus status) {
    final (color, label) = switch (status) {
      AIModelStatus.notDownloaded => (Colors.grey, 'Not Downloaded'),
      AIModelStatus.downloading => (Colors.orange, 'Downloading'),
      AIModelStatus.downloaded => (Colors.blue, 'Downloaded'),
      AIModelStatus.loading => (Colors.orange, 'Loading'),
      AIModelStatus.ready => (Colors.green, 'Ready'),
      AIModelStatus.error => (Colors.red, 'Error'),
    };
    
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.2),
      labelStyle: TextStyle(color: color),
    );
  }
  
  Widget _buildDownloadSection() {
    return Column(
      children: [
        const Text('Download ~350MB model for offline food analysis'),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _downloadModel,
          icon: const Icon(Icons.download),
          label: const Text('Download Model'),
        ),
      ],
    );
  }
  
  Widget _buildProgressSection() {
    return Column(
      children: [
        LinearProgressIndicator(value: _progress),
        const SizedBox(height: 8),
        Text('${(_progress * 100).toStringAsFixed(1)}% downloaded'),
      ],
    );
  }
  
  Widget _buildLoadSection() {
    return ElevatedButton.icon(
      onPressed: _loadModel,
      icon: const Icon(Icons.memory),
      label: const Text('Load Model'),
    );
  }
  
  Widget _buildReadySection() {
    return const Row(
      children: [
        Icon(Icons.check_circle, color: Colors.green),
        SizedBox(width: 8),
        Text('On-device AI is ready! Food analysis will be private.'),
      ],
    );
  }
}
```

---

## Testing Plan

### Phase 5: Quality Validation

#### Test Categories

1. **Single Food Items**
   - Apple, banana, orange (fruits)
   - Chicken breast, steak, fish (proteins)
   - Rice, pasta, bread (carbs)
   - Salad, broccoli, carrots (vegetables)

2. **Complex Meals**
   - Plate with multiple items
   - Mixed dishes (curry, stir-fry)
   - Fast food (burger, pizza)

3. **Edge Cases**
   - Poor lighting
   - Partial view
   - Non-food images (should return isFood: false)

#### Quality Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Food Detection Accuracy | > 90% | Correctly identifies food vs non-food |
| Food Identification | > 75% | Correct food name |
| Calorie Estimation | ± 30% | Compared to USDA database |
| Macro Estimation | ± 25% | Protein/carbs/fat accuracy |
| Response Time | < 5s | On mid-range device |

---

## Rollout Strategy

### Phase 1: Internal Testing
- Build POC on `feature/on-device-ai` branch
- Test with team on various Android devices

### Phase 2: Beta Release
- Feature flag: `enable_on_device_ai`
- Opt-in for beta users
- Collect quality feedback

### Phase 3: Gradual Rollout
- 10% → 25% → 50% → 100%
- Monitor crash rates and quality metrics

### Phase 4: iOS Planning
- Evaluate RunAnywhere iOS SDK when available
- Or investigate alternatives (Core ML, etc.)

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Model quality insufficient | Keep Gemini as fallback, A/B test |
| Download size concerns | Clear messaging, WiFi-only option |
| Device compatibility | Minimum Android 8.0, 3GB RAM |
| Battery drain | Auto-unload model when idle |
| App size increase | Lazy-load SDK, on-demand download |

---

## Success Criteria

✅ POC is successful if:
1. SmolVLM can identify common foods with > 75% accuracy
2. Calorie estimates are within ± 30% of Gemini
3. Inference time < 5 seconds on mid-range device
4. No crashes or memory issues
5. User experience is smooth (download, loading, inference)

---

## Next Steps

1. **Immediate**: Create `feature/on-device-ai` branch
2. **Day 1-2**: Android SDK setup and basic Platform Channel
3. **Day 3-4**: VLM integration and food analysis
4. **Day 5-6**: Flutter UI and model management
5. **Day 7**: Testing and quality assessment
6. **Day 8+**: Iterate based on findings
