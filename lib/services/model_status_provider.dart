import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'asset_pack_service.dart';
import 'on_device_ai_service.dart';

/// ModelStatus - Represents the current state of the on-device AI model
///
/// State machine:
/// notDownloaded → downloading → downloaded → loading → ready
///                                                    ↓
///                                              analyzing
///                                                    ↓
///                                         usingCloudFallback (if error)
sealed class ModelStatus {
  const ModelStatus();

  /// Model files not yet downloaded (PAD not complete)
  const factory ModelStatus.notDownloaded() = ModelStatusNotDownloaded;

  /// Model is being downloaded via PAD
  const factory ModelStatus.downloading({
    required double progress,
    required int bytesDownloaded,
    required int totalBytes,
  }) = ModelStatusDownloading;

  /// Model files downloaded but not loaded into memory
  const factory ModelStatus.downloaded() = ModelStatusDownloaded;

  /// Model is being loaded into memory
  const factory ModelStatus.loading({required double progress}) = ModelStatusLoading;

  /// Model is ready for inference
  const factory ModelStatus.ready({required ModelInfo info}) = ModelStatusReady;

  /// Model is currently analyzing an image
  const factory ModelStatus.analyzing({required Duration elapsed}) = ModelStatusAnalyzing;

  /// Download failed with retry count
  const factory ModelStatus.downloadFailed({
    required String message,
    required int retryCount,
    required int maxRetries,
  }) = ModelStatusDownloadFailed;

  /// Error occurred, can retry
  const factory ModelStatus.error({
    required String message,
    required bool canRetry,
  }) = ModelStatusError;

  /// Using cloud API fallback (on-device not available)
  const factory ModelStatus.usingCloudFallback({required String reason}) = ModelStatusCloudFallback;

  /// Platform doesn't support on-device AI (iOS)
  const factory ModelStatus.notSupported() = ModelStatusNotSupported;
}

class ModelStatusNotDownloaded extends ModelStatus {
  const ModelStatusNotDownloaded();
}

class ModelStatusDownloading extends ModelStatus {
  final double progress;
  final int bytesDownloaded;
  final int totalBytes;

  const ModelStatusDownloading({
    required this.progress,
    required this.bytesDownloaded,
    required this.totalBytes,
  });

  String get progressText {
    final mb = bytesDownloaded / (1024 * 1024);
    final totalMb = totalBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(0)} / ${totalMb.toStringAsFixed(0)} MB';
  }

  int get progressPercent => (progress * 100).round();

  Duration get estimatedTimeRemaining {
    // Rough estimate: assume 2 MB/s download speed
    final remainingBytes = totalBytes - bytesDownloaded;
    final seconds = remainingBytes / (2 * 1024 * 1024);
    return Duration(seconds: seconds.round());
  }
}

class ModelStatusDownloaded extends ModelStatus {
  const ModelStatusDownloaded();
}

class ModelStatusLoading extends ModelStatus {
  final double progress;

  const ModelStatusLoading({required this.progress});

  int get progressPercent => (progress * 100).round();
}

class ModelStatusReady extends ModelStatus {
  final ModelInfo info;

  const ModelStatusReady({required this.info});
}

class ModelStatusAnalyzing extends ModelStatus {
  final Duration elapsed;

  const ModelStatusAnalyzing({required this.elapsed});

  String get elapsedText => '${(elapsed.inMilliseconds / 1000).toStringAsFixed(1)}s';
}

class ModelStatusDownloadFailed extends ModelStatus {
  final String message;
  final int retryCount;
  final int maxRetries;

  const ModelStatusDownloadFailed({
    required this.message,
    required this.retryCount,
    required this.maxRetries,
  });

  bool get canRetry => retryCount < maxRetries;
  bool get needsUserConsent => retryCount >= maxRetries;
}

class ModelStatusError extends ModelStatus {
  final String message;
  final bool canRetry;

  const ModelStatusError({required this.message, required this.canRetry});
}

class ModelStatusCloudFallback extends ModelStatus {
  final String reason;

  const ModelStatusCloudFallback({required this.reason});
}

class ModelStatusNotSupported extends ModelStatus {
  const ModelStatusNotSupported();
}

