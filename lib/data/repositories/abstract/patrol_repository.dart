import '../../models/patrol_unit_model.dart';

abstract class PatrolRepository {
  Future<List<PatrolUnitModel>> getPatrolUnits();
  Stream<List<PatrolUnitModel>> getPatrolUnitsStream();
  Future<PatrolUnitModel?> findNearestAvailableUnit(double targetLat, double targetLng);
  Future<void> updateUnitAvailability(String unitId, bool available);
}
