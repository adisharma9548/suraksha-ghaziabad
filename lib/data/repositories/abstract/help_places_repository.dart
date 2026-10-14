import '../../models/help_place_model.dart';

abstract class HelpPlacesRepository {
  Future<List<HelpPlaceModel>> getHelpPlaces();
  Future<List<HelpPlaceModel>> getHelpPlacesByType(String type);
}