/// Information about the loaded model
class ModelInfo {
  final String modelName;
  final String quantization;
  final int memorySizeMB;
  final bool isOnDevice;

  const ModelInfo({
    required this.modelName,
    required this.quantization,
    required this.memorySizeMB,
    required this.isOnDevice,
  });

  factory ModelInfo.fromMap(Map<String, dynamic> map) {
    return ModelInfo(
      modelName: map['model'] as String? ?? 'SmolVLM-256M',
      quantization: map['quantization'] as String? ?? 'Q8_0',
      memorySizeMB: map['memoryMB'] as int? ?? 365,
      isOnDevice: map['onDevice'] as bool? ?? true,
    );
  }

  static const defaultInfo = ModelInfo(
    modelName: 'SmolVLM-256M',
    quantization: 'Q8_0',
    memorySizeMB: 365,
    isOnDevice: true,
  );
}

/// ModelStatusNotifier - Manages the model lifecycle state
class ModelStatusNotifier extends StateNotifier<ModelStatus> {
  final AssetPackService _assetPackService;
  final OnDeviceAIService _onDeviceAI;

  StreamSubscription? _progressSubscription;
  Timer? _analysisTimer;
  DateTime? _analysisStartTime;
  
  /// Track retry count for proactive download
  int _downloadRetryCount = 0;
  static const int _maxRetries = 1; // Retry once before fallback consent
  
  /// Callback for when user consent is needed for cloud fallback
  void Function()? onNeedCloudFallbackConsent;

  ModelStatusNotifier({
    required AssetPackService assetPackService,
    required OnDeviceAIService onDeviceAI,
  })  : _assetPackService = assetPackService,
        _onDeviceAI = onDeviceAI,
        super(const ModelStatus.notDownloaded()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Check platform support
    if (!Platform.isAndroid) {
      state = const ModelStatus.notSupported();
      return;
    }

    // Check asset pack status
    await refreshStatus();

    // Listen to download progress
    _progressSubscription = _assetPackService.progressStream.listen(_onDownloadProgress);
  }

  void _onDownloadProgress(DownloadProgress progress) {
    if (progress.isCompleted) {
      state = const ModelStatus.downloaded();
      // Auto-load model when download completes
      loadModel();
    } else if (progress.isDownloading || progress.isPending) {
      state = ModelStatus.downloading(
        progress: progress.progress,
        bytesDownloaded: progress.bytesDownloaded,
        totalBytes: progress.totalBytes,
      );
    } else if (progress.isFailed) {
      state = const ModelStatus.error(
        message: 'Download failed. Please check your connection.',
        canRetry: true,
      );
    }
  }

  /// Refresh the current status from native side
  Future<void> refreshStatus() async {
    if (!Platform.isAndroid) {
      state = const ModelStatus.notSupported();
      return;
    }

    // First check if model is already ready in memory
    final isReady = await _onDeviceAI.checkReady();
    if (isReady) {
      final modelInfo = await _onDeviceAI.getModelInfo();
      state = ModelStatus.ready(
        info: modelInfo != null ? ModelInfo.fromMap(modelInfo) : ModelInfo.defaultInfo,
      );
      return;
    }

    // Check asset pack status
    final packStatus = await _assetPackService.checkStatus();

    if (packStatus.isCompleted) {
      // Downloaded but not loaded
      state = const ModelStatus.downloaded();
    } else if (packStatus.isDownloading) {
      state = ModelStatus.downloading(
        progress: packStatus.progress,
        bytesDownloaded: packStatus.bytesDownloaded,
        totalBytes: packStatus.totalBytes,
      );
    } else if (packStatus.isNotInstalled) {
      state = const ModelStatus.notDownloaded();
    } else if (packStatus.isFailed) {
      state = ModelStatus.error(
        message: packStatus.errorMessage ?? 'Download failed',
        canRetry: true,
      );
    } else if (packStatus.isNotApplicable) {
      state = const ModelStatus.notSupported();
    }
  }

  /// Start downloading the model via PAD
  Future<void> startDownload() async {
    if (!Platform.isAndroid) return;

    state = const ModelStatus.downloading(
      progress: 0.0,
      bytesDownloaded: 0,
      totalBytes: AssetPackStatus.expectedTotalBytes,
    );

    final success = await _assetPackService.startDownload();
    if (!success) {
      state = const ModelStatus.error(
        message: 'Could not start download. Please try again.',
        canRetry: true,
      );
    }
  }

