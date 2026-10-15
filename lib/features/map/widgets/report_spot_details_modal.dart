import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/report_model.dart';

class ReportSpotDetailsModal extends StatelessWidget {
  final ReportModel report;

  const ReportSpotDetailsModal({super.key, required this.report});

  Future<void> _openNavigation() async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${report.lat},${report.lng}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final separatorColor = isDark ? AppColors.separatorDark : AppColors.separatorLight;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    final isFixed = report.status == 'Fixed';
    final isInProgress = report.status == 'In progress';
    final isOpen = !isFixed && !isInProgress;

    IconData statusIcon;
    String statusText;
    if (isFixed) {
      statusIcon = CupertinoIcons.checkmark_alt_circle_fill;
      statusText = 'RESOLVED';
    } else if (isInProgress) {
      statusIcon = CupertinoIcons.arrow_2_circlepath;
      statusText = 'IN ACTION';
    } else {
      statusIcon = CupertinoIcons.exclamationmark_circle_fill;
      statusText = 'OPEN';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // iOS Sheet Grabber Bar
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category & Multi-cue Status Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.secondarySurfaceDark : AppColors.secondarySurfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    report.category,
                    style: IosTypography.caption1(
                      color: primaryTextColor,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOpen
                        ? (isDark ? AppColors.primaryActionDark : AppColors.primaryActionLight)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white : Colors.black,
                      width: isOpen ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 13,
                        color: isOpen
                            ? (isDark ? AppColors.onPrimaryActionDark : AppColors.onPrimaryActionLight)
                            : primaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: IosTypography.caption2(
                          color: isOpen
                              ? (isDark ? AppColors.onPrimaryActionDark : AppColors.onPrimaryActionLight)
                              : primaryTextColor,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              report.locationName,
              style: IosTypography.title2(color: primaryTextColor),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  report.routedAuthority == 'NAGAR_NIGAM_GHAZIABAD'
                      ? CupertinoIcons.building_2_fill
                      : CupertinoIcons.shield_fill,
                  size: 13,
                  color: secondaryTextColor,
                ),
                const SizedBox(width: 5),
                Text(
                  report.routedAuthorityLabel,
                  style: IosTypography.caption1(
                    color: secondaryTextColor,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text('•', style: TextStyle(color: secondaryTextColor)),
                const SizedBox(width: 8),
                Text(
                  DateFormatter.formatRelative(report.createdAt),
                  style: IosTypography.caption1(color: secondaryTextColor),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Inset Details Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.secondarySurfaceDark : AppColors.secondarySurfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: separatorColor.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Incident Description',
                    style: IosTypography.footnote(
                      color: secondaryTextColor,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.description,
                    style: IosTypography.body(color: primaryTextColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'GPS: ${report.lat.toStringAsFixed(4)}, ${report.lng.toStringAsFixed(4)}',
                    style: IosTypography.caption2(
                      color: isDark ? AppColors.tertiaryTextDark : AppColors.tertiaryTextLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Apple HIG Primary Action: Navigate
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(CupertinoIcons.location_fill, size: 18),
                label: const Text('Open in Apple / Google Maps'),
                onPressed: _openNavigation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
