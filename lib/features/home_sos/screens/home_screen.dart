import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/sos_provider.dart';
import '../../../data/providers/settings_provider.dart';
import '../widgets/pulsing_sos_button.dart';
import '../widgets/status_banner.dart';
import '../widgets/quick_action_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Function(int tabIndex)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  StreamSubscription<UserAccelerometerEvent>? _sensorSubscription;
  DateTime _lastShakeTime = DateTime.now();
  int _shakeCounter = 0;

  @override
  void initState() {
    super.initState();
    _initShakeDetector();
  }

  void _initShakeDetector() {
    final isShakeEnabled = ref.read(settingsProvider).isShakeEnabled;
    if (!isShakeEnabled) return;

    _sensorSubscription = userAccelerometerEventStream().listen((event) {
      final now = DateTime.now();
      // Calculate acceleration magnitude
      final magnitude = (event.x * event.x + event.y * event.y + event.z * event.z);

      if (magnitude > 180) { // High threshold for vigorous shake
        if (now.difference(_lastShakeTime).inMilliseconds < 500) {
          _shakeCounter++;
          if (_shakeCounter >= 3) {
            _shakeCounter = 0;
            _onTriggerSos();
          }
        } else {
          _shakeCounter = 1;
        }
        _lastShakeTime = now;
      }
    });
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    super.dispose();
  }

  void _onTriggerSos() {
    // Default Ghaziabad center coordinates (simulated GPS fix)
    ref.read(sosProvider.notifier).triggerSos(
          lat: AppConstants.ghaziabadCenterLat,
          lng: AppConstants.ghaziabadCenterLng,
        );
    context.go('/sos-active');
  }

  Future<void> _callEmergencyPolice() async {
    final uri = Uri.parse('tel:${AppConstants.emergencyNumberPolice}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final sosState = ref.watch(sosProvider);
    final userName = authState.user?.name ?? 'Citizen';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Row: User greeting & Dial 112 button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Namaste, $userName',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: const [
                          Icon(Icons.location_on, size: 14, color: AppColors.primaryPurple),
                          SizedBox(width: 4),
                          Text(
                            'Ghaziabad, Uttar Pradesh',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: _callEmergencyPolice,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.sosRedLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.sosRed.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.phone_in_talk, size: 16, color: AppColors.sosRed),
                          SizedBox(width: 6),
                          Text(
                            '112',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.sosRedDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Status Chip (Safe / SOS Active)
              StatusBanner(
                isSosActive: sosState.hasActiveSos,
                activeStatusLabel: sosState.hasActiveSos ? l10n.sosActiveStatus : null,
              ),
              const SizedBox(height: 28),

              // Pulsing SOS Button Core (min 160dp)
              PulsingSosButton(
                onTriggerSos: _onTriggerSos,
                isSosActive: sosState.hasActiveSos,
              ),
              const SizedBox(height: 18),

              Text(
                l10n.tapOrHoldSos,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 32),

              // Quick Actions Grid Header
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.quickActions,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 2x2 Quick Action Tiles
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.15,
                children: [
                  QuickActionCard(
                    icon: Icons.directions_walk_rounded,
                    iconColor: AppColors.primaryPurple,
                    backgroundColor: AppColors.primaryPurpleSurface,
                    title: l10n.shareTrip,
                    subtitle: l10n.shareTripDesc,
                    onTap: () {
                      if (widget.onNavigateTab != null) {
                        widget.onNavigateTab!(3); // Trip tab
                      } else {
                        context.go('/citizen', extra: 3);
                      }
                    },
                  ),
                  QuickActionCard(
                    icon: Icons.local_police_rounded,
                    iconColor: AppColors.policeNavy,
                    backgroundColor: AppColors.policeNavySurface,
                    title: l10n.nearbyHelp,
                    subtitle: l10n.nearbyHelpDesc,
                    onTap: () {
                      if (widget.onNavigateTab != null) {
                        widget.onNavigateTab!(1); // Map tab
                      } else {
                        context.go('/citizen', extra: 1);
                      }
                    },
                  ),
                  QuickActionCard(
                    icon: Icons.report_problem_rounded,
                    iconColor: AppColors.warningAmberDark,
                    backgroundColor: AppColors.warningAmberLight,
                    title: l10n.reportUnsafe,
                    subtitle: l10n.reportUnsafeDesc,
                    onTap: () {
                      if (widget.onNavigateTab != null) {
                        widget.onNavigateTab!(2); // Report tab
                      } else {
                        context.go('/citizen', extra: 2);
                      }
                    },
                  ),
                  QuickActionCard(
                    icon: Icons.phone_callback_rounded,
                    iconColor: AppColors.safeGreen,
                    backgroundColor: AppColors.safeGreenLight,
                    title: l10n.fakeCall,
                    subtitle: l10n.fakeCallDesc,
                    onTap: () => context.push('/fake-call'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
