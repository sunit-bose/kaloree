# Health Alerts Feature - Architecture Plan

## Overview
Add intelligent health alerts that warn users when scanned food items may pose risks based on their personal health profile. Alerts are shown before saving, can be dismissed, and are stored with the meal entry for tracking.

---

## Health Alert Types

### Core Alerts (Initially Requested)
| Alert Type | Risk Level | Trigger Condition | Target Users |
|------------|------------|-------------------|--------------|
| **High Purines** | ⚠️ Medium | Foods like organ meats, shellfish, red meat, beer | Gout patients |
| **High Glycemic Index** | 🔴 High | Refined carbs, sugary foods, white bread | Diabetics, pre-diabetics |
| **High Sodium** | ⚠️ Medium | Processed foods, cured meats, salty snacks >500mg | Hypertension patients |
| **High Cholesterol** | ⚠️ Medium | Egg yolks, organ meats, full-fat dairy | Heart disease risk |
| **High Saturated Fat** | ⚠️ Medium | Fried foods, fatty meats, butter >5g | Cardiovascular risk |
| **Contains Allergen** | 🔴 Critical | Nuts, dairy, gluten, shellfish, eggs, soy | Allergy sufferers |

### Additional Critical Alerts (Recommended)

#### Kidney Health
| Alert Type | Risk Level | Trigger Condition | Target Users |
|------------|------------|-------------------|--------------|
| **High Potassium** | 🔴 Critical | Bananas, oranges, potatoes, spinach >400mg | Kidney disease patients |
| **High Phosphorus** | ⚠️ High | Dairy, nuts, beans, cola drinks | Kidney disease patients |
| **High Oxalate** | ⚠️ Medium | Spinach, rhubarb, chocolate, nuts | Kidney stone formers |

#### Digestive Health
| Alert Type | Risk Level | Trigger Condition | Target Users |
|------------|------------|-------------------|--------------|
| **High FODMAP** | ⚠️ Medium | Garlic, onions, wheat, lactose, beans | IBS/IBD patients |
| **High Histamine** | ⚠️ Medium | Aged cheese, fermented foods, alcohol | Histamine intolerance |
| **Nightshade** | ⚠️ Low | Tomatoes, potatoes, peppers, eggplant | Autoimmune conditions |

#### Cardiovascular
| Alert Type | Risk Level | Trigger Condition | Target Users |
|------------|------------|-------------------|--------------|
| **High Trans Fat** | 🔴 Critical | Margarine, fried foods, packaged snacks | Everyone (banned in many countries) |
| **Very High Calories** | ⚠️ Medium | Single item >800 kcal | Weight management |

#### Pregnancy & Children
| Alert Type | Risk Level | Trigger Condition | Target Users |
|------------|------------|-------------------|--------------|
| **High Mercury** | 🔴 Critical | Swordfish, king mackerel, tilefish | Pregnant women |
| **Raw/Undercooked** | 🔴 Critical | Sushi, rare meat, raw eggs | Pregnant women, elderly |
| **High Caffeine** | ⚠️ Medium | Coffee, energy drinks >200mg | Pregnant women |
| **Alcohol Content** | 🔴 Critical | Wine, beer, spirits | Pregnant women, recovering |

#### Medication Interactions
| Alert Type | Risk Level | Trigger Condition | Target Users |
|------------|------------|-------------------|--------------|
| **High Vitamin K** | ⚠️ High | Leafy greens, broccoli | Warfarin/blood thinner users |
| **Grapefruit** | 🔴 Critical | Grapefruit, pomelo | Many medication users |
| **Tyramine** | 🔴 Critical | Aged cheese, cured meats, fermented | MAO inhibitor users |

#### Thyroid Health
| Alert Type | Risk Level | Trigger Condition | Target Users |
|------------|------------|-------------------|--------------|
| **Goitrogen** | ⚠️ Low | Raw cruciferous vegetables, soy | Thyroid condition patients |

#### Metabolic Conditions
| Alert Type | Risk Level | Trigger Condition | Target Users |
|------------|------------|-------------------|--------------|
| **High Phenylalanine** | 🔴 Critical | Aspartame, high-protein foods | PKU patients |
| **High Copper** | ⚠️ Medium | Shellfish, organ meats, chocolate | Wilson's disease patients |

---

## Data Models

