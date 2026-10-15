import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../data/models/report_model.dart';
import '../../../data/providers/report_provider.dart';

/// Native iOS Admin Report Status Dialog
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

  final List<String> _ackOptions = [
    'Delivered to Control Room',
    'Acknowledged by Nagar Nigam',
    'Acknowledged by UP Police',
    'Inspection Scheduled',
    'Fixed & Verified',
  ];

  final List<String> _statusOptions = ['Open', 'In progress', 'Fixed'];

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    return CupertinoAlertDialog(
      title: Text('Update Incident Status', style: IosTypography.headline()),
      content: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.report.locationName,
                style: IosTypography.subhead(color: primaryTextColor, weight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                widget.report.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: IosTypography.caption1(color: secondaryTextColor),
              ),
              const SizedBox(height: 12),

              // Status Selector
              Text('Status:', style: IosTypography.caption1(color: secondaryTextColor, weight: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(
                children: _statusOptions.map((st) {
                  final isSelected = st == _status;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 32,
                        onPressed: () => setState(() => _status = st),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryTextColor
                                : (isDark ? AppColors.surfaceDark : AppColors.secondarySurfaceLight),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? primaryTextColor : (isDark ? AppColors.separatorDark : AppColors.separatorLight),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            st,
                            style: IosTypography.caption2(
                              color: isSelected
                                  ? (isDark ? Colors.black : Colors.white)
                                  : primaryTextColor,
                              weight: isSelected ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),
              Text('Acknowledgement:', style: IosTypography.caption1(color: secondaryTextColor, weight: FontWeight.w600)),
              const SizedBox(height: 6),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (pickerCtx) => Container(
                      height: 220,
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      child: CupertinoPicker(
                        itemExtent: 36,
                        scrollController: FixedExtentScrollController(
                          initialItem: _ackOptions.indexOf(_ackStatus).clamp(0, _ackOptions.length - 1),
                        ),
                        onSelectedItemChanged: (idx) {
                          setState(() => _ackStatus = _ackOptions[idx]);
                        },
                        children: _ackOptions
                            .map((opt) => Center(child: Text(opt, style: IosTypography.footnote())))
                            .toList(),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.secondarySurfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _ackStatus,
                          style: IosTypography.footnote(color: primaryTextColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(CupertinoIcons.chevron_up_chevron_down, size: 12, color: primaryTextColor),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Text('Action Note:', style: IosTypography.caption1(color: secondaryTextColor, weight: FontWeight.w600)),
              const SizedBox(height: 6),
              CupertinoTextField(
                controller: _noteController,
                placeholder: 'e.g., Streetlight repaired by MCD; Pink booth patrolling deployed.',
                placeholderStyle: IosTypography.caption1(color: AppColors.tertiaryTextDark),
                style: IosTypography.footnote(color: primaryTextColor),
                maxLines: 2,
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ),
      ),
      actions: [
        CupertinoDialogAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: _handleSave,
          child: const Text('Update'),
        ),
      ],
    );
  }
}
