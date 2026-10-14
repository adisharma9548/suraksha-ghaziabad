import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip_model.dart';
import 'repository_providers.dart';
import 'auth_provider.dart';

class TripState {
  final TripModel? activeTrip;
  final bool isTracking;
  final bool showAreYouOkDialog;
  final int safetyResponseSecondsLeft; // 60s countdown
  final String? errorMessage;

  const TripState({
    this.activeTrip,
    this.isTracking = false,
    this.showAreYouOkDialog = false,
    this.safetyResponseSecondsLeft = 60,
    this.errorMessage,
  });

  bool get hasActiveTrip => activeTrip != null && activeTrip!.isActive;

  TripState copyWith({
    TripModel? activeTrip,
    bool? isTracking,
    bool? showAreYouOkDialog,
    int? safetyResponseSecondsLeft,
    String? errorMessage,
  }) {
    return TripState(
      activeTrip: activeTrip ?? this.activeTrip,
      isTracking: isTracking ?? this.isTracking,
      showAreYouOkDialog: showAreYouOkDialog ?? this.showAreYouOkDialog,
      safetyResponseSecondsLeft:
          safetyResponseSecondsLeft ?? this.safetyResponseSecondsLeft,
      errorMessage: errorMessage,
    );
  }
}

class TripNotifier extends StateNotifier<TripState> {
  final Ref _ref;
  Timer? _safetyCheckSimulationTimer;
  Timer? _alertCountdownTimer;

  TripNotifier(this._ref) : super(const TripState());

  Future<void> startTrip({
    required String destination,
    required double startLat,
    required double startLng,
    required double destLat,
    required double destLng,
  }) async {
    final user = _ref.read(authProvider).user;
    final userId = user?.id ?? 'guest_user';
    final userName = user?.name ?? 'Citizen';

    final contacts =
        await _ref.read(authRepositoryProvider).getTrustedContacts();
    final contactPhones = contacts.map((c) => c.phone).toList();

    try {
      final trip = await _ref.read(tripRepositoryProvider).startTrip(
            userId: userId,
            userName: userName,
            destination: destination,
            startLat: startLat,
            startLng: startLng,
            destLat: destLat,
            destLng: destLng,
            contactPhones: contactPhones,
          );

      state = TripState(
        activeTrip: trip,
        isTracking: true,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  void promptSafetyCheck() {
    state = state.copyWith(
      showAreYouOkDialog: true,
      safetyResponseSecondsLeft: 60,
    );

    _alertCountdownTimer?.cancel();
    _alertCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.safetyResponseSecondsLeft > 1) {
        state = state.copyWith(
          safetyResponseSecondsLeft: state.safetyResponseSecondsLeft - 1,
        );
      } else {
        timer.cancel();
        // Time expired! Trigger emergency alerts to trusted contacts
        _autoAlertContactsOverdue();
      }
    });
  }

  Future<void> confirmSafe() async {
    _alertCountdownTimer?.cancel();
    state = state.copyWith(showAreYouOkDialog: false);

    final trip = state.activeTrip;
    if (trip != null) {
      await _ref.read(tripRepositoryProvider).confirmSafetyCheck(trip.id);
    }
  }

  Future<void> triggerTripSos() async {
    _alertCountdownTimer?.cancel();
    state = state.copyWith(showAreYouOkDialog: false);

    final trip = state.activeTrip;
    if (trip != null) {
      await _ref.read(tripRepositoryProvider).triggerTripAlarm(trip.id);
    }
  }

  Future<void> _autoAlertContactsOverdue() async {
    state = state.copyWith(showAreYouOkDialog: false);
    final trip = state.activeTrip;
    if (trip != null) {
      await _ref.read(tripRepositoryProvider).triggerTripAlarm(trip.id);
    }
  }

  Future<void> endTrip() async {
    _safetyCheckSimulationTimer?.cancel();
    _alertCountdownTimer?.cancel();

    final trip = state.activeTrip;
    if (trip != null) {
      await _ref.read(tripRepositoryProvider).completeTrip(trip.id);
    }
    state = const TripState();
  }

  @override
  void dispose() {
    _safetyCheckSimulationTimer?.cancel();
    _alertCountdownTimer?.cancel();
    super.dispose();
  }
}

final tripProvider = StateNotifierProvider<TripNotifier, TripState>((ref) {
  return TripNotifier(ref);
});