### HealthAlertType Enum
```dart
enum HealthAlertType {
  // === METABOLIC ===
  highPurines,        // Gout risk
  highGlycemicIndex,  // Blood sugar spike
  highSodium,         // Hypertension risk
  highCholesterol,    // Heart disease risk
  highSaturatedFat,   // Cardiovascular risk
  highTransFat,       // Banned in many countries
  veryHighCalories,   // Weight management
  
  // === ALLERGENS ===
  containsNuts,       // Tree nuts, peanuts
  containsDairy,      // Milk, cheese, lactose
  containsGluten,     // Wheat, barley, rye
  containsShellfish,  // Shrimp, crab, lobster
  containsEggs,       // Egg products
  containsSoy,        // Soy products
  
  // === KIDNEY HEALTH ===
  highPotassium,      // Kidney disease risk
  highPhosphorus,     // Kidney disease risk
  highOxalate,        // Kidney stone risk
  
  // === DIGESTIVE ===
  highFodmap,         // IBS/IBD trigger
  highHistamine,      // Histamine intolerance
  containsNightshade, // Autoimmune trigger
  
  // === PREGNANCY & SAFETY ===
  highMercury,        // Pregnant women
  rawUndercooked,     // Food safety
  highCaffeine,       // Pregnancy, anxiety
  containsAlcohol,    // Pregnancy, recovery
  
  // === MEDICATION INTERACTIONS ===
  highVitaminK,       // Warfarin interaction
  containsGrapefruit, // Many medication interactions
  highTyramine,       // MAO inhibitor interaction
  
  // === OTHER CONDITIONS ===
  containsGoitrogen,  // Thyroid conditions
  highPhenylalanine,  // PKU
  highCopper,         // Wilson's disease
}
```

### HealthAlert Model
```dart
class HealthAlert {
  final HealthAlertType type;
  final String severity;        // critical, high, medium, low
  final String message;         // Human-readable alert text
  final String? details;        // Additional context
  final double? value;          // Numeric value if applicable
  final String? unit;           // mg, g, index, etc.
  
  // Dismissal tracking
  bool isDismissed;
  DateTime? dismissedAt;
  String? dismissalReason;     // Optional: "occasional treat", "doctor approved"
}
```

### HealthAlertPreferences Model - User Settings
```dart
class HealthAlertPreferences {
  // === METABOLIC CONDITIONS ===
  bool hasGout;              // → highPurines alerts
  bool hasDiabetes;          // → highGlycemicIndex alerts
  bool hasHypertension;      // → highSodium alerts
  bool hasHeartDisease;      // → highCholesterol, highSaturatedFat alerts
  
  // === KIDNEY CONDITIONS ===
  bool hasKidneyDisease;     // → highPotassium, highPhosphorus alerts
  bool hasKidneyStones;      // → highOxalate alerts
  
  // === DIGESTIVE CONDITIONS ===
  bool hasIBS;               // → highFodmap alerts
  bool hasHistamineIntolerance; // → highHistamine alerts
  bool hasAutoimmune;        // → containsNightshade alerts
  
  // === THYROID ===
  bool hasThyroidCondition;  // → containsGoitrogen alerts
  
  // === RARE CONDITIONS ===
  bool hasPKU;               // → highPhenylalanine alerts
  bool hasWilsonDisease;     // → highCopper alerts
  
  // === ALLERGENS ===
  bool allergyNuts;
  bool allergyDairy;
  bool allergyGluten;
  bool allergyShellfish;
  bool allergyEggs;
  bool allergySoy;
  
  // === LIFE STAGES ===
  bool isPregnant;           // → highMercury, rawUndercooked, highCaffeine, containsAlcohol
  bool isBreastfeeding;      // → highCaffeine, containsAlcohol
  bool inRecovery;           // → containsAlcohol alerts
  
  // === MEDICATIONS ===
  bool takesWarfarin;        // → highVitaminK alerts
  bool takesMAOInhibitors;   // → highTyramine alerts
  bool hasGrapefruitInteraction; // → containsGrapefruit alerts
  
  // === GENERAL WELLNESS ===
  bool warnHighSaturatedFat;
  bool warnHighCholesterol;
  bool warnHighTransFat;     // Always recommend ON
  bool warnVeryHighCalories;
  bool warnRawUndercooked;   // Food safety for everyone
}
```

