import '../../models/user_model.dart';
import '../../models/trusted_contact_model.dart';

abstract class AuthRepository {
  Future<UserModel?> getCurrentUser();
  Future<bool> sendOtp(String phone);
  Future<UserModel> verifyOtp(String phone, String otp);
  Future<UserModel> officerLogin(String code, String pin);
  Future<void> saveProfile({
    required String name,
    required String pin,
    required List<TrustedContactModel> contacts,
  });
  Future<void> updateUser(UserModel user);
  Future<bool> verifyEmergencyPin(String pin);
  Future<void> changeEmergencyPin(String newPin);
  Future<List<TrustedContactModel>> getTrustedContacts();
  Future<void> addTrustedContact(TrustedContactModel contact);
  Future<void> removeTrustedContact(String contactId);
  Future<void> deleteUserData();
  Future<void> logout();
}
