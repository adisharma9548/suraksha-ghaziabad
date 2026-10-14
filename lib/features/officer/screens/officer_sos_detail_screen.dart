import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/sos_alert_model.dart';
import '../../../data/providers/repository_providers.dart';
import '../widgets/patrol_assign_dialog.dart';

class OfficerSosDetailScreen extends ConsumerStatefulWidget {
  final String alertId;

  const OfficerSosDetailScreen({super.key, required this.alertId});

  @override
  ConsumerState<OfficerSosDetailScreen> createState() =>
      _OfficerSosDetailScreenState();
}

class _OfficerSosDetailScreenState extends ConsumerState<OfficerSosDetailScreen> {
  final MapController _mapController = MapController();
  bool _isPlayingAudio = false;

  Future<void> _callCitizen(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showAssignDialog(SosAlertModel alert) {
    final latestPoint = alert.latestLocation;
    final lat = latestPoint?.lat ?? 28.6692;
    final lng = latestPoint?.lng ?? 77.4538;

    showDialog(
      context: context,
      builder: (ctx) => PatrolAssignDialog(
        citizenLat: lat,
        citizenLng: lng,
        onAssign: (unit) async {
          await ref.read(sosRepositoryProvider).assignPatrolUnit(
                alertId: alert.id,
                unitId: unit.id,
                unitName: unit.name,
                officerPhone: unit.phone,
              );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${unit.name} dispatched to citizen location!'),
                backgroundColor: AppColors.safeGreen,
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _markResolved(SosAlertModel alert) async {
    await ref.read(sosRepositoryProvider).updateAlertStatus(
          alertId: alert.id,
          status: 'resolved',
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incident marked as Resolved and logged.'),
          backgroundColor: AppColors.safeGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sosRepo = ref.watch(sosRepositoryProvider);

    return StreamBuilder<SosAlertModel?>(
      stream: sosRepo.getSosAlertStream(widget.alertId),
      builder: (context, snapshot) {
        final alert = snapshot.data;

        if (alert == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('SOS Detail')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final latestPoint = alert.latestLocation;
        final lat = latestPoint?.lat ?? 28.6692;
        final lng = latestPoint?.lng ?? 77.4538;
        final isResolved = alert.status == 'resolved';

        return Scaffold(
          appBar: AppBar(
            title: Text('Incident: ${alert.userName}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () => _callCitizen(alert.userPhone),
              ),
            ],
          ),
          body: Column(
            children: [
              // Map displaying live moving location
              Expanded(
                flex: 4,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(lat, lng),
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.suraksha.ghaziabad',
                    ),
                    // Breadcrumb Trail Polyline
                    if (alert.locations.length > 1)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: alert.locations
                                .map((p) => LatLng(p.lat, p.lng))
                                .toList(),
                            color: AppColors.sosRed,
                            strokeWidth: 4.0,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(lat, lng),
                          width: 50,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.sosRed.withOpacity(0.2),
                            ),
                            child: Center(
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: AppColors.sosRed,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black26, blurRadius: 6),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Detail Drawer & Actions
              Expanded(
                flex: 5,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alert.userName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Phone: ${alert.userPhone}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isResolved
                                ? AppColors.safeGreenLight
                                : AppColors.sosRedLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isResolved ? AppColors.safeGreen : AppColors.sosRed,
                            ),
                          ),
                          child: Text(
                            alert.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isResolved
                                  ? AppColors.safeGreenDark
                                  : AppColors.sosRedDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (alert.isDuress) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.sosRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_rounded,
                                color: Colors.white, size: 24),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '⚠️ CRITICAL DURESS DETECTED: Citizen entered Decoy Duress PIN under coercion. DO NOT STAND DOWN. Urgent patrol dispatch required!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),

                    // Location address & timestamp
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primaryPurple, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            alert.lastLocationAddress ?? 'Ghaziabad GPS Tracked Area',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: AppColors.textHintLight, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Triggered at: ${DateFormatter.formatDateTime(alert.startedAt)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textHintLight),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Dispatched Unit Card
                    if (alert.assignedUnitName != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.policeNavySurface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.policeNavy.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_police, color: AppColors.policeNavy),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dispatched: ${alert.assignedUnitName}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.policeNavy,
                                    ),
                                  ),
                                  Text(
                                    'Officer Contact: ${alert.assignedOfficerPhone ?? '112'}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Simulated Audio Evidence Player
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.dividerLight),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isPlayingAudio
                                  ? Icons.pause_circle_filled_rounded
                                  : Icons.play_circle_fill_rounded,
                              size: 36,
                              color: AppColors.primaryPurple,
                            ),
                            onPressed: () {
                              setState(() => _isPlayingAudio = !_isPlayingAudio);
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ambient Audio Evidence',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  _isPlayingAudio ? 'Playing simulated clip (0:14)...' : 'Encrypted background audio stream (0:45)',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.graphic_eq_rounded, color: AppColors.primaryPurple),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Primary Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.policeNavy,
                            ),
                            icon: const Icon(Icons.near_me_rounded),
                            label: const Text('Assign Unit'),
                            onPressed: isResolved ? null : () => _showAssignDialog(alert),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.safeGreen,
                              side: const BorderSide(color: AppColors.safeGreen, width: 1.5),
                            ),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Mark Resolved'),
                            onPressed: isResolved ? null : () => _markResolved(alert),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
