import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/providers/report_provider.dart';
import '../widgets/report_card.dart';
import '../../map/widgets/report_spot_details_modal.dart';

class MyReportsScreen extends ConsumerWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final myReportsAsync = ref.watch(myReportsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myReportsTitle),
      ),
      body: SafeArea(
        child: myReportsAsync.when(
          data: (reports) {
            if (reports.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurpleSurface,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.assignment_turned_in_rounded,
                          size: 48,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No Reports Submitted Yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Help make Ghaziabad safer for women by reporting broken lights, isolated roads, or harassment hotspots.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondaryLight,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return ReportCard(
                  report: report,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => ReportSpotDetailsModal(report: report),
                    );
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}
