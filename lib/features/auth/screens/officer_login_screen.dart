import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../core/widgets/ios_widgets.dart';
import '../../../data/providers/auth_provider.dart';

/// Native iOS Officer Login Screen
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
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Missing Credentials'),
          content: const Text('Please enter both your Officer Identification Code and PIN.'),
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

    final success =
        await ref.read(authProvider.notifier).officerLogin(code, pin);
    if (success && mounted) {
      context.go('/officer');
    } else if (mounted) {
      final error = ref.read(authProvider).errorMessage ?? 'Invalid officer credentials';
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Authentication Failed'),
          content: Text(error),
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
      appBar: AppBar(
        title: Text(l10n.officerPortal, style: IosTypography.headline(color: primaryTextColor)),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
        elevation: 0,
        centerTitle: true,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(CupertinoIcons.chevron_left, color: primaryTextColor),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
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
                      CupertinoIcons.shield_fill,
                      size: 40,
                      color: primaryTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'District Police & Admin Control',
                textAlign: TextAlign.center,
                style: IosTypography.title2(color: primaryTextColor),
              ),
              const SizedBox(height: 4),
              Text(
                'Authorized Police Personnel & Control Room Access',
                textAlign: TextAlign.center,
                style: IosTypography.footnote(color: secondaryTextColor),
              ),
              const SizedBox(height: 28),

              // Security notice banner
              IosCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.lock_fill, size: 18, color: primaryTextColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Restricted Access: Authorized credentials issued by Ghaziabad District Police Administration.',
                        style: IosTypography.caption1(color: secondaryTextColor),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Officer Code Input
              CupertinoTextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                placeholder: 'Officer Identification Code',
                placeholderStyle: IosTypography.callout(color: AppColors.tertiaryTextDark),
                style: IosTypography.callout(color: primaryTextColor),
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(CupertinoIcons.person_badge_plus_fill, size: 18, color: primaryTextColor),
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

              const SizedBox(height: 14),

              // Officer PIN Input
              CupertinoTextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                placeholder: '4-Digit Officer Access PIN',
                placeholderStyle: IosTypography.callout(color: AppColors.tertiaryTextDark),
                style: IosTypography.callout(color: primaryTextColor),
                prefix: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(CupertinoIcons.lock_fill, size: 18, color: primaryTextColor),
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

              const SizedBox(height: 24),

              IosButton(
                text: l10n.loginAsOfficer,
                icon: CupertinoIcons.arrow_right_circle_fill,
                isLoading: authState.isLoading,
                onPressed: _handleOfficerLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
