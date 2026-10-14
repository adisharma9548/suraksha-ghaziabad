import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/repository_providers.dart';

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
      setState(() => _error = 'New PIN must be 4 digits and match confirmation');
      return;
    }

    await ref.read(authRepositoryProvider).changeEmergencyPin(newPin);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Change Emergency PIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _oldPinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Current PIN', counterText: ''),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newPinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'New 4-Digit PIN', counterText: ''),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmPinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm New PIN',
              counterText: '',
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          child: const Text('Update PIN'),
        ),
      ],
    );
  }
}
