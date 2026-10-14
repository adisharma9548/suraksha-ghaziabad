import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/distance_util.dart';
import '../../../data/models/help_place_model.dart';

class HelpPlaceCard extends StatelessWidget {
  final HelpPlaceModel place;

  const HelpPlaceCard({super.key, required this.place});

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Women\'s Help Desk':
        return const Color(0xFFD81B60);
      case 'Police Station':
        return AppColors.policeNavy;
      case 'Hospital':
        return AppColors.safeGreen;
      default:
        return AppColors.primaryPurple;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Women\'s Help Desk':
        return Icons.female_rounded;
      case 'Police Station':
        return Icons.local_police_rounded;
      case 'Hospital':
        return Icons.local_hospital_rounded;
      default:
        return Icons.place_rounded;
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
    final color = _getTypeColor(place.type);
    final icon = _getTypeIcon(place.type);

    final distanceStr = DistanceUtil.formatDistance(
      DistanceUtil.calculateDistanceInMeters(
        AppConstants.ghaziabadCenterLat,
        AppConstants.ghaziabadCenterLng,
        place.lat,
        place.lng,
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          place.type.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  distanceStr,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              place.address,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondaryLight,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.verified_user_rounded, size: 13, color: AppColors.safeGreen),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Verified • Source: ${place.source}${place.verifiedAt != null ? ' (${place.verifiedAt!.day}/${place.verifiedAt!.month}/${place.verifiedAt!.year})' : ''}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.safeGreen,
                      fontWeight: FontWeight.w600,
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
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(0, 40),
                      side: BorderSide(color: color),
                      foregroundColor: color,
                    ),
                    icon: const Icon(Icons.phone, size: 16),
                    label: Text('Call ${place.phone}', style: const TextStyle(fontSize: 12)),
                    onPressed: () => _makeCall(place.phone),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      minimumSize: const Size(0, 40),
                    ),
                    icon: const Icon(Icons.directions, size: 16),
                    label: const Text('Directions', style: TextStyle(fontSize: 12)),
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
