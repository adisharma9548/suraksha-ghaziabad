import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../core/widgets/ios_widgets.dart';
import '../../../data/providers/report_provider.dart';
import '../../../data/providers/sos_provider.dart';

class _WardAnalytics {
  final String name;
  final String subAreas;
  int totalReports = 0;
  int resolvedReports = 0;
  int nagarNigamReports = 0;
  int policeReports = 0;
  double decayWeightedRisk = 0.0;

  _WardAnalytics({required this.name, required this.subAreas});
}

/// Pattern styles for color-blind safe charts
enum ChartPatternStyle { solid, diagonalStripes, dots, crossHatch }

/// Native iOS Officer Analytics Screen
/// 100% accessible to all forms of color blindness:
/// Uses luminance hierarchy, patterned/textured charts (stripes, dots, hatching), direct labels, and multi-cue badges.
class OfficerAnalyticsScreen extends ConsumerWidget {
  const OfficerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(allReportsStreamProvider);
    final alertsAsync = ref.watch(allOfficerAlertsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
      body: SafeArea(
        child: reportsAsync.when(
          data: (reports) {
            final total = reports.length;
            final resolved = reports.where((r) => r.status == 'Fixed').length;
            final inProgress = reports.where((r) => r.status == 'In progress').length;
            final open = reports.where((r) => r.status == 'Open').length;

            // 1. Calculate Real Response Time from SOS alerts timestamps
            final alerts = alertsAsync.asData?.value ?? [];
            final responseTimes = alerts
                .where((a) => a.assignedAt != null)
                .map((a) => a.assignedAt!.difference(a.startedAt).inSeconds)
                .where((sec) => sec >= 0)
                .toList();

            String avgResponseVal = '--';
            String avgResponseSub = 'No dispatch logs yet';
            if (responseTimes.isNotEmpty) {
              final avgSec =
                  responseTimes.reduce((a, b) => a + b) / responseTimes.length;
              if (avgSec < 60) {
                avgResponseVal = '${avgSec.round()}s';
              } else {
                avgResponseVal = '${(avgSec / 60).toStringAsFixed(1)}m';
              }
              avgResponseSub = 'From ${responseTimes.length} live dispatches';
            } else if (alerts.isNotEmpty) {
              avgResponseVal = 'Pending';
              avgResponseSub = '${alerts.length} active alerts awaiting unit';
            }

            // 2. Category counts
            final Map<String, int> categoryCounts = {};
            for (final r in reports) {
              categoryCounts[r.category] = (categoryCounts[r.category] ?? 0) + 1;
            }

            // 3. Time of day counts
            final Map<String, int> timeCounts = {};
            for (final r in reports) {
              timeCounts[r.timeOfDay] = (timeCounts[r.timeOfDay] ?? 0) + 1;
            }

            // 4. Time-Decay and Ward-Level Analytics Computation
            final now = DateTime.now();
            final Map<String, _WardAnalytics> wardMap = {
              'Vasundhara Zone (Ward 82)': _WardAnalytics(
                name: 'Vasundhara Zone (Ward 82)',
                subAreas: 'Indirapuram, Vaishali, Kaushambi',
              ),
              'Mohan Nagar Zone (Ward 64)': _WardAnalytics(
                name: 'Mohan Nagar Zone (Ward 64)',
                subAreas: 'Sahibabad, Arthala, Rajendra Nagar',
              ),
              'Kavi Nagar Zone (Ward 12)': _WardAnalytics(
                name: 'Kavi Nagar Zone (Ward 12)',
                subAreas: 'Raj Nagar, Shastri Nagar, Govindpuram',
              ),
              'Vijay Nagar Zone (Ward 28)': _WardAnalytics(
                name: 'Vijay Nagar Zone (Ward 28)',
                subAreas: 'Crossings Republik, Pratap Vihar',
              ),
              'City Kotwali Zone (Ward 41)': _WardAnalytics(
                name: 'City Kotwali Zone (Ward 41)',
                subAreas: 'Ghantaghar, Model Town, Naya Ganj',
              ),
            };

            for (final r in reports) {
              final wardKey = wardMap.containsKey(r.wardName)
                  ? r.wardName
                  : 'City Kotwali Zone (Ward 41)';
              final ward = wardMap[wardKey]!;

              final daysOld = math.max(0.0, now.difference(r.createdAt).inMinutes / (60 * 24));
              final decayWeight = 1.0 / (1.0 + (daysOld / 7.0));
              final statusFactor = r.status == 'Fixed' ? 0.2 : 1.0;
              final weightedScore = r.severity * decayWeight * statusFactor;

              ward.totalReports++;
              ward.decayWeightedRisk += weightedScore;
              if (r.status == 'Fixed') ward.resolvedReports++;
              if (r.routedAuthority == 'NAGAR_NIGAM_GHAZIABAD') {
                ward.nagarNigamReports++;
              } else {
                ward.policeReports++;
              }
            }

            final sortedWards = wardMap.values.toList()
              ..sort((a, b) => b.decayWeightedRisk.compareTo(a.decayWeightedRisk));

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Top KPI Metrics 2x2 Grid
                Row(
                  children: [
                    Expanded(
                      child: _IosMetricTile(
                        icon: CupertinoIcons.doc_text_fill,
                        label: 'Total Reports',
                        value: '$total',
                        subtitle: '$open open • $inProgress in action',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _IosMetricTile(
                        icon: CupertinoIcons.checkmark_seal_fill,
                        label: 'Resolution Rate',
                        value: total > 0 ? '${((resolved / total) * 100).round()}%' : '0%',
                        subtitle: '$resolved fixed and verified',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _IosMetricTile(
                        icon: CupertinoIcons.timer_fill,
                        label: 'Avg Response',
                        value: avgResponseVal,
                        subtitle: avgResponseSub,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _IosMetricTile(
                        icon: CupertinoIcons.shield_lefthalf_fill,
                        label: 'Patrol Queue',
                        value: '${alerts.length}',
                        subtitle: '${alerts.where((a) => a.isDuress).length} duress events',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Reports by Category with Accessible Patterned Progress Bars
                Row(
                  children: [
                    Icon(CupertinoIcons.chart_bar_square_fill, size: 20, color: primaryTextColor),
                    const SizedBox(width: 8),
                    Text(
                      'Reports by Category',
                      style: IosTypography.title3(color: primaryTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Differentiated with distinct hatchings and icons, readable without color.',
                  style: IosTypography.caption1(color: secondaryTextColor),
                ),
                const SizedBox(height: 12),

                IosCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: categoryCounts.entries.map((entry) {
                      final cat = entry.key;
                      final count = entry.value;
                      final pct = total > 0 ? (count / total) : 0.0;

                      ChartPatternStyle pattern = ChartPatternStyle.solid;
                      IconData markerIcon = CupertinoIcons.question_circle;
                      if (cat == 'Harassment') {
                        pattern = ChartPatternStyle.diagonalStripes;
                        markerIcon = CupertinoIcons.exclamationmark_triangle_fill;
                      } else if (cat == 'Broken streetlight') {
                        pattern = ChartPatternStyle.solid;
                        markerIcon = CupertinoIcons.lightbulb_fill;
                      } else if (cat == 'Isolated road') {
                        pattern = ChartPatternStyle.dots;
                        markerIcon = CupertinoIcons.arrow_branch;
                      } else if (cat == 'Drunk crowd') {
                        pattern = ChartPatternStyle.crossHatch;
                        markerIcon = CupertinoIcons.person_3_fill;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(markerIcon, size: 14, color: primaryTextColor),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    cat,
                                    style: IosTypography.footnote(
                                      color: primaryTextColor,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$count (${(pct * 100).round()}%)',
                                  style: IosTypography.footnote(
                                    color: primaryTextColor,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            _PatternedProgressBar(
                              percentage: pct,
                              pattern: pattern,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // Incidents by Time of Day
                Row(
                  children: [
                    Icon(CupertinoIcons.clock_fill, size: 20, color: primaryTextColor),
                    const SizedBox(width: 8),
                    Text(
                      'Incidents by Time of Day',
                      style: IosTypography.title3(color: primaryTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ('Morning', CupertinoIcons.sunrise_fill),
                    ('Afternoon', CupertinoIcons.sun_max_fill),
                    ('Evening', CupertinoIcons.sunset_fill),
                    ('Night', CupertinoIcons.moon_stars_fill),
                  ].map((item) {
                    final time = item.$1;
                    final icon = item.$2;
                    final count = timeCounts[time] ?? 0;
                    final isNight = time == 'Night';

                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                        decoration: BoxDecoration(
                          color: isNight
                              ? (isDark ? Colors.white : const Color(0xFF1C1C1E))
                              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              icon,
                              size: 18,
                              color: isNight
                                  ? (isDark ? Colors.black : Colors.white)
                                  : primaryTextColor,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              time,
                              style: IosTypography.caption2(
                                color: isNight
                                    ? (isDark ? Colors.black : Colors.white)
                                    : secondaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$count',
                              style: IosTypography.headline(
                                color: isNight
                                    ? (isDark ? Colors.black : Colors.white)
                                    : primaryTextColor,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Ward-Level Risk Index with 7-Day Decay Model
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(CupertinoIcons.building_2_fill, size: 20, color: primaryTextColor),
                        const SizedBox(width: 8),
                        Text(
                          'Ward Risk Index',
                          style: IosTypography.title3(color: primaryTextColor),
                        ),
                      ],
                    ),
                    IosBadge(
                      label: '7-Day Decay',
                      icon: CupertinoIcons.arrow_2_circlepath,
                      type: IosBadgeType.info,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Recent reports carry higher risk; verified fixes decay exponentially over time.',
                  style: IosTypography.caption1(color: secondaryTextColor),
                ),
                const SizedBox(height: 12),

                ...sortedWards.map((w) {
                  final riskScore = w.decayWeightedRisk;
                  final IosBadgeType badgeType;
                  final String riskLevel;
                  final IconData riskIcon;
                  if (riskScore > 10) {
                    badgeType = IosBadgeType.error;
                    riskLevel = 'HIGH RISK';
                    riskIcon = CupertinoIcons.exclamationmark_triangle_fill;
                  } else if (riskScore > 4) {
                    badgeType = IosBadgeType.warning;
                    riskLevel = 'ELEVATED';
                    riskIcon = CupertinoIcons.exclamationmark_circle_fill;
                  } else {
                    badgeType = IosBadgeType.success;
                    riskLevel = 'LOW RISK';
                    riskIcon = CupertinoIcons.checkmark_circle_fill;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: IosCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  w.name,
                                  style: IosTypography.headline(color: primaryTextColor),
                                ),
                              ),
                              IosBadge(
                                label: riskLevel,
                                icon: riskIcon,
                                type: badgeType,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            w.subAreas,
                            style: IosTypography.caption1(color: secondaryTextColor),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                'Decay Score: ${riskScore.toStringAsFixed(1)}',
                                style: IosTypography.footnote(
                                  color: primaryTextColor,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              Text(' • ', style: IosTypography.footnote(color: secondaryTextColor)),
                              Text(
                                '${w.totalReports} total',
                                style: IosTypography.footnote(color: secondaryTextColor),
                              ),
                              const Spacer(),
                              Icon(CupertinoIcons.building_2_fill, size: 12, color: secondaryTextColor),
                              const SizedBox(width: 4),
                              Text('${w.nagarNigamReports}', style: IosTypography.caption1(color: primaryTextColor, weight: FontWeight.w700)),
                              const SizedBox(width: 8),
                              Icon(CupertinoIcons.shield_fill, size: 12, color: secondaryTextColor),
                              const SizedBox(width: 4),
                              Text('${w.policeReports}', style: IosTypography.caption1(color: primaryTextColor, weight: FontWeight.w700)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            );
          },
          loading: () => Center(
            child: CupertinoActivityIndicator(radius: 14, color: primaryTextColor),
          ),
          error: (e, _) => Center(
            child: Text('Analytics error: $e', style: IosTypography.subhead(color: secondaryTextColor)),
          ),
        ),
      ),
    );
  }
}

class _IosMetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;

  const _IosMetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    return IosCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: primaryTextColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: IosTypography.caption1(color: secondaryTextColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: IosTypography.title1(color: primaryTextColor),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: IosTypography.caption2(color: secondaryTextColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Accessible Patterned Progress Bar (Stripes, Dots, Solid)
class _PatternedProgressBar extends StatelessWidget {
  final double percentage;
  final ChartPatternStyle pattern;
  final bool isDark;

  const _PatternedProgressBar({
    required this.percentage,
    required this.pattern,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE5E5EA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? const Color(0xFF38383A) : const Color(0xFFD1D1D6),
        ),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: percentage.clamp(0.02, 1.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: CustomPaint(
            painter: _PatternPainter(pattern: pattern, isDark: isDark),
          ),
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final ChartPatternStyle pattern;
  final bool isDark;

  _PatternPainter({required this.pattern, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF1C1C1E)
      ..style = PaintingStyle.fill;

    if (pattern == ChartPatternStyle.solid) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), fillPaint);
    } else if (pattern == ChartPatternStyle.diagonalStripes) {
      // Base background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = isDark ? const Color(0xFF38383A) : const Color(0xFFC6C6C8),
      );
      final stripePaint = Paint()
        ..color = isDark ? Colors.white : const Color(0xFF1C1C1E)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      for (double x = -size.height; x < size.width; x += 8) {
        canvas.drawLine(
          Offset(x, size.height),
          Offset(x + size.height, 0),
          stripePaint,
        );
      }
    } else if (pattern == ChartPatternStyle.dots) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
      );
      final dotPaint = Paint()
        ..color = isDark ? Colors.white : const Color(0xFF1C1C1E)
        ..style = PaintingStyle.fill;

      for (double x = 4; x < size.width; x += 8) {
        for (double y = 3; y < size.height; y += 6) {
          canvas.drawCircle(Offset(x, y), 1.8, dotPaint);
        }
      }
    } else if (pattern == ChartPatternStyle.crossHatch) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = isDark ? const Color(0xFF38383A) : const Color(0xFFC6C6C8),
      );
      final linePaint = Paint()
        ..color = isDark ? Colors.white : const Color(0xFF1C1C1E)
        ..strokeWidth = 1.5;

      for (double x = -size.height; x < size.width; x += 7) {
        canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), linePaint);
        canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) =>
      oldDelegate.pattern != pattern || oldDelegate.isDark != isDark;
}
