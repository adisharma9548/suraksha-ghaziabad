import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';
import '../../models/trusted_contact_model.dart';
import '../abstract/auth_repository.dart';
import '../../../core/utils/hash_util.dart';
import '../../../core/services/sms_service.dart';

/// Firebase implementation of AuthRepository
/// Connects to FirebaseAuth (Phone OTP) and Cloud Firestore ('users' & 'trusted_contacts')
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth? auth;
  final FirebaseFirestore? firestore;
  UserModel? _cachedUser;
  final List<TrustedContactModel> _cachedContacts = [];
  String? _verificationId;
  String? _pendingPhone;
  String? _pendingOtp;
  DateTime? _otpExpiresAt;

  FirebaseAuthRepository({
    this.auth,
    this.firestore,
    UserModel? initialUser,
  }) : _cachedUser = initialUser;

  bool get _isFirebaseAvailable => Firebase.apps.isNotEmpty;
  FirebaseAuth get _effectiveAuth => auth ?? FirebaseAuth.instance;
  FirebaseFirestore get _effectiveFirestore =>
      firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel?> getCurrentUser() async {
    if (!_isFirebaseAvailable) {
      return _cachedUser;
    }

    try {
      final firebaseUser = _effectiveAuth.currentUser;
      if (firebaseUser == null) {
        return _cachedUser;
      }

      final doc = await _effectiveFirestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        _cachedUser = UserModel.fromJson(doc.data()!);
        return _cachedUser;
      }

      return _cachedUser;
    } catch (e) {
      debugPrint('FirebaseAuthRepository.getCurrentUser error: $e');
      return _cachedUser;
    }
  }

  @override
  Future<bool> sendOtp(String phone) async {
    final cleanPhone = SmsHorizonService.sanitizePhoneNumber(phone);

    // Generate secure 6-digit random OTP
    final random = math.Random.secure();
    final otp = (100000 + random.nextInt(900000)).toString();

    _pendingPhone = cleanPhone;
    _pendingOtp = otp;
    _otpExpiresAt = DateTime.now().add(const Duration(minutes: 5));

    debugPrint(
        '[FirebaseAuthRepository] Sending OTP $otp via SMS Horizon to $cleanPhone');
    final sent = await SmsHorizonService.instance.sendOtpSms(
      phone: cleanPhone,
      otp: otp,
    );

    if (sent) {
      return true;
    }

    // Fallback: If SMS Horizon gateway had a network issue, try Firebase Phone Auth if available
    if (_isFirebaseAvailable) {
      final completer = Completer<bool>();
      try {
        await _effectiveAuth.verifyPhoneNumber(
          phoneNumber: phone.startsWith('+') ? phone : '+91$cleanPhone',
          verificationCompleted: (PhoneAuthCredential credential) async {
            await _effectiveAuth.signInWithCredential(credential);
            if (!completer.isCompleted) completer.complete(true);
          },
          verificationFailed: (FirebaseAuthException e) {
            debugPrint(
                'FirebaseAuthRepository.verifyPhoneNumber failed: ${e.message}');
            if (!completer.isCompleted) completer.complete(false);
          },
          codeSent: (String verificationId, int? resendToken) {
            _verificationId = verificationId;
            if (!completer.isCompleted) completer.complete(true);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            _verificationId = verificationId;
          },
          timeout: const Duration(seconds: 60),
        );
        return await completer.future;
      } catch (e) {
        debugPrint('FirebaseAuthRepository.sendOtp fallback error: $e');
        return false;
      }
    }

    return false;
  }

  @override
  Future<UserModel> verifyOtp(String phone, String otp) async {
    final cleanPhone = SmsHorizonService.sanitizePhoneNumber(phone);

    // 1. Verify against SMS Horizon OTP
    if (_pendingPhone == cleanPhone && _pendingOtp != null) {
      if (_otpExpiresAt != null && DateTime.now().isAfter(_otpExpiresAt!)) {
        throw Exception(
            'Verification code expired. Please request a new OTP.');
      }

      if (_pendingOtp == otp) {
        _pendingOtp = null;
        _otpExpiresAt = null;

        String uid = 'usr_$cleanPhone';
        if (_isFirebaseAvailable) {
          try {
            if (_effectiveAuth.currentUser == null) {
              final anon = await _effectiveAuth.signInAnonymously();
              uid = anon.user?.uid ?? uid;
            } else {
              uid = _effectiveAuth.currentUser!.uid;
            }
          } catch (e) {
            debugPrint('Firebase Auth anonymous binding notice: $e');
          }

          final userDocRef = _effectiveFirestore.collection('users').doc(uid);
          final userDoc = await userDocRef.get();

          if (userDoc.exists && userDoc.data() != null) {
            _cachedUser = UserModel.fromJson(userDoc.data()!);
            return _cachedUser!;
          }

          final newUser = UserModel(
            id: uid,
            name: '',
            phone: '+91$cleanPhone',
            role: 'citizen',
            language: 'en',
            emergencyPinHash: '',
            createdAt: DateTime.now(),
            hasConsented: true,
          );
          await userDocRef.set(newUser.toJson());
          _cachedUser = newUser;
          return newUser;
        }

        // Offline / sandbox user creation
        final newUser = UserModel(
          id: uid,
          name: '',
          phone: '+91$cleanPhone',
          role: 'citizen',
          language: 'en',
          emergencyPinHash: '',
          createdAt: DateTime.now(),
          hasConsented: true,
        );
        _cachedUser = newUser;
        return newUser;
      }
    }

    // 2. Fallback to Firebase PhoneAuthProvider if verificationId was issued
    if (_verificationId != null && _isFirebaseAvailable) {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      final userCredential =
          await _effectiveAuth.signInWithCredential(credential);
      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw Exception('Firebase authentication returned no user UID');
      }

      final userDocRef = _effectiveFirestore.collection('users').doc(uid);
      final userDoc = await userDocRef.get();

      if (userDoc.exists && userDoc.data() != null) {
        _cachedUser = UserModel.fromJson(userDoc.data()!);
        return _cachedUser!;
      }

      final newUser = UserModel(
        id: uid,
        name: '',
        phone: phone,
        role: 'citizen',
        language: 'en',
        emergencyPinHash: '',
        createdAt: DateTime.now(),
        hasConsented: true,
      );

      await userDocRef.set(newUser.toJson());
      _cachedUser = newUser;
      return newUser;
    }

    throw Exception(
        'Invalid OTP. Please check the SMS sent to your phone and try again.');
  }

  @override
  Future<UserModel> officerLogin(String code, String pin) async {
    if (!_isFirebaseAvailable) {
      // In offline/test mode without Firebase, query must be explicitly mocked
      if (_cachedUser != null &&
          _cachedUser!.role == 'officer' &&
          HashUtil.verifyPin(pin, _cachedUser!.emergencyPinHash)) {
        return _cachedUser!;
      }
      throw Exception('Invalid Officer credentials. Official administrative registration required.');
    }

    // Query Firestore for officer credential
    final query = await _effectiveFirestore
        .collection('users')
        .where('role', isEqualTo: 'officer')
        .where('officerCode', isEqualTo: code.trim().toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('No officer found with code $code');
    }

    final data = query.docs.first.data();
    final storedHash = data['emergencyPinHash'] as String? ?? '';
    if (!HashUtil.verifyPin(pin, storedHash)) {
      throw Exception('Invalid officer authentication PIN');
    }

    _cachedUser = UserModel.fromJson(data);

    if (_isFirebaseAvailable) {
      try {
        await FirebaseMessaging.instance.subscribeToTopic('officers_ghaziabad');
      } catch (fcmErr) {
        debugPrint('FCM topic subscription notice: $fcmErr');
      }
    }

    return _cachedUser!;
  }

  @override
  Future<void> saveProfile({
    required String name,
    required String pin,
    String? duressPin,
    required List<TrustedContactModel> contacts,
  }) async {
    final user = await getCurrentUser();
    if (user != null) {
      final updated = user.copyWith(
        name: name,
        emergencyPinHash: HashUtil.hashPin(pin),
        duressPinHash: (duressPin != null && duressPin.isNotEmpty)
            ? HashUtil.hashPin(duressPin)
            : user.duressPinHash,
      );
      _cachedUser = updated;

      if (_isFirebaseAvailable) {
        await _effectiveFirestore
            .collection('users')
            .doc(user.id)
            .set(updated.toJson(), SetOptions(merge: true));

        // Save contacts to subcollection
        final contactsBatch = _effectiveFirestore.batch();
        final contactsCol = _effectiveFirestore
            .collection('users')
            .doc(user.id)
            .collection('trusted_contacts');

        for (final contact in contacts) {
          contactsBatch.set(contactsCol.doc(contact.id), contact.toJson());
        }
        await contactsBatch.commit();
      }
    }

    _cachedContacts.clear();
    _cachedContacts.addAll(contacts);
  }

  @override
  Future<void> updateUser(UserModel user) async {
    _cachedUser = user;
    if (_isFirebaseAvailable) {
      await _effectiveFirestore
          .collection('users')
          .doc(user.id)
          .set(user.toJson(), SetOptions(merge: true));
    }
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
    final updated = user.copyWith(
      emergencyPinHash: HashUtil.hashPin(newPin),
    );
    _cachedUser = updated;

    if (_isFirebaseAvailable) {
      await _effectiveFirestore.collection('users').doc(user.id).update({
        'emergencyPinHash': HashUtil.hashPin(newPin),
      });
    }
  }

  @override
  Future<bool> verifyDuressPin(String pin) async {
    final user = await getCurrentUser();
    if (user == null || user.duressPinHash.isEmpty) {
      return false;
    }
    return HashUtil.verifyPin(pin, user.duressPinHash);
  }

  @override
  Future<void> changeDuressPin(String newDuressPin) async {
    final user = await getCurrentUser();
    if (user == null) return;
    final updated = user.copyWith(
      duressPinHash: HashUtil.hashPin(newDuressPin),
    );
    _cachedUser = updated;

    if (_isFirebaseAvailable) {
      await _effectiveFirestore.collection('users').doc(user.id).update({
        'duressPinHash': HashUtil.hashPin(newDuressPin),
      });
    }
  }

  @override
  Future<List<TrustedContactModel>> getTrustedContacts() async {
    if (!_isFirebaseAvailable) {
      return List.unmodifiable(_cachedContacts);
    }

    try {
      final user = await getCurrentUser();
      if (user == null) return List.unmodifiable(_cachedContacts);

      final snapshot = await _effectiveFirestore
          .collection('users')
          .doc(user.id)
          .collection('trusted_contacts')
          .get();

      final list = snapshot.docs
          .map((doc) => TrustedContactModel.fromJson(doc.data()))
          .toList();

      _cachedContacts.clear();
      _cachedContacts.addAll(list);
      return List.unmodifiable(_cachedContacts);
    } catch (e) {
      debugPrint('FirebaseAuthRepository.getTrustedContacts error: $e');
      return List.unmodifiable(_cachedContacts);
    }
  }

  @override
  Future<void> addTrustedContact(TrustedContactModel contact) async {
    _cachedContacts.add(contact);

    if (_isFirebaseAvailable) {
      final user = await getCurrentUser();
      if (user != null) {
        await _effectiveFirestore
            .collection('users')
            .doc(user.id)
            .collection('trusted_contacts')
            .doc(contact.id)
            .set(contact.toJson());
      }
    }
  }

  @override
  Future<void> removeTrustedContact(String contactId) async {
    _cachedContacts.removeWhere((c) => c.id == contactId);

    if (_isFirebaseAvailable) {
      final user = await getCurrentUser();
      if (user != null) {
        await _effectiveFirestore
            .collection('users')
            .doc(user.id)
            .collection('trusted_contacts')
            .doc(contactId)
            .delete();
      }
    }
  }

  @override
  Future<void> deleteUserData() async {
    if (_isFirebaseAvailable) {
      final user = _effectiveAuth.currentUser;
      if (user != null) {
        await _effectiveFirestore.collection('users').doc(user.uid).delete();
        await user.delete();
      }
    }
    _cachedUser = null;
    _cachedContacts.clear();
  }

  @override
  Future<void> logout() async {
    if (_isFirebaseAvailable) {
      try {
        await FirebaseMessaging.instance.unsubscribeFromTopic('officers_ghaziabad');
      } catch (_) {}
      await _effectiveAuth.signOut();
    }
    _cachedUser = null;
    _cachedContacts.clear();
  }
}
