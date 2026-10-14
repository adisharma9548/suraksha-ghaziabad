import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashUtil {
  HashUtil._();

  /// Hashes an emergency PIN with a salt using SHA-256
  static String hashPin(String pin) {
    const salt = 'suraksha_ghaziabad_secure_salt_2026';
    final bytes = utf8.encode('$pin:$salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifies a plain PIN against a stored SHA-256 hash
  static bool verifyPin(String pin, String storedHash) {
    return hashPin(pin) == storedHash;
  }
}
