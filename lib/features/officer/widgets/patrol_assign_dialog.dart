import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/distance_util.dart';
import '../../../data/models/patrol_unit_model.dart';
import '../../../data/providers/patrol_provider.dart';

class PatrolAssignDialog extends ConsumerWidget {
  final double citizenLat;
  final double citizenLng;
  final Function(PatrolUnitModel unit) onAssign;

  const PatrolAssignDialog({
    super.key,
    required this.citizenLat,
    required this.citizenLng,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(patrolUnitsStreamProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: const [
          Icon(Icons.local_police_rounded, color: AppColors.policeNavy, size: 26),
          SizedBox(width: 8),
          Text('Dispatch Patrol Unit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: unitsAsync.when(
          data: (units) {
            final availableUnits = units.where((u) => u.available).toList();

            // Sort by nearest distance
            availableUnits.sort((a, b) {
              final distA = DistanceUtil.calculateDistanceInMeters(
                  citizenLat, citizenLng, a.lat, a.lng);
              final distB = DistanceUtil.calculateDistanceInMeters(
                  citizenLat, citizenLng, b.lat, b.lng);
              return distA.compareTo(distB);
            });

            if (availableUnits.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No patrol vehicles currently available in this sector.'),
              );
            }

            final nearest = availableUnits.first;
            final nearestDist = DistanceUtil.formatDistance(
              DistanceUtil.calculateDistanceInMeters(
                  citizenLat, citizenLng, nearest.lat, nearest.lng),
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quick "Assign Nearest" Highlight Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.safeGreenLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.safeGreen),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flash_on, color: AppColors.safeGreen, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Closest: ${nearest.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.safeGreenDark,
                              ),
                            ),
                            Text(
                              'Distance: $nearestDist away',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.safeGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          minimumSize: const Size(0, 36),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          onAssign(nearest);
                        },
                        child: const Text('DISPATCH', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Other Available Patrol Units:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableUnits.length,
                    itemBuilder: (ctx, idx) {
                      final unit = availableUnits[idx];
                      final dist = DistanceUtil.formatDistance(
                        DistanceUtil.calculateDistanceInMeters(
                            citizenLat, citizenLng, unit.lat, unit.lng),
                      );

                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.directions_car, color: AppColors.policeNavy),
                        title: Text(unit.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        subtitle: Text('$dist • ${unit.officerName}'),
                        trailing: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onAssign(unit);
                          },
                          child: const Text('Assign'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error: $e'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