### Updated FoodItem Model
```dart
class FoodItem {
  // Existing fields...
  String name;
  int calories;
  double protein, carbs, fat, fiber;
  
  // NEW: Comprehensive health risk indicators from AI
  HealthIndicators? healthIndicators;
  
  // NEW: Triggered alerts for this item
  List<HealthAlert> healthAlerts;
}

class HealthIndicators {
  // Metabolic
  double? glycemicIndex;
  String? purineLevel;        // high, medium, low
  double? sodiumMg;
  double? cholesterolMg;
  double? saturatedFatG;
  double? transFatG;
  
  // Kidney
  double? potassiumMg;
  double? phosphorusMg;
  String? oxalateLevel;       // high, medium, low
  
  // Digestive
  String? fodmapLevel;        // high, medium, low
  String? histamineLevel;     // high, medium, low
  bool isNightshade;
  
  // Pregnancy/Safety
  String? mercuryLevel;       // high, medium, low, none
  bool isRawUndercooked;
  double? caffeineMg;
  bool containsAlcohol;
  
  // Medication interactions
  double? vitaminKMcg;
  bool isGrapefruit;
  String? tyramineLevel;      // high, medium, low
  
  // Other conditions
  bool isGoitrogen;
  double? phenylalanineMg;
  double? copperMg;
  
  // Allergens
  List<String> allergens;     // nuts, dairy, gluten, shellfish, eggs, soy, sesame, fish
}
```

---

## User Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        SCAN FOOD                                │
│                     [Camera Screen]                             │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                    AI ANALYSIS                                  │
│   - Identify food items                                         │
│   - Calculate nutrition                                         │
│   - NEW: Estimate health risk values                            │
│   - glycemicIndex, purineLevel, sodium, allergens, etc.         │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                CHECK HEALTH ALERTS                              │
│   Compare AI values against user preferences:                   │
│   - If user hasGout AND food purineLevel > threshold → ALERT    │
│   - If user hasDiabetes AND glycemicIndex > 70 → ALERT          │
│   - If user allergyNuts AND nuts in allergens → ALERT           │
└─────────────────────────┬───────────────────────────────────────┘
                          │
              ┌───────────┴───────────┐
              │                       │
              ▼                       ▼
┌─────────────────────┐   ┌─────────────────────────────────────┐
│   NO ALERTS         │   │   ALERTS TRIGGERED                  │
│                     │   │                                     │
│   Show normal       │   │   Show Alert Dialog:                │
│   meal info screen  │   │   ┌─────────────────────────────┐   │
│                     │   │   │ ⚠️ Health Alert              │   │
│                     │   │   │                              │   │
│                     │   │   │ HIGH PURINES                 │   │
│                     │   │   │ Shellfish may trigger gout   │   │
│                     │   │   │                              │   │
│                     │   │   │ HIGH GLYCEMIC INDEX          │   │
│                     │   │   │ May cause blood sugar spike  │   │
│                     │   │   │                              │   │
│                     │   │   │ [Dismiss] [Add Anyway]       │   │
│                     │   │   └─────────────────────────────┘   │
│                     │   │                                     │
└─────────────────────┘   └─────────────────┬───────────────────┘
                                            │
                                            ▼
                          ┌─────────────────────────────────────┐
                          │        SAVE MEAL ENTRY              │
                          │   - Food items with nutrition       │
                          │   - Health alerts that triggered    │
                          │   - Dismissal status + reason       │
                          │   - Timestamp                       │
                          └─────────────────────────────────────┘
```

---

## AI Prompt Update

Update the LLM prompt to request comprehensive health risk indicators:

```
Analyze this image and determine if it contains food items.

Return your response in this exact JSON format:
{
  "isFood": true,
  "items": [
    {
      "name": "Food Item Name",
      "portion": "1 serving",
      "portionGrams": 100,
      "calories": 250,
      "protein": 15.5,
      "carbs": 20.0,
      "fat": 12.0,
      "fiber": 3.2,
      
      // Health risk indicators
      "healthIndicators": {
        // Metabolic
        "glycemicIndex": 65,
        "purineLevel": "high|medium|low",
        "sodiumMg": 450,
        "cholesterolMg": 85,
        "saturatedFatG": 4.2,
        "transFatG": 0,
        
        // Kidney
        "potassiumMg": 300,
        "phosphorusMg": 150,
        "oxalateLevel": "high|medium|low",
        
        // Digestive
        "fodmapLevel": "high|medium|low",
        "histamineLevel": "high|medium|low",
        "isNightshade": false,
        
        // Pregnancy/Safety
        "mercuryLevel": "high|medium|low|none",
        "isRawUndercooked": false,
        "caffeineMg": 0,
        "containsAlcohol": false,
        
        // Medication interactions
        "vitaminKMcg": 50,
        "isGrapefruit": false,
        "tyramineLevel": "high|medium|low",
        
        // Other conditions
        "isGoitrogen": false,
        "phenylalanineMg": 100,
        "copperMg": 0.2,
        
        // Allergens
        "allergens": ["shellfish", "soy"]
      }
    }
  ],
  "confidence": "high|medium|low"
}

