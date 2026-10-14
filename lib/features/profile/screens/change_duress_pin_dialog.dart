import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/repository_providers.dart';

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

    // Verify identity with emergency PIN
    final isValidEmergency = await ref
        .read(authRepositoryProvider)
        .verifyEmergencyPin(emergencyPin);
    if (!isValidEmergency) {
      setState(() => _error = 'Your emergency PIN is incorrect');
      return;
    }

    if (newDuressPin.length != 4 || newDuressPin != confirmDuressPin) {
      setState(
          () => _error = 'Duress PIN must be 4 digits and match confirmation');
      return;
    }

    if (newDuressPin == emergencyPin) {
      setState(() =>
          _error = 'Duress PIN must be different from your emergency PIN');
      return;
    }

    await ref.read(authRepositoryProvider).changeDuressPin(newDuressPin);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.shield_outlined, color: AppColors.sosRed),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Set Decoy Duress PIN',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A decoy PIN used when coerced by an attacker. Entering it appears to cancel the alarm, but secretly alerts police control room and keeps live GPS tracking on.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, height: 1.35),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emergencyPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Verify Current Emergency PIN',
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newDuressPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New 4-Digit Duress PIN',
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmDuressPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Duress PIN',
                counterText: '',
                errorText: _error,
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
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.sosRed),
          onPressed: _handleSave,
          child: const Text('Save Duress PIN'),
        ),
      ],
    );
  }
}
