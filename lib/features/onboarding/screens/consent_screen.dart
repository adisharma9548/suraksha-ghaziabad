import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../core/widgets/ios_widgets.dart';
import '../../../data/providers/repository_providers.dart';

/// Native iOS Consent & Permissions Screen
/// Transparent privacy disclosure with Apple HIG grouped insets, SF Pro scale, and color-blind safe multi-cue tiles.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
      appBar: AppBar(
        title: Text(l10n.safetyPermissions, style: IosTypography.headline(color: primaryTextColor)),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      l10n.permissionsSubtitle,
                      style: IosTypography.subhead(color: secondaryTextColor),
                    ),
                  ),

                  // Inset Section: Permissions
                  IosGroupedSection(
                    header: 'REQUIRED SAFETY CAPABILITIES',
                    footer: 'Location is streamed strictly during an active emergency SOS or safe trip, never continuously.',
                    children: [
                      IosListTile(
                        leadingIcon: CupertinoIcons.location_fill,
                        title: l10n.locationPermissionTitle,
                        subtitle: l10n.locationPermissionDesc,
                        trailing: IosBadge(
                          label: 'Mandatory',
                          icon: CupertinoIcons.exclamationmark_circle_fill,
                          type: IosBadgeType.warning,
                        ),
                      ),
                      IosListTile(
                        leadingIcon: CupertinoIcons.mic_fill,
                        title: l10n.audioPermissionTitle,
                        subtitle: l10n.audioPermissionDesc,
                      ),
                      IosListTile(
                        leadingIcon: CupertinoIcons.bubble_left_bubble_right_fill,
                        title: l10n.smsPermissionTitle,
                        subtitle: l10n.smsPermissionDesc,
                      ),
                      IosListTile(
                        showDivider: false,
                        leadingIcon: CupertinoIcons.bell_fill,
                        title: l10n.notificationPermissionTitle,
                        subtitle: l10n.notificationPermissionDesc,
                      ),
                    ],
                  ),

                  // Notice Card: Police & Civic Disclaimer
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: IosCard(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            CupertinoIcons.shield_lefthalf_fill,
                            size: 20,
                            color: primaryTextColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppConstants.policeIntegrationNotice,
                              style: IosTypography.footnote(
                                color: secondaryTextColor,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Consent Agreement Inset Tile
                  IosGroupedSection(
                    children: [
                      IosListTile(
                        showDivider: false,
                        leadingIcon: CupertinoIcons.checkmark_shield_fill,
                        title: 'I acknowledge the privacy terms',
                        subtitle: l10n.consentDisclaimer,
                        trailing: CupertinoSwitch(
                          value: _agreedToTerms,
                          activeColor: primaryTextColor,
                          onChanged: (val) => setState(() => _agreedToTerms = val),
                        ),
                        onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Accept and Continue Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: IosButton(
                text: l10n.acceptAndContinue,
                icon: CupertinoIcons.checkmark_alt,
                onPressed: _agreedToTerms ? _handleAccept : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
