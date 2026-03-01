import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../app/theme.dart';

/// Splash Screen - Shows app logo with animated brand gradients
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient (purple)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
          ),

          // Animated glow effect
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Positioned(
                top: size.height * 0.3,
                left: size.width * 0.1,
                right: size.width * 0.1,
                child: Opacity(
                  opacity: _glowAnimation.value * 0.6,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.flameOrange.withAlpha(100),
                          AppTheme.flamePink.withAlpha(50),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Decorative wave lines
          Positioned(
            bottom: size.height * 0.15,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _glowAnimation.value * 0.4,
                  child: CustomPaint(
                    size: Size(size.width, 100),
                    painter: _WavePainter(),
                  ),
                );
              },
            ),
          ),

          // Center content
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Flame logo with glow
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.flameOrange.withAlpha(
                                  (80 * _glowAnimation.value).round(),
                                ),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                              BoxShadow(
                                color: AppTheme.flamePink.withAlpha(
                                  (60 * _glowAnimation.value).round(),
                                ),
                                blurRadius: 60,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/kaloree_logo.png',
                              width: 140,
                              height: 140,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to flame icon if image not found
                                return ShaderMask(
                                  shaderCallback: (bounds) => AppTheme
                                      .flameGradient
                                      .createShader(bounds),
                                  child: const Icon(
                                    Icons.local_fire_department_rounded,
                                    size: 100,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // App name with gradient text
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppTheme.textGradient.createShader(bounds),
                          blendMode: BlendMode.srcIn,
                          child: const Text(
                            'Kaloree',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.5,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Tagline
                        Opacity(
                          opacity: _glowAnimation.value,
                          child: Text(
                            'AI-Powered Calorie Tracking',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withAlpha(180),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom glow accent
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppTheme.flameMagenta.withAlpha(
                          (40 * _glowAnimation.value).round(),
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Loading indicator at bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _glowAnimation.value,
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.flameOrange,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for decorative wave lines
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppTheme.flameOrange.withAlpha(100),
          AppTheme.flamePink.withAlpha(80),
          AppTheme.flameMagenta.withAlpha(60),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final waveHeight = 15.0;
    final waveLength = size.width / 3;

    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height / 2 +
          math.sin((x / waveLength) * 2 * math.pi) * waveHeight;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Second wave (offset)
    final path2 = Path();
    path2.moveTo(0, size.height / 2 + 20);

    for (double x = 0; x <= size.width; x += 1) {
      final y = size.height / 2 +
          20 +
          math.sin((x / waveLength) * 2 * math.pi + math.pi / 3) *
              (waveHeight * 0.7);
      path2.lineTo(x, y);
    }

    paint.strokeWidth = 1.0;
    paint.shader = LinearGradient(
      colors: [
        AppTheme.flamePink.withAlpha(60),
        AppTheme.flameMagenta.withAlpha(40),
      ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
