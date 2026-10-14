class AppConfig {
  AppConfig._();

  /// Set to true to switch data layer to live Firebase backend.
  /// When false, the application executes completely offline in zero-setup Mock Mode.
  static const bool useFirebase = false;

  /// Default demo mode toggle
  static const bool defaultDemoMode = true;

  /// Default shake detection
  static const bool defaultShakeEnabled = true;
}
