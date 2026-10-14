import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/help_place_model.dart';
import '../abstract/help_places_repository.dart';

class MockHelpPlacesRepository implements HelpPlacesRepository {
  final List<HelpPlaceModel> _places = [];
  bool _isInitialized = false;

  MockHelpPlacesRepository();

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/ghaziabad_seed_data.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final rawList = data['help_places'] as List;
      _places.clear();
      for (final item in rawList) {
        _places.add(HelpPlaceModel.fromJson(item as Map<String, dynamic>));
      }
    } catch (_) {
      // Fallback
    }
    _isInitialized = true;
  }

  @override
  Future<List<HelpPlaceModel>> getHelpPlaces() async {
    await _ensureInitialized();
    return List.unmodifiable(_places);
  }

  @override
  Future<List<HelpPlaceModel>> getHelpPlacesByType(String type) async {
    await _ensureInitialized();
    if (type.isEmpty || type == 'All') return List.unmodifiable(_places);
    return _places.where((p) => p.type.toLowerCase() == type.toLowerCase()).toList();
  }
}
