import 'package:flutter/material.dart';

/// Apple Human Interface Guidelines Typography Scale
/// Utilizes the official iOS Dynamic Type sizing scale with SF Pro typographic metrics.
class IosTypography {
  IosTypography._();

  static const String fontName = '.SF Pro Text';

  // 1. Large Title (34pt, Bold, Letter spacing 0.37)
  static TextStyle largeTitle({
    Color? color,
    FontWeight weight = FontWeight.bold,
    double? height = 1.2,
    FontStyle? style,
  }) {
    return TextStyle(
      fontSize: 34,
      fontWeight: weight,
      letterSpacing: 0.37,
      height: height,
      color: color,
      fontStyle: style,
    );
  }

  // 2. Title 1 (28pt, Bold, Letter spacing 0.36)
  static TextStyle title1({
    Color? color,
    FontWeight weight = FontWeight.bold,
    double? height = 1.21,
    FontStyle? style,
  }) {
    return TextStyle(
      fontSize: 28,
      fontWeight: weight,
      letterSpacing: 0.36,
      height: height,
      color: color,
      fontStyle: style,
    );
  }

  // 3. Title 2 (22pt, Bold, Letter spacing 0.35)
  static TextStyle title2({
    Color? color,
    FontWeight weight = FontWeight.bold,
    double? height = 1.27,
    FontStyle? style,
  }) {
    return TextStyle(
      fontSize: 22,
      fontWeight: weight,
      letterSpacing: 0.35,
      height: height,
      color: color,
      fontStyle: style,
    );
  }

  // 4. Title 3 (20pt, Semibold, Letter spacing 0.38)
  static TextStyle title3({
    Color? color,
    FontWeight weight = FontWeight.w600,
    double? height = 1.25,
    FontStyle? style,
  }) {
    return TextStyle(
      fontSize: 20,
      fontWeight: weight,
      letterSpacing: 0.38,
      height: height,
      color: color,
      fontStyle: style,
    );
  }

  // 5. Headline (17pt, Semibold, Letter spacing -0.41)
  static TextStyle headline({
    Color? color,
    FontWeight weight = FontWeight.w600,
    double? height = 1.29,
    FontStyle? style,
  }) {
    return TextStyle(
      fontSize: 17,
      fontWeight: weight,
      letterSpacing: -0.41,
      height: height,
      color: color,
      fontStyle: style,
    );
  }

  // 6. Body (17pt, Regular, Letter spacing -0.41)
  static TextStyle body({
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? height = 1.29,
    FontStyle? style,
  }) {
    return TextStyle(
      fontSize: 17,
      fontWeight: weight,
      letterSpacing: -0.41,
      height: height,
      color: color,
      fontStyle: style,
    );
  }

  // 7. Callout (16pt, Regular, Letter spacing -0.32)
  static TextStyle callout({
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? height = 1.31,
    FontStyle? style,
  }) {
    return TextStyle(
      fontSize: 16,
      fontWeight: weight,
      letterSpacing: -0.32,
      height: height,
      color: color,
      fontStyle: style,
    );
  }

  // 8. Subhead (15pt, Regular, Letter spacing -0.24)
  static TextStyle subhead({
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? height = 1.33,
    FontStyle? style,
  }) {
    return TextStyle(
      fontSize: 15,
      fontWeight: weight,
      letterSpacing: -0.24,
      height: height,
      color: color,
      fontStyle: style,
    );
  }

  // 9. Footnote (13pt, Regular, Letter spacing -0.08)
  static TextStyle footnote({
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? height = 1.38,
    FontStyle? style,
  }) {
    return TextStyle(
      fontSize: 13,
      fontWeight: weight,
      letterSpacing: -0.08,
      height: height,
      color: color,
      fontStyle: style,
    );
  }

  // 10. Caption 1 (12pt, Regular, Letter spacing 0.0)
  static TextStyle caption1({
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? height = 1.33,
    FontStyle? style,
  }) {
    return TextStyle(
      fontSize: 12,
      fontWeight: weight,
      letterSpacing: 0.0,
      height: height,
      color: color,
      fontStyle: style,
    );
  }

  // 11. Caption 2 (11pt, Regular, Letter spacing 0.06)
  static TextStyle caption2({
    Color? color,
    FontWeight weight = FontWeight.w400,
    double? height = 1.36,
    FontStyle? style,
  }) {
    return TextStyle(
      fontSize: 11,
      fontWeight: weight,
      letterSpacing: 0.06,
      height: height,
      color: color,
      fontStyle: style,
    );
  }
}
