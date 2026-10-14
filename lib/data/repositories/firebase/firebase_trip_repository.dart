import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../models/trip_model.dart';
import '../abstract/trip_repository.dart';

class FirebaseTripRepository implements TripRepository {
  final FirebaseFirestore? firestore;
  final _uuid = const Uuid();

  final Map<String, TripModel> _cachedTrips = {};
  final Map<String, StreamController<TripModel?>> _tripControllers = {};

  FirebaseTripRepository({this.firestore});

  bool get _isFirebaseAvailable => Firebase.apps.isNotEmpty;
  FirebaseFirestore get _effectiveFirestore =>
      firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tripsCol =>
      _effectiveFirestore.collection('trips');

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
    final tripId = _uuid.v4();
    final firstPoint = TripPoint(
      lat: startLat,
      lng: startLng,
      timestamp: DateTime.now(),
    );

    final trip = TripModel(
      id: tripId,
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
      routePoints: [firstPoint],
    );

    _cachedTrips[tripId] = trip;
    _notifyTripChange(trip);

    if (_isFirebaseAvailable) {
      try {
        await _tripsCol.doc(tripId).set(trip.toJson());
      } catch (e) {
        debugPrint('FirebaseTripRepository.startTrip error: $e');
      }
    }

    return trip;
  }

  @override
  Future<void> addTripBreadcrumb({
    required String tripId,
    required double lat,
    required double lng,
  }) async {
    final point = TripPoint(lat: lat, lng: lng, timestamp: DateTime.now());
    final existing = _cachedTrips[tripId];
    if (existing != null) {
      final updatedPoints = List<TripPoint>.from(existing.routePoints)
        ..add(point);
      final updated = existing.copyWith(routePoints: updatedPoints);
      _cachedTrips[tripId] = updated;
      _notifyTripChange(updated);
    }

    if (_isFirebaseAvailable) {
      try {
        await _tripsCol.doc(tripId).update({
          'routePoints': FieldValue.arrayUnion([point.toJson()]),
        });
      } catch (e) {
        debugPrint('FirebaseTripRepository.addTripBreadcrumb error: $e');
      }
    }
  }

  @override
  Future<TripModel?> getActiveTrip(String userId) async {
    if (_isFirebaseAvailable) {
      try {
        final snapshot = await _tripsCol
            .where('userId', isEqualTo: userId)
            .where('status', isEqualTo: 'active')
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final trip = TripModel.fromJson(snapshot.docs.first.data());
          _cachedTrips[trip.id] = trip;
          return trip;
        }
      } catch (e) {
        debugPrint('FirebaseTripRepository.getActiveTrip error: $e');
      }
    }

    try {
      return _cachedTrips.values.firstWhere(
        (t) => t.userId == userId && t.isActive,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<TripModel?> getTripStream(String tripId) {
    if (_isFirebaseAvailable) {
      return _tripsCol.doc(tripId).snapshots().map((doc) {
        if (!doc.exists || doc.data() == null) return null;
        final trip = TripModel.fromJson(doc.data()!);
        _cachedTrips[trip.id] = trip;
        return trip;
      });
    }

    if (!_tripControllers.containsKey(tripId)) {
      _tripControllers[tripId] = StreamController<TripModel?>.broadcast();
    }
    Future.microtask(() {
      _tripControllers[tripId]?.add(_cachedTrips[tripId]);
    });
    return _tripControllers[tripId]!.stream;
  }

  @override
  Future<void> confirmSafetyCheck(String tripId) async {
    final existing = _cachedTrips[tripId];
    if (existing != null) {
      final updated = existing.copyWith(
        status: 'active',
        lastCheckInAt: DateTime.now(),
      );
      _cachedTrips[tripId] = updated;
      _notifyTripChange(updated);
    }

    if (_isFirebaseAvailable) {
      try {
        await _tripsCol.doc(tripId).update({
          'status': 'active',
          'lastCheckInAt': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('FirebaseTripRepository.confirmSafetyCheck error: $e');
      }
    }
  }

  @override
  Future<void> triggerTripAlarm(String tripId) async {
    final existing = _cachedTrips[tripId];
    if (existing != null) {
      final updated = existing.copyWith(status: 'alerted');
      _cachedTrips[tripId] = updated;
      _notifyTripChange(updated);
    }

    if (_isFirebaseAvailable) {
      try {
        await _tripsCol.doc(tripId).update({
          'status': 'alerted',
        });
      } catch (e) {
        debugPrint('FirebaseTripRepository.triggerTripAlarm error: $e');
      }
    }
  }

  @override
  Future<void> completeTrip(String tripId) async {
    final existing = _cachedTrips[tripId];
    if (existing != null) {
      final updated = existing.copyWith(
        status: 'completed',
        completedAt: DateTime.now(),
      );
      _cachedTrips[tripId] = updated;
      _notifyTripChange(updated);
    }

    if (_isFirebaseAvailable) {
      try {
        await _tripsCol.doc(tripId).update({
          'status': 'completed',
          'completedAt': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('FirebaseTripRepository.completeTrip error: $e');
      }
    }
  }

  void _notifyTripChange(TripModel trip) {
    if (_tripControllers.containsKey(trip.id)) {
      _tripControllers[trip.id]?.add(trip);
    }
  }
}
