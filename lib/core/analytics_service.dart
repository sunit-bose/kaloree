import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Analytics Service - Firebase Analytics wrapper
/// 
/// Provides type-safe event logging and user property management.
/// All analytics calls are fire-and-forget to avoid blocking UI.
class AnalyticsService {
  late final FirebaseAnalytics _analytics;
  bool _isInitialized = false;

  /// Initialize Analytics
  /// 
  /// Should be called after Firebase Core is initialized.
  /// Safe to call multiple times.
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _analytics = FirebaseAnalytics.instance;
      _isInitialized = true;
    } catch (e) {
      print('⚠️ Analytics initialization failed: $e');
    }
  }

  bool get isInitialized => _isInitialized;

  // ============================================
  // USER PROPERTIES
  // ============================================

  /// Set authentication type property
  Future<void> setAuthType(String authType) async {
    if (!_isInitialized) return;
    try {
      await _analytics.setUserProperty(
        name: 'auth_type',
        value: authType,
      );
    } catch (e) {
      // Silent fail - analytics should never crash app
    }
  }

  /// Set premium status property
  Future<void> setPremiumStatus(bool isPremium) async {
    if (!_isInitialized) return;
    try {
      await _analytics.setUserProperty(
        name: 'premium_status',
        value: isPremium ? 'premium' : 'free',
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Set user ID for cross-device tracking (if user consents)
  Future<void> setUserId(String? userId) async {
    if (!_isInitialized) return;
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      // Silent fail
    }
  }

  // ============================================
  // AUTHENTICATION EVENTS
  // ============================================

  /// Log login event
  Future<void> logLogin({required String method}) async {
    if (!_isInitialized) return;
    try {
      await _analytics.logLogin(loginMethod: method);
    } catch (e) {
      // Silent fail
    }
  }

  /// Log sign up event
  Future<void> logSignUp({required String method}) async {
    if (!_isInitialized) return;
    try {
      await _analytics.logSignUp(signUpMethod: method);
    } catch (e) {
      // Silent fail
    }
  }

  /// Log account upgrade (anonymous to full account)
  Future<void> logAccountUpgraded({required String method}) async {
    if (!_isInitialized) return;
    try {
      await _analytics.logEvent(
        name: 'account_upgraded',
        parameters: {
          'upgrade_method': method,
        },
      );
    } catch (e) {
      // Silent fail
    }
  }

  // ============================================
  // MEAL TRACKING EVENTS
  // ============================================

  /// Log meal added event
  Future<void> logMealAdded({
    required String source, // 'ai_scan', 'manual_search', 'favorites'
    required int itemCount,
    required int totalCalories,
  }) async {
    if (!_isInitialized) return;
    try {
      await _analytics.logEvent(
        name: 'meal_added',
        parameters: {
          'source': source,
          'item_count': itemCount,
          'total_calories': totalCalories,
        },
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Log food scanned with AI
  Future<void> logFoodScanned({
    required bool success,
    required String? foodType,
  }) async {
    if (!_isInitialized) return;
    try {
      await _analytics.logEvent(
        name: 'food_scanned',
        parameters: {
          'success': success ? 1 : 0,
          'food_type': foodType ?? 'unknown',
        },
      );
    } catch (e) {
      // Silent fail
    }
  }

  // ============================================
  // USER PROFILE EVENTS
  // ============================================

  /// Log weight updated
  Future<void> logWeightUpdated({
    required double weight,
    required String unit,
  }) async {
    if (!_isInitialized) return;
    try {
      await _analytics.logEvent(
        name: 'weight_updated',
        parameters: {
          'weight': weight,
          'unit': unit,
        },
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Log goal set
  Future<void> logGoalSet({
    required String goalType, // 'calorie', 'weight', 'macro'
    required double value,
  }) async {
    if (!_isInitialized) return;
    try {
      await _analytics.logEvent(
        name: 'goal_set',
        parameters: {
          'goal_type': goalType,
          'value': value,
        },
      );
    } catch (e) {
      // Silent fail
    }
  }

  // ============================================
  // ENGAGEMENT EVENTS
  // ============================================

  /// Log favorite added
  Future<void> logFavoriteAdded({required String foodName}) async {
    if (!_isInitialized) return;
    try {
      await _analytics.logEvent(
        name: 'favorite_added',
        parameters: {
          'food_name': foodName,
        },
      );
    } catch (e) {
      // Silent fail
    }
  }

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_isInitialized) return;
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      // Silent fail
    }
  }

  // ============================================
  // GENERIC EVENT LOGGING
  // ============================================

  /// Log custom event
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!_isInitialized) return;
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
    } catch (e) {
      // Silent fail
    }
  }
}

/// Provider for Analytics Service
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

/// Future provider for analytics initialization
final analyticsInitializedProvider = FutureProvider<bool>((ref) async {
  final analytics = ref.watch(analyticsServiceProvider);
  await analytics.initialize();
  return analytics.isInitialized;
});
