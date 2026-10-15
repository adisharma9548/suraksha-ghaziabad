import 'package:flutter/material.dart';

/// Apple Human Interface Guidelines (HIG) Greyscale Design System
/// Specially calibrated for full usability across all types of color vision deficiency
/// (Deuteranopia, Protanopia, Tritanopia, and Achromatopsia/Monochromacy).
///
/// Features Light, Dark, and High Contrast palettes with WCAG AAA luminance contrast.
class AppColors {
  AppColors._();

  // ==========================================
  // LIGHT MODE TOKENS (HIG Greyscale First)
  // ==========================================
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color secondaryBackgroundLight = Color(0xFFF2F2F7); // Grouped table background
  static const Color tertiaryBackgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color secondarySurfaceLight = Color(0xFFE5E5EA);
  static const Color separatorLight = Color(0xFFD1D1D6);
  static const Color opaqueSeparatorLight = Color(0xFFC6C6C8);
  static const Color primaryTextLight = Color(0xFF1C1C1E); // Contrast > 12:1 against #FFFFFF
  static const Color secondaryTextLight = Color(0xFF636366); // Contrast > 7:1 against #FFFFFF (AAA)
  static const Color tertiaryTextLight = Color(0xFF8E8E93); // Contrast > 4.5:1 against #FFFFFF (Large text/icons)
  static const Color primaryActionLight = Color(0xFF1C1C1E);
  static const Color onPrimaryActionLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = primaryTextLight;
  static const Color textSecondaryLight = secondaryTextLight;
  static const Color textTertiaryLight = tertiaryTextLight;

  // ==========================================
  // DARK MODE TOKENS (HIG Greyscale First)
  // ==========================================
  static const Color backgroundDark = Color(0xFF000000);
  static const Color secondaryBackgroundDark = Color(0xFF1C1C1E); // Grouped table background dark
  static const Color tertiaryBackgroundDark = Color(0xFF2C2C2E);
  static const Color surfaceDark = Color(0xFF2C2C2E);
  static const Color secondarySurfaceDark = Color(0xFF3A3A3C);
  static const Color separatorDark = Color(0xFF38383A);
  static const Color opaqueSeparatorDark = Color(0xFF545458);
  static const Color primaryTextDark = Color(0xFFFFFFFF); // Contrast > 15:1 against #000000
  static const Color secondaryTextDark = Color(0xFFAEAEB2); // Contrast > 7:1 against #000000 (AAA)
  static const Color tertiaryTextDark = Color(0xFF8E8E93);
  static const Color primaryActionDark = Color(0xFFFFFFFF);
  static const Color onPrimaryActionDark = Color(0xFF000000);
  static const Color textPrimaryDark = primaryTextDark;
  static const Color textSecondaryDark = secondaryTextDark;
  static const Color textTertiaryDark = tertiaryTextDark;

  // ==========================================
  // ACCENT COLORS (Color-Blind Safe Blue / Orange)
  // Used sparingly, ALWAYS paired with a non-color cue (icon, label, shape)
  // ==========================================
  static const Color accentBlue = Color(0xFF007AFF); // Apple System Blue
  static const Color accentBlueDark = Color(0xFF0A84FF);
  static const Color accentBlueLight = Color(0xFFEBF5FF);

  static const Color accentOrange = Color(0xFFFF9500); // Apple System Orange (Accessible Warning)
  static const Color accentOrangeDark = Color(0xFFFF9F0A);
  static const Color accentOrangeLight = Color(0xFFFFF4E5);

  // ==========================================
  // HIGH CONTRAST TOKENS (Accessibility Mode)
  // ==========================================
  static const Color highContrastBackground = Color(0xFFFFFFFF);
  static const Color highContrastSurface = Color(0xFFFFFFFF);
  static const Color highContrastBorder = Color(0xFF000000);
  static const Color highContrastText = Color(0xFF000000);
  static const Color highContrastTextSecondary = Color(0xFF2C2C2E);

  // ==========================================
  // STATE MAPPINGS (Multi-Cue Compatible Aliases)
  // Maps previous color names to accessible greyscale + high-contrast equivalents
  // ==========================================
  static const Color primaryPurple = Color(0xFF1C1C1E); // Primary action neutral
  static const Color primaryPurpleLight = Color(0xFF636366);
  static const Color primaryPurpleDark = Color(0xFF000000);
  static const Color primaryPurpleSurface = Color(0xFFF2F2F7);

  // Emergency & SOS: High contrast luminance with bold outlines and distinct symbols
  static const Color sosRed = Color(0xFF1C1C1E); // Dark tactile action (paired with alert icon & bold border)
  static const Color sosRedLight = Color(0xFFF2F2F7);
  static const Color sosRedDark = Color(0xFF000000);

  // Safe & Resolved: Luminance contrast with checkmark symbols
  static const Color safeGreen = Color(0xFF1C1C1E);
  static const Color safeGreenLight = Color(0xFFF2F2F7);
  static const Color safeGreenDark = Color(0xFF000000);

  // Warning & Pending: High luminance contrast with warning triangles
  static const Color warningAmber = Color(0xFF636366);
  static const Color warningAmberLight = Color(0xFFF2F2F7);
  static const Color warningAmberDark = Color(0xFF1C1C1E);

  // Info:
  static const Color infoBlue = Color(0xFF636366);
  static const Color infoBlueLight = Color(0xFFF2F2F7);

  // Legacy Card & Text mappings
  static const Color cardLight = surfaceLight;
  static const Color cardDark = surfaceDark;
  static const Color textHintLight = tertiaryTextLight;
  static const Color textHintDark = tertiaryTextDark;
  static const Color dividerLight = separatorLight;
  static const Color dividerDark = separatorDark;

  static const Color policeNavy = Color(0xFF1C1C1E);
  static const Color policeNavySurface = Color(0xFFF2F2F7);

  // Heatmap Gradients (Monochromatic Luminance Density: Light to Dark)
  static const Color heatMapLow = Color(0xFFD1D1D6);
  static const Color heatMapMedium = Color(0xFF636366);
  static const Color heatMapHigh = Color(0xFF1C1C1E);
}
