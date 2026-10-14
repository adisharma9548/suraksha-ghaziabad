import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import 'repository_providers.dart';

class SettingsState {
  final Locale locale;
  final bool isDarkMode;
  final bool isDemoMode;
  final bool isShakeEnabled;

  const SettingsState({
    required this.locale,
    required this.isDarkMode,
    required this.isDemoMode,
    required this.isShakeEnabled,
  });

  SettingsState copyWith({
    Locale? locale,
    bool? isDarkMode,
    bool? isDemoMode,
    bool? isShakeEnabled,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isDemoMode: isDemoMode ?? this.isDemoMode,
      isShakeEnabled: isShakeEnabled ?? this.isShakeEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final Ref _ref;

  SettingsNotifier(this._ref)
      : super(const SettingsState(
          locale: Locale('en'),
          isDarkMode: false,
          isDemoMode: true,
          isShakeEnabled: true,
        )) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final prefs = _ref.read(sharedPreferencesProvider);
    final langCode = prefs.getString(AppConstants.keySelectedLanguage) ?? 'en';
    final isDark = prefs.getBool(AppConstants.keyDarkMode) ?? false;
    final isDemo = prefs.getBool(AppConstants.keyDemoMode) ?? true;
    final isShake = prefs.getBool(AppConstants.keyShakeDetection) ?? true;

    state = SettingsState(
      locale: Locale(langCode),
      isDarkMode: isDark,
      isDemoMode: isDemo,
      isShakeEnabled: isShake,
    );
  }

  Future<void> setLocale(Locale newLocale) async {
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setString(AppConstants.keySelectedLanguage, newLocale.languageCode);
    state = state.copyWith(locale: newLocale);
  }

  Future<void> toggleDarkMode(bool enabled) async {
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.keyDarkMode, enabled);
    state = state.copyWith(isDarkMode: enabled);
  }

  Future<void> toggleDemoMode(bool enabled) async {
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.keyDemoMode, enabled);
    state = state.copyWith(isDemoMode: enabled);
  }

  Future<void> toggleShake(bool enabled) async {
    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setBool(AppConstants.keyShakeDetection, enabled);
    state = state.copyWith(isShakeEnabled: enabled);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref);
});
