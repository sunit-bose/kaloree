# Kaloree App Size Reduction Plan

**Current Size:** ~90MB  
**Target Size:** ~25-35MB (60-70% reduction)  
**Status:** Ready for implementation

---

## 📊 Size Analysis

### Current Contributors
1. **ML Kit Libraries (~30-40MB)**
   - [`google_mlkit_image_labeling`](../pubspec.yaml:32) - Food detection
   - [`google_mlkit_text_recognition`](../pubspec.yaml:33) - Nutrition label OCR
   - Native libraries for different CPU architectures

2. **CSV Asset Files (~1-2MB)**
   - [`Indian_Food_Nutrition_Processed.csv`](../assets/data/Indian_Food_Nutrition_Processed.csv) - 1,014 recipes
   - [`sample_indian_foods.csv`](../assets/data/sample_indian_foods.csv) - Duplicate data

3. **Unoptimized Build (~20-30MB)**
   - No code shrinking enabled
   - No resource shrinking enabled
   - Debug symbols included
   - Unused code not removed

4. **Multi-Architecture Binaries (~10-15MB)**
   - APK includes ARM, ARM64, x86, x86_64 libraries
   - Most devices only need one architecture

---

## 🎯 Reduction Strategies

### Priority 1: Build Optimization (HIGH IMPACT - 40-50MB reduction)

#### 1.1 Enable ProGuard/R8 Code Shrinking
**Impact:** 15-20MB reduction

Update [`android/app/build.gradle.kts`](../android/app/build.gradle.kts):

```kotlin
android {
    // ... existing config ...
    
    buildTypes {
        release {
            // Enable code shrinking, obfuscation, and optimization
            isMinifyEnabled = true
            isShrinkResources = true
            
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
```

Create `android/app/proguard-rules.pro`:

```proguard
# Keep Flutter framework classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep ML Kit classes
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Keep Drift/SQLite classes
-keep class drift.** { *; }
-keep class com.simolus.** { *; }

# Keep Riverpod classes
-keep class riverpod.** { *; }

# Preserve generic signatures (for Kotlin coroutines)
-keepattributes Signature
-keepattributes *Annotation*
```

#### 1.2 Use App Bundles (AAB) Instead of APK
**Impact:** 15-25MB reduction (Google Play splits by device)

Build command change:
```bash
# Instead of: flutter build apk --release
flutter build appbundle --release
```

Benefits:
- Google Play delivers optimized APK per device
- Only includes needed screen densities
- Only includes needed CPU architecture
- Only includes needed languages

#### 1.3 Split APKs by ABI (If using APK)
**Impact:** 10-15MB reduction per architecture

Update [`android/app/build.gradle.kts`](../android/app/build.gradle.kts):

```kotlin
android {
    // ... existing config ...
    
    splits {
        abi {
            isEnable = true
            reset()
            include("armeabi-v7a", "arm64-v8a", "x86", "x86_64")
            isUniversalApk = false // Don't generate universal APK
        }
    }
}
```

---

### Priority 2: Asset Optimization (MEDIUM IMPACT - 1-2MB reduction)

#### 2.1 Remove Large CSV After Import
**Impact:** 1-2MB reduction

The [`Indian_Food_Nutrition_Processed.csv`](../assets/data/Indian_Food_Nutrition_Processed.csv) is only needed during first run to populate SQLite database.

**Options:**

**Option A: Remove CSV from bundle** (Recommended)
- Move CSV to cloud storage (Firebase Storage, GitHub raw, etc.)
- Download on first run if database is empty
- Show progress indicator during download

**Option B: Keep only essential CSV**
- Keep only [`sample_indian_foods.csv`](../assets/data/sample_indian_foods.csv) (smaller subset)
- Remove large CSV file

**Option C: Compress CSV**
- Use gzip compression
- Decompress during import

**Recommendation:** Option A - This is industry standard practice.

#### 2.2 Optimize Image Assets
**Impact:** 0.5-1MB reduction

Check current image sizes:
- [`kaloree_app_logo.png`](../assets/images/kaloree_app_logo.png)
- [`kaloree_logo.png`](../assets/images/kaloree_logo.png)

