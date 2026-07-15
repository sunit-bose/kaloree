// Health Alert Models for Kaloree
// These models handle health-related warnings and user preferences

/// Severity levels for health alerts
enum AlertSeverity {
  low('Low', 'ℹ️'),
  medium('Medium', '⚠️'),
  high('High', '🔶'),
  critical('Critical', '🔴');

  final String displayName;
  final String emoji;
  const AlertSeverity(this.displayName, this.emoji);

  static AlertSeverity fromString(String value) {
    return AlertSeverity.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => AlertSeverity.medium,
    );
  }
}

/// Types of health alerts that can be triggered
enum HealthAlertType {
  // === METABOLIC ===
  highPurines('High Purines', 'May trigger gout flare-ups', 'metabolic', AlertSeverity.medium),
  highGlycemicIndex('High Glycemic Index', 'May cause blood sugar spike', 'metabolic', AlertSeverity.high),
  highSodium('High Sodium', 'May affect blood pressure', 'metabolic', AlertSeverity.medium),
  highCholesterol('High Cholesterol', 'May affect heart health', 'metabolic', AlertSeverity.medium),
  highSaturatedFat('High Saturated Fat', 'May affect cardiovascular health', 'metabolic', AlertSeverity.medium),
  highTransFat('High Trans Fat', 'Harmful to heart health', 'metabolic', AlertSeverity.critical),
  veryHighCalories('Very High Calories', 'Single item exceeds 800 kcal', 'metabolic', AlertSeverity.medium),

  // === ALLERGENS ===
  containsNuts('Contains Nuts', 'Contains tree nuts or peanuts', 'allergen', AlertSeverity.critical),
  containsDairy('Contains Dairy', 'Contains milk or dairy products', 'allergen', AlertSeverity.critical),
  containsGluten('Contains Gluten', 'Contains wheat, barley, or rye', 'allergen', AlertSeverity.critical),
  containsShellfish('Contains Shellfish', 'Contains shrimp, crab, or lobster', 'allergen', AlertSeverity.critical),
  containsEggs('Contains Eggs', 'Contains egg products', 'allergen', AlertSeverity.critical),
  containsSoy('Contains Soy', 'Contains soy products', 'allergen', AlertSeverity.critical),

  // === KIDNEY HEALTH ===
  highPotassium('High Potassium', 'May affect kidney function', 'kidney', AlertSeverity.high),
  highPhosphorus('High Phosphorus', 'May affect kidney health', 'kidney', AlertSeverity.high),
  highOxalate('High Oxalate', 'May contribute to kidney stones', 'kidney', AlertSeverity.medium),

  // === DIGESTIVE ===
  highFodmap('High FODMAP', 'May trigger IBS symptoms', 'digestive', AlertSeverity.medium),
  highHistamine('High Histamine', 'May trigger histamine intolerance symptoms', 'digestive', AlertSeverity.medium),
  containsNightshade('Contains Nightshade', 'May trigger autoimmune symptoms', 'digestive', AlertSeverity.low),

  // === PREGNANCY & SAFETY ===
  highMercury('High Mercury', 'Not recommended during pregnancy', 'pregnancy', AlertSeverity.critical),
  rawUndercooked('Raw/Undercooked', 'Food safety concern', 'pregnancy', AlertSeverity.critical),
  highCaffeine('High Caffeine', 'May affect pregnancy or sleep', 'pregnancy', AlertSeverity.medium),
  containsAlcohol('Contains Alcohol', 'Not recommended during pregnancy or recovery', 'pregnancy', AlertSeverity.critical),

  // === MEDICATION INTERACTIONS ===
  highVitaminK('High Vitamin K', 'May interact with blood thinners', 'medication', AlertSeverity.high),
  containsGrapefruit('Contains Grapefruit', 'May interact with medications', 'medication', AlertSeverity.critical),
  highTyramine('High Tyramine', 'May interact with MAO inhibitors', 'medication', AlertSeverity.critical),

  // === OTHER CONDITIONS ===
  containsGoitrogen('Contains Goitrogen', 'May affect thyroid function', 'other', AlertSeverity.low),
  highPhenylalanine('High Phenylalanine', 'Not recommended for PKU', 'other', AlertSeverity.critical),
  highCopper('High Copper', 'Not recommended for Wilson\'s disease', 'other', AlertSeverity.medium);

