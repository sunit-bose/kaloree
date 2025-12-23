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
          padding: const EdgeInsets.all(24),
          child: Image.asset(
            'assets/images/kaloree_logo.png',
            width: 180,
          ),
        ),
      ),
    );
  }
}
