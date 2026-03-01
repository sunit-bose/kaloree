# Kaloree Comprehensive Feature Comparison
## `feature/ui-updates` (v1 Baseline) → `release-v2`

**Generated:** 2026-02-28  
**Baseline Commit:** `00c5910` (Initial commit: Kaloree - AI-Powered Calorie Tracking App)  
**Release Commit:** `e0ac253` (Release v2)

---

## 📊 Branch Relationship

```
feature/ui-updates = main = 00c5910 (Initial Commit)
                        │
                        ▼
                   release-v2 = e0ac253
                   (+15 files, +4,884 lines, -175 lines)
```

**Note:** `feature/ui-updates` and `main` point to the same commit. All baseline features exist in both. `release-v2` adds new features on top.

---

# 📱 PAGE-BY-PAGE FEATURE ANALYSIS

---

## 1. 📷 Camera Screen (`lib/features/camera/camera_screen.dart`)

### ✅ BASELINE FEATURES (v1 - feature/ui-updates)

| Feature | Description | Implementation |
|---------|-------------|----------------|
| **Camera Preview** | Full-screen camera viewfinder | `CameraController` with high resolution |
| **Flash Toggle** | Cycle through off/auto/on modes | `_toggleFlash()` with icon updates |
| **AI Capture Button** | Gradient circular button with glow effect | 80x80 Container with `AppTheme.primaryGradient` |
| **Manual Search Button** | Orange gradient button to right of camera | 60x60 Container with `AppTheme.flameGradient` |
| **Loading States** | Capturing spinner, analyzing overlay | `_isCapturing`, `_isAnalyzing` states |
| **Instructional Banner** | "Point at your meal • AI will identify items" | Semi-transparent overlay at top |
| **ML Kit Integration** | On-device food detection before LLM | `MLKitFoodDetector` service |
| **Image Preview Flow** | Confirm image before sending to AI | `ImagePreviewScreen` navigation |
| **Error Handling** | Camera not available message | Desktop/permission error handling |

### 🔄 UNCHANGED IN release-v2
No changes to camera_screen.dart in release-v2.

---

## 2. 🍽️ Meal Info Screen (`lib/features/meal_info/meal_info_screen.dart`)

### ✅ BASELINE FEATURES (v1 - feature/ui-updates)

| Feature | Description | Implementation |
|---------|-------------|----------------|
| **Summary Card** | Gradient card showing total calories + macros | `AppTheme.primaryGradient` with shadow |
| **Editable Food Items** | Tap any item to edit portion/calories/macros | `_editItem(index)` → `_EditItemSheet` |
| **Delete Food Items** | Swipe or tap to remove items | `onDelete` callback in edit sheet |
| **Add Manual Item** | "Add" button to create custom entries | `_addManualItem()` → empty `_EditItemSheet` |
| **Meal Type Selection** | Auto-infer based on time, chips to change | `_inferMealType()`, breakfast/lunch/dinner/snack |
| **Date Picker** | Tap date to log for different day | `showDatePicker()` with "Today"/"Yesterday" labels |
| **Edit Sheet** | Bottom sheet with portion, grams, all macros | `_EditItemSheet` widget with form fields |
| **Save to Log** | Save meal to database with refresh trigger | `database.saveMeal()` + `diaryRefreshProvider` |

### 🆕 ADDED IN release-v2 (+58 lines)

| Feature | Description | Implementation |
|---------|-------------|----------------|
| **Auto-Recalculate Macros** | When grams change, all macros update proportionally | Per-100g base values + listener on `_gramsController` |

**Code Change:**
```dart
// Added per-100g calculations for proportional editing
double _proteinPer100g, _carbsPer100g, _fatPer100g, _fiberPer100g, _caloriesPer100g;

// Listener recalculates when grams change
_gramsController.addListener(() {
  final grams = int.tryParse(_gramsController.text) ?? 100;
  _caloriesController.text = ((_caloriesPer100g * grams) / 100).round().toString();
  _proteinController.text = ((_proteinPer100g * grams) / 100).toStringAsFixed(1);
  // ... same for carbs, fat, fiber
});
```

