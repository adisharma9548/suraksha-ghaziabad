import 'package:flutter_test/flutter_test.dart';
import 'package:suraksha_ghaziabad/core/utils/distance_util.dart';
import 'package:suraksha_ghaziabad/core/utils/hash_util.dart';
import 'package:suraksha_ghaziabad/data/models/report_model.dart';
import 'package:suraksha_ghaziabad/data/models/sos_alert_model.dart';
import 'package:suraksha_ghaziabad/data/models/user_model.dart';

void main() {
  group('Suraksha Ghaziabad Core Utility Tests', () {
    test('HashUtil hashes and verifies PIN correctly', () {
      const pin = '1234';
      final hash = HashUtil.hashPin(pin);

      expect(hash, isNotEmpty);
      expect(HashUtil.verifyPin('1234', hash), isTrue);
      expect(HashUtil.verifyPin('0000', hash), isFalse);
    });

    test('DistanceUtil calculates Haversine distance accurately', () {
      // Ghaziabad center to Vaishali Metro (~11.6 km)
      final distanceMeters = DistanceUtil.calculateDistanceInMeters(
        28.6692,
        77.4538,
        28.6478,
        77.3392,
      );

      expect(distanceMeters, greaterThan(10000));
      expect(distanceMeters, lessThan(15000));

      final formatted = DistanceUtil.formatDistance(distanceMeters);
      expect(formatted.contains('km'), isTrue);
    });

    test('ReportModel authority resolution and ward mapping', () {
      expect(ReportModel.resolveAuthority('Broken streetlight'),
          'NAGAR_NIGAM_GHAZIABAD');
      expect(ReportModel.resolveAuthority('Isolated road'),
          'NAGAR_NIGAM_GHAZIABAD');
      expect(ReportModel.resolveAuthority('Harassment'), 'UP_POLICE');
      expect(ReportModel.resolveAuthority('Drunk crowd'), 'UP_POLICE');

      final ward = ReportModel.resolveWard(28.6432, 77.3695, 'Indirapuram');
      expect(ward.contains('Vasundhara'), isTrue);
    });

    test('ReportModel serialization maintains fields and authority queues',
        () {
      final report = ReportModel(
        id: 'test_rep_1',
        category: 'Broken streetlight',
        description: 'Dark road near Kala Patthar',
        lat: 28.6432,
        lng: 77.3695,
        locationName: 'Indirapuram',
        status: 'Open',
        createdAt: DateTime(2026, 3, 10),
        isAnonymous: true,
        severity: 4,
        timeOfDay: 'Night',
        routedAuthority: 'NAGAR_NIGAM_GHAZIABAD',
        acknowledgementStatus: 'Delivered to Control Room',
      );

      final json = report.toJson();
      final fromJson = ReportModel.fromJson(json);

      expect(fromJson.id, 'test_rep_1');
      expect(fromJson.category, 'Broken streetlight');
      expect(fromJson.severity, 4);
      expect(fromJson.isAnonymous, isTrue);
      expect(fromJson.routedAuthority, 'NAGAR_NIGAM_GHAZIABAD');
      expect(fromJson.acknowledgementStatus, 'Delivered to Control Room');
    });

    test('SosAlertModel active status and duress lifecycle check', () {
      final alert = SosAlertModel(
        id: 'sos_1',
        userId: 'u_1',
        userName: 'Aditi',
        userPhone: '+919876543210',
        status: 'triggered',
        startedAt: DateTime.now(),
      );

      expect(alert.isActive, isTrue);

      final resolved = alert.copyWith(status: 'resolved');
      expect(resolved.isActive, isFalse);

      final cancelled = alert.copyWith(status: 'cancelled');
      expect(cancelled.isActive, isFalse);

      // Duress alert remains active to protect victim even if status marked cancelled
      final duressAlert = alert.copyWith(isDuress: true, status: 'cancelled');
      expect(duressAlert.isActive, isTrue);
    });

    test('UserModel duressPinHash verification and serialization', () {
      final user = UserModel(
        id: 'usr_test',
        name: 'Citizen Safety Tester',
        phone: '+919876543210',
        role: 'citizen',
        emergencyPinHash: HashUtil.hashPin('4321'),
        duressPinHash: HashUtil.hashPin('9999'),
        createdAt: DateTime.now(),
      );

      expect(HashUtil.verifyPin('4321', user.emergencyPinHash), isTrue);
      expect(HashUtil.verifyPin('9999', user.duressPinHash), isTrue);
      expect(HashUtil.verifyPin('1234', user.duressPinHash), isFalse);

      final json = user.toJson();
      final fromJson = UserModel.fromJson(json);
      expect(fromJson.duressPinHash, user.duressPinHash);
    });
  });
}
