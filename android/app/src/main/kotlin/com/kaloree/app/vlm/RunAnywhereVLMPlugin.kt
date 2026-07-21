package com.kaloree.app.vlm

import android.content.Context
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

/**
 * RunAnywhereVLMPlugin - Flutter Platform Channel Plugin
 * 
 * Provides a bridge between Flutter and the native VLMService for
 * on-device food image analysis using RunAnywhere SDK.
 * 
 * Channel: com.kaloree.app/vlm
 * 
 * Methods:
 * - initialize(): Initialize the VLM model
 * - analyzeFood(imageBytes): Analyze food image and return nutrition JSON
 * - isReady(): Check if model is ready
 * - getModelInfo(): Get model metadata
 * - release(): Release model resources
 */
class RunAnywhereVLMPlugin private constructor(
    private val context: Context,
    flutterEngine: FlutterEngine
) : MethodCallHandler {
    
    companion object {
        private const val TAG = "RunAnywhereVLMPlugin"
        private const val CHANNEL_NAME = "com.kaloree.app/vlm"
        
        private var instance: RunAnywhereVLMPlugin? = null
        
        /**
         * Register the plugin with Flutter engine.
         */
        fun registerWith(context: Context, flutterEngine: FlutterEngine) {
            if (instance == null) {
                instance = RunAnywhereVLMPlugin(context, flutterEngine)
                Log.d(TAG, "RunAnywhereVLMPlugin registered")
            }
        }
        
        /**
         * Cleanup when activity is destroyed.
         */
        fun cleanup() {
            instance?.dispose()
            instance = null
        }
    }
    
    private val channel: MethodChannel = MethodChannel(
        flutterEngine.dartExecutor.binaryMessenger,
        CHANNEL_NAME
    )
    
    private val vlmService: VLMService = VLMService(context)
    
    private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    
    init {
        channel.setMethodCallHandler(this)
    }
    
    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d(TAG, "Method called: ${call.method}")
        
        when (call.method) {
            "initialize" -> handleInitialize(result)
            "analyzeFood" -> handleAnalyzeFood(call, result)
            "isReady" -> handleIsReady(result)
            "getModelInfo" -> handleGetModelInfo(result)
            "release" -> handleRelease(result)
            else -> result.notImplemented()
        }
    }
    
    private fun handleInitialize(result: Result) {
        coroutineScope.launch {
            try {
                val initResult = vlmService.initialize()
                
                initResult.fold(
                    onSuccess = { success ->
                        result.success(mapOf(
                            "success" to success,
                            "message" to "VLM model initialized successfully"
                        ))
                    },
                    onFailure = { error ->
                        result.error(
                            "INIT_ERROR",
                            "Failed to initialize VLM: ${error.message}",
                            error.stackTraceToString()
                        )
                    }
                )
            } catch (e: Exception) {
                Log.e(TAG, "Initialize error: ${e.message}", e)
                result.error(
                    "INIT_ERROR",
                    "Exception during initialization: ${e.message}",
                    e.stackTraceToString()
                )
            }
        }
    }
    
    private fun handleAnalyzeFood(call: MethodCall, result: Result) {
        val imageBytes = call.argument<ByteArray>("imageBytes")
        
        if (imageBytes == null || imageBytes.isEmpty()) {
            result.error(
                "INVALID_ARGUMENT",
                "imageBytes is required and must not be empty",
                null
            )
            return
        }
        
        coroutineScope.launch {
            try {
                val analyzeResult = vlmService.analyzeFood(imageBytes)
                
                analyzeResult.fold(
                    onSuccess = { json ->
                        result.success(mapOf(
                            "success" to true,
                            "data" to json,
                            "onDevice" to true
                        ))
                    },
                    onFailure = { error ->
                        result.error(
                            "ANALYZE_ERROR",
                            "Failed to analyze food: ${error.message}",
                            error.stackTraceToString()
                        )
                    }
                )
            } catch (e: Exception) {
                Log.e(TAG, "Analyze error: ${e.message}", e)
                result.error(
                    "ANALYZE_ERROR",
                    "Exception during analysis: ${e.message}",
                    e.stackTraceToString()
                )
            }
        }
    }
    
    private fun handleIsReady(result: Result) {
        try {
            val isReady = vlmService.isReady()
            result.success(isReady)
        } catch (e: Exception) {
            Log.e(TAG, "isReady error: ${e.message}", e)
            result.success(false)
        }
    }
    
    private fun handleGetModelInfo(result: Result) {
        try {
            val info = vlmService.getModelInfo()
            result.success(info)
        } catch (e: Exception) {
            Log.e(TAG, "getModelInfo error: ${e.message}", e)
            result.error(
                "INFO_ERROR",
                "Failed to get model info: ${e.message}",
                null
            )
        }
    }
    
    private fun handleRelease(result: Result) {
        try {
            vlmService.release()
            result.success(mapOf(
                "success" to true,
                "message" to "VLM model released"
            ))
        } catch (e: Exception) {
            Log.e(TAG, "Release error: ${e.message}", e)
            result.error(
                "RELEASE_ERROR",
                "Failed to release VLM: ${e.message}",
                null
            )
        }
    }
    
    private fun dispose() {
        try {
            coroutineScope.cancel()
            vlmService.release()
            channel.setMethodCallHandler(null)
            Log.d(TAG, "Plugin disposed")
        } catch (e: Exception) {
            Log.e(TAG, "Dispose error: ${e.message}", e)
        }
    }
}