Guidelines for health indicators:
- glycemicIndex: 0-100 scale. >70=high, 55-70=medium, <55=low
- purineLevel: "high" for organ meats/shellfish/beer, "medium" for red meat/legumes, "low" for most foods
- fodmapLevel: "high" for garlic/onion/wheat/beans, "medium" for moderate amounts, "low" for safe foods
- histamineLevel: "high" for aged cheese/fermented/cured meats/alcohol, "medium" for citrus, "low" for fresh foods
- mercuryLevel: "high" for swordfish/shark/king mackerel, "medium" for tuna, "low" for salmon/shrimp, "none" for non-seafood
- tyramineLevel: "high" for aged cheese/cured meats/fermented, "medium" for fresh cheese, "low" for most foods
- allergens: List any of: nuts, dairy, gluten, shellfish, eggs, soy, sesame, fish
- isNightshade: true for tomatoes, potatoes, peppers, eggplant
- isGoitrogen: true for raw cruciferous vegetables like broccoli, cabbage, kale
```

---

## Database Schema Update

### New Table: health_alert_preferences
```sql
CREATE TABLE health_alert_preferences (
  id INTEGER PRIMARY KEY,
  
  -- Enable/Disable all alerts
  alerts_enabled INTEGER DEFAULT 1,
  
  -- Metabolic & Cardiovascular
  has_gout INTEGER DEFAULT 0,
  has_diabetes INTEGER DEFAULT 0,
  has_hypertension INTEGER DEFAULT 0,
  has_heart_disease INTEGER DEFAULT 0,
  
  -- Kidney Health
  has_kidney_disease INTEGER DEFAULT 0,
  has_kidney_stones INTEGER DEFAULT 0,
  
  -- Digestive Health
  has_ibs INTEGER DEFAULT 0,
  has_histamine_intolerance INTEGER DEFAULT 0,
  has_autoimmune INTEGER DEFAULT 0,
  
  -- Thyroid & Rare
  has_thyroid_condition INTEGER DEFAULT 0,
  has_pku INTEGER DEFAULT 0,
  has_wilson_disease INTEGER DEFAULT 0,
  
  -- Allergens
  allergy_nuts INTEGER DEFAULT 0,
  allergy_dairy INTEGER DEFAULT 0,
  allergy_gluten INTEGER DEFAULT 0,
  allergy_shellfish INTEGER DEFAULT 0,
  allergy_eggs INTEGER DEFAULT 0,
  allergy_soy INTEGER DEFAULT 0,
  
  -- Life Stage
  is_pregnant INTEGER DEFAULT 0,
  is_breastfeeding INTEGER DEFAULT 0,
  in_recovery INTEGER DEFAULT 0,
  
  -- Medications
  takes_warfarin INTEGER DEFAULT 0,
  takes_mao_inhibitors INTEGER DEFAULT 0,
  has_grapefruit_interaction INTEGER DEFAULT 0,
  
  -- General Wellness
  warn_saturated_fat INTEGER DEFAULT 1,
  warn_trans_fat INTEGER DEFAULT 1,
  warn_cholesterol INTEGER DEFAULT 0,
  warn_high_calories INTEGER DEFAULT 0,
  warn_raw_undercooked INTEGER DEFAULT 1,
  
  updated_at TEXT
);
```

### Updated meals table - add health indicators
```sql
ALTER TABLE meal_items ADD COLUMN glycemic_index REAL;
ALTER TABLE meal_items ADD COLUMN purine_level TEXT;
ALTER TABLE meal_items ADD COLUMN sodium_mg REAL;
ALTER TABLE meal_items ADD COLUMN cholesterol_mg REAL;
ALTER TABLE meal_items ADD COLUMN saturated_fat_g REAL;
ALTER TABLE meal_items ADD COLUMN allergens TEXT; -- JSON array
```

### New Table: meal_health_alerts
```sql
CREATE TABLE meal_health_alerts (
  id INTEGER PRIMARY KEY,
  meal_item_id INTEGER REFERENCES meal_items(id),
  alert_type TEXT NOT NULL,
  severity TEXT NOT NULL,
  message TEXT NOT NULL,
  value REAL,
  unit TEXT,
  is_dismissed INTEGER DEFAULT 0,
  dismissed_at TEXT,
  dismissal_reason TEXT,
  created_at TEXT NOT NULL
);
```

---

## UI Components

### 1. Settings Screen - Health Alerts Section
New card in Settings with toggles for:
- Health Conditions checkboxes
- Allergen selection
- General warnings toggles

### 2. HealthAlertCard Widget
Displays a single alert with:
- Icon based on severity
- Alert type name
- Description
- Value if applicable
- Dismiss button

### 3. HealthAlertsDialog
Modal shown when alerts are triggered:
- List of all alerts
- Option to dismiss individually or all
- Optional reason dropdown
- Continue button to save

### 4. Insights Integration
Show health alert summary:
- "This week: 3 high-purine meals dismissed"
- "Blood sugar spike warnings: 5"

---

## Settings UI Structure

```
Health Alerts Section
├── [Toggle] Enable Health Alerts
│
├── 🫀 Metabolic & Cardiovascular
│   ├── [Toggle] Gout / High Uric Acid → purines
│   ├── [Toggle] Diabetes / Pre-diabetic → glycemic index
│   ├── [Toggle] Hypertension → sodium
│   └── [Toggle] Heart Disease → cholesterol, saturated fat
│
├── 🫘 Kidney Health
│   ├── [Toggle] Kidney Disease (CKD) → potassium, phosphorus
│   └── [Toggle] Kidney Stone History → oxalate
│
├── 🍽️ Digestive Health
│   ├── [Toggle] IBS / IBD → FODMAPs
│   ├── [Toggle] Histamine Intolerance → aged/fermented foods
│   └── [Toggle] Autoimmune Conditions → nightshades
│
├── 🦋 Thyroid & Rare Conditions
│   ├── [Toggle] Thyroid Condition → goitrogens
│   ├── [Toggle] PKU - Phenylketonuria → phenylalanine
│   └── [Toggle] Wilson's Disease → copper
│
├── ⚠️ Allergens
│   ├── [Toggle] Tree Nuts & Peanuts
│   ├── [Toggle] Dairy / Lactose
│   ├── [Toggle] Gluten / Wheat
│   ├── [Toggle] Shellfish
│   ├── [Toggle] Eggs
│   └── [Toggle] Soy
│
├── 🤰 Life Stage
│   ├── [Toggle] Pregnant → mercury, raw foods, caffeine, alcohol
│   ├── [Toggle] Breastfeeding → caffeine, alcohol
│   └── [Toggle] In Recovery → alcohol
│
├── 💊 Medication Interactions
│   ├── [Toggle] Taking Warfarin → vitamin K
│   ├── [Toggle] Taking MAO Inhibitors → tyramine
│   └── [Toggle] Grapefruit Interaction → check med label
│
└── ✅ General Wellness (Always recommended)
    ├── [Toggle] Warn high saturated fat
    ├── [Toggle] Warn high trans fat
    ├── [Toggle] Warn high cholesterol
    ├── [Toggle] Warn very high calorie items
    └── [Toggle] Warn raw/undercooked foods
