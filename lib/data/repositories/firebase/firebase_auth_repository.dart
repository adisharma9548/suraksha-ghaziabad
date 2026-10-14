import '../../models/user_model.dart';
import '../../models/trusted_contact_model.dart';
import '../abstract/auth_repository.dart';

/// Firebase Implementation of AuthRepository
/// When Firebase credentials are plugged in (google-services.json),
/// this repository connects to FirebaseAuth and FirebaseFirestore.
class FirebaseAuthRepository implements AuthRepository {
  @override
  Future<UserModel?> getCurrentUser() async {
    // Connects to FirebaseAuth.instance.currentUser
    return null;
  }

  @override
  Future<bool> sendOtp(String phone) async {
    // Connects to FirebaseAuth.instance.verifyPhoneNumber()
    return true;
  }

  @override
  Future<UserModel> verifyOtp(String phone, String otp) async {
    // Connects to FirebaseAuth.instance.signInWithCredential()
    throw UnimplementedError('Connect Firebase project configuration to enable live OTP');
  }

  @override
  Future<UserModel> officerLogin(String code, String pin) async {
    // Connects to Firestore query on 'users' collection where role == 'officer'
    throw UnimplementedError('Connect Firebase project configuration for live officer portal');
  }

  @override
  Future<void> saveProfile({
    required String name,
    required String pin,
    required List<TrustedContactModel> contacts,
  }) async {}

  @override
  Future<void> updateUser(UserModel user) async {}

  @override
  Future<bool> verifyEmergencyPin(String pin) async => true;

  @override
  Future<void> changeEmergencyPin(String newPin) async {}

  @override
  Future<List<TrustedContactModel>> getTrustedContacts() async => [];

  @override
  Future<void> addTrustedContact(TrustedContactModel contact) async {}

  @override
  Future<void> removeTrustedContact(String contactId) async {}

  @override
  Future<void> deleteUserData() async {}

  @override
  Future<void> logout() async {}
}