---

## 3. 📅 Daily Log Screen (`lib/features/daily_log/daily_log_screen.dart`)

### ✅ BASELINE FEATURES (v1 - feature/ui-updates)

| Feature | Description | Implementation |
|---------|-------------|----------------|
| **Date Navigation** | Pill-style date selector with arrows | Gradient container with chevron buttons |
| **Calendar Picker** | Tap date label to open date picker | `showDatePicker()` |
| **Goal Progress Card** | Visual progress bars for calories + macros | `_GoalProgressCard` with percentage calculations |
| **Meal Cards** | Expandable cards for each meal | `_MealCard` with items list |
| **Meal Type Dropdown** | Change meal type after logging | `onTypeChanged` callback |
| **Delete Meal** | Remove entire meal from log | `database.deleteMeal()` |
| **Empty State** | Illustration when no meals logged | `_EmptyState` widget |
| **Auto Refresh** | Refresh when returning from meal logging | `diaryRefreshProvider` watch |

### 🔄 UNCHANGED IN release-v2
No changes to daily_log_screen.dart in release-v2.

---

## 4. 🔍 Search Screen (`lib/features/search/search_screen.dart`)

### ✅ BASELINE FEATURES (v1 - feature/ui-updates)

| Feature | Description | Implementation |
|---------|-------------|----------------|
| **Search Input** | Text field with clear button | `TextField` with `onChanged` callback |
| **Indian Foods Database** | Query SQLite for matching foods | `database.searchFoods(query)` |
| **Food Cards** | Name, serving, region, macro chips, calories | `_FoodSearchCard` widget |
| **Popular Foods** | Show all foods when no search query | `_PopularFoods` widget |
| **Infinite Scroll** | Load more as user scrolls | `_displayCount` increment on scroll |
| **Multi-Select** | Add multiple items to selection | `_selectedItems` list with chips |
| **Selection Chips** | Horizontal chip bar showing selected items | `Chip` with delete button |
| **Continue Button** | Navigate to MealInfoScreen with selection | `_proceed()` with `MealAnalysis` |

### 🆕 ADDED IN release-v2 (+163 lines)

| Feature | Description | Implementation |
|---------|-------------|----------------|
| **OpenFoodFacts Badge** | Green attribution badge above search | "🌱 Powered by OpenFoodFacts" container |
| **Heart Icon on Cards** | Toggle favorite status per food | `_FoodSearchCardState` with `isFavorite` check |
| **Favorite Toggle** | Tap heart to add/remove from favorites | `_toggleFavorite()` with database calls |
| **Loading Indicator** | Spinner while checking/toggling favorite | `_isLoading` state |
| **Snackbar Feedback** | "Added to favorites" / "Removed" messages | `ScaffoldMessenger.showSnackBar()` |

**UI Change:**
```
Before: [Food Info] [Calories] [+ Add]
After:  [Food Info] [Calories] [❤️ Heart] [+ Add]
```

---

## 5. 📊 Analytics Screen (`lib/features/analytics/analytics_screen.dart`)

### ✅ BASELINE FEATURES (v1 - feature/ui-updates)

| Feature | Description | Implementation |
|---------|-------------|----------------|
| **Time Range Selector** | Today/Week/Month/Year toggle pills | `TimeRange` enum with selection state |
| **Calorie Bar Chart** | Daily intake vs goal visualization | `fl_chart` BarChart |
| **Tooltip on Touch** | Show exact calories when tapping bars | `BarTouchTooltipData` |
| **Macro Breakdown Card** | Average P/C/F distribution | `_MacroBreakdownCard` |
| **Stats Card** | Average daily calories, best/worst days | `_StatsCard` |
| **Empty State** | Illustration when no data | `_EmptyAnalytics` widget |
| **Dynamic Labels** | E for week days, d for month dates | Conditional `DateFormat` |