  final String displayName;
  final String description;
  final String category;
  final AlertSeverity defaultSeverity;

  const HealthAlertType(this.displayName, this.description, this.category, this.defaultSeverity);

  static HealthAlertType? fromString(String value) {
    try {
      return HealthAlertType.values.firstWhere(
        (e) => e.name == value || e.name == _camelToSnake(value),
      );
    } catch (_) {
      return null;
    }
  }

  static String _camelToSnake(String str) {
    return str.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceFirst('_', '');
  }
}

/// Level indicators for qualitative health metrics
enum QualitativeLevel {
  none('none'),
  low('low'),
  medium('medium'),
  high('high');

  final String value;
  const QualitativeLevel(this.value);

  static QualitativeLevel fromString(String? value) {
    if (value == null) return QualitativeLevel.low;
    return QualitativeLevel.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => QualitativeLevel.low,
    );
  }
}

/// Health indicators extracted from AI analysis
class HealthIndicators {
  // Metabolic
  final double? glycemicIndex;
  final QualitativeLevel purineLevel;
  final double? sodiumMg;
  final double? cholesterolMg;
  final double? saturatedFatG;
  final double? transFatG;

  // Kidney
  final double? potassiumMg;
  final double? phosphorusMg;
  final QualitativeLevel oxalateLevel;

  // Digestive
  final QualitativeLevel fodmapLevel;
  final QualitativeLevel histamineLevel;
  final bool isNightshade;

  // Pregnancy/Safety
  final QualitativeLevel mercuryLevel;
  final bool isRawUndercooked;
  final double? caffeineMg;
  final bool containsAlcohol;

  // Medication interactions
  final double? vitaminKMcg;
  final bool isGrapefruit;
  final QualitativeLevel tyramineLevel;

  // Other conditions
  final bool isGoitrogen;
  final double? phenylalanineMg;
  final double? copperMg;

  // Allergens
  final List<String> allergens;

  HealthIndicators({
    this.glycemicIndex,
    this.purineLevel = QualitativeLevel.low,
    this.sodiumMg,
    this.cholesterolMg,
    this.saturatedFatG,
    this.transFatG,
    this.potassiumMg,
    this.phosphorusMg,
    this.oxalateLevel = QualitativeLevel.low,
    this.fodmapLevel = QualitativeLevel.low,
    this.histamineLevel = QualitativeLevel.low,
    this.isNightshade = false,
    this.mercuryLevel = QualitativeLevel.none,
    this.isRawUndercooked = false,
    this.caffeineMg,
    this.containsAlcohol = false,
    this.vitaminKMcg,
    this.isGrapefruit = false,
    this.tyramineLevel = QualitativeLevel.low,
    this.isGoitrogen = false,
    this.phenylalanineMg,
    this.copperMg,
    this.allergens = const [],
  });

