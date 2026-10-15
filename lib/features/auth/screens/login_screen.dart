import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../core/widgets/ios_widgets.dart';
import '../../../data/providers/auth_provider.dart';

/// Native iOS Citizen Login Screen
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Invalid Mobile Number'),
          content: const Text('Please enter a valid 10-digit mobile number.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).sendOtp(phone);
    if (success && mounted) {
      setState(() => _otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SMS OTP sent to +91 $phone'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Incomplete OTP'),
          content: const Text('Please enter the 6-digit OTP received via SMS.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).verifyOtp(otp);
    if (success && mounted) {
      final user = ref.read(authProvider).user;
      if (user != null && user.name.isNotEmpty) {
        context.go('/citizen');
      } else {
        context.go('/profile-setup');
      }
    } else if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Verification Failed'),
          content: const Text('Invalid OTP. Please check the code and try again.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 36),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.secondarySurfaceLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      CupertinoIcons.device_phone_portrait,
                      size: 40,
                      color: primaryTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.citizenLogin,
                textAlign: TextAlign.center,
                style: IosTypography.title1(color: primaryTextColor),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.loginPrompt,
                textAlign: TextAlign.center,
                style: IosTypography.subhead(color: secondaryTextColor),
              ),
              const SizedBox(height: 36),

              // Mobile Number Input Field
              CupertinoTextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                placeholder: '10-digit mobile number',
                placeholderStyle: IosTypography.callout(color: AppColors.tertiaryTextDark),
                style: IosTypography.callout(color: primaryTextColor),
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Text(
                    '+91 ',
                    style: IosTypography.headline(color: primaryTextColor),
                  ),
                ),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              if (!_otpSent) ...[
                IosButton(
                  text: l10n.sendOtp,
                  icon: CupertinoIcons.arrow_right_circle_fill,
                  isLoading: authState.isLoading,
                  onPressed: _handleSendOtp,
                ),
              ] else ...[
                CupertinoTextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  placeholder: 'Enter 6-digit OTP',
                  placeholderStyle: IosTypography.callout(color: AppColors.tertiaryTextDark),
                  style: IosTypography.title2(color: primaryTextColor),
                  textAlign: TextAlign.center,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                IosButton(
                  text: l10n.verifyAndLogin,
                  icon: CupertinoIcons.checkmark_seal_fill,
                  isLoading: authState.isLoading,
                  onPressed: _handleVerifyOtp,
                ),
                const SizedBox(height: 12),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(
                    'Change mobile number',
                    style: IosTypography.subhead(color: AppColors.accentBlue),
                  ),
                  onPressed: () => setState(() => _otpSent = false),
                ),
              ],

              const SizedBox(height: 48),

              // Officer Login Shortcut
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Police & Administrative Staff',
                      style: IosTypography.footnote(color: secondaryTextColor),
                    ),
                    const SizedBox(height: 6),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.shield_fill, size: 16, color: primaryTextColor),
                          const SizedBox(width: 6),
                          Text(
                            l10n.officerLoginLink,
                            style: IosTypography.headline(color: primaryTextColor),
                          ),
                        ],
                      ),
                      onPressed: () => context.go('/officer-login'),
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
