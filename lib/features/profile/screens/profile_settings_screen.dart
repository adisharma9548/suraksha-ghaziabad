import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../core/widgets/ios_widgets.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/settings_provider.dart';
import 'change_duress_pin_dialog.dart';
import 'change_pin_dialog.dart';

/// Native iOS Profile and Settings Screen
/// Apple HIG Grouped Inset lists, SF Pro typography, and color-blind safe multi-cue indicators.
class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  void _showChangePinDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => const ChangePinDialog(),
    ).then((updated) {
      if (updated == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency PIN updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _showChangeDuressPinDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => const ChangeDuressPinDialog(),
    ).then((updated) {
      if (updated == true && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Decoy Duress PIN configured successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _showDeleteDataConfirmation(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete All Safety Data?'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'This will permanently remove your profile, emergency PIN, and registered trusted contacts from this device.',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete Forever'),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authProvider.notifier).deleteMyData();
              if (context.mounted) {
                context.go('/language');
              }
            },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;
    final separatorColor = isDark ? AppColors.separatorDark : AppColors.separatorLight;

    final user = authState.user;
    final userName = user?.name ?? 'Aditi Sharma';
    final userPhone = user?.phone ?? '+91 98765 43210';
    final isHindi = settings.locale.languageCode == 'hi';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
      appBar: AppBar(
        title: Text(l10n.profileAndSettings, style: IosTypography.headline(color: primaryTextColor)),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            // User Profile Header Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: IosCard(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.secondarySurfaceDark : AppColors.secondarySurfaceLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: separatorColor),
                      ),
                      child: Center(
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                          style: IosTypography.title1(color: primaryTextColor),
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
                            style: IosTypography.title3(color: primaryTextColor),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userPhone,
                            style: IosTypography.subhead(color: secondaryTextColor),
                          ),
                          const SizedBox(height: 6),
                          IosBadge(
                            label: 'PROTECTED CITIZEN',
                            icon: CupertinoIcons.checkmark_shield_fill,
                            type: IosBadgeType.success,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Inset Section 1: Emergency Controls
            IosGroupedSection(
              header: 'EMERGENCY CONTROLS',
              footer: 'Decoy duress PIN enables silent distress transmission if coerced by an aggressor.',
              children: [
                IosListTile(
                  leadingIcon: CupertinoIcons.person_2_fill,
                  title: l10n.editTrustedContacts,
                  trailing: Icon(CupertinoIcons.chevron_right, size: 14, color: secondaryTextColor),
                  onTap: () => context.push('/edit-contacts'),
                ),
                IosListTile(
                  leadingIcon: CupertinoIcons.lock_shield_fill,
                  title: l10n.changeEmergencyPin,
                  trailing: Icon(CupertinoIcons.chevron_right, size: 14, color: secondaryTextColor),
                  onTap: () => _showChangePinDialog(context),
                ),
                IosListTile(
                  leadingIcon: CupertinoIcons.exclamationmark_shield_fill,
                  title: 'Configure Decoy Duress PIN',
                  subtitle: 'Silent covert cancellation code under duress',
                  trailing: Icon(CupertinoIcons.chevron_right, size: 14, color: secondaryTextColor),
                  onTap: () => _showChangeDuressPinDialog(context),
                ),
                IosListTile(
                  showDivider: false,
                  leadingIcon: CupertinoIcons.waveform_path,
                  title: l10n.shakeTriggerTitle,
                  subtitle: l10n.shakeTriggerDesc,
                  trailing: CupertinoSwitch(
                    value: settings.isShakeEnabled,
                    activeColor: primaryTextColor,
                    onChanged: (val) => settingsNotifier.toggleShake(val),
                  ),
                ),
              ],
            ),

            // Inset Section 2: Preferences & Legal
            IosGroupedSection(
              header: 'PREFERENCES & LEGAL',
              children: [
                IosListTile(
                  leadingIcon: CupertinoIcons.globe,
                  title: l10n.selectLanguage,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isHindi ? 'हिंदी' : 'English',
                        style: IosTypography.subhead(color: AppColors.accentBlue),
                      ),
                      const SizedBox(width: 4),
                      Icon(CupertinoIcons.chevron_right, size: 14, color: secondaryTextColor),
                    ],
                  ),
                  onTap: () {
                    settingsNotifier.setLocale(
                      isHindi ? const Locale('en') : const Locale('hi'),
                    );
                  },
                ),
                IosListTile(
                  leadingIcon: CupertinoIcons.doc_text_fill,
                  title: l10n.privacyPolicy,
                  trailing: Icon(CupertinoIcons.chevron_right, size: 14, color: secondaryTextColor),
                  onTap: () => context.push('/privacy-policy'),
                ),
                IosListTile(
                  showDivider: false,
                  leadingIcon: CupertinoIcons.trash_fill,
                  title: l10n.deleteMyData,
                  subtitle: 'Permanently purge local registration credentials',
                  trailing: Icon(CupertinoIcons.chevron_right, size: 14, color: secondaryTextColor),
                  onTap: () => _showDeleteDataConfirmation(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
