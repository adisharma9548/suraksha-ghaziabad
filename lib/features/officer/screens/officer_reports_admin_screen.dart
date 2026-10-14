import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/report_model.dart';
import '../../../data/providers/report_provider.dart';
import '../widgets/admin_report_dialog.dart';
import '../../reports/widgets/report_card.dart';

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
    showDialog(
      context: context,
      builder: (ctx) => AdminReportDialog(report: report),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(allReportsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('District Reports Review', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Authority Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  ('All Authorities', 'All'),
                  ('🏛️ Nagar Nigam', 'NAGAR_NIGAM_GHAZIABAD'),
                  ('👮 UP Police', 'UP_POLICE'),
                ].map((item) {
                  final isSelected = item.$2 == _selectedAuthority;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(item.$1),
                      selected: isSelected,
                      selectedColor: AppColors.policeNavySurface,
                      checkmarkColor: AppColors.policeNavy,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.policeNavy : AppColors.textPrimaryLight,
                      ),
                      onSelected: (_) => setState(() => _selectedAuthority = item.$2),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Status Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: ['All', 'Open', 'In progress', 'Fixed'].map((status) {
                  final isSelected = status == _selectedStatus;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status),
                      selected: isSelected,
                      selectedColor: AppColors.primaryPurpleSurface,
                      checkmarkColor: AppColors.primaryPurple,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primaryPurple : AppColors.textPrimaryLight,
                      ),
                      onSelected: (val) {
                        setState(() => _selectedStatus = status);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1, color: AppColors.dividerLight),

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
                    return const Center(child: Text('No reports matching selected filter.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
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
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