  factory HealthIndicators.fromJson(Map<String, dynamic>? json) {
    if (json == null) return HealthIndicators();

    return HealthIndicators(
      glycemicIndex: (json['glycemicIndex'] as num?)?.toDouble(),
      purineLevel: QualitativeLevel.fromString(json['purineLevel'] as String?),
      sodiumMg: (json['sodiumMg'] as num?)?.toDouble(),
      cholesterolMg: (json['cholesterolMg'] as num?)?.toDouble(),
      saturatedFatG: (json['saturatedFatG'] as num?)?.toDouble(),
      transFatG: (json['transFatG'] as num?)?.toDouble(),
      potassiumMg: (json['potassiumMg'] as num?)?.toDouble(),
      phosphorusMg: (json['phosphorusMg'] as num?)?.toDouble(),
      oxalateLevel: QualitativeLevel.fromString(json['oxalateLevel'] as String?),
      fodmapLevel: QualitativeLevel.fromString(json['fodmapLevel'] as String?),
      histamineLevel: QualitativeLevel.fromString(json['histamineLevel'] as String?),
      isNightshade: json['isNightshade'] as bool? ?? false,
      mercuryLevel: QualitativeLevel.fromString(json['mercuryLevel'] as String?),
      isRawUndercooked: json['isRawUndercooked'] as bool? ?? false,
      caffeineMg: (json['caffeineMg'] as num?)?.toDouble(),
      containsAlcohol: json['containsAlcohol'] as bool? ?? false,
      vitaminKMcg: (json['vitaminKMcg'] as num?)?.toDouble(),
      isGrapefruit: json['isGrapefruit'] as bool? ?? false,
      tyramineLevel: QualitativeLevel.fromString(json['tyramineLevel'] as String?),
      isGoitrogen: json['isGoitrogen'] as bool? ?? false,
      phenylalanineMg: (json['phenylalanineMg'] as num?)?.toDouble(),
      copperMg: (json['copperMg'] as num?)?.toDouble(),
      allergens: (json['allergens'] as List<dynamic>?)
              ?.map((e) => e.toString().toLowerCase())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'glycemicIndex': glycemicIndex,
      'purineLevel': purineLevel.value,
      'sodiumMg': sodiumMg,
      'cholesterolMg': cholesterolMg,
      'saturatedFatG': saturatedFatG,
      'transFatG': transFatG,
      'potassiumMg': potassiumMg,
      'phosphorusMg': phosphorusMg,
      'oxalateLevel': oxalateLevel.value,
      'fodmapLevel': fodmapLevel.value,
      'histamineLevel': histamineLevel.value,
      'isNightshade': isNightshade,
      'mercuryLevel': mercuryLevel.value,
      'isRawUndercooked': isRawUndercooked,
      'caffeineMg': caffeineMg,
      'containsAlcohol': containsAlcohol,
      'vitaminKMcg': vitaminKMcg,
      'isGrapefruit': isGrapefruit,
      'tyramineLevel': tyramineLevel.value,
      'isGoitrogen': isGoitrogen,
      'phenylalanineMg': phenylalanineMg,
      'copperMg': copperMg,
      'allergens': allergens,
    };
  }

  /// Check if allergen is present
  bool hasAllergen(String allergen) {
    return allergens.any((a) => a.toLowerCase() == allergen.toLowerCase());
  }
}

/// A triggered health alert for a specific food item
class HealthAlert {
  final HealthAlertType type;
  final AlertSeverity severity;
  final String message;
  final String? details;
  final double? value;
  final String? unit;
  final String foodItemName;

  // Dismissal tracking
  bool isDismissed;
  DateTime? dismissedAt;
  String? dismissalReason;

  HealthAlert({
    required this.type,
    required this.severity,
    required this.message,
    this.details,
    this.value,
    this.unit,
    required this.foodItemName,
    this.isDismissed = false,
    this.dismissedAt,
    this.dismissalReason,
  });

  /// Create an alert from a detected condition
  factory HealthAlert.create({
    required HealthAlertType type,
    required String foodItemName,
    double? value,
    String? unit,
    String? customMessage,
    AlertSeverity? overrideSeverity,
  }) {
    return HealthAlert(
      type: type,
      severity: overrideSeverity ?? type.defaultSeverity,
      message: customMessage ?? type.description,
      value: value,
      unit: unit,
      foodItemName: foodItemName,
    );
  }

  /// Dismiss this alert
  void dismiss({String? reason}) {
    isDismissed = true;
    dismissedAt = DateTime.now();
    dismissalReason = reason;
  }

