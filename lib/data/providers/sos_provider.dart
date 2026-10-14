import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/sos_alert_model.dart';
import 'repository_providers.dart';
import 'auth_provider.dart';
import '../../core/services/foreground_location_service.dart';

class SosState {
  final SosAlertModel? activeAlert;
  final bool isTriggering;
  final int cancelCountdown; // 5 to 0
  final bool isAudioRecording;
  final String? errorMessage;

  const SosState({
    this.activeAlert,
    this.isTriggering = false,
    this.cancelCountdown = 5,
    this.isAudioRecording = false,
    this.errorMessage,
  });

  bool get hasActiveSos => activeAlert != null && activeAlert!.isActive;

  SosState copyWith({
    SosAlertModel? activeAlert,
    bool? isTriggering,
    int? cancelCountdown,
    bool? isAudioRecording,
    String? errorMessage,
  }) {
    return SosState(
      activeAlert: activeAlert ?? this.activeAlert,
      isTriggering: isTriggering ?? this.isTriggering,
      cancelCountdown: cancelCountdown ?? this.cancelCountdown,
      isAudioRecording: isAudioRecording ?? this.isAudioRecording,
      errorMessage: errorMessage,
    );
  }
}

class SosNotifier extends StateNotifier<SosState> {
  final Ref _ref;
  Timer? _countdownTimer;
  StreamSubscription<SosAlertModel?>? _alertSubscription;

  SosNotifier(this._ref) : super(const SosState());

  Future<void> triggerSos({
    required double lat,
    required double lng,
  }) async {
    final user = _ref.read(authProvider).user;
    final userId = user?.id ?? 'citizen_user';
    final userName = user != null && user.name.isNotEmpty ? user.name : 'Citizen in Distress';
    final userPhone = user?.phone ?? '';

    state = state.copyWith(
      isTriggering: true,
      cancelCountdown: 5,
      isAudioRecording: true,
      errorMessage: null,
    );

    try {
      // (a) Launch direct 112 emergency phone call intent to complement national emergency service
      final telUri = Uri.parse('tel:112');
      try {
        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri);
        }
      } catch (telErr) {
        debugPrint('Direct 112 intent launch notice: $telErr');
      }

      // (b) Write alert to Firestore
      final alert = await _ref.read(sosRepositoryProvider).triggerSos(
            userId: userId,
            userName: userName,
            userPhone: userPhone,
            lat: lat,
            lng: lng,
          );

      state = state.copyWith(
        activeAlert: alert,
        isTriggering: false,
      );

      // (c) Start Foreground Location Service for live breadcrumb streaming during SOS
      ForegroundLocationService.instance.startTracking(
        sessionId: alert.id,
        sessionType: 'sos',
        onLocationUpdate: (currentLat, currentLng) {
          _ref.read(sosRepositoryProvider).addLocationBreadcrumb(
                alertId: alert.id,
                lat: currentLat,
                lng: currentLng,
              );
        },
      );

      // Start 5-second cancel countdown
      _startCountdown(alert.id);

      // Subscribe to real-time status changes
      _subscribeToAlert(alert.id);

      // (d) Notify trusted contacts via SMS intent
      _sendFallbackSms(lat, lng, userName);
    } catch (e) {
      state = state.copyWith(isTriggering: false, errorMessage: e.toString());
    }
  }

  void _startCountdown(String alertId) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.cancelCountdown > 1) {
        state = state.copyWith(cancelCountdown: state.cancelCountdown - 1);
      } else {
        timer.cancel();
        state = state.copyWith(cancelCountdown: 0);
      }
    });
  }

  void _subscribeToAlert(String alertId) {
    _alertSubscription?.cancel();
    _alertSubscription = _ref
        .read(sosRepositoryProvider)
        .getSosAlertStream(alertId)
        .listen((updatedAlert) {
      if (updatedAlert != null) {
        state = state.copyWith(activeAlert: updatedAlert);
        if (!updatedAlert.isActive) {
          state = state.copyWith(isAudioRecording: false);
          ForegroundLocationService.instance.stopTracking();
        }
      }
    });
  }

  Future<bool> cancelSosWithPin(String pin) async {
    final activeAlert = state.activeAlert;
    if (activeAlert == null) return false;

    try {
      // 1. Check if victim entered Decoy Duress PIN under coercion
      final isDuress =
          await _ref.read(authRepositoryProvider).verifyDuressPin(pin);
      if (isDuress) {
        // Flag silent duress alert to District Police Control Room
        await _ref
            .read(sosRepositoryProvider)
            .flagDuress(alertId: activeAlert.id);

        // Cancel on-screen alerts so screen visually clears to protect victim from assailant
        _countdownTimer?.cancel();
        _alertSubscription?.cancel();

        // Note: ForegroundLocationService remains ACTIVE to stream live coordinates to police!
        state = const SosState();
        return true;
      }

      // 2. Otherwise verify authentic emergency PIN
      final isValidPin =
          await _ref.read(authRepositoryProvider).verifyEmergencyPin(pin);
      if (!isValidPin) {
        return false;
      }

      await _ref.read(sosRepositoryProvider).cancelSos(
            alertId: activeAlert.id,
            pin: pin,
          );
      _countdownTimer?.cancel();
      _alertSubscription?.cancel();
      await ForegroundLocationService.instance.stopTracking();
      state = const SosState();
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> _sendFallbackSms(double lat, double lng, String name) async {
    try {
      final contacts = await _ref.read(authRepositoryProvider).getTrustedContacts();
      if (contacts.isEmpty) return;

      final mapsUrl = 'https://maps.google.com/?q=$lat,$lng';
      final message =
          'EMERGENCY SOS: $name requires urgent emergency assistance in Ghaziabad! GPS Location: $mapsUrl';

      final recipients = contacts.map((c) => c.phone).join(';');
      final smsUri = Uri(
        scheme: 'sms',
        path: recipients,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    } catch (e) {
      debugPrint('SMS intent fallback notice: $e');
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _alertSubscription?.cancel();
    ForegroundLocationService.instance.stopTracking();
    super.dispose();
  }
}

final sosProvider = StateNotifierProvider<SosNotifier, SosState>((ref) {
  return SosNotifier(ref);
});

final allOfficerAlertsStreamProvider =
    StreamProvider<List<SosAlertModel>>((ref) {
  return ref.watch(sosRepositoryProvider).getAllActiveAlertsStream();
});
