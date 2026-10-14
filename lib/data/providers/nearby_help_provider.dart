import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/help_place_model.dart';
import 'repository_providers.dart';

final selectedHelpCategoryProvider = StateProvider<String>((ref) => 'All');

final helpPlacesProvider = FutureProvider<List<HelpPlaceModel>>((ref) async {
  final category = ref.watch(selectedHelpCategoryProvider);
  return ref.watch(helpPlacesRepositoryProvider).getHelpPlacesByType(category);
});
