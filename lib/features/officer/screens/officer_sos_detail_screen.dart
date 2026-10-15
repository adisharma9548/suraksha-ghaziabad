import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/ios_widgets.dart';
import '../../../data/models/sos_alert_model.dart';
import '../../../data/providers/repository_providers.dart';
import '../widgets/patrol_assign_dialog.dart';

/// Native iOS Officer SOS Detail Screen
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

    showCupertinoDialog(
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
                duration: const Duration(seconds: 2),
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
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sosRepo = ref.watch(sosRepositoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;
    final separatorColor = isDark ? AppColors.separatorDark : AppColors.separatorLight;

    return StreamBuilder<SosAlertModel?>(
      stream: sosRepo.getSosAlertStream(widget.alertId),
      builder: (context, snapshot) {
        final alert = snapshot.data;

        if (alert == null) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
            appBar: AppBar(
              title: Text('SOS Detail', style: IosTypography.headline(color: primaryTextColor)),
              backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
              elevation: 0,
            ),
            body: Center(
              child: CupertinoActivityIndicator(radius: 14, color: primaryTextColor),
            ),
          );
        }

        final latestPoint = alert.latestLocation;
        final lat = latestPoint?.lat ?? 28.6692;
        final lng = latestPoint?.lng ?? 77.4538;
        final isResolved = alert.status == 'resolved';

        return Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
          appBar: AppBar(
            title: Text(alert.userName, style: IosTypography.headline(color: primaryTextColor)),
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
            elevation: 0,
            centerTitle: true,
            actions: [
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Icon(CupertinoIcons.phone_fill, color: primaryTextColor),
                onPressed: () => _callCitizen(alert.userPhone),
              ),
            ],
          ),
          body: Column(
            children: [
              // Moving Breadcrumb Map
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
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.suraksha.ghaziabad',
                    ),
                    if (alert.locations.length > 1)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: alert.locations.map((p) => LatLng(p.lat, p.lng)).toList(),
                            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                            strokeWidth: 4.5,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(lat, lng),
                          width: 48,
                          height: 48,
                          child: Center(
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, blurRadius: 6),
                                ],
                              ),
                              child: Icon(
                                CupertinoIcons.exclamationmark,
                                size: 18,
                                color: isDark ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Detail Inset Section & Action Panel
              Expanded(
                flex: 5,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    if (alert.isDuress) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.exclamationmark_triangle_fill,
                              color: isDark ? Colors.black : Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'CRITICAL DURESS DETECTED: Citizen entered Decoy Duress PIN under coercion. DO NOT STAND DOWN. Urgent patrol dispatch required!',
                                style: IosTypography.footnote(
                                  color: isDark ? Colors.black : Colors.white,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    IosCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    alert.userName,
                                    style: IosTypography.title2(color: primaryTextColor),
                                  ),
                                  Text(
                                    'Phone: ${alert.userPhone}',
                                    style: IosTypography.subhead(color: secondaryTextColor),
                                  ),
                                ],
                              ),
                              IosBadge(
                                label: alert.status.toUpperCase(),
                                icon: isResolved
                                    ? CupertinoIcons.checkmark_seal_fill
                                    : CupertinoIcons.antenna_radiowaves_left_right,
                                type: isResolved ? IosBadgeType.success : IosBadgeType.error,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(CupertinoIcons.location_solid, size: 16, color: primaryTextColor),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  alert.lastLocationAddress ?? 'Ghaziabad GPS Tracked Area',
                                  style: IosTypography.footnote(color: primaryTextColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(CupertinoIcons.clock, size: 14, color: secondaryTextColor),
                              const SizedBox(width: 6),
                              Text(
                                'Started: ${DateFormatter.formatDateTime(alert.startedAt)}',
                                style: IosTypography.caption1(color: secondaryTextColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Dispatched Patrol Card
                    if (alert.assignedUnitName != null) ...[
                      IosCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(CupertinoIcons.car_fill, size: 24, color: primaryTextColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dispatched Unit: ${alert.assignedUnitName}',
                                    style: IosTypography.headline(color: primaryTextColor),
                                  ),
                                  Text(
                                    'Officer Contact: ${alert.assignedOfficerPhone ?? '112'}',
                                    style: IosTypography.footnote(color: secondaryTextColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Simulated Audio Evidence Box
                    IosCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => setState(() => _isPlayingAudio = !_isPlayingAudio),
                            child: Icon(
                              _isPlayingAudio ? CupertinoIcons.pause_circle_fill : CupertinoIcons.play_circle_fill,
                              size: 40,
                              color: primaryTextColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Ambient Audio Evidence', style: IosTypography.headline(color: primaryTextColor)),
                                Text(
                                  _isPlayingAudio ? 'Streaming audio evidence...' : 'Encrypted background recording',
                                  style: IosTypography.caption1(color: secondaryTextColor),
                                ),
                              ],
                            ),
                          ),
                          Icon(CupertinoIcons.waveform, color: separatorColor),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Action Controls
                    Row(
                      children: [
                        Expanded(
                          child: IosButton(
                            text: 'Assign Patrol',
                            icon: CupertinoIcons.paperplane_fill,
                            type: IosButtonType.primary,
                            onPressed: isResolved ? null : () => _showAssignDialog(alert),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: IosButton(
                            text: 'Mark Resolved',
                            icon: CupertinoIcons.checkmark_circle_fill,
                            type: IosButtonType.secondary,
                            onPressed: isResolved ? null : () => _markResolved(alert),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
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
