import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../data/providers/report_provider.dart';
import '../../map/widgets/report_spot_details_modal.dart';
import '../widgets/report_card.dart';

/// Native iOS My Reports Screen
/// Presents citizen's submitted reports with Apple HIG list layout and empty state.
class MyReportsScreen extends ConsumerWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final myReportsAsync = ref.watch(myReportsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
      appBar: AppBar(
        title: Text(l10n.myReportsTitle, style: IosTypography.headline(color: primaryTextColor)),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: myReportsAsync.when(
          data: (reports) {
            if (reports.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
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
                            CupertinoIcons.checkmark_shield,
                            size: 36,
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No Reports Submitted Yet',
                        style: IosTypography.title2(color: primaryTextColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Help make Ghaziabad safer for women by reporting broken streetlights, isolated roads, or harassment hotspots.',
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
          loading: () => Center(
            child: CupertinoActivityIndicator(radius: 14, color: primaryTextColor),
          ),
          error: (err, _) => Center(
            child: Text('Error: $err', style: IosTypography.subhead(color: secondaryTextColor)),
          ),
        ),
      ),
    );
  }
}
