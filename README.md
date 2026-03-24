# Kaloree - AI-Powered Calorie Tracking

A privacy-focused calorie tracking app with AI meal recognition, specifically optimized for Indian cuisine.

## Features

- 📷 **AI Meal Analysis**: Point your camera at food and get instant nutritional information using Claude or Gemini
- 🔍 **Manual Search**: Look up Indian dishes from a database of 1000+ foods
- 📊 **Analytics**: Track your nutrition over time with beautiful charts
- 🎯 **Goal Tracking**: Set and monitor daily calorie and macro targets
- 🧮 **TDEE Calculator**: Calculate your daily energy needs based on BMR and activity level
- ❤️ **Favorites**: Save frequently eaten foods for quick logging
- 🍽️ **Custom Foods**: Create your own food entries with custom nutrition data
- 🔐 **Google Sign-In**: Optional authentication for data backup (coming soon)
- 🔒 **Privacy-First**: All data stored locally, images never saved

## Security & Privacy

### Minimal Permissions
This app only requests what's absolutely necessary:
- **CAMERA**: Required for meal photo capture (image is processed in-memory and immediately discarded)
- **INTERNET**: Required for LLM API calls and Firebase services (HTTPS enforced)

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
├── app_boot_controller.dart     # App initialization controller
├── app/
│   ├── router.dart              # Navigation helpers
│   └── theme.dart               # App theming (Kaloree orange flame)
├── core/
│   ├── ads_policy_service.dart  # AdMob policy management
│   ├── analytics_service.dart   # Firebase Analytics
│   ├── firebase_initializer.dart # Firebase setup
│   └── remote_config_service.dart # Firebase Remote Config
├── features/
│   ├── analytics/               # Charts and statistics
│   ├── auth/                    # Firebase Auth & Google Sign-In
│   │   ├── data/auth_repository.dart
│   │   └── presentation/auth_gate.dart
│   ├── camera/                  # Camera screen (AI capture)
│   ├── daily_log/               # Daily meal log
│   ├── favorites/               # Favorite foods & custom foods
│   ├── meal_info/               # Meal analysis results
│   ├── monetization/            # AdMob integration
│   ├── search/                  # Manual food search
│   ├── settings/                # API keys, goals, TDEE
│   ├── shared/                  # Shared feature utilities
│   └── splash/                  # App splash screen
├── models/
│   └── meal_analysis.dart       # Data models
├── services/
│   ├── database_service.dart    # SQLite (Drift) database
│   ├── llm_service.dart         # Claude/Gemini API
│   ├── mlkit_food_detector.dart # ML Kit on-device detection
│   ├── secure_storage_service.dart # API key storage
│   └── tdee_calculator.dart     # BMR/TDEE calculations
├── utils/
│   ├── csv_parser.dart          # CSV data parsing
│   └── food_data_importer.dart  # Food database import
└── widgets/
    ├── brand_hero.dart          # Kaloree brand logo widget
    ├── main_scaffold.dart       # Bottom navigation (4 tabs)
    └── nutrient_chip.dart       # Nutrient display chips
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
cd Kaloree
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
The app supports two LLM providers for AI meal analysis:

1. **Claude (Anthropic)**
   - Get your key from [console.anthropic.com](https://console.anthropic.com)
   - Uses `claude-sonnet-4-20250514` model

2. **Gemini (Google)**
   - Get your key from [makersuite.google.com](https://makersuite.google.com)
   - Uses `gemini-2.0-flash` model

Enter your API key in Settings → AI Configuration.

### Daily Goals
Set your nutrition targets in Settings → Daily Goals:
- Calories (kcal)
- Protein (g)
- Carbs (g)
- Fat (g)

### TDEE Calculator
The app includes a built-in TDEE (Total Daily Energy Expenditure) calculator:
1. Go to Settings → Calculate Goals
2. Enter your profile (age, weight, height, gender)
3. Select your activity level
4. Enter your target weight
5. Tap "Calculate" to auto-set calorie and macro goals

The calculator uses the Mifflin-St Jeor equation for BMR and adjusts based on:
- Activity level (1.2x - 1.9x multiplier)
- Weight goal (deficit for fat loss, surplus for muscle gain)

## Navigation

The app has 4 main tabs:

| Tab | Icon | Description |
|-----|------|-------------|
| **Snap** | 📷 | Camera for AI meal capture + manual search |
| **Today** | 📅 | Daily meal log with goal progress |
| **Insights** | 📊 | Analytics charts (day/week/month/year) |
| **Settings** | ⚙️ | API keys, goals, profile |

## Indian Food Database

The app includes a built-in database of 1000+ Indian dishes with accurate nutritional information sourced from:
- IFCT (Indian Food Composition Tables)
- NIN (National Institute of Nutrition)
- Kaggle Indian Food Nutrition Dataset

Categories include:
- North Indian (Dal, Roti, Paneer dishes, etc.)
- South Indian (Idli, Dosa, Sambar, etc.)
- Rice dishes (Biryani, Pulao, etc.)
- Snacks (Samosa, Pakora, etc.)
- Sweets (Gulab Jamun, Kheer, etc.)
- Beverages (Chai, Lassi, etc.)

## Architecture

### State Management
- **Riverpod**: Clean, testable state management with providers

### Database
- **Drift (SQLite)**: Type-safe, reactive queries
- Schema:
  - `meals`: Meal entries with totals
  - `meal_items`: Individual food items
  - `user_settings`: Goals, profile, and TDEE data
  - `indian_foods`: Pre-seeded food database (1000+ items)
  - `favorite_foods`: User's favorite and custom foods

### Security
- **flutter_secure_storage**: Android Keystore for API keys
- **Network Security Config**: HTTPS only, whitelisted domains

### Firebase Integration
- **Firebase Auth**: Google Sign-In for optional authentication
- **Firebase Analytics**: Usage analytics and events
- **Firebase Remote Config**: Feature flags and A/B testing

### Monetization
- **Google AdMob**: Banner ads and interstitials (policy-compliant)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `flutter test`
5. Run analysis: `flutter analyze`
6. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Acknowledgments

- Nutritional data from Indian Food Composition Tables (IFCT)
- Icons from Material Design
- Charts by fl_chart
- Firebase services by Google
