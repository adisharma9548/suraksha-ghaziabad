import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../data/models/report_model.dart';
import '../../../data/providers/report_provider.dart';
import '../../reports/widgets/report_card.dart';
import '../widgets/admin_report_dialog.dart';

/// Native iOS Officer Reports Admin Screen
class OfficerReportsAdminScreen extends ConsumerStatefulWidget {
  const OfficerReportsAdminScreen({super.key});

  @override
  ConsumerState<OfficerReportsAdminScreen> createState() =>
      _OfficerReportsAdminScreenState();
}

class _OfficerReportsAdminScreenState
    extends ConsumerState<OfficerReportsAdminScreen> {
  String _selectedStatus = 'All';
  String _selectedAuthority = 'All';

  void _openUpdateDialog(ReportModel report) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => AdminReportDialog(report: report),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(allReportsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;
    final separatorColor = isDark ? AppColors.separatorDark : AppColors.separatorLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Authority Filter Pills
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  ('All Authorities', 'All'),
                  ('Nagar Nigam', 'NAGAR_NIGAM_GHAZIABAD'),
                  ('UP Police', 'UP_POLICE'),
                ].map((item) {
                  final isSelected = item.$2 == _selectedAuthority;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 32,
                      onPressed: () => setState(() => _selectedAuthority = item.$2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryTextColor
                              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? primaryTextColor : separatorColor,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              Icon(
                                CupertinoIcons.checkmark,
                                size: 12,
                                color: isDark ? Colors.black : Colors.white,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              item.$1,
                              style: IosTypography.footnote(
                                color: isSelected
                                    ? (isDark ? Colors.black : Colors.white)
                                    : primaryTextColor,
                                weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Status Filter Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: ['All', 'Open', 'In progress', 'Fixed'].map((status) {
                  final isSelected = status == _selectedStatus;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 30,
                      onPressed: () => setState(() => _selectedStatus = status),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryTextColor
                              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? primaryTextColor : separatorColor,
                          ),
                        ),
                        child: Text(
                          status,
                          style: IosTypography.caption1(
                            color: isSelected
                                ? (isDark ? Colors.black : Colors.white)
                                : primaryTextColor,
                            weight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            Divider(height: 1, color: separatorColor),

            Expanded(
              child: reportsAsync.when(
                data: (reports) {
                  final filtered = reports.where((r) {
                    final matchesStatus =
                        _selectedStatus == 'All' || r.status == _selectedStatus;
                    final matchesAuth = _selectedAuthority == 'All' ||
                        r.routedAuthority == _selectedAuthority;
                    return matchesStatus && matchesAuth;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(CupertinoIcons.tray, size: 48, color: secondaryTextColor),
                            const SizedBox(height: 14),
                            Text(
                              'No Reports Matching Filter',
                              style: IosTypography.headline(color: primaryTextColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final report = filtered[index];
                      return ReportCard(
                        report: report,
                        onTap: () => _openUpdateDialog(report),
                      );
                    },
                  );
                },
                loading: () => Center(
                  child: CupertinoActivityIndicator(radius: 14, color: primaryTextColor),
                ),
                error: (e, _) => Center(
                  child: Text('Error: $e', style: IosTypography.subhead(color: secondaryTextColor)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
