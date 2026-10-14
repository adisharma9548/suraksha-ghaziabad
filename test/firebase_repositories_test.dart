import 'package:flutter_test/flutter_test.dart';
import 'package:suraksha_ghaziabad/data/models/report_model.dart';
import 'package:suraksha_ghaziabad/data/repositories/firebase/firebase_sos_repository.dart';
import 'package:suraksha_ghaziabad/data/repositories/firebase/firebase_report_repository.dart';
import 'package:suraksha_ghaziabad/data/repositories/firebase/firebase_patrol_repository.dart';
import 'package:suraksha_ghaziabad/data/repositories/firebase/firebase_trip_repository.dart';

void main() {
  group('Firebase Repositories Lifecycle & State Machine Tests', () {
    test('FirebaseSosRepository trigger and lifecycle transitions', () async {
      final repo = FirebaseSosRepository();
      final alert = await repo.triggerSos(
        userId: 'citizen_123',
        userName: 'Aditi',
        userPhone: '+919876543210',
        lat: 28.6692,
        lng: 77.4538,
      );

      expect(alert.id, isNotEmpty);
      expect(alert.userId, 'citizen_123');
      expect(alert.status, 'triggered');
      expect(alert.isActive, isTrue);
      expect(alert.locations.length, 1);

      // Add location breadcrumb
      await repo.addLocationBreadcrumb(
        alertId: alert.id,
        lat: 28.6700,
        lng: 77.4550,
      );

      final active = await repo.getActiveSosAlert('citizen_123');
      expect(active, isNotNull);
      expect(active!.locations.length, 2);

      // Assign unit
      await repo.assignPatrolUnit(
        alertId: alert.id,
        unitId: 'unit_01',
        unitName: 'Cheetah-1',
        officerPhone: '+919454403001',
      );
      final assigned = await repo.getActiveSosAlert('citizen_123');
      expect(assigned!.status, 'assigned');
      expect(assigned.assignedUnitId, 'unit_01');

      // Cancel SOS
      await repo.cancelSos(alertId: alert.id, pin: '1234');
      final cancelled = await repo.getActiveSosAlert('citizen_123');
      expect(cancelled, isNull, reason: 'Active alert should be null once cancelled');
    });

    test('FirebaseReportRepository submission and status updates', () async {
      final repo = FirebaseReportRepository();
      final report = ReportModel(
        id: 'rep_fb_1',
        category: 'Broken streetlight',
        description: 'Dark corner in Raj Nagar',
        lat: 28.6850,
        lng: 77.4420,
        createdAt: DateTime.now(),
      );

      final submitted = await repo.submitReport(report);
      expect(submitted.id, 'rep_fb_1');

      final allReports = await repo.getAllReports();
      expect(allReports.any((r) => r.id == 'rep_fb_1'), isTrue);

      await repo.updateReportStatus(
        reportId: 'rep_fb_1',
        status: 'In progress',
        adminNote: 'Nagar Nigam team dispatched',
      );

      final updatedReports = await repo.getAllReports();
      final updated = updatedReports.firstWhere((r) => r.id == 'rep_fb_1');
      expect(updated.status, 'In progress');
      expect(updated.adminNote, 'Nagar Nigam team dispatched');
    });

    test('FirebaseTripRepository start, check-in, and completion', () async {
      final repo = FirebaseTripRepository();
      final trip = await repo.startTrip(
        userId: 'citizen_123',
        userName: 'Aditi',
        destination: 'Vaishali Metro Station',
        startLat: 28.6432,
        startLng: 77.3695,
        destLat: 28.6478,
        destLng: 77.3392,
        contactPhones: ['+919876543210'],
      );

      expect(trip.id, isNotEmpty);
      expect(trip.status, 'active');
      expect(trip.isActive, isTrue);

      final activeTrip = await repo.getActiveTrip('citizen_123');
      expect(activeTrip, isNotNull);

      await repo.confirmSafetyCheck(trip.id);
      await repo.completeTrip(trip.id);

      final afterCompletion = await repo.getActiveTrip('citizen_123');
      expect(afterCompletion, isNull, reason: 'Completed trip must not be returned as active');
    });

    test('FirebasePatrolRepository nearest unit resolution', () async {
      final repo = FirebasePatrolRepository();
      // Test nearest calculation with empty / default units
      final nearest = await repo.findNearestAvailableUnit(28.6692, 77.4538);
      expect(nearest, isNull); // Empty initially before units are loaded
    });
  });
}
