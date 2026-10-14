import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import 'officer_sos_feed_screen.dart';
import 'officer_patrol_units_screen.dart';
import 'officer_reports_admin_screen.dart';
import 'officer_analytics_screen.dart';
import '../../map/screens/safety_map_screen.dart';

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.policeNavy,
        foregroundColor: Colors.white,
        title: Column(
          children: const [
            Text(
              'UP Police Control Portal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'Ghaziabad District Commissionerate',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 18),
            label: const Text('Citizen App', style: TextStyle(color: Colors.white, fontSize: 12)),
            onPressed: () => context.go('/citizen'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.policeNavy,
        unselectedItemColor: AppColors.textHintLight,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.radar_rounded),
            label: 'Live SOS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            label: 'Heatmap',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_rounded),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_police_rounded),
            label: 'Patrols',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}
