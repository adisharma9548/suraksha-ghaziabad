import '../../models/sos_alert_model.dart';
import '../abstract/sos_repository.dart';

class FirebaseSosRepository implements SosRepository {
  @override
  Future<SosAlertModel> triggerSos({
    required String userId,
    required String userName,
    required String userPhone,
    required double lat,
    required double lng,
  }) async {
    throw UnimplementedError('Connect Firebase configuration to stream alerts to Firestore');
  }

  @override
  Future<void> cancelSos({required String alertId, required String pin}) async {}

  @override
  Future<void> addLocationBreadcrumb({
    required String alertId,
    required double lat,
    required double lng,
  }) async {}

  @override
  Future<SosAlertModel?> getActiveSosAlert(String userId) async => null;

  @override
  Stream<SosAlertModel?> getSosAlertStream(String alertId) => const Stream.empty();

  @override
  Stream<List<SosAlertModel>> getAllActiveAlertsStream() => const Stream.empty();

  @override
  Future<void> updateAlertStatus({
    required String alertId,
    required String status,
  }) async {}

  @override
  Future<void> assignPatrolUnit({
    required String alertId,
    required String unitId,
    required String unitName,
    required String officerPhone,
  }) async {}

  @override
  Future<void> simulateOfficerProgression(String alertId) async {}
}
