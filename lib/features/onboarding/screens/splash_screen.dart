import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../data/providers/repository_providers.dart';

/// Native iOS Splash Screen
/// Apple HIG minimalist launch presentation with restrained spring animation and greyscale tokens.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();
    _checkNextScreen();
  }

  Future<void> _checkNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final prefs = ref.read(sharedPreferencesProvider);
    final hasConsented = prefs.getBool(AppConstants.keyConsentGiven) ?? false;
    final currentUser = await ref.read(authRepositoryProvider).getCurrentUser();

    if (!hasConsented) {
      context.go('/language');
    } else if (currentUser != null) {
      if (currentUser.isOfficer) {
        context.go('/officer');
      } else {
        context.go('/citizen');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/images/app_logo.png',
                        width: 130,
                        height: 130,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            CupertinoIcons.shield_lefthalf_fill,
                            size: 56,
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Suraksha Ghaziabad',
                      style: IosTypography.largeTitle(color: primaryTextColor),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'आपकी सुरक्षा, हमारी ज़िम्मेदारी',
                      style: IosTypography.callout(color: secondaryTextColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Safe City for Women • UP Police & Nagar Nigam',
                      style: IosTypography.footnote(color: AppColors.tertiaryTextDark),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              CupertinoActivityIndicator(
                radius: 12,
                color: primaryTextColor,
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
