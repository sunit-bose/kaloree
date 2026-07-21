# Kaloree - Claude Context & Technical Debt

> **Branch**: `edgeV0` - On-Device AI Implementation
> **Last Updated**: 2026-07-20

---

## 📋 Project Overview

Kaloree (NutriSnap) is a Flutter-based calorie tracking app that uses AI to analyze food images and provide nutritional information along with 20+ health indicators.

### Current Architecture
- **Cloud AI**: Google Gemini 2.5 Flash API for food image analysis
- **Platform**: Flutter (Android + iOS)
- **Database**: SQLite with Drift ORM
- **State**: Provider pattern

### Target Architecture (edgeV0)
- **On-Device AI**: RunAnywhere SDK with SmolVLM 256M
- **Platform**: Android-first (iOS fallback to cloud)
- **Privacy**: Complete on-device inference, no data leaves phone

---

## 📁 Plan Documents Reference

| Document | Description | Status |
|----------|-------------|--------|
| [`ON_DEVICE_AI_POC_PLAN.md`](plans/ON_DEVICE_AI_POC_PLAN.md) | Complete implementation plan for on-device AI using RunAnywhere SDK | Active |
| [`health_alerts_feature.md`](plans/health_alerts_feature.md) | Health alerts based on nutritional analysis | Implemented |
| [`sqlite_migration_plan.md`](plans/sqlite_migration_plan.md) | SQLite database migration plan | Completed |
| [`cleanup-refactoring-plan.md`](plans/cleanup-refactoring-plan.md) | Code cleanup and refactoring tasks | In Progress |
| [`documentation-cleanup-plan.md`](plans/documentation-cleanup-plan.md) | Documentation improvement plan | Pending |
| [`kaloree-orchestrator-mvp.md`](plans/kaloree-orchestrator-mvp.md) | MVP orchestration plan | Reference |
| [`RELEASE_V2_COMPARISON.md`](plans/RELEASE_V2_COMPARISON.md) | V2 release comparison | Reference |

---

## 🔧 Technical Debt

### 1. LoRA Adapter System (Priority: Medium)

**Description**: Implement LoRA (Low-Rank Adaptation) adapter support for iterative model accuracy improvements without full model updates.

**Architecture**:
```
┌─────────────────────────────────────────────────────────────────────────┐
│  CENTRALIZED TRAINING (Server)                                         │
│  ──────────────────────────────                                        │
│  • Train LoRA adapters on GPU cluster using food image datasets        │
│  • Output: nutrition-lora-v{N}.gguf (~10-20 MB)                       │
│  • Upload to CDN for distribution                                      │
│                                                                         │
│  DISTRIBUTION (CDN)                                                     │
│  ─────────────────                                                      │
│  • API endpoint: /api/lora/latest returns version info                 │
│  • CDN download: ~15 MB per device                                     │
│  • Cost: ~$10-20 per 100K devices per update                          │
│                                                                         │
│  ON-DEVICE (App)                                                        │
│  ──────────────                                                         │
│  • Background check for new LoRA version                               │
│  • Download and hot-swap without app update                            │
│  • RunAnywhere.loadLoRAAdapter(path)                                   │
└─────────────────────────────────────────────────────────────────────────┘
```

**Implementation Tasks**:
- [ ] Create LoRA training pipeline (external, GPU server)
- [ ] Set up CDN for LoRA distribution (CloudFlare/AWS)
- [ ] Create `/api/lora/latest` endpoint
- [ ] Add `LoRAManager.kt` for version checking and downloading
- [ ] Implement hot-swap mechanism in `VLMService.kt`
- [ ] Add background update check on app launch
- [ ] Create user notification for AI updates

