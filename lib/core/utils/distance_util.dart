import 'dart:math';

class DistanceUtil {
  DistanceUtil._();

  /// Calculates the Haversine distance in meters between two lat/lng points
  static double calculateDistanceInMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusMeters = 6371000;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  /// Calculates the Haversine distance in kilometers between two lat/lng points
  static double calculateDistanceInKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return calculateDistanceInMeters(lat1, lon1, lat2, lon2) / 1000.0;
  }

  /// Formats distance into human readable text: e.g. "450 m" or "2.3 km"
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      final km = meters / 1000.0;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  static double _degToRad(double deg) {
    return deg * (pi / 180.0);
  }
}
