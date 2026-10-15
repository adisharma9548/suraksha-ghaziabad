import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/report_model.dart';

class ReportCard extends StatelessWidget {
  final ReportModel report;
  final VoidCallback? onTap;

  const ReportCard({super.key, required this.report, this.onTap});

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

    // Multi-Cue Status Badge (Never color alone: Icon + Label + Shape + Border)
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: separatorColor.withOpacity(0.5), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category Inset Pill
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

                    // Multi-cue Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
                            size: 12,
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
                const SizedBox(height: 10),

                // Authority Queue Routing Row
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
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.secondarySurfaceDark : AppColors.secondarySurfaceLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.location_solid,
                            size: 10,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            report.wardName.split('(').first.trim(),
                            style: IosTypography.caption2(
                              color: secondaryTextColor,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Description
                Text(
                  report.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: IosTypography.callout(color: primaryTextColor),
                ),
                const SizedBox(height: 10),

                // Footer Row: Location & Timestamp
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.map_pin_ellipse,
                      size: 13,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        report.locationName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: IosTypography.caption1(color: secondaryTextColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormatter.formatRelative(report.createdAt),
                      style: IosTypography.caption2(color: isDark ? AppColors.tertiaryTextDark : AppColors.tertiaryTextLight),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
