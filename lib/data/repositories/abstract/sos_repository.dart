import '../../models/sos_alert_model.dart';

abstract class SosRepository {
  Future<SosAlertModel> triggerSos({
    required String userId,
    required String userName,
    required String userPhone,
    required double lat,
    required double lng,
  });
  Future<void> cancelSos({
    required String alertId,
    required String pin,
  });
  Future<void> addLocationBreadcrumb({
    required String alertId,
    required double lat,
    required double lng,
  });
  Future<SosAlertModel?> getActiveSosAlert(String userId);
  Stream<SosAlertModel?> getSosAlertStream(String alertId);
  Stream<List<SosAlertModel>> getAllActiveAlertsStream();
  Future<void> updateAlertStatus({
    required String alertId,
    required String status,
  });
  Future<void> assignPatrolUnit({
    required String alertId,
    required String unitId,
    required String unitName,
    required String officerPhone,
  });
  Future<void> simulateOfficerProgression(String alertId);
}
