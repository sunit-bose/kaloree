import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Secure storage service for API keys
/// Uses Android Keystore / iOS Keychain for hardware-backed encryption
/// Keys are NEVER stored in SQLite or logs
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // Uses EncryptedSharedPreferences
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Key identifiers
  static const _geminiApiKey = 'gemini_api_key';

  // ============================================
  // GOOGLE GEMINI API KEY MANAGEMENT
  // ============================================

  /// Store Google AI (Gemini) API key securely
  /// Get your key from: https://aistudio.google.com/app/apikey
  Future<void> setGeminiApiKey(String apiKey) async {
    if (apiKey.isEmpty) {
      await _storage.delete(key: _geminiApiKey);
    } else {
      await _storage.write(key: _geminiApiKey, value: apiKey);
    }
  }

  /// Retrieve Gemini API key (only in memory during use)
  Future<String?> getGeminiApiKey() async {
    return await _storage.read(key: _geminiApiKey);
  }

  /// Check if Gemini API key exists
  Future<bool> hasGeminiApiKey() async {
    final key = await _storage.read(key: _geminiApiKey);
    return key != null && key.isNotEmpty;
  }

  // ============================================
  // CHECK CONFIGURATION STATUS
  // ============================================

  /// Check if API is configured (Gemini key present)
  Future<bool> isConfigured() async {
    return await hasGeminiApiKey();
  }

  /// Get the configured API key
  Future<String?> getActiveApiKey() async {
    return await getGeminiApiKey();
  }

  // ============================================
  // CLEAR ALL (for logout/reset)
  // ============================================

  /// Clear all stored keys
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

// Provider
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

// Configuration status provider
final isApiConfiguredProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  return await storage.isConfigured();
});
