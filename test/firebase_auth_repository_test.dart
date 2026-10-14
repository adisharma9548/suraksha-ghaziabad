import 'package:flutter_test/flutter_test.dart';
import 'package:suraksha_ghaziabad/core/utils/hash_util.dart';
import 'package:suraksha_ghaziabad/data/models/user_model.dart';
import 'package:suraksha_ghaziabad/data/models/trusted_contact_model.dart';
import 'package:suraksha_ghaziabad/data/repositories/firebase/firebase_auth_repository.dart';

void main() {
  group('FirebaseAuthRepository Emergency PIN Verification (Safety Tests)', () {
    test('returns false when no user is authenticated', () async {
      final repo = FirebaseAuthRepository();
      final result = await repo.verifyEmergencyPin('1234');
      expect(result, isFalse, reason: 'Must not allow PIN verification when user is null');
    });

    test('returns false when user emergencyPinHash is empty', () async {
      final userWithoutPin = UserModel(
        id: 'user_test_1',
        name: 'Test Citizen',
        phone: '+919999999999',
        role: 'citizen',
        language: 'en',
        emergencyPinHash: '',
        createdAt: DateTime.now(),
      );

      final repo = FirebaseAuthRepository(initialUser: userWithoutPin);
      final result = await repo.verifyEmergencyPin('1234');
      expect(result, isFalse, reason: 'Must not accept any PIN if emergencyPinHash is empty');
    });

    test('returns false when incorrect PIN is provided', () async {
      final userWithPin = UserModel(
        id: 'user_test_2',
        name: 'Test Citizen',
        phone: '+919999999999',
        role: 'citizen',
        language: 'en',
        emergencyPinHash: HashUtil.hashPin('5821'),
        createdAt: DateTime.now(),
      );

      final repo = FirebaseAuthRepository(initialUser: userWithPin);
      expect(await repo.verifyEmergencyPin('0000'), isFalse);
      expect(await repo.verifyEmergencyPin('1234'), isFalse);
      expect(await repo.verifyEmergencyPin('9999'), isFalse);
    });

    test('returns true when exact matching PIN is provided', () async {
      const pin = '4829';
      final userWithPin = UserModel(
        id: 'user_test_3',
        name: 'Test Citizen',
        phone: '+919999999999',
        role: 'citizen',
        language: 'en',
        emergencyPinHash: HashUtil.hashPin(pin),
        createdAt: DateTime.now(),
      );

      final repo = FirebaseAuthRepository(initialUser: userWithPin);
      expect(await repo.verifyEmergencyPin(pin), isTrue);
    });

    test('changing emergency PIN updates the hash and invalidates old PIN', () async {
      final user = UserModel(
        id: 'user_test_4',
        name: 'Test Citizen',
        phone: '+919999999999',
        role: 'citizen',
        language: 'en',
        emergencyPinHash: HashUtil.hashPin('1111'),
        createdAt: DateTime.now(),
      );

      final repo = FirebaseAuthRepository(initialUser: user);
      expect(await repo.verifyEmergencyPin('1111'), isTrue);

      await repo.changeEmergencyPin('2222');
      expect(await repo.verifyEmergencyPin('1111'), isFalse, reason: 'Old PIN must fail');
      expect(await repo.verifyEmergencyPin('2222'), isTrue, reason: 'New PIN must succeed');
    });

    test('saveProfile updates emergency PIN correctly', () async {
      final user = UserModel(
        id: 'user_test_5',
        name: 'Initial Name',
        phone: '+919999999999',
        role: 'citizen',
        language: 'en',
        emergencyPinHash: HashUtil.hashPin('0000'),
        createdAt: DateTime.now(),
      );

      final repo = FirebaseAuthRepository(initialUser: user);
      await repo.saveProfile(
        name: 'Updated Name',
        pin: '9876',
        contacts: [
          TrustedContactModel(
            id: 'c1',
            userId: user.id,
            name: 'Contact 1',
            phone: '+919876543210',
          ),
        ],
      );

      expect(await repo.verifyEmergencyPin('0000'), isFalse);
      expect(await repo.verifyEmergencyPin('9876'), isTrue);
      final contacts = await repo.getTrustedContacts();
      expect(contacts.length, 1);
    });
  });
}