  /// Load the model into memory
  Future<void> loadModel() async {
    if (!Platform.isAndroid) return;

    state = const ModelStatus.loading(progress: 0.0);

    try {
      // Simulate loading progress (actual loading happens in native code)
      for (var i = 1; i <= 5; i++) {
        await Future.delayed(const Duration(milliseconds: 400));
        if (state is! ModelStatusLoading) return; // Cancelled
        state = ModelStatus.loading(progress: i * 0.2);
      }

      final success = await _onDeviceAI.initialize();

      if (success) {
        final modelInfo = await _onDeviceAI.getModelInfo();
        state = ModelStatus.ready(
          info: modelInfo != null ? ModelInfo.fromMap(modelInfo) : ModelInfo.defaultInfo,
        );
      } else {
        state = const ModelStatus.usingCloudFallback(
          reason: 'Model not available. Using cloud AI instead.',
        );
      }
    } catch (e) {
      debugPrint('Model load error: $e');
      state = const ModelStatus.usingCloudFallback(
        reason: 'Failed to load model. Using cloud AI instead.',
      );
    }
  }

  /// Mark that analysis has started
  void startAnalysis() {
    _analysisStartTime = DateTime.now();
    state = const ModelStatus.analyzing(elapsed: Duration.zero);

    // Update elapsed time every 100ms
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_analysisStartTime != null) {
        state = ModelStatus.analyzing(
          elapsed: DateTime.now().difference(_analysisStartTime!),
        );
      }
    });
  }

  /// Mark that analysis has completed
  void endAnalysis() {
    _analysisTimer?.cancel();
    _analysisTimer = null;
    _analysisStartTime = null;

    // Return to ready state
    refreshStatus();
  }

  /// Switch to cloud fallback mode
  void useCloudFallback(String reason) {
    state = ModelStatus.usingCloudFallback(reason: reason);
  }

  /// Cancel ongoing download
  Future<void> cancelDownload() async {
    await _assetPackService.cancelDownload();
    state = const ModelStatus.notDownloaded();
  }

  /// Retry after error
  Future<void> retry() async {
    await refreshStatus();

    if (state is ModelStatusNotDownloaded) {
      await startDownload();
    } else if (state is ModelStatusDownloaded) {
      await loadModel();
    }
  }
  
  /// Proactive download with automatic retry (called after login)
  ///
  /// Flow:
  /// 1. Check if model already available → load it
  /// 2. If not → download
  /// 3. If download fails → retry once
  /// 4. If retry fails → trigger cloud fallback consent
  Future<void> downloadWithRetry() async {
    if (!Platform.isAndroid) {
      state = const ModelStatus.notSupported();
      return;
    }
    
    debugPrint('ModelStatusNotifier: Starting proactive download flow');
    _downloadRetryCount = 0;
    
    // First check current status
    await refreshStatus();
    
    // If already ready, nothing to do
    if (state is ModelStatusReady) {
      debugPrint('ModelStatusNotifier: Model already ready');
      return;
    }
    
    // If downloaded but not loaded, load it
    if (state is ModelStatusDownloaded) {
      debugPrint('ModelStatusNotifier: Model downloaded, loading...');
      await loadModel();
      return;
    }
    
    // If already downloading, just monitor
    if (state is ModelStatusDownloading) {
      debugPrint('ModelStatusNotifier: Already downloading, monitoring...');
      return;
    }
    
    // Need to download
    if (state is ModelStatusNotDownloaded || state is ModelStatusDownloadFailed) {
      await _attemptDownloadWithRetry();
    }
  }
  
  /// Attempt download with automatic retry on failure
  Future<void> _attemptDownloadWithRetry() async {
    debugPrint('ModelStatusNotifier: Attempting download (retry: $_downloadRetryCount/$_maxRetries)');
    
    state = const ModelStatus.downloading(
      progress: 0.0,
      bytesDownloaded: 0,
      totalBytes: AssetPackStatus.expectedTotalBytes,
    );
    
    final success = await _assetPackService.startDownload();
    
    if (!success) {
      _downloadRetryCount++;
      
      if (_downloadRetryCount <= _maxRetries) {
        // Retry after a short delay
        debugPrint('ModelStatusNotifier: Download failed, retrying in 2s...');
        await Future.delayed(const Duration(seconds: 2));
        await _attemptDownloadWithRetry();
      } else {
        // Max retries reached, need user consent for cloud fallback
        debugPrint('ModelStatusNotifier: Max retries reached, needs user consent');
        state = ModelStatus.downloadFailed(
          message: 'Unable to download AI model. Check your connection.',
          retryCount: _downloadRetryCount,
          maxRetries: _maxRetries,
        );
        // Trigger callback for showing consent dialog
        onNeedCloudFallbackConsent?.call();
      }
    }
    // If success, the progress listener will handle state updates
  }
  
  /// Enable cloud fallback after user consent
  void enableCloudFallback() {
    debugPrint('ModelStatusNotifier: User consented to cloud fallback');
    state = const ModelStatus.usingCloudFallback(
      reason: 'Using cloud AI (user choice)',
    );
  }
  
  /// Reset retry count and try downloading again (manual retry from settings)
  Future<void> retryDownload() async {
    _downloadRetryCount = 0;
    await downloadWithRetry();
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    _analysisTimer?.cancel();
    super.dispose();
  }
}

