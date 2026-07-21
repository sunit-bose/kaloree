// AI Model Asset Pack - Play Asset Delivery Configuration
//
// This asset pack contains the SmolVLM-256M model files for on-device
// food image analysis. Using "fast-follow" delivery mode means the model
// will automatically download after the user installs the app.
//
// Contents:
// - smolvlm-256m-instruct-q8_0.gguf (~300 MB) - Main VLM model
// - smolvlm-256m-clip-q8_0.gguf (~65 MB) - CLIP vision encoder
//
// Total size: ~365 MB
//
// To add model files:
// 1. Place files in: ai-model-pack/src/main/assets/models/
// 2. Build with: flutter build appbundle
// 3. Test locally with bundletool

plugins {
    id("com.android.asset-pack")
}

assetPack {
    packName.set("ai_model_pack")
    dynamicDelivery {
        // fast-follow: Downloads automatically after app installation
        // Alternative options:
        // - install-time: Bundled with initial APK (large download)
        // - on-demand: User must explicitly request download
        deliveryType.set("fast-follow")
    }
}
