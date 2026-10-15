import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../data/providers/repository_providers.dart';

/// Native iOS Change Emergency PIN Dialog
class ChangePinDialog extends ConsumerStatefulWidget {
  const ChangePinDialog({super.key});

  @override
  ConsumerState<ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends ConsumerState<ChangePinDialog> {
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final oldPin = _oldPinController.text.trim();
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    final isValidOld =
        await ref.read(authRepositoryProvider).verifyEmergencyPin(oldPin);
    if (!isValidOld) {
      setState(() => _error = 'Current PIN is incorrect');
      return;
    }

    if (newPin.length != 4 || newPin != confirmPin) {
      setState(() => _error = 'New PIN must be 4 digits and match');
      return;
    }

    await ref.read(authRepositoryProvider).changeEmergencyPin(newPin);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;

    return CupertinoAlertDialog(
      title: Text('Change Emergency PIN', style: IosTypography.headline()),
      content: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoTextField(
              controller: _oldPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              placeholder: 'Current 4-Digit PIN',
              style: IosTypography.callout(color: primaryTextColor),
              padding: const EdgeInsets.all(10),
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _newPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              placeholder: 'New 4-Digit PIN',
              style: IosTypography.callout(color: primaryTextColor),
              padding: const EdgeInsets.all(10),
            ),
            const SizedBox(height: 8),
            CupertinoTextField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              placeholder: 'Confirm New PIN',
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
          child: const Text('Update PIN'),
        ),
      ],
    );
  }
}
