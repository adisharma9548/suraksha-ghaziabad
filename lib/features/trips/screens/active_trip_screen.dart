import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/trip_provider.dart';
import '../../../data/providers/sos_provider.dart';
import '../widgets/safety_check_dialog.dart';

class ActiveTripScreen extends ConsumerWidget {
  const ActiveTripScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripState = ref.watch(tripProvider);
    final trip = tripState.activeTrip;

    if (trip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Trip Safe')),
        body: const Center(child: Text('No active trip in progress.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Trip to: ${trip.destination}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded, color: AppColors.sosRed),
            tooltip: 'Trigger Emergency SOS',
            onPressed: () {
              ref.read(sosProvider.notifier).triggerSos(
                    lat: trip.startLat,
                    lng: trip.startLng,
                  );
              context.go('/sos-active');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Live Map with start, destination, and route
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
                    color: AppColors.primaryPurple,
                    strokeWidth: 4.0,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(trip.startLat, trip.startLng),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.my_location, color: AppColors.primaryPurple, size: 30),
                  ),
                  Marker(
                    point: LatLng(trip.destLat, trip.destLng),
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: AppColors.sosRed, size: 36),
                  ),
                ],
              ),
            ],
          ),

          // Bottom Trip Info & Controls
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.safeGreenLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shield, color: AppColors.safeGreen, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Destination: ${trip.destination}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const Text(
                                'Live location shared with 2 emergency contacts',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        // Manual Check-in button
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primaryPurple),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: const Size(0, 46),
                            ),
                            onPressed: () {
                              ref.read(tripProvider.notifier).confirmSafe();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Safety check confirmed. Timestamp refreshed.'),
                                  backgroundColor: AppColors.safeGreen,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Text('Check-In OK', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // End Trip Button
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.safeGreen,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: const Size(0, 46),
                            ),
                            onPressed: () async {
                              await ref.read(tripProvider.notifier).endTrip();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Trip completed! Emergency contacts notified you reached safely.'),
                                    backgroundColor: AppColors.safeGreen,
                                  ),
                                );
                                context.go('/citizen');
                              }
                            },
                            child: const Text('I Reached Safely', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // If Safety Check is Active, show dialog
          if (tripState.showAreYouOkDialog)
            SafetyCheckDialog(
              secondsRemaining: tripState.safetyResponseSecondsLeft,
              onIAmSafe: () {
                ref.read(tripProvider.notifier).confirmSafe();
              },
              onTriggerSos: () {
                ref.read(tripProvider.notifier).triggerTripSos();
                ref.read(sosProvider.notifier).triggerSos(
                      lat: trip.startLat,
                      lng: trip.startLng,
                    );
                context.go('/sos-active');
              },
            ),
        ],
      ),
    );
  }
}