```

---

## Implementation Order

1. **Data Models** - Create HealthAlert, HealthAlertType, HealthAlertPreferences
2. **Database** - Add new tables and columns with migration
3. **AI Prompt** - Update to request health indicators
4. **Settings UI** - Add Health Alerts preferences section
5. **Alert Detection** - Create service to check food against preferences
6. **Alert UI** - Create HealthAlertCard and HealthAlertsDialog
7. **Meal Info Screen** - Integrate alert display before save
8. **Insights** - Add health alerts summary widget

---

## Risk Thresholds

### Metabolic & Cardiovascular
| Metric | Low | Medium | High | Critical |
|--------|-----|--------|------|----------|
| Glycemic Index | <55 | 55-70 | 70-85 | >85 |
| Purine Level | <50mg | 50-150mg | 150-400mg | >400mg |
| Sodium | <200mg | 200-500mg | 500-1000mg | >1000mg |
| Cholesterol | <50mg | 50-100mg | 100-200mg | >200mg |
| Saturated Fat | <3g | 3-5g | 5-10g | >10g |
| Trans Fat | 0g | >0g | >0.5g | >1g |
| Calories per item | <300 | 300-500 | 500-800 | >800 |

### Kidney Health
| Metric | Low | Medium | High | Critical |
|--------|-----|--------|------|----------|
| Potassium | <200mg | 200-400mg | 400-600mg | >600mg |
| Phosphorus | <100mg | 100-250mg | 250-400mg | >400mg |
| Oxalate | low | medium | high | - |

### Pregnancy & Safety
| Metric | Low | Medium | High | Critical |
|--------|-----|--------|------|----------|
| Mercury | none/low | medium | high | - |
| Caffeine | <50mg | 50-100mg | 100-200mg | >200mg |
| Alcohol | false | - | - | true |
| Raw/Undercooked | false | - | - | true |

### Medication Interactions
| Metric | Low | Medium | High | Critical |
|--------|-----|--------|------|----------|
| Vitamin K | <50mcg | 50-100mcg | 100-200mcg | >200mcg |
| Tyramine | low | medium | high | - |
| Grapefruit | false | - | - | true |

### Rare Conditions
| Metric | Low | Medium | High | Critical |
|--------|-----|--------|------|----------|
| Phenylalanine | <100mg | 100-300mg | 300-500mg | >500mg |
| Copper | <0.2mg | 0.2-0.5mg | 0.5-1mg | >1mg |

### Qualitative Levels (AI-determined)
| Type | Triggers Alert When |
|------|---------------------|
| Purine Level | "high" |
| FODMAP Level | "high" for IBS users |
| Histamine Level | "high" for intolerant users |
| Oxalate Level | "high" for kidney stone users |
| Mercury Level | "high" or "medium" for pregnant users |
| Tyramine Level | "high" for MAO inhibitor users |
| Is Nightshade | true for autoimmune users |
| Is Goitrogen | true for thyroid users |
| Is Grapefruit | true for medication interaction users |
| Contains Alcohol | true for pregnant/recovery users |
| Is Raw/Undercooked | true for pregnant/safety-conscious users |

---

## Privacy Considerations

- Health preferences stored locally only
- Not synced to cloud
- User can export/delete all health data
- Clear disclaimer: "Not medical advice"

---

## Required Disclaimers (High Priority)

### 1. Medical Liability Disclaimer
**Location:** Settings screen header, First-time setup, Alert dialogs

```
⚠️ IMPORTANT HEALTH DISCLAIMER

