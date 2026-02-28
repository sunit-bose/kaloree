import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Secure storage service for API keys
/// Uses Android Keystore for hardware-backed encryption
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
  static const _claudeApiKey = 'claude_api_key';
  static const _geminiApiKey = 'gemini_api_key';
  static const _selectedProvider = 'selected_provider';

  // ============================================
  // API KEY MANAGEMENT
  // ============================================

  /// Store Claude API key securely
  Future<void> setClaudeApiKey(String apiKey) async {
    if (apiKey.isEmpty) {
      await _storage.delete(key: _claudeApiKey);
    } else {
      await _storage.write(key: _claudeApiKey, value: apiKey);
    }
  }

  /// Retrieve Claude API key (only in memory during use)
  Future<String?> getClaudeApiKey() async {
    return await _storage.read(key: _claudeApiKey);
  }

  /// Check if Claude API key exists
  Future<bool> hasClaudeApiKey() async {
    final key = await _storage.read(key: _claudeApiKey);
    return key != null && key.isNotEmpty;
  }

  /// Store Gemini API key securely
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
  // PROVIDER SELECTION
  // ============================================

  /// Set selected LLM provider
  Future<void> setSelectedProvider(LLMProvider provider) async {
    await _storage.write(key: _selectedProvider, value: provider.name);
  }

  /// Get selected LLM provider
  Future<LLMProvider> getSelectedProvider() async {
    final value = await _storage.read(key: _selectedProvider);
    if (value == 'gemini') return LLMProvider.gemini;
    return LLMProvider.claude; // Default
  }

  // ============================================
  // CHECK CONFIGURATION STATUS
  // ============================================

  /// Check if any API is configured
  Future<bool> isConfigured() async {
    final provider = await getSelectedProvider();
    if (provider == LLMProvider.claude) {
      return await hasClaudeApiKey();
    } else {
      return await hasGeminiApiKey();
    }
  }

  /// Get the configured API key for the selected provider
  Future<String?> getActiveApiKey() async {
    final provider = await getSelectedProvider();
    if (provider == LLMProvider.claude) {
      return await getClaudeApiKey();
    } else {
      return await getGeminiApiKey();
    }
  }

  // ============================================
  // CLEAR ALL (for logout/reset)
  // ============================================

  /// Clear all stored keys
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

/// LLM Provider enum
enum LLMProvider {
  claude('Claude (Anthropic)'),
  gemini('Gemini (Google)');

  final String displayName;
  const LLMProvider(this.displayName);
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

// Selected provider state
final selectedProviderProvider = FutureProvider<LLMProvider>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  return await storage.getSelectedProvider();
});
