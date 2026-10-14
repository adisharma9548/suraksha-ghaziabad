import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/abstract/auth_repository.dart';
import '../repositories/abstract/sos_repository.dart';
import '../repositories/abstract/report_repository.dart';
import '../repositories/abstract/patrol_repository.dart';
import '../repositories/abstract/help_places_repository.dart';
import '../repositories/abstract/trip_repository.dart';
import '../repositories/mock/mock_auth_repository.dart';
import '../repositories/mock/mock_sos_repository.dart';
import '../repositories/mock/mock_report_repository.dart';
import '../repositories/mock/mock_patrol_repository.dart';
import '../repositories/mock/mock_help_places_repository.dart';
import '../repositories/mock/mock_trip_repository.dart';
import '../repositories/firebase/firebase_auth_repository.dart';
import '../repositories/firebase/firebase_sos_repository.dart';
import '../repositories/firebase/firebase_report_repository.dart';
import '../../core/config/app_config.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPreferencesProvider in main.dart');
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppConfig.useFirebase) {
    return FirebaseAuthRepository();
  }
  final prefs = ref.watch(sharedPreferencesProvider);
  return MockAuthRepository(prefs);
});

final sosRepositoryProvider = Provider<SosRepository>((ref) {
  if (AppConfig.useFirebase) {
    return FirebaseSosRepository();
  }
  final authRepo = ref.watch(authRepositoryProvider);
  return MockSosRepository(authRepo);
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  if (AppConfig.useFirebase) {
    return FirebaseReportRepository();
  }
  return MockReportRepository();
});

final patrolRepositoryProvider = Provider<PatrolRepository>((ref) {
  return MockPatrolRepository();
});

final helpPlacesRepositoryProvider = Provider<HelpPlacesRepository>((ref) {
  return MockHelpPlacesRepository();
});

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return MockTripRepository();
});
