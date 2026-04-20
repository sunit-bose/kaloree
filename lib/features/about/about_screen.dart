import 'package:flutter/material.dart';
import '../../app/theme.dart';

/// About Screen - Shows app info, version, credits
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // App Logo and Name
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.kaloreePurple.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/images/kaloree_app_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text('🔥', style: TextStyle(fontSize: 50)),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ShaderMask(
                  shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                  child: const Text(
                    'Kaloree',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'AI-Powered Calorie Tracking',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.kaloreePurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: AppTheme.kaloreePurple,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Features Section
          _SectionTitle(title: '✨ Features'),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.camera_alt,
            color: Colors.purple,
            title: 'AI Meal Analysis',
            description: 'Point your camera at any meal and get instant nutritional breakdown',
          ),
          _FeatureCard(
            icon: Icons.search,
            color: Colors.orange,
            title: 'Food Database',
            description: 'Search from thousands of Indian foods with accurate nutrition data',
          ),
          _FeatureCard(
            icon: Icons.insights,
            color: Colors.blue,
            title: 'Smart Analytics',
            description: 'Track your progress with beautiful charts and insights',
          ),
          _FeatureCard(
            icon: Icons.lock,
            color: Colors.green,
            title: 'Privacy First',
            description: 'Your data stays on your device. No tracking, no ads.',
          ),
          const SizedBox(height: 32),

          // Technology Section
          _SectionTitle(title: '🛠️ Powered By'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _TechItem(
                    label: 'AI Vision',
                    value: 'Claude AI / Gemini',
                    icon: Icons.auto_awesome,
                    color: Colors.purple,
                  ),
                  const Divider(height: 20),
                  _TechItem(
                    label: 'Framework',
                    value: 'Flutter',
                    icon: Icons.flutter_dash,
                    color: Colors.blue,
                  ),
                  const Divider(height: 20),
                  _TechItem(
                    label: 'Food Detection',
                    value: 'Google ML Kit',
                    icon: Icons.visibility,
                    color: Colors.green,
                  ),
                  const Divider(height: 20),
                  _TechItem(
                    label: 'Local Storage',
                    value: 'SQLite (Drift)',
                    icon: Icons.storage,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Credits Section
          _SectionTitle(title: '❤️ Credits'),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Made with love for healthy eating',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kaloree was built to make calorie tracking simple, '
                    'private, and powered by cutting-edge AI technology.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.food_bank, color: Colors.amber.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Food data: IFCT (Indian Food Composition Tables)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Footer
          Center(
            child: Column(
              children: [
                const Text(
                  '🇮🇳 Made in India',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2024 Kaloree',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
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

class _TechItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _TechItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
