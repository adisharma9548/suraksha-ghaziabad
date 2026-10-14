import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../models/patrol_unit_model.dart';
import '../abstract/patrol_repository.dart';
import '../../../core/utils/distance_util.dart';

class FirebasePatrolRepository implements PatrolRepository {
  final FirebaseFirestore? firestore;
  final List<PatrolUnitModel> _cachedUnits = [];
  final StreamController<List<PatrolUnitModel>> _unitsController =
      StreamController<List<PatrolUnitModel>>.broadcast();

  FirebasePatrolRepository({this.firestore, List<PatrolUnitModel>? initialUnits}) {
    if (initialUnits != null) {
      _cachedUnits.addAll(initialUnits);
    }
  }

  bool get _isFirebaseAvailable => Firebase.apps.isNotEmpty;
  FirebaseFirestore get _effectiveFirestore =>
      firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _patrolCol =>
      _effectiveFirestore.collection('patrol_units');

  @override
  Future<List<PatrolUnitModel>> getPatrolUnits() async {
    if (_isFirebaseAvailable) {
      try {
        final snapshot = await _patrolCol.get();
        final units = snapshot.docs
            .map((doc) => PatrolUnitModel.fromJson(doc.data()))
            .toList();

        _cachedUnits.clear();
        _cachedUnits.addAll(units);
        return List.unmodifiable(_cachedUnits);
      } catch (e) {
        debugPrint('FirebasePatrolRepository.getPatrolUnits error: $e');
      }
    }
    return List.unmodifiable(_cachedUnits);
  }

  @override
  Stream<List<PatrolUnitModel>> getPatrolUnitsStream() {
    if (_isFirebaseAvailable) {
      return _patrolCol.snapshots().map((snapshot) {
        final units = snapshot.docs
            .map((doc) => PatrolUnitModel.fromJson(doc.data()))
            .toList();
        _cachedUnits.clear();
        _cachedUnits.addAll(units);
        return units;
      });
    }

    Future.microtask(() {
      _unitsController.add(List.unmodifiable(_cachedUnits));
    });
    return _unitsController.stream;
  }

  @override
  Future<PatrolUnitModel?> findNearestAvailableUnit(
    double targetLat,
    double targetLng,
  ) async {
    final units = await getPatrolUnits();
    final availableUnits = units.where((u) => u.available).toList();
    if (availableUnits.isEmpty) return null;

    availableUnits.sort((a, b) {
      final distA = DistanceUtil.calculateDistanceInMeters(
        targetLat,
        targetLng,
        a.lat,
        a.lng,
      );
      final distB = DistanceUtil.calculateDistanceInMeters(
        targetLat,
        targetLng,
        b.lat,
        b.lng,
      );
      return distA.compareTo(distB);
    });

    return availableUnits.first;
  }

  @override
  Future<void> updateUnitAvailability(String unitId, bool available) async {
    final index = _cachedUnits.indexWhere((u) => u.id == unitId);
    if (index != -1) {
      _cachedUnits[index] = _cachedUnits[index].copyWith(available: available);
      _unitsController.add(List.unmodifiable(_cachedUnits));
    }

    if (_isFirebaseAvailable) {
      try {
        await _patrolCol.doc(unitId).update({'available': available});
      } catch (e) {
        debugPrint('FirebasePatrolRepository.updateUnitAvailability error: $e');
      }
    }
  }
}
