import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSosActive ? AppColors.sosRedLight : AppColors.safeGreenLight,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isSosActive ? AppColors.sosRed : AppColors.safeGreen,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSosActive ? AppColors.sosRed : AppColors.safeGreen,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isSosActive
                ? (activeStatusLabel ?? 'EMERGENCY SOS ACTIVE')
                : 'STATUS: SAFE & PROTECTED',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: isSosActive ? AppColors.sosRedDark : AppColors.safeGreenDark,
            ),
          ),
        ],
      ),
    );
  }
}
