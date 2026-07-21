package com.kaloree.app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import com.kaloree.app.vlm.RunAnywhereVLMPlugin
import com.kaloree.app.pad.AssetPackPlugin

/**
 * MainActivity - Main entry point for Kaloree Android app.
 *
 * Registers plugins for:
 * - RunAnywhereVLMPlugin: On-device food image analysis
 * - AssetPackPlugin: Play Asset Delivery for AI model files
 */
class MainActivity : FlutterActivity() {
    
    private var assetPackPlugin: AssetPackPlugin? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register VLM plugin for on-device AI
        RunAnywhereVLMPlugin.registerWith(applicationContext, flutterEngine)
        
        // Register Asset Pack plugin for model delivery
        assetPackPlugin = AssetPackPlugin()
        flutterEngine.plugins.add(assetPackPlugin!!)
    }
    
    override fun onDestroy() {
        // Cleanup VLM resources
        RunAnywhereVLMPlugin.cleanup()
        super.onDestroy()
    }
}
