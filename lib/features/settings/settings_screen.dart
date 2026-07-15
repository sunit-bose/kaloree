import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/secure_storage_service.dart';
import '../../services/database_service.dart';
import '../../services/tdee_calculator.dart';
import '../../services/health_alert_service.dart';
import '../../models/meal_analysis.dart';
import '../../models/health_alert.dart';
import '../auth/data/auth_repository.dart';
import '../../app/theme.dart';

/// Settings Screen - API key management and daily goals
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // My Account Section (at the top)
          Text('👤 My Account', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Manage your account, sign out, or export your data.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          _MyAccountCard(),
          
          const SizedBox(height: 32),
          Text('🤖 AI Configuration', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Add your Google AI API key to enable AI meal analysis. Keys are stored securely on your device.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          _ApiConfigCard(),

          const SizedBox(height: 32),
          Text('👤 Your Profile', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Enter your details to calculate personalized nutrition goals using the Mifflin-St Jeor equation.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          _ProfileCard(),

          const SizedBox(height: 32),
          Text('⚠️ Health Alerts', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Get personalized alerts when scanned foods may affect your health conditions.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          _HealthAlertsCard(),

          const SizedBox(height: 32),
          Text('🎯 Calculated Goals', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Your personalized nutrition targets based on your profile. You can also adjust manually.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          _GoalsCard(),

          const SizedBox(height: 32),
          Text('🔒 Privacy', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PrivacyItem(icon: Icons.photo_camera_outlined, iconColor: Colors.blue.shade400, title: 'Images', description: 'Photos are processed in memory and never stored'),
                  const Divider(height: 24),
                  _PrivacyItem(icon: Icons.storage_outlined, iconColor: Colors.green.shade400, title: 'Data Storage', description: 'All data stored locally on your device only'),
                  const Divider(height: 24),
                  _PrivacyItem(icon: Icons.key_outlined, iconColor: Colors.purple.shade400, title: 'API Keys', description: 'Encrypted using device Keychain/Keystore'),
                  const Divider(height: 24),
                  _PrivacyItem(icon: Icons.wifi_outlined, iconColor: Colors.orange.shade400, title: 'Network', description: 'Only connects to Google AI API (HTTPS)'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          Text('🗂️ Data Management', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Clear All Data', style: TextStyle(color: Colors.red)),
              subtitle: const Text('Delete all meals and settings'),
              onTap: () => _showClearDataDialog(context),
            ),
          ),

          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                const Text('🔥 Kaloree', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                Text('Version 1.0.0', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Text('Made with ❤️ for healthy eating 💪', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500)),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will delete all your meals, settings, and API keys. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(secureStorageProvider).clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data cleared')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

/// API Configuration Card - Google AI (Gemini) only
class _ApiConfigCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ApiConfigCard> createState() => _ApiConfigCardState();
}

class _ApiConfigCardState extends ConsumerState<_ApiConfigCard> {
  bool _isLoading = true;
  bool _hasApiKey = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final storage = ref.read(secureStorageProvider);
    final hasKey = await storage.hasGeminiApiKey();
    setState(() {
      _hasApiKey = hasKey;
      _isLoading = false;
    });
  }

  void _showApiKeyDialog() {
    final controller = TextEditingController();
    final isObscured = ValueNotifier(true);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Image.network(
              'https://www.gstatic.com/lamda/images/gemini_sparkle_v002_d4735304ff6292a690345.svg',
              width: 24,
              height: 24,
              errorBuilder: (_, __, ___) => const Icon(Icons.auto_awesome, color: Colors.blue),
            ),
            const SizedBox(width: 8),
            const Text('Google AI API Key'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Get your free API key from Google AI Studio',
                      style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                // Could open URL here with url_launcher
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Visit: aistudio.google.com/app/apikey')),
                );
              },
              child: Text(
                'aistudio.google.com/app/apikey',
                style: TextStyle(
                  color: Colors.blue.shade600,
                  decoration: TextDecoration.underline,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: isObscured,
              builder: (context, obscured, _) {
                return TextField(
                  controller: controller,
                  obscureText: obscured,
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    hintText: 'AIza...',
                    prefixIcon: const Icon(Icons.key),
                    suffixIcon: IconButton(
                      icon: Icon(obscured ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => isObscured.value = !obscured,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () async {
              final key = controller.text.trim();
              if (key.isEmpty) return;
              
              // Basic validation - accept both legacy 'AI' keys and new 'AQ' auth keys (since June 2026)
              if (!key.startsWith('AI') && !key.startsWith('AQ')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid key format. Google AI keys start with "AI" or "AQ"'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              
              final storage = ref.read(secureStorageProvider);
              await storage.setGeminiApiKey(key);
              Navigator.pop(context);
              await _loadConfig();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ API key saved securely'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showRemoveKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove API Key?'),
        content: const Text('This will remove your Google AI API key. You can add it again later.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final storage = ref.read(secureStorageProvider);
              await storage.setGeminiApiKey('');
              Navigator.pop(context);
              await _loadConfig();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('API key removed')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Google AI Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.purple.shade400],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Google AI (Gemini)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      Text('Gemini 2.0 Flash', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Status Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _hasApiKey ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _hasApiKey ? Colors.green.shade200 : Colors.orange.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _hasApiKey ? Icons.check_circle : Icons.warning_amber_rounded,
                    color: _hasApiKey ? Colors.green.shade600 : Colors.orange.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hasApiKey ? 'Ready to analyze meals' : 'API key required',
                          style: TextStyle(
                            color: _hasApiKey ? Colors.green.shade700 : Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _hasApiKey 
                            ? 'Your key is stored securely' 
                            : 'Add your Google AI API key to enable AI features',
                          style: TextStyle(
                            color: _hasApiKey ? Colors.green.shade600 : Colors.orange.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showApiKeyDialog,
                    icon: Icon(_hasApiKey ? Icons.edit : Icons.add),
                    label: Text(_hasApiKey ? 'Change Key' : 'Add Key'),
                  ),
                ),
                if (_hasApiKey) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _showRemoveKeyDialog,
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    tooltip: 'Remove API key',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends ConsumerState<_ProfileCard> {
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _targetWeightController;
  Gender _gender = Gender.male;
  ActivityLevel _activityLevel = ActivityLevel.sedentary;
  bool _isLoading = true;
  
  // Calculated preview state
  NutritionTargets? _calculatedPreview;
  bool _hasCalculated = false;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _targetWeightController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final database = ref.read(databaseProvider);
    final profile = await database.getUserProfile();
    
    setState(() {
      if (profile != null) {
        _ageController.text = profile.age.toString();
        _weightController.text = profile.weightKg.toStringAsFixed(1);
        _heightController.text = profile.heightCm.toStringAsFixed(1);
        _gender = profile.gender;
        _activityLevel = profile.activityLevel;
        // Pre-fill target weight if it was same as current (maintenance)
        if (profile.targetWeightKg != null) {
          _targetWeightController.text = profile.targetWeightKg!.toStringAsFixed(1);
        }
      }
      _isLoading = false;
    });
  }
  
  /// Validate inputs and calculate preview
  void _calculatePreview() {
    final age = int.tryParse(_ageController.text);
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    final targetWeight = double.tryParse(_targetWeightController.text);

    if (age == null || weight == null || height == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in Age, Weight, and Height')),
      );
      return;
    }

    if (age < 15 || age > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Age must be between 15 and 100')),
      );
      return;
    }

    if (weight < 30 || weight > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weight must be between 30 and 300 kg')),
      );
      return;
    }

    if (height < 100 || height > 250) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Height must be between 100 and 250 cm')),
      );
      return;
    }

    if (targetWeight != null && (targetWeight < 30 || targetWeight > 300)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Target weight must be between 30 and 300 kg')),
      );
      return;
    }

    // Calculate using target weight (if provided, else uses maintenance)
    final targets = TDEECalculator.quickCalculate(
      age: age,
      weightKg: weight,
      heightCm: height,
      gender: _gender,
      activityLevel: _activityLevel,
      targetWeightKg: targetWeight ?? weight, // Default to current weight (maintenance)
    );

    setState(() {
      _calculatedPreview = targets;
      _hasCalculated = true;
    });
  }

  Future<void> _saveGoals() async {
    if (_calculatedPreview == null) return;
    
    final age = int.tryParse(_ageController.text)!;
    final weight = double.tryParse(_weightController.text)!;
    final height = double.tryParse(_heightController.text)!;
    final targetWeight = double.tryParse(_targetWeightController.text) ?? weight;

    final profile = UserProfile(
      age: age,
      weightKg: weight,
      heightCm: height,
      gender: _gender,
      activityLevel: _activityLevel,
      targetWeightKg: targetWeight,
      fitnessGoal: FitnessGoal.fromWeightDifference(weight, targetWeight),
    );

    final database = ref.read(databaseProvider);
    await database.saveUserProfile(profile);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Goals saved successfully! 🎯')),
    );
  }
  
  /// Reset calculation when inputs change
  void _onInputChanged() {
    if (_hasCalculated) {
      setState(() {
        _hasCalculated = false;
        _calculatedPreview = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Info
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _onInputChanged(),
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      suffixText: 'years',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<Gender>(
                    value: _gender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: Gender.values.map((g) => DropdownMenuItem(
                      value: g,
                      child: Text(g == Gender.male ? 'Male' : 'Female'),
                    )).toList(),
                    onChanged: (v) {
                      setState(() => _gender = v ?? Gender.male);
                      _onInputChanged();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Current Weight & Height
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _onInputChanged(),
                    decoration: const InputDecoration(
                      labelText: 'Current Weight',
                      suffixText: 'kg',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _onInputChanged(),
                    decoration: const InputDecoration(
                      labelText: 'Height',
                      suffixText: 'cm',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Activity Level
            Text('Activity Level', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            DropdownButtonFormField<ActivityLevel>(
              value: _activityLevel,
              isExpanded: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: ActivityLevel.values.map((level) => DropdownMenuItem(
                value: level,
                child: Text(_getActivityLevelText(level), overflow: TextOverflow.ellipsis),
              )).toList(),
              onChanged: (v) {
                setState(() => _activityLevel = v ?? ActivityLevel.sedentary);
                _onInputChanged();
              },
            ),
            const SizedBox(height: 16),
            
            // Target Weight (NEW - replaces FitnessGoal dropdown)
            Text('Target Weight', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _targetWeightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => _onInputChanged(),
              decoration: InputDecoration(
                labelText: 'Your Goal Weight',
                suffixText: 'kg',
                helperText: 'Leave empty or same as current for maintenance',
                helperStyle: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 20),
            
            // Calculate Button (Step 1)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _hasCalculated ? null : _calculatePreview,
                icon: const Icon(Icons.calculate),
                label: Text(_hasCalculated ? 'Calculated ✓' : 'Calculate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasCalculated ? Colors.grey.shade400 : null,
                ),
              ),
            ),
            
            // Calculated Preview Section (shows after Calculate is clicked)
            if (_hasCalculated && _calculatedPreview != null) ...[
              const SizedBox(height: 20),
              _buildCalculatedPreview(theme),
            ],
            
            const SizedBox(height: 12),
            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Uses the Mifflin-St Jeor equation. '
                      'Calorie adjustment is calculated based on your target weight.',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCalculatedPreview(ThemeData theme) {
    final targets = _calculatedPreview!;
    final adjustmentText = targets.calorieAdjustment >= 0
        ? '+${targets.calorieAdjustment}'
        : '${targets.calorieAdjustment}';
    final adjustmentColor = targets.calorieAdjustment < 0
        ? Colors.orange.shade700
        : targets.calorieAdjustment > 0
            ? Colors.green.shade700
            : Colors.grey.shade700;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.indigo.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.purple.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Your Calculated Goals',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Goal Type Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getGoalColor(targets.goalType).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              targets.goalType,
              style: TextStyle(
                color: _getGoalColor(targets.goalType),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // BMR & TDEE Row with tooltips
          Row(
            children: [
              Expanded(
                child: _buildStatBoxWithTooltip(
                  context,
                  'BMR',
                  '${targets.bmr}',
                  'kcal',
                  Colors.blue,
                  'Basal Metabolic Rate: The calories your body burns at rest just to maintain vital functions like breathing, circulation, and cell production.',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatBoxWithTooltip(
                  context,
                  'TDEE',
                  '${targets.tdee}',
                  'kcal',
                  Colors.green,
                  'Total Daily Energy Expenditure: Your BMR plus calories burned through daily activities and exercise. This is how much you burn in a day.',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatBox('Adjustment', adjustmentText, 'kcal', adjustmentColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Daily Calories Target
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text('Daily Calorie Target', style: theme.textTheme.bodySmall),
                Text(
                  '${targets.dailyCalories}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                Text('kcal/day', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Macros Row
          Row(
            children: [
              Expanded(child: _buildMacroBox('Protein', targets.proteinGrams, 'g', Colors.red.shade400)),
              const SizedBox(width: 8),
              Expanded(child: _buildMacroBox('Carbs', targets.carbsGrams, 'g', Colors.amber.shade600)),
              const SizedBox(width: 8),
              Expanded(child: _buildMacroBox('Fat', targets.fatGrams, 'g', Colors.blue.shade400)),
            ],
          ),
          
          // Estimated time to goal
          if (targets.weeksToTarget != null && targets.weeksToTarget! > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Estimated time: ~${targets.weeksToTarget} weeks',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Save Button (Step 2)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveGoals,
              icon: const Icon(Icons.save),
              label: const Text('Save Goals'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatBox(String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
          Text(unit, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
  
  Widget _buildStatBoxWithTooltip(BuildContext context, String label, String value, String unit, Color color, String tooltip) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      showDuration: const Duration(seconds: 4),
      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: GestureDetector(
        onTap: () {
          // Show a dialog for better readability on mobile
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.info_outline, color: color),
                  const SizedBox(width: 8),
                  Text(label),
                ],
              ),
              content: Text(tooltip),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Got it'),
                ),
              ],
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                  const SizedBox(width: 2),
                  Icon(Icons.help_outline, size: 10, color: Colors.grey.shade400),
                ],
              ),
              Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
              Text(unit, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMacroBox(String label, double value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: color)),
          Text('${value.toStringAsFixed(0)}$unit', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
  
  Color _getGoalColor(String goalType) {
    switch (goalType) {
      case 'Fat Loss': return Colors.orange.shade700;
      case 'Muscle Gain': return Colors.green.shade700;
      default: return Colors.blue.shade700;
    }
  }

  String _getActivityLevelText(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 'Sedentary (little/no exercise)';
      case ActivityLevel.lightlyActive:
        return 'Lightly Active (1-3 days/week)';
      case ActivityLevel.moderatelyActive:
        return 'Moderately Active (3-5 days/week)';
      case ActivityLevel.veryActive:
        return 'Very Active (6-7 days/week)';
      case ActivityLevel.extraActive:
        return 'Extra Active (physical job + exercise)';
    }
  }
}

class _GoalsCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_GoalsCard> createState() => _GoalsCardState();
}

class _GoalsCardState extends ConsumerState<_GoalsCard> {
  late TextEditingController _calorieController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _fiberController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calorieController = TextEditingController();
    _proteinController = TextEditingController();
    _carbsController = TextEditingController();
    _fatController = TextEditingController();
    _fiberController = TextEditingController();
    _loadGoals();
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    super.dispose();
  }

  Future<void> _loadGoals() async {
    final database = ref.read(databaseProvider);
    final goals = await database.getGoals();
    setState(() {
      _calorieController.text = goals.calorieGoal.toString();
      _proteinController.text = goals.proteinGoal.toStringAsFixed(0);
      _carbsController.text = goals.carbsGoal.toStringAsFixed(0);
      _fatController.text = goals.fatGoal.toStringAsFixed(0);
      _fiberController.text = goals.fiberGoal.toStringAsFixed(0);
      _isLoading = false;
    });
  }

  Future<void> _saveGoals() async {
    final goals = DailyGoals(
      calorieGoal: int.tryParse(_calorieController.text) ?? 2000,
      proteinGoal: double.tryParse(_proteinController.text) ?? 60,
      carbsGoal: double.tryParse(_carbsController.text) ?? 250,
      fatGoal: double.tryParse(_fatController.text) ?? 65,
      fiberGoal: double.tryParse(_fiberController.text) ?? 25,
    );
    final database = ref.read(databaseProvider);
    await database.updateGoals(goals);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Goals saved')));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _calorieController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Daily Calories', suffixText: 'kcal')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _proteinController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Protein', suffixText: 'g'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _carbsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Carbs', suffixText: 'g'))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _fatController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fat', suffixText: 'g'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _fiberController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fiber', suffixText: 'g'))),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveGoals, child: const Text('Save Manual Goals'))),
            const SizedBox(height: 8),
            Text(
              'Note: Use the profile section above for automatic calculation based on your body metrics.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _PrivacyItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              Text(description, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Health Alerts Settings Card - Categorized toggles for health conditions
class _HealthAlertsCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_HealthAlertsCard> createState() => _HealthAlertsCardState();
}

class _HealthAlertsCardState extends ConsumerState<_HealthAlertsCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefs = ref.watch(healthAlertPreferencesProvider);
    final notifier = ref.read(healthAlertPreferencesProvider.notifier);
    final enabledCount = prefs.enabledConditionCount;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Master Switch Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: prefs.alertsEnabled
                        ? Colors.orange.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.health_and_safety,
                    color: prefs.alertsEnabled
                        ? Colors.orange.shade600
                        : Colors.grey.shade400,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Alerts',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        prefs.alertsEnabled
                            ? '$enabledCount condition${enabledCount == 1 ? '' : 's'} configured'
                            : 'Alerts disabled',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: prefs.alertsEnabled,
                  onChanged: (_) => notifier.toggleAlertsEnabled(),
                  activeColor: Colors.orange.shade600,
                ),
              ],
            ),
          ),

          if (prefs.alertsEnabled) ...[
            const Divider(height: 1),

            // Medical Disclaimer
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'These alerts are for informational purposes only and do not replace medical advice. Always consult your healthcare provider.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Expand/Collapse Button
            InkWell(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      _isExpanded ? 'Hide conditions' : 'Configure conditions',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.kaloreePurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppTheme.kaloreePurple,
                    ),
                  ],
                ),
              ),
            ),

            if (_isExpanded) ...[
              const Divider(height: 1),

              // === METABOLIC & CARDIOVASCULAR ===
              _buildCategoryHeader(
                theme,
                '🫀 Metabolic & Cardiovascular',
                Colors.red.shade400,
              ),
              _buildToggle(
                'Gout',
                'Alert on high purine foods',
                prefs.hasGout,
                (v) => notifier.updatePreference((p) => p.copyWith(hasGout: v)),
              ),
              _buildToggle(
                'Diabetes',
                'Alert on high glycemic index foods',
                prefs.hasDiabetes,
                (v) => notifier.updatePreference((p) => p.copyWith(hasDiabetes: v)),
              ),
              _buildToggle(
                'Hypertension',
                'Alert on high sodium foods',
                prefs.hasHypertension,
                (v) => notifier.updatePreference((p) => p.copyWith(hasHypertension: v)),
              ),
              _buildToggle(
                'Heart Disease',
                'Alert on high cholesterol/saturated fat',
                prefs.hasHeartDisease,
                (v) => notifier.updatePreference((p) => p.copyWith(hasHeartDisease: v)),
              ),

              // === KIDNEY HEALTH ===
              _buildCategoryHeader(
                theme,
                '🫘 Kidney Health',
                Colors.brown.shade400,
              ),
              _buildToggle(
                'Kidney Disease',
                'Alert on high potassium/phosphorus foods',
                prefs.hasKidneyDisease,
                (v) => notifier.updatePreference((p) => p.copyWith(hasKidneyDisease: v)),
              ),
              _buildToggle(
                'Kidney Stones',
                'Alert on high oxalate foods',
                prefs.hasKidneyStones,
                (v) => notifier.updatePreference((p) => p.copyWith(hasKidneyStones: v)),
              ),

              // === DIGESTIVE HEALTH ===
              _buildCategoryHeader(
                theme,
                '🍽️ Digestive Health',
                Colors.green.shade400,
              ),
              _buildToggle(
                'IBS',
                'Alert on high FODMAP foods',
                prefs.hasIBS,
                (v) => notifier.updatePreference((p) => p.copyWith(hasIBS: v)),
              ),
              _buildToggle(
                'Histamine Intolerance',
                'Alert on high histamine foods',
                prefs.hasHistamineIntolerance,
                (v) => notifier.updatePreference((p) => p.copyWith(hasHistamineIntolerance: v)),
              ),
              _buildToggle(
                'Autoimmune Condition',
                'Alert on nightshade vegetables',
                prefs.hasAutoimmune,
                (v) => notifier.updatePreference((p) => p.copyWith(hasAutoimmune: v)),
              ),

              // === THYROID & RARE ===
              _buildCategoryHeader(
                theme,
                '🦋 Thyroid & Rare Conditions',
                Colors.purple.shade400,
              ),
              _buildToggle(
                'Thyroid Condition',
                'Alert on goitrogen-containing foods',
                prefs.hasThyroidCondition,
                (v) => notifier.updatePreference((p) => p.copyWith(hasThyroidCondition: v)),
              ),
              _buildToggle(
                'PKU (Phenylketonuria)',
                'Alert on high phenylalanine foods',
                prefs.hasPKU,
                (v) => notifier.updatePreference((p) => p.copyWith(hasPKU: v)),
              ),
              _buildToggle(
                'Wilson\'s Disease',
                'Alert on high copper foods',
                prefs.hasWilsonDisease,
                (v) => notifier.updatePreference((p) => p.copyWith(hasWilsonDisease: v)),
              ),

              // === ALLERGENS ===
              _buildCategoryHeader(
                theme,
                '⚠️ Allergens',
                Colors.orange.shade600,
              ),
              _buildToggle(
                'Nut Allergy',
                'Alert on foods containing nuts',
                prefs.allergyNuts,
                (v) => notifier.updatePreference((p) => p.copyWith(allergyNuts: v)),
              ),
              _buildToggle(
                'Dairy Allergy',
                'Alert on foods containing dairy',
                prefs.allergyDairy,
                (v) => notifier.updatePreference((p) => p.copyWith(allergyDairy: v)),
              ),
              _buildToggle(
                'Gluten Intolerance',
                'Alert on foods containing gluten',
                prefs.allergyGluten,
                (v) => notifier.updatePreference((p) => p.copyWith(allergyGluten: v)),
              ),
              _buildToggle(
                'Shellfish Allergy',
                'Alert on foods containing shellfish',
                prefs.allergyShellfish,
                (v) => notifier.updatePreference((p) => p.copyWith(allergyShellfish: v)),
              ),
              _buildToggle(
                'Egg Allergy',
                'Alert on foods containing eggs',
                prefs.allergyEggs,
                (v) => notifier.updatePreference((p) => p.copyWith(allergyEggs: v)),
              ),
              _buildToggle(
                'Soy Allergy',
                'Alert on foods containing soy',
                prefs.allergySoy,
                (v) => notifier.updatePreference((p) => p.copyWith(allergySoy: v)),
              ),

              // === LIFE STAGE ===
              _buildCategoryHeader(
                theme,
                '🤰 Life Stage',
                Colors.pink.shade400,
              ),
              _buildToggle(
                'Pregnant',
                'Alert on mercury, raw foods, alcohol',
                prefs.isPregnant,
                (v) => notifier.updatePreference((p) => p.copyWith(isPregnant: v)),
              ),
              _buildToggle(
                'Breastfeeding',
                'Alert on high caffeine, alcohol',
                prefs.isBreastfeeding,
                (v) => notifier.updatePreference((p) => p.copyWith(isBreastfeeding: v)),
              ),
              _buildToggle(
                'In Recovery',
                'Alert on alcohol-containing foods',
                prefs.inRecovery,
                (v) => notifier.updatePreference((p) => p.copyWith(inRecovery: v)),
              ),

              // === MEDICATION INTERACTIONS ===
              _buildCategoryHeader(
                theme,
                '💊 Medication Interactions',
                Colors.blue.shade600,
              ),
              _buildToggle(
                'Warfarin / Blood Thinners',
                'Alert on high Vitamin K foods',
                prefs.takesWarfarin,
                (v) => notifier.updatePreference((p) => p.copyWith(takesWarfarin: v)),
              ),
              _buildToggle(
                'MAO Inhibitors',
                'Alert on high tyramine foods',
                prefs.takesMAOInhibitors,
                (v) => notifier.updatePreference((p) => p.copyWith(takesMAOInhibitors: v)),
              ),
              _buildToggle(
                'Grapefruit Interaction',
                'Alert on grapefruit-containing foods',
                prefs.hasGrapefruitInteraction,
                (v) => notifier.updatePreference((p) => p.copyWith(hasGrapefruitInteraction: v)),
              ),

              // === GENERAL WELLNESS ===
              _buildCategoryHeader(
                theme,
                '✅ General Wellness',
                Colors.teal.shade400,
              ),
              _buildToggle(
                'High Saturated Fat',
                'Warn when food exceeds 5g saturated fat',
                prefs.warnHighSaturatedFat,
                (v) => notifier.updatePreference((p) => p.copyWith(warnHighSaturatedFat: v)),
              ),
              _buildToggle(
                'High Cholesterol',
                'Warn when food exceeds 100mg cholesterol',
                prefs.warnHighCholesterol,
                (v) => notifier.updatePreference((p) => p.copyWith(warnHighCholesterol: v)),
              ),
              _buildToggle(
                'Trans Fat',
                'Warn when food contains any trans fat',
                prefs.warnHighTransFat,
                (v) => notifier.updatePreference((p) => p.copyWith(warnHighTransFat: v)),
              ),
              _buildToggle(
                'Very High Calories',
                'Warn when single item exceeds 800 kcal',
                prefs.warnVeryHighCalories,
                (v) => notifier.updatePreference((p) => p.copyWith(warnVeryHighCalories: v)),
              ),
              _buildToggle(
                'Raw/Undercooked Food',
                'Warn about food safety concerns',
                prefs.warnRawUndercooked,
                (v) => notifier.updatePreference((p) => p.copyWith(warnRawUndercooked: v)),
              ),

              const SizedBox(height: 16),

              // Reset Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: OutlinedButton.icon(
                  onPressed: () => _showResetDialog(notifier),
                  icon: const Icon(Icons.restore, size: 18),
                  label: const Text('Reset to Defaults'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(ThemeData theme, String title, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: color.withOpacity(0.1),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildToggle(
    String title,
    String subtitle,
    bool value,
    void Function(bool) onChanged,
  ) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.orange.shade600,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  void _showResetDialog(HealthAlertPreferencesNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Health Preferences?'),
        content: const Text(
          'This will reset all health conditions to their default values. '
          'Only general wellness warnings will remain enabled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Health preferences reset')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

/// My Account Card - Shows user email, logout, and export data options
class _MyAccountCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepo = ref.watch(authRepositoryProvider);
    final userEmail = authRepo.email ?? 'Not signed in';
    final displayName = authRepo.displayName;
    final photoURL = authRepo.photoURL;
    final authProvider = authRepo.authProvider;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.kaloreePurple.withOpacity(0.1),
          backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
          child: photoURL == null
              ? Icon(Icons.person, color: AppTheme.kaloreePurple)
              : null,
        ),
        title: Text(
          displayName ?? userEmail,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: displayName != null
            ? Text(userEmail, style: TextStyle(color: Colors.grey.shade600, fontSize: 12))
            : Text('Signed in with ${authProvider.capitalize()}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showAccountBottomSheet(context, ref),
      ),
    );
  }

  void _showAccountBottomSheet(BuildContext context, WidgetRef ref) {
    final authRepo = ref.read(authRepositoryProvider);
    final userEmail = authRepo.email ?? 'Not signed in';
    final displayName = authRepo.displayName;
    final photoURL = authRepo.photoURL;
    final authProvider = authRepo.authProvider;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // User Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: AppTheme.kaloreePurple.withOpacity(0.1),
              backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
              child: photoURL == null
                  ? Icon(Icons.person, size: 40, color: AppTheme.kaloreePurple)
                  : null,
            ),
            const SizedBox(height: 16),

            // Display Name
            if (displayName != null)
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

            // Email
            Text(
              userEmail,
              style: TextStyle(
                fontSize: displayName != null ? 14 : 18,
                color: displayName != null ? Colors.grey.shade600 : Colors.black,
                fontWeight: displayName != null ? FontWeight.normal : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Auth Provider Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.kaloreePurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Signed in with ${authProvider.capitalize()}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.kaloreePurple,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Export Data Button (Placeholder)
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.download, color: Colors.blue.shade600),
              ),
              title: const Text('Export Data'),
              subtitle: const Text('Download your meal history'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Coming Soon',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export feature coming soon!')),
                );
              },
            ),
            const Divider(height: 1),

            // Logout Button
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.logout, color: Colors.red.shade600),
              ),
              title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              subtitle: const Text('Sign out of your account'),
              onTap: () async {
                Navigator.pop(context); // Close bottom sheet
                _showSignOutDialog(context, ref);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out? You will need to sign in again to access your data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authRepo = ref.read(authRepositoryProvider);
              await authRepo.signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Signed out successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

/// Extension to capitalize strings
extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
