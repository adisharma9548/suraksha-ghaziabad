import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
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
      final magnitude = (event.x * event.x + event.y * event.y + event.z * event.z);

      if (magnitude > 180) {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96), // Extra bottom padding for frosted tab bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Row: User greeting & Dial 112 Speed Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Namaste, $userName',
                          style: IosTypography.title2(color: primaryTextColor),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.location_solid,
                              size: 13,
                              color: secondaryTextColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Ghaziabad, Uttar Pradesh',
                              style: IosTypography.footnote(color: secondaryTextColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Native Dial 112 Tactile Pill (Min 44x44pt target)
                  Semantics(
                    button: true,
                    label: 'Emergency Dial 112 National Police Helpline',
                    child: GestureDetector(
                      onTap: _callEmergencyPolice,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.phone_fill,
                              size: 15,
                              color: primaryTextColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '112',
                              style: IosTypography.headline(color: primaryTextColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Multi-Cue Status Banner
              StatusBanner(
                isSosActive: sosState.hasActiveSos,
                activeStatusLabel: sosState.hasActiveSos ? l10n.sosActiveStatus : null,
              ),
              const SizedBox(height: 32),

              // Tactical Apple HIG Pulsing SOS Button
              PulsingSosButton(
                onTriggerSos: _onTriggerSos,
                isSosActive: sosState.hasActiveSos,
              ),
              const SizedBox(height: 20),

              Text(
                l10n.tapOrHoldSos,
                textAlign: TextAlign.center,
                style: IosTypography.subhead(color: secondaryTextColor),
              ),
              const SizedBox(height: 36),

              // Quick Actions Header
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.quickActions,
                  style: IosTypography.title3(color: primaryTextColor),
                ),
              ),
              const SizedBox(height: 14),

              // 2x2 Quick Action Squircle Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  QuickActionCard(
                    icon: CupertinoIcons.location_north_fill,
                    title: l10n.shareTrip,
                    subtitle: l10n.shareTripDesc,
                    onTap: () {
                      if (widget.onNavigateTab != null) {
                        widget.onNavigateTab!(3);
                      } else {
                        context.go('/citizen', extra: 3);
                      }
                    },
                  ),
                  QuickActionCard(
                    icon: CupertinoIcons.building_2_fill,
                    title: l10n.nearbyHelp,
                    subtitle: l10n.nearbyHelpDesc,
                    onTap: () {
                      if (widget.onNavigateTab != null) {
                        widget.onNavigateTab!(1);
                      } else {
                        context.go('/citizen', extra: 1);
                      }
                    },
                  ),
                  QuickActionCard(
                    icon: CupertinoIcons.exclamationmark_bubble_fill,
                    title: l10n.reportUnsafe,
                    subtitle: l10n.reportUnsafeDesc,
                    onTap: () {
                      if (widget.onNavigateTab != null) {
                        widget.onNavigateTab!(2);
                      } else {
                        context.go('/citizen', extra: 2);
                      }
                    },
                  ),
                  QuickActionCard(
                    icon: CupertinoIcons.phone_arrow_down_left,
                    title: l10n.fakeCall,
                    subtitle: l10n.fakeCallDesc,
                    onTap: () => context.push('/fake-call'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
