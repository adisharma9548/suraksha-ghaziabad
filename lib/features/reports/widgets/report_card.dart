import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/report_model.dart';

class ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback? onTap;

  const ReportCard({super.key, required this.report, this.onTap});

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

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(report.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurpleSurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      report.category,
                      style: const TextStyle(
                        fontSize: 11,
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
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                report.locationName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                report.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                  height: 1.3,
                ),
              ),
              if (report.adminNote != null && report.adminNote!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.safeGreenLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 14, color: AppColors.safeGreen),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Update: ${report.adminNote}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.safeGreenDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                DateFormatter.formatDateTime(report.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textHintLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