### 🔄 UNCHANGED IN release-v2
No changes to analytics_screen.dart in release-v2.

---

## 6. ⚙️ Settings Screen (`lib/features/settings/settings_screen.dart`)

### ✅ BASELINE FEATURES (v1 - feature/ui-updates)

| Feature | Description | Implementation |
|---------|-------------|----------------|
| **LLM Provider Selection** | Claude / Gemini / Groq radio tiles | `ListTile` with `LLMProvider` enum |
| **API Key Input** | Masked text field for each provider | `TextField` with obscureText |
| **Save API Key** | Store securely in keychain | `SecureStorageService` |
| **Calorie Goal** | Numeric input for daily target | `TextEditingController` |
| **Macro Goals** | P/C/F numeric inputs | Individual controllers |

### 🆕 ADDED IN release-v2 (+674 lines)

| Feature | Description | Implementation |
|---------|-------------|----------------|
| **Groq Removal** | Removed Groq as provider option | Deleted from enum and UI |
| **User Profile Section** | Age, weight, height, gender inputs | New form fields |
| **Activity Level Dropdown** | Sedentary to Extra Active | `DropdownButton` with `ActivityLevel` |
| **Target Weight Input** | Goal weight for calorie calculation | New numeric field |
| **Calculate Button** | Compute TDEE and macros | `_calculateGoals()` |
| **BMR Display** | Show calculated basal metabolic rate | Stat box with value |
| **TDEE Display** | Show total daily energy expenditure | Stat box with value |
| **BMR Tooltip** | Tap info icon for explanation | `_buildStatBoxWithTooltip()` + dialog |
| **TDEE Tooltip** | Tap info icon for explanation | Dialog with formula description |
| **Save Button** | Persist profile and calculated goals | `database.saveUserProfile()` |
| **Macro Distribution** | Auto-calculate P/C/F based on goal | `TDEECalculator.calculateNutritionTargets()` |

---

## 7. ❤️ Favorites Screen (`lib/features/favorites/favorites_screen.dart`)

### 🆕 NEW IN release-v2 (+509 lines)

| Feature | Description | Implementation |
|---------|-------------|----------------|
| **Favorites List** | Display all saved favorite foods | `FutureBuilder` with `database.getFavorites()` |
| **Quick Add** | Tap to add to current selection | `_addToSelection()` |
| **Multi-Select** | Select multiple for batch logging | `_selectedItems` list |
| **Quick Log Button** | Navigate to MealInfoScreen with selection | `_proceed()` |
| **Delete Favorite** | Swipe or button to remove | `database.removeFromFavorites()` |
| **Custom Food Badge** | Orange "Custom" label for user-created | `isCustom` flag check |
| **Favorite Badge** | Red heart indicator | Conditional icon |
| **Add Custom Food** | Bottom sheet with full form | `_showAddCustomFoodDialog()` |
| **Custom Food Form** | Name, portion, grams, all macros | Form with 8 input fields |
| **Empty State** | Prompt to add favorites or custom foods | Illustration + buttons |

---

## 8. 🧭 Navigation (`lib/widgets/main_scaffold.dart`)

### ✅ BASELINE FEATURES (v1 - feature/ui-updates)

| Feature | Description | Implementation |
|---------|-------------|----------------|
| **4-Tab Navigation** | Snap, Today, Insights, Settings | `IndexedStack` + `BottomNavigationBar` |
| **Color-Coded Tabs** | Different gradient for each tab | `_tabColors` array |
| **Active Indicator** | Dot under selected tab | Conditional container |

### 🆕 CHANGED IN release-v2 (+16 lines)

| Change | Before | After |
|--------|--------|-------|
| Tab Count | 4 tabs | 5 tabs |
| Tab 0 | Snap (Camera) | **Favs (Favorites)** |
| Tab 1 | Today | Snap (Camera) |
| Tab 2 | Insights | Today |
| Tab 3 | Settings | Insights |
| Tab 4 | - | Settings |
| Default Index | 0 | 1 (Camera) |

