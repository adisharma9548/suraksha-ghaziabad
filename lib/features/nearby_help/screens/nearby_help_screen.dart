import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/nearby_help_provider.dart';
import '../widgets/help_place_card.dart';

class NearbyHelpScreen extends ConsumerWidget {
  const NearbyHelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedHelpCategoryProvider);
    final placesAsync = ref.watch(helpPlacesProvider);

    final categories = ['All', 'Police Station', 'Women\'s Help Desk', 'Hospital'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Emergency Help Centers', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category filter chips
            SizedBox(
              height: 48,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = cat == selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primaryPurpleSurface,
                      checkmarkColor: AppColors.primaryPurple,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primaryPurple : AppColors.textPrimaryLight,
                      ),
                      onSelected: (val) {
                        ref.read(selectedHelpCategoryProvider.notifier).state = cat;
                      },
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1, color: AppColors.dividerLight),

            Expanded(
              child: placesAsync.when(
                data: (places) {
                  if (places.isEmpty) {
                    return const Center(child: Text('No emergency places found.'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      return HelpPlaceCard(place: places[index]);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
