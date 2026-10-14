import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Foreground Location Service for Active SOS and Trips.
///
/// Location coordinates are strictly streamed ONLY during an active SOS emergency
/// or active trip session, never running continuously in the background.
class ForegroundLocationService {
  ForegroundLocationService._();
  static final ForegroundLocationService instance = ForegroundLocationService._();

  StreamSubscription<Position>? _positionSubscription;
  bool _isRunning = false;
  String? _activeSessionId;
  String? _sessionType; // 'sos' or 'trip'

  bool get isRunning => _isRunning;
  String? get activeSessionId => _activeSessionId;
  String? get sessionType => _sessionType;

  /// Starts high-accuracy foreground location streaming
  Future<bool> startTracking({
    required String sessionId,
    required String sessionType,
    required void Function(double lat, double lng) onLocationUpdate,
  }) async {
    // If already tracking this session, do not re-initialize
    if (_isRunning && _activeSessionId == sessionId) {
      return true;
    }

    await stopTracking();

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('ForegroundLocationService: Location permission denied.');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('ForegroundLocationService: Location permission permanently denied.');
        return false;
      }

      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        debugPrint('ForegroundLocationService: Location service disabled on device.');
        return false;
      }

      // Configure location settings
      late LocationSettings locationSettings;
      if (defaultTargetPlatform == TargetPlatform.android) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
          intervalDuration: const Duration(seconds: 5),
          foregroundNotificationConfig: ForegroundNotificationConfig(
            notificationTitle: sessionType == 'sos'
                ? 'EMERGENCY SOS ACTIVE - Suraksha Ghaziabad'
                : 'Safe Trip Tracking - Suraksha Ghaziabad',
            notificationText: sessionType == 'sos'
                ? 'Streaming live location to Control Room and Emergency Contacts'
                : 'Sharing live trip journey with trusted emergency contacts',
            enableWakeLock: true,
            notificationIcon: const AndroidResource(name: 'ic_launcher'),
          ),
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
          activityType: ActivityType.fitness,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: true,
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        );
      }

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          onLocationUpdate(position.latitude, position.longitude);
        },
        onError: (e) {
          debugPrint('ForegroundLocationService stream error: $e');
        },
      );

      _isRunning = true;
      _activeSessionId = sessionId;
      _sessionType = sessionType;
      debugPrint('ForegroundLocationService started for $sessionType ($sessionId)');
      return true;
    } catch (e) {
      debugPrint('ForegroundLocationService.startTracking error: $e');
      return false;
    }
  }

  /// Stops location streaming and releases foreground service
  Future<void> stopTracking() async {
    if (_positionSubscription != null) {
      await _positionSubscription?.cancel();
      _positionSubscription = null;
    }
    _isRunning = false;
    _activeSessionId = null;
    _sessionType = null;
    debugPrint('ForegroundLocationService stopped.');
  }
}
