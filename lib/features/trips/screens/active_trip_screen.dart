import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../core/widgets/ios_widgets.dart';
import '../../../data/providers/sos_provider.dart';
import '../../../data/providers/trip_provider.dart';

/// Native iOS Active Trip Screen
/// Real-time route tracking with Apple HIG bottom sheet, tactile manual check-ins, and color-blind safe cues.
class ActiveTripScreen extends ConsumerWidget {
  const ActiveTripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripState = ref.watch(tripProvider);
    final trip = tripState.activeTrip;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;
    final separatorColor = isDark ? AppColors.separatorDark : AppColors.separatorLight;

    if (trip == null) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
        appBar: AppBar(
          title: Text('Trip Safe', style: IosTypography.headline(color: primaryTextColor)),
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
          elevation: 0,
        ),
        body: Center(
          child: Text('No active trip in progress.', style: IosTypography.body(color: secondaryTextColor)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // FlutterMap OpenStreetMap route
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(trip.startLat, trip.startLng),
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.suraksha.ghaziabad',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [
                      LatLng(trip.startLat, trip.startLng),
                      LatLng(trip.destLat, trip.destLng),
                    ],
                    color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                    strokeWidth: 4.5,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // Origin Marker
                  Marker(
                    point: LatLng(trip.startLat, trip.startLng),
                    width: 44,
                    height: 44,
                    child: Center(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: const Icon(CupertinoIcons.location_fill, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                  // Destination Marker
                  Marker(
                    point: LatLng(trip.destLat, trip.destLng),
                    width: 44,
                    height: 44,
                    child: Center(
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3)),
                          ],
                        ),
                        child: Icon(
                          CupertinoIcons.flag_fill,
                          color: isDark ? Colors.black : Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Top Header Bar with Emergency Action
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.surfaceDark : AppColors.surfaceLight).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: separatorColor.withOpacity(0.6)),
                    ),
                    child: Row(
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 36,
                          child: Icon(CupertinoIcons.chevron_left, color: primaryTextColor),
                          onPressed: () => context.pop(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            trip.destination,
                            style: IosTypography.headline(color: primaryTextColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 36,
                          onPressed: () {
                            ref.read(sosProvider.notifier).triggerSos(
                                  lat: trip.startLat,
                                  lng: trip.startLng,
                                );
                            context.go('/sos-active');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.exclamationmark_triangle_fill,
                                  size: 14,
                                  color: isDark ? Colors.black : Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'SOS',
                                  style: IosTypography.caption1(
                                    color: isDark ? Colors.black : Colors.white,
                                    weight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Native iOS Floating Bottom Inset Card
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.surfaceDark : AppColors.surfaceLight).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: separatorColor),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.secondarySurfaceDark : AppColors.secondarySurfaceLight,
                              shape: BoxShape.circle,
                              border: Border.all(color: separatorColor),
                            ),
                            child: Center(
                              child: Icon(
                                CupertinoIcons.checkmark_shield_fill,
                                color: primaryTextColor,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Heading to ${trip.destination}',
                                  style: IosTypography.headline(color: primaryTextColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Live GPS shared with emergency contacts',
                                  style: IosTypography.footnote(color: secondaryTextColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          // Manual Check-in
                          Expanded(
                            child: IosButton(
                              text: 'I am OK',
                              icon: CupertinoIcons.checkmark_circle,
                              type: IosButtonType.secondary,
                              onPressed: () {
                                ref.read(tripProvider.notifier).confirmSafe();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Safety confirmed: check-in recorded!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // End Trip
                          Expanded(
                            child: IosButton(
                              text: 'End Trip',
                              icon: CupertinoIcons.stop_fill,
                              type: IosButtonType.primary,
                              onPressed: () async {
                                await ref.read(tripProvider.notifier).endTrip();
                                if (context.mounted) {
                                  context.pop();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
