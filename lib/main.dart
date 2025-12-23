import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/theme.dart';
import 'services/database_service.dart';
import 'widgets/main_scaffold.dart';
import 'features/splash/splash_screen.dart';

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
  
  // Initialize database
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

class KaloreeApp extends StatefulWidget {
  const KaloreeApp({super.key});

  @override
  State<KaloreeApp> createState() => _KaloreeAppState();
}

class _KaloreeAppState extends State<KaloreeApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash screen for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kaloree',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light, // 🌟 Force light mode - Gen Z vibes only!
      home: _isInitialized ? const MainScaffold() : const SplashScreen(),
    );
  }
}
