# Kaloree Documentation Cleanup Plan

**Date:** 2026-03-24  
**Status:** Planning  
**Branch:** `main` or dedicated `docs/cleanup` branch

---

## Executive Summary

The Kaloree repository contains documentation that still references the old app name "NutriSnap" and has outdated project structure information. This plan outlines a comprehensive cleanup to:

1. Rebrand all documentation from NutriSnap → Kaloree
2. Update project structure to reflect current codebase
3. Create a CLAUDE.md configuration file
4. Consolidate/archive auxiliary documentation
5. Clean up the plans directory

---

## Current Documentation Inventory

### Root-Level Files

| File | Status | Issues |
|------|--------|--------|
| [`README.md`](../README.md) | ❌ Needs Update | Title says "NutriSnap", outdated structure, missing Firebase/Auth |
| [`SECURITY.md`](../SECURITY.md) | ❌ Needs Update | References "NutriSnap", missing Firebase Auth |
| [`API_404_FIX.md`](../API_404_FIX.md) | ⚠️ Consider Archive | Specific fix doc, may be obsolete |
| [`DATASET_IMPORT_QUICK_START.md`](../DATASET_IMPORT_QUICK_START.md) | ❌ Needs Update | References "NutriSnap", duplicates README_DATASET_INTEGRATION |
| [`IMPORT_FIX_SUMMARY.md`](../IMPORT_FIX_SUMMARY.md) | ⚠️ Consider Archive | Specific fix doc, technical debt |
| [`PACKAGE_RENAME_SUMMARY.md`](../PACKAGE_RENAME_SUMMARY.md) | ✅ Keep | Documents package rename, useful history |
| [`README_DATASET_INTEGRATION.md`](../README_DATASET_INTEGRATION.md) | ❌ Needs Update | References "NutriSnap" |
| [`README_LOGO_SETUP.md`](../README_LOGO_SETUP.md) | ❌ Needs Update | References "NutriSnap" logo |
| `CLAUDE.md` | 🆕 Create | Does not exist, needed for Claude Code |

### Plans Directory

| File | Status | Recommendation |
|------|--------|----------------|
| [`cleanup-refactoring-plan.md`](cleanup-refactoring-plan.md) | ✅ Completed | Archive to `plans/archive/` |
| [`kaloree-orchestrator-mvp.md`](kaloree-orchestrator-mvp.md) | 📍 Active | Keep - ongoing orchestrator project |
| [`RELEASE_V2_COMPARISON.md`](RELEASE_V2_COMPARISON.md) | ✅ Completed | Archive - historical reference |
| [`sqlite_migration_plan.md`](sqlite_migration_plan.md) | ⏸️ Deferred | Keep - future optimization |

---

## Phase 1: README.md Overhaul

### Current Issues

1. **Wrong Title**: "NutriSnap - AI-Powered Calorie Tracker" → should be "Kaloree"
2. **Outdated Clone Path**: `cd calorie_tracker` → should be `cd Kaloree`
3. **Missing Features**:
   - Firebase Authentication
   - Google Sign-In
   - Remote Config
   - AdMob monetization
   - Favorites system
   - TDEE calculator
   - User profiles
4. **Wrong Navigation**: Documents 5 tabs but app has 4 tabs now
5. **Project Structure**: Missing new directories:
   - `lib/features/auth/`
   - `lib/core/` (monetization, providers)
   - `lib/widgets/` (brand_hero, nutrient_chip)

### Proposed README Structure

```markdown
# Kaloree - AI-Powered Calorie Tracking

## Features
- AI Meal Analysis (Claude/Gemini)
- 1000+ Indian Food Database
- TDEE & Macro Calculator
- Daily/Weekly Analytics
- Favorites & Custom Foods
- Google Sign-In (optional)

## Quick Start
## Architecture
## Security & Privacy
## Configuration
## Contributing
## License
```

---

## Phase 2: SECURITY.md Update

### Current Issues

1. References "NutriSnap" instead of "Kaloree"
2. Missing Firebase Authentication section
3. Database path shows old package name `com.example.calorie_tracker`

### Required Changes

- Replace all "NutriSnap" → "Kaloree"
- Update database path: `/data/data/com.kaloree.app/databases/`
- Add Firebase Auth security considerations
- Add Google Sign-In permissions explanation

---

## Phase 3: Create CLAUDE.md

A configuration file for Claude Code to understand the project:

