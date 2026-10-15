import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/ios_widgets.dart';
import '../../../data/providers/sos_provider.dart';

/// Native iOS Officer SOS Feed Screen
/// Displays active and past emergency distress alerts with multi-cue status indicators and duress banners.
class OfficerSosFeedScreen extends ConsumerWidget {
  const OfficerSosFeedScreen({super.key});

  IosBadgeType _getBadgeType(String status, bool isDuress) {
    if (isDuress || status == 'duress_active') {
      return IosBadgeType.error;
    }
    switch (status) {
      case 'resolved':
        return IosBadgeType.success;
      case 'assigned':
        return IosBadgeType.warning;
      default:
        return IosBadgeType.info;
    }
  }

  IconData _getStatusIcon(String status, bool isDuress) {
    if (isDuress || status == 'duress_active') {
      return CupertinoIcons.exclamationmark_triangle_fill;
    }
    switch (status) {
      case 'resolved':
        return CupertinoIcons.checkmark_seal_fill;
      case 'assigned':
        return CupertinoIcons.car_fill;
      default:
        return CupertinoIcons.antenna_radiowaves_left_right;
    }
  }

  String _formatStatusLabel(String status, bool isDuress) {
    if (isDuress || status == 'duress_active') {
      return 'SILENT DURESS (COERCED)';
    }
    switch (status) {
      case 'resolved':
        return 'RESOLVED';
      case 'assigned':
        return 'DISPATCHED';
      case 'police_notified':
        return 'PENDING DISPATCH';
      case 'triggered':
        return 'NEW ALERT';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(allOfficerAlertsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
      body: SafeArea(
        child: alertsAsync.when(
          data: (alerts) {
            if (alerts.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.secondarySurfaceLight,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            CupertinoIcons.checkmark_shield_fill,
                            size: 36,
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'No Active SOS Alerts',
                        style: IosTypography.title2(color: primaryTextColor),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ghaziabad jurisdiction is calm. Listening on the live emergency channel...',
                        textAlign: TextAlign.center,
                        style: IosTypography.body(color: secondaryTextColor),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                final badgeType = _getBadgeType(alert.status, alert.isDuress);
                final statusIcon = _getStatusIcon(alert.status, alert.isDuress);
                final statusLabel = _formatStatusLabel(alert.status, alert.isDuress);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: IosCard(
                    padding: const EdgeInsets.all(16),
                    onTap: () => context.push('/officer/sos-detail/${alert.id}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (alert.isDuress) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.exclamationmark_triangle_fill,
                                  color: isDark ? Colors.black : Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'CRITICAL: Citizen entered Decoy Duress PIN! Coerced cancellation. DO NOT STAND DOWN.',
                                    style: IosTypography.caption1(
                                      color: isDark ? Colors.black : Colors.white,
                                      weight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.secondarySurfaceDark : AppColors.secondarySurfaceLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      alert.userName.isNotEmpty ? alert.userName[0].toUpperCase() : 'U',
                                      style: IosTypography.headline(color: primaryTextColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      alert.userName,
                                      style: IosTypography.headline(color: primaryTextColor),
                                    ),
                                    Text(
                                      alert.userPhone,
                                      style: IosTypography.caption1(color: secondaryTextColor),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IosBadge(
                              label: statusLabel,
                              icon: statusIcon,
                              type: badgeType,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(CupertinoIcons.location_solid, size: 14, color: secondaryTextColor),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                alert.latestLocation != null
                                    ? 'GPS: ${alert.latestLocation!.lat.toStringAsFixed(4)}, ${alert.latestLocation!.lng.toStringAsFixed(4)}'
                                    : 'GPS: Live stream active',
                                style: IosTypography.footnote(color: secondaryTextColor),
                              ),
                            ),
                            Text(
                              DateFormatter.formatDateTime(alert.startedAt),
                              style: IosTypography.caption1(color: secondaryTextColor),
                            ),
                          ],
                        ),
                        if (alert.assignedUnitId != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(CupertinoIcons.car_fill, size: 14, color: primaryTextColor),
                              const SizedBox(width: 6),
                              Text(
                                'Assigned: ${alert.assignedUnitName ?? alert.assignedUnitId}',
                                style: IosTypography.caption1(
                                  color: primaryTextColor,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => Center(
            child: CupertinoActivityIndicator(radius: 14, color: primaryTextColor),
          ),
          error: (e, _) => Center(
            child: Text('Feed error: $e', style: IosTypography.subhead(color: secondaryTextColor)),
          ),
        ),
      ),
    );
  }
}
