# Kaloree Code Cleanup - Refactoring Plan (v2)

**Branch:** `cleanup`  
**Base:** `feature/ui-updates` (commit c082f38)  
**Date:** 2026-03-02  
**Version:** 2 (revised based on feedback)

---

## Executive Summary

This plan addresses duplicate code and dead code identified across the Kaloree codebase. The refactoring will:
- Extract 2 reusable widgets (KaloreeBrandHero, NutrientChip)
- Create a pure `FoodSelectionHelper` class (no UI coupling)
- Remove dead code and unused imports
- Use 3 separate commits for easier rollback
- Reduce code duplication by ~83 lines (~42%)

---

## Progress Snapshot

### Completed commits
1. `bc02ce0` - `refactor: extract shared widgets KaloreeBrandHero and NutrientChip`
2. `b95c834` - `refactor: extract FoodSelectionHelper for DRY selection logic`

### In-progress commit
3. `chore: remove dead code and unused imports` (local changes ready)

### Validation status
- `dart analyze` on touched files: no errors/warnings (info-only lint output)
- `flutter build apk --debug`: successful (`build/app/outputs/flutter-apk/app-debug.apk`)
- Manual QA: pending

---

## Key Changes from v1

| Issue | v1 Plan | v2 Plan |
|-------|---------|---------|
| FoodSelectionMixin | Coupled to UI (snackbars, navigation) | Pure helper class - screens own UI |
| Import style | "Use absolute imports" | Keep existing relative imports |
| Validation | "No warnings" | "No regressions" (no new issues) |
| Dead code | Not addressed | Added Phase 2.5 |
| Commits | Single commit | 3 separate commits |
| Deprecated API | `withOpacity()` | `withValues(alpha:)` in new code |

---

## Identified Duplications

### 1. Branded Hero/Logo Block

**Locations:**
| File | Lines | Context |
|------|-------|---------|
| `lib/main.dart` | 137-184 | `_BootLoadingScreen` widget |
| `lib/features/auth/presentation/auth_gate.dart` | 170-217 | `_LoginScreen` widget |

**Duplicate Elements:**
- Circular container with glowing orange shadow
- `Image.asset('assets/images/kaloree_app_logo.png')` with flame icon fallback
- ShaderMask gradient for "Kaloree" app name text
- Same styling: fontSize 48, fontWeight w800, letterSpacing -1.5

---

### 2. NutrientChip Widget

**Locations:**
| File | Lines |
|------|-------|
| `lib/features/search/search_screen.dart` | 457-476 |
| `lib/features/favorites/favorites_screen.dart` | 489-509 |

**100% Identical Implementation** - Also exists in `meal_info_screen.dart` (noted for Phase 2B)

---

### 3. Selection Flow Logic

**Locations:**
| File | Lines | Context |
|------|-------|---------|
| `lib/features/search/search_screen.dart` | 90-124 | `_SearchScreenState` |
| `lib/features/favorites/favorites_screen.dart` | 34-65 | `_FavoritesScreenState` |

**Key Differences:**
| Aspect | search_screen | favorites_screen |
|--------|---------------|------------------|
| Source | `'search'` | `'favorites'` |
| Navigation | `pushReplacement` | `push` |
| Input Type | `IndianFood` | `FavoriteFood` |

---

## Dead Code Identified

### File: `camera_screen.dart`
| Symbol | Issue | Type |
|--------|-------|------|
| `import '../../models/meal_analysis.dart'` | MealAnalysis not referenced | Unused import |
| `_capturedImageBytes` field | Assigned but never read | Write-only variable |

### File: `search_screen.dart`
| Symbol | Issue | Type |
|--------|-------|------|
| `_currentPage` field | Never referenced | Unused field |
| `_pageSize` constant | Never referenced | Unused constant |
| `_loadMorePopularFoods()` method | Sets/resets state immediately | No-op function |

### File: `auth_repository.dart`
| Symbol | Issue | Type |
|--------|-------|------|
| `import 'package:cloud_firestore/cloud_firestore.dart'` | Firestore not used | Unused import |
| `_firestore` field | Declared but never used | Unused field |

### File: `mlkit_food_detector.dart`
| Symbol | Issue | Type |
|--------|-------|------|
| `import 'package:flutter/material.dart'` | Uses `print()` not `debugPrint()` | Unused import |

### File: `main_scaffold.dart`
| Symbol | Issue | Type |
|--------|-------|------|
| `import '../app/theme.dart'` | AppTheme not referenced | Unused import |

---

## Implementation Phases

### Phase 1: Extract Shared Widgets (Commit 1)
**Message:** `refactor: extract shared widgets KaloreeBrandHero and NutrientChip`

