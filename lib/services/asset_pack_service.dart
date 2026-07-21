import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AssetPackService - Flutter Bridge for Play Asset Delivery
///
/// Manages the download and access of the AI model asset pack
/// delivered via Google Play Asset Delivery (PAD).
///
/// The asset pack contains:
/// - smolvlm-256m-instruct-q8_0.gguf (~300 MB)
/// - smolvlm-256m-clip-q8_0.gguf (~65 MB)
///
/// Delivery mode: fast-follow (auto-downloads after app install)
class AssetPackService {
  static const _channel = MethodChannel('com.kaloree.app/pad');
  static const _eventChannel = EventChannel('com.kaloree.app/pad_progress');
  static const packName = 'ai_model_pack';

  static AssetPackService? _instance;
  static AssetPackService get instance => _instance ??= AssetPackService._();
  AssetPackService._();

  StreamSubscription? _progressSubscription;
  final _progressController = StreamController<DownloadProgress>.broadcast();

  /// Stream of download progress updates
  Stream<DownloadProgress> get progressStream => _progressController.stream;

  /// Initialize the event channel listener
  void initProgressListener() {
    if (!Platform.isAndroid) return;

    _progressSubscription?.cancel();
    _progressSubscription = _eventChannel
        .receiveBroadcastStream()
        .map((event) => DownloadProgress.fromMap(Map<String, dynamic>.from(event as Map)))
        .listen(
          (progress) => _progressController.add(progress),
          onError: (error) => debugPrint('AssetPack progress error: $error'),
        );
  }

  /// Check current status of the AI model asset pack
  Future<AssetPackStatus> checkStatus() async {
    if (!Platform.isAndroid) {
      // On iOS, return "completed" as we use cloud API
      return AssetPackStatus(
        status: 'not_applicable',
        progress: 1.0,
        bytesDownloaded: 0,
        totalBytes: 0,
      );
    }

    try {
      final result = await _channel.invokeMethod<Map>('checkStatus');
      if (result == null) {
        return AssetPackStatus.notInstalled();
      }
      return AssetPackStatus.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      debugPrint('AssetPack checkStatus error: ${e.message}');
      return AssetPackStatus.error(e.message ?? 'Unknown error');
    } catch (e) {
      debugPrint('AssetPack checkStatus error: $e');
      return AssetPackStatus.error(e.toString());
    }
  }

  /// Start downloading the AI model asset pack
  Future<bool> startDownload() async {
    if (!Platform.isAndroid) return false;

    try {
      final result = await _channel.invokeMethod<bool>('startDownload');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('AssetPack startDownload error: ${e.message}');
      return false;
    }
  }

  /// Get the path to model files (null if not downloaded)
  Future<String?> getModelPath() async {
    if (!Platform.isAndroid) return null;

    try {
      return await _channel.invokeMethod<String?>('getModelPath');
    } on PlatformException catch (e) {
      debugPrint('AssetPack getModelPath error: ${e.message}');
      return null;
    }
  }

  /// Cancel ongoing download
  Future<bool> cancelDownload() async {
    if (!Platform.isAndroid) return false;

    try {
      final result = await _channel.invokeMethod<bool>('cancelDownload');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('AssetPack cancelDownload error: ${e.message}');
      return false;
    }
  }

  /// Cleanup resources
  void dispose() {
    _progressSubscription?.cancel();
    _progressController.close();
  }
}

/// Status of the AI model asset pack
class AssetPackStatus {
  final String status;
  final double progress;
  final int bytesDownloaded;
  final int totalBytes;
  final String? errorMessage;

  /// Total size of the model pack in bytes (~365 MB)
  static const int expectedTotalBytes = 365 * 1024 * 1024;

  AssetPackStatus({
    required this.status,
    required this.progress,
    required this.bytesDownloaded,
    required this.totalBytes,
    this.errorMessage,
  });

