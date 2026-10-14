import '../../models/trip_model.dart';

abstract class TripRepository {
  Future<TripModel> startTrip({
    required String userId,
    required String userName,
    required String destination,
    required double startLat,
    required double startLng,
    required double destLat,
    required double destLng,
    required List<String> contactPhones,
  });
  Future<void> addTripBreadcrumb({
    required String tripId,
    required double lat,
    required double lng,
  });
  Future<TripModel?> getActiveTrip(String userId);
  Stream<TripModel?> getTripStream(String tripId);
  Future<void> confirmSafetyCheck(String tripId);
  Future<void> triggerTripAlarm(String tripId);
  Future<void> completeTrip(String tripId);
}
