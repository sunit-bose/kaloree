import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../services/llm_service.dart';
import '../../services/secure_storage_service.dart';
import '../../services/mlkit_food_detector.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../search/search_screen.dart';
import '../favorites/favorites_screen.dart';
import 'image_preview_screen.dart';

/// Camera screen - Primary home view
/// Opens with camera ready for meal capture
/// Toggle between AI analysis and manual search
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false; // Capturing image
  bool _isAnalyzing = false; // Analyzing with ML Kit + LLM
  FlashMode _flashMode = FlashMode.auto;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() => _error = 'No camera available');
        return;
      }

      final camera = _cameras!.first;
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false, // No audio permission needed
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      await _controller!.setFlashMode(_flashMode);

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _error = null;
        });
      }
    } catch (e) {
      // Handle platform-specific camera errors
      String errorMessage = 'Camera not supported on this platform';
      if (e.toString().contains('MissingPluginException')) {
        errorMessage = 'Camera not available on desktop. Use mobile device or search manually.';
      } else if (e.toString().contains('camera')) {
        errorMessage = 'Camera access denied or not available';
      } else {
        errorMessage = 'Camera error: $e';
      }

      setState(() => _error = errorMessage);
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() {
      switch (_flashMode) {
        case FlashMode.off:
          _flashMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          _flashMode = FlashMode.always;
          break;
        case FlashMode.always:
          _flashMode = FlashMode.off;
          break;
        case FlashMode.torch:
          _flashMode = FlashMode.off;
          break;
      }
    });

    await _controller!.setFlashMode(_flashMode);
  }

  IconData get _flashIcon {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.flashlight_on;
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (_controller == null || !_controller!.value.isInitialized || _isCapturing) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      // Capture image
      final XFile imageFile = await _controller!.takePicture();

      // Reset flash to off after taking picture
      if (_flashMode != FlashMode.off) {
        _flashMode = FlashMode.off;
        await _controller!.setFlashMode(FlashMode.off);
      }

      // Read image bytes into memory
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // IMPORTANT: Delete the temporary file immediately after reading
      // This ensures photos are processed in memory only and never stored
      try {
        final tempFile = File(imageFile.path);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (e) {
        // Ignore deletion errors - file may already be cleaned up
        debugPrint('Note: Could not delete temp file: $e');
      }

      setState(() => _isCapturing = false);

      // Show preview screen - analysis starts ONLY when user clicks "Continue"
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImagePreviewScreen(
              imageBytes: imageBytes,
              onRetake: () {},
              onContinue: () => _processImage(imageBytes),
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to capture image: $e');
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _processImage(Uint8List imageBytes) async {
    setState(() => _isAnalyzing = true);

    try {
      // Step 1: Check API configuration FIRST
      final secureStorage = ref.read(secureStorageProvider);
      final isConfigured = await secureStorage.isConfigured();
      final selectedProvider = await secureStorage.getSelectedProvider();
      final activeKey = await secureStorage.getActiveApiKey();
      
      print('🔑 DEBUG: API configured: $isConfigured');
      print('🔑 DEBUG: Selected provider: ${selectedProvider.name}');
      print('🔑 DEBUG: Has active key: ${activeKey != null && activeKey.isNotEmpty}');

      if (!isConfigured) {
        setState(() => _isAnalyzing = false);
        print('⚠️ DEBUG: Showing API key dialog');
        _showApiKeyDialog();
        return;
      }

      print('✅ DEBUG: API configured, proceeding with food detection');

      // Step 2: ML Kit pre-screening (fast, on-device, free)
      final mlKitDetector = ref.read(mlKitFoodDetectorProvider);
      final isFoodDetected = await mlKitDetector.isFoodImage(imageBytes);

      print('🔍 DEBUG: Food detected by ML Kit: $isFoodDetected');

      if (!isFoodDetected) {
        // ML Kit determined this is NOT food - skip LLM call
        setState(() => _isAnalyzing = false);
        _showNotFoodDialog();
        return;
      }

      print('✅ DEBUG: Proceeding with LLM analysis');

      // Step 3: Send to LLM for detailed nutritional analysis
      final llmService = ref.read(llmServiceProvider);
      final analysis = await llmService.analyzeMealImage(imageBytes);

      if (mounted) {
        // Navigate to meal info screen with results
        AppNavigator.toMealInfo(context, analysis);
      }
    } on LLMException catch (e) {
      if (e.message == 'NOT_FOOD') {
        // LLM also detected non-food (secondary check)
        setState(() => _isAnalyzing = false);
        _showNotFoodDialog();
      } else {
        _showError(e.message);
        setState(() => _isAnalyzing = false);
      }
    } catch (e) {
      _showError('Failed to process image: $e');
      setState(() => _isAnalyzing = false);
    } finally {
      if (mounted && _isAnalyzing) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  void _showNotFoodDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Not a valid image'),
        content: const Text('The image doesn\'t appear to contain food. Would you like to try again?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to search/manual entry
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            child: const Text('Add Manually'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Stay on camera to retry
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showApiKeyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Analysis Unavailable'),
        content: const Text(
          'To use AI meal analysis, please configure your API key in Settings.\n\n'
          'You can still manually search for foods using the Search button above.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to search
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            child: const Text('Use Search'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to settings screen
              AppNavigator.toSettings(context);
            },
            child: const Text('Configure API'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview
            if (_isInitialized && _controller != null)
              Positioned.fill(
                child: ClipRRect(
                  child: CameraPreview(_controller!),
                ),
              )
            else if (_error != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: TextStyle(color: Colors.grey.shade400),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _initializeCamera,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else
              Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              ),

            // Top bar with branding, mode toggle and flash
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Flash toggle button
                  if (_isInitialized)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _toggleFlash,
                        icon: Icon(_flashIcon, color: Colors.white),
                        tooltip: 'Flash: ${_flashMode.name}',
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  
                  // App Branding
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGradient.colors[0].withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo image with fallback to emoji
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Image.asset(
                            'assets/images/kaloree_app_logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Text('🔥', style: TextStyle(fontSize: 20));
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Kaloree',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Empty space to balance the layout
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Instructions
            Positioned(
              top: 80,
              left: 16,
              right: 16,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    '📸 Point at your meal • AI will identify items ✨',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // Bottom capture button with gradient glow
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _isCapturing ? null : _captureAndAnalyze,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _isCapturing
                          ? null
                          : AppTheme.primaryGradient,
                      color: _isCapturing ? Colors.grey : null,
                      boxShadow: _isCapturing
                          ? null
                          : [
                              BoxShadow(
                                color: AppTheme.primaryGradient.colors[0].withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                    ),
                    child: _isCapturing
                        ? const Center(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 36,
                          ),
                  ),
                ),
              ),
            ),

            // Favorites button - Positioned to the left of camera button
            Positioned(
              bottom: 50,
              left: 40,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                  );
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFF6B6B), // Light red
                        Color(0xFFEE5A5A), // Red
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEE5A5A).withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
            
            // Search button - Positioned to the right of camera button
            Positioned(
              bottom: 50,
              right: 40,
              child: GestureDetector(
                onTap: () => AppNavigator.toSearch(context),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.flameGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.flameOrange.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),

            // Analyzing overlay (only shown AFTER user confirms on preview)
            if (_isAnalyzing)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 24),
                        Text(
                          'Analyzing your meal... ✨',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Step 1: Food detection 🔍',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
