import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/patrol_unit_model.dart';
import 'repository_providers.dart';

final patrolUnitsStreamProvider = StreamProvider<List<PatrolUnitModel>>((ref) {
  return ref.watch(patrolRepositoryProvider).getPatrolUnitsStream();
});

final nearestUnitProvider =
    FutureProvider.family<PatrolUnitModel?, ({double lat, double lng})>(
        (ref, coords) async {
  return ref
      .watch(patrolRepositoryProvider)
      .findNearestAvailableUnit(coords.lat, coords.lng);
});
