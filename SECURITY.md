# Security Architecture

## Overview

Kaloree is designed with a privacy-first approach. This document outlines the security measures implemented to protect user data.

## Permission Model

### Requested Permissions

| Permission | Purpose | Justification |
|------------|---------|---------------|
| `CAMERA` | Meal photo capture | Required for AI analysis; image never stored |
| `INTERNET` | LLM API calls, Firebase | Required for Claude/Gemini API and Firebase services; HTTPS only |

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
- **Location**: `/data/data/com.kaloree.app/databases/`
- **Access**: Only accessible by the app (Android sandboxing)

### Images (Transient)
- **Storage**: NEVER saved to disk
- **Lifecycle**: 
  1. Captured in memory
  2. Encoded to base64
  3. Sent to API
  4. Immediately discarded
- **Temporary Files**: Any camera temp files deleted immediately

### Firebase Data (Optional)
- **Authentication**: Firebase Auth with Google Sign-In
- **User Profile**: Firebase UID, display name, email (optional sign-in only)
- **Data Sync**: Not currently implemented (data stays local)
- **Analytics**: Anonymized usage events (crash-free, feature usage)

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
- `*.googleapis.com` (Firebase services)
- `*.firebaseio.com` (Firebase Realtime Database)
- `*.firebaseapp.com` (Firebase Hosting)

### Certificate Pinning
System certificates are trusted; consider adding certificate pinning for production.

## Firebase Security

### Authentication
- **Provider**: Google Sign-In only (no password storage)
- **Token Storage**: Firebase SDK manages tokens securely
- **Session**: Tokens refreshed automatically, revoked on sign-out

### Analytics
- **Data Collected**: Anonymized usage metrics, crash reports
- **No PII**: Personal meal data never sent to analytics
- **User Consent**: Analytics can be disabled via Firebase settings

### Remote Config
- **Purpose**: Feature flags and A/B testing
- **Data Flow**: Server → Client only (no user data uploaded)
- **Cache**: Config cached locally, refreshed periodically

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
6. **Credential Theft**: Google Sign-In uses OAuth, no passwords stored

### Not Protected Against
1. **Rooted Devices**: Hardware keystore can be bypassed
2. **Device Physical Access**: No app-level PIN/biometric
3. **API Key Exposure**: Key visible during API call (HTTPS protected)
4. **Screen Recording**: UI elements visible
5. **Compromised Google Account**: Affects Google Sign-In

## Best Practices Implemented

1. **Principle of Least Privilege**: Minimal permissions requested
2. **Defense in Depth**: Multiple security layers
3. **Secure by Default**: HTTPS, encrypted storage by default
4. **Data Minimization**: Only essential data collected
5. **Transparent Privacy**: Clear disclosure of data handling
6. **OAuth for Auth**: No custom password handling

## Recommendations for Production

1. **Add Certificate Pinning**: Pin Claude/Gemini/Firebase certificates
2. **Implement Biometric Lock**: Add app-level authentication
3. **Add Tamper Detection**: Detect rooted devices
4. **Obfuscate Code**: Enable R8/ProGuard
5. **Add Security Logging**: Monitor for anomalies
6. **Regular Security Audits**: Penetration testing
7. **Implement Firestore Rules**: If/when cloud sync is added

## Compliance Considerations

- **GDPR**: All data stored locally, user controls deletion
- **Data Localization**: No data leaves device except API calls
- **Right to Erasure**: "Clear All Data" feature implemented
- **Data Portability**: Export feature can be added
- **Firebase Compliance**: Google Firebase is GDPR compliant
