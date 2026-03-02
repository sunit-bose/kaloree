import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ad Type enumeration
enum AdType {
  banner,
  interstitial,
  rewarded,
}

/// Ad Load Status
enum AdLoadStatus {
  notLoaded,
  loading,
  loaded,
  failed,
  shown,
}

/// Abstract Ads Service - Defines the contract for ad providers
/// 
/// This abstraction allows for:
/// - Easy testing with mock implementations
/// - Switching ad providers without changing app code
/// - Graceful degradation when ads are unavailable
abstract class AdsService {
  /// Initialize the ad service
  /// 
  /// CRITICAL: Must only be called AFTER consent is obtained.
  /// See AdsPolicyService for consent flow.
  Future<void> initialize();

  /// Check if service is initialized
  bool get isInitialized;

  /// Check if ads are available
  bool get adsAvailable;

  // ============================================
  // BANNER ADS
  // ============================================

  /// Load a banner ad
  Future<bool> loadBannerAd({String? adUnitId});

  /// Get banner ad load status
  AdLoadStatus get bannerAdStatus;

  /// Dispose banner ad
  void disposeBannerAd();

  // ============================================
  // INTERSTITIAL ADS
  // ============================================

  /// Load an interstitial ad
  Future<bool> loadInterstitialAd({String? adUnitId});

  /// Show interstitial ad
  /// 
  /// Returns true if ad was shown successfully.
  Future<bool> showInterstitialAd();

  /// Get interstitial ad load status
  AdLoadStatus get interstitialAdStatus;

  // ============================================
  // REWARDED ADS
  // ============================================

  /// Load a rewarded ad
  Future<bool> loadRewardedAd({String? adUnitId});

  /// Show rewarded ad
  /// 
  /// Returns the reward amount if user completed watching, null otherwise.
  Future<int?> showRewardedAd();

  /// Get rewarded ad load status
  AdLoadStatus get rewardedAdStatus;

  // ============================================
  // LIFECYCLE
  // ============================================

  /// Pause ad loading (e.g., when app goes to background)
  void pause();

  /// Resume ad loading
  void resume();

  /// Dispose all ads and cleanup
  void dispose();

  // ============================================
  // ANALYTICS
  // ============================================

  /// Track ad impression
  void trackImpression(AdType type);

  /// Track ad click
  void trackClick(AdType type);

  /// Get total impressions
  int getTotalImpressions(AdType type);
}

/// No-op Ads Service - Used when ads are disabled or consent not obtained
class NoOpAdsService implements AdsService {
  @override
  Future<void> initialize() async {}

  @override
  bool get isInitialized => false;

  @override
  bool get adsAvailable => false;

  @override
  Future<bool> loadBannerAd({String? adUnitId}) async => false;

  @override
  AdLoadStatus get bannerAdStatus => AdLoadStatus.notLoaded;

  @override
  void disposeBannerAd() {}

  @override
  Future<bool> loadInterstitialAd({String? adUnitId}) async => false;

  @override
  Future<bool> showInterstitialAd() async => false;

  @override
  AdLoadStatus get interstitialAdStatus => AdLoadStatus.notLoaded;

  @override
  Future<bool> loadRewardedAd({String? adUnitId}) async => false;

  @override
  Future<int?> showRewardedAd() async => null;

  @override
  AdLoadStatus get rewardedAdStatus => AdLoadStatus.notLoaded;

  @override
  void pause() {}

  @override
  void resume() {}

  @override
  void dispose() {}

  @override
  void trackImpression(AdType type) {}

  @override
  void trackClick(AdType type) {}

  @override
  int getTotalImpressions(AdType type) => 0;
}

/// Provider for Ads Service
/// 
/// Returns NoOpAdsService by default.
/// Override with AdMobService when ads are enabled.
final adsServiceProvider = Provider<AdsService>((ref) {
  return NoOpAdsService();
});

/// Provider for checking if ads are available
final adsAvailableProvider = Provider<bool>((ref) {
  final adsService = ref.watch(adsServiceProvider);
  return adsService.adsAvailable;
});
