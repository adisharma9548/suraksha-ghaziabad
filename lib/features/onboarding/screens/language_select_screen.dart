import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../core/widgets/ios_widgets.dart';
import '../../../data/providers/settings_provider.dart';

/// Native iOS Language Select Screen
class LanguageSelectScreen extends ConsumerWidget {
  const LanguageSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context);
    final isHindi = settings.locale.languageCode == 'hi';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      CupertinoIcons.globe,
                      size: 36,
                      color: primaryTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select Language',
                textAlign: TextAlign.center,
                style: IosTypography.title1(color: primaryTextColor),
              ),
              const SizedBox(height: 6),
              Text(
                'Choose your preferred language for safety alerts and navigation.',
                textAlign: TextAlign.center,
                style: IosTypography.subhead(color: secondaryTextColor),
              ),
              const SizedBox(height: 36),

              _LanguageCard(
                title: 'English',
                subtitle: 'Safe City for Women Initiative',
                isSelected: !isHindi,
                onTap: () {
                  ref.read(settingsProvider.notifier).setLocale(const Locale('en'));
                },
              ),
              const SizedBox(height: 16),
              _LanguageCard(
                title: 'हिंदी (Hindi)',
                subtitle: 'आपकी सुरक्षा, हमारी ज़िम्मेदारी',
                isSelected: isHindi,
                onTap: () {
                  ref.read(settingsProvider.notifier).setLocale(const Locale('hi'));
                },
              ),

              const Spacer(),
              IosButton(
                text: l10n.continueText,
                icon: CupertinoIcons.arrow_right,
                onPressed: () => context.go('/consent'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? primaryTextColor
                : (isDark ? AppColors.separatorDark : AppColors.separatorLight),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: IosTypography.headline(
                      color: primaryTextColor,
                      weight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: IosTypography.footnote(color: secondaryTextColor),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: primaryTextColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    CupertinoIcons.checkmark,
                    size: 16,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                ),
              )
            else
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                    width: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
