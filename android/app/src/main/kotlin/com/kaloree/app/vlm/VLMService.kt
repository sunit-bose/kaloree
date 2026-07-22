package com.kaloree.app.vlm

import android.content.Context
import android.content.pm.ApplicationInfo
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Log
import com.google.android.play.core.assetpacks.AssetPackManager
import com.google.android.play.core.assetpacks.AssetPackManagerFactory
import com.google.android.play.core.assetpacks.model.AssetPackStatus
import com.google.gson.Gson
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream
import kotlin.random.Random

/**
 * VLMService - On-Device Vision Language Model Service
 *
 * Development Mode (BuildConfig.DEBUG):
 *   - Returns realistic stub responses for testing
 *   - Simulates model loading delay
 *   - Bypasses PAD entirely
 *   - Allows end-to-end flow testing without real models
 *
 * Production Mode:
 *   - Requires real VLM SDK integration
 *   - Uses Play Asset Delivery for model files
 *   - Falls back to cloud API if SDK not available
 *
 * Model Loading Priority:
 * 1. Play Asset Delivery (PAD) - ai_model_pack
 * 2. APK Assets - fallback for development
 * 3. External path - for testing with custom models
 *
 * Candidates for real implementation:
 * - llama-android (llama.cpp bindings)
 * - MLC LLM
 * - MediaPipe LLM Inference
 * - Custom llama.cpp JNI wrapper
 */
class VLMService(private val context: Context) {
    
    companion object {
        private const val TAG = "VLMService"
        // Qwen2-VL 2B - Much better accuracy for food recognition
        private const val MODEL_NAME = "qwen2-vl-2b-instruct"
        private const val MODEL_FILE = "qwen2-vl-2b-instruct-q4_k_m.gguf"   // ~1.5GB
        private const val CLIP_FILE = "qwen2-vl-2b-clip-q8_0.gguf"          // ~400MB
        private const val ASSET_PACK_NAME = "ai_model_pack"
        
        // Model state
        @Volatile
        private var isInitialized = false
        
        // Cached model path from PAD
        @Volatile
        private var modelBasePath: String? = null
        
        // sdkAvailable is set per-instance based on debug mode
        @Volatile
        var sdkAvailable_FLAG: Boolean = false
    }
    
