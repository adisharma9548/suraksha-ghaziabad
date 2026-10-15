import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';

/// Apple HIG Multi-Cue Status Banner
/// Uses shape, iconography, weight, and luminance contrast (NEVER color alone).
class StatusBanner extends StatelessWidget {
  final bool isSosActive;
  final String? activeStatusLabel;

  const StatusBanner({
    super.key,
    required this.isSosActive,
    this.activeStatusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // High contrast styling:
    // Safe: Inset clean badge with filled checkmark-shield
    // Active SOS: Inverted filled badge with prominent warning triangle and double border
    final bg = isSosActive
        ? (isDark ? AppColors.primaryActionDark : AppColors.primaryActionLight)
        : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);

    final fg = isSosActive
        ? (isDark ? AppColors.onPrimaryActionDark : AppColors.onPrimaryActionLight)
        : (isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight);

    final borderColor = isSosActive
        ? (isDark ? Colors.white : Colors.black)
        : (isDark ? AppColors.separatorDark : AppColors.separatorLight);

    final icon = isSosActive
        ? CupertinoIcons.exclamationmark_triangle_fill
        : CupertinoIcons.checkmark_shield_fill;

    final label = isSosActive
        ? (activeStatusLabel ?? 'EMERGENCY SOS ACTIVE')
        : 'STATUS: SAFE & MONITORED';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: isSosActive ? 2.0 : 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: fg,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: IosTypography.caption1(
              color: fg,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
