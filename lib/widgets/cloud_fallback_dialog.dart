import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/router.dart';
import '../services/model_status_provider.dart';

/// Dialog shown when model download fails after retries
/// Asks user for consent to use cloud API instead
class CloudFallbackDialog extends ConsumerWidget {
  const CloudFallbackDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CloudFallbackDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.cloud_off, color: theme.colorScheme.error, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'AI Model Download Failed',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Unable to download the on-device AI model after multiple attempts.',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Would you like to use Cloud AI instead?',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '• Requires internet connection\n'
                  '• Food images sent to Google AI for analysis\n'
                  '• You\'ll need to add an API key in Settings',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You can retry downloading the on-device model anytime from Settings.',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            // User wants to retry later - stays in downloadFailed state
            // They can retry from settings
          },
          child: const Text('Retry Later'),
        ),
        FilledButton(
          onPressed: () {
            // User consents to cloud fallback
            ref.read(modelStatusProvider.notifier).enableCloudFallback();
            Navigator.pop(context);
            // Navigate to settings to configure API key
            AppNavigator.toSettings(context);
          },
          child: const Text('Use Cloud AI'),
        ),
      ],
    );
  }
}

/// Show the cloud fallback dialog from anywhere
void showCloudFallbackDialog(BuildContext context) {
  CloudFallbackDialog.show(context);
}
