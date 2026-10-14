import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  bool get isHindi => locale.languageCode == 'hi';

  // Common Strings
  String get appName => isHindi ? 'सुरक्षा ग़ाज़ियाबाद' : 'Suraksha Ghaziabad';
  String get appTagline =>
      isHindi ? 'आपकी सुरक्षा, हमारी ज़िम्मेदारी' : 'Aapki Suraksha, Hamari Zimmedari';
  String get continueText => isHindi ? 'आगे बढ़ें' : 'Continue';
  String get save => isHindi ? 'सुरक्षित करें' : 'Save';
  String get cancel => isHindi ? 'रद्द करें' : 'Cancel';
  String get submit => isHindi ? 'जमा करें' : 'Submit';
  String get done => isHindi ? 'पूर्ण' : 'Done';
  String get search => isHindi ? 'खोजें' : 'Search';
  String get call => isHindi ? 'कॉल करें' : 'Call';
  String get navigate => isHindi ? 'रास्ता देखें' : 'Navigate';
  String get back => isHindi ? 'वापस' : 'Back';
  String get loading => isHindi ? 'लोड हो रहा है...' : 'Loading...';
  String get error => isHindi ? 'त्रुटि' : 'Error';
  String get success => isHindi ? 'सफल' : 'Success';

  // Language Selection
  String get selectLanguage => isHindi ? 'भाषा चुनें' : 'Select Language';
  String get choosePreferredLanguage => isHindi
      ? 'अपनी पसंदीदा भाषा का चयन करें'
      : 'Choose your preferred language for the app';
  String get english => 'English';
  String get hindi => 'हिंदी';

  // Permissions & Consent
  String get safetyPermissions =>
      isHindi ? 'सुरक्षा अनुमतियां और सहमति' : 'Safety Permissions & Consent';
  String get permissionsSubtitle => isHindi
      ? 'आपकी सुरक्षा के लिए हमें कुछ आवश्यक अनुमतियों की आवश्यकता है।'
      : 'We require specific device permissions to protect you in emergencies.';
  String get locationPermissionTitle => isHindi ? 'सटीक स्थान (GPS)' : 'Live GPS Location';
  String get locationPermissionDesc => isHindi
      ? 'स्थान केवल सक्रिय SOS या यात्रा (Trip) के दौरान ही साझा किया जाता है, लगातार कभी नहीं।'
      : 'Location is shared ONLY during an active SOS or live trip, never continuously.';
  String get audioPermissionTitle => isHindi ? 'ऑडियो रिकॉर्डिंग (माइक्रोफ़ोन)' : 'Microphone & Audio';
  String get audioPermissionDesc => isHindi
      ? 'SOS सक्रिय होने पर आपातकालीन साक्ष्य एकत्र करने के लिए सुरक्षित रूप से ध्वनि रिकॉर्ड करता है।'
      : 'Records ambient audio when SOS triggers to gather emergency evidence.';
  String get smsPermissionTitle => isHindi ? 'ऑफ़लाइन SMS बैकअप' : 'SMS Fallback Dispatch';
  String get smsPermissionDesc => isHindi
      ? 'इंटरनेट न होने पर आपातकालीन संपर्कों को निर्देशांक (GPS link) भेजने के लिए।'
      : 'Sends GPS coordinates via SMS to trusted contacts if internet is unavailable.';
  String get notificationPermissionTitle => isHindi ? 'महत्वपूर्ण सूचनाएं' : 'High Priority Alerts';
  String get notificationPermissionDesc => isHindi
      ? 'सुरक्षा अलर्ट और पुलिस सहायता स्थिति प्राप्त करने के लिए।'
      : 'Receive emergency trip check-ins and police response progress updates.';
  String get consentDisclaimer => isHindi
      ? 'मैं पुष्टि करता/करती हूँ कि मैंने गोपनीयता नीति पढ़ ली है और मैं सुरक्षा उद्देश्यों के लिए डेटा साझा करने की सहमति देता/देती हूँ।'
      : 'I confirm that I understand location is only shared during active emergencies, and I give consent for safety purposes.';
  String get acceptAndContinue => isHindi ? 'स्वीकार करें और जारी रखें' : 'Accept & Continue';

  // Authentication
  String get citizenLogin => isHindi ? 'नागरिक लॉगिन' : 'Citizen Login';
  String get loginPrompt => isHindi
      ? 'अपना 10-अंकों का मोबाइल नंबर दर्ज करें'
      : 'Enter your 10-digit mobile number';
  String get sendOtp => isHindi ? 'OTP भेजें' : 'Send OTP';
  String get enterOtp => isHindi ? 'OTP दर्ज करें' : 'Enter 6-digit OTP';
  String get otpSentTo => isHindi ? 'OTP भेजा गया:' : 'OTP sent to:';
  String get verifyAndLogin => isHindi ? 'सत्यापित करें और लॉगिन करें' : 'Verify & Login';
  String get mockOtpHint => isHindi ? 'डेमो OTP: 123456' : 'Demo Mode OTP: 123456';
  String get officerLoginLink => isHindi ? 'पुलिस / अधिकारी लॉगिन' : 'Police Officer Login';
  String get officerPortal => isHindi ? 'पुलिस नियंत्रण कक्ष' : 'Police Officer Portal';
  String get officerCode => isHindi ? 'अधिकारी कोड (उदा. OFFICER01)' : 'Officer Code (e.g. OFFICER01)';
  String get officerPin => isHindi ? 'अधिकारी पिन (उदा. 1234)' : 'Officer PIN (e.g. 1234)';
  String get loginAsOfficer => isHindi ? 'अधिकारी के रूप में लॉगिन करें' : 'Login as Officer';

  // Profile Setup
  String get completeProfile => isHindi ? 'प्रोफ़ाइल सेटअप' : 'Profile Setup';
  String get yourName => isHindi ? 'आपका नाम' : 'Your Full Name';
  String get emergencyPin => isHindi ? 'आपातकालीन पिन (4 अंक)' : 'Emergency PIN (4 digits)';
  String get emergencyPinDesc => isHindi
      ? 'गलत अलार्म रद्द करने के लिए 4 अंकों का गुप्त पिन चुनें।'
      : 'Create a 4-digit PIN required to cancel an active SOS alert.';
  String get trustedContacts => isHindi ? 'विश्वसनीय संपर्क (1 से 5)' : 'Trusted Emergency Contacts (1 to 5)';
  String get addContact => isHindi ? 'संपर्क जोड़ें' : 'Add Contact';
  String get contactName => isHindi ? 'संपर्क का नाम' : 'Contact Name';
  String get contactPhone => isHindi ? 'मोबाइल नंबर' : 'Phone Number';

  // Bottom Navigation (Citizen)
  String get navHome => isHindi ? 'होम' : 'Home';
  String get navMap => isHindi ? 'नक्शा' : 'Safety Map';
  String get navReport => isHindi ? 'रिपोर्ट' : 'Report Spot';
  String get navTrips => isHindi ? 'यात्रा' : 'Trip Safe';
  String get navProfile => isHindi ? 'प्रोफ़ाइल' : 'Profile';

  // Citizen Home Screen
  String get safeStatus => isHindi ? 'आप सुरक्षित हैं' : 'You are Protected';
  String get sosActiveStatus => isHindi ? 'आपातकालीन SOS सक्रिय है!' : 'EMERGENCY SOS ACTIVE!';
  String get tapOrHoldSos => isHindi
      ? 'SOS भेजने के लिए 2 सेकंड दबाएं या टैप करें'
      : 'Hold for 2 seconds or tap for emergency alert';
  String get quickActions => isHindi ? 'त्वरित सुरक्षा सुविधाएं' : 'Quick Safety Tools';
  String get shareTrip => isHindi ? 'सुरक्षित यात्रा' : 'Share Trip';
  String get shareTripDesc => isHindi ? 'लाइव लोकेशन और ऑटो-चेक' : 'Live tracking & auto-checks';
  String get nearbyHelp => isHindi ? 'निकटतम सहायता' : 'Nearby Help';
  String get nearbyHelpDesc => isHindi ? 'थाना, महिला हेल्प डेस्क, अस्पताल' : 'Police stations, Pink booths, Hospitals';
  String get reportUnsafe => isHindi ? 'असुरक्षित स्थान' : 'Report Unsafe Spot';
  String get reportUnsafeDesc => isHindi ? 'अंधेरी सड़कें, छेड़छाड़ हॉटस्पॉट' : 'Dark roads, harassment points';
  String get fakeCall => isHindi ? 'फ़ेक कॉल' : 'Fake Call';
  String get fakeCallDesc => isHindi ? 'असुरक्षित स्थिति से निकलने के लिए' : 'Exit unsafe situations safely';

  // SOS Active Screen
  String get sosAlertInitiated => isHindi ? 'SOS आपातकालीन अलर्ट भेजा जा रहा है' : 'SOS Emergency Alert Triggered';
  String get cancelCountdown => isHindi ? 'रद्द करने के लिए सेकंड:' : 'Seconds left to cancel:';
  String get cancelAlertButton => isHindi ? 'अलर्ट रद्द करें (पिन आवश्यक)' : 'Cancel Alert (PIN Required)';
  String get enterPinToCancel => isHindi ? 'अलर्ट रद्द करने के लिए अपना आपातकालीन पिन दर्ज करें' : 'Enter Emergency PIN to cancel SOS';
  String get locationSharingLive => isHindi ? 'लाइव GPS स्थान साझा हो रहा है' : 'Live GPS location is being streamed';
  String get recordingActive => isHindi ? 'आस-पास का ऑडियो रिकॉर्ड हो रहा है' : 'Ambient audio recording active';
  String get statusAlertSent => isHindi ? 'अलर्ट भेजा गया' : 'Alert Sent';
  String get statusPoliceNotified => isHindi ? 'पुलिस नियंत्रण कक्ष को सूचित किया गया' : 'Police Control Room Notified';
  String get statusHelpAssigned => isHindi ? 'गश्ती दल (Patrol Unit) रवाना' : 'Patrol Unit Dispatched';
  String get statusResolved => isHindi ? 'स्थिति नियंत्रित / समाधान पूर्ण' : 'Situation Resolved';
  String get simulateOfficerResponse => isHindi ? 'अधिकारी प्रतिक्रिया अनुकरण (Demo)' : 'Simulate Police Response (Demo)';

  // Safety Map Screen
  String get safetyHeatmapTitle => isHindi ? 'ग़ाज़ियाबाद सुरक्षा नक्शा' : 'Ghaziabad Safety Heatmap';
  String get filterReports => isHindi ? 'फ़िल्टर करें' : 'Filter Spots';
  String get allCategories => isHindi ? 'सभी श्रेणियां' : 'All Categories';
  String get brokenStreetlight => isHindi ? 'टूटी स्ट्रीटलाइट' : 'Broken streetlight';
  String get isolatedRoad => isHindi ? 'सुनसान सड़क' : 'Isolated road';
  String get harassment => isHindi ? 'छेड़छाड़ / उत्पीड़न' : 'Harassment';
  String get drunkCrowd => isHindi ? 'शराबी / असामाजिक तत्व' : 'Drunk crowd';
  String get otherCategory => isHindi ? 'अन्य समस्या' : 'Other';
  String get statusOpen => isHindi ? 'खुला (लंबित)' : 'Open';
  String get statusInProgress => isHindi ? 'कार्य प्रगति पर' : 'In progress';
  String get statusFixed => isHindi ? 'समाधान पूर्ण (ठीक किया गया)' : 'Fixed';
  String get highRiskZone => isHindi ? 'उच्च जोखिम क्षेत्र' : 'High Risk Area';
  String get moderateRiskZone => isHindi ? 'मध्यम जोखिम' : 'Moderate Risk';

  // Report Unsafe Spot Screen
  String get reportTitle => isHindi ? 'असुरक्षित स्थान की रिपोर्ट करें' : 'Report Unsafe Location';
  String get selectCategory => isHindi ? 'समस्या की श्रेणी' : 'Incident Category';
  String get pickOnMap => isHindi ? 'नक्शे पर स्थान चुनें' : 'Pinpoint on Map';
  String get descriptionLabel => isHindi ? 'विस्तार से विवरण दें' : 'Detailed Description';
  String get descriptionHint => isHindi
      ? 'उदा. 500 मीटर तक लाइट बंद है, शाम को असामाजिक तत्व जमा होते हैं...'
      : 'e.g. Streetlights not working for 2 weeks, dark patch near metro gate...';
  String get anonymousToggle => isHindi ? 'गुमनाम रूप से सबमिट करें' : 'Submit Anonymously';
  String get anonymousNote => isHindi
      ? 'आपका नाम या नंबर इस रिपोर्ट के साथ कभी सहेजा नहीं जाएगा।'
      : 'Your personal name and identity will not be linked to this report.';
  String get addPhoto => isHindi ? 'फोटो जोड़ें (वैकल्पिक)' : 'Attach Photo (Optional)';
  String get myReportsTitle => isHindi ? 'मेरी रिपोर्टें' : 'My Reported Spots';

  // Trip Sharing Screen
  String get tripSharingTitle => isHindi ? 'सुरक्षित यात्रा साझाकरण' : 'Live Safe Trip Sharing';
  String get enterDestination => isHindi ? 'गंतव्य दर्ज करें (उदा. वैशाली मेट्रो)' : 'Enter Destination (e.g. Vaishali Metro)';
  String get startTrip => isHindi ? 'यात्रा शुरू करें' : 'Start Protected Trip';
  String get tripInProgress => isHindi ? 'यात्रा प्रगति पर है' : 'Trip in Progress';
  String get endTrip => isHindi ? 'यात्रा समाप्त करें' : 'End Trip (I Reached Safely)';
  String get areYouOkTitle => isHindi ? 'क्या आप सुरक्षित हैं?' : 'Safety Check: Are you OK?';
  String get areYouOkDesc => isHindi
      ? 'गाड़ी अधिक समय से रुकी है। कृपया पुष्टि करें कि आप सुरक्षित हैं। 60 सेकंड में जवाब न मिलने पर संपर्कों को अलर्ट भेजा जाएगा।'
      : 'Vehicle is stationary or off route. Please confirm you are safe. If no response in 60s, emergency contacts will be alerted.';
  String get iAmOk => isHindi ? 'मैं सुरक्षित हूँ' : 'I am Safe';
  String get needHelp => isHindi ? 'मुझे मदद चाहिए (SOS)' : 'Need Help (Send SOS)';

  // Fake Call
  String get fakeCallTitle => isHindi ? 'फ़ेक इनकमिंग कॉल' : 'Fake Incoming Call';
  String get fakeCallSubtitle => isHindi
      ? 'असहज स्थिति से सम्मानपूर्वक निकलने के लिए कॉल शेड्यूल करें।'
      : 'Schedule a realistic call to politely excuse yourself from unsafe situations.';
  String get callerName => isHindi ? 'कॉलर का नाम' : 'Caller Name';
  String get defaultCaller => isHindi ? 'पापा (Papa)' : 'Papa';
  String get delaySeconds => isHindi ? 'कितने सेकंड बाद कॉल आए?' : 'Trigger Call In';
  String get callNow => isHindi ? 'अभी कॉल शुरू करें' : 'Call in 5 Seconds';
  String get callIn15 => isHindi ? '15 सेकंड' : '15 Seconds';
  String get callIn30 => isHindi ? '30 सेकंड' : '30 Seconds';

  // Profile & Settings
  String get profileAndSettings => isHindi ? 'प्रोफ़ाइल एवं सेटिंग्स' : 'Profile & Settings';
  String get changeEmergencyPin => isHindi ? 'आपातकालीन पिन बदलें' : 'Change Emergency PIN';
  String get editTrustedContacts => isHindi ? 'विश्वसनीय संपर्क बदलें' : 'Manage Trusted Contacts';
  String get shakeTriggerTitle => isHindi ? 'फोन हिलाकर SOS (Shake Trigger)' : 'Shake Phone for SOS';
  String get shakeTriggerDesc => isHindi
      ? 'फोन को 3 बार तेज़ी से हिलाने पर स्वतः SOS सक्रिय हो जाता है।'
      : 'Shake phone 3 times in danger to instantly trigger SOS.';
  String get demoModeTitle => isHindi ? 'डेमो मोड (Demo Mode)' : 'Demo Mode';
  String get demoModeDesc => isHindi
      ? 'वास्तविक SMS या 112 अलर्ट भेजे बिना सभी सुविधाओं का परीक्षण करें।'
      : 'Safely test and demonstrate all features without sending real SMS or alerts.';
  String get privacyPolicy => isHindi ? 'गोपनीयता नीति' : 'Privacy Policy';
  String get aboutApp => isHindi ? 'ऐप के बारे में' : 'About App';
  String get deleteMyData => isHindi ? 'मेरा डेटा हटाएं' : 'Delete My Data';
  String get logout => isHindi ? 'लॉगआउट' : 'Logout';

  // Officer Mode
  String get officerFeedTitle => isHindi ? 'लाइव SOS फ़ीड' : 'Live SOS Feed';
  String get officerHeatmapTitle => isHindi ? 'प्रशासनिक हीटमैप' : 'District Heatmap';
  String get officerReportsTitle => isHindi ? 'नागरिक रिपोर्ट समीक्षा' : 'Citizen Reports Admin';
  String get officerAnalyticsTitle => isHindi ? 'सुरक्षा एनालिटिक्स' : 'Safety Analytics';
  String get patrolUnitsTitle => isHindi ? 'गश्ती दल (Patrol Units)' : 'Patrol Units';
  String get assignNearestUnit => isHindi ? 'निकटतम गश्ती दल भेजें' : 'Assign Nearest Patrol Unit';
  String get markResolved => isHindi ? 'समाधान पूर्ण मार्क करें' : 'Mark as Resolved';
  String get callCitizen => isHindi ? 'नागरिक को कॉल करें' : 'Call Citizen';
  String get audioEvidence => isHindi ? 'ऑडियो साक्ष्य' : 'Audio Evidence';
  String get topUnsafeZones => isHindi ? 'शीर्ष 10 असुरक्षित क्षेत्र' : 'Top 10 High-Risk Zones';
  String get reportsByCategory => isHindi ? 'श्रेणी अनुसार रिपोर्ट' : 'Reports by Category';
  String get reportsByTime => isHindi ? 'समय अनुसार रिपोर्ट' : 'Reports by Time of Day';
  String get avgResponseTime => isHindi ? 'औसत प्रतिक्रिया समय' : 'Avg SOS-to-Dispatch Time';
  String get minutes => isHindi ? 'मिनट' : 'minutes';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
