import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Consent Status for ad personalization (our own enum)
enum AppConsentStatus {
  unknown,
  notRequired,
  required,
  obtained,
  denied,
}

/// Ads Policy Service - GDPR + Apple ATT Compliant Consent Management
/// 
/// CRITICAL: AdMob SDK must NEVER be initialized before consent is resolved.
/// This is mandatory for:
/// - GDPR compliance (EU users)
/// - Apple App Tracking Transparency (iOS 14.5+)
/// - App Store approval
/// 
/// Flow:
/// 1. Check consent status using Google UMP
/// 2. If consent required, show consent form
/// 3. ONLY after consent granted/not required, initialize AdMob
class AdsPolicyService {
  AppConsentStatus _consentStatus = AppConsentStatus.unknown;
  bool _adMobInitialized = false;
  
  AppConsentStatus get consentStatus => _consentStatus;
  bool get adMobInitialized => _adMobInitialized;
  bool get canShowAds => _adMobInitialized && 
      (_consentStatus == AppConsentStatus.obtained || 
       _consentStatus == AppConsentStatus.notRequired);

  /// Check consent and initialize AdMob if allowed
  /// 
  /// CRITICAL: This is the ONLY place where MobileAds.instance.initialize()
  /// should be called. Never call it elsewhere.
  /// 
  /// Returns true if AdMob was initialized successfully.
  Future<bool> checkConsentAndInitialize() async {
    try {
      // Step 1: Request consent info update
      final params = ConsentRequestParameters(
        tagForUnderAgeOfConsent: false,
      );
      
      await _requestConsentInfoUpdate(params);
      
      // Step 2: Check if consent form is available and needed
      final formStatus = ConsentInformation.instance.getConsentStatus();
      
      switch (formStatus) {
        case ConsentStatus.notRequired:
          // No consent needed (non-EU user or already consented)
          _consentStatus = AppConsentStatus.notRequired;
          return await _initializeAdMob();
          
        case ConsentStatus.required:
          // Need to show consent form
          _consentStatus = AppConsentStatus.required;
          final formAvailable = await ConsentInformation.instance.isConsentFormAvailable();
          
          if (formAvailable) {
            await _showConsentForm();
          } else {
            // Form not available - cannot proceed with personalized ads
            _consentStatus = AppConsentStatus.denied;
            return false;
          }
          break;
          
        case ConsentStatus.obtained:
          // Consent already obtained
          _consentStatus = AppConsentStatus.obtained;
          return await _initializeAdMob();
          
        case ConsentStatus.unknown:
        default:
          // Unknown status - don't initialize
          _consentStatus = AppConsentStatus.unknown;
          return false;
      }
      
      // After form shown, check final status
      final finalStatus = ConsentInformation.instance.getConsentStatus();
      if (finalStatus == ConsentStatus.obtained) {
        _consentStatus = AppConsentStatus.obtained;
        return await _initializeAdMob();
      }
      
      _consentStatus = AppConsentStatus.denied;
      return false;
      
    } catch (e) {
      print('⚠️ Consent check failed: $e');
      _consentStatus = AppConsentStatus.unknown;
      return false;
    }
  }

  /// Request consent info update from UMP (callback-based API wrapped in Future)
  Future<void> _requestConsentInfoUpdate(ConsentRequestParameters params) async {
    final completer = Completer<void>();
    
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () {
        // Success callback
        print('✅ Consent info updated');
        completer.complete();
      },
      (error) {
        // Error callback
        print('⚠️ Consent info update failed: ${error.message}');
        completer.completeError(error);
      },
    );
    
    return completer.future;
  }

  /// Show consent form (callback-based API wrapped in Future)
  Future<void> _showConsentForm() async {
    final completer = Completer<void>();
    
    ConsentForm.loadConsentForm(
      (consentForm) {
        consentForm.show((formError) {
          if (formError != null) {
            print('⚠️ Consent form error: ${formError.message}');
            completer.completeError(formError);
          } else {
            completer.complete();
          }
        });
      },
      (formError) {
        print('⚠️ Consent form load failed: ${formError.message}');
        completer.completeError(formError);
      },
    );
    
    return completer.future;
  }

  /// Initialize AdMob SDK
  /// 
  /// CRITICAL: Only call this AFTER consent is resolved.
  Future<bool> _initializeAdMob() async {
    if (_adMobInitialized) return true;
    
    try {
      await MobileAds.instance.initialize();
      _adMobInitialized = true;
      print('✅ AdMob SDK initialized');
      return true;
    } catch (e) {
      print('⚠️ AdMob initialization failed: $e');
      return false;
    }
  }

  /// Reset consent (for testing or user request)
  /// 
  /// Use with caution - this will require user to re-consent.
  Future<void> resetConsent() async {
    await ConsentInformation.instance.reset();
    _consentStatus = AppConsentStatus.unknown;
    _adMobInitialized = false;
  }

  /// Check if running on iOS (for ATT-specific logic)
  bool get isIOS => Platform.isIOS;

  /// Get debug info for troubleshooting
  Map<String, dynamic> get debugInfo => {
    'consentStatus': _consentStatus.toString(),
    'adMobInitialized': _adMobInitialized,
    'canShowAds': canShowAds,
    'platform': Platform.operatingSystem,
  };
}

/// Provider for Ads Policy Service
final adsPolicyServiceProvider = Provider<AdsPolicyService>((ref) {
  return AdsPolicyService();
});

/// Provider for consent status
final consentStatusProvider = Provider<AppConsentStatus>((ref) {
  final adsPolicy = ref.watch(adsPolicyServiceProvider);
  return adsPolicy.consentStatus;
});

/// Provider for ad availability
final canShowAdsProvider = Provider<bool>((ref) {
  final adsPolicy = ref.watch(adsPolicyServiceProvider);
  return adsPolicy.canShowAds;
});