/// Provider for model status
final modelStatusProvider = StateNotifierProvider<ModelStatusNotifier, ModelStatus>((ref) {
  final assetPackService = ref.watch(assetPackServiceProvider);
  final onDeviceAI = OnDeviceAIService.instance;

  return ModelStatusNotifier(
    assetPackService: assetPackService,
    onDeviceAI: onDeviceAI,
  );
});

/// Convenience getters for specific states
extension ModelStatusExtensions on ModelStatus {
  bool get isReady => this is ModelStatusReady;
  bool get isAnalyzing => this is ModelStatusAnalyzing;
  bool get isDownloading => this is ModelStatusDownloading;
  bool get isLoading => this is ModelStatusLoading;
  bool get isError => this is ModelStatusError;
  bool get isDownloadFailed => this is ModelStatusDownloadFailed;
  bool get isCloudFallback => this is ModelStatusCloudFallback;
  bool get isNotSupported => this is ModelStatusNotSupported;
  bool get needsDownload => this is ModelStatusNotDownloaded;

  /// Whether on-device AI is usable (ready or analyzing)
  bool get isOnDeviceUsable => isReady || isAnalyzing;

  /// Whether cloud fallback is active
  bool get usingCloud => isCloudFallback || isNotSupported;
  
  /// Whether user needs to consent to cloud fallback
  bool get needsCloudFallbackConsent {
    if (this is ModelStatusDownloadFailed) {
      return (this as ModelStatusDownloadFailed).needsUserConsent;
    }
    return false;
  }

  /// Short status text for badges
  String get badgeText {
    return switch (this) {
      ModelStatusNotDownloaded() => 'Download AI',
      ModelStatusDownloading(progressPercent: var p) => 'Downloading $p%',
      ModelStatusDownloaded() => 'Tap to Load',
      ModelStatusLoading(progressPercent: var p) => 'Loading $p%',
      ModelStatusReady() => 'On-Device AI Ready',
      ModelStatusAnalyzing(elapsedText: var t) => 'Analyzing... $t',
      ModelStatusDownloadFailed() => 'Download Failed',
      ModelStatusError(message: var m) => 'Error: $m',
      ModelStatusCloudFallback() => 'Cloud AI',
      ModelStatusNotSupported() => 'Cloud AI (iOS)',
    };
  }

  /// Icon name for the status
  String get iconName {
    return switch (this) {
      ModelStatusNotDownloaded() => 'download',
      ModelStatusDownloading() => 'downloading',
      ModelStatusDownloaded() => 'check_circle_outline',
      ModelStatusLoading() => 'hourglass_top',
      ModelStatusReady() => 'smartphone',
      ModelStatusAnalyzing() => 'auto_awesome',
      ModelStatusDownloadFailed() => 'cloud_off',
      ModelStatusError() => 'error_outline',
      ModelStatusCloudFallback() => 'cloud',
      ModelStatusNotSupported() => 'cloud',
    };
  }
}
