import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../map/screens/safety_map_screen.dart';
import 'officer_analytics_screen.dart';
import 'officer_patrol_units_screen.dart';
import 'officer_reports_admin_screen.dart';
import 'officer_sos_feed_screen.dart';

/// Native iOS Officer Shell Screen
/// Frosted glass bottom tab bar with 5 tabs, responsive dark/light theme, and Apple HIG navigation.
class OfficerShellScreen extends ConsumerStatefulWidget {
  const OfficerShellScreen({super.key});

  @override
  ConsumerState<OfficerShellScreen> createState() => _OfficerShellScreenState();
}

class _OfficerShellScreenState extends ConsumerState<OfficerShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    OfficerSosFeedScreen(),
    SafetyMapScreen(),
    OfficerReportsAdminScreen(),
    OfficerPatrolUnitsScreen(),
    OfficerAnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;
    final separatorColor = isDark ? AppColors.separatorDark : AppColors.separatorLight;
    final tabBackgroundColor = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    return Scaffold(
      extendBody: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
      appBar: AppBar(
        backgroundColor: (isDark ? AppColors.surfaceDark : AppColors.surfaceLight).withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'UP Police Control Portal',
              style: IosTypography.headline(color: primaryTextColor),
            ),
            Text(
              'Ghaziabad District Commissionerate',
              style: IosTypography.caption2(color: secondaryTextColor),
            ),
          ],
        ),
        actions: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            onPressed: () => context.go('/citizen'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(CupertinoIcons.arrow_right_arrow_left, size: 14, color: primaryTextColor),
                const SizedBox(width: 4),
                Text('Citizen', style: IosTypography.caption1(color: primaryTextColor, weight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: tabBackgroundColor.withOpacity(0.85),
              border: Border(
                top: BorderSide(
                  color: separatorColor.withOpacity(0.6),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 56,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _OfficerTabItem(
                      icon: CupertinoIcons.antenna_radiowaves_left_right,
                      label: 'Live SOS',
                      isSelected: _currentIndex == 0,
                      onTap: () => setState(() => _currentIndex = 0),
                    ),
                    _OfficerTabItem(
                      icon: CupertinoIcons.map_fill,
                      label: 'Heatmap',
                      isSelected: _currentIndex == 1,
                      onTap: () => setState(() => _currentIndex = 1),
                    ),
                    _OfficerTabItem(
                      icon: CupertinoIcons.tray_full_fill,
                      label: 'Reports',
                      isSelected: _currentIndex == 2,
                      onTap: () => setState(() => _currentIndex = 2),
                    ),
                    _OfficerTabItem(
                      icon: CupertinoIcons.shield_fill,
                      label: 'Patrols',
                      isSelected: _currentIndex == 3,
                      onTap: () => setState(() => _currentIndex = 3),
                    ),
                    _OfficerTabItem(
                      icon: CupertinoIcons.chart_bar_alt_fill,
                      label: 'Analytics',
                      isSelected: _currentIndex == 4,
                      onTap: () => setState(() => _currentIndex = 4),
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
}

class _OfficerTabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OfficerTabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final inactiveColor = const Color(0xFF8E8E93);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      minSize: 44,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? activeColor : inactiveColor,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: IosTypography.caption2(
              color: isSelected ? activeColor : inactiveColor,
              weight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
