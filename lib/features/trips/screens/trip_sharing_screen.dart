import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../core/widgets/ios_widgets.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/trip_provider.dart';

/// Native iOS Trip Sharing Screen
/// Complies with Apple HIG, grouped insets, SF Pro typography, and color-blind accessibility.
class TripSharingScreen extends ConsumerStatefulWidget {
  const TripSharingScreen({super.key});

  @override
  ConsumerState<TripSharingScreen> createState() => _TripSharingScreenState();
}

class _TripSharingScreenState extends ConsumerState<TripSharingScreen> {
  final _destinationController =
      TextEditingController(text: 'Vaishali Metro Station (Gate 2)');

  final List<String> _quickDestinations = [
    'Vaishali Metro Station (Gate 2)',
    'Shipra Mall, Indirapuram',
    'RDC Market, Raj Nagar',
    'ABES Engineering College, NH-24',
    'River Heights, Raj Nagar Extension',
    'Kaushambi Bus Terminal',
  ];

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _handleStartTrip() async {
    final destination = _destinationController.text.trim();
    if (destination.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Destination Required'),
          content: const Text('Please enter or select a destination for trip tracking.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
      return;
    }

    await ref.read(tripProvider.notifier).startTrip(
          destination: destination,
          startLat: 28.6432,
          startLng: 77.3695,
          destLat: 28.6478,
          destLng: 77.3392,
        );

    if (mounted) {
      context.push('/active-trip');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final contactsAsync = ref.watch(trustedContactsProvider);
    final tripState = ref.watch(tripProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    if (tripState.hasActiveTrip) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
        appBar: AppBar(
          title: Text(l10n.tripSharingTitle, style: IosTypography.headline(color: primaryTextColor)),
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
          elevation: 0,
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.secondarySurfaceLight,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      CupertinoIcons.location_north_fill,
                      size: 38,
                      color: primaryTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Trip In Progress',
                  style: IosTypography.title2(color: primaryTextColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'Destination: ${tripState.activeTrip?.destination}',
                  style: IosTypography.subhead(color: secondaryTextColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                IosButton(
                  text: 'View Active Live Trip',
                  icon: CupertinoIcons.map_fill,
                  onPressed: () => context.push('/active-trip'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
      appBar: AppBar(
        title: Text(l10n.tripSharingTitle, style: IosTypography.headline(color: primaryTextColor)),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Inset Section 1: Destination
              IosGroupedSection(
                header: 'DESTINATION & ROUTE',
                footer: 'Live GPS breadcrumbs stream to contacts. Automatic safety check-ins occur if vehicle halts.',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CupertinoTextField(
                          controller: _destinationController,
                          placeholder: 'Where are you heading?',
                          placeholderStyle: IosTypography.callout(color: AppColors.tertiaryTextDark),
                          style: IosTypography.callout(color: primaryTextColor),
                          prefix: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Icon(
                              CupertinoIcons.location_solid,
                              color: primaryTextColor,
                              size: 18,
                            ),
                          ),
                          clearButtonMode: OverlayVisibilityMode.editing,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.secondarySurfaceDark : AppColors.secondaryBackgroundLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text('Quick Presets in Ghaziabad', style: IosTypography.footnote(color: secondaryTextColor)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _quickDestinations.map((dest) {
                            final isCurrent = _destinationController.text == dest;
                            return CupertinoButton(
                              padding: EdgeInsets.zero,
                              minSize: 32,
                              onPressed: () => setState(() => _destinationController.text = dest),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isCurrent
                                      ? primaryTextColor
                                      : (isDark ? AppColors.surfaceDark : AppColors.secondaryBackgroundLight),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isCurrent
                                        ? primaryTextColor
                                        : (isDark ? AppColors.separatorDark : AppColors.separatorLight),
                                  ),
                                ),
                                child: Text(
                                  dest,
                                  style: IosTypography.caption1(
                                    color: isCurrent
                                        ? (isDark ? Colors.black : Colors.white)
                                        : primaryTextColor,
                                    weight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Inset Section 2: Trusted Contacts
              IosGroupedSection(
                header: 'EMERGENCY MONITORS',
                footer: 'Contacts will receive SMS alerts with your real-time tracking link.',
                children: [
                  contactsAsync.when(
                    data: (contacts) {
                      if (contacts.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No trusted contacts configured. Add contacts in Profile > Trusted Contacts.',
                            style: IosTypography.footnote(color: secondaryTextColor),
                          ),
                        );
                      }
                      return Column(
                        children: contacts.asMap().entries.map((entry) {
                          final c = entry.value;
                          final isLast = entry.key == contacts.length - 1;
                          return IosListTile(
                            showDivider: !isLast,
                            leadingIcon: CupertinoIcons.person_crop_circle_badge_checkmark,
                            title: c.name,
                            subtitle: '${c.relationship} • ${c.phone}',
                            trailing: IosBadge(
                              label: 'Active',
                              icon: CupertinoIcons.checkmark_alt,
                              type: IosBadgeType.success,
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child: CupertinoActivityIndicator(),
                    ),
                    error: (_, __) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Failed to load contacts', style: IosTypography.footnote(color: secondaryTextColor)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Start Trip Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: IosButton(
                  text: l10n.startTrip,
                  icon: CupertinoIcons.shield_fill,
                  onPressed: _handleStartTrip,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
