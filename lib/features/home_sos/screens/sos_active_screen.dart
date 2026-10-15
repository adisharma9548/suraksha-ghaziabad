import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/providers/sos_provider.dart';
import '../widgets/pin_verify_dialog.dart';

class SosActiveScreen extends ConsumerWidget {
  const SosActiveScreen({super.key});

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PinVerifyDialog(
        onVerify: (pin) async {
          final success =
              await ref.read(sosProvider.notifier).cancelSosWithPin(pin);
          if (success && context.mounted) {
            context.go('/citizen');
          }
          return success;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sosState = ref.watch(sosProvider);
    final alert = sosState.activeAlert;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final status = alert?.status ?? 'triggered';
    final isResolved = status == 'resolved';
    final isAssigned = status == 'assigned';
    final isPoliceNotified = status == 'police_notified' || isAssigned || isResolved;
    final isAlertSent = true;

    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;
    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final separatorColor = isDark ? AppColors.separatorDark : AppColors.separatorLight;

    return WillPopScope(
      onWillPop: () async {
        if (alert != null && alert.isActive) {
          _showCancelDialog(context, ref);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            isResolved ? 'SOS Incident Resolved' : l10n.sosActiveStatus,
            style: IosTypography.headline(color: primaryTextColor),
          ),
          actions: [
            if (alert != null && alert.isActive)
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                onPressed: () => _showCancelDialog(context, ref),
                child: Text(
                  'Cancel',
                  style: IosTypography.body(
                    color: primaryTextColor,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // Emergency Status Inset Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: separatorColor,
                    width: isResolved ? 1.0 : 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isResolved
                              ? CupertinoIcons.checkmark_seal_fill
                              : CupertinoIcons.exclamationmark_triangle_fill,
                          size: 24,
                          color: primaryTextColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isResolved ? 'INCIDENT RESOLVED' : 'EMERGENCY BEACON ACTIVE',
                          style: IosTypography.headline(
                            color: primaryTextColor,
                            weight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isResolved
                          ? 'Police confirmed all safety measures are complete.'
                          : 'Live GPS breadcrumbs streaming every 5s to District Police',
                      textAlign: TextAlign.center,
                      style: IosTypography.subhead(color: secondaryTextColor),
                    ),

                    if (sosState.cancelCountdown > 0 && !isResolved) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.secondarySurfaceDark : AppColors.secondarySurfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: separatorColor),
                        ),
                        child: Text(
                          '${l10n.cancelCountdown} ${sosState.cancelCountdown}s (PIN protected)',
                          style: IosTypography.footnote(
                            color: primaryTextColor,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Active Indicators: Location & Audio
              Row(
                children: [
                  Expanded(
                    child: _IosLiveIndicator(
                      icon: CupertinoIcons.location_fill,
                      label: isResolved ? 'GPS Idle' : l10n.locationSharingLive,
                      isActive: !isResolved,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _IosLiveIndicator(
                      icon: CupertinoIcons.mic_fill,
                      label: isResolved ? 'Recording Saved' : l10n.recordingActive,
                      isActive: !isResolved && sosState.isAudioRecording,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Emergency Response Lifecycle
              Text(
                'Response Lifecycle',
                style: IosTypography.title3(color: primaryTextColor),
              ),
              const SizedBox(height: 14),

              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: separatorColor.withOpacity(0.5), width: 0.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: [
                      _IosStatusStep(
                        stepNumber: 1,
                        title: l10n.statusAlertSent,
                        subtitle: 'GPS coordinates and emergency SMS dispatched',
                        isCompleted: isAlertSent,
                        isCurrent: status == 'triggered',
                      ),
                      Divider(height: 0.5, thickness: 0.5, indent: 56, color: separatorColor),
                      _IosStatusStep(
                        stepNumber: 2,
                        title: l10n.statusPoliceNotified,
                        subtitle: 'Transmitted to Ghaziabad Control Room live feed',
                        isCompleted: isPoliceNotified,
                        isCurrent: status == 'police_notified',
                      ),
                      Divider(height: 0.5, thickness: 0.5, indent: 56, color: separatorColor),
                      _IosStatusStep(
                        stepNumber: 3,
                        title: isAssigned
                            ? 'Patrol Assigned: ${alert?.assignedUnitName ?? 'Unit'}'
                            : l10n.statusHelpAssigned,
                        subtitle: isAssigned
                            ? 'Officer contact: ${alert?.assignedOfficerPhone ?? 'Assigned Officer'}'
                            : 'Nearest patrol unit assigned to coordinates',
                        isCompleted: isAssigned || isResolved,
                        isCurrent: status == 'assigned',
                      ),
                      Divider(height: 0.5, thickness: 0.5, indent: 56, color: separatorColor),
                      _IosStatusStep(
                        stepNumber: 4,
                        title: l10n.statusResolved,
                        subtitle: 'Safety verified and logged in district control record',
                        isCompleted: isResolved,
                        isCurrent: isResolved,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ERSS Complement Notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.secondarySurfaceDark : AppColors.secondarySurfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: separatorColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(CupertinoIcons.info_circle_fill, size: 18, color: primaryTextColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppConstants.policeIntegrationNotice,
                        style: IosTypography.caption1(
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IosLiveIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const _IosLiveIndicator({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? (isDark ? Colors.white : Colors.black)
              : (isDark ? AppColors.separatorDark : AppColors.separatorLight),
          width: isActive ? 1.5 : 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive ? primaryTextColor : secondaryTextColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: IosTypography.footnote(
                color: isActive ? primaryTextColor : secondaryTextColor,
                weight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IosStatusStep extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;

  const _IosStatusStep({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    Widget indicator;
    if (isCompleted && !isCurrent) {
      indicator = Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: isDark ? AppColors.primaryActionDark : AppColors.primaryActionLight,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          CupertinoIcons.checkmark,
          size: 14,
          color: isDark ? AppColors.onPrimaryActionDark : AppColors.onPrimaryActionLight,
        ),
      );
    } else if (isCurrent) {
      indicator = Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? Colors.white : Colors.black,
            width: 2.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '$stepNumber',
          style: IosTypography.caption1(
            color: primaryTextColor,
            weight: FontWeight.w800,
          ),
        ),
      );
    } else {
      indicator = Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          '$stepNumber',
          style: IosTypography.caption1(color: secondaryTextColor),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          indicator,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: IosTypography.body(
                    color: primaryTextColor,
                    weight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: IosTypography.footnote(color: secondaryTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
