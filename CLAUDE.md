# CLAUDE.md - Kaloree Project Configuration

This file provides context for Claude Code (Claude's CLI coding assistant) when working on this project.

## Project Overview

**Kaloree** is a Flutter mobile app for AI-powered calorie tracking, specifically optimized for Indian cuisine. Users can photograph meals for AI analysis or manually search from a database of 1000+ Indian foods.

## Tech Stack

| Component | Technology |
|-----------|------------|
| **Framework** | Flutter 3.2+ / Dart |
| **State Management** | Riverpod |
| **Database** | Drift (SQLite) |
| **Auth** | Firebase Auth (Google Sign-In) |
| **Analytics** | Firebase Analytics |
| **Remote Config** | Firebase Remote Config |
| **Monetization** | Google AdMob |
| **AI/ML** | Claude API, Gemini API, ML Kit |
| **Secure Storage** | flutter_secure_storage (Android Keystore) |

## Key Directories

```
lib/
├── app/           # Router, theme, app-wide config
├── core/          # Firebase, analytics, remote config, ads policy
├── features/      # Feature modules (camera, search, analytics, auth, etc.)
├── models/        # Data models (MealAnalysis, FoodItem)
├── services/      # Business logic (database, LLM, auth, TDEE)
├── utils/         # CSV parsing, food import utilities
└── widgets/       # Reusable UI components (brand_hero, nutrient_chip)
```

## Common Commands

```bash
# Development
flutter run                          # Run in debug mode
flutter run --release                # Run in release mode

# Testing
flutter test                         # Run unit tests
flutter analyze                      # Static analysis

# Code Generation (Drift)
dart run build_runner build          # Generate database code
dart run build_runner watch          # Watch mode for code generation

# Building
flutter build apk --release          # Build Android APK
flutter build appbundle --release    # Build Android App Bundle
flutter clean                        # Clean build artifacts
```

## Code Conventions

### Imports
- Use **relative imports** within `lib/` (e.g., `import '../services/database_service.dart';`)
- Avoid absolute `package:kaloree/` imports within the lib directory

### Styling
- Use `withValues(alpha: 0.5)` instead of deprecated `withOpacity(0.5)`
- Follow existing theme colors from `lib/app/theme.dart`
- Brand colors: Orange gradient `#FF6B35` → `#FFA500`

### State Management
- Use Riverpod providers for all state management
- Place providers in their respective feature directories
- Use `ref.watch()` for reactive state, `ref.read()` for one-time reads

### Feature Structure
Each feature in `lib/features/` follows this pattern:
```
features/feature_name/
├── feature_screen.dart          # Main UI widget
├── data/                        # Repository, data sources (if needed)
│   └── feature_repository.dart
└── presentation/                # Additional UI components (if needed)
```

### Database (Drift)
- Schema defined in `lib/services/database_service.dart`
- Generated code in `database_service.g.dart`
- Run `dart run build_runner build` after schema changes
- Use migrations for schema updates (see existing migration patterns)

## Important Files

| File | Purpose |
|------|---------|
| [`lib/main.dart`](lib/main.dart) | App entry point, Firebase init |
| [`lib/app/theme.dart`](lib/app/theme.dart) | AppTheme, colors, gradients |
| [`lib/services/database_service.dart`](lib/services/database_service.dart) | Drift database, all tables |
| [`lib/services/llm_service.dart`](lib/services/llm_service.dart) | Claude/Gemini API integration |
| [`lib/widgets/main_scaffold.dart`](lib/widgets/main_scaffold.dart) | Bottom navigation (4 tabs) |
| [`pubspec.yaml`](pubspec.yaml) | Dependencies and assets |

## Current State

- **Package ID**: `com.kaloree.app`
- **App Name**: Kaloree
- **Current Branch**: `main`
- **Navigation**: 4 tabs (Snap, Today, Insights, Settings)
- **LLM Providers**: Claude (Anthropic), Gemini (Google)
- **Food Database**: 1000+ Indian foods from CSV/prebuilt SQLite

## Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## Known Patterns

### Adding a New Feature
1. Create directory under `lib/features/feature_name/`
2. Create main screen widget
3. Add navigation in `lib/widgets/main_scaffold.dart` (if tab-level)
4. Create providers in feature directory
5. Update database schema if persistent data needed

### Adding a New Food Source
1. Place CSV in `assets/data/`
2. Update `pubspec.yaml` assets
3. Use `FoodDataImporter` to import data
4. Run on first launch or provide UI trigger

### Modifying Database Schema
1. Update table definitions in `database_service.dart`
2. Add migration in `migration` getter
3. Run `dart run build_runner build`
4. Test migration from previous version

## Environment

- **Minimum SDK**: Flutter 3.2.0
- **Target SDK**: Android 34, iOS 17
- **Build System**: Gradle (Android), CocoaPods (iOS)

## Firebase Configuration

Firebase config files are required but not committed:
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

Contact repository owner for Firebase project access.

## Don't Forget

- Run `flutter analyze` before commits
- Run `dart run build_runner build` after database changes
- Test on both Android and iOS if making platform-specific changes
- Update this file if adding major new features or changing conventions
