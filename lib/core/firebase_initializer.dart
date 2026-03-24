import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase Initializer - Handles Firebase Core initialization
///
/// This is the ONLY place where Firebase.initializeApp() should be called.
/// All other Firebase services depend on this being initialized first.
///
/// Note: Firebase may be pre-initialized in main.dart for timing reasons.
/// This class handles that case by checking Firebase.apps before re-initializing.
class FirebaseInitializer {
  
  /// Check if Firebase is already initialized
  bool get isInitialized => Firebase.apps.isNotEmpty;

  /// Initialize Firebase Core
  ///
  /// Must be called before any other Firebase service.
  /// Safe to call multiple times - will only initialize once.
  /// Checks Firebase.apps to detect if already initialized (e.g., from main.dart).
  Future<void> initialize() async {
    // Check if Firebase is already initialized (by main.dart or previous call)
    if (Firebase.apps.isNotEmpty) {
      print('ℹ️ Firebase already initialized, skipping');
      return;
    }
    
    try {
      await Firebase.initializeApp();
      print('✅ Firebase initialized by FirebaseInitializer');
    } catch (e) {
      // Log but don't crash - allow app to function with degraded features
      print('⚠️ Firebase initialization failed: $e');
      rethrow;
    }
  }
}

/// Provider for Firebase Initializer
final firebaseInitializerProvider = Provider<FirebaseInitializer>((ref) {
  return FirebaseInitializer();
});

/// Future provider for initialization status
final firebaseInitializedProvider = FutureProvider<bool>((ref) async {
  final initializer = ref.watch(firebaseInitializerProvider);
  await initializer.initialize();
  return initializer.isInitialized;
});
