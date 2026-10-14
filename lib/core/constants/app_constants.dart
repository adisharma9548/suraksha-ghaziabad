class AppConstants {
  AppConstants._();

  static const String appName = 'Suraksha Ghaziabad';
  static const String appTagline = 'Aapki Suraksha, Hamari Zimmedari';
  static const String eventName = 'Ghaziabad Seva First Innovation Challenge 2026';
  static const String eventCategory = 'Safe City for Women';

  // Ghaziabad Geographic Coordinates
  static const double ghaziabadCenterLat = 28.6692;
  static const double ghaziabadCenterLng = 77.4538;
  static const double defaultMapZoom = 13.0;

  // Emergency Hotlines
  static const String emergencyNumberPolice = '112';
  static const String womenHelplineUP = '1090';
  static const String womenNationalHelpline = '181';
  static const String ambulanceNumber = '108';

  // Disclaimer & Police Integration Notice
  static const String policeIntegrationNotice =
      'Suraksha Ghaziabad is an independent citizen safety companion designed to complement UP Dial 112 by launching emergency calls, alerting trusted contacts, and assisting local response. Direct ERSS backend integration requires an official police agreement.';

  // Local Storage Keys
  static const String keyUserRole = 'user_role';
  static const String keyUserPhone = 'user_phone';
  static const String keyUserName = 'user_name';
  static const String keyPinHash = 'emergency_pin_hash';
  static const String keySelectedLanguage = 'selected_language';
  static const String keyConsentGiven = 'consent_given';
  static const String keyShakeDetection = 'shake_detection_enabled';
  static const String keyDarkMode = 'dark_mode_enabled';
}
