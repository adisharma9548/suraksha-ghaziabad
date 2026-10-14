import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../models/trip_model.dart';
import '../abstract/trip_repository.dart';

class MockTripRepository implements TripRepository {
  final List<TripModel> _trips = [];
  final Map<String, StreamController<TripModel?>> _tripControllers = {};
  final _uuid = const Uuid();

  MockTripRepository();

  @override
  Future<TripModel> startTrip({
    required String userId,
    required String userName,
    required String destination,
    required double startLat,
    required double startLng,
    required double destLat,
    required double destLng,
    required List<String> contactPhones,
  }) async {
    final trip = TripModel(
      id: _uuid.v4(),
      userId: userId,
      userName: userName,
      destination: destination,
      startLat: startLat,
      startLng: startLng,
      destLat: destLat,
      destLng: destLng,
      status: 'active',
      startedAt: DateTime.now(),
      lastCheckInAt: DateTime.now(),
      trustedContactPhones: contactPhones,
      routePoints: [
        TripPoint(lat: startLat, lng: startLng, timestamp: DateTime.now()),
      ],
    );

    _trips.insert(0, trip);
    _notifyChanges(trip);
    return trip;
  }

  @override
  Future<void> addTripBreadcrumb({
    required String tripId,
    required double lat,
    required double lng,
  }) async {
    final index = _trips.indexWhere((t) => t.id == tripId);
    if (index != -1) {
      final current = _trips[index];
      final newPoints = List<TripPoint>.from(current.routePoints)
        ..add(TripPoint(lat: lat, lng: lng, timestamp: DateTime.now()));
      final updated = current.copyWith(routePoints: newPoints);
      _trips[index] = updated;
      _notifyChanges(updated);
    }
  }

  @override
  Future<TripModel?> getActiveTrip(String userId) async {
    try {
      return _trips.firstWhere((t) => t.userId == userId && t.isActive);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<TripModel?> getTripStream(String tripId) {
    if (!_tripControllers.containsKey(tripId)) {
      _tripControllers[tripId] = StreamController<TripModel?>.broadcast();
    }
    Future.microtask(() {
      try {
        final trip = _trips.firstWhere((t) => t.id == tripId);
        _tripControllers[tripId]?.add(trip);
      } catch (_) {
        _tripControllers[tripId]?.add(null);
      }
    });
    return _tripControllers[tripId]!.stream;
  }

  @override
  Future<void> confirmSafetyCheck(String tripId) async {
    final index = _trips.indexWhere((t) => t.id == tripId);
    if (index != -1) {
      final updated = _trips[index].copyWith(
        status: 'active',
        lastCheckInAt: DateTime.now(),
      );
      _trips[index] = updated;
      _notifyChanges(updated);
    }
  }

  @override
  Future<void> triggerTripAlarm(String tripId) async {
    final index = _trips.indexWhere((t) => t.id == tripId);
    if (index != -1) {
      final updated = _trips[index].copyWith(status: 'alerted');
      _trips[index] = updated;
      _notifyChanges(updated);
    }
  }

  @override
  Future<void> completeTrip(String tripId) async {
    final index = _trips.indexWhere((t) => t.id == tripId);
    if (index != -1) {
      final updated = _trips[index].copyWith(
        status: 'completed',
        completedAt: DateTime.now(),
      );
      _trips[index] = updated;
      _notifyChanges(updated);
    }
  }

  void _notifyChanges(TripModel trip) {
    _tripControllers[trip.id]?.add(trip);
  }
}
