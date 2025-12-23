# Security Architecture

## Overview

NutriSnap is designed with a privacy-first approach. This document outlines the security measures implemented to protect user data.

## Permission Model

### Requested Permissions

| Permission | Purpose | Justification |
|------------|---------|---------------|
| `CAMERA` | Meal photo capture | Required for AI analysis; image never stored |
| `INTERNET` | LLM API calls | Required for Claude/Gemini API; HTTPS only |

### Explicitly NOT Requested

| Permission | Why Not Needed |
|------------|----------------|
| `READ_EXTERNAL_STORAGE` | App uses private SQLite storage |
| `WRITE_EXTERNAL_STORAGE` | No files saved outside app directory |
| `ACCESS_FINE_LOCATION` | No location features |
| `ACCESS_COARSE_LOCATION` | No location features |
| `READ_CONTACTS` | No contact access needed |
| `RECORD_AUDIO` | No audio features |

## Data Storage

### API Keys (High Sensitivity)
- **Storage**: Android Keystore via `flutter_secure_storage`
- **Encryption**: Hardware-backed RSA/AES
- **Access**: Retrieved only during API calls, held in memory briefly

```dart
// Android Keystore configuration
AndroidOptions(
  encryptedSharedPreferences: true,
  keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
  storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
)
```

### Meal Data (Medium Sensitivity)
- **Storage**: SQLite in app-private directory
- **Location**: `/data/data/com.example.calorie_tracker/databases/`
- **Access**: Only accessible by the app (Android sandboxing)

### Images (Transient)
- **Storage**: NEVER saved to disk
- **Lifecycle**: 
  1. Captured in memory
  2. Encoded to base64
  3. Sent to API
  4. Immediately discarded
- **Temporary Files**: Any camera temp files deleted immediately

## Network Security

### HTTPS Enforcement
All network traffic is forced through HTTPS via `network_security_config.xml`:

```xml
<network-security-config>
  <base-config cleartextTrafficPermitted="false">
    <trust-anchors>
      <certificates src="system" />
    </trust-anchors>
  </base-config>
</network-security-config>
```

### Allowed Domains
Only whitelisted API endpoints are reachable:
- `api.anthropic.com` (Claude API)
- `generativelanguage.googleapis.com` (Gemini API)

### Certificate Pinning
System certificates are trusted; consider adding certificate pinning for production.

## Backup Protection

Android backup is disabled to prevent API key leakage:

```xml
<application
    android:allowBackup="false"
    android:fullBackupContent="false">
```

## Threat Model

### Protected Against
1. **Data at Rest Exposure**: API keys encrypted with hardware-backed keystore
2. **Network Interception**: HTTPS enforced, cleartext disabled
3. **Image Leakage**: Images never touch disk
4. **Backup Extraction**: Backups disabled
5. **Storage Permission Abuse**: No external storage access

### Not Protected Against
1. **Rooted Devices**: Hardware keystore can be bypassed
2. **Device Physical Access**: No app-level PIN/biometric
3. **API Key Exposure**: Key visible during API call (HTTPS protected)
4. **Screen Recording**: UI elements visible

## Best Practices Implemented

1. **Principle of Least Privilege**: Minimal permissions requested
2. **Defense in Depth**: Multiple security layers
3. **Secure by Default**: HTTPS, encrypted storage by default
4. **Data Minimization**: Only essential data collected
5. **Transparent Privacy**: Clear disclosure of data handling

## Recommendations for Production

1. **Add Certificate Pinning**: Pin Claude/Gemini certificates
2. **Implement Biometric Lock**: Add app-level authentication
3. **Add Tamper Detection**: Detect rooted devices
4. **Obfuscate Code**: Enable R8/ProGuard
5. **Add Security Logging**: Monitor for anomalies
6. **Regular Security Audits**: Penetration testing

## Compliance Considerations

- **GDPR**: All data stored locally, user controls deletion
- **Data Localization**: No data leaves device except API calls
- **Right to Erasure**: "Clear All Data" feature implemented
