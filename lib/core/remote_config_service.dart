import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Remote Config Service - Firebase Remote Config wrapper
/// 
/// CRITICAL: Non-blocking implementation
/// - loadCached() returns immediately with cached values
/// - fetchAndActivateInBackground() does NOT block UI
/// 
/// Default values are used until first successful fetch.
class RemoteConfigService {
  late final FirebaseRemoteConfig _remoteConfig;
  bool _isInitialized = false;

  // Default parameter keys
  static const _adsEnabled = 'ads_enabled';
  static const _bannerEnabled = 'banner_enabled';
  static const _interstitialEnabled = 'interstitial_enabled';
  static const _rewardedEnabled = 'rewarded_enabled';
  static const _adsMinSessionsBeforeShow = 'ads_min_sessions_before_show';
  
  // Feature flags
  static const _premiumFeaturesEnabled = 'premium_features_enabled';
  static const _maintenanceMode = 'maintenance_mode';

  /// Default values - used when config not fetched
  static final Map<String, dynamic> _defaults = {
    _adsEnabled: false,
    _bannerEnabled: false,
    _interstitialEnabled: false,
    _rewardedEnabled: false,
    _adsMinSessionsBeforeShow: 5,
    _premiumFeaturesEnabled: false,
    _maintenanceMode: false,
  };

  bool get isInitialized => _isInitialized;

  /// Load cached values immediately (non-blocking)
  /// 
  /// Returns default values if no cache exists.
  /// Safe to call before Firebase is fully initialized.
  Future<void> loadCached() async {
    if (_isInitialized) return;
    
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      
      // Set defaults immediately
      await _remoteConfig.setDefaults(_defaults);
      
      // Configure settings for production
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      
      _isInitialized = true;
    } catch (e) {
      print('⚠️ Remote Config cache load failed: $e');
      // Still mark as initialized - we have defaults
      _isInitialized = true;
    }
  }

  /// Fetch and activate in background (non-blocking)
  /// 
  /// CRITICAL: This method does NOT await the fetch result.
  /// Values are applied when fetch completes, without blocking UI.
  void fetchAndActivateInBackground() {
    if (!_isInitialized) return;
    
    // Fire and forget - do NOT await
    _remoteConfig.fetchAndActivate().then((_) {
      print('✅ Remote Config fetched and activated');
    }).catchError((e) {
      print('⚠️ Remote Config fetch failed: $e');
      // Silent fail - cached values still work
    });
  }

  // ============================================
  // AD CONFIGURATION
  // ============================================

  /// Check if any ads are enabled
  bool get adsEnabled {
    if (!_isInitialized) return false;
    return _remoteConfig.getBool(_adsEnabled);
  }

  /// Check if banner ads are enabled
  bool get bannerEnabled {
    if (!_isInitialized) return false;
    return _remoteConfig.getBool(_bannerEnabled);
  }

  /// Check if interstitial ads are enabled
  bool get interstitialEnabled {
    if (!_isInitialized) return false;
    return _remoteConfig.getBool(_interstitialEnabled);
  }

  /// Check if rewarded ads are enabled
  bool get rewardedEnabled {
    if (!_isInitialized) return false;
    return _remoteConfig.getBool(_rewardedEnabled);
  }

  /// Get minimum sessions before showing ads
  int get adsMinSessionsBeforeShow {
    if (!_isInitialized) return 5;
    return _remoteConfig.getInt(_adsMinSessionsBeforeShow);
  }

  // ============================================
  // FEATURE FLAGS
  // ============================================

  /// Check if premium features are enabled
  bool get premiumFeaturesEnabled {
    if (!_isInitialized) return false;
    return _remoteConfig.getBool(_premiumFeaturesEnabled);
  }

  /// Check if app is in maintenance mode
  bool get maintenanceMode {
    if (!_isInitialized) return false;
    return _remoteConfig.getBool(_maintenanceMode);
  }

  // ============================================
  // GENERIC GETTERS
  // ============================================

  /// Get string value
  String getString(String key) {
    if (!_isInitialized) return '';
    return _remoteConfig.getString(key);
  }

  /// Get int value
  int getInt(String key) {
    if (!_isInitialized) return 0;
    return _remoteConfig.getInt(key);
  }

  /// Get bool value
  bool getBool(String key) {
    if (!_isInitialized) return false;
    return _remoteConfig.getBool(key);
  }

  /// Get double value
  double getDouble(String key) {
    if (!_isInitialized) return 0.0;
    return _remoteConfig.getDouble(key);
  }
}

/// Provider for Remote Config Service
final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});

/// Ad configuration state
class AdConfig {
  final bool adsEnabled;
  final bool bannerEnabled;
  final bool interstitialEnabled;
  final bool rewardedEnabled;
  final int minSessionsBeforeShow;

  const AdConfig({
    required this.adsEnabled,
    required this.bannerEnabled,
    required this.interstitialEnabled,
    required this.rewardedEnabled,
    required this.minSessionsBeforeShow,
  });

  /// Default config (all ads disabled)
  const AdConfig.disabled()
      : adsEnabled = false,
        bannerEnabled = false,
        interstitialEnabled = false,
        rewardedEnabled = false,
        minSessionsBeforeShow = 5;
}

/// Provider for ad configuration
final adConfigProvider = Provider<AdConfig>((ref) {
  final config = ref.watch(remoteConfigServiceProvider);
  
  if (!config.isInitialized) {
    return const AdConfig.disabled();
  }
  
  return AdConfig(
    adsEnabled: config.adsEnabled,
    bannerEnabled: config.bannerEnabled,
    interstitialEnabled: config.interstitialEnabled,
    rewardedEnabled: config.rewardedEnabled,
    minSessionsBeforeShow: config.adsMinSessionsBeforeShow,
  );
});
