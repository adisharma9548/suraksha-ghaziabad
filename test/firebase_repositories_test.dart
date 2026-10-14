import 'package:flutter_test/flutter_test.dart';
import 'package:suraksha_ghaziabad/data/models/patrol_unit_model.dart';
import 'package:suraksha_ghaziabad/data/models/report_model.dart';
import 'package:suraksha_ghaziabad/data/repositories/firebase/firebase_sos_repository.dart';
import 'package:suraksha_ghaziabad/data/repositories/firebase/firebase_report_repository.dart';
import 'package:suraksha_ghaziabad/data/repositories/firebase/firebase_patrol_repository.dart';
import 'package:suraksha_ghaziabad/data/repositories/firebase/firebase_trip_repository.dart';

void main() {
  group('Firebase Repositories Lifecycle & State Machine Tests', () {
    test('FirebaseSosRepository trigger, assign, and resolution lifecycle', () async {
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

      // Add location breadcrumbs
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

      // Resolve SOS
      await repo.updateAlertStatus(
        alertId: alert.id,
        status: 'resolved',
      );
      final afterResolution = await repo.getActiveSosAlert('citizen_123');
      expect(afterResolution, isNull, reason: 'Active alert must be null once resolved');
    });

    test('FirebaseSosRepository decoy duress triggers silent stealth mode', () async {
      final repo = FirebaseSosRepository();
      final alert = await repo.triggerSos(
        userId: 'citizen_coerced',
        userName: 'Pooja',
        userPhone: '+919876543211',
        lat: 28.6658,
        lng: 77.4526,
      );

      expect(alert.status, 'triggered');
      expect(alert.isDuress, isFalse);

      // Victim enters decoy duress PIN under coercion
      await repo.flagDuress(alertId: alert.id);

      final duressAlert = await repo.getActiveSosAlert('citizen_coerced');
      expect(duressAlert, isNotNull);
      expect(duressAlert!.isDuress, isTrue);
      expect(duressAlert.status, 'duress_active');

      // Ensure breadcrumb streaming continues in duress mode
      await repo.addLocationBreadcrumb(
        alertId: alert.id,
        lat: 28.6680,
        lng: 77.4540,
      );
      final updatedDuress = await repo.getActiveSosAlert('citizen_coerced');
      expect(updatedDuress!.locations.length, 2);
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

    test('FirebasePatrolRepository nearest unit resolution with candidate units', () async {
      // Empty initially
      final emptyRepo = FirebasePatrolRepository();
      expect(await emptyRepo.findNearestAvailableUnit(28.6692, 77.4538), isNull);

      // Add candidate patrol units across Ghaziabad
      const unitRajNagar = PatrolUnitModel(
        id: 'pcr_raj_nagar',
        name: 'PCR-01 Raj Nagar',
        officerName: 'Inspector Kumar',
        phone: '+919454403001',
        lat: 28.6850,
        lng: 77.4420,
        available: true,
      );
      const unitIndirapuram = PatrolUnitModel(
        id: 'cheetah_indirapuram',
        name: 'Cheetah-04 Indirapuram',
        officerName: 'Sub-Inspector Verma',
        phone: '+919454403004',
        lat: 28.6350,
        lng: 77.3650,
        available: true,
      );

      final repo = FirebasePatrolRepository(initialUnits: [unitRajNagar, unitIndirapuram]);

      // Incident in Raj Nagar sector 10 (28.6840, 77.4410)
      final nearest = await repo.findNearestAvailableUnit(28.6840, 77.4410);
      expect(nearest, isNotNull);
      expect(nearest!.id, 'pcr_raj_nagar', reason: 'Must choose closest unit by Haversine distance');
    });
  });
}