**Kotlin Code Reference**:
```kotlin
class LoRAManager(private val context: Context) {
    companion object {
        const val LORA_API = "https://api.kaloree.com/lora/latest"
        const val LORA_PREFS = "lora_preferences"
    }
    
    private var currentVersion: Int = 0
    
    suspend fun checkAndUpdate() {
        try {
            val response = httpClient.get(LORA_API)
            val latest = response.body<LoraInfo>()
            
            if (latest.version > currentVersion) {
                downloadAndApply(latest)
            }
        } catch (e: Exception) {
            // Silent fail - use existing LoRA
        }
    }
    
    private suspend fun downloadAndApply(info: LoraInfo) {
        val localPath = "${context.filesDir}/lora/${info.filename}"
        downloadFile(info.url, localPath)
        
        // Hot-swap LoRA
        RunAnywhere.unloadLoRAAdapter()
        RunAnywhere.loadLoRAAdapter(localPath)
        
        saveVersion(info.version)
    }
}
```

**Expected Accuracy Improvements**:
| Version | Training Data | Accuracy |
|---------|--------------|----------|
| v1.0 | 50K food images | ~75% |
| v2.0 | + 100K images + user feedback | ~82% |
| v3.0 | + Regional cuisines | ~85% |
| v4.0 | + Portion estimation | ~88% |

---

### 2. iOS On-Device AI Support (Priority: Low)

**Description**: RunAnywhere VLM SDK is currently Kotlin-only. iOS requires either:
- Swift port of RunAnywhere SDK
- Alternative framework (Core ML + custom VLM)
- Continue using cloud API for iOS

**Options**:
1. **Wait for RunAnywhere iOS SDK** - Likely 6-12 months
2. **Core ML conversion** - Convert SmolVLM to Core ML format
3. **Hybrid approach** - Android on-device, iOS cloud (current plan)

**Tasks**:
- [ ] Monitor RunAnywhere SDK roadmap for iOS support
- [ ] Evaluate Core ML conversion feasibility
- [ ] Maintain cloud fallback for iOS

---

### 3. Play Asset Delivery (PAD) Integration (Priority: Medium)

**Description**: If APK size (~400 MB with model) causes Play Store issues, implement Play Asset Delivery for on-demand model download.

**Implementation**:
```gradle
// android/app/build.gradle
android {
    assetPacks = [":model_pack"]
}

// android/model_pack/build.gradle
plugins {
    id 'com.android.asset-pack'
}

assetPack {
    packName = "model_pack"
    dynamicDelivery {
        deliveryType = "install-time"  // or "fast-follow"
    }
}
```

**Tasks**:
- [ ] Create asset pack module structure
- [ ] Move model files to asset pack
- [ ] Implement AssetPackManager for download handling
- [ ] Add progress UI for model download
- [ ] Handle offline scenarios gracefully

---

### 4. Model Quantization Optimization (Priority: Low)

**Description**: Current plan uses Q8_0 quantization. Could explore:
- Q4_K_M for smaller size (~180 MB vs ~320 MB)
- Dynamic quantization based on device capabilities

**Trade-offs**:
| Quantization | Size | Quality | Speed |
|--------------|------|---------|-------|
| Q8_0 | ~320 MB | Best | Moderate |
| Q4_K_M | ~180 MB | Good | Faster |
| Q4_0 | ~150 MB | Acceptable | Fastest |

**Tasks**:
- [ ] Benchmark Q4_K_M vs Q8_0 accuracy on food images
- [ ] Implement device capability detection
- [ ] Create quantization selection logic

---

### 5. Offline-First Data Sync (Priority: Medium)

**Description**: Ensure app works completely offline with proper sync when connectivity returns.

**Current Issues**:
- Some features may require network
- User data backup not implemented
- Conflict resolution not defined

**Tasks**:
- [ ] Audit all network-dependent features
- [ ] Implement offline queue for failed operations
- [ ] Add data export/backup functionality
- [ ] Define conflict resolution strategy

---

### 6. User Feedback Collection (Priority: Low)

**Description**: Opt-in system to collect anonymized correction data for improving LoRA training.

