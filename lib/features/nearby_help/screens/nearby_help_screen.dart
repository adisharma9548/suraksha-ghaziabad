import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../data/providers/nearby_help_provider.dart';
import '../widgets/help_place_card.dart';

/// Native iOS Nearby Help Screen
/// Displays verified district emergency response centers with Apple HIG filter pills and card layout.
class NearbyHelpScreen extends ConsumerWidget {
  const NearbyHelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedHelpCategoryProvider);
    final placesAsync = ref.watch(helpPlacesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;
    final separatorColor = isDark ? AppColors.separatorDark : AppColors.separatorLight;

    final categories = ['All', 'Police Station', 'Women\'s Help Desk', 'Hospital'];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
      appBar: AppBar(
        title: Text('Nearby Help Centers', style: IosTypography.headline(color: primaryTextColor)),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Horizontal Apple HIG Category Pills
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
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      minSize: 34,
                      onPressed: () {
                        ref.read(selectedHelpCategoryProvider.notifier).state = cat;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryTextColor
                              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? primaryTextColor : separatorColor,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              Icon(
                                CupertinoIcons.checkmark,
                                size: 12,
                                color: isDark ? Colors.black : Colors.white,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              cat,
                              style: IosTypography.footnote(
                                color: isSelected
                                    ? (isDark ? Colors.black : Colors.white)
                                    : primaryTextColor,
                                weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Divider(height: 1, color: separatorColor),

            Expanded(
              child: placesAsync.when(
                data: (places) {
                  if (places.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.surfaceDark : AppColors.secondarySurfaceLight,
                                shape: BoxShape.circle,
                                border: Border.all(color: separatorColor),
                              ),
                              child: Center(
                                child: Icon(
                                  CupertinoIcons.building_2_fill,
                                  size: 34,
                                  color: primaryTextColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'No Emergency Places Found',
                              style: IosTypography.title2(color: primaryTextColor),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Help places (police stations, pink booths, hospitals) are imported from the verified Ghaziabad district directory.',
                              textAlign: TextAlign.center,
                              style: IosTypography.body(color: secondaryTextColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      return HelpPlaceCard(place: places[index]);
                    },
                  );
                },
                loading: () => Center(
                  child: CupertinoActivityIndicator(radius: 14, color: primaryTextColor),
                ),
                error: (e, _) => Center(
                  child: Text('Error loading directory: $e', style: IosTypography.subhead(color: secondaryTextColor)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
