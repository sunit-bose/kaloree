# NutriSnap - AI-Powered Calorie Tracker

A privacy-focused calorie tracking app with AI meal recognition, specifically optimized for Indian cuisine.

## Features

- 📷 **AI Meal Analysis**: Point your camera at food and get instant nutritional information
- 🔍 **Manual Search**: Look up Indian dishes from a built-in database of 50+ foods
- 📊 **Analytics**: Track your nutrition over time with beautiful charts
- 🎯 **Goal Tracking**: Set and monitor daily calorie and macro targets
- 🔒 **Privacy-First**: All data stored locally, images never saved
- 🔐 **BYOK**: Bring your own API key (Claude or Gemini)

## Security & Privacy

### Minimal Permissions
This app only requests what's absolutely necessary:
- **CAMERA**: Required for meal photo capture (image is processed in-memory and immediately discarded)
- **INTERNET**: Required for LLM API calls only (HTTPS enforced)

### NOT Requested
- ❌ Storage permissions (uses app-private SQLite)
- ❌ Location permissions
- ❌ Contacts/Phone/SMS permissions
- ❌ Background services

### Data Security
- **API Keys**: Stored in Android Keystore (hardware-backed encryption)
- **Images**: Never saved to disk, processed in memory only
- **Meal Data**: Stored locally in SQLite (app-private directory)
- **Network**: HTTPS only, cleartext traffic disabled
- **Backup**: Disabled to prevent API key leakage

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── app/
│   ├── router.dart              # Navigation helpers
│   └── theme.dart               # App theming
├── features/
│   ├── camera/                  # Camera screen (home)
│   ├── meal_info/               # Meal analysis results
│   ├── daily_log/               # Daily meal log
│   ├── analytics/               # Charts and statistics
│   ├── search/                  # Manual food search
│   └── settings/                # API keys and goals
├── services/
│   ├── database_service.dart    # SQLite (Drift)
│   ├── secure_storage_service.dart  # API key storage
│   └── llm_service.dart         # Claude/Gemini API
├── models/
│   └── meal_analysis.dart       # Data models
└── widgets/
    └── main_scaffold.dart       # Bottom navigation
```

## Setup

### Prerequisites
- Flutter SDK 3.2.0+
- Android Studio / VS Code
- Android device or emulator

### Installation

1. Clone the repository:
```bash
git clone <repo-url>
cd calorie_tracker
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Drift database code:
```bash
dart run build_runner build
```

4. Run the app:
```bash
flutter run
```

### Build Release APK
```bash
flutter build apk --release
```

## Configuration

### API Keys
The app supports two LLM providers:

1. **Claude (Anthropic)**
   - Get your key from [console.anthropic.com](https://console.anthropic.com)
   - Uses `claude-sonnet-4-20250514` model

2. **Gemini (Google)**
   - Get your key from [makersuite.google.com](https://makersuite.google.com)
   - Uses `gemini-1.5-flash` model

Enter your API key in Settings → AI Configuration.

### Daily Goals
Set your nutrition targets in Settings → Daily Goals:
- Calories (kcal)
- Protein (g)
- Carbs (g)
- Fat (g)

## Indian Food Database

The app includes a built-in database of 50+ Indian dishes with accurate nutritional information sourced from:
- IFCT (Indian Food Composition Tables)
- NIN (National Institute of Nutrition)

Categories include:
- North Indian (Dal, Roti, Paneer dishes, etc.)
- South Indian (Idli, Dosa, Sambar, etc.)
- Rice dishes (Biryani, Pulao, etc.)
- Snacks (Samosa, Pakora, etc.)
- Sweets (Gulab Jamun, Kheer, etc.)
- Beverages (Chai, Lassi, etc.)

## Architecture

### State Management
- **Riverpod**: Clean, testable state management

### Database
- **Drift (SQLite)**: Type-safe, reactive queries
- Schema:
  - `meals`: Meal entries with totals
  - `meal_items`: Individual food items
  - `user_settings`: Goals and preferences
  - `indian_foods`: Pre-seeded food database

### Security
- **flutter_secure_storage**: Android Keystore for API keys
- **Network Security Config**: HTTPS only, whitelisted domains

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `flutter test`
5. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Acknowledgments

- Nutritional data from Indian Food Composition Tables (IFCT)
- Icons from Material Design
- Charts by fl_chart
