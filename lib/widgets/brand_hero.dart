import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Reusable Kaloree brand hero widget displaying logo and app name
/// 
/// Used in:
/// - BootLoadingScreen (main.dart)
/// - LoginScreen (auth_gate.dart)
class KaloreeBrandHero extends StatelessWidget {
  /// Size of the logo image/icon (default: 120)
  final double logoSize;
  
  /// Font size for "Kaloree" text (default: 48)
  final double fontSize;
  
  /// Whether to show the glowing shadow effect (default: true)
  final bool showGlow;

  const KaloreeBrandHero({
    super.key,
    this.logoSize = 120,
    this.fontSize = 48,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo with glow
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: showGlow
                ? [
                    BoxShadow(
                      color: AppTheme.flameOrange.withValues(alpha: 0.4),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Image.asset(
            'assets/images/kaloree_app_logo.png',
            width: logoSize,
            height: logoSize,
            errorBuilder: (context, error, stackTrace) {
              return ShaderMask(
                shaderCallback: (bounds) =>
                    AppTheme.flameGradient.createShader(bounds),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  size: logoSize * 0.67,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        // App Name with gradient
        ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.textGradient.createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(
            'Kaloree',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
