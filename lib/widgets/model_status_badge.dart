import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/model_status_provider.dart';

/// ModelStatusBadge - Compact status indicator for camera screen
///
/// Shows the current state of the on-device AI model in a small badge:
/// - 🟢 Ready: Green badge with "On-Device AI"
/// - ⬇️ Downloading: Blue badge with progress
/// - ⚡ Analyzing: Animated pulse badge
/// - ☁️ Cloud: Gray badge indicating cloud fallback
class ModelStatusBadge extends ConsumerWidget {
  final VoidCallback? onTap;
  final bool compact;

  const ModelStatusBadge({
    super.key,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(modelStatusProvider);

    return GestureDetector(
      onTap: onTap ?? () => _showStatusDialog(context, ref, status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 12,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: _getBackgroundColor(status),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _getBackgroundColor(status).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(status),
            if (!compact) ...[
              const SizedBox(width: 6),
              _buildText(status),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(ModelStatus status) {
    final iconData = _getIcon(status);
    final iconColor = _getIconColor(status);

    // Animate analyzing state
    if (status is ModelStatusAnalyzing) {
      return _PulsingIcon(icon: iconData, color: iconColor);
    }

    // Show progress indicator for downloading/loading
    if (status is ModelStatusDownloading || status is ModelStatusLoading) {
      final progress = status is ModelStatusDownloading
          ? status.progress
          : (status as ModelStatusLoading).progress;
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          value: progress > 0 ? progress : null,
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(iconColor),
        ),
      );
    }

    return Icon(iconData, size: 16, color: iconColor);
  }

  Widget _buildText(ModelStatus status) {
    return Text(
      _getShortText(status),
      style: TextStyle(
        color: _getTextColor(status),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Color _getBackgroundColor(ModelStatus status) {
    return switch (status) {
      ModelStatusReady() => Colors.green.shade50,
      ModelStatusAnalyzing() => Colors.purple.shade50,
      ModelStatusDownloading() || ModelStatusLoading() => Colors.blue.shade50,
      ModelStatusDownloaded() => Colors.teal.shade50,
      ModelStatusError() => Colors.red.shade50,
      ModelStatusCloudFallback() || ModelStatusNotSupported() => Colors.grey.shade100,
      ModelStatusNotDownloaded() => Colors.orange.shade50,
    };
  }

  Color _getIconColor(ModelStatus status) {
    return switch (status) {
      ModelStatusReady() => Colors.green.shade700,
      ModelStatusAnalyzing() => Colors.purple.shade700,
      ModelStatusDownloading() || ModelStatusLoading() => Colors.blue.shade700,
      ModelStatusDownloaded() => Colors.teal.shade700,
      ModelStatusError() => Colors.red.shade700,
      ModelStatusCloudFallback() || ModelStatusNotSupported() => Colors.grey.shade600,
      ModelStatusNotDownloaded() => Colors.orange.shade700,
    };
  }

  Color _getTextColor(ModelStatus status) {
    return _getIconColor(status);
  }

  IconData _getIcon(ModelStatus status) {
    return switch (status) {
      ModelStatusReady() => Icons.smartphone,
      ModelStatusAnalyzing() => Icons.auto_awesome,
      ModelStatusDownloading() => Icons.download,
      ModelStatusLoading() => Icons.hourglass_top,
      ModelStatusDownloaded() => Icons.check_circle_outline,
      ModelStatusError() => Icons.error_outline,
      ModelStatusCloudFallback() || ModelStatusNotSupported() => Icons.cloud,
      ModelStatusNotDownloaded() => Icons.download_for_offline,
    };
  }

  String _getShortText(ModelStatus status) {
    return switch (status) {
      ModelStatusReady() => 'On-Device AI',
      ModelStatusAnalyzing(elapsedText: var t) => 'Analyzing $t',
      ModelStatusDownloading(progressPercent: var p) => 'Downloading $p%',
      ModelStatusLoading(progressPercent: var p) => 'Loading $p%',
      ModelStatusDownloaded() => 'Tap to Load',
      ModelStatusError() => 'Error',
      ModelStatusCloudFallback() => 'Cloud AI',
      ModelStatusNotSupported() => 'Cloud AI',
      ModelStatusNotDownloaded() => 'Download AI',
    };
  }

  void _showStatusDialog(BuildContext context, WidgetRef ref, ModelStatus status) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _StatusBottomSheet(status: status),
    );
  }
}

/// Pulsing icon animation for analyzing state
class _PulsingIcon extends StatefulWidget {
  final IconData icon;
  final Color color;

  const _PulsingIcon({required this.icon, required this.color});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Icon(widget.icon, size: 16, color: widget.color),
        );
      },
    );
  }
}

