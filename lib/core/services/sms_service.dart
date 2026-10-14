import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// SMS Horizon Integration Service for Real DLT-Approved OTP Verification
class SmsHorizonService {
  SmsHorizonService._();
  static final SmsHorizonService instance = SmsHorizonService._();

  static const String _apiUrl = 'https://smshorizon.com/api/v2/sendsms';
  static const String _bearerToken = 'jS1cmecLDAp1qcNxbknqrwyNzMZZm7';
  static const String _username = 'adisharma';
  static const String _senderId = 'HORIZN';
  static const String _templateId = '1607100000000323238';

  /// Sanitizes Indian phone numbers down to the 10-digit mobile number
  static String sanitizePhoneNumber(String phone) {
    String clean = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (clean.startsWith('91') && clean.length > 10) {
      clean = clean.substring(clean.length - 10);
    }
    return clean;
  }

  /// Sends a DLT-approved 6-digit OTP SMS via SMS Horizon Gateway
  Future<bool> sendOtpSms({
    required String phone,
    required String otp,
  }) async {
    final mobile = sanitizePhoneNumber(phone);
    if (mobile.length != 10) {
      debugPrint('[SmsHorizonService] Invalid phone number format: $phone');
      return false;
    }

    // DLT Template 1607100000000323238 exact text format
    final message = 'OTP for your new user account registration is: $otp\n\n- SmsHorizon';

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_bearerToken',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'user': _username,
          'number': mobile,
          'senderid': _senderId,
          'message': message,
          'type': 'txt',
          'tid': _templateId,
          'prettyprint': '1',
        },
      );

      debugPrint('[SmsHorizonService] Response code: ${response.statusCode}');
      debugPrint('[SmsHorizonService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final bodyJson = jsonDecode(response.body);
        if (bodyJson is Map && bodyJson.containsKey('msgid')) {
          debugPrint('[SmsHorizonService] OTP SMS successfully dispatched. MsgId: ${bodyJson['msgid']}');
          return true;
        } else if (bodyJson is Map && bodyJson.containsKey('error')) {
          debugPrint('[SmsHorizonService] Gateway error: ${bodyJson['error']}');
          return false;
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('[SmsHorizonService] Network error sending OTP: $e');
      return false;
    }
  }
}
