package com.kaloree.app.pad

import android.content.Context
import android.content.pm.ApplicationInfo
import android.util.Log
import com.google.android.play.core.assetpacks.AssetPackManager
import com.google.android.play.core.assetpacks.AssetPackManagerFactory
import com.google.android.play.core.assetpacks.AssetPackState
import com.google.android.play.core.assetpacks.AssetPackStateUpdateListener
import com.google.android.play.core.assetpacks.AssetPackStates
import com.google.android.play.core.assetpacks.model.AssetPackStatus
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext

/**
 * AssetPackPlugin - Flutter Plugin for Play Asset Delivery
 *
 * Manages the download and access of the AI model asset pack
 * delivered via Google Play Asset Delivery (PAD).
 *
 * Development Mode:
 *   - In debug builds, bypasses PAD entirely
 *   - Returns "completed" status immediately
 *   - Uses context.filesDir/models/ path
 *   - Allows local testing without Play Store
 *
 * Production Mode:
 *   - Uses real PAD to download models
 *   - Requires app to be published on Play Store
 *
 * Asset Pack: ai_model_pack (fast-follow delivery)
 * Contents:
 *   - smolvlm-256m-instruct-q8_0.gguf (~300 MB)
 *   - smolvlm-256m-clip-q8_0.gguf (~65 MB)
 */
class AssetPackPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    
    companion object {
        private const val TAG = "AssetPackPlugin"
        private const val METHOD_CHANNEL = "com.kaloree.app/pad"
        private const val EVENT_CHANNEL = "com.kaloree.app/pad_progress"
        private const val PACK_NAME = "ai_model_pack"
    }
    
    // Development mode flag - bypasses PAD in debug builds
    // Uses ApplicationInfo flag instead of BuildConfig for reliability
    private val isDevMode: Boolean
        get() = if (::context.isInitialized) {
            (context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
        } else {
            false
        }
    
    private lateinit var context: Context
    private lateinit var assetPackManager: AssetPackManager
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
    private var progressSink: EventChannel.EventSink? = null
    private var stateUpdateListener: AssetPackStateUpdateListener? = null
    
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        
        // Only initialize PAD manager in production mode
        if (!isDevMode) {
            assetPackManager = AssetPackManagerFactory.getInstance(context)
        }
        
        // Setup method channel
        methodChannel = MethodChannel(binding.binaryMessenger, METHOD_CHANNEL)
        methodChannel.setMethodCallHandler(this)
        
        // Setup event channel for progress updates
        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL)
        eventChannel.setStreamHandler(this)
        
        if (isDevMode) {
            Log.d(TAG, "🔧 AssetPackPlugin attached in DEVELOPMENT MODE - PAD bypassed")
        } else {
            Log.d(TAG, "AssetPackPlugin attached to engine (Production mode)")
        }
    }
    
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        unregisterListener()
        scope.cancel()
        Log.d(TAG, "AssetPackPlugin detached from engine")
    }
    
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "checkStatus" -> checkStatus(result)
            "startDownload" -> startDownload(result)
            "getModelPath" -> getModelPath(result)
            "cancelDownload" -> cancelDownload(result)
            else -> result.notImplemented()
        }
    }
    
    // ==================== EventChannel StreamHandler ====================
    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        progressSink = events
        registerListener()
    }
    
    override fun onCancel(arguments: Any?) {
        progressSink = null
        unregisterListener()
    }
    
    // ==================== Method Implementations ====================
    
    /**
     * Check the current status of the asset pack
     *
     * In dev mode: Always returns "completed" (models are "ready")
     * In prod mode: Checks actual PAD status
     */
    private fun checkStatus(result: MethodChannel.Result) {
        // Development mode - bypass PAD, return completed immediately
        if (isDevMode) {
            Log.d(TAG, "🔧 DEV MODE: Returning 'completed' status (PAD bypassed)")
            result.success(mapOf(
                "status" to "completed",
                "progress" to 1.0,
                "bytesDownloaded" to 365L * 1024 * 1024,
                "totalBytes" to 365L * 1024 * 1024,
                "devMode" to true
            ))
            return
        }
        
        // Production mode - check actual PAD status
        scope.launch {
            try {
                val packStates = withContext(Dispatchers.IO) {
                    assetPackManager.getPackStates(listOf(PACK_NAME)).await()
                }
                val state = packStates.packStates()[PACK_NAME]
                
                val response = buildStatusMap(state)
                result.success(response)
                
            } catch (e: Exception) {
                Log.e(TAG, "Error checking status: ${e.message}", e)
                result.success(mapOf(
                    "status" to "error",
                    "progress" to 0.0,
                    "bytesDownloaded" to 0L,
                    "totalBytes" to 0L,
                    "error" to (e.message ?: "Unknown error")
                ))
            }
        }
    }
    
    /**
     * Start downloading the asset pack
     *
     * In dev mode: Returns success immediately (no download needed)
     * In prod mode: Initiates actual PAD download
     */
    private fun startDownload(result: MethodChannel.Result) {
        // Development mode - no download needed
        if (isDevMode) {
            Log.d(TAG, "🔧 DEV MODE: Download skipped (PAD bypassed)")
            result.success(true)
            return
        }
        
        // Production mode - start actual download
        try {
            Log.d(TAG, "Starting asset pack download: $PACK_NAME")
            assetPackManager.fetch(listOf(PACK_NAME))
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error starting download: ${e.message}", e)
            result.success(false)
        }
    }
    
    /**
     * Get the path to the downloaded model files
     *
     * In dev mode: Returns context.filesDir/models/ path
     * In prod mode: Returns actual PAD asset path
     */
    private fun getModelPath(result: MethodChannel.Result) {
        // Development mode - return filesDir path
        if (isDevMode) {
            val devModelPath = "${context.filesDir.absolutePath}/models/"
            Log.d(TAG, "🔧 DEV MODE: Model path: $devModelPath")
            result.success(devModelPath)
            return
        }
        
        // Production mode - get actual PAD path
        scope.launch {
            try {
                val location = assetPackManager.getPackLocation(PACK_NAME)
                
                if (location != null) {
                    val basePath = location.assetsPath()
                    val modelPath = "$basePath/models/"
                    Log.d(TAG, "Model path: $modelPath")
                    result.success(modelPath)
                } else {
                    Log.d(TAG, "Asset pack not available")
                    result.success(null)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error getting model path: ${e.message}", e)
                result.success(null)
            }
        }
    }
    
    /**
     * Cancel ongoing download
     *
     * In dev mode: Returns success immediately (nothing to cancel)
     * In prod mode: Cancels actual PAD download
     */
    private fun cancelDownload(result: MethodChannel.Result) {
        // Development mode - nothing to cancel
        if (isDevMode) {
            Log.d(TAG, "🔧 DEV MODE: Cancel skipped (no download in progress)")
            result.success(true)
            return
        }
        
        // Production mode - cancel actual download
        try {
            Log.d(TAG, "Cancelling asset pack download")
            assetPackManager.cancel(listOf(PACK_NAME))
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error cancelling download: ${e.message}", e)
            result.success(false)
        }
    }
    
    // ==================== Progress Listener ====================
    
    private fun registerListener() {
        // Skip listener in dev mode
        if (isDevMode) {
            Log.d(TAG, "🔧 DEV MODE: Progress listener skipped")
            return
        }
        
        if (stateUpdateListener != null) return
        
        stateUpdateListener = AssetPackStateUpdateListener { state: AssetPackState ->
            handleStateUpdate(state)
        }
        assetPackManager.registerListener(stateUpdateListener!!)
        Log.d(TAG, "Registered state update listener")
    }
    
    private fun unregisterListener() {
        // Skip in dev mode
        if (isDevMode) return
        
        stateUpdateListener?.let {
            assetPackManager.unregisterListener(it)
            stateUpdateListener = null
            Log.d(TAG, "Unregistered state update listener")
        }
    }
    
    private fun handleStateUpdate(state: AssetPackState) {
        // Only handle updates for our pack
        if (state.name() != PACK_NAME) return
        
        val progressMap = buildStatusMap(state)
        Log.d(TAG, "Progress update: ${progressMap["status"]} - ${progressMap["progress"]}")
        
        progressSink?.success(progressMap)
    }
    
    // ==================== Helper Methods ====================
    
    private fun buildStatusMap(state: AssetPackState?): Map<String, Any?> {
        if (state == null) {
            return mapOf(
                "status" to "not_installed",
                "progress" to 0.0,
                "bytesDownloaded" to 0L,
                "totalBytes" to 365L * 1024 * 1024 // Estimated size
            )
        }
        
        val totalBytes = state.totalBytesToDownload()
        val bytesDownloaded = state.bytesDownloaded()
        val progress = if (totalBytes > 0) {
            bytesDownloaded.toDouble() / totalBytes.toDouble()
        } else {
            0.0
        }
        
        val statusString = when (state.status()) {
            AssetPackStatus.UNKNOWN -> "unknown"
            AssetPackStatus.PENDING -> "pending"
            AssetPackStatus.DOWNLOADING -> "downloading"
            AssetPackStatus.TRANSFERRING -> "transferring"
            AssetPackStatus.COMPLETED -> "completed"
            AssetPackStatus.FAILED -> "failed"
            AssetPackStatus.CANCELED -> "canceled"
            AssetPackStatus.WAITING_FOR_WIFI -> "waiting_for_wifi"
            AssetPackStatus.NOT_INSTALLED -> "not_installed"
            AssetPackStatus.REQUIRES_USER_CONFIRMATION -> "requires_confirmation"
            else -> "unknown"
        }
        
        return mapOf(
            "status" to statusString,
            "progress" to progress,
            "bytesDownloaded" to bytesDownloaded,
            "totalBytes" to totalBytes,
            "errorCode" to state.errorCode()
        )
    }
}
