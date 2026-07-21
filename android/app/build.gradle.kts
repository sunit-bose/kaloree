plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase Google Services plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.kaloree.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
        // Increase heap size for RunAnywhere SDK compilation
        freeCompilerArgs += listOf("-Xmx4g")
    }

    defaultConfig {
        // Kaloree - AI-Powered Calorie Tracking
        applicationId = "com.kaloree.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 26  // RunAnywhere VLM requires API 26+
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Enable native libraries for RunAnywhere
        ndk {
            abiFilters += listOf("arm64-v8a", "armeabi-v7a", "x86_64")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    
    // ============================================================
    // PLAY ASSET DELIVERY (PAD) CONFIGURATION
    // ============================================================
    // The AI model is delivered as a "fast-follow" asset pack
    // to keep the base APK small (~30MB instead of ~430MB).
    //
    // Asset Pack: ai_model_pack
    // Delivery: fast-follow (auto-downloads after install)
    // Size: ~365 MB (SmolVLM-256M model files)
    // ============================================================
    assetPacks += listOf(":ai-model-pack")
    
    bundle {
        language {
            enableSplit = true
        }
        density {
            enableSplit = true
        }
        abi {
            enableSplit = true
        }
    }
    
    // Packaging options for RunAnywhere native libraries
    packaging {
        jniLibs {
            useLegacyPackaging = true
            // Exclude duplicate native libraries
            pickFirsts += listOf(
                "lib/arm64-v8a/libc++_shared.so",
                "lib/armeabi-v7a/libc++_shared.so",
                "lib/x86_64/libc++_shared.so"
            )
        }
        resources {
            excludes += listOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt"
            )
        }
    }
    
    // Enable large heap for model loading
    defaultConfig {
        manifestPlaceholders["largeHeap"] = "true"
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ============================================================
    // PLAY ASSET DELIVERY (PAD)
    // ============================================================
    // For delivering the AI model as a separate asset pack
    implementation("com.google.android.play:asset-delivery:2.2.1")
    implementation("com.google.android.play:asset-delivery-ktx:2.2.1")
    
    // Kotlin coroutines with Play Services support (for await())
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-play-services:1.7.3")
    
    // ============================================================
    // ON-DEVICE VLM SDK - INTEGRATION PENDING
    // ============================================================
    // The RunAnywhere VLM SDK is not yet publicly available.
    // When a real on-device VLM SDK becomes available, add it here.
    //
    // Options to consider:
    // 1. llama-android (llama.cpp bindings): https://github.com/aspect/llama-android
    // 2. MLC LLM: https://github.com/mlc-ai/mlc-llm
    // 3. MediaPipe LLM: https://developers.google.com/mediapipe
    // 4. Custom llama.cpp JNI wrapper
    //
    // Example (when available):
    // implementation("com.example:vlm-android:1.0.0")
    // ============================================================
    
    // JSON parsing for structured output
    implementation("com.google.code.gson:gson:2.10.1")
}
