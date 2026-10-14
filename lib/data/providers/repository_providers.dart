import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/abstract/auth_repository.dart';
import '../repositories/abstract/sos_repository.dart';
import '../repositories/abstract/report_repository.dart';
import '../repositories/abstract/patrol_repository.dart';
import '../repositories/abstract/help_places_repository.dart';
import '../repositories/abstract/trip_repository.dart';
import '../repositories/firebase/firebase_auth_repository.dart';
import '../repositories/firebase/firebase_sos_repository.dart';
import '../repositories/firebase/firebase_report_repository.dart';
import '../repositories/firebase/firebase_patrol_repository.dart';
import '../repositories/firebase/firebase_help_places_repository.dart';
import '../repositories/firebase/firebase_trip_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPreferencesProvider in main.dart');
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

final sosRepositoryProvider = Provider<SosRepository>((ref) {
  return FirebaseSosRepository();
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return FirebaseReportRepository();
});

final patrolRepositoryProvider = Provider<PatrolRepository>((ref) {
  return FirebasePatrolRepository();
});

final helpPlacesRepositoryProvider = Provider<HelpPlacesRepository>((ref) {
  return FirebaseHelpPlacesRepository();
});

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  return FirebaseTripRepository();
});
