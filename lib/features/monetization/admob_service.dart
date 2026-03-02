import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ads_service.dart';

/// AdMob Service - Concrete implementation of AdsService
/// 
/// CRITICAL: This service should ONLY be instantiated AFTER:
/// 1. AdsPolicyService has obtained consent
/// 2. MobileAds.instance.initialize() has been called
/// 
/// NO banner widgets are injected anywhere by this implementation.
/// This is infrastructure only.
class AdMobService implements AdsService {
  bool _isInitialized = false;
  
  // Ad instances
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  
  // Ad load status
  AdLoadStatus _bannerAdStatus = AdLoadStatus.notLoaded;
  AdLoadStatus _interstitialAdStatus = AdLoadStatus.notLoaded;
  AdLoadStatus _rewardedAdStatus = AdLoadStatus.notLoaded;
  
  // Analytics counters
  final Map<AdType, int> _impressions = {
    AdType.banner: 0,
    AdType.interstitial: 0,
    AdType.rewarded: 0,
  };
  final Map<AdType, int> _clicks = {
    AdType.banner: 0,
    AdType.interstitial: 0,
    AdType.rewarded: 0,
  };

  // ============================================
  // TEST AD UNIT IDS (Replace with production IDs)
  // ============================================
  
  String get _bannerAdUnitId {
    if (kDebugMode) {
      // Test IDs
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      }
    }
    // TODO: Replace with production ad unit IDs
    if (Platform.isAndroid) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
    }
    return '';
  }
  
  String get _interstitialAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/1033173712';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/4411468910';
      }
    }
    // TODO: Replace with production ad unit IDs
    if (Platform.isAndroid) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
    }
    return '';
  }
  
  String get _rewardedAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/5224354917';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/1712485313';
      }
    }
    // TODO: Replace with production ad unit IDs
    if (Platform.isAndroid) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
    }
    return '';
  }

  // ============================================
  // INITIALIZATION
  // ============================================

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Note: MobileAds.instance.initialize() should already be called
    // by AdsPolicyService AFTER consent is obtained.
    // This method just marks our service as ready.
    
    _isInitialized = true;
    print('✅ AdMobService initialized');
  }

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get adsAvailable => _isInitialized;

  // ============================================
  // BANNER ADS
  // ============================================

  @override
  Future<bool> loadBannerAd({String? adUnitId}) async {
    if (!_isInitialized) return false;
    
    _bannerAdStatus = AdLoadStatus.loading;
    
    _bannerAd = BannerAd(
      adUnitId: adUnitId ?? _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _bannerAdStatus = AdLoadStatus.loaded;
          print('✅ Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          _bannerAdStatus = AdLoadStatus.failed;
          ad.dispose();
          _bannerAd = null;
          print('⚠️ Banner ad failed to load: ${error.message}');
        },
        onAdOpened: (ad) => trackImpression(AdType.banner),
        onAdClicked: (ad) => trackClick(AdType.banner),
      ),
    );
    
    await _bannerAd!.load();
    return _bannerAdStatus == AdLoadStatus.loaded;
  }

  @override
  AdLoadStatus get bannerAdStatus => _bannerAdStatus;

  /// Get the banner ad widget (null if not loaded)
  BannerAd? get bannerAd => _bannerAd;

  @override
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _bannerAdStatus = AdLoadStatus.notLoaded;
  }

  // ============================================
  // INTERSTITIAL ADS
  // ============================================

  @override
  Future<bool> loadInterstitialAd({String? adUnitId}) async {
    if (!_isInitialized) return false;
    
    _interstitialAdStatus = AdLoadStatus.loading;
    
    await InterstitialAd.load(
      adUnitId: adUnitId ?? _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAdStatus = AdLoadStatus.loaded;
          print('✅ Interstitial ad loaded');
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              trackImpression(AdType.interstitial);
            },
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _interstitialAdStatus = AdLoadStatus.notLoaded;
              // Preload next ad
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _interstitialAdStatus = AdLoadStatus.failed;
              print('⚠️ Interstitial ad failed to show: ${error.message}');
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialAdStatus = AdLoadStatus.failed;
          print('⚠️ Interstitial ad failed to load: ${error.message}');
        },
      ),
    );
    
    return _interstitialAdStatus == AdLoadStatus.loaded;
  }

  @override
  Future<bool> showInterstitialAd() async {
    if (_interstitialAd == null || _interstitialAdStatus != AdLoadStatus.loaded) {
      return false;
    }
    
    await _interstitialAd!.show();
    _interstitialAdStatus = AdLoadStatus.shown;
    return true;
  }

  @override
  AdLoadStatus get interstitialAdStatus => _interstitialAdStatus;

  // ============================================
  // REWARDED ADS
  // ============================================

  @override
  Future<bool> loadRewardedAd({String? adUnitId}) async {
    if (!_isInitialized) return false;
    
    _rewardedAdStatus = AdLoadStatus.loading;
    
    await RewardedAd.load(
      adUnitId: adUnitId ?? _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedAdStatus = AdLoadStatus.loaded;
          print('✅ Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          _rewardedAdStatus = AdLoadStatus.failed;
          print('⚠️ Rewarded ad failed to load: ${error.message}');
        },
      ),
    );
    
    return _rewardedAdStatus == AdLoadStatus.loaded;
  }

  @override
  Future<int?> showRewardedAd() async {
    if (_rewardedAd == null || _rewardedAdStatus != AdLoadStatus.loaded) {
      return null;
    }
    
    int? rewardAmount;
    
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        trackImpression(AdType.rewarded);
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _rewardedAdStatus = AdLoadStatus.notLoaded;
        // Preload next ad
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _rewardedAdStatus = AdLoadStatus.failed;
        print('⚠️ Rewarded ad failed to show: ${error.message}');
      },
    );
    
    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewardAmount = reward.amount.toInt();
        print('🎁 User earned reward: ${reward.amount} ${reward.type}');
      },
    );
    
    _rewardedAdStatus = AdLoadStatus.shown;
    return rewardAmount;
  }

  @override
  AdLoadStatus get rewardedAdStatus => _rewardedAdStatus;

  // ============================================
  // LIFECYCLE
  // ============================================

  @override
  void pause() {
    // AdMob handles pause/resume automatically
    print('⏸️ AdMobService paused');
  }

  @override
  void resume() {
    print('▶️ AdMobService resumed');
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
    
    _bannerAdStatus = AdLoadStatus.notLoaded;
    _interstitialAdStatus = AdLoadStatus.notLoaded;
    _rewardedAdStatus = AdLoadStatus.notLoaded;
    
    _isInitialized = false;
    print('🗑️ AdMobService disposed');
  }

  // ============================================
  // ANALYTICS
  // ============================================

  @override
  void trackImpression(AdType type) {
    _impressions[type] = (_impressions[type] ?? 0) + 1;
  }

  @override
  void trackClick(AdType type) {
    _clicks[type] = (_clicks[type] ?? 0) + 1;
  }

  @override
  int getTotalImpressions(AdType type) {
    return _impressions[type] ?? 0;
  }

  /// Get total clicks for an ad type
  int getTotalClicks(AdType type) {
    return _clicks[type] ?? 0;
  }

  /// Get analytics summary
  Map<String, dynamic> get analyticsData => {
    'impressions': _impressions,
    'clicks': _clicks,
    'ctr': {
      AdType.banner: _calculateCTR(AdType.banner),
      AdType.interstitial: _calculateCTR(AdType.interstitial),
      AdType.rewarded: _calculateCTR(AdType.rewarded),
    },
  };

  double _calculateCTR(AdType type) {
    final impressions = _impressions[type] ?? 0;
    final clicks = _clicks[type] ?? 0;
    if (impressions == 0) return 0.0;
    return clicks / impressions;
  }
}