    // Development mode flag - uses ApplicationInfo for reliability
    private val isDevMode: Boolean
        get() = (context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
    
    // In dev mode, SDK is "available" for testing with stubs
    // In prod mode, SDK is not available until real integration
    val sdkAvailable: Boolean
        get() = isDevMode
    
    private val gson = Gson()
    private val assetPackManager: AssetPackManager by lazy {
        AssetPackManagerFactory.getInstance(context)
    }
    
    /**
     * Initialize the VLM model.
     *
     * Development Mode:
     *   - Simulates model loading with a brief delay
     *   - Returns success immediately
     *   - Allows end-to-end testing without real models
     *
     * Production Mode:
     *   - Model loading priority:
     *     1. Play Asset Delivery (PAD) - for production
     *     2. APK assets - for development/testing
     *     3. External path - for custom model testing
     *   - Returns failure until real VLM SDK is integrated
     */
    suspend fun initialize(): Result<Boolean> = withContext(Dispatchers.IO) {
        // Development mode - simulate model loading
        if (isDevMode) {
            if (isInitialized) {
                Log.d(TAG, "🔧 DEV MODE: VLM already initialized")
                return@withContext Result.success(true)
            }
            
            Log.d(TAG, "🔧 DEV MODE: Simulating VLM model initialization...")
            
            // Simulate loading time (1-2 seconds)
            delay(1500)
            
            modelBasePath = "${context.filesDir.absolutePath}/models/"
            isInitialized = true
            
            Log.d(TAG, "🔧 DEV MODE: VLM model initialized (stub)")
            Log.d(TAG, "🔧 DEV MODE: Model path: $modelBasePath")
            
            return@withContext Result.success(true)
        }
        
        // Production mode - real SDK required
        if (!sdkAvailable) {
            Log.w(TAG, "VLM SDK not yet integrated. Using cloud fallback.")
            return@withContext Result.failure(
                UnsupportedOperationException("On-device VLM SDK is not yet available. Falling back to cloud API.")
            )
        }
        
        // This code will be enabled when a real VLM SDK is integrated
        /*
        if (isInitialized) {
            Log.d(TAG, "VLM already initialized")
            return@withContext Result.success(true)
        }
        
        try {
            Log.d(TAG, "Initializing VLM model...")
            
            // Copy model files from assets to internal storage
            val modelPath = copyAssetToInternalStorage(MODEL_FILE)
            val clipPath = copyAssetToInternalStorage(CLIP_FILE)
            
            Log.d(TAG, "Model path: $modelPath")
            Log.d(TAG, "CLIP path: $clipPath")
            
            // TODO: Initialize actual VLM library here
            // Example with hypothetical API:
            // val config = VLMConfig.Builder()
            //     .setModelPath(modelPath)
            //     .setClipModelPath(clipPath)
            //     .setContextSize(2048)
            //     .setThreadCount(4)
            //     .build()
            // vlmModel = VLMModel.load(config)
            
            isInitialized = true
            Log.d(TAG, "VLM model initialized successfully")
            Result.success(true)
            
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize VLM: ${e.message}", e)
            Result.failure(e)
        }
        */
        
        Result.failure(UnsupportedOperationException("VLM SDK not available"))
    }
    
    /**
     * Analyze a food image and return nutritional information.
     *
     * Development Mode:
     *   - Returns realistic stub responses from a variety of common foods
     *   - Simulates inference time (500-1500ms)
     *   - Allows end-to-end UI testing
     *
     * Production Mode:
     *   - Returns failure to trigger cloud fallback until SDK integrated
     *
     * @param imageBytes Raw image bytes (JPEG/PNG)
     * @return JSON string with meal analysis results
     */
    suspend fun analyzeFood(imageBytes: ByteArray): Result<String> = withContext(Dispatchers.IO) {
        // Development mode - return realistic stub response
        if (isDevMode) {
            Log.d(TAG, "🔧 DEV MODE: Analyzing food image (${imageBytes.size} bytes)...")
            
            // Simulate inference time (500-1500ms)
            val inferenceTime = Random.nextLong(500, 1500)
            delay(inferenceTime)
            
            // Generate a realistic stub response
            val stubResponse = generateDevModeStubResponse()
            
            Log.d(TAG, "🔧 DEV MODE: Analysis complete in ${inferenceTime}ms")
            Log.d(TAG, "🔧 DEV MODE: Response: ${stubResponse.take(100)}...")
            
            return@withContext Result.success(stubResponse)
        }
        
        // Production mode - require real SDK
        if (!sdkAvailable || !isInitialized) {
            return@withContext Result.failure(
                UnsupportedOperationException("On-device VLM not available. Use cloud API.")
            )
        }
        
        // This code will be enabled when a real VLM SDK is integrated
        /*
        try {
            Log.d(TAG, "Analyzing food image (${imageBytes.size} bytes)...")
            
            // Decode and resize image for optimal inference
            val bitmap = decodeAndResizeImage(imageBytes)
            
            // Create the food analysis prompt
            val prompt = buildFoodAnalysisPrompt()
            
            // Run VLM inference
            val startTime = System.currentTimeMillis()
            val response = vlmModel!!.generate(bitmap, prompt)
            val inferenceTime = System.currentTimeMillis() - startTime
            
            Log.d(TAG, "VLM inference completed in ${inferenceTime}ms")
            
            // Parse and validate response
            val result = parseVLMResponse(response)
            
            Result.success(result)
            
        } catch (e: Exception) {
            Log.e(TAG, "Food analysis failed: ${e.message}", e)
            Result.failure(e)
        }
        */
        
        Result.failure(UnsupportedOperationException("VLM SDK not available"))
    }
    
    /**
     * Generate a realistic stub response for development mode testing.
     * Returns varied responses from common foods to test the UI.
     */
    private fun generateDevModeStubResponse(): String {
        val foods = listOf(
            DevModeFoodStub(
                name = "Grilled Chicken Salad",
                servingSize = "1 bowl (350g)",
                calories = 320,
                protein = 35.0,
                carbs = 15.0,
                fat = 14.0,
                fiber = 6.0,
                sugar = 5.0,
                sodium = 520,
                ingredients = listOf("grilled chicken breast", "mixed greens", "cherry tomatoes", "cucumber", "olive oil dressing"),
                healthNotes = listOf("High protein", "Low carb", "Good source of fiber"),
                isHealthy = true,
                confidence = 0.92
            ),
            DevModeFoodStub(
                name = "Cheese Pizza Slice",
                servingSize = "1 large slice (120g)",
                calories = 285,
                protein = 12.0,
                carbs = 36.0,
                fat = 10.0,
                fiber = 2.0,
                sugar = 4.0,
                sodium = 640,
                ingredients = listOf("pizza dough", "tomato sauce", "mozzarella cheese"),
                healthNotes = listOf("Moderate calories", "Good source of calcium", "High sodium"),
                isHealthy = false,
                confidence = 0.88
            ),
            DevModeFoodStub(
                name = "Banana Smoothie",
                servingSize = "1 glass (300ml)",
                calories = 180,
                protein = 5.0,
                carbs = 38.0,
                fat = 2.0,
                fiber = 3.0,
                sugar = 28.0,
                sodium = 45,
                ingredients = listOf("banana", "milk", "honey", "ice"),
                healthNotes = listOf("Good source of potassium", "Natural sugars", "Post-workout recovery"),
                isHealthy = true,
                confidence = 0.95
            ),
            DevModeFoodStub(
                name = "Vegetable Biryani",
                servingSize = "1 plate (300g)",
                calories = 420,
                protein = 9.0,
                carbs = 65.0,
                fat = 14.0,
                fiber = 5.0,
                sugar = 3.0,
                sodium = 780,
                ingredients = listOf("basmati rice", "mixed vegetables", "spices", "ghee", "fried onions"),
                healthNotes = listOf("Complex carbohydrates", "Rich in spices", "Vegetarian protein"),
                isHealthy = true,
                confidence = 0.85
            ),
            DevModeFoodStub(
                name = "Masala Dosa",
                servingSize = "1 dosa with chutney (200g)",
                calories = 350,
                protein = 8.0,
                carbs = 55.0,
                fat = 12.0,
                fiber = 4.0,
                sugar = 2.0,
                sodium = 450,
                ingredients = listOf("fermented rice batter", "potato masala", "coconut chutney", "sambar"),
                healthNotes = listOf("Fermented food", "Good probiotics", "South Indian staple"),
                isHealthy = true,
                confidence = 0.91
            ),
            DevModeFoodStub(
                name = "Paneer Tikka",
                servingSize = "6 pieces (180g)",
                calories = 290,
                protein = 18.0,
                carbs = 8.0,
                fat = 22.0,
                fiber = 2.0,
                sugar = 3.0,
                sodium = 380,
                ingredients = listOf("paneer", "bell peppers", "onions", "yogurt marinade", "spices"),
                healthNotes = listOf("High protein", "Vegetarian", "Good source of calcium"),
                isHealthy = true,
                confidence = 0.89
            ),
            DevModeFoodStub(
                name = "French Fries",
                servingSize = "Medium serving (150g)",
                calories = 365,
                protein = 4.0,
                carbs = 48.0,
                fat = 17.0,
                fiber = 4.0,
                sugar = 0.5,
                sodium = 280,
                ingredients = listOf("potatoes", "vegetable oil", "salt"),
                healthNotes = listOf("High in calories", "Deep fried", "Limit consumption"),
                isHealthy = false,
                confidence = 0.94
            ),
            DevModeFoodStub(
                name = "Fruit Bowl",
                servingSize = "1 bowl (250g)",
                calories = 125,
                protein = 2.0,
                carbs = 32.0,
                fat = 0.5,
                fiber = 5.0,
                sugar = 24.0,
                sodium = 5,
                ingredients = listOf("apple", "banana", "grapes", "orange", "pomegranate"),
                healthNotes = listOf("Rich in vitamins", "Natural sugars", "High fiber"),
                isHealthy = true,
                confidence = 0.96
            )
        )
        
        // Pick a random food for variety in testing
        val food = foods[Random.nextInt(foods.size)]
        
        // Build JSON response
        val json = JsonObject().apply {
            addProperty("food_name", food.name)
            addProperty("confidence", food.confidence)
            addProperty("serving_size", food.servingSize)
            addProperty("calories", food.calories)
            addProperty("protein_g", food.protein)
            addProperty("carbs_g", food.carbs)
            addProperty("fat_g", food.fat)
            addProperty("fiber_g", food.fiber)
            addProperty("sugar_g", food.sugar)
            addProperty("sodium_mg", food.sodium)
            
            val ingredientsArray = JsonArray()
            food.ingredients.forEach { ingredientsArray.add(it) }
            add("ingredients", ingredientsArray)
            
            val notesArray = JsonArray()
            food.healthNotes.forEach { notesArray.add(it) }
            add("health_notes", notesArray)
            
            addProperty("is_healthy", food.isHealthy)
            addProperty("_dev_mode", true)
            addProperty("_model", "SmolVLM-256M-Stub")
        }
        
        return gson.toJson(json)
    }
    
    /**
     * Data class for dev mode food stubs
     */
    private data class DevModeFoodStub(
        val name: String,
        val servingSize: String,
        val calories: Int,
        val protein: Double,
        val carbs: Double,
        val fat: Double,
        val fiber: Double,
        val sugar: Double,
        val sodium: Int,
        val ingredients: List<String>,
        val healthNotes: List<String>,
        val isHealthy: Boolean,
        val confidence: Double
    )
    
    /**
     * Check if VLM is ready for inference.
     * In dev mode, returns true once initialized (stub mode).
     */
    fun isReady(): Boolean {
        return if (isDevMode) {
            isInitialized
        } else {
            sdkAvailable && isInitialized
        }
    }
    
    /**
     * Get model information.
     */
    fun getModelInfo(): Map<String, Any> = mapOf(
        "model" to MODEL_NAME,
        "initialized" to isInitialized,
        "onDevice" to true,
        "sdkAvailable" to sdkAvailable,
        "quantization" to "Q4_K_M",
        "memoryMB" to 500,  // ~350MB model + ~150MB CLIP
        "status" to when {
            isDevMode && isInitialized -> "ready_dev_mode"
            isDevMode -> "dev_mode_not_initialized"
            sdkAvailable && isInitialized -> "ready"
            else -> "sdk_pending"
        },
        "modelPath" to (modelBasePath ?: "not_loaded"),
        "assetPackName" to ASSET_PACK_NAME,
        "devMode" to isDevMode
    )
    
    /**
     * Check if the AI model asset pack is downloaded via PAD.
     */
    suspend fun checkAssetPackStatus(): AssetPackStatusInfo = withContext(Dispatchers.IO) {
        try {
            val packStates = assetPackManager.getPackStates(listOf(ASSET_PACK_NAME)).await()
            val state = packStates.packStates()[ASSET_PACK_NAME]
            
            if (state == null) {
                return@withContext AssetPackStatusInfo(
                    status = "not_installed",
                    isDownloaded = false,
                    progress = 0.0
                )
            }
            
            val totalBytes = state.totalBytesToDownload()
            val downloadedBytes = state.bytesDownloaded()
            val progress = if (totalBytes > 0) downloadedBytes.toDouble() / totalBytes else 0.0
            
            val statusString = when (state.status()) {
                AssetPackStatus.COMPLETED -> "completed"
                AssetPackStatus.DOWNLOADING -> "downloading"
                AssetPackStatus.PENDING -> "pending"
                AssetPackStatus.NOT_INSTALLED -> "not_installed"
                AssetPackStatus.FAILED -> "failed"
                else -> "unknown"
            }
            
            AssetPackStatusInfo(
                status = statusString,
                isDownloaded = state.status() == AssetPackStatus.COMPLETED,
                progress = progress,
                bytesDownloaded = downloadedBytes,
                totalBytes = totalBytes
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error checking asset pack status: ${e.message}", e)
            AssetPackStatusInfo(
                status = "error",
                isDownloaded = false,
                progress = 0.0,
                errorMessage = e.message
            )
        }
    }
    
    /**
     * Get the model path from Play Asset Delivery.
     * Returns null if the asset pack is not downloaded.
     */
    suspend fun getModelPathFromPAD(): String? = withContext(Dispatchers.IO) {
        try {
            val location = assetPackManager.getPackLocation(ASSET_PACK_NAME)
            if (location != null) {
                val basePath = location.assetsPath()
                modelBasePath = "$basePath/models/"
                Log.d(TAG, "PAD model path: $modelBasePath")
                modelBasePath
            } else {
                Log.d(TAG, "Asset pack not available")
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error getting PAD model path: ${e.message}", e)
            null
        }
    }
    
    /**
     * Set an external model path (for testing or custom models).
     */
    fun setModelPath(path: String) {
        modelBasePath = path
        Log.d(TAG, "External model path set: $path")
    }
    
    /**
     * Release model resources.
     */
    fun release() {
        try {
            // TODO: Release actual VLM model resources
            // vlmModel?.close()
            // vlmModel = null
            isInitialized = false
            Log.d(TAG, "VLM model released")
        } catch (e: Exception) {
            Log.e(TAG, "Error releasing VLM: ${e.message}", e)
        }
    }
    
    // ==================== Private Helper Methods ====================
    
    private fun copyAssetToInternalStorage(assetName: String): String {
        val outputFile = File(context.filesDir, "models/$assetName")
        
        // Skip if already copied
        if (outputFile.exists()) {
            Log.d(TAG, "Model file already exists: ${outputFile.absolutePath}")
            return outputFile.absolutePath
        }
        
        // Create models directory
        outputFile.parentFile?.mkdirs()
        
        // Copy from assets
        context.assets.open("models/$assetName").use { input ->
            FileOutputStream(outputFile).use { output ->
                input.copyTo(output)
            }
        }
        
        Log.d(TAG, "Copied model to: ${outputFile.absolutePath}")
        return outputFile.absolutePath
    }
    
    private fun decodeAndResizeImage(imageBytes: ByteArray): Bitmap {
        // First, decode bounds only
        val options = BitmapFactory.Options().apply {
            inJustDecodeBounds = true
        }
        BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size, options)
        
        // Calculate sample size for 512px max dimension (optimal for SmolVLM)
        val maxDimension = 512
        val sampleSize = calculateSampleSize(options.outWidth, options.outHeight, maxDimension)
        
        // Decode with sample size
        val decodeOptions = BitmapFactory.Options().apply {
            inSampleSize = sampleSize
            inPreferredConfig = Bitmap.Config.ARGB_8888
        }
        
        val bitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size, decodeOptions)
        Log.d(TAG, "Image decoded: ${bitmap.width}x${bitmap.height}")
        
        return bitmap
    }
    
    private fun calculateSampleSize(width: Int, height: Int, maxDimension: Int): Int {
        var sampleSize = 1
        val maxSize = maxOf(width, height)
        while (maxSize / sampleSize > maxDimension) {
            sampleSize *= 2
        }
        return sampleSize
    }
    
    private fun buildFoodAnalysisPrompt(): String {
        return """
            Analyze this food image and provide nutritional information in JSON format.
            
            Return ONLY a valid JSON object with this exact structure:
            {
                "food_name": "Name of the food/meal",
                "confidence": 0.85,
                "serving_size": "estimated portion (e.g., '1 cup', '200g')",
                "calories": 350,
                "protein_g": 15.0,
                "carbs_g": 45.0,
                "fat_g": 12.0,
                "fiber_g": 5.0,
                "sugar_g": 8.0,
                "sodium_mg": 400,
                "ingredients": ["ingredient1", "ingredient2"],
                "health_notes": ["note about health aspects"],
                "is_healthy": true
            }
            
            Be accurate with calorie estimates. If unsure, provide reasonable estimates.
            Return ONLY the JSON, no additional text.
        """.trimIndent()
    }
    
    private fun parseVLMResponse(responseText: String): String {
        val rawText = responseText.trim()
        Log.d(TAG, "Raw VLM response: $rawText")
        
        // Try to extract JSON from response
        val jsonString = extractJson(rawText)
        
        // Validate JSON structure
        return try {
            val jsonObject = gson.fromJson(jsonString, JsonObject::class.java)
            
            // Ensure required fields exist
            if (!jsonObject.has("food_name") || !jsonObject.has("calories")) {
                // Create a fallback response
                createFallbackResponse(rawText)
            } else {
                jsonString
            }
        } catch (e: Exception) {
            Log.w(TAG, "Failed to parse JSON, creating fallback: ${e.message}")
            createFallbackResponse(rawText)
        }
    }
    
    private fun extractJson(text: String): String {
        // Find JSON object in text
        val jsonStart = text.indexOf('{')
        val jsonEnd = text.lastIndexOf('}')
        
        return if (jsonStart >= 0 && jsonEnd > jsonStart) {
            text.substring(jsonStart, jsonEnd + 1)
        } else {
            text
        }
    }
    
    private fun createFallbackResponse(rawText: String): String {
        // Create a minimal valid response when parsing fails
        val fallback = JsonObject().apply {
            addProperty("food_name", "Food item")
            addProperty("confidence", 0.5)
            addProperty("serving_size", "1 serving")
            addProperty("calories", 250)
            addProperty("protein_g", 10.0)
            addProperty("carbs_g", 30.0)
            addProperty("fat_g", 10.0)
            addProperty("fiber_g", 2.0)
            addProperty("sugar_g", 5.0)
            addProperty("sodium_mg", 300)
            addProperty("is_healthy", true)
            addProperty("raw_response", rawText.take(200))
            addProperty("parse_error", true)
        }
        return gson.toJson(fallback)
    }
}

/**
 * Data class representing the status of the AI model asset pack.
 */
data class AssetPackStatusInfo(
    val status: String,
    val isDownloaded: Boolean,
    val progress: Double,
    val bytesDownloaded: Long = 0,
    val totalBytes: Long = 0,
    val errorMessage: String? = null
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "status" to status,
        "isDownloaded" to isDownloaded,
        "progress" to progress,
        "bytesDownloaded" to bytesDownloaded,
        "totalBytes" to totalBytes,
        "errorMessage" to errorMessage
    )
}
