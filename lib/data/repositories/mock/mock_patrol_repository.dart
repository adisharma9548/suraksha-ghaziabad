import 'dart:async';
import '../../models/patrol_unit_model.dart';
import '../abstract/patrol_repository.dart';
import '../../../core/utils/distance_util.dart';

class MockPatrolRepository implements PatrolRepository {
  final List<PatrolUnitModel> _units = [];
  final _unitsController = StreamController<List<PatrolUnitModel>>.broadcast();

  MockPatrolRepository([List<PatrolUnitModel>? initialUnits]) {
    if (initialUnits != null) {
      _units.addAll(initialUnits);
    }
  }

  @override
  Future<List<PatrolUnitModel>> getPatrolUnits() async {
    return List.unmodifiable(_units);
  }

  @override
  Stream<List<PatrolUnitModel>> getPatrolUnitsStream() {
    Future.microtask(() {
      _unitsController.add(List.unmodifiable(_units));
    });
    return _unitsController.stream;
  }

  @override
  Future<PatrolUnitModel?> findNearestAvailableUnit(
    double targetLat,
    double targetLng,
  ) async {
    final availableUnits = _units.where((u) => u.available).toList();
    if (availableUnits.isEmpty) return null;

    availableUnits.sort((a, b) {
      final distA = DistanceUtil.calculateDistanceInMeters(
          targetLat, targetLng, a.lat, a.lng);
      final distB = DistanceUtil.calculateDistanceInMeters(
          targetLat, targetLng, b.lat, b.lng);
      return distA.compareTo(distB);
    });

    return availableUnits.first;
  }

  @override
  Future<void> updateUnitAvailability(String unitId, bool available) async {
    final index = _units.indexWhere((u) => u.id == unitId);
    if (index != -1) {
      _units[index] = _units[index].copyWith(available: available);
      _unitsController.add(List.unmodifiable(_units));
    }
  }
}