  factory HealthAlert.fromJson(Map<String, dynamic> json) {
    return HealthAlert(
      type: HealthAlertType.fromString(json['type'] as String) ?? HealthAlertType.highSodium,
      severity: AlertSeverity.fromString(json['severity'] as String),
      message: json['message'] as String,
      details: json['details'] as String?,
      value: (json['value'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      foodItemName: json['foodItemName'] as String? ?? 'Unknown',
      isDismissed: json['isDismissed'] as bool? ?? false,
      dismissedAt: json['dismissedAt'] != null
          ? DateTime.parse(json['dismissedAt'] as String)
          : null,
      dismissalReason: json['dismissalReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'severity': severity.name,
      'message': message,
      'details': details,
      'value': value,
      'unit': unit,
      'foodItemName': foodItemName,
      'isDismissed': isDismissed,
      'dismissedAt': dismissedAt?.toIso8601String(),
      'dismissalReason': dismissalReason,
    };
  }

  /// Get display string with value if applicable
  String get displayValue {
    if (value == null) return '';
    return '${value!.toStringAsFixed(1)} ${unit ?? ''}';
  }

  /// Check if this is a critical alert
  bool get isCritical => severity == AlertSeverity.critical;
}

/// User preferences for which health alerts to show
class HealthAlertPreferences {
  // Master switch
  bool alertsEnabled;

  // === METABOLIC CONDITIONS ===
  bool hasGout;
  bool hasDiabetes;
  bool hasHypertension;
  bool hasHeartDisease;

  // === KIDNEY CONDITIONS ===
  bool hasKidneyDisease;
  bool hasKidneyStones;

  // === DIGESTIVE CONDITIONS ===
  bool hasIBS;
  bool hasHistamineIntolerance;
  bool hasAutoimmune;

  // === THYROID ===
  bool hasThyroidCondition;

  // === RARE CONDITIONS ===
  bool hasPKU;
  bool hasWilsonDisease;

  // === ALLERGENS ===
  bool allergyNuts;
  bool allergyDairy;
  bool allergyGluten;
  bool allergyShellfish;
  bool allergyEggs;
  bool allergySoy;

  // === LIFE STAGES ===
  bool isPregnant;
  bool isBreastfeeding;
  bool inRecovery;

  // === MEDICATIONS ===
  bool takesWarfarin;
  bool takesMAOInhibitors;
  bool hasGrapefruitInteraction;

  // === GENERAL WELLNESS ===
  bool warnHighSaturatedFat;
  bool warnHighCholesterol;
  bool warnHighTransFat;
  bool warnVeryHighCalories;
  bool warnRawUndercooked;

  HealthAlertPreferences({
    this.alertsEnabled = true,
    // Metabolic
    this.hasGout = false,
    this.hasDiabetes = false,
    this.hasHypertension = false,
    this.hasHeartDisease = false,
    // Kidney
    this.hasKidneyDisease = false,
    this.hasKidneyStones = false,
    // Digestive
    this.hasIBS = false,
    this.hasHistamineIntolerance = false,
    this.hasAutoimmune = false,
    // Thyroid
    this.hasThyroidCondition = false,
    // Rare
    this.hasPKU = false,
    this.hasWilsonDisease = false,
    // Allergens
    this.allergyNuts = false,
    this.allergyDairy = false,
    this.allergyGluten = false,
    this.allergyShellfish = false,
    this.allergyEggs = false,
    this.allergySoy = false,
    // Life stages
    this.isPregnant = false,
    this.isBreastfeeding = false,
    this.inRecovery = false,
    // Medications
    this.takesWarfarin = false,
    this.takesMAOInhibitors = false,
    this.hasGrapefruitInteraction = false,
    // General wellness - some defaults ON
    this.warnHighSaturatedFat = true,
    this.warnHighCholesterol = false,
    this.warnHighTransFat = true,
    this.warnVeryHighCalories = false,
    this.warnRawUndercooked = true,
  });

  /// Create default preferences (minimal alerts enabled)
  factory HealthAlertPreferences.defaults() {
    return HealthAlertPreferences();
  }

  /// Count how many conditions are enabled
  int get enabledConditionCount {
    int count = 0;
    if (hasGout) count++;
    if (hasDiabetes) count++;
    if (hasHypertension) count++;
    if (hasHeartDisease) count++;
    if (hasKidneyDisease) count++;
    if (hasKidneyStones) count++;
    if (hasIBS) count++;
    if (hasHistamineIntolerance) count++;
    if (hasAutoimmune) count++;
    if (hasThyroidCondition) count++;
    if (hasPKU) count++;
    if (hasWilsonDisease) count++;
    if (allergyNuts) count++;
    if (allergyDairy) count++;
    if (allergyGluten) count++;
    if (allergyShellfish) count++;
    if (allergyEggs) count++;
    if (allergySoy) count++;
    if (isPregnant) count++;
    if (isBreastfeeding) count++;
    if (inRecovery) count++;
    if (takesWarfarin) count++;
    if (takesMAOInhibitors) count++;
    if (hasGrapefruitInteraction) count++;
    return count;
  }

  /// Check if any allergens are enabled
  bool get hasAnyAllergies =>
      allergyNuts ||
      allergyDairy ||
      allergyGluten ||
      allergyShellfish ||
      allergyEggs ||
      allergySoy;

  /// Check if any pregnancy-related concerns are enabled
  bool get hasPregnancyConcerns => isPregnant || isBreastfeeding;

  /// Check if any medication interactions are enabled
  bool get hasMedicationConcerns =>
      takesWarfarin || takesMAOInhibitors || hasGrapefruitInteraction;

  factory HealthAlertPreferences.fromJson(Map<String, dynamic> json) {
    return HealthAlertPreferences(
      alertsEnabled: json['alertsEnabled'] as bool? ?? true,
      // Metabolic
      hasGout: json['hasGout'] as bool? ?? false,
      hasDiabetes: json['hasDiabetes'] as bool? ?? false,
      hasHypertension: json['hasHypertension'] as bool? ?? false,
      hasHeartDisease: json['hasHeartDisease'] as bool? ?? false,
      // Kidney
      hasKidneyDisease: json['hasKidneyDisease'] as bool? ?? false,
      hasKidneyStones: json['hasKidneyStones'] as bool? ?? false,
      // Digestive
      hasIBS: json['hasIBS'] as bool? ?? false,
      hasHistamineIntolerance: json['hasHistamineIntolerance'] as bool? ?? false,
      hasAutoimmune: json['hasAutoimmune'] as bool? ?? false,
      // Thyroid
      hasThyroidCondition: json['hasThyroidCondition'] as bool? ?? false,
      // Rare
      hasPKU: json['hasPKU'] as bool? ?? false,
      hasWilsonDisease: json['hasWilsonDisease'] as bool? ?? false,
      // Allergens
      allergyNuts: json['allergyNuts'] as bool? ?? false,
      allergyDairy: json['allergyDairy'] as bool? ?? false,
      allergyGluten: json['allergyGluten'] as bool? ?? false,
      allergyShellfish: json['allergyShellfish'] as bool? ?? false,
      allergyEggs: json['allergyEggs'] as bool? ?? false,
      allergySoy: json['allergySoy'] as bool? ?? false,
      // Life stages
      isPregnant: json['isPregnant'] as bool? ?? false,
      isBreastfeeding: json['isBreastfeeding'] as bool? ?? false,
      inRecovery: json['inRecovery'] as bool? ?? false,
      // Medications
      takesWarfarin: json['takesWarfarin'] as bool? ?? false,
      takesMAOInhibitors: json['takesMAOInhibitors'] as bool? ?? false,
      hasGrapefruitInteraction: json['hasGrapefruitInteraction'] as bool? ?? false,
      // General wellness
      warnHighSaturatedFat: json['warnHighSaturatedFat'] as bool? ?? true,
      warnHighCholesterol: json['warnHighCholesterol'] as bool? ?? false,
      warnHighTransFat: json['warnHighTransFat'] as bool? ?? true,
      warnVeryHighCalories: json['warnVeryHighCalories'] as bool? ?? false,
      warnRawUndercooked: json['warnRawUndercooked'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alertsEnabled': alertsEnabled,
      // Metabolic
      'hasGout': hasGout,
      'hasDiabetes': hasDiabetes,
      'hasHypertension': hasHypertension,
      'hasHeartDisease': hasHeartDisease,
      // Kidney
      'hasKidneyDisease': hasKidneyDisease,
      'hasKidneyStones': hasKidneyStones,
      // Digestive
      'hasIBS': hasIBS,
      'hasHistamineIntolerance': hasHistamineIntolerance,
      'hasAutoimmune': hasAutoimmune,
      // Thyroid
      'hasThyroidCondition': hasThyroidCondition,
      // Rare
      'hasPKU': hasPKU,
      'hasWilsonDisease': hasWilsonDisease,
      // Allergens
      'allergyNuts': allergyNuts,
      'allergyDairy': allergyDairy,
      'allergyGluten': allergyGluten,
      'allergyShellfish': allergyShellfish,
      'allergyEggs': allergyEggs,
      'allergySoy': allergySoy,
      // Life stages
      'isPregnant': isPregnant,
      'isBreastfeeding': isBreastfeeding,
      'inRecovery': inRecovery,
      // Medications
      'takesWarfarin': takesWarfarin,
      'takesMAOInhibitors': takesMAOInhibitors,
      'hasGrapefruitInteraction': hasGrapefruitInteraction,
      // General wellness
      'warnHighSaturatedFat': warnHighSaturatedFat,
      'warnHighCholesterol': warnHighCholesterol,
      'warnHighTransFat': warnHighTransFat,
      'warnVeryHighCalories': warnVeryHighCalories,
      'warnRawUndercooked': warnRawUndercooked,
    };
  }

  HealthAlertPreferences copyWith({
    bool? alertsEnabled,
    bool? hasGout,
    bool? hasDiabetes,
    bool? hasHypertension,
    bool? hasHeartDisease,
    bool? hasKidneyDisease,
    bool? hasKidneyStones,
    bool? hasIBS,
    bool? hasHistamineIntolerance,
    bool? hasAutoimmune,
    bool? hasThyroidCondition,
    bool? hasPKU,
    bool? hasWilsonDisease,
    bool? allergyNuts,
    bool? allergyDairy,
    bool? allergyGluten,
    bool? allergyShellfish,
    bool? allergyEggs,
    bool? allergySoy,
    bool? isPregnant,
    bool? isBreastfeeding,
    bool? inRecovery,
    bool? takesWarfarin,
    bool? takesMAOInhibitors,
    bool? hasGrapefruitInteraction,
    bool? warnHighSaturatedFat,
    bool? warnHighCholesterol,
    bool? warnHighTransFat,
    bool? warnVeryHighCalories,
    bool? warnRawUndercooked,
  }) {
    return HealthAlertPreferences(
      alertsEnabled: alertsEnabled ?? this.alertsEnabled,
      hasGout: hasGout ?? this.hasGout,
      hasDiabetes: hasDiabetes ?? this.hasDiabetes,
      hasHypertension: hasHypertension ?? this.hasHypertension,
      hasHeartDisease: hasHeartDisease ?? this.hasHeartDisease,
      hasKidneyDisease: hasKidneyDisease ?? this.hasKidneyDisease,
      hasKidneyStones: hasKidneyStones ?? this.hasKidneyStones,
      hasIBS: hasIBS ?? this.hasIBS,
      hasHistamineIntolerance: hasHistamineIntolerance ?? this.hasHistamineIntolerance,
      hasAutoimmune: hasAutoimmune ?? this.hasAutoimmune,
      hasThyroidCondition: hasThyroidCondition ?? this.hasThyroidCondition,
      hasPKU: hasPKU ?? this.hasPKU,
      hasWilsonDisease: hasWilsonDisease ?? this.hasWilsonDisease,
      allergyNuts: allergyNuts ?? this.allergyNuts,
      allergyDairy: allergyDairy ?? this.allergyDairy,
      allergyGluten: allergyGluten ?? this.allergyGluten,
      allergyShellfish: allergyShellfish ?? this.allergyShellfish,
      allergyEggs: allergyEggs ?? this.allergyEggs,
      allergySoy: allergySoy ?? this.allergySoy,
      isPregnant: isPregnant ?? this.isPregnant,
      isBreastfeeding: isBreastfeeding ?? this.isBreastfeeding,
      inRecovery: inRecovery ?? this.inRecovery,
      takesWarfarin: takesWarfarin ?? this.takesWarfarin,
      takesMAOInhibitors: takesMAOInhibitors ?? this.takesMAOInhibitors,
      hasGrapefruitInteraction: hasGrapefruitInteraction ?? this.hasGrapefruitInteraction,
      warnHighSaturatedFat: warnHighSaturatedFat ?? this.warnHighSaturatedFat,
      warnHighCholesterol: warnHighCholesterol ?? this.warnHighCholesterol,
      warnHighTransFat: warnHighTransFat ?? this.warnHighTransFat,
      warnVeryHighCalories: warnVeryHighCalories ?? this.warnVeryHighCalories,
      warnRawUndercooked: warnRawUndercooked ?? this.warnRawUndercooked,
    );
  }
}

/// Common dismissal reasons for alerts
class DismissalReasons {
  static const String occasionalTreat = 'Occasional treat';
  static const String doctorApproved = 'Doctor approved';
  static const String smallPortion = 'Small portion';
  static const String alreadyAccounted = 'Already accounted for';
  static const String notAccurate = 'AI not accurate';
  static const String other = 'Other';

  static List<String> get all => [
        occasionalTreat,
        doctorApproved,
        smallPortion,
        alreadyAccounted,
        notAccurate,
        other,
      ];
}