- [x] Create `lib/widgets/brand_hero.dart` with `KaloreeBrandHero`
- [x] Create `lib/widgets/nutrient_chip.dart` with `NutrientChip`
- [x] Update `lib/main.dart` to use `KaloreeBrandHero`
- [x] Update `lib/features/auth/presentation/auth_gate.dart` to use `KaloreeBrandHero`
- [x] Update `lib/features/search/search_screen.dart` to use shared `NutrientChip`
- [x] Update `lib/features/favorites/favorites_screen.dart` to use shared `NutrientChip`
- [x] Verify: `flutter analyze` shows no new issues
- [x] Verify: `flutter build apk --debug` succeeds

---

### Phase 2: Selection Logic Refactor (Commit 2)
**Message:** `refactor: extract FoodSelectionHelper for DRY selection logic`

- [x] Create `lib/features/shared/food_selection_helper.dart` (pure logic, no UI)
- [x] Update `search_screen.dart` to use helper (keep snackbar/nav in screen)
- [x] Update `favorites_screen.dart` to use helper (keep snackbar/nav in screen)
- [x] Verify: `flutter analyze` shows no new issues
- [ ] Verify: Manual test selection flow in both screens

---

### Phase 2.5: Dead Code Removal (Commit 3)
**Message:** `chore: remove dead code and unused imports`

- [x] `camera_screen.dart`: Remove unused `meal_analysis.dart` import
- [x] `camera_screen.dart`: Remove unused `_capturedImageBytes` field
- [x] `search_screen.dart`: Remove unused `_currentPage` field
- [x] `search_screen.dart`: Remove unused `_pageSize` constant
- [x] `search_screen.dart`: Remove no-op `_loadMorePopularFoods()` method
- [x] `auth_repository.dart`: Remove unused `cloud_firestore.dart` import
- [x] `auth_repository.dart`: Remove unused `_firestore` field
- [x] `mlkit_food_detector.dart`: Remove unused `material.dart` import
- [x] `main_scaffold.dart`: Remove unused `theme.dart` import
- [x] Verify: `flutter analyze` shows no new issues
- [x] Verify: `flutter build apk --debug` succeeds

---

## New Components Specification

### 1. `lib/widgets/brand_hero.dart`

```dart
import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Reusable Kaloree brand hero widget displaying logo and app name
/// 
/// Used in:
/// - BootLoadingScreen (main.dart)
/// - LoginScreen (auth_gate.dart)
class KaloreeBrandHero extends StatelessWidget {
  /// Size of the logo image/icon (default: 120)
  final double logoSize;
  
  /// Font size for "Kaloree" text (default: 48)
  final double fontSize;
  
  /// Whether to show the glowing shadow effect (default: true)
  final bool showGlow;

  const KaloreeBrandHero({
    super.key,
    this.logoSize = 120,
    this.fontSize = 48,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo with glow
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: showGlow
                ? [
                    BoxShadow(
                      color: AppTheme.flameOrange.withValues(alpha: 0.4),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Image.asset(
            'assets/images/kaloree_app_logo.png',
            width: logoSize,
            height: logoSize,
            errorBuilder: (context, error, stackTrace) {
              return ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.flameGradient.createShader(bounds),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  size: logoSize * 0.67,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        // App Name with gradient
        ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.textGradient.createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(
            'Kaloree',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
```

---

### 2. `lib/widgets/nutrient_chip.dart`

```dart
import 'package:flutter/material.dart';

/// Compact chip displaying a nutrient value with colored background
/// 
/// Used in:
/// - SearchScreen food cards
/// - FavoritesScreen food cards
/// - Potentially MealInfoScreen (Phase 2B)
/// 
/// Example:
/// ```dart
/// NutrientChip(value: '25g P', color: AppTheme.proteinColor)
/// ```
class NutrientChip extends StatelessWidget {
  /// The display value (e.g., "25g P", "30g C", "10g F")
  final String value;
  
  /// The color for text and background tint
  final Color color;
  
  /// Font size (default: 10)
  final double fontSize;

