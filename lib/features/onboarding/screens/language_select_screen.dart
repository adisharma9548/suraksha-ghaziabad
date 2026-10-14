import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/providers/settings_provider.dart';

class LanguageSelectScreen extends ConsumerWidget {
  const LanguageSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context);
    final isHindi = settings.locale.languageCode == 'hi';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectLanguage),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurpleSurface,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.translate_rounded,
                    size: 40,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.choosePreferredLanguage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondaryLight,
                ),
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
              ElevatedButton(
                onPressed: () => context.go('/consent'),
                child: Text(l10n.continueText),
              ),
              const SizedBox(height: 16),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryPurpleSurface
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primaryPurple : AppColors.dividerLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primaryPurple
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? AppColors.primaryPurpleDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? AppColors.primaryPurple : AppColors.textHintLight,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}
