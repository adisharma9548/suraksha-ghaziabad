import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/repository_providers.dart';

class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _agreedToTerms = false;

  Future<void> _handleAccept() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.keyConsentGiven, true);
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.safetyPermissions),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  Text(
                    l10n.permissionsSubtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondaryLight,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Location (Highlight: only shared during SOS or Trip)
                  _PermissionTile(
                    icon: Icons.location_on_rounded,
                    iconColor: AppColors.sosRed,
                    title: l10n.locationPermissionTitle,
                    description: l10n.locationPermissionDesc,
                    isCritical: true,
                  ),

                  // Microphone / Audio
                  _PermissionTile(
                    icon: Icons.mic_rounded,
                    iconColor: AppColors.primaryPurple,
                    title: l10n.audioPermissionTitle,
                    description: l10n.audioPermissionDesc,
                  ),

                  // Offline SMS
                  _PermissionTile(
                    icon: Icons.sms_rounded,
                    iconColor: AppColors.infoBlue,
                    title: l10n.smsPermissionTitle,
                    description: l10n.smsPermissionDesc,
                  ),

                  // Notifications
                  _PermissionTile(
                    icon: Icons.notifications_active_rounded,
                    iconColor: AppColors.warningAmber,
                    title: l10n.notificationPermissionTitle,
                    description: l10n.notificationPermissionDesc,
                  ),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurpleSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryPurple.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.primaryPurple,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppConstants.policeIntegrationNotice,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryPurpleDark,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _agreedToTerms,
                    onChanged: (val) {
                      setState(() {
                        _agreedToTerms = val ?? false;
                      });
                    },
                    activeColor: AppColors.primaryPurple,
                    title: Text(
                      l10n.consentDisclaimer,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ElevatedButton(
                onPressed: _agreedToTerms ? _handleAccept : null,
                child: Text(l10n.acceptAndContinue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool isCritical;

  const _PermissionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.isCritical = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCritical
              ? iconColor.withOpacity(0.4)
              : AppColors.dividerLight,
          width: isCritical ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    if (isCritical) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.sosRedLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'MANDATORY',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.sosRedDark,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryLight,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
