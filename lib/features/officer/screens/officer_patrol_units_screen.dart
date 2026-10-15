import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../core/utils/distance_util.dart';
import '../../../core/widgets/ios_widgets.dart';
import '../../../data/providers/patrol_provider.dart';
import '../../../data/providers/repository_providers.dart';

/// Native iOS Officer Patrol Units Screen
class OfficerPatrolUnitsScreen extends ConsumerWidget {
  const OfficerPatrolUnitsScreen({super.key});

  Future<void> _callUnit(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(patrolUnitsStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;
    final separatorColor = isDark ? AppColors.separatorDark : AppColors.separatorLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
      body: SafeArea(
        child: unitsAsync.when(
          data: (units) {
            if (units.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
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
                            CupertinoIcons.car_detailed,
                            size: 36,
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'No Patrol Units Registered',
                        style: IosTypography.title2(color: primaryTextColor),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'No active patrol units in the district roster yet.',
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
              itemCount: units.length,
              itemBuilder: (context, index) {
                final unit = units[index];
                final dist = DistanceUtil.formatDistance(
                  DistanceUtil.calculateDistanceInMeters(
                    AppConstants.ghaziabadCenterLat,
                    AppConstants.ghaziabadCenterLng,
                    unit.lat,
                    unit.lng,
                  ),
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: IosCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.secondarySurfaceDark : AppColors.secondarySurfaceLight,
                                shape: BoxShape.circle,
                                border: Border.all(color: separatorColor),
                              ),
                              child: Center(
                                child: Icon(
                                  CupertinoIcons.car_fill,
                                  color: primaryTextColor,
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    unit.name,
                                    style: IosTypography.headline(color: primaryTextColor),
                                  ),
                                  Text(
                                    '${unit.officerName} • $dist away',
                                    style: IosTypography.footnote(color: secondaryTextColor),
                                  ),
                                ],
                              ),
                            ),
                            CupertinoSwitch(
                              value: unit.available,
                              activeColor: primaryTextColor,
                              onChanged: (val) {
                                ref
                                    .read(patrolRepositoryProvider)
                                    .updateUnitAvailability(unit.id, val);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IosBadge(
                              label: unit.available ? 'AVAILABLE' : 'BUSY / ON PATROL',
                              icon: unit.available
                                  ? CupertinoIcons.checkmark_circle_fill
                                  : CupertinoIcons.clock_fill,
                              type: unit.available ? IosBadgeType.success : IosBadgeType.info,
                            ),
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              minSize: 36,
                              onPressed: () => _callUnit(unit.phone),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(CupertinoIcons.phone_fill, size: 14, color: AppColors.accentBlue),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Call Unit',
                                    style: IosTypography.subhead(color: AppColors.accentBlue),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => Center(
            child: CupertinoActivityIndicator(radius: 14, color: primaryTextColor),
          ),
          error: (err, _) => Center(
            child: Text('Error: $err', style: IosTypography.subhead(color: secondaryTextColor)),
          ),
        ),
      ),
    );
  }
}
