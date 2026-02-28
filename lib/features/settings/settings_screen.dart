import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/secure_storage_service.dart';
import '../../services/database_service.dart';
import '../../services/tdee_calculator.dart';
import '../../models/meal_analysis.dart';

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
          Text('🤖 AI Configuration', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Add your own API key to enable AI meal analysis. Keys are stored securely on your device.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          _ApiConfigCard(),

          const SizedBox(height: 32),
          Text('👤 Your Profile', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Enter your details to calculate personalized nutrition goals using the Mifflin-St Jeor equation.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          _ProfileCard(),

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
                  _PrivacyItem(icon: Icons.key_outlined, iconColor: Colors.purple.shade400, title: 'API Keys', description: 'Encrypted using Android Keystore'),
                  const Divider(height: 24),
                  _PrivacyItem(icon: Icons.wifi_outlined, iconColor: Colors.orange.shade400, title: 'Network', description: 'Only connects to Claude/Gemini APIs (HTTPS)'),
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

class _ApiConfigCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ApiConfigCard> createState() => _ApiConfigCardState();
}

class _ApiConfigCardState extends ConsumerState<_ApiConfigCard> {
  LLMProvider _selectedProvider = LLMProvider.claude;
  bool _isLoading = true;
  bool _hasClaudeKey = false;
  bool _hasGeminiKey = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final storage = ref.read(secureStorageProvider);
    final provider = await storage.getSelectedProvider();
    final hasClaudeKey = await storage.hasClaudeApiKey();
    final hasGeminiKey = await storage.hasGeminiApiKey();
    setState(() {
      _selectedProvider = provider;
      _hasClaudeKey = hasClaudeKey;
      _hasGeminiKey = hasGeminiKey;
      _isLoading = false;
    });
  }

  Future<void> _setProvider(LLMProvider provider) async {
    await ref.read(secureStorageProvider).setSelectedProvider(provider);
    setState(() => _selectedProvider = provider);
  }

  void _showApiKeyDialog(LLMProvider provider) {
    final controller = TextEditingController();
    final isObscured = ValueNotifier(true);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${provider.displayName} API Key'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider == LLMProvider.claude ? 'Get your key from console.anthropic.com' :
              'Get your key from makersuite.google.com',
              style: Theme.of(context).textTheme.bodySmall,
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
                    hintText: provider == LLMProvider.claude ? 'sk-ant-...' : 'AI...',
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
          ElevatedButton(
            onPressed: () async {
              final key = controller.text.trim();
              if (key.isEmpty) return;
              final storage = ref.read(secureStorageProvider);
              if (provider == LLMProvider.claude) {
                await storage.setClaudeApiKey(key);
              } else {
                await storage.setGeminiApiKey(key);
              }
              Navigator.pop(context);
              await _loadConfig();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('API key saved securely')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) return const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Provider', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ...LLMProvider.values.map((provider) {
              final hasKey = provider == LLMProvider.claude ? _hasClaudeKey : _hasGeminiKey;
              return RadioListTile<LLMProvider>(
                title: Text(provider.displayName),
                subtitle: Text(hasKey ? 'API key configured ✓' : 'No API key'),
                value: provider,
                groupValue: _selectedProvider,
                onChanged: (value) { if (value != null) _setProvider(value); },
                secondary: IconButton(icon: Icon(hasKey ? Icons.edit : Icons.add), onPressed: () => _showApiKeyDialog(provider)),
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final hasKey = _selectedProvider == LLMProvider.claude ? _hasClaudeKey : _hasGeminiKey;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: hasKey ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasKey ? Icons.check_circle : Icons.warning,
                        color: hasKey ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hasKey ? 'Ready to analyze meals' : 'Add an API key to enable AI analysis',
                          style: TextStyle(color: hasKey ? Colors.green.shade700 : Colors.orange.shade700),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
      _fiberController.text = '25'; // Default fiber goal
      _isLoading = false;
    });
  }

  Future<void> _saveGoals() async {
    final goals = DailyGoals(
      calorieGoal: int.tryParse(_calorieController.text) ?? 2000,
      proteinGoal: double.tryParse(_proteinController.text) ?? 60,
      carbsGoal: double.tryParse(_carbsController.text) ?? 250,
      fatGoal: double.tryParse(_fatController.text) ?? 65,
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
