import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/theme.dart';
import 'services/database_service.dart';
import 'widgets/main_scaffold.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'app_boot_controller.dart';

/// Main entry point
/// 
/// CRITICAL: Initialization order matters!
/// 1. WidgetsFlutterBinding.ensureInitialized()
/// 2. Firebase.initializeApp() - MUST be before runApp
/// 3. ProviderScope wrapper
/// 4. All other initialization handled inside AppBootController
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock to portrait mode for consistent camera experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Set system UI overlay style - Force light mode Gen Z style!
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFFFFFFF), // Pure white background
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize Firebase Core BEFORE runApp for timing reliability
  // Note: FirebaseInitializer in boot controller will detect this
  // and skip re-initialization (checks Firebase.apps.isNotEmpty)
  await Firebase.initializeApp();
  
  // Initialize SQLite database
  final database = AppDatabase();
  await database.initializeDefaultData();
  
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: const KaloreeApp(),
    ),
  );
}

/// Main app widget
class KaloreeApp extends ConsumerStatefulWidget {
  const KaloreeApp({super.key});

  @override
  ConsumerState<KaloreeApp> createState() => _KaloreeAppState();
}

class _KaloreeAppState extends ConsumerState<KaloreeApp> {
  @override
  void initState() {
    super.initState();
    // Start the boot sequence after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startBoot();
    });
  }

  Future<void> _startBoot() async {
    // Start the boot controller
    final bootController = ref.read(appBootControllerProvider.notifier);
    await bootController.boot();
  }

  @override
  Widget build(BuildContext context) {
    final bootState = ref.watch(appBootControllerProvider);
    
    return MaterialApp(
      title: 'Kaloree',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light, // 🌟 Force light mode - Gen Z vibes only!
      home: bootState.when(
        loading: () => const SplashScreen(),
        error: (error, stack) => _BootErrorScreen(
          error: error.toString(),
          onRetry: () {
            ref.read(appBootControllerProvider.notifier).retry();
          },
        ),
        data: (progress) {
          if (progress.isLoading) {
            return _BootLoadingScreen(progress: progress);
          }
          if (progress.isFailed) {
            return _BootErrorScreen(
              error: progress.error ?? 'Unknown error',
              onRetry: () {
                ref.read(appBootControllerProvider.notifier).retry();
              },
            );
          }
          // Boot complete - show auth gate
          return const AuthGate(
            child: MainScaffold(),
          );
        },
      ),
    );
  }
}

/// Boot loading screen with progress
class _BootLoadingScreen extends StatelessWidget {
  final BootProgress progress;

  const _BootLoadingScreen({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.flameOrange.withOpacity(0.4),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/kaloree_app_logo.png',
                  width: 120,
                  height: 120,
                  errorBuilder: (context, error, stackTrace) {
                    return ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.flameGradient.createShader(bounds),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        size: 80,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // App Name
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
              
              const Spacer(),
              
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress.progress,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.flameOrange,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      progress.message,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Boot error screen
class _BootErrorScreen extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _BootErrorScreen({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.kaloreePurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