**Privacy-Preserving Approach**:
```dart
// Only send if user explicitly opts in
if (userOptedInToFeedback && userMadeCorrection) {
  sendAnonymizedFeedback({
    'predicted_food': 'margherita_pizza',
    'corrected_food': 'pepperoni_pizza',
    'calorie_diff': 65,
    // NO image sent unless explicit consent
  });
}
```

**Tasks**:
- [ ] Design opt-in UI in settings
- [ ] Implement feedback collection service
- [ ] Create privacy policy for data collection
- [ ] Set up aggregation pipeline server-side

---

### 7. Performance Monitoring (Priority: Medium)

**Description**: Track on-device inference performance across devices.

**Metrics to Collect**:
- Inference time (ms)
- Memory usage (MB)
- Device model
- Android version
- Success/failure rate

**Tasks**:
- [ ] Add Firebase Performance or custom analytics
- [ ] Create performance dashboard
- [ ] Set alerts for degraded performance
- [ ] Implement automatic fallback to cloud if on-device fails

---

## 🚀 Implementation Checklist (edgeV0)

### Phase 1: Core On-Device AI
- [ ] Switch to `edgeV0` branch
- [ ] Add RunAnywhere SDK dependencies to `build.gradle`
- [ ] Configure Android `packagingOptions` and JVM memory
- [ ] Download SmolVLM 256M model files
- [ ] Create `VLMService.kt` - Core VLM processing logic
- [ ] Create `RunAnywhereVLMPlugin.kt` - Platform Channel handler
- [ ] Register plugin in `MainActivity.kt`
- [ ] Create `on_device_ai_service.dart` - Flutter bridge
- [ ] Update `LLMService` to use on-device AI for Android

### Phase 2: UI/UX Updates
- [ ] Simplify settings screen (no API key for Android)
- [ ] Add "On-Device AI" badge/indicator
- [ ] Create loading state for model initialization
- [ ] Add fallback UI for model loading failures

### Phase 3: Testing & Validation
- [ ] Test food recognition on 50+ food images
- [ ] Compare SmolVLM vs Gemini accuracy
- [ ] Benchmark inference time on various devices
- [ ] Memory profiling on low-end devices
- [ ] Document findings and quality assessment

### Phase 4: Polish
- [ ] Error handling and graceful degradation
- [ ] User-facing error messages
- [ ] Analytics integration
- [ ] Performance optimization

---

## 📊 Key Metrics to Track

| Metric | Target | Current |
|--------|--------|---------|
| APK Size | < 500 MB | ~35 MB (without model) |
| Model Load Time | < 5 sec | TBD |
| Inference Time | < 3 sec | TBD |
| Memory Usage | < 500 MB | TBD |
| Food Recognition Accuracy | > 75% | TBD |
| Calorie Estimation Error | < 20% | TBD |

---

## 🔗 External Resources

- [RunAnywhere SDK Documentation](https://docs.runanywhere.io)
- [SmolVLM Model Card](https://huggingface.co/HuggingFaceTB/SmolVLM-256M-Instruct)
- [LoRA Paper](https://arxiv.org/abs/2106.09685)
- [Play Asset Delivery](https://developer.android.com/guide/playcore/asset-delivery)

---

## 📝 Notes for Future Claude Sessions

1. **Primary focus**: On-device AI implementation using RunAnywhere SDK
2. **Branch**: All work should be on `edgeV0` branch
3. **Model**: SmolVLM 256M with Q8_0 quantization
4. **Platform priority**: Android first, iOS uses cloud fallback
5. **LoRA**: Deferred to post-MVP, documented above
6. **Key files**:
   - [`lib/services/llm_service.dart`](lib/services/llm_service.dart) - Current Gemini implementation
   - [`plans/ON_DEVICE_AI_POC_PLAN.md`](plans/ON_DEVICE_AI_POC_PLAN.md) - Full implementation plan