```markdown
# CLAUDE.md

## Project Overview
Kaloree is a Flutter mobile app for AI-powered calorie tracking, 
optimized for Indian cuisine.

## Tech Stack
- Flutter 3.2+ / Dart
- Riverpod (state management)
- Drift (SQLite database)
- Firebase (Auth, Analytics, Remote Config)
- Google AdMob (monetization)

## Key Directories
- lib/features/ - Feature modules (camera, search, analytics, auth)
- lib/services/ - Business logic (database, LLM, auth)
- lib/core/ - Shared utilities (monetization, providers)
- lib/widgets/ - Reusable UI components

## Commands
- flutter run - Development
- flutter test - Run tests
- flutter analyze - Static analysis
- dart run build_runner build - Generate Drift code

## Conventions
- Use relative imports within lib/
- Feature-first directory structure
- Riverpod for state management
- withValues(alpha:) instead of withOpacity()

## Current Branch: main
## Android Package: com.kaloree.app
```

---

## Phase 4: Consolidate Auxiliary Docs

### Recommendation: Create `docs/` Directory

```
docs/
├── guides/
│   ├── dataset-integration.md    (merge DATASET_IMPORT + README_DATASET_INTEGRATION)
│   └── logo-setup.md             (from README_LOGO_SETUP.md)
├── fixes/                        (or archive to plans/archive/)
│   ├── api-404-fix.md
│   └── import-fix-summary.md
└── CHANGELOG.md                  (optional)
```

### Alternative: Archive to plans/

Move fix-related docs to `plans/archive/` since they document historical issues.

---

## Phase 5: Plans Directory Cleanup

### Create Archive Subdirectory

```
plans/
├── archive/
│   ├── cleanup-refactoring-plan.md    (completed)
│   ├── RELEASE_V2_COMPARISON.md       (completed)
│   └── api-404-fix.md                 (from root)
├── kaloree-orchestrator-mvp.md        (active)
├── sqlite_migration_plan.md           (deferred)
└── documentation-cleanup-plan.md      (this file)
```

---

## Implementation Checklist

### High Priority

- [ ] **README.md**: Complete overhaul
  - [ ] Change title to "Kaloree"
  - [ ] Update clone instructions
  - [ ] Add Firebase Auth section
  - [ ] Add Favorites system docs
  - [ ] Add TDEE calculator docs
  - [ ] Update project structure
  - [ ] Fix navigation description (4 tabs)
  - [ ] Update LLM providers (removed Groq)

- [ ] **SECURITY.md**: Update branding
  - [ ] Replace "NutriSnap" with "Kaloree"
  - [ ] Update database path
  - [ ] Add Firebase Auth section

- [ ] **CLAUDE.md**: Create new file
  - [ ] Project overview
  - [ ] Tech stack
  - [ ] Key directories
  - [ ] Commands
  - [ ] Conventions

### Medium Priority

- [ ] **Consolidate dataset docs**: Merge into single guide
  - [ ] Merge DATASET_IMPORT_QUICK_START.md + README_DATASET_INTEGRATION.md
  - [ ] Update to reference Kaloree

- [ ] **Update logo setup**: README_LOGO_SETUP.md
  - [ ] Reference Kaloree logo assets
  - [ ] Update file paths

- [ ] **Plans cleanup**:
  - [ ] Create `plans/archive/` directory
  - [ ] Move completed plans to archive
  - [ ] Keep active plans in root

### Low Priority

- [ ] Create docs/ directory structure
- [ ] Add CHANGELOG.md
- [ ] Archive fix documentation

---

## Commit Strategy

| Order | Commit Message | Files |
|-------|----------------|-------|
| 1 | `docs: rebrand README.md from NutriSnap to Kaloree` | README.md |
| 2 | `docs: update SECURITY.md branding and add Firebase` | SECURITY.md |
| 3 | `docs: add CLAUDE.md configuration file` | CLAUDE.md |
| 4 | `docs: consolidate and update auxiliary documentation` | Multiple |
| 5 | `chore: archive completed plans` | plans/ |

---

## Decision Points for User

1. **Documentation Structure**: 
   - Option A: Keep docs in root (simpler)
   - Option B: Create `docs/` directory (cleaner)

2. **Archive Strategy**:
   - Option A: Move to `plans/archive/`
   - Option B: Delete obsolete docs
   - Option C: Keep all docs in root

3. **Dataset Docs**:
   - Option A: Merge into single file
   - Option B: Keep separate files
   - Option C: Move to README.md appendix

---

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Broken links in docs | Low | Search for internal links and update |
| Missing information | Medium | Review code before doc updates |
| Git history loss | Low | Archive instead of delete |

---

*Plan created by Roo - Architect Mode*
