import 'package:flutter/material.dart';
import '../models/health_alert.dart';
import '../app/theme.dart';
import 'health_alert_card.dart';

/// Dialog for viewing and dismissing health alerts before saving a meal
/// 
/// Shows all active alerts and allows users to:
/// - View details of each alert
/// - Dismiss individual alerts with optional reason
/// - Dismiss all alerts at once
/// - Proceed to save with or without dismissing
class HealthAlertsDialog extends StatefulWidget {
  final List<HealthAlert> alerts;
  final String mealName;
  final VoidCallback onSaveAnyway;
  final Function(List<HealthAlert>) onAlertsUpdated;

  const HealthAlertsDialog({
    super.key,
    required this.alerts,
    required this.mealName,
    required this.onSaveAnyway,
    required this.onAlertsUpdated,
  });

  /// Show the dialog and return true if user wants to save
  static Future<bool?> show({
    required BuildContext context,
    required List<HealthAlert> alerts,
    required String mealName,
    required Function(List<HealthAlert>) onAlertsUpdated,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HealthAlertsDialog(
        alerts: alerts,
        mealName: mealName,
        onSaveAnyway: () => Navigator.of(context).pop(true),
        onAlertsUpdated: onAlertsUpdated,
      ),
    );
  }

  @override
  State<HealthAlertsDialog> createState() => _HealthAlertsDialogState();
}

class _HealthAlertsDialogState extends State<HealthAlertsDialog> {
  late List<HealthAlert> _alerts;

  @override
  void initState() {
    super.initState();
    _alerts = List.from(widget.alerts);
  }

  int get _activeCount => _alerts.where((a) => !a.isDismissed).length;
  int get _criticalCount =>
      _alerts.where((a) => !a.isDismissed && a.isCritical).length;

  void _dismissAlert(int index, {String? reason}) {
    setState(() {
      _alerts[index].dismiss(reason: reason);
    });
    widget.onAlertsUpdated(_alerts);
  }

  void _dismissAllAlerts({String? reason}) {
    setState(() {
      for (final alert in _alerts) {
        if (!alert.isDismissed) {
          alert.dismiss(reason: reason);
        }
      }
    });
    widget.onAlertsUpdated(_alerts);
  }

  void _showDismissReasonSheet(int alertIndex) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _DismissReasonSheet(
        alert: _alerts[alertIndex],
        onDismiss: (reason) {
          _dismissAlert(alertIndex, reason: reason);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCritical = _criticalCount > 0;
    final headerColor =
        hasCritical ? const Color(0xFFDC2626) : const Color(0xFFCA8A04);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: headerColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    hasCritical ? Icons.warning_rounded : Icons.info_rounded,
                    color: headerColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Alerts',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _activeCount == 0
                            ? 'All alerts dismissed'
                            : '$_activeCount alert${_activeCount > 1 ? 's' : ''} for ${widget.mealName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_activeCount > 1)
                  TextButton(
                    onPressed: () => _showDismissAllSheet(),
                    child: const Text('Dismiss All'),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Alerts list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                return HealthAlertCard(
                  alert: alert,
                  onDismiss: () => _showDismissReasonSheet(index),
                  onTap: () => _showAlertDetails(alert),
                );
              },
            ),
          ),

          // Disclaimer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                Icon(
                  Icons.medical_information_outlined,
                  size: 18,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'For educational purposes only. Not medical advice.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: widget.onSaveAnyway,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _activeCount > 0 && hasCritical
                            ? headerColor
                            : AppTheme.kaloreePurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _activeCount == 0
                            ? 'Save Meal'
                            : 'Save Anyway',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDismissAllSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _DismissReasonSheet(
        alert: null, // null means dismiss all
        onDismiss: (reason) {
          _dismissAllAlerts(reason: reason);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showAlertDetails(HealthAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(
              alert.severity.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                alert.type.displayName,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alert.message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            if (alert.details != null) ...[
              const SizedBox(height: 12),
              Text(
                alert.details!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            if (alert.value != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.analytics_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Value: ${alert.displayValue}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Food: ${alert.foodItemName}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for selecting dismissal reason
class _DismissReasonSheet extends StatelessWidget {
  final HealthAlert? alert; // null means dismiss all
  final Function(String?) onDismiss;

  const _DismissReasonSheet({
    required this.alert,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isAll = alert == null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAll ? 'Dismiss All Alerts' : 'Dismiss Alert',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAll
                  ? 'Why are you dismissing all alerts?'
                  : 'Why are you dismissing this alert?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // Quick reasons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: DismissalReasons.all.map((reason) {
                return ActionChip(
                  label: Text(reason),
                  onPressed: () => onDismiss(reason),
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Dismiss without reason
            Center(
              child: TextButton(
                onPressed: () => onDismiss(null),
                child: Text(
                  'Dismiss without reason',
                  style: TextStyle(
                    color: Colors.grey.shade500,
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

/// Simple confirmation dialog for critical alerts
class CriticalAlertConfirmDialog extends StatelessWidget {
  final int criticalCount;
  final VoidCallback onProceed;
  final VoidCallback onCancel;

  const CriticalAlertConfirmDialog({
    super.key,
    required this.criticalCount,
    required this.onProceed,
    required this.onCancel,
  });

  static Future<bool?> show({
    required BuildContext context,
    required int criticalCount,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CriticalAlertConfirmDialog(
        criticalCount: criticalCount,
        onProceed: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.warning_rounded,
        color: Color(0xFFDC2626),
        size: 48,
      ),
      title: Text(
        '$criticalCount Critical Alert${criticalCount > 1 ? 's' : ''}',
        textAlign: TextAlign.center,
      ),
      content: const Text(
        'This meal has critical health alerts that may pose serious risks based on your health profile.\n\nAre you sure you want to save this meal?',
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Review Alerts'),
        ),
        ElevatedButton(
          onPressed: onProceed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
          ),
          child: const Text('Save Anyway'),
        ),
      ],
    );
  }
}
