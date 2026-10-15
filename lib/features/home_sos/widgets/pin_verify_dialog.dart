import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';

/// Apple HIG Native PIN Verification Modal
/// Enforces secure cancellation with native Cupertino dialog aesthetics.
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
      setState(() => _error = 'Enter 4-digit PIN');
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
        _error = 'Incorrect PIN';
      });
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
        children: const [
          Icon(CupertinoIcons.lock_shield_fill, size: 22),
          SizedBox(width: 8),
          Text('Cancel SOS Alert'),
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your 4-digit emergency or duress PIN to cancel this distress transmission:',
              style: IosTypography.footnote(color: secondaryTextColor),
            ),
            const SizedBox(height: 14),
            CupertinoTextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              textAlign: TextAlign.center,
              autofocus: true,
              style: IosTypography.title2(
                color: primaryTextColor,
                weight: FontWeight.bold,
              ).copyWith(letterSpacing: 10),
              placeholder: '••••',
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.secondarySurfaceDark : AppColors.secondarySurfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _error != null
                      ? (isDark ? Colors.white : Colors.black)
                      : (isDark ? AppColors.separatorDark : AppColors.separatorLight),
                  width: _error != null ? 1.5 : 0.8,
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.exclamationmark_circle_fill, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    _error!,
                    style: IosTypography.caption1(
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Dismiss'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: _isLoading ? null : _handleConfirm,
          child: _isLoading
              ? const CupertinoActivityIndicator()
              : const Text('Confirm PIN'),
        ),
      ],
    );
  }
}