Actions:
1. Convert to WebP format (better compression)
2. Use appropriate resolution (don't over-size)
3. Remove unused image resources

---

### Priority 3: Dependency Optimization (LOW-MEDIUM IMPACT - 5-10MB reduction)

#### 3.1 Use ML Kit Dynamic Feature Modules
**Impact:** 5-10MB reduction (models downloaded on-demand)

Currently, ML Kit models are bundled with the app. Consider:
- Download models on first use
- Show one-time setup screen
- Cache models locally after download

This is more complex but significantly reduces initial download size.

#### 3.2 Review Dependencies
**Current dependencies are lean** - No obvious bloat detected in [`pubspec.yaml`](../pubspec.yaml).

All dependencies are essential:
- ✅ ML Kit (core feature)
- ✅ Drift (efficient SQLite ORM)
- ✅ Riverpod (lightweight state management)
- ✅ Camera (core feature)
- ✅ Other utilities are small

---

## 📋 Implementation Checklist

### Phase 1: Quick Wins (Can implement immediately)
- [ ] Enable `minifyEnabled` and `shrinkResources` in release build
- [ ] Create ProGuard rules file
- [ ] Test release build thoroughly
- [ ] Switch to App Bundle (AAB) for distribution
- [ ] Remove `Indian_Food_Nutrition_Processed.csv` from assets

### Phase 2: Medium-term improvements
- [ ] Implement CSV download on first run (if removed from bundle)
- [ ] Optimize logo images to WebP format
- [ ] Add ABI splits configuration
- [ ] Test on multiple devices/architectures

### Phase 3: Advanced optimizations (Optional)
- [ ] Implement ML Kit dynamic feature modules
- [ ] Set up cloud storage for large assets
- [ ] Implement background model downloads

---

## 📏 Expected Results

| Optimization | Size Reduction | Effort | Priority |
|-------------|----------------|--------|----------|
| ProGuard/R8 + Resource Shrinking | 15-20MB | Low | ⭐⭐⭐ |
| App Bundle (AAB) | 15-25MB | Very Low | ⭐⭐⭐ |
| Remove Large CSV | 1-2MB | Low | ⭐⭐ |
| ABI Splits | 10-15MB | Low | ⭐⭐ |
| Image Optimization | 0.5-1MB | Low | ⭐ |
| ML Kit Dynamic Modules | 5-10MB | Medium-High | ⭐ |

**Total Potential Reduction:** 47-73MB  
**Expected Final Size:** 17-43MB (from 90MB)

---

## ⚠️ Testing Considerations

After implementing size optimizations, thoroughly test:

1. **App Functionality**
   - Camera capture works
   - ML Kit food detection works
   - ML Kit OCR (nutrition labels) works
   - Database queries work
   - Search functionality works
   - All navigation flows work

2. **ProGuard Issues**
   - Watch for runtime crashes due to over-aggressive shrinking
   - Test all Dart↔️Native interactions
   - Verify JSON serialization works
   - Check if any reflection is broken

3. **Performance**
   - App startup time
   - First ML Kit inference time (if models download on-demand)
   - Database initialization time

4. **Different Devices**
   - Test on various Android versions
   - Test on different CPU architectures
   - Test on low-end devices

---

## 🚀 Recommended Implementation Order

### Week 1: Phase 1 (Immediate Impact)
1. ✅ Enable ProGuard/R8 code shrinking
2. ✅ Enable resource shrinking
3. ✅ Create ProGuard rules
4. ✅ Build and test release APK
5. ✅ Switch to App Bundle (AAB)

**Expected Result:** 30-45MB reduction → App size: 45-60MB

### Week 2: Phase 2 (Fine-tuning)
6. ✅ Remove large CSV or implement download
7. ✅ Optimize images to WebP
8. ✅ Add ABI splits configuration
9. ✅ Comprehensive device testing

**Expected Result:** Additional 12-18MB reduction → App size: 27-48MB

### Future: Phase 3 (Advanced - Optional)
10. ⚠️ Implement ML Kit dynamic modules (complex)
11. ⚠️ Set up cloud asset delivery

**Expected Result:** Additional 5-10MB reduction → App size: 17-43MB

---

## 📝 Notes

1. **App Bundle is Mandatory for Google Play** (from August 2021)
   - You should use AAB anyway for Play Store distribution
   - Can still build APK for testing or alternative stores

2. **ProGuard/R8 is Standard Practice**
   - All production Android apps should use code shrinking
   - It's safe when configured correctly
   - Improves security by obfuscating code

3. **CSV Data Strategy**
   - Currently both CSV files exist: need to decide which to keep
   - Database is already populated from CSV on first run
   - CSV files serve no purpose after initial import
   - Can be removed entirely or downloaded on-demand

4. **ML Kit Model Sizes**
   - Image labeling model: ~15-20MB
   - Text recognition model: ~10-15MB
   - These are the largest unavoidable components
   - Dynamic download can help but adds complexity

---

## 🔧 Quick Start: Minimal Changes for Maximum Impact

If you want immediate results with minimal risk, just do these 3 things:

1. **Update [`android/app/build.gradle.kts`](../android/app/build.gradle.kts):**
   ```kotlin
   release {
       isMinifyEnabled = true
       isShrinkResources = true
       proguardFiles(
           getDefaultProguardFile("proguard-android-optimize.txt"),
           "proguard-rules.pro"
       )
       signingConfig = signingConfigs.getByName("debug")
   }
   ```

2. **Create `android/app/proguard-rules.pro`** (see section 1.1 above)

3. **Delete [`assets/data/Indian_Food_Nutrition_Processed.csv`](../assets/data/Indian_Food_Nutrition_Processed.csv)**
   - Database is already populated
   - CSV is never used after first launch

**Expected Immediate Reduction:** 16-22MB  
**New App Size:** 68-74MB  
**Implementation Time:** 15 minutes  
**Risk Level:** Low

---

## 📚 References

- [Android App Bundle Documentation](https://developer.android.com/guide/app-bundle)
- [ProGuard/R8 Shrinking Guide](https://developer.android.com/studio/build/shrink-code)
- [Flutter Build Modes](https://docs.flutter.dev/perf/app-size)
- [ML Kit Best Practices](https://developers.google.com/ml-kit/tips-best-practices)

---

**Last Updated:** 2025-12-24  
**Status:** ✅ Ready for Implementation  
**Next Steps:** Review plan → Implement Phase 1 → Test → Measure results
