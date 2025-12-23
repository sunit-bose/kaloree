# API 404 Error Fix - Gemini Model

## Problem
When taking a picture in AI mode, the following error appeared:
```
API error: This exception was thrown because the response has a status code of 404
The status code of 404 has the following meaning: "Client error - the request contains bad syntax or cannot be fulfilled"
```

## Root Cause
The app was configured to use the experimental Gemini model `gemini-2.0-flash-exp`, which:
- Is not available to all users
- May have been removed or restricted
- Returns a 404 Not Found error

**Location:** [`lib/services/llm_service.dart:119`](lib/services/llm_service.dart:119)

## Solution
Changed the Gemini API endpoint to use a stable, production-ready model:

### Before:
```dart
'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent'
```

### After:
```dart
'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent'
```

## Model Details

### Gemini 1.5 Flash
- ✅ **Stable**: Production-ready, publicly available
- ✅ **Fast**: Optimized for speed with multimodal support
- ✅ **Vision**: Supports image analysis for meal recognition
- ✅ **Reliable**: Consistent API availability
- ✅ **Free Tier**: Available in Google AI Studio free tier

## Testing Steps

1. **Verify API Key**: Go to Settings and ensure your Gemini API key is entered
2. **Take a Picture**: 
   - Open the camera
   - Point at food
   - Click the camera button
3. **Expected Result**: AI should successfully analyze the food without 404 errors

## Additional Notes

- The fix maintains all existing functionality
- No changes needed to user's API keys
- Works with the same Gemini API key from Google AI Studio
- Gemini 1.5 Flash provides excellent quality for meal analysis

## Alternative Models Available

If you need to switch models in the future, here are other stable options:

1. **Gemini 1.5 Flash** (Current)
   - Endpoint: `gemini-1.5-flash:generateContent`
   - Best for: Fast, efficient analysis

2. **Gemini 1.5 Pro**
   - Endpoint: `gemini-1.5-pro:generateContent`
   - Best for: Higher accuracy, more complex meals

3. **Gemini 1.0 Pro Vision**
   - Endpoint: `gemini-pro-vision:generateContent`
   - Best for: Legacy compatibility

## How to Get a Gemini API Key

If you don't have a Gemini API key:

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click "Get API Key"
4. Copy the key (starts with "AI...")
5. Open Kaloree → Settings → Select "Gemini" → Paste API key

## Verification

After this fix:
- ✅ 404 errors should be resolved
- ✅ AI meal analysis should work correctly
- ✅ All three providers (Claude, Gemini, Groq) remain functional
