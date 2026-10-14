import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/providers/sos_provider.dart';
import '../../../data/providers/settings_provider.dart';
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
    final isDemoMode = ref.watch(settingsProvider).isDemoMode;

    final status = alert?.status ?? 'triggered';
    final isResolved = status == 'resolved';
    final isAssigned = status == 'assigned';
    final isPoliceNotified = status == 'police_notified' || isAssigned || isResolved;
    final isAlertSent = true;

    return WillPopScope(
      onWillPop: () async {
        // Prevent accidental back press during active SOS
        if (alert != null && alert.isActive) {
          _showCancelDialog(context, ref);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            isResolved ? 'SOS Incident Resolved' : l10n.sosActiveStatus,
            style: TextStyle(
              color: isResolved ? AppColors.safeGreen : AppColors.sosRed,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            if (alert != null && alert.isActive)
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.sosRed),
                tooltip: 'Cancel SOS with PIN',
                onPressed: () => _showCancelDialog(context, ref),
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                    // Emergency Status Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isResolved
                              ? [AppColors.safeGreenLight, Colors.white]
                              : [AppColors.sosRedLight, Colors.white],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isResolved ? AppColors.safeGreen : AppColors.sosRed,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isResolved ? AppColors.safeGreen : AppColors.sosRed)
                                .withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            isResolved
                                ? Icons.check_circle_rounded
                                : Icons.warning_rounded,
                            size: 64,
                            color: isResolved ? AppColors.safeGreen : AppColors.sosRed,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isResolved
                                ? 'SITUATION RESOLVED'
                                : 'POLICE DISPATCH INITIATED',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isResolved
                                  ? AppColors.safeGreenDark
                                  : AppColors.sosRedDark,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isResolved
                                ? 'Patrol unit confirmed on-scene resolution. Location streaming and evidence recording stopped.'
                                : 'High priority distress beacon broadcasting to UP Dial 112 Control Room & Trusted Circles.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondaryLight,
                              height: 1.35,
                            ),
                          ),

                          // 5-Second Cancel Countdown
                          if (!isResolved && sosState.cancelCountdown > 0) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.sosRed,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${l10n.cancelCountdown} ${sosState.cancelCountdown}s',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Active Indicators: Location & Recording
                    Row(
                      children: [
                        Expanded(
                          child: _LiveIndicator(
                            icon: Icons.my_location_rounded,
                            label: isResolved
                                ? 'GPS Sharing Idle'
                                : l10n.locationSharingLive,
                            isActive: !isResolved,
                            activeColor: AppColors.sosRed,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _LiveIndicator(
                            icon: Icons.mic_rounded,
                            label: isResolved
                                ? 'Recording Saved'
                                : l10n.recordingActive,
                            isActive: !isResolved && sosState.isAudioRecording,
                            activeColor: AppColors.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Live Status Progression Steps
                    Text(
                      'Emergency Response Lifecycle',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 14),

                    _StatusStep(
                      stepNumber: 1,
                      title: l10n.statusAlertSent,
                      subtitle: 'GPS coordinates and emergency SMS dispatched',
                      isCompleted: isAlertSent,
                      isCurrent: status == 'triggered',
                    ),
                    _StatusStep(
                      stepNumber: 2,
                      title: l10n.statusPoliceNotified,
                      subtitle: 'Transmitted to Ghaziabad Control Room live feed',
                      isCompleted: isPoliceNotified,
                      isCurrent: status == 'police_notified',
                    ),
                    _StatusStep(
                      stepNumber: 3,
                      title: isAssigned
                          ? 'Help is on the way: ${alert?.assignedUnitName ?? 'Cheetah-12'}'
                          : l10n.statusHelpAssigned,
                      subtitle: isAssigned
                          ? 'Officer contact: ${alert?.assignedOfficerPhone ?? '+91-9871023401'}'
                          : 'Nearest patrol vehicle assigned to your coordinates',
                      isCompleted: isAssigned || isResolved,
                      isCurrent: status == 'assigned',
                      highlight: isAssigned,
                    ),
                    _StatusStep(
                      stepNumber: 4,
                      title: l10n.statusResolved,
                      subtitle: 'Safety verified and logged in district heatmap',
                      isCompleted: isResolved,
                      isCurrent: isResolved,
                    ),

                    // Demo Mode Response Simulation Button
                    if (isDemoMode && !isResolved) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPurpleSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primaryPurple.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.smart_toy_rounded,
                                    color: AppColors.primaryPurple, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Pitch Demo Control',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryPurpleDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Advance through the response lifecycle stages to demonstrate control room dispatch & unit arrival.',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.textSecondaryLight),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryPurple,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                minimumSize: const Size(double.infinity, 44),
                              ),
                              icon: const Icon(Icons.fast_forward_rounded, size: 18),
                              label: Text(l10n.simulateOfficerResponse),
                              onPressed: () {
                                ref
                                    .read(sosProvider.notifier)
                                    .simulateOfficerResponse();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Bottom Cancel / Done action button
              Padding(
                padding: const EdgeInsets.all(16),
                child: isResolved
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.safeGreen,
                        ),
                        onPressed: () => context.go('/citizen'),
                        child: const Text('Back to Home'),
                      )
                    : OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.sosRed,
                          side: const BorderSide(color: AppColors.sosRed, width: 2),
                        ),
                        icon: const Icon(Icons.lock_reset_rounded),
                        label: Text(l10n.cancelAlertButton),
                        onPressed: () => _showCancelDialog(context, ref),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;

  const _LiveIndicator({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? activeColor : AppColors.dividerLight,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? activeColor : AppColors.textHintLight,
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isActive ? activeColor : AppColors.textHintLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;
  final bool highlight;

  const _StatusStep({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isCurrent,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    Color stepColor;
    if (isCompleted) {
      stepColor = AppColors.safeGreen;
    } else if (isCurrent) {
      stepColor = AppColors.primaryPurple;
    } else {
      stepColor = AppColors.textHintLight;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.safeGreenLight
            : (isCurrent ? AppColors.primaryPurpleSurface : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? AppColors.safeGreen
              : (isCurrent ? AppColors.primaryPurple : AppColors.dividerLight),
          width: isCurrent || highlight ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: stepColor,
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '$stepNumber',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: highlight
                        ? AppColors.safeGreenDark
                        : (isCurrent
                            ? AppColors.primaryPurpleDark
                            : AppColors.textPrimaryLight),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