  factory AssetPackStatus.fromMap(Map<String, dynamic> map) {
    final total = map['totalBytes'] as int? ?? 0;
    final downloaded = map['bytesDownloaded'] as int? ?? 0;
    final progress = total > 0 ? downloaded / total : 0.0;

    return AssetPackStatus(
      status: map['status'] as String? ?? 'unknown',
      progress: (map['progress'] as num?)?.toDouble() ?? progress,
      bytesDownloaded: downloaded,
      totalBytes: total,
      errorMessage: map['error'] as String?,
    );
  }

  factory AssetPackStatus.notInstalled() => AssetPackStatus(
        status: 'not_installed',
        progress: 0.0,
        bytesDownloaded: 0,
        totalBytes: expectedTotalBytes,
      );

  factory AssetPackStatus.error(String message) => AssetPackStatus(
        status: 'error',
        progress: 0.0,
        bytesDownloaded: 0,
        totalBytes: 0,
        errorMessage: message,
      );

  bool get isCompleted => status == 'completed';
  bool get isDownloading => status == 'downloading' || status == 'pending';
  bool get isNotInstalled => status == 'not_installed';
  bool get isFailed => status == 'failed' || status == 'error';
  bool get isNotApplicable => status == 'not_applicable';

  String get statusText {
    switch (status) {
      case 'completed':
        return 'Ready';
      case 'downloading':
        return 'Downloading...';
      case 'pending':
        return 'Pending...';
      case 'not_installed':
        return 'Not Downloaded';
      case 'failed':
      case 'error':
        return 'Download Failed';
      case 'not_applicable':
        return 'Cloud API Mode';
      default:
        return 'Unknown';
    }
  }

  String get progressText {
    if (totalBytes == 0) return '';
    final downloadedMB = bytesDownloaded / (1024 * 1024);
    final totalMB = totalBytes / (1024 * 1024);
    return '${downloadedMB.toStringAsFixed(0)} / ${totalMB.toStringAsFixed(0)} MB';
  }

  int get progressPercent => (progress * 100).round();

  @override
  String toString() => 'AssetPackStatus($status, ${progressPercent}%)';
}

/// Real-time download progress
class DownloadProgress {
  final String status;
  final int bytesDownloaded;
  final int totalBytes;
  final double progress;

  DownloadProgress({
    required this.status,
    required this.bytesDownloaded,
    required this.totalBytes,
    required this.progress,
  });

  factory DownloadProgress.fromMap(Map<String, dynamic> map) {
    final total = map['totalBytes'] as int? ?? 0;
    final downloaded = map['bytesDownloaded'] as int? ?? 0;
    final progress = total > 0 ? downloaded / total : 0.0;

    return DownloadProgress(
      status: map['status'] as String? ?? 'unknown',
      bytesDownloaded: downloaded,
      totalBytes: total,
      progress: (map['progress'] as num?)?.toDouble() ?? progress,
    );
  }

  String get progressText {
    final mb = bytesDownloaded / (1024 * 1024);
    final totalMb = totalBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(0)} / ${totalMb.toStringAsFixed(0)} MB';
  }

  int get progressPercent => (progress * 100).round();

  bool get isCompleted => status == 'COMPLETED' || status == 'completed';
  bool get isDownloading => status == 'DOWNLOADING' || status == 'downloading';
  bool get isPending => status == 'PENDING' || status == 'pending';
  bool get isFailed => status == 'FAILED' || status == 'failed';
}

/// Riverpod provider for AssetPackService
final assetPackServiceProvider = Provider<AssetPackService>((ref) {
  final service = AssetPackService.instance;
  service.initProgressListener();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Stream provider for download progress
final assetPackProgressProvider = StreamProvider<DownloadProgress>((ref) {
  final service = ref.watch(assetPackServiceProvider);
  return service.progressStream;
});

/// Future provider for current asset pack status
final assetPackStatusProvider = FutureProvider<AssetPackStatus>((ref) async {
  final service = ref.watch(assetPackServiceProvider);
  return service.checkStatus();
});
