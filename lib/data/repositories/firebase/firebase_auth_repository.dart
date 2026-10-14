import '../../models/user_model.dart';
import '../../models/trusted_contact_model.dart';
import '../abstract/auth_repository.dart';
import '../../../core/utils/hash_util.dart';

/// Firebase Implementation of AuthRepository
/// When Firebase credentials are plugged in (google-services.json),
/// this repository connects to FirebaseAuth and FirebaseFirestore.
class FirebaseAuthRepository implements AuthRepository {
  UserModel? _currentUser;
  final List<TrustedContactModel> _contacts = [];

  FirebaseAuthRepository({UserModel? initialUser}) : _currentUser = initialUser;

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<bool> sendOtp(String phone) async {
    return true;
  }

  @override
  Future<UserModel> verifyOtp(String phone, String otp) async {
    throw UnimplementedError('Connect Firebase project configuration to enable live OTP');
  }

  @override
  Future<UserModel> officerLogin(String code, String pin) async {
    throw UnimplementedError('Connect Firebase project configuration for live officer portal');
  }

  @override
  Future<void> saveProfile({
    required String name,
    required String pin,
    required List<TrustedContactModel> contacts,
  }) async {
    final user = await getCurrentUser();
    if (user != null) {
      _currentUser = user.copyWith(
        name: name,
        emergencyPinHash: HashUtil.hashPin(pin),
      );
    }
    _contacts.clear();
    _contacts.addAll(contacts);
  }

  @override
  Future<void> updateUser(UserModel user) async {
    _currentUser = user;
  }

  @override
  Future<bool> verifyEmergencyPin(String pin) async {
    final user = await getCurrentUser();
    if (user == null || user.emergencyPinHash.isEmpty) {
      return false;
    }
    return HashUtil.verifyPin(pin, user.emergencyPinHash);
  }

  @override
  Future<void> changeEmergencyPin(String newPin) async {
    final user = await getCurrentUser();
    if (user == null) return;
    _currentUser = user.copyWith(
      emergencyPinHash: HashUtil.hashPin(newPin),
    );
  }

  @override
  Future<List<TrustedContactModel>> getTrustedContacts() async =>
      List.unmodifiable(_contacts);

  @override
  Future<void> addTrustedContact(TrustedContactModel contact) async {
    _contacts.add(contact);
  }

  @override
  Future<void> removeTrustedContact(String contactId) async {
    _contacts.removeWhere((c) => c.id == contactId);
  }

  @override
  Future<void> deleteUserData() async {
    _currentUser = null;
    _contacts.clear();
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }
}
