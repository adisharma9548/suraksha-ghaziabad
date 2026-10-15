import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/ios_typography.dart';

/// Native iOS Safety Check-in Dialog
/// Apple HIG Cupertino modal with tactile haptics, countdown indicator, and accessible multi-cue choices.
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
      onWillPop: () async => false,
      child: CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.question_diamond_fill, size: 22),
            const SizedBox(width: 8),
            Text('Are you OK?', style: IosTypography.headline()),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Vehicle appears stationary or off-route. Please confirm your safety.',
                style: IosTypography.subhead(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1.5),
                ),
                child: Text(
                  'Auto-dispatching alert in ${secondsRemaining}s',
                  style: IosTypography.footnote(weight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: onTriggerSos,
            child: const Text('TRIGGER SOS'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: onIAmSafe,
            child: const Text('I AM SAFE'),
          ),
        ],
      ),
    );
  }
}
