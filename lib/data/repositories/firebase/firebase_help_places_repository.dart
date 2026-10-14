import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../models/help_place_model.dart';
import '../abstract/help_places_repository.dart';

class FirebaseHelpPlacesRepository implements HelpPlacesRepository {
  final FirebaseFirestore? firestore;
  final List<HelpPlaceModel> _cachedPlaces = [];

  FirebaseHelpPlacesRepository({this.firestore});

  bool get _isFirebaseAvailable => Firebase.apps.isNotEmpty;
  FirebaseFirestore get _effectiveFirestore =>
      firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _helpPlacesCol =>
      _effectiveFirestore.collection('help_places');

  @override
  Future<List<HelpPlaceModel>> getHelpPlaces() async {
    if (_isFirebaseAvailable) {
      try {
        final snapshot = await _helpPlacesCol.get();
        final places = snapshot.docs
            .map((doc) => HelpPlaceModel.fromJson(doc.data()))
            .toList();

        _cachedPlaces.clear();
        _cachedPlaces.addAll(places);
        return List.unmodifiable(_cachedPlaces);
      } catch (e) {
        debugPrint('FirebaseHelpPlacesRepository.getHelpPlaces error: $e');
      }
    }
    return List.unmodifiable(_cachedPlaces);
  }

  @override
  Future<List<HelpPlaceModel>> getHelpPlacesByType(String type) async {
    final places = await getHelpPlaces();
    if (type.isEmpty || type == 'All') return places;
    return places.where((p) => p.type.toLowerCase() == type.toLowerCase()).toList();
  }
}
