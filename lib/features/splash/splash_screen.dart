import 'package:flutter/material.dart';
import '../../app/theme.dart';

/// Splash Screen - Shows app logo while initializing
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kaloreePurple,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Image.asset(
            'assets/images/kaloree_logo.png',
            // Let the image maintain its aspect ratio
            // The logo will scale to fit width while preserving proportions
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
