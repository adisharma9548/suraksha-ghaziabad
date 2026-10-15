import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../core/utils/distance_util.dart';
import '../../../core/widgets/ios_widgets.dart';
import '../../../data/models/help_place_model.dart';

/// Native iOS Help Place Card
/// Features 16px squircle card, multi-cue category icon & badge, and 44pt call/navigate actions.
class HelpPlaceCard extends StatelessWidget {
  final HelpPlaceModel place;

  const HelpPlaceCard({super.key, required this.place});

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Women\'s Help Desk':
        return CupertinoIcons.shield_lefthalf_fill;
      case 'Police Station':
        return CupertinoIcons.shield_fill;
      case 'Hospital':
        return CupertinoIcons.plus_square_fill;
      default:
        return CupertinoIcons.building_2_fill;
    }
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openNavigation(double lat, double lng) async {
    final uri =
        Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;
    final separatorColor = isDark ? AppColors.separatorDark : AppColors.separatorLight;
    final icon = _getTypeIcon(place.type);

    final distanceStr = DistanceUtil.formatDistance(
      DistanceUtil.calculateDistanceInMeters(
        AppConstants.ghaziabadCenterLat,
        AppConstants.ghaziabadCenterLng,
        place.lat,
        place.lng,
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.secondarySurfaceDark : AppColors.secondarySurfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: separatorColor),
                  ),
                  child: Center(
                    child: Icon(icon, color: primaryTextColor, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IosBadge(
                        label: place.type.toUpperCase(),
                        icon: icon,
                        type: IosBadgeType.info,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        place.name,
                        style: IosTypography.headline(color: primaryTextColor),
                      ),
                    ],
                  ),
                ),
                Text(
                  distanceStr,
                  style: IosTypography.footnote(
                    color: secondaryTextColor,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              place.address,
              style: IosTypography.subhead(color: secondaryTextColor),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  CupertinoIcons.checkmark_seal_fill,
                  size: 14,
                  color: primaryTextColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Verified Source: ${place.source}',
                    style: IosTypography.caption1(
                      color: secondaryTextColor,
                      weight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: IosButton(
                    text: 'Call ${place.phone}',
                    icon: CupertinoIcons.phone_fill,
                    type: IosButtonType.secondary,
                    onPressed: () => _makeCall(place.phone),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: IosButton(
                    text: 'Directions',
                    icon: CupertinoIcons.arrow_turn_up_right,
                    type: IosButtonType.primary,
                    onPressed: () => _openNavigation(place.lat, place.lng),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
