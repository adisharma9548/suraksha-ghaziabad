import '../../models/help_place_model.dart';
import '../abstract/help_places_repository.dart';

class MockHelpPlacesRepository implements HelpPlacesRepository {
  final List<HelpPlaceModel> _places = [];

  MockHelpPlacesRepository([List<HelpPlaceModel>? initialPlaces]) {
    if (initialPlaces != null) {
      _places.addAll(initialPlaces);
    }
  }

  @override
  Future<List<HelpPlaceModel>> getHelpPlaces() async {
    return List.unmodifiable(_places);
  }

  @override
  Future<List<HelpPlaceModel>> getHelpPlacesByType(String type) async {
    if (type.isEmpty || type == 'All') return List.unmodifiable(_places);
    return _places.where((p) => p.type.toLowerCase() == type.toLowerCase()).toList();
  }
}
