import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'model_status_provider.dart';

/// ModelBootstrapService - Orchestrates model initialization after login
///
/// Flow:
/// 1. Called after successful login (Android only)
/// 2. Checks if model is already available
/// 3. If not, triggers proactive download with retry
/// 4. If download fails after retry, prepares for cloud fallback consent
class ModelBootstrapService {
  final Ref _ref;
  
  ModelBootstrapService(this._ref);
  
  /// Initialize the AI model after login
  /// 
  /// This should be called right after successful login on Android.
  /// On iOS, this does nothing since iOS uses cloud API.
  Future<void> initializeAfterLogin() async {
    // Skip on iOS - uses cloud API
    if (!Platform.isAndroid) {
      debugPrint('ModelBootstrapService: iOS detected, skipping on-device AI init');
      return;
    }
    
    debugPrint('ModelBootstrapService: Starting model initialization after login');
    
    // Trigger proactive download with retry
    final notifier = _ref.read(modelStatusProvider.notifier);
    await notifier.downloadWithRetry();
    
    debugPrint('ModelBootstrapService: Initialization complete');
  }
  
  /// Check if on-device AI is ready to use
  bool get isOnDeviceAIReady {
    if (!Platform.isAndroid) return false;
    
    final status = _ref.read(modelStatusProvider);
    return status.isOnDeviceUsable;
  }
  
  /// Check if cloud fallback is being used
  bool get isUsingCloudFallback {
    final status = _ref.read(modelStatusProvider);
    return status.usingCloud;
  }
  
  /// Check if user needs to consent to cloud fallback
  bool get needsCloudFallbackConsent {
    final status = _ref.read(modelStatusProvider);
    return status.needsCloudFallbackConsent;
  }
  
  /// Set the callback for when cloud fallback consent is needed
  void setCloudFallbackConsentCallback(void Function() callback) {
    if (!Platform.isAndroid) return;
    
    final notifier = _ref.read(modelStatusProvider.notifier);
    notifier.onNeedCloudFallbackConsent = callback;
  }
  
  /// Enable cloud fallback after user consent
  void enableCloudFallback() {
    if (!Platform.isAndroid) return;
    
    final notifier = _ref.read(modelStatusProvider.notifier);
    notifier.enableCloudFallback();
  }
  
  /// Retry model download manually
  Future<void> retryDownload() async {
    if (!Platform.isAndroid) return;
    
    final notifier = _ref.read(modelStatusProvider.notifier);
    await notifier.retryDownload();
  }
}

/// Provider for ModelBootstrapService
final modelBootstrapServiceProvider = Provider<ModelBootstrapService>((ref) {
  return ModelBootstrapService(ref);
});
