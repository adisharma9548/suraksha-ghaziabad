import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Safety Policy', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryPurpleSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryPurple.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Our Core Privacy Pledge',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurpleDark,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Suraksha Ghaziabad was architected from the ground up for women\'s safety without surveillance compromise. We strictly minimize collected telemetry.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _PolicySection(
              title: '1. Ephemeral Location Sharing Only',
              content:
                  'Your GPS coordinates are accessed and streamed ONLY during an actively triggered SOS alert or while a user initiates a "Trip Safe" session. There is ZERO passive or background tracking during standard everyday use.',
            ),

            _PolicySection(
              title: '2. Anonymous Spot Reporting',
              content:
                  'All citizen reports of dark roads, broken streetlights, or harassment hotspots are submitted anonymously by default. No personal identity or phone number is ever permanently attached to civic hazard reports on the public heatmap.',
            ),

            _PolicySection(
              title: '3. Cryptographic PIN Hashing',
              content:
                  'Your 4-digit emergency cancellation PIN is hashed locally using cryptographic SHA-256 before storage. Plaintext PINs are never stored or transmitted in the clear.',
            ),

            _PolicySection(
              title: '4. Dial 112 & Control Room Notice',
              content: AppConstants.policeIntegrationNotice,
            ),

            _PolicySection(
              title: '5. Absolute Right to Delete Data',
              content:
                  'Under the "Delete My Data" feature in your profile settings, you can instantly erase your account, contact circles, and cached local records with one confirmation tap.',
            ),

            const SizedBox(height: 30),
            Center(
              child: Text(
                'Version 1.0.0 • ${AppConstants.eventName}',
                style: const TextStyle(fontSize: 11, color: AppColors.textHintLight),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String content;

  const _PolicySection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
