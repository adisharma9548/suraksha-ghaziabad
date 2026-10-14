import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
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

    final screens = [
      HomeScreen(onNavigateTab: _onNavigateTab),
      const SafetyMapScreen(),
      const ReportUnsafeSpotScreen(),
      const TripSharingScreen(),
      const ProfileSettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.textHintLight,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: l10n.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_rounded),
            label: l10n.navMap,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_location_alt_rounded),
            label: l10n.navReport,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.directions_walk_rounded),
            label: l10n.navTrips,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_rounded),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
