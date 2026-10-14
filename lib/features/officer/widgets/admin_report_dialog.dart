import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/report_model.dart';
import '../../../data/providers/report_provider.dart';

class AdminReportDialog extends ConsumerStatefulWidget {
  final ReportModel report;

  const AdminReportDialog({super.key, required this.report});

  @override
  ConsumerState<AdminReportDialog> createState() => _AdminReportDialogState();
}

class _AdminReportDialogState extends ConsumerState<AdminReportDialog> {
  late String _status;
  late String _ackStatus;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _status = widget.report.status;
    _ackStatus = widget.report.acknowledgementStatus;
    _noteController.text = widget.report.adminNote ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    await ref.read(reportControllerProvider.notifier).updateReportStatus(
          reportId: widget.report.id,
          status: _status,
          adminNote: _noteController.text.trim(),
          acknowledgementStatus: _ackStatus,
        );
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Update Incident Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.report.locationName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              widget.report.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 14),
            Text(
              'Assigned Queue: ${widget.report.routedAuthorityLabel}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.policeNavy),
            ),
            const SizedBox(height: 14),
            const Text('Acknowledgement Status:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _ackStatus,
              isExpanded: true,
              items: [
                'Delivered to Control Room',
                'Acknowledged by Nagar Nigam',
                'Acknowledged by UP Police',
                'Inspection Scheduled',
                'Fixed & Verified'
              ]
                  .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12))))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _ackStatus = val);
              },
            ),
            const SizedBox(height: 14),
            const Text('Incident Status:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _status,
              items: ['Open', 'In progress', 'Fixed']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _status = val);
              },
            ),
          const SizedBox(height: 14),
          const Text('Action Note (MCD / Police Action):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText:
                    'e.g. Streetlight repaired by MCD electrical wing; Pink booth patrolling deployed.',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: const Text('Update & Notify'),
        ),
      ],
    );
  }
}