---

## 9. 🤖 LLM Service (`lib/services/llm_service.dart`)

### ✅ BASELINE FEATURES (v1 - feature/ui-updates)

| Feature | Description | Implementation |
|---------|-------------|----------------|
| **Claude Integration** | Anthropic API for image analysis | `_analyzeWithClaude()` |
| **Gemini Integration** | Google AI API for image analysis | `_analyzeWithGemini()` |
| **Groq Integration** | Llama 3.2 Vision API | `_analyzeWithGroq()` |
| **JSON Parsing** | Extract food items from LLM response | `_parseResponse()` |
| **Prompt Engineering** | Detailed instructions for food analysis | `_getPrompt()` |
| **Error Handling** | API key validation, rate limits, network | `try/catch` with `LLMException` |

### 🆕 CHANGED IN release-v2 (-52 lines)

| Change | Description |
|--------|-------------|
| **Groq Removal** | Deleted `_analyzeWithGroq()` method |
| **Groq Validation** | Removed `gsk_` prefix check |
| **Gemini Model** | Changed from `gemini-2.0-flash-exp` to `gemini-2.0-flash` |

---

## 10. 🔐 Secure Storage (`lib/services/secure_storage_service.dart`)

### ✅ BASELINE FEATURES (v1 - feature/ui-updates)

| Feature | Description | Implementation |
|---------|-------------|----------------|
| **Claude API Key** | Secure storage for Anthropic key | `_claudeApiKey` |
| **Gemini API Key** | Secure storage for Google key | `_geminiApiKey` |
| **Groq API Key** | Secure storage for Groq key | `_groqApiKey` |
| **Provider Selection** | Remember selected provider | `_selectedProvider` |

### 🆕 CHANGED IN release-v2 (-33 lines)

| Change | Description |
|--------|-------------|
| **Groq Removal** | Deleted `setGroqApiKey()`, `getGroqApiKey()`, `hasGroqApiKey()` |
| **Provider Enum** | Removed `groq` from `LLMProvider` enum |

---

## 11. 🗄️ Database Service (`lib/services/database_service.dart`)

### ✅ BASELINE FEATURES (v1 - feature/ui-updates)

| Feature | Description | Implementation |
|---------|-------------|----------------|
| **Meals Table** | Store logged meals | `Meals` drift table |
| **MealItems Table** | Store food items per meal | `MealItems` drift table |
| **UserSettings Table** | Store goals | `UserSettings` drift table |
| **IndianFoods Table** | Food database | `IndianFoods` drift table |
| **CSV Import** | Load foods from CSV file | `importFoodsFromCSV()` |
| **Seed Data** | 43 fallback foods | `_seedIndianFoods()` |
| **Search** | Query foods by name/alias | `searchFoods()` |

### 🆕 ADDED IN release-v2 (+333 lines)

| Feature | Description | Implementation |
|---------|-------------|----------------|
| **FavoriteFoods Table** | New table for favorites | `FavoriteFoods` drift table |
| **Schema v2** | TDEE profile columns | Migration: age, weight, height, gender, activity |
| **Schema v3** | Target weight | Migration: targetWeightKg |
| **Schema v4** | Favorites table | Migration: create favoriteFoods |
| **Prebuilt DB Import** | Faster SQLite copy instead of CSV | `_importFromPrebuiltDatabase()` |
| **Add Favorite** | Insert food to favorites | `addToFavorites()` |
| **Get Favorites** | Query all favorites | `getFavorites()` |
| **Is Favorite** | Check by name | `isFavorite()` |
| **Remove Favorite** | Delete by id or name | `removeFromFavorites()`, `removeFromFavoritesByName()` |
| **Add Custom Food** | Insert custom with isCustom=true | `addCustomFood()` |
| **User Profile CRUD** | Get/save profile | `getUserProfile()`, `saveUserProfile()` |
| **TDEE Cache** | Store calculated BMR/TDEE | `calculatedBmr`, `calculatedTdee` columns |

