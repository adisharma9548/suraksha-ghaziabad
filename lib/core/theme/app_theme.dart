import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'ios_typography.dart';

/// Apple Human Interface Guidelines Native iOS Theme
/// Strict greyscale-first color system, high-contrast typography, and squircle geometries.
class AppTheme {
  AppTheme._();

  // ==========================================
  // LIGHT THEME (Apple HIG iOS Standard)
  // ==========================================
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryActionLight,
      onPrimary: AppColors.onPrimaryActionLight,
      secondary: AppColors.secondaryTextLight,
      onSecondary: AppColors.backgroundLight,
      error: AppColors.primaryActionLight, // Greyscale with warning symbol
      onError: AppColors.onPrimaryActionLight,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.primaryTextLight,
      outline: AppColors.separatorLight,
      outlineVariant: AppColors.opaqueSeparatorLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.secondaryBackgroundLight, // iOS Grouped Background #F2F2F7
      fontFamily: IosTypography.fontName,
      splashFactory: NoSplash.splashFactory, // iOS uses opacity/scale changes, not ink ripples
      highlightColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.secondaryBackgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryTextLight, size: 20),
        titleTextStyle: IosTypography.headline(color: AppColors.primaryTextLight),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.separatorLight, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: AppColors.primaryActionLight,
          foregroundColor: AppColors.onPrimaryActionLight,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: IosTypography.headline(color: AppColors.onPrimaryActionLight),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          foregroundColor: AppColors.primaryTextLight,
          side: const BorderSide(color: AppColors.separatorLight, width: 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: IosTypography.headline(color: AppColors.primaryTextLight),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 44),
          foregroundColor: AppColors.primaryTextLight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: IosTypography.body(
            color: AppColors.primaryTextLight,
            weight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.separatorLight, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.separatorLight, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryTextLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryTextLight, width: 2.0),
        ),
        labelStyle: IosTypography.subhead(color: AppColors.secondaryTextLight),
        hintStyle: IosTypography.subhead(color: AppColors.tertiaryTextLight),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight.withOpacity(0.92),
        elevation: 0,
        selectedItemColor: AppColors.primaryTextLight,
        unselectedItemColor: AppColors.tertiaryTextLight,
        selectedLabelStyle: IosTypography.caption2(weight: FontWeight.w600),
        unselectedLabelStyle: IosTypography.caption2(weight: FontWeight.w500),
        type: BottomNavigationBarType.fixed,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: IosTypography.title3(color: AppColors.primaryTextLight),
        contentTextStyle: IosTypography.callout(color: AppColors.secondaryTextLight),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.separatorLight,
        thickness: 0.5,
        space: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) => Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryActionLight;
          }
          return AppColors.separatorLight;
        }),
      ),
    );
  }

  // ==========================================
  // DARK THEME (Apple HIG iOS Dark Mode)
  // ==========================================
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryActionDark,
      onPrimary: AppColors.onPrimaryActionDark,
      secondary: AppColors.secondaryTextDark,
      onSecondary: AppColors.backgroundDark,
      error: AppColors.primaryActionDark,
      onError: AppColors.onPrimaryActionDark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.primaryTextDark,
      outline: AppColors.separatorDark,
      outlineVariant: AppColors.opaqueSeparatorDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.secondaryBackgroundDark, // #1C1C1E
      fontFamily: IosTypography.fontName,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.secondaryBackgroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryTextDark, size: 20),
        titleTextStyle: IosTypography.headline(color: AppColors.primaryTextDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.separatorDark, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: AppColors.primaryActionDark,
          foregroundColor: AppColors.onPrimaryActionDark,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: IosTypography.headline(color: AppColors.onPrimaryActionDark),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          foregroundColor: AppColors.primaryTextDark,
          side: const BorderSide(color: AppColors.separatorDark, width: 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: IosTypography.headline(color: AppColors.primaryTextDark),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 44),
          foregroundColor: AppColors.primaryTextDark,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: IosTypography.body(
            color: AppColors.primaryTextDark,
            weight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.separatorDark, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.separatorDark, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryTextDark, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryTextDark, width: 2.0),
        ),
        labelStyle: IosTypography.subhead(color: AppColors.secondaryTextDark),
        hintStyle: IosTypography.subhead(color: AppColors.tertiaryTextDark),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark.withOpacity(0.92),
        elevation: 0,
        selectedItemColor: AppColors.primaryTextDark,
        unselectedItemColor: AppColors.tertiaryTextDark,
        selectedLabelStyle: IosTypography.caption2(weight: FontWeight.w600),
        unselectedLabelStyle: IosTypography.caption2(weight: FontWeight.w500),
        type: BottomNavigationBarType.fixed,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: IosTypography.title3(color: AppColors.primaryTextDark),
        contentTextStyle: IosTypography.callout(color: AppColors.secondaryTextDark),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.separatorDark,
        thickness: 0.5,
        space: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) => Colors.black),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryActionDark;
          }
          return AppColors.separatorDark;
        }),
      ),
    );
  }
}
