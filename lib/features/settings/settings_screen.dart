import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/secure_storage_service.dart';
import '../../services/database_service.dart';
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
          Text('🎯 Daily Goals', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Set your daily nutrition targets.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
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
  bool _hasGroqKey = false;

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
    final hasGroqKey = await storage.hasGroqApiKey();
    setState(() {
      _selectedProvider = provider;
      _hasClaudeKey = hasClaudeKey;
      _hasGeminiKey = hasGeminiKey;
      _hasGroqKey = hasGroqKey;
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
              provider == LLMProvider.gemini ? 'Get your key from makersuite.google.com' :
              'Get your free API key from console.groq.com',
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
                    hintText: provider == LLMProvider.claude ? 'sk-ant-...' :
                             provider == LLMProvider.groq ? 'gsk_...' : 'AI...',
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
              } else if (provider == LLMProvider.gemini) {
                await storage.setGeminiApiKey(key);
              } else {
                await storage.setGroqApiKey(key);
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
              final isSelected = _selectedProvider == provider;
              final hasKey = provider == LLMProvider.claude ? _hasClaudeKey :
                            provider == LLMProvider.gemini ? _hasGeminiKey : _hasGroqKey;
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_selectedProvider == LLMProvider.claude ? _hasClaudeKey :
                       _selectedProvider == LLMProvider.gemini ? _hasGeminiKey : _hasGroqKey) ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    (_selectedProvider == LLMProvider.claude ? _hasClaudeKey :
                     _selectedProvider == LLMProvider.gemini ? _hasGeminiKey : _hasGroqKey) ? Icons.check_circle : Icons.warning,
                    color: (_selectedProvider == LLMProvider.claude ? _hasClaudeKey :
                           _selectedProvider == LLMProvider.gemini ? _hasGeminiKey : _hasGroqKey) ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      (_selectedProvider == LLMProvider.claude ? _hasClaudeKey :
                       _selectedProvider == LLMProvider.gemini ? _hasGeminiKey : _hasGroqKey) ? 'Ready to analyze meals' : 'Add an API key to enable AI analysis',
                      style: TextStyle(color: (_selectedProvider == LLMProvider.claude ? _hasClaudeKey :
                                             _selectedProvider == LLMProvider.gemini ? _hasGeminiKey : _hasGroqKey) ? Colors.green.shade700 : Colors.orange.shade700),
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calorieController = TextEditingController();
    _proteinController = TextEditingController();
    _carbsController = TextEditingController();
    _fatController = TextEditingController();
    _loadGoals();
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
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
          children: [
            TextField(controller: _calorieController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Daily Calories', suffixText: 'kcal')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextField(controller: _proteinController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Protein', suffixText: 'g'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _carbsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Carbs', suffixText: 'g'))),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _fatController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fat', suffixText: 'g'))),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saveGoals, child: const Text('Save Goals'))),
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