/// Bottom sheet with detailed status information
class _StatusBottomSheet extends ConsumerWidget {
  final ModelStatus status;

  const _StatusBottomSheet({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Status icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getColor(status).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(status),
              size: 40,
              color: _getColor(status),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            _getTitle(status),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            _getDescription(status),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),

          // Progress bar for downloading
          if (status is ModelStatusDownloading) ...[
            const SizedBox(height: 24),
            _buildProgressBar(status as ModelStatusDownloading),
          ],

          // Action buttons
          const SizedBox(height: 24),
          _buildActions(context, ref, status),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ModelStatusDownloading status) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: status.progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              status.progressText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '~${status.estimatedTimeRemaining.inMinutes} min remaining',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref, ModelStatus status) {
    final notifier = ref.read(modelStatusProvider.notifier);

    return switch (status) {
      ModelStatusNotDownloaded() => ElevatedButton.icon(
          onPressed: () {
            notifier.startDownload();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.download),
          label: const Text('Download AI Model (365 MB)'),
        ),
      ModelStatusDownloading() => OutlinedButton.icon(
          onPressed: () {
            notifier.cancelDownload();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
          label: const Text('Cancel Download'),
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
        ),
      ModelStatusDownloaded() => ElevatedButton.icon(
          onPressed: () {
            notifier.loadModel();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text('Load Model'),
        ),
      ModelStatusError(canRetry: true) => ElevatedButton.icon(
          onPressed: () {
            notifier.retry();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      _ => TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
    };
  }

  Color _getColor(ModelStatus status) {
    return switch (status) {
      ModelStatusReady() => Colors.green.shade600,
      ModelStatusAnalyzing() => Colors.purple.shade600,
      ModelStatusDownloading() || ModelStatusLoading() => Colors.blue.shade600,
      ModelStatusDownloaded() => Colors.teal.shade600,
      ModelStatusError() => Colors.red.shade600,
      ModelStatusCloudFallback() || ModelStatusNotSupported() => Colors.grey.shade600,
      ModelStatusNotDownloaded() => Colors.orange.shade600,
    };
  }

  IconData _getIcon(ModelStatus status) {
    return switch (status) {
      ModelStatusReady() => Icons.check_circle,
      ModelStatusAnalyzing() => Icons.auto_awesome,
      ModelStatusDownloading() => Icons.download,
      ModelStatusLoading() => Icons.hourglass_top,
      ModelStatusDownloaded() => Icons.inventory_2,
      ModelStatusError() => Icons.error,
      ModelStatusCloudFallback() || ModelStatusNotSupported() => Icons.cloud,
      ModelStatusNotDownloaded() => Icons.download_for_offline,
    };
  }

  String _getTitle(ModelStatus status) {
    return switch (status) {
      ModelStatusReady() => 'On-Device AI Ready',
      ModelStatusAnalyzing() => 'Analyzing...',
      ModelStatusDownloading() => 'Downloading Model',
      ModelStatusLoading() => 'Loading Model',
      ModelStatusDownloaded() => 'Model Downloaded',
      ModelStatusError(message: var m) => 'Error',
      ModelStatusCloudFallback() => 'Using Cloud AI',
      ModelStatusNotSupported() => 'Cloud AI Mode',
      ModelStatusNotDownloaded() => 'Download AI Model',
    };
  }

  String _getDescription(ModelStatus status) {
    return switch (status) {
      ModelStatusReady() =>
        'All food analysis happens privately on your device. No internet required.',
      ModelStatusAnalyzing() =>
        'SmolVLM is analyzing your food image...',
      ModelStatusDownloading() =>
        'Downloading the AI model for offline food analysis. You can use cloud AI in the meantime.',
      ModelStatusLoading() =>
        'Loading the model into memory. This takes a few seconds.',
      ModelStatusDownloaded() =>
        'The AI model is downloaded. Tap to load it into memory for instant analysis.',
      ModelStatusError(message: var m) => m,
      ModelStatusCloudFallback(reason: var r) => r,
      ModelStatusNotSupported() =>
        'On-device AI is not available on iOS. Using Google Gemini for food analysis.',
      ModelStatusNotDownloaded() =>
        'Download the 365 MB AI model for private, offline food analysis. No API key required!',
    };
  }
}

/// Overlay shown during food analysis
class AnalysisOverlay extends ConsumerWidget {
  final VoidCallback? onCancel;

  const AnalysisOverlay({super.key, this.onCancel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(modelStatusProvider);

    if (status is! ModelStatusAnalyzing) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  'Analyzing Food...',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  status.elapsedText,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Processing on-device',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                if (onCancel != null) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
