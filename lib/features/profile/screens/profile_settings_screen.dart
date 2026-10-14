import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/settings_provider.dart';
import 'change_pin_dialog.dart';

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  void _showChangePinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const ChangePinDialog(),
    ).then((updated) {
      if (updated == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency PIN updated successfully!'),
            backgroundColor: AppColors.safeGreen,
          ),
        );
      }
    });
  }

  void _showDeleteDataConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Safety Data?'),
        content: const Text(
          'This will permanently delete your profile, emergency PIN, and registered trusted contacts from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.sosRed),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).deleteMyData();
              if (context.mounted) {
                context.go('/language');
              }
            },
            child: const Text('DELETE FOREVER'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    final user = authState.user;
    final userName = user?.name ?? 'Aditi Sharma';
    final userPhone = user?.phone ?? '+91 98765 43210';
    final isHindi = settings.locale.languageCode == 'hi';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileAndSettings),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // User Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.dividerLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primaryPurpleSurface,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          userPhone,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.safeGreenLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'PROTECTED CITIZEN',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.safeGreenDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Emergency Configuration Section
            const Text(
              'Emergency Controls',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.people_outline, color: AppColors.primaryPurple),
                    title: Text(l10n.editTrustedContacts),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/edit-contacts'),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.lock_outline, color: AppColors.primaryPurple),
                    title: Text(l10n.changeEmergencyPin),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showChangePinDialog(context),
                  ),
                  const Divider(height: 1, indent: 56),
                  SwitchListTile(
                    secondary: const Icon(Icons.vibration_rounded, color: AppColors.primaryPurple),
                    title: Text(l10n.shakeTriggerTitle),
                    subtitle: Text(l10n.shakeTriggerDesc, style: const TextStyle(fontSize: 11)),
                    value: settings.isShakeEnabled,
                    activeColor: AppColors.primaryPurple,
                    onChanged: (val) => settingsNotifier.toggleShake(val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Preferences & Privacy
            const Text(
              'Preferences & Legal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language_rounded, color: AppColors.primaryPurple),
                    title: Text(l10n.selectLanguage),
                    trailing: Text(
                      isHindi ? 'हिंदी' : 'English',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple),
                    ),
                    onTap: () {
                      settingsNotifier.setLocale(
                        isHindi ? const Locale('en') : const Locale('hi'),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primaryPurple),
                    title: Text(l10n.privacyPolicy),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/privacy-policy'),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.delete_forever_rounded, color: AppColors.sosRed),
                    title: Text(
                      l10n.deleteMyData,
                      style: const TextStyle(color: AppColors.sosRed, fontWeight: FontWeight.bold),
                    ),
                    onTap: () => _showDeleteDataConfirmation(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
