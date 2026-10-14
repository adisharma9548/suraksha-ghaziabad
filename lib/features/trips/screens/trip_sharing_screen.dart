import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/providers/trip_provider.dart';
import '../../../data/providers/auth_provider.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please specify a destination')),
      );
      return;
    }

    // Default Ghaziabad route start & destination points
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

    if (tripState.hasActiveTrip) {
      // If trip is already active, offer resume button
      return Scaffold(
        appBar: AppBar(title: Text(l10n.tripSharingTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.navigation_rounded, size: 64, color: AppColors.primaryPurple),
                const SizedBox(height: 16),
                const Text(
                  'Trip Already In Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Destination: ${tripState.activeTrip?.destination}',
                  style: const TextStyle(color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.push('/active-trip'),
                  child: const Text('View Active Live Trip'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tripSharingTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.tripSharingTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Share real-time trip progress with emergency contacts. If your vehicle halts unusually or deviates, the app checks if you are OK.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight, height: 1.35),
              ),
              const SizedBox(height: 20),

              // Destination Input
              TextField(
                controller: _destinationController,
                decoration: InputDecoration(
                  labelText: l10n.enterDestination,
                  prefixIcon: const Icon(Icons.pin_drop_rounded, color: AppColors.primaryPurple),
                ),
              ),
              const SizedBox(height: 12),

              // Quick preset chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickDestinations.map((dest) {
                  return ActionChip(
                    label: Text(dest, style: const TextStyle(fontSize: 11)),
                    backgroundColor: Colors.white,
                    onPressed: () => setState(() => _destinationController.text = dest),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Trusted Contacts who will receive updates
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Contacts to be Notified:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              contactsAsync.when(
                data: (contacts) {
                  if (contacts.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warningAmberLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'No trusted contacts added yet. Go to Profile > Trusted Contacts to add emergency phone numbers.',
                        style: TextStyle(fontSize: 12, color: AppColors.warningAmberDark),
                      ),
                    );
                  }
                  return Column(
                    children: contacts.map((c) {
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.primaryPurpleSurface,
                          child: const Icon(Icons.person, size: 16, color: AppColors.primaryPurple),
                        ),
                        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        subtitle: Text('${c.relationship} • ${c.phone}', style: const TextStyle(fontSize: 11)),
                        trailing: const Icon(Icons.check_circle, size: 16, color: AppColors.safeGreen),
                      );
                    }).toList(),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const Text('Could not load contacts'),
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                icon: const Icon(Icons.security_rounded),
                label: Text(l10n.startTrip),
                onPressed: _handleStartTrip,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
