import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/providers/sos_provider.dart';

class OfficerSosFeedScreen extends ConsumerWidget {
  const OfficerSosFeedScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'resolved':
        return AppColors.safeGreen;
      case 'assigned':
        return AppColors.warningAmber;
      case 'police_notified':
      case 'triggered':
        return AppColors.sosRed;
      default:
        return AppColors.textHintLight;
    }
  }

  String _formatStatusLabel(String status) {
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
        return 'CANCELLED (FALSE ALARM)';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(allOfficerAlertsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.radar_rounded, color: AppColors.sosRed, size: 24),
            SizedBox(width: 8),
            Text(
              'Live SOS Control Feed',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: alertsAsync.when(
          data: (alerts) {
            if (alerts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.shield_outlined, size: 64, color: AppColors.safeGreen),
                    SizedBox(height: 16),
                    Text(
                      'No Active SOS Alerts',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Ghaziabad jurisdiction is calm. Listening on emergency channel...',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                final statusColor = _getStatusColor(alert.status);
                final statusLabel = _formatStatusLabel(alert.status);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => context.push('/officer/sos-detail/${alert.id}'),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.sosRedLight,
                                    child: const Icon(
                                      Icons.emergency,
                                      size: 18,
                                      color: AppColors.sosRed,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    alert.userName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: statusColor, width: 1),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: AppColors.primaryPurple),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  alert.lastLocationAddress ?? 'Ghaziabad, UP',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 14, color: AppColors.textHintLight),
                              const SizedBox(width: 6),
                              Text(
                                alert.userPhone,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                DateFormatter.formatDateTime(alert.startedAt),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textHintLight,
                                ),
                              ),
                            ],
                          ),
                          if (alert.assignedUnitName != null) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.policeNavySurface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_police,
                                      size: 16, color: AppColors.policeNavy),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Dispatched: ${alert.assignedUnitName}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.policeNavy,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading feed: $err')),
        ),
      ),
    );
  }
}
