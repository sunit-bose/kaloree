import 'package:flutter/material.dart';
import '../models/health_alert.dart';
import '../app/theme.dart';

/// Card widget displaying a single health alert with severity indicator
/// 
/// Used in:
/// - MealInfoScreen (before saving)
/// - HealthAlertsDialog
/// - InsightsScreen (summary)
class HealthAlertCard extends StatelessWidget {
  final HealthAlert alert;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;
  final bool showDismissButton;
  final bool compact;

  const HealthAlertCard({
    super.key,
    required this.alert,
    this.onDismiss,
    this.onTap,
    this.showDismissButton = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDismissed = alert.isDismissed;

    return Opacity(
      opacity: isDismissed ? 0.5 : 1.0,
      child: Card(
        margin: EdgeInsets.symmetric(
          vertical: compact ? 4 : 6,
          horizontal: compact ? 0 : 4,
        ),
        elevation: isDismissed ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(compact ? 12 : 16),
          side: BorderSide(
            color: _getSeverityColor(alert.severity).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(compact ? 12 : 16),
          child: Padding(
            padding: EdgeInsets.all(compact ? 12 : 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Severity indicator
                _SeverityBadge(
                  severity: alert.severity,
                  compact: compact,
                ),
                SizedBox(width: compact ? 10 : 14),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Alert type name
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              alert.type.displayName,
                              style: TextStyle(
                                fontSize: compact ? 14 : 16,
                                fontWeight: FontWeight.w700,
                                color: isDismissed
                                    ? Colors.grey
                                    : _getSeverityColor(alert.severity),
                                decoration: isDismissed
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          if (alert.displayValue.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getSeverityColor(alert.severity)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                alert.displayValue,
                                style: TextStyle(
                                  fontSize: compact ? 10 : 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getSeverityColor(alert.severity),
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      SizedBox(height: compact ? 2 : 4),
                      
                      // Message
                      Text(
                        alert.message,
                        style: TextStyle(
                          fontSize: compact ? 12 : 14,
                          color: isDismissed
                              ? Colors.grey
                              : Colors.grey.shade700,
                          height: 1.3,
                        ),
                        maxLines: compact ? 2 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Dismissed reason (if applicable)
                      if (isDismissed && alert.dismissalReason != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Dismissed: ${alert.dismissalReason}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Dismiss button
                if (showDismissButton && !isDismissed) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: compact ? 18 : 20,
                      color: Colors.grey.shade400,
                    ),
                    onPressed: onDismiss,
                    tooltip: 'Dismiss alert',
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: compact ? 28 : 32,
                      minHeight: compact ? 28 : 32,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return const Color(0xFFDC2626); // Red
      case AlertSeverity.high:
        return const Color(0xFFEA580C); // Orange
      case AlertSeverity.medium:
        return const Color(0xFFCA8A04); // Yellow/Amber
      case AlertSeverity.low:
        return const Color(0xFF2563EB); // Blue
    }
  }
}

/// Badge showing severity level with icon
class _SeverityBadge extends StatelessWidget {
  final AlertSeverity severity;
  final bool compact;

  const _SeverityBadge({
    required this.severity,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 36 : 44,
      height: compact ? 36 : 44,
      decoration: BoxDecoration(
        color: _getSeverityColor(severity).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(compact ? 10 : 12),
      ),
      child: Center(
        child: Text(
          severity.emoji,
          style: TextStyle(fontSize: compact ? 18 : 22),
        ),
      ),
    );
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return const Color(0xFFDC2626);
      case AlertSeverity.high:
        return const Color(0xFFEA580C);
      case AlertSeverity.medium:
        return const Color(0xFFCA8A04);
      case AlertSeverity.low:
        return const Color(0xFF2563EB);
    }
  }
}

/// Compact summary chip for showing alert count
class HealthAlertSummaryChip extends StatelessWidget {
  final int criticalCount;
  final int totalCount;
  final VoidCallback? onTap;

  const HealthAlertSummaryChip({
    super.key,
    required this.criticalCount,
    required this.totalCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (totalCount == 0) return const SizedBox.shrink();

    final hasCritical = criticalCount > 0;
    final color = hasCritical
        ? const Color(0xFFDC2626)
        : const Color(0xFFCA8A04);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasCritical ? Icons.warning_rounded : Icons.info_rounded,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              hasCritical
                  ? '$criticalCount critical'
                  : '$totalCount alert${totalCount > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Banner shown at top of screen when alerts are present
class HealthAlertBanner extends StatelessWidget {
  final List<HealthAlert> alerts;
  final VoidCallback onViewAll;
  final VoidCallback onDismissAll;

  const HealthAlertBanner({
    super.key,
    required this.alerts,
    required this.onViewAll,
    required this.onDismissAll,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    final activeAlerts = alerts.where((a) => !a.isDismissed).toList();
    if (activeAlerts.isEmpty) return const SizedBox.shrink();

    final criticalCount = activeAlerts.where((a) => a.isCritical).length;
    final hasCritical = criticalCount > 0;
    final color = hasCritical
        ? const Color(0xFFDC2626)
        : const Color(0xFFCA8A04);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasCritical ? Icons.warning_rounded : Icons.info_rounded,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasCritical
                      ? '$criticalCount Critical Alert${criticalCount > 1 ? 's' : ''}'
                      : '${activeAlerts.length} Health Alert${activeAlerts.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Review before saving',
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              foregroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}
