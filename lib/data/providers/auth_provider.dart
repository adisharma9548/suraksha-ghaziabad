import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/trusted_contact_model.dart';
import 'repository_providers.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;
  final String? pendingPhone;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.pendingPhone,
  });

  bool get isAuthenticated => user != null;
  bool get isOfficer => user?.isOfficer ?? false;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    String? pendingPhone,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      pendingPhone: pendingPhone ?? this.pendingPhone,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState()) {
    checkCurrentUser();
  }

  Future<void> checkCurrentUser() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _ref.read(authRepositoryProvider).getCurrentUser();
      state = AuthState(user: user, isLoading: false);
    } catch (e) {
      state = AuthState(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<bool> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, errorMessage: null, pendingPhone: phone);
    try {
      final success = await _ref.read(authRepositoryProvider).sendOtp(phone);
      state = state.copyWith(isLoading: false);
      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    final phone = state.pendingPhone ?? '9876543210';
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _ref.read(authRepositoryProvider).verifyOtp(phone, otp);
      state = AuthState(user: user, isLoading: false);
      _ref.invalidate(trustedContactsProvider);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> officerLogin(String code, String pin) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final officer = await _ref.read(authRepositoryProvider).officerLogin(code, pin);
      state = AuthState(user: officer, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> saveProfile({
    required String name,
    required String pin,
    String? duressPin,
    required List<TrustedContactModel> contacts,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _ref.read(authRepositoryProvider).saveProfile(
            name: name,
            pin: pin,
            duressPin: duressPin,
            contacts: contacts,
          );
      final updatedUser = await _ref.read(authRepositoryProvider).getCurrentUser();
      state = AuthState(user: updatedUser, isLoading: false);
      _ref.invalidate(trustedContactsProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> changeDuressPin(String newDuressPin) async {
    await _ref.read(authRepositoryProvider).changeDuressPin(newDuressPin);
    final updatedUser = await _ref.read(authRepositoryProvider).getCurrentUser();
    state = state.copyWith(user: updatedUser);
  }

  Future<void> deleteMyData() async {
    await _ref.read(authRepositoryProvider).deleteUserData();
    state = const AuthState();
    _ref.invalidate(trustedContactsProvider);
  }

  Future<void> logout() async {
    await _ref.read(authRepositoryProvider).logout();
    state = const AuthState();
    _ref.invalidate(trustedContactsProvider);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

final trustedContactsProvider =
    FutureProvider<List<TrustedContactModel>>((ref) async {
  return ref.watch(authRepositoryProvider).getTrustedContacts();
});
