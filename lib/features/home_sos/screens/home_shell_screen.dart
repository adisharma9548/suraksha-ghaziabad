import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../core/l10n/app_localizations.dart';
import 'home_screen.dart';
import '../../map/screens/safety_map_screen.dart';
import '../../reports/screens/report_unsafe_spot_screen.dart';
import '../../trips/screens/trip_sharing_screen.dart';
import '../../profile/screens/profile_settings_screen.dart';

class HomeShellScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const HomeShellScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends ConsumerState<HomeShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  void _onNavigateTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      HomeScreen(onNavigateTab: _onNavigateTab),
      const SafetyMapScreen(),
      const ReportUnsafeSpotScreen(),
      const TripSharingScreen(),
      const ProfileSettingsScreen(),
    ];

    final activeColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final inactiveColor = isDark ? AppColors.tertiaryTextDark : AppColors.tertiaryTextLight;
    final barBg = isDark
        ? AppColors.backgroundDark.withOpacity(0.85)
        : AppColors.backgroundLight.withOpacity(0.85);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: barBg,
              border: Border(
                top: BorderSide(
                  color: (isDark ? AppColors.separatorDark : AppColors.separatorLight).withOpacity(0.5),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 52,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTabItem(
                      index: 0,
                      label: l10n.navHome,
                      icon: CupertinoIcons.shield,
                      activeIcon: CupertinoIcons.shield_fill,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),
                    _buildTabItem(
                      index: 1,
                      label: l10n.navMap,
                      icon: CupertinoIcons.map,
                      activeIcon: CupertinoIcons.map_fill,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),
                    _buildTabItem(
                      index: 2,
                      label: l10n.navReport,
                      icon: CupertinoIcons.exclamationmark_bubble,
                      activeIcon: CupertinoIcons.exclamationmark_bubble_fill,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),
                    _buildTabItem(
                      index: 3,
                      label: l10n.navTrips,
                      icon: CupertinoIcons.location_north,
                      activeIcon: CupertinoIcons.location_north_fill,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),
                    _buildTabItem(
                      index: 4,
                      label: l10n.navProfile,
                      icon: CupertinoIcons.person_crop_circle,
                      activeIcon: CupertinoIcons.person_crop_circle_fill,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? activeColor : inactiveColor;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: IosTypography.caption2(
                color: color,
                weight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
