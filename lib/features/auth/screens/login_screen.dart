import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/providers/auth_provider.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).sendOtp(phone);
    if (success && mounted) {
      setState(() {
        _otpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SMS OTP sent to +91 $phone'),
          backgroundColor: AppColors.safeGreen,
        ),
      );
    }
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP. Please check and try again.'),
          backgroundColor: AppColors.sosRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurpleSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_android_rounded,
                    size: 48,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.citizenLogin,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.loginPrompt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 36),

              // Mobile Number Input
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: l10n.contactPhone,
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primaryPurple),
                  prefixText: '+91 ',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 16),

              if (!_otpSent) ...[
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleSendOtp,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(l10n.sendOtp),
                ),
              ] else ...[
                // OTP Field
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.enterOtp,
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleVerifyOtp,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(l10n.verifyAndLogin),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _otpSent = false;
                      _otpController.clear();
                    });
                  },
                  child: const Text('Change Phone Number'),
                ),
              ],

              const SizedBox(height: 48),
              const Divider(color: AppColors.dividerLight),
              const SizedBox(height: 20),

              // Officer Login Button
              OutlinedButton.icon(
                icon: const Icon(Icons.local_police_rounded, color: AppColors.policeNavy),
                label: Text(
                  l10n.officerLoginLink,
                  style: const TextStyle(color: AppColors.policeNavy),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.policeNavy, width: 1.5),
                  backgroundColor: AppColors.policeNavySurface.withOpacity(0.4),
                ),
                onPressed: () => context.go('/officer-login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
