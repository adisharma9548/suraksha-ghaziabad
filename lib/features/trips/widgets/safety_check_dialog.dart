import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

class SafetyCheckDialog extends StatelessWidget {
  final int secondsRemaining;
  final VoidCallback onIAmSafe;
  final VoidCallback onTriggerSos;

  const SafetyCheckDialog({
    super.key,
    required this.secondsRemaining,
    required this.onIAmSafe,
    required this.onTriggerSos,
  });

  @override
  Widget build(BuildContext context) {
    HapticFeedback.heavyImpact();

    return WillPopScope(
      onWillPop: () async => false, // Cannot dismiss without answering
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Row(
          children: const [
            Icon(Icons.health_and_safety_rounded, color: AppColors.warningAmberDark, size: 28),
            SizedBox(width: 10),
            Text('Are you OK?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your vehicle appears stationary or off-route. Please confirm your safety.',
              style: TextStyle(fontSize: 13, color: AppColors.textPrimaryLight, height: 1.35),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.sosRedLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.sosRed.withOpacity(0.4)),
              ),
              child: Text(
                'Auto-alerting emergency contacts in: ${secondsRemaining}s',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.sosRedDark,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.sosRed,
                    side: const BorderSide(color: AppColors.sosRed, width: 1.5),
                  ),
                  onPressed: onTriggerSos,
                  child: const Text('TRIGGER SOS'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.safeGreen,
                  ),
                  onPressed: onIAmSafe,
                  child: const Text('I AM SAFE'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
