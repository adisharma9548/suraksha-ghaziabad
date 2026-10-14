import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/report_provider.dart';
import '../../../data/providers/sos_provider.dart';

class OfficerAnalyticsScreen extends ConsumerWidget {
  const OfficerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(allReportsStreamProvider);
    final alertsAsync = ref.watch(allOfficerAlertsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'District Safety Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: reportsAsync.when(
          data: (reports) {
            final total = reports.length;
            final resolved = reports.where((r) => r.status == 'Fixed').length;
            final inProgress =
                reports.where((r) => r.status == 'In progress').length;
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
                avgResponseVal = '${avgSec.round()} sec';
              } else {
                avgResponseVal = '${(avgSec / 60).toStringAsFixed(1)} min';
              }
              avgResponseSub = 'From ${responseTimes.length} live dispatches';
            } else if (alerts.isNotEmpty) {
              avgResponseVal = 'Pending';
              avgResponseSub = '${alerts.length} active alerts awaiting unit';
            }

            // 2. Category counts
            final Map<String, int> categoryCounts = {};
            for (final r in reports) {
              categoryCounts[r.category] =
                  (categoryCounts[r.category] ?? 0) + 1;
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

              // Time-decay factor: 7-day half-life decay
              final daysOld = math.max(
                  0.0, now.difference(r.createdAt).inMinutes / (60 * 24));
              final decayWeight = 1.0 / (1.0 + (daysOld / 7.0));

              // Fixed issues contribute 20% residual risk; active issues contribute 100%
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
              ..sort((a, b) =>
                  b.decayWeightedRisk.compareTo(a.decayWeightedRisk));

            // Top unsafe zones
            final Map<String, int> zoneCounts = {};
            for (final r in reports) {
              final zone = r.locationName.split(',').first.trim();
              zoneCounts[zone] = (zoneCounts[zone] ?? 0) + 1;
            }
            final sortedZones = zoneCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            final topZones = sortedZones.take(10).toList();

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Top KPI Metrics
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        title: 'Total Reports',
                        value: '$total',
                        subtitle: 'Across Ghaziabad',
                        icon: Icons.assignment_rounded,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        title: 'Avg Response',
                        value: avgResponseVal,
                        subtitle: avgResponseSub,
                        icon: Icons.timer_rounded,
                        color: AppColors.safeGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        title: 'Resolved (Fixed)',
                        value: '$resolved',
                        subtitle:
                            '${((resolved / (total > 0 ? total : 1)) * 100).round()}% closure rate',
                        icon: Icons.verified_rounded,
                        color: AppColors.safeGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        title: 'Open / In Action',
                        value: '${open + inProgress}',
                        subtitle: 'Active patrols / works',
                        icon: Icons.pending_actions_rounded,
                        color: AppColors.warningAmberDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // WARD-LEVEL TIME-DECAY RISK ANALYTICS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ward-Level Time-Decay Risk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurpleSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '7-Day Decay Model',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Recent incidents carry higher weight; resolved issues decay over time.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                ...sortedWards.map((w) {
                  final riskScore = w.decayWeightedRisk;
                  final Color riskColor;
                  final String riskLevel;
                  if (riskScore > 10) {
                    riskColor = AppColors.sosRed;
                    riskLevel = 'HIGH RISK';
                  } else if (riskScore > 4) {
                    riskColor = AppColors.warningAmberDark;
                    riskLevel = 'ELEVATED';
                  } else {
                    riskColor = AppColors.safeGreen;
                    riskLevel = 'LOW RISK';
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.dividerLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                w.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: riskColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: riskColor, width: 1),
                              ),
                              child: Text(
                                riskLevel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: riskColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          w.subAreas,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textHintLight,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Decay Score: ${riskScore.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: riskColor,
                              ),
                            ),
                            const Text(' • ',
                                style: TextStyle(
                                    color: AppColors.textSecondaryLight)),
                            Text(
                              '${w.totalReports} total',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(Icons.account_balance_rounded,
                                    size: 12, color: AppColors.policeNavy),
                                const SizedBox(width: 3),
                                Text(
                                  '${w.nagarNigamReports}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.policeNavy,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.local_police_rounded,
                                    size: 12, color: AppColors.sosRed),
                                const SizedBox(width: 3),
                                Text(
                                  '${w.policeReports}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.sosRed,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),

                // Reports by Category Chart Section
                const Text(
                  'Reports by Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.dividerLight),
                  ),
                  child: Column(
                    children: categoryCounts.entries.map((entry) {
                      final cat = entry.key;
                      final count = entry.value;
                      final pct = total > 0 ? (count / total) : 0.0;

                      Color barColor = AppColors.primaryPurple;
                      if (cat == 'Harassment') barColor = AppColors.sosRed;
                      if (cat == 'Isolated road') {
                        barColor = AppColors.warningAmberDark;
                      }
                      if (cat == 'Drunk crowd') barColor = Colors.deepOrange;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  cat,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '$count (${(pct * 100).round()}%)',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 8,
                                backgroundColor: AppColors.dividerLight,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(barColor),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Incidents by Time of Day
                const Text(
                  'Reports by Time of Day',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children:
                      ['Morning', 'Afternoon', 'Evening', 'Night'].map((time) {
                    final count = timeCounts[time] ?? 0;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: time == 'Night'
                              ? AppColors.policeNavySurface
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: time == 'Night'
                                ? AppColors.policeNavy
                                : AppColors.dividerLight,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: time == 'Night'
                                    ? AppColors.policeNavy
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              time,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Top 10 High-Risk Unsafe Zones
                const Text(
                  'Top 10 High-Risk Unsafe Zones',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.dividerLight),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topZones.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.dividerLight),
                    itemBuilder: (context, index) {
                      final item = topZones[index];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 13,
                          backgroundColor: index < 3
                              ? AppColors.sosRedLight
                              : AppColors.primaryPurpleSurface,
                          child: Text(
                            '#${index + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: index < 3
                                  ? AppColors.sosRedDark
                                  : AppColors.primaryPurple,
                            ),
                          ),
                        ),
                        title: Text(
                          item.key,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: index < 3
                                ? AppColors.sosRedLight
                                : AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${item.value} reports',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: index < 3
                                  ? AppColors.sosRedDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

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

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondaryLight),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style:
                const TextStyle(fontSize: 11, color: AppColors.textHintLight),
          ),
        ],
      ),
    );
  }
}
