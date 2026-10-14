import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/report_model.dart';

class ReportSpotDetailsModal extends StatelessWidget {
  final ReportModel report;

  const ReportSpotDetailsModal({super.key, required this.report});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Fixed':
        return AppColors.safeGreen;
      case 'In progress':
        return AppColors.warningAmber;
      default:
        return AppColors.sosRed;
    }
  }

  Future<void> _openNavigation() async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${report.lat},${report.lng}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(report.status);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.dividerLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurpleSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  report.category,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor, width: 1),
                ),
                child: Text(
                  report.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            report.locationName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Reported: ${DateFormatter.formatDateTime(report.createdAt)} • ${report.timeOfDay}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.dividerLight),
            ),
            child: Text(
              report.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimaryLight,
                height: 1.4,
              ),
            ),
          ),
          if (report.adminNote != null && report.adminNote!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.safeGreenLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.safeGreen.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: AppColors.safeGreen, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Police/MCD Action: ${report.adminNote}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.safeGreenDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.directions_rounded),
                  label: const Text('Directions'),
                  onPressed: _openNavigation,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.share_location_rounded),
                  label: const Text('Share Spot'),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Safety spot coordinates copied')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
