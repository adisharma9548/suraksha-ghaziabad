import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/trusted_contact_model.dart';
import '../../../data/providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _duressPinController = TextEditingController();
  final List<TrustedContactModel> _contacts = [];
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _duressPinController.dispose();
    super.dispose();
  }

  void _showAddContactDialog() {
    if (_contacts.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 emergency contacts allowed')),
      );
      return;
    }

    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String relationship = 'Family';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Trusted Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Contact Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number (+91)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: relationship,
                items: ['Mother', 'Father', 'Sister', 'Brother', 'Friend', 'Guardian', 'Family']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => relationship = val);
                  }
                },
                decoration: const InputDecoration(labelText: 'Relationship'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty &&
                    phoneCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _contacts.add(TrustedContactModel(
                      id: _uuid.v4(),
                      userId: '',
                      name: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      relationship: relationship,
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    if (pin.length != 4 || pin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter and confirm a 4-digit PIN')),
      );
      return;
    }

    if (_contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 1 emergency contact')),
      );
      return;
    }

    final duressPin = _duressPinController.text.trim();
    if (duressPin.isNotEmpty && duressPin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Duress PIN must be exactly 4 digits if set')),
      );
      return;
    }

    if (duressPin.isNotEmpty && duressPin == pin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Duress PIN must be different from your emergency PIN')),
      );
      return;
    }

    await ref.read(authProvider.notifier).saveProfile(
          name: name,
          pin: pin,
          duressPin: duressPin.isNotEmpty ? duressPin : null,
          contacts: _contacts,
        );

    if (mounted) {
      context.go('/citizen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.completeProfile),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.completeProfile,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Personalize your safety profile and setup trusted emergency circles.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 24),

              // Name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.yourName,
                  prefixIcon: const Icon(Icons.person_rounded, color: AppColors.primaryPurple),
                ),
              ),
              const SizedBox(height: 20),

              // Emergency PIN section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurpleSurface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.pin_rounded, color: AppColors.primaryPurple),
                        const SizedBox(width: 8),
                        Text(
                          l10n.emergencyPin,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurpleDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.emergencyPinDesc,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _pinController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: '4-Digit PIN',
                              counterText: '',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _confirmPinController,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Confirm PIN',
                              counterText: '',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Decoy Duress PIN (Optional)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.sosRedLight.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.sosRed.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined,
                            color: AppColors.sosRed, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Decoy Duress PIN (Optional)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.sosRedDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'If forced by an attacker to cancel an active SOS, entering this PIN visually closes the alert while secretly continuing live location streaming to the police control room.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _duressPinController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: '4-Digit Duress PIN (optional)',
                        counterText: '',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Trusted Contacts Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.trustedContacts,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.addContact),
                    onPressed: _showAddContactDialog,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_contacts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.dividerLight),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.contact_phone_outlined, color: AppColors.textSecondaryLight),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No emergency contacts added yet. Add 1 to 5 contacts (parents, family, trusted friends) to notify during an SOS.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                        ),
                      ),
                    ],
                  ),
                ),

              ..._contacts.asMap().entries.map((entry) {
                final idx = entry.key;
                final contact = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primaryPurpleSurface,
                      child: Text(
                        contact.name[0],
                        style: const TextStyle(
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      contact.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('${contact.relationship} • ${contact.phone}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.sosRed),
                      onPressed: () {
                        setState(() {
                          _contacts.removeAt(idx);
                        });
                      },
                    ),
                  ),
                );
              }),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _handleSave,
                child: Text(l10n.save),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
