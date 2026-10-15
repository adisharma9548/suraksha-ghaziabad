import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../data/providers/repository_providers.dart';

/// Native iOS Change Duress PIN Dialog
class ChangeDuressPinDialog extends ConsumerStatefulWidget {
  const ChangeDuressPinDialog({super.key});

  @override
  ConsumerState<ChangeDuressPinDialog> createState() =>
      _ChangeDuressPinDialogState();
}

class _ChangeDuressPinDialogState extends ConsumerState<ChangeDuressPinDialog> {
  final _emergencyPinController = TextEditingController();
  final _newDuressPinController = TextEditingController();
  final _confirmDuressPinController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _emergencyPinController.dispose();
    _newDuressPinController.dispose();
    _confirmDuressPinController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final emergencyPin = _emergencyPinController.text.trim();
    final newDuressPin = _newDuressPinController.text.trim();
    final confirmDuressPin = _confirmDuressPinController.text.trim();

    final isValidEmergency = await ref
        .read(authRepositoryProvider)
        .verifyEmergencyPin(emergencyPin);
    if (!isValidEmergency) {
      setState(() => _error = 'Current emergency PIN is incorrect');
      return;
    }

    if (newDuressPin.length != 4 || newDuressPin != confirmDuressPin) {
      setState(() => _error = 'Duress PIN must be 4 digits and match confirmation');
      return;
    }

    if (newDuressPin == emergencyPin) {
      setState(() => _error = 'Duress PIN must differ from emergency PIN');
      return;
    }

    await ref.read(authRepositoryProvider).changeDuressPin(newDuressPin);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    return CupertinoAlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.exclamationmark_shield_fill, size: 20),
          const SizedBox(width: 8),
          Text('Set Decoy Duress PIN', style: IosTypography.headline()),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'A covert PIN entered if coerced by an attacker. It silently alerts the control room while appearing to cancel the alarm.',
              style: IosTypography.caption1(color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: _emergencyPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              placeholder: 'Current Emergency PIN',
              style: IosTypography.callout(color: primaryTextColor),
              padding: const EdgeInsets.all(10),
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _newDuressPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              placeholder: 'New 4-Digit Duress PIN',
              style: IosTypography.callout(color: primaryTextColor),
              padding: const EdgeInsets.all(10),
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _confirmDuressPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              placeholder: 'Confirm Duress PIN',
              style: IosTypography.callout(color: primaryTextColor),
              padding: const EdgeInsets.all(10),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: IosTypography.caption1(
                  color: isDark ? AppColors.primaryTextDark : const Color(0xFF1C1C1E),
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ],
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
          child: const Text('Save Duress PIN'),
        ),
      ],
    );
  }
}
