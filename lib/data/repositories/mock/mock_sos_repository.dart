import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../models/sos_alert_model.dart';
import '../abstract/sos_repository.dart';
import '../abstract/auth_repository.dart';

class MockSosRepository implements SosRepository {
  final AuthRepository _authRepo;
  final _uuid = const Uuid();

  final List<SosAlertModel> _alerts = [];
  final _allAlertsController = StreamController<List<SosAlertModel>>.broadcast();
  final Map<String, StreamController<SosAlertModel?>> _alertControllers = {};

  MockSosRepository(this._authRepo) {
    // Seed initial active demo SOS alert so officer feed immediately has live data on first launch
    final demoAlert = SosAlertModel(
      id: 'demo_sos_active_01',
      userId: 'citizen_demo_user',
      userName: 'Priya Verma',
      userPhone: '+919871122334',
      status: 'police_notified',
      startedAt: DateTime.now().subtract(const Duration(minutes: 4)),
      lastLocationAddress: 'Near Vaishali Metro Pillar 114, Ghaziabad',
      locations: [
        SosLocationPoint(
          lat: 28.6480,
          lng: 77.3390,
          timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
        ),
        SosLocationPoint(
          lat: 28.6485,
          lng: 77.3395,
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
      ],
    );
    _alerts.add(demoAlert);
  }

  @override
  Future<SosAlertModel> triggerSos({
    required String userId,
    required String userName,
    required String userPhone,
    required double lat,
    required double lng,
  }) async {
    final alert = SosAlertModel(
      id: _uuid.v4(),
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      status: 'triggered',
      startedAt: DateTime.now(),
      lastLocationAddress: 'Indirapuram / Ghaziabad Area',
      locations: [
        SosLocationPoint(
          lat: lat,
          lng: lng,
          timestamp: DateTime.now(),
        ),
      ],
    );

    _alerts.insert(0, alert);
    _notifyChanges(alert);
    return alert;
  }

  @override
  Future<void> cancelSos({
    required String alertId,
    required String pin,
  }) async {
    final isPinValid = await _authRepo.verifyEmergencyPin(pin);
    if (!isPinValid) {
      throw Exception('Incorrect Emergency PIN. False alarm cancellation failed.');
    }

    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      final updated = _alerts[index].copyWith(
        status: 'cancelled',
        resolvedAt: DateTime.now(),
      );
      _alerts[index] = updated;
      _notifyChanges(updated);
    }
  }

  @override
  Future<void> addLocationBreadcrumb({
    required String alertId,
    required double lat,
    required double lng,
  }) async {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      final current = _alerts[index];
      final newLocations = List<SosLocationPoint>.from(current.locations)
        ..add(SosLocationPoint(lat: lat, lng: lng, timestamp: DateTime.now()));

      final updated = current.copyWith(locations: newLocations);
      _alerts[index] = updated;
      _notifyChanges(updated);
    }
  }

  @override
  Future<SosAlertModel?> getActiveSosAlert(String userId) async {
    try {
      return _alerts.firstWhere(
        (a) => a.userId == userId && a.isActive,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<SosAlertModel?> getSosAlertStream(String alertId) {
    if (!_alertControllers.containsKey(alertId)) {
      _alertControllers[alertId] = StreamController<SosAlertModel?>.broadcast();
    }
    // Emit current state immediately
    Future.microtask(() {
      try {
        final alert = _alerts.firstWhere((a) => a.id == alertId);
        _alertControllers[alertId]?.add(alert);
      } catch (_) {
        _alertControllers[alertId]?.add(null);
      }
    });
    return _alertControllers[alertId]!.stream;
  }

  @override
  Stream<List<SosAlertModel>> getAllActiveAlertsStream() {
    Future.microtask(() => _allAlertsController.add(List.unmodifiable(_alerts)));
    return _allAlertsController.stream;
  }

  @override
  Future<void> updateAlertStatus({
    required String alertId,
    required String status,
  }) async {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      final updated = _alerts[index].copyWith(
        status: status,
        resolvedAt: status == 'resolved' ? DateTime.now() : null,
      );
      _alerts[index] = updated;
      _notifyChanges(updated);
    }
  }

  @override
  Future<void> assignPatrolUnit({
    required String alertId,
    required String unitId,
    required String unitName,
    required String officerPhone,
  }) async {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      final updated = _alerts[index].copyWith(
        status: 'assigned',
        assignedUnitId: unitId,
        assignedUnitName: unitName,
        assignedOfficerPhone: officerPhone,
      );
      _alerts[index] = updated;
      _notifyChanges(updated);
    }
  }

  void _notifyChanges(SosAlertModel alert) {
    _alertControllers[alert.id]?.add(alert);
    _allAlertsController.add(List.unmodifiable(_alerts));
  }
}
