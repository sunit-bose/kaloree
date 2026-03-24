import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/firebase_initializer.dart';
import 'core/analytics_service.dart';
import 'core/remote_config_service.dart';
import 'core/ads_policy_service.dart';
import 'features/auth/data/auth_repository.dart';

/// Boot State - Represents app initialization progress
enum BootState {
  notStarted,
  initializingFirebase,
  authenticating,
  loadingConfig,
  initializingAnalytics,
  checkingConsent,
  ready,
  failed,
}

/// Boot Progress - Detailed boot status
class BootProgress {
  final BootState state;
  final String message;
  final double progress;
  final String? error;

  const BootProgress({
    required this.state,
    required this.message,
    required this.progress,
    this.error,
  });

  const BootProgress.initial()
      : state = BootState.notStarted,
        message = 'Starting...',
        progress = 0.0,
        error = null;

  const BootProgress.ready()
      : state = BootState.ready,
        message = 'Ready',
        progress = 1.0,
        error = null;

  BootProgress copyWith({
    BootState? state,
    String? message,
    double? progress,
    String? error,
  }) {
    return BootProgress(
      state: state ?? this.state,
      message: message ?? this.message,
      progress: progress ?? this.progress,
      error: error,
    );
  }

  bool get isReady => state == BootState.ready;
  bool get isFailed => state == BootState.failed;
  bool get isLoading => !isReady && !isFailed;
}

/// App Boot Controller - Orchestrates initialization sequence
///
/// CRITICAL: Boot sequence must follow this exact order:
/// 1. loadCached() - Load cached Remote Config (non-blocking)
/// 2. fetchAndActivateInBackground() - Fetch new config (fire-and-forget)
/// 3. initialize() - Initialize Analytics
/// 4. checkConsentAndInitialize() - Check GDPR/ATT consent for ads
///
/// Authentication is handled separately by AuthGate.
/// UI must NOT freeze during initialization.
class AppBootController extends AsyncNotifier<BootProgress> {
  @override
  Future<BootProgress> build() async {
    return const BootProgress.initial();
  }

  /// Start the boot sequence
  Future<void> boot() async {
    try {
      // Step 1: Initialize Firebase Core
      state = const AsyncValue.data(BootProgress(
        state: BootState.initializingFirebase,
        message: 'Initializing Firebase...',
        progress: 0.2,
      ));
      
      final firebaseInitializer = ref.read(firebaseInitializerProvider);
      await firebaseInitializer.initialize();
      
      // Note: Authentication is handled by AuthGate separately
      // User must sign in with Google - no anonymous accounts
      
      // Step 2: Load cached Remote Config (immediate, non-blocking)
      state = const AsyncValue.data(BootProgress(
        state: BootState.loadingConfig,
        message: 'Loading configuration...',
        progress: 0.4,
      ));
      
      final remoteConfig = ref.read(remoteConfigServiceProvider);
      await remoteConfig.loadCached();
      
      // Fire-and-forget: Fetch new config in background
      // This does NOT block the boot sequence
      remoteConfig.fetchAndActivateInBackground();
      
      // Step 3: Initialize Analytics (non-blocking)
      state = const AsyncValue.data(BootProgress(
        state: BootState.initializingAnalytics,
        message: 'Setting up analytics...',
        progress: 0.6,
      ));
      
      final analytics = ref.read(analyticsServiceProvider);
      await analytics.initialize();
      
      // Log app start event
      analytics.logEvent(name: 'app_boot_completed');
      
      // Set user properties (if logged in)
      final authRepo = ref.read(authRepositoryProvider);
      if (authRepo.currentUser != null) {
        analytics.setUserId(authRepo.currentUser!.uid);
        analytics.setAuthType(authRepo.authProvider);
      }
      
      // Step 4: Check consent and initialize ads (if applicable)
      state = const AsyncValue.data(BootProgress(
        state: BootState.checkingConsent,
        message: 'Finalizing setup...',
        progress: 0.8,
      ));
      
      // Fire-and-forget: Consent check runs in background
      // This does NOT block the boot sequence
      _checkConsentInBackground();
      
      // Boot complete!
      state = const AsyncValue.data(BootProgress.ready());
      
      print('✅ App boot completed successfully');
      
    } catch (e, stack) {
      print('❌ App boot failed: $e');
      print(stack);
      
      state = AsyncValue.data(BootProgress(
        state: BootState.failed,
        message: 'Failed to initialize app',
        progress: 0.0,
        error: e.toString(),
      ));
    }
  }

  /// Check consent in background (fire-and-forget)
  void _checkConsentInBackground() {
    final adsPolicy = ref.read(adsPolicyServiceProvider);
    
    // Don't await - this runs in background
    adsPolicy.checkConsentAndInitialize().then((initialized) {
      if (initialized) {
        print('✅ AdMob initialized after consent');
      } else {
        print('ℹ️ AdMob not initialized (consent not obtained or not required)');
      }
    }).catchError((e) {
      print('⚠️ Consent check failed: $e');
      // Silent fail - app continues without ads
    });
  }

  /// Retry boot after failure
  Future<void> retry() async {
    state = const AsyncValue.data(BootProgress.initial());
    await boot();
  }
}

/// Provider for App Boot Controller
final appBootControllerProvider =
    AsyncNotifierProvider<AppBootController, BootProgress>(() {
  return AppBootController();
});

/// Provider for boot ready state
final isBootReadyProvider = Provider<bool>((ref) {
  final bootState = ref.watch(appBootControllerProvider);
  return bootState.maybeWhen(
    data: (progress) => progress.isReady,
    orElse: () => false,
  );
});

/// Provider for boot loading state
final isBootLoadingProvider = Provider<bool>((ref) {
  final bootState = ref.watch(appBootControllerProvider);
  return bootState.maybeWhen(
    data: (progress) => progress.isLoading,
    orElse: () => true,
  );
});

/// Provider for boot error
final bootErrorProvider = Provider<String?>((ref) {
  final bootState = ref.watch(appBootControllerProvider);
  return bootState.maybeWhen(
    data: (progress) => progress.error,
    orElse: () => null,
  );
});
