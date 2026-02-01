import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../services/llm_service.dart';
import '../../services/secure_storage_service.dart';
import '../../services/mlkit_food_detector.dart';
import '../../services/nutrition_label_scanner.dart';
import '../../models/meal_analysis.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../search/search_screen.dart';
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
  Uint8List? _capturedImageBytes; // Store captured image for preview
  bool _isCameraMode = true; // Toggle between camera and search mode

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

      // IMPORTANT: Delete the temporary file immediately
      // We only keep the bytes in memory for the API call
      await imageFile.saveTo('/dev/null').catchError((_) {});

      setState(() {
        _capturedImageBytes = imageBytes;
        _isCapturing = false;
      });

      // Show preview screen - analysis starts ONLY when user clicks "Continue"
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImagePreviewScreen(
              imageBytes: imageBytes,
              onRetake: () {
                setState(() => _capturedImageBytes = null);
              },
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

      // Step 2: ML Kit pre-screening for food (fast, on-device, free)
      final mlKitDetector = ref.read(mlKitFoodDetectorProvider);
      final isFoodDetected = await mlKitDetector.isFoodImage(imageBytes);

      print('🔍 DEBUG: Food detected by ML Kit: $isFoodDetected');

      if (!isFoodDetected) {
        // Step 3: Not food - check if it's a nutrition label
        print('🏷️ DEBUG: Checking for nutrition label...');
        final nutritionScanner = ref.read(nutritionLabelScannerProvider);
        final isNutritionLabel = await nutritionScanner.isNutritionLabel(imageBytes);

        print('🏷️ DEBUG: Nutrition label detected: $isNutritionLabel');

        if (isNutritionLabel) {
          // Extract nutrition information from label
          print('📊 DEBUG: Extracting nutrition info from label...');
          try {
            final analysis = await nutritionScanner.extractNutritionInfo(imageBytes);

            if (analysis != null && mounted) {
              setState(() => _isAnalyzing = false);
              // Navigate to meal info screen with nutrition label data
              AppNavigator.toMealInfo(context, analysis);
              return;
            } else {
              setState(() => _isAnalyzing = false);
              _showError('Could not extract nutrition information from label. Please try again or enter manually.');
              return;
            }
          } catch (e) {
            if (e.toString().contains('MULTI_COLUMN_NOT_SUPPORTED')) {
              setState(() => _isAnalyzing = false);
              _showMultiColumnNotSupportedDialog();
              return;
            } else {
              setState(() => _isAnalyzing = false);
              _showError('Failed to parse nutrition label: $e');
              return;
            }
          }
        }

        // Not food and not nutrition label - show error
        setState(() => _isAnalyzing = false);
        _showNotFoodDialog();
        return;
      }

      print('✅ DEBUG: Proceeding with LLM analysis for food image');

      // Step 4: IS food - send to LLM for detailed nutritional analysis
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

  void _showMultiColumnNotSupportedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Multi-Column Label'),
        content: const Text(
          'This appears to be a nutrition label with multiple columns (e.g., "Per Serving" and "Per 100g").\n\n'
          'Currently, only single-column labels are supported. Please enter the nutrition information manually.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Stay on camera to retry with different label
            },
            child: const Text('Retry'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to search/manual entry
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            child: const Text('Add Manually'),
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
        child: Column(
          children: [
            // Simple logo at top
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  height: 50,
                  child: Image.asset(
                    'assets/images/kaloree_app_logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('🔥 Kaloree', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700));
                    },
                  ),
                ),
              ),
            ),

            // Camera frame
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Stack(
                  children: [
                    // Camera preview with rounded corners
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppTheme.primaryGradient.colors[0],
                            width: 3,
                          ),
                        ),
                        child: _isInitialized && _controller != null
                            ? CameraPreview(_controller!)
                            : _error != null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
                                        const SizedBox(height: 16),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 32),
                                          child: Text(
                                            _error!,
                                            style: TextStyle(color: Colors.grey.shade400),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        ElevatedButton(
                                          onPressed: _initializeCamera,
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    ),
                                  )
                                : Center(
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                      ),
                    ),

                    // Flash toggle inside camera frame (top-left)
                    if (_isInitialized && _isCameraMode)
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _toggleFlash,
                            icon: Icon(_flashIcon, color: Colors.white, size: 24),
                            tooltip: 'Flash: ${_flashMode.name}',
                          ),
                        ),
                      ),

                    // Instructions overlay
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.black.withOpacity(0.4),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            '📸 Scan meals or 🏷️ nutrition labels',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Mode toggle slider (Camera/Search)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade200, Colors.grey.shade100],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Animated sliding indicator
                    AnimatedAlign(
                      alignment: _isCameraMode ? Alignment.centerLeft : Alignment.centerRight,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2 - 44,
                        height: 48,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!_isCameraMode) {
                                setState(() => _isCameraMode = true);
                              } else if (!_isCapturing) {
                                _captureAndAnalyze();
                              }
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      color: _isCameraMode ? AppTheme.primaryGradient.colors[0] : Colors.grey.shade600,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Camera',
                                      style: TextStyle(
                                        color: _isCameraMode ? AppTheme.primaryGradient.colors[0] : Colors.grey.shade600,
                                        fontWeight: _isCameraMode ? FontWeight.w700 : FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_isCameraMode) {
                                setState(() => _isCameraMode = false);
                              } else {
                                AppNavigator.toSearch(context);
                              }
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search,
                                      color: !_isCameraMode ? AppTheme.flameOrange : Colors.grey.shade600,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Search',
                                      style: TextStyle(
                                        color: !_isCameraMode ? AppTheme.flameOrange : Colors.grey.shade600,
                                        fontWeight: !_isCameraMode ? FontWeight.w700 : FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Analyzing overlay
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
