import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../models/user_model.dart';
import '../../models/trusted_contact_model.dart';
import '../abstract/auth_repository.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/hash_util.dart';

class MockAuthRepository implements AuthRepository {
  final SharedPreferences _prefs;
  final _uuid = const Uuid();

  MockAuthRepository(this._prefs);

  @override
  Future<UserModel?> getCurrentUser() async {
    final rawUser = _prefs.getString('current_user_json');
    if (rawUser == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> sendOtp(String phone) async {
    // Mock simulation: OTP is always 123456
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  @override
  Future<UserModel> verifyOtp(String phone, String otp) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final existingUser = await getCurrentUser();

    if (existingUser != null && existingUser.phone == phone) {
      return existingUser;
    }

    final newUser = UserModel(
      id: _uuid.v4(),
      name: '',
      phone: phone,
      role: 'citizen',
      language: _prefs.getString(AppConstants.keySelectedLanguage) ?? 'en',
      emergencyPinHash: '', // PIN must be explicitly configured
      createdAt: DateTime.now(),
      hasConsented: _prefs.getBool(AppConstants.keyConsentGiven) ?? false,
    );

    await _saveUser(newUser);
    return newUser;
  }

  @override
  Future<UserModel> officerLogin(String code, String pin) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final rawOfficer = _prefs.getString('officer_credentials_$code');
    if (rawOfficer != null) {
      final officer = UserModel.fromJson(jsonDecode(rawOfficer) as Map<String, dynamic>);
      if (HashUtil.verifyPin(pin, officer.emergencyPinHash)) {
        await _saveUser(officer);
        return officer;
      }
    }

    throw Exception('Invalid Officer Code or PIN. Please enter authorized credentials.');
  }

  @override
  Future<void> saveProfile({
    required String name,
    required String pin,
    String? duressPin,
    required List<TrustedContactModel> contacts,
  }) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return;

    final updated = currentUser.copyWith(
      name: name,
      emergencyPinHash: HashUtil.hashPin(pin),
      duressPinHash: (duressPin != null && duressPin.isNotEmpty)
          ? HashUtil.hashPin(duressPin)
          : currentUser.duressPinHash,
    );

    await _saveUser(updated);

    // Save contacts
    final contactsJson = contacts.map((c) => c.toJson()).toList();
    await _prefs.setString('trusted_contacts_json', jsonEncode(contactsJson));
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await _saveUser(user);
  }

  @override
  Future<bool> verifyEmergencyPin(String pin) async {
    final user = await getCurrentUser();
    if (user == null || user.emergencyPinHash.isEmpty) return false;
    return HashUtil.verifyPin(pin, user.emergencyPinHash);
  }

  @override
  Future<void> changeEmergencyPin(String newPin) async {
    final user = await getCurrentUser();
    if (user == null) return;
    final updated = user.copyWith(
      emergencyPinHash: HashUtil.hashPin(newPin),
    );
    await _saveUser(updated);
  }

  @override
  Future<bool> verifyDuressPin(String pin) async {
    final user = await getCurrentUser();
    if (user == null || user.duressPinHash.isEmpty) return false;
    return HashUtil.verifyPin(pin, user.duressPinHash);
  }

  @override
  Future<void> changeDuressPin(String newDuressPin) async {
    final user = await getCurrentUser();
    if (user == null) return;
    final updated = user.copyWith(
      duressPinHash: HashUtil.hashPin(newDuressPin),
    );
    await _saveUser(updated);
  }

  @override
  Future<List<TrustedContactModel>> getTrustedContacts() async {
    final raw = _prefs.getString('trusted_contacts_json');
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => TrustedContactModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addTrustedContact(TrustedContactModel contact) async {
    final current = await getTrustedContacts();
    current.add(contact);
    await _prefs.setString(
      'trusted_contacts_json',
      jsonEncode(current.map((c) => c.toJson()).toList()),
    );
  }

  @override
  Future<void> removeTrustedContact(String contactId) async {
    final current = await getTrustedContacts();
    current.removeWhere((c) => c.id == contactId);
    await _prefs.setString(
      'trusted_contacts_json',
      jsonEncode(current.map((c) => c.toJson()).toList()),
    );
  }

  @override
  Future<void> deleteUserData() async {
    await _prefs.remove('current_user_json');
    await _prefs.remove('trusted_contacts_json');
    await _prefs.remove(AppConstants.keyConsentGiven);
  }

  @override
  Future<void> logout() async {
    await _prefs.remove('current_user_json');
  }

  Future<void> _saveUser(UserModel user) async {
    await _prefs.setString('current_user_json', jsonEncode(user.toJson()));
  }
}