The health alerts in Kaloree are for EDUCATIONAL PURPOSES ONLY and should NOT
be used as a substitute for professional medical advice, diagnosis, or treatment.

• These alerts are AI-generated estimates and may not be accurate
• Nutritional values and health indicators are approximations
• Individual health needs vary significantly
• Always consult your doctor or registered dietitian before making dietary changes
• In case of medical emergency, contact your healthcare provider immediately

By enabling health alerts, you acknowledge that:
1. You will not rely solely on this app for medical decisions
2. You understand AI analysis has limitations and may contain errors
3. You will verify critical health information with qualified professionals

This app does not establish a doctor-patient relationship.
```

### 2. Alert Fatigue Prevention
**Location:** Settings screen, after enabling 5+ conditions

```
💡 TIP: Less is More

You've enabled many health conditions. To avoid alert fatigue:
• Start with your most critical conditions (e.g., severe allergies)
• Use "Critical Only" mode to see only high-severity alerts
• You can always enable more conditions later

Too many alerts may cause you to ignore important warnings.
```

### 3. Onboarding Guidance
**Location:** First-time Health Alerts setup

```
🏥 Setting Up Your Health Profile

We recommend starting simple:

STEP 1: Do you have any food allergies?
        [Select from common allergens]

STEP 2: Do you have any of these common conditions?
        □ Diabetes or pre-diabetes
        □ High blood pressure
        □ Heart disease
        □ Gout
        
STEP 3: Are you currently:
        □ Pregnant or breastfeeding
        □ Taking blood thinners (Warfarin)
        
