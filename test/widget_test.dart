import 'package:flutter_test/flutter_test.dart';
import 'package:suraksha_ghaziabad/core/utils/distance_util.dart';
import 'package:suraksha_ghaziabad/core/utils/hash_util.dart';
import 'package:suraksha_ghaziabad/data/models/report_model.dart';
import 'package:suraksha_ghaziabad/data/models/sos_alert_model.dart';

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

    test('ReportModel serialization maintains fields', () {
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
      );

      final json = report.toJson();
      final fromJson = ReportModel.fromJson(json);

      expect(fromJson.id, 'test_rep_1');
      expect(fromJson.category, 'Broken streetlight');
      expect(fromJson.severity, 4);
      expect(fromJson.isAnonymous, isTrue);
    });

    test('SosAlertModel active status lifecycle check', () {
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
    });
  });
}
