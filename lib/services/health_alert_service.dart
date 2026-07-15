import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_alert.dart';
import '../models/meal_analysis.dart';

/// Service to check food items against user health preferences and generate alerts
class HealthAlertService {
  static const String _preferencesKey = 'health_alert_preferences';

  final SharedPreferences _prefs;

  HealthAlertService(this._prefs);

  /// Load user's health alert preferences
  HealthAlertPreferences loadPreferences() {
    final jsonString = _prefs.getString(_preferencesKey);
    if (jsonString == null) {
      return HealthAlertPreferences.defaults();
    }
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return HealthAlertPreferences.fromJson(json);
    } catch (e) {
      return HealthAlertPreferences.defaults();
    }
  }

  /// Save user's health alert preferences
  Future<void> savePreferences(HealthAlertPreferences preferences) async {
    final jsonString = jsonEncode(preferences.toJson());
    await _prefs.setString(_preferencesKey, jsonString);
  }

  /// Check a food item against user preferences and return triggered alerts
  List<HealthAlert> checkFoodItem(FoodItem item, HealthAlertPreferences prefs) {
    if (!prefs.alertsEnabled) return [];

    final alerts = <HealthAlert>[];
    final indicators = item.healthIndicators;

    if (indicators == null) return alerts;

    // === METABOLIC CHECKS ===
    
    // Gout - High Purines
    if (prefs.hasGout && indicators.purineLevel == QualitativeLevel.high) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.highPurines,
        foodItemName: item.name,
        customMessage: '${item.name} is high in purines which may trigger gout flare-ups',
      ));
    }

    // Diabetes - High Glycemic Index
    if (prefs.hasDiabetes && indicators.glycemicIndex != null && indicators.glycemicIndex! > 70) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.highGlycemicIndex,
        foodItemName: item.name,
        value: indicators.glycemicIndex,
        unit: 'GI',
        customMessage: '${item.name} has a high glycemic index (${indicators.glycemicIndex!.toInt()}) which may cause blood sugar spikes',
      ));
    }

    // Hypertension - High Sodium
    if (prefs.hasHypertension && indicators.sodiumMg != null && indicators.sodiumMg! > 500) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.highSodium,
        foodItemName: item.name,
        value: indicators.sodiumMg,
        unit: 'mg',
        customMessage: '${item.name} contains ${indicators.sodiumMg!.toInt()}mg sodium which may affect blood pressure',
        overrideSeverity: indicators.sodiumMg! > 1000 ? AlertSeverity.high : AlertSeverity.medium,
      ));
    }

    // Heart Disease - High Cholesterol
    if ((prefs.hasHeartDisease || prefs.warnHighCholesterol) && 
        indicators.cholesterolMg != null && indicators.cholesterolMg! > 100) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.highCholesterol,
        foodItemName: item.name,
        value: indicators.cholesterolMg,
        unit: 'mg',
        customMessage: '${item.name} contains ${indicators.cholesterolMg!.toInt()}mg cholesterol',
        overrideSeverity: indicators.cholesterolMg! > 200 ? AlertSeverity.high : AlertSeverity.medium,
      ));
    }

    // Heart Disease / Wellness - High Saturated Fat
    if ((prefs.hasHeartDisease || prefs.warnHighSaturatedFat) && 
        indicators.saturatedFatG != null && indicators.saturatedFatG! > 5) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.highSaturatedFat,
        foodItemName: item.name,
        value: indicators.saturatedFatG,
        unit: 'g',
        customMessage: '${item.name} contains ${indicators.saturatedFatG!.toStringAsFixed(1)}g saturated fat',
        overrideSeverity: indicators.saturatedFatG! > 10 ? AlertSeverity.high : AlertSeverity.medium,
      ));
    }

    // Trans Fat - Always critical when present
    if (prefs.warnHighTransFat && indicators.transFatG != null && indicators.transFatG! > 0) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.highTransFat,
        foodItemName: item.name,
        value: indicators.transFatG,
        unit: 'g',
        customMessage: '${item.name} contains trans fat which is harmful to heart health',
      ));
    }

    // Very High Calories
    if (prefs.warnVeryHighCalories && item.calories > 800) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.veryHighCalories,
        foodItemName: item.name,
        value: item.calories.toDouble(),
        unit: 'kcal',
        customMessage: '${item.name} contains ${item.calories} calories in a single item',
      ));
    }

    // === ALLERGEN CHECKS ===
    
    if (prefs.allergyNuts && indicators.hasAllergen('nuts')) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.containsNuts,
        foodItemName: item.name,
        customMessage: '${item.name} contains nuts - allergen alert!',
      ));
    }

    if (prefs.allergyDairy && indicators.hasAllergen('dairy')) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.containsDairy,
        foodItemName: item.name,
        customMessage: '${item.name} contains dairy - allergen alert!',
      ));
    }

    if (prefs.allergyGluten && indicators.hasAllergen('gluten')) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.containsGluten,
        foodItemName: item.name,
        customMessage: '${item.name} contains gluten - allergen alert!',
      ));
    }

    if (prefs.allergyShellfish && indicators.hasAllergen('shellfish')) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.containsShellfish,
        foodItemName: item.name,
        customMessage: '${item.name} contains shellfish - allergen alert!',
      ));
    }

    if (prefs.allergyEggs && indicators.hasAllergen('eggs')) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.containsEggs,
        foodItemName: item.name,
        customMessage: '${item.name} contains eggs - allergen alert!',
      ));
    }

    if (prefs.allergySoy && indicators.hasAllergen('soy')) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.containsSoy,
        foodItemName: item.name,
        customMessage: '${item.name} contains soy - allergen alert!',
      ));
    }

    // === KIDNEY HEALTH CHECKS ===

    if (prefs.hasKidneyDisease) {
      // High Potassium
      if (indicators.potassiumMg != null && indicators.potassiumMg! > 400) {
        alerts.add(HealthAlert.create(
          type: HealthAlertType.highPotassium,
          foodItemName: item.name,
          value: indicators.potassiumMg,
          unit: 'mg',
          customMessage: '${item.name} contains ${indicators.potassiumMg!.toInt()}mg potassium',
          overrideSeverity: indicators.potassiumMg! > 600 ? AlertSeverity.critical : AlertSeverity.high,
        ));
      }

      // High Phosphorus
      if (indicators.phosphorusMg != null && indicators.phosphorusMg! > 250) {
        alerts.add(HealthAlert.create(
          type: HealthAlertType.highPhosphorus,
          foodItemName: item.name,
          value: indicators.phosphorusMg,
          unit: 'mg',
          customMessage: '${item.name} contains ${indicators.phosphorusMg!.toInt()}mg phosphorus',
        ));
      }
    }

    // Kidney Stones - High Oxalate
    if (prefs.hasKidneyStones && indicators.oxalateLevel == QualitativeLevel.high) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.highOxalate,
        foodItemName: item.name,
        customMessage: '${item.name} is high in oxalates which may contribute to kidney stones',
      ));
    }

    // === DIGESTIVE HEALTH CHECKS ===

    // IBS - High FODMAP
    if (prefs.hasIBS && indicators.fodmapLevel == QualitativeLevel.high) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.highFodmap,
        foodItemName: item.name,
        customMessage: '${item.name} is high in FODMAPs which may trigger IBS symptoms',
      ));
    }

    // Histamine Intolerance
    if (prefs.hasHistamineIntolerance && indicators.histamineLevel == QualitativeLevel.high) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.highHistamine,
        foodItemName: item.name,
        customMessage: '${item.name} is high in histamine',
      ));
    }

    // Autoimmune - Nightshades
    if (prefs.hasAutoimmune && indicators.isNightshade) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.containsNightshade,
        foodItemName: item.name,
        customMessage: '${item.name} is a nightshade vegetable',
      ));
    }

    // === PREGNANCY & SAFETY CHECKS ===

    if (prefs.isPregnant || prefs.isBreastfeeding) {
      // High Mercury
      if (indicators.mercuryLevel == QualitativeLevel.high ||
          (prefs.isPregnant && indicators.mercuryLevel == QualitativeLevel.medium)) {
        alerts.add(HealthAlert.create(
          type: HealthAlertType.highMercury,
          foodItemName: item.name,
          customMessage: '${item.name} may contain mercury - not recommended during pregnancy',
        ));
      }

      // Caffeine
      if (indicators.caffeineMg != null && indicators.caffeineMg! > 100) {
        alerts.add(HealthAlert.create(
          type: HealthAlertType.highCaffeine,
          foodItemName: item.name,
          value: indicators.caffeineMg,
          unit: 'mg',
          customMessage: '${item.name} contains ${indicators.caffeineMg!.toInt()}mg caffeine',
          overrideSeverity: indicators.caffeineMg! > 200 ? AlertSeverity.high : AlertSeverity.medium,
        ));
      }

      // Alcohol
      if (indicators.containsAlcohol) {
        alerts.add(HealthAlert.create(
          type: HealthAlertType.containsAlcohol,
          foodItemName: item.name,
          customMessage: '${item.name} contains alcohol - not recommended during pregnancy',
        ));
      }
    }

    // Raw/Undercooked - for pregnancy or general safety
    if ((prefs.isPregnant || prefs.warnRawUndercooked) && indicators.isRawUndercooked) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.rawUndercooked,
        foodItemName: item.name,
        customMessage: '${item.name} may be raw or undercooked - food safety concern',
      ));
    }

    // Recovery - Alcohol only
    if (prefs.inRecovery && indicators.containsAlcohol) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.containsAlcohol,
        foodItemName: item.name,
        customMessage: '${item.name} contains alcohol',
      ));
    }

    // === MEDICATION INTERACTION CHECKS ===

    // Warfarin - High Vitamin K
    if (prefs.takesWarfarin && indicators.vitaminKMcg != null && indicators.vitaminKMcg! > 100) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.highVitaminK,
        foodItemName: item.name,
        value: indicators.vitaminKMcg,
        unit: 'mcg',
        customMessage: '${item.name} is high in Vitamin K which may interact with blood thinners',
        overrideSeverity: indicators.vitaminKMcg! > 200 ? AlertSeverity.critical : AlertSeverity.high,
      ));
    }

    // Grapefruit Interaction
    if (prefs.hasGrapefruitInteraction && indicators.isGrapefruit) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.containsGrapefruit,
        foodItemName: item.name,
        customMessage: '${item.name} contains grapefruit which may interact with your medications',
      ));
    }

    // MAO Inhibitors - High Tyramine
    if (prefs.takesMAOInhibitors && indicators.tyramineLevel == QualitativeLevel.high) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.highTyramine,
        foodItemName: item.name,
        customMessage: '${item.name} is high in tyramine which may interact with MAO inhibitors',
      ));
    }

    // === OTHER CONDITION CHECKS ===

    // Thyroid - Goitrogens
    if (prefs.hasThyroidCondition && indicators.isGoitrogen) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.containsGoitrogen,
        foodItemName: item.name,
        customMessage: '${item.name} contains goitrogens which may affect thyroid function',
      ));
    }

    // PKU - High Phenylalanine
    if (prefs.hasPKU && indicators.phenylalanineMg != null && indicators.phenylalanineMg! > 100) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.highPhenylalanine,
        foodItemName: item.name,
        value: indicators.phenylalanineMg,
        unit: 'mg',
        customMessage: '${item.name} contains phenylalanine - not recommended for PKU',
      ));
    }

    // Wilson's Disease - High Copper
    if (prefs.hasWilsonDisease && indicators.copperMg != null && indicators.copperMg! > 0.5) {
      alerts.add(HealthAlert.create(
        type: HealthAlertType.highCopper,
        foodItemName: item.name,
        value: indicators.copperMg,
        unit: 'mg',
        customMessage: '${item.name} is high in copper',
      ));
    }

    // Sort by severity (critical first)
    alerts.sort((a, b) => b.severity.index.compareTo(a.severity.index));

    return alerts;
  }

  /// Check all food items in a meal analysis and attach alerts
  MealAnalysis checkMealAnalysis(MealAnalysis analysis, HealthAlertPreferences prefs) {
    if (!prefs.alertsEnabled) return analysis;

    final updatedItems = analysis.items.map((item) {
      final alerts = checkFoodItem(item, prefs);
      return item.copyWith(healthAlerts: alerts);
    }).toList();

    return MealAnalysis(
      items: updatedItems,
      confidence: analysis.confidence,
      source: analysis.source,
    );
  }
}

/// Provider for HealthAlertService
final healthAlertServiceProvider = Provider<HealthAlertService>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

/// Provider for health alert preferences
final healthAlertPreferencesProvider = StateNotifierProvider<HealthAlertPreferencesNotifier, HealthAlertPreferences>((ref) {
  final service = ref.watch(healthAlertServiceProvider);
  return HealthAlertPreferencesNotifier(service);
});

/// State notifier for health alert preferences
class HealthAlertPreferencesNotifier extends StateNotifier<HealthAlertPreferences> {
  final HealthAlertService _service;

  HealthAlertPreferencesNotifier(this._service) : super(_service.loadPreferences());

  /// Update a single preference
  Future<void> updatePreference(HealthAlertPreferences Function(HealthAlertPreferences) updater) async {
    state = updater(state);
    await _service.savePreferences(state);
  }

  /// Reset to defaults
  Future<void> resetToDefaults() async {
    state = HealthAlertPreferences.defaults();
    await _service.savePreferences(state);
  }

  /// Toggle master switch
  Future<void> toggleAlertsEnabled() async {
    state = state.copyWith(alertsEnabled: !state.alertsEnabled);
    await _service.savePreferences(state);
  }
}