  const NutrientChip({
    super.key,
    required this.value,
    required this.color,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
```

---

### 3. `lib/features/shared/food_selection_helper.dart`

**Pure logic - NO UI/navigation coupling**

```dart
import '../../models/meal_analysis.dart';

/// Pure helper class for food selection logic
/// 
/// Screens are responsible for:
/// - Calling setState after mutations
/// - Showing snackbars
/// - Navigation
/// 
/// This class provides:
/// - Selection list management
/// - MealAnalysis creation
/// - Validation
class FoodSelectionHelper {
  final List<FoodItem> _selectedItems = [];
  
  /// Read-only access to selected items
  List<FoodItem> get selectedItems => List.unmodifiable(_selectedItems);
  
  /// Number of selected items
  int get count => _selectedItems.length;
  
  /// Total calories of selected items
  int get totalCalories => 
      _selectedItems.fold(0, (sum, item) => sum + item.calories);
  
  /// Check if any items are selected
  bool get hasSelection => _selectedItems.isNotEmpty;
  
  /// Add item to selection
  /// Returns the added item for snackbar display
  FoodItem addItem(FoodItem item) {
    _selectedItems.add(item);
    return item;
  }
  
  /// Remove item at index
  /// Returns removed item or null if index invalid
  FoodItem? removeAt(int index) {
    if (index < 0 || index >= _selectedItems.length) return null;
    return _selectedItems.removeAt(index);
  }
  
  /// Clear all selections
  void clear() => _selectedItems.clear();
  
  /// Build MealAnalysis from current selection
  /// Returns null if selection is empty
  MealAnalysis? buildAnalysis({required String source}) {
    if (_selectedItems.isEmpty) return null;
    
    return MealAnalysis(
      items: List.from(_selectedItems), // Create a copy
      confidence: 'high',
      source: source,
    );
  }
  
  /// Validate selection (at least one item)
  bool validate() => _selectedItems.isNotEmpty;
}
```

**Usage in screens (keeps UI logic in screen):**

```dart
// In _SearchScreenState
final _selectionHelper = FoodSelectionHelper();

void _addToSelection(IndianFood food) {
  final item = FoodItem(
    name: food.name,
    portion: food.servingSize,
    // ... other fields
  );
  
  final added = _selectionHelper.addItem(item);
  setState(() {}); // Trigger rebuild
  
  // UI logic stays in screen
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Added ${added.name}')),
  );
}

void _proceed() {
  final analysis = _selectionHelper.buildAnalysis(source: 'search');
  if (analysis == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Select at least one item')),
    );
    return;
  }
  
  // Navigation stays in screen
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => MealInfoScreen(analysis: analysis)),
  );
}
```

---

## Validation Criteria

**Changed from "no warnings" to "no regressions":**

- [ ] `flutter analyze` shows no **new** issues compared to pre-refactor
- [ ] `flutter test` shows no new test failures (same baseline failures acceptable)
- [ ] `flutter build apk --debug` succeeds
- [ ] Manual test: Boot loading screen displays correctly
- [ ] Manual test: Login screen displays correctly
- [ ] Manual test: Search screen selection flow works
- [ ] Manual test: Favorites screen selection flow works
- [ ] Manual test: Nutrient chips display correctly in both screens

---

## Code Reduction Summary

| Component | Before | After | Lines Saved |
|-----------|--------|-------|-------------|
| Brand Hero | ~94 lines (2×47) | ~50 lines | **44 lines** |
| NutrientChip | ~40 lines (2×20) | ~22 lines | **18 lines** |
| Selection Logic | ~66 lines (35+31) | ~45 lines | **21 lines** |
| Dead Code | N/A | Removed | **~15 lines** |
| **Total** | **~200+ lines** | **~117 lines** | **~98 lines** |

---

## Commit Strategy

| Commit | Message | Files Changed (approx) | Risk Level |
|--------|---------|------------------------|------------|
| 1 | `refactor: extract shared widgets KaloreeBrandHero and NutrientChip` | ~6 files | Low |
| 2 | `refactor: extract FoodSelectionHelper for DRY selection logic` | ~3 files | Medium |
| 3 | `chore: remove dead code and unused imports` | ~5 files | Low |

---

## Future Opportunities (Phase 2B - Not in Scope)

After this refactoring, consider:

1. **Expand NutrientChip usage:**
   - `meal_info_screen.dart` (line 464) also has similar chip widget

2. **Unify food cards:**
   - `_FoodSearchCard` and `_FavoriteCard` share similar structure
   - Could create shared `FoodCard` widget

3. **Create widgets barrel file:**
   ```dart
   // lib/widgets/widgets.dart
   export 'brand_hero.dart';
   export 'nutrient_chip.dart';
   export 'main_scaffold.dart';
   ```

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Helper class adds indirection | Comprehensive documentation + simple API |
| Widget extraction may break styling | Compare screenshots before/after |
| Dead code removal may break something | Each dead code item verified as truly unused |
| Multiple commits complicate review | Each commit is self-contained and tested |

---

*Plan v2 created by Roo - Architect Mode*
*Revised based on feedback: decoupled selection helper, kept relative imports, added dead code phase, split commits*
