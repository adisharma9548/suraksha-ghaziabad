import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/distance_util.dart';
import '../../../data/providers/patrol_provider.dart';
import '../../../data/providers/repository_providers.dart';

class OfficerPatrolUnitsScreen extends ConsumerWidget {
  const OfficerPatrolUnitsScreen({super.key});

  Future<void> _callUnit(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(patrolUnitsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patrol Fleet Management', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: unitsAsync.when(
          data: (units) {
            if (units.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_car_outlined, size: 56, color: AppColors.policeNavy),
                    SizedBox(height: 16),
                    Text(
                      'No Patrol Units Registered',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'No active patrol units in the district roster yet.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: units.length,
              itemBuilder: (context, index) {
                final unit = units[index];
                final dist = DistanceUtil.formatDistance(
                  DistanceUtil.calculateDistanceInMeters(
                    AppConstants.ghaziabadCenterLat,
                    AppConstants.ghaziabadCenterLng,
                    unit.lat,
                    unit.lng,
                  ),
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: unit.available
                                    ? AppColors.safeGreenLight
                                    : AppColors.dividerLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.directions_car_filled_rounded,
                                color: unit.available
                                    ? AppColors.safeGreen
                                    : AppColors.textHintLight,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    unit.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${unit.officerName} • $dist from Sector HQ',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: unit.available,
                              activeColor: AppColors.safeGreen,
                              onChanged: (val) {
                                ref
                                    .read(patrolRepositoryProvider)
                                    .updateUnitAvailability(unit.id, val);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              unit.available ? 'AVAILABLE FOR DISPATCH' : 'BUSY / ON PATROL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: unit.available ? AppColors.safeGreenDark : AppColors.textHintLight,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              icon: const Icon(Icons.phone, size: 16),
                              label: const Text('Call Unit'),
                              onPressed: () => _callUnit(unit.phone),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}
