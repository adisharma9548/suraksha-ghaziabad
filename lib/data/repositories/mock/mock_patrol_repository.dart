import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/patrol_unit_model.dart';
import '../abstract/patrol_repository.dart';
import '../../../core/utils/distance_util.dart';

class MockPatrolRepository implements PatrolRepository {
  final List<PatrolUnitModel> _units = [];
  final _unitsController = StreamController<List<PatrolUnitModel>>.broadcast();
  bool _isInitialized = false;

  MockPatrolRepository();

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/ghaziabad_seed_data.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final rawList = data['patrol_units'] as List;
      _units.clear();
      for (final item in rawList) {
        _units.add(PatrolUnitModel.fromJson(item as Map<String, dynamic>));
      }
    } catch (_) {
      // Fallback
    }
    _isInitialized = true;
  }

  @override
  Future<List<PatrolUnitModel>> getPatrolUnits() async {
    await _ensureInitialized();
    return List.unmodifiable(_units);
  }

  @override
  Stream<List<PatrolUnitModel>> getPatrolUnitsStream() {
    _ensureInitialized().then((_) {
      _unitsController.add(List.unmodifiable(_units));
    });
    return _unitsController.stream;
  }

  @override
  Future<PatrolUnitModel?> findNearestAvailableUnit(
    double targetLat,
    double targetLng,
  ) async {
    await _ensureInitialized();
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
    await _ensureInitialized();
    final index = _units.indexWhere((u) => u.id == unitId);
    if (index != -1) {
      _units[index] = _units[index].copyWith(available: available);
      _unitsController.add(List.unmodifiable(_units));
    }
  }
}