---

## 12. 🧮 TDEE Calculator (`lib/services/tdee_calculator.dart`)

### 🆕 NEW IN release-v2 (+310 lines)

| Feature | Description | Implementation |
|---------|-------------|----------------|
| **Mifflin-St Jeor BMR** | Scientific BMR calculation | Men: 10w + 6.25h - 5a + 5, Women: -161 |
| **Activity Multipliers** | PAL values for TDEE | 1.2 to 1.9 multipliers |
| **Fitness Goals** | Calorie adjustments | -400 fat loss, 0 maintain, +300 muscle |
| **Macro Distribution** | Automatic P/C/F split | Based on goal type |
| **Target Weight Logic** | Derive goal from weight difference | `FitnessGoal.fromWeightDifference()` |
| **Nutrition Targets** | Complete macro calculation | `calculateNutritionTargets()` |

---

# 📋 SUMMARY: What's in Each Version

## feature/ui-updates (v1 Baseline) Contains:

1. ✅ Full camera capture with AI analysis
2. ✅ Manual food search with 1014 Indian foods
3. ✅ Editable food items on meal logging screen
4. ✅ Delete/modify food items
5. ✅ Meal type selection and date picker
6. ✅ Daily log with goal progress
7. ✅ Analytics with charts (day/week/month/year)
8. ✅ 3 LLM providers (Claude, Gemini, Groq)
9. ✅ 4-tab navigation
10. ✅ Basic calorie/macro goals
11. ✅ Camera button with gradient glow
12. ✅ Search button with flame gradient
13. ✅ Flash toggle

## release-v2 Adds:

1. 🆕 **Favorites System** - New screen, database table, heart icons
2. 🆕 **Custom Foods** - Create personal food entries
3. 🆕 **TDEE Calculator** - Mifflin-St Jeor BMR/TDEE
4. 🆕 **User Profile** - Age, weight, height, activity level
5. 🆕 **BMR/TDEE Tooltips** - Educational info dialogs
6. 🆕 **Auto-Recalc Macros** - Proportional updates on weight edit
7. 🆕 **OpenFoodFacts Badge** - Attribution in search
8. 🆕 **Heart Icon on Search** - Quick favorite toggle
9. 🆕 **5-Tab Navigation** - Added Favorites tab
10. ❌ **Groq Removed** - Simplified to 2 providers
11. 🔄 **Gemini Stable** - Changed to non-experimental model
12. 🔄 **Prebuilt SQLite** - Faster food database loading
13. 🔄 **Schema v4** - Database migrations for new features

---

# 🎯 Feature Parity Matrix

| Feature | v1 (feature/ui-updates) | v2 (release-v2) |
|---------|:-----------------------:|:---------------:|
| Camera AI Analysis | ✅ | ✅ |
| Manual Food Search | ✅ | ✅ |
| Edit Food Items | ✅ | ✅ |
| Auto-Recalc on Edit | ❌ | ✅ |
| Delete Food Items | ✅ | ✅ |
| Meal Type Selection | ✅ | ✅ |
| Date Picker | ✅ | ✅ |
| Daily Log View | ✅ | ✅ |
| Analytics Charts | ✅ | ✅ |
| Claude Provider | ✅ | ✅ |
| Gemini Provider | ✅ (exp) | ✅ (stable) |
| Groq Provider | ✅ | ❌ |
| Basic Goals | ✅ | ✅ |
| TDEE Calculation | ❌ | ✅ |
| User Profile | ❌ | ✅ |
| Favorites System | ❌ | ✅ |
| Custom Foods | ❌ | ✅ |
| Heart Icon Search | ❌ | ✅ |
| OpenFoodFacts Badge | ❌ | ✅ |
| 4-Tab Nav | ✅ | ❌ |
| 5-Tab Nav | ❌ | ✅ |
