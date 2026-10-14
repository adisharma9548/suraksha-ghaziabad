import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/providers/auth_provider.dart';

class OfficerLoginScreen extends ConsumerStatefulWidget {
  const OfficerLoginScreen({super.key});

  @override
  ConsumerState<OfficerLoginScreen> createState() => _OfficerLoginScreenState();
}

class _OfficerLoginScreenState extends ConsumerState<OfficerLoginScreen> {
  final _codeController = TextEditingController();
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleOfficerLogin() async {
    final code = _codeController.text.trim();
    final pin = _pinController.text.trim();

    if (code.isEmpty || pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Officer Code and PIN')),
      );
      return;
    }

    final success =
        await ref.read(authProvider.notifier).officerLogin(code, pin);
    if (success && mounted) {
      context.go('/officer');
    } else if (mounted) {
      final error = ref.read(authProvider).errorMessage ?? 'Invalid officer credentials';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
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
      appBar: AppBar(
        title: Text(l10n.officerPortal),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    color: AppColors.policeNavySurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.badge_rounded,
                    size: 48,
                    color: AppColors.policeNavy,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'District Police & Admin Control',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.policeNavy,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Authorized Police Personnel & Control Room Access',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 28),

              // Security notice banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.policeNavySurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.policeNavy.withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.security_rounded, color: AppColors.policeNavy, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Restricted Access: Authorized credentials issued by Ghaziabad District Police Administration.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.policeNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: l10n.officerCode,
                  prefixIcon: const Icon(Icons.person_pin_rounded, color: AppColors.policeNavy),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: l10n.officerPin,
                  prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.policeNavy),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.policeNavy,
                ),
                onPressed: authState.isLoading ? null : _handleOfficerLogin,
                child: authState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(l10n.loginAsOfficer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
