import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../models/sos_alert_model.dart';
import '../abstract/sos_repository.dart';

class FirebaseSosRepository implements SosRepository {
  final FirebaseFirestore? firestore;
  final _uuid = const Uuid();

  // In-memory cache for resilience/testing
  final Map<String, SosAlertModel> _cachedAlerts = {};
  final Map<String, StreamController<SosAlertModel?>> _alertControllers = {};
  final StreamController<List<SosAlertModel>> _allActiveController =
      StreamController<List<SosAlertModel>>.broadcast();

  FirebaseSosRepository({this.firestore});

  bool get _isFirebaseAvailable => Firebase.apps.isNotEmpty;
  FirebaseFirestore get _effectiveFirestore =>
      firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _alertsCol =>
      _effectiveFirestore.collection('sos_alerts');

  @override
  Future<SosAlertModel> triggerSos({
    required String userId,
    required String userName,
    required String userPhone,
    required double lat,
    required double lng,
  }) async {
    final alertId = _uuid.v4();
    final initialLocation = SosLocationPoint(
      lat: lat,
      lng: lng,
      timestamp: DateTime.now(),
    );

    final alert = SosAlertModel(
      id: alertId,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      status: 'triggered',
      startedAt: DateTime.now(),
      locations: [initialLocation],
      lastLocationAddress: 'Ghaziabad, UP (GPS: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})',
    );

    _cachedAlerts[alertId] = alert;
    _notifyAlertChange(alert);

    if (_isFirebaseAvailable) {
      try {
        final docRef = _alertsCol.doc(alertId);
        await docRef.set(alert.toJson());
        await docRef.collection('locations').add(initialLocation.toJson());
      } catch (e) {
        debugPrint('FirebaseSosRepository.triggerSos error: $e');
      }
    }

    return alert;
  }

  @override
  Future<void> cancelSos({required String alertId, required String pin}) async {
    final existing = _cachedAlerts[alertId];
    final updated = (existing ??
            SosAlertModel(
              id: alertId,
              userId: '',
              userName: '',
              userPhone: '',
              status: 'cancelled',
              startedAt: DateTime.now(),
            ))
        .copyWith(
      status: 'cancelled',
      resolvedAt: DateTime.now(),
    );

    _cachedAlerts[alertId] = updated;
    _notifyAlertChange(updated);

    if (_isFirebaseAvailable) {
      try {
        await _alertsCol.doc(alertId).update({
          'status': 'cancelled',
          'resolvedAt': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('FirebaseSosRepository.cancelSos error: $e');
      }
    }
  }

  @override
  Future<void> addLocationBreadcrumb({
    required String alertId,
    required double lat,
    required double lng,
  }) async {
    final point = SosLocationPoint(
      lat: lat,
      lng: lng,
      timestamp: DateTime.now(),
    );

    final existing = _cachedAlerts[alertId];
    if (existing != null) {
      final updatedLocations = List<SosLocationPoint>.from(existing.locations)
        ..add(point);
      final updated = existing.copyWith(locations: updatedLocations);
      _cachedAlerts[alertId] = updated;
      _notifyAlertChange(updated);
    }

    if (_isFirebaseAvailable) {
      try {
        final docRef = _alertsCol.doc(alertId);
        await docRef.collection('locations').add(point.toJson());
        await docRef.update({
          'locations': FieldValue.arrayUnion([point.toJson()]),
        });
      } catch (e) {
        debugPrint('FirebaseSosRepository.addLocationBreadcrumb error: $e');
      }
    }
  }

  @override
  Future<SosAlertModel?> getActiveSosAlert(String userId) async {
    if (_isFirebaseAvailable) {
      try {
        final snapshot = await _alertsCol
            .where('userId', isEqualTo: userId)
            .where('status', whereIn: ['triggered', 'police_notified', 'assigned'])
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final alert = SosAlertModel.fromJson(snapshot.docs.first.data());
          _cachedAlerts[alert.id] = alert;
          return alert;
        }
      } catch (e) {
        debugPrint('FirebaseSosRepository.getActiveSosAlert error: $e');
      }
    }

    try {
      return _cachedAlerts.values.firstWhere(
        (a) => a.userId == userId && a.isActive,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<SosAlertModel?> getSosAlertStream(String alertId) {
    if (_isFirebaseAvailable) {
      return _alertsCol.doc(alertId).snapshots().map((doc) {
        if (!doc.exists || doc.data() == null) return null;
        final alert = SosAlertModel.fromJson(doc.data()!);
        _cachedAlerts[alert.id] = alert;
        return alert;
      });
    }

    if (!_alertControllers.containsKey(alertId)) {
      _alertControllers[alertId] = StreamController<SosAlertModel?>.broadcast();
    }
    Future.microtask(() {
      _alertControllers[alertId]?.add(_cachedAlerts[alertId]);
    });
    return _alertControllers[alertId]!.stream;
  }

  @override
  Stream<List<SosAlertModel>> getAllActiveAlertsStream() {
    if (_isFirebaseAvailable) {
      return _alertsCol
          .where('status', whereIn: ['triggered', 'police_notified', 'assigned'])
          .snapshots()
          .map((snapshot) {
            final alerts = snapshot.docs
                .map((doc) => SosAlertModel.fromJson(doc.data()))
                .toList();
            alerts.sort((a, b) => b.startedAt.compareTo(a.startedAt));
            return alerts;
          });
    }

    Future.microtask(() {
      final active = _cachedAlerts.values.where((a) => a.isActive).toList();
      active.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      _allActiveController.add(active);
    });
    return _allActiveController.stream;
  }

  @override
  Future<void> updateAlertStatus({
    required String alertId,
    required String status,
  }) async {
    final existing = _cachedAlerts[alertId];
    if (existing != null) {
      final updated = existing.copyWith(
        status: status,
        resolvedAt: (status == 'resolved' || status == 'cancelled')
            ? DateTime.now()
            : null,
      );
      _cachedAlerts[alertId] = updated;
      _notifyAlertChange(updated);
    }

    if (_isFirebaseAvailable) {
      try {
        final updateMap = <String, dynamic>{'status': status};
        if (status == 'resolved' || status == 'cancelled') {
          updateMap['resolvedAt'] = DateTime.now().toIso8601String();
        }
        await _alertsCol.doc(alertId).update(updateMap);
      } catch (e) {
        debugPrint('FirebaseSosRepository.updateAlertStatus error: $e');
      }
    }
  }

  @override
  Future<void> assignPatrolUnit({
    required String alertId,
    required String unitId,
    required String unitName,
    required String officerPhone,
  }) async {
    final existing = _cachedAlerts[alertId];
    if (existing != null) {
      final updated = existing.copyWith(
        assignedUnitId: unitId,
        assignedUnitName: unitName,
        assignedOfficerPhone: officerPhone,
        status: 'assigned',
      );
      _cachedAlerts[alertId] = updated;
      _notifyAlertChange(updated);
    }

    if (_isFirebaseAvailable) {
      try {
        await _alertsCol.doc(alertId).update({
          'assignedUnitId': unitId,
          'assignedUnitName': unitName,
          'assignedOfficerPhone': officerPhone,
          'status': 'assigned',
        });
      } catch (e) {
        debugPrint('FirebaseSosRepository.assignPatrolUnit error: $e');
      }
    }
  }

  void _notifyAlertChange(SosAlertModel alert) {
    if (_alertControllers.containsKey(alert.id)) {
      _alertControllers[alert.id]?.add(alert);
    }
    final active = _cachedAlerts.values.where((a) => a.isActive).toList();
    active.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    _allActiveController.add(active);
  }
}