You can add more conditions anytime in Settings.
Start with what matters most to you.
```

---

## Data Model Flexibility (Architecture Deep Dive)

### The Rigidity Problem

The current enum-based approach:
```dart
enum HealthAlertType {
  highPurines,
  highGlycemicIndex,
  // ... 25+ types hardcoded
}
```

**Limitations:**
1. Adding a new alert type requires a code update + app store release
2. Database migration needed for new preference columns
3. Users must update the app to get new alert types
4. Cannot A/B test new alert types without code changes

### Flexible Alternative (Recommended for v2)

```dart
// Use string-based types stored in JSON
class HealthAlertType {
  final String id;          // "high_purines", "high_glycemic_index"
  final String category;    // "metabolic", "allergen", "pregnancy"
  final String displayName; // "High Purines"
  final String description; // "May trigger gout..."
  final AlertSeverity defaultSeverity;
  
  // Can be loaded from:
  // 1. Hardcoded defaults (shipped with app)
  // 2. Remote config (Firebase/custom backend)
  // 3. User-defined custom alerts
}

// Preferences stored as JSON blob
class HealthAlertPreferences {
  Map<String, bool> enabledConditions;  // {"gout": true, "diabetes": false}
  Map<String, bool> enabledAllergens;   // {"nuts": true, "dairy": false}
  
  // Easy to add new keys without migration
}
```

**Benefits:**
- New alert types via remote config (no app update)
- User-defined custom alerts (e.g., "I'm sensitive to caffeine after 2pm")
- Regional health alerts (e.g., specific to Indian diet patterns)
- A/B testing new alert categories

**Why we're using enums for v1:**
- Faster to implement
- Type-safe at compile time
- No remote config infrastructure needed yet
- Sufficient for MVP with 25-30 alert types

### Migration Path

When moving to flexible model later:
1. Keep enums as "known types" for type-safety
2. Add `customAlerts: List<String>` field
3. Store preferences as JSON blob in single column
4. Enum values become string IDs for backwards compatibility

---

## Product Backlog & Tech Debt

### 🚀 Product Enhancements (Future)

| Priority | Feature | Description | Effort |
|----------|---------|-------------|--------|
| P1 | Health Profile Wizard | Guided first-time setup with progressive disclosure | Medium |
| P1 | Severity Filter | "Critical Only" / "All Warnings" toggle | Low |
| P2 | Snooze Feature | "Ignore sodium alerts for 24 hours" | Medium |
| P2 | Learn More Links | Each alert links to educational content | Low |
| P2 | Alert Statistics | "This week: 5 high-sodium meals" in Insights | Medium |
| P3 | Custom Alerts | User-defined triggers (e.g., "avoid after 6pm") | High |
| P3 | Family Profiles | Different health settings per family member | High |
| P3 | Doctor Export | PDF report of dismissed alerts for doctor visits | Medium |

### 🔧 Tech Debt (To Address Later)

| Priority | Item | Current State | Target State | Risk if Ignored |
|----------|------|---------------|--------------|-----------------|
| P1 | Enum-based types | Hardcoded 30 types | JSON/remote config types | Hard to add new alerts without app update |
| P1 | Single preferences table | Wide table with 30+ columns | JSON blob in single column | Migration headaches as we add conditions |
| P2 | AI prompt size | 500+ token prompt | Structured request format | Higher API costs as indicators grow |
| P2 | No alert caching | Re-check on every view | Cache alerts per meal item | Unnecessary compute on repeated views |
| P3 | No unit tests | Alert service untested | 90%+ coverage on health logic | Regression bugs in health-critical code |
| P3 | Hardcoded thresholds | Thresholds in code | User-configurable sensitivity | Users can't tune for their needs |

### ⚖️ Legal & Compliance Considerations

| Item | Status | Action Required |
|------|--------|-----------------|
| Medical disclaimer | 🟡 Planned | Add to Settings, First-run, Alert dialogs |
| Terms of Service update | ❌ Not started | Add health feature limitations section |
| Privacy Policy update | ❌ Not started | Document health data handling (local-only) |
| HIPAA compliance | ✅ N/A | Not applicable - no cloud storage of health data |
| GDPR compliance | 🟡 Partial | Health data is local, but export/delete needed |

### 📊 Success Metrics (To Track Post-Launch)

| Metric | Target | Measurement |
|--------|--------|-------------|
| Alert enable rate | >30% users enable at least one condition | Settings analytics |
| Alert dismiss rate | <50% of alerts dismissed (indicates relevance) | Database queries |
| Feature retention | <10% users disable all alerts after trying | Settings analytics |
| Support tickets | <5% increase in health-related support | Support desk |
