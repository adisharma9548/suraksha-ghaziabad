import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PinVerifyDialog extends StatefulWidget {
  final Future<bool> Function(String pin) onVerify;

  const PinVerifyDialog({super.key, required this.onVerify});

  @override
  State<PinVerifyDialog> createState() => _PinVerifyDialogState();
}

class _PinVerifyDialogState extends State<PinVerifyDialog> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    final pin = _pinController.text.trim();
    if (pin.length != 4) {
      setState(() => _error = 'Enter your 4-digit PIN');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await widget.onVerify(pin);
    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Incorrect Emergency PIN';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: const [
          Icon(Icons.lock_rounded, color: AppColors.primaryPurple, size: 26),
          SizedBox(width: 10),
          Text('Cancel SOS Alert', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'To prevent unauthorized or coerced cancellation, enter your emergency PIN:',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pinController,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: '••••',
              counterText: '',
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Dismiss'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.sosRed),
          onPressed: _isLoading ? null : _handleConfirm,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Confirm Cancel'),
        ),
      ],
    );
  }
}
