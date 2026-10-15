import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../core/widgets/ios_widgets.dart';
import '../../../data/models/trusted_contact_model.dart';
import '../../../data/providers/auth_provider.dart';

/// Native iOS Citizen Profile Setup Screen
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
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _duressPinController.dispose();
    super.dispose();
  }

  void _showAddContactDialog() {
    if (_contacts.length >= 5) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Limit Reached'),
          content: const Text('A maximum of 5 emergency contacts can be registered.'),
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

    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String relationship = 'Family';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;

    showCupertinoDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => CupertinoAlertDialog(
          title: Text('Add Trusted Contact', style: IosTypography.headline()),
          content: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoTextField(
                  controller: nameCtrl,
                  placeholder: 'Contact Full Name',
                  style: IosTypography.callout(color: primaryTextColor),
                  padding: const EdgeInsets.all(10),
                ),
                const SizedBox(height: 10),
                CupertinoTextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  placeholder: '10-Digit Mobile (+91)',
                  style: IosTypography.callout(color: primaryTextColor),
                  padding: const EdgeInsets.all(10),
                ),
                const SizedBox(height: 10),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.secondarySurfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Relationship: $relationship', style: IosTypography.footnote(color: primaryTextColor)),
                        Icon(CupertinoIcons.chevron_up_chevron_down, size: 14, color: primaryTextColor),
                      ],
                    ),
                  ),
                  onPressed: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (pickerCtx) => Container(
                        height: 220,
                        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                        child: CupertinoPicker(
                          itemExtent: 36,
                          onSelectedItemChanged: (index) {
                            final rels = ['Mother', 'Father', 'Sister', 'Brother', 'Friend', 'Guardian', 'Family'];
                            setDialogState(() => relationship = rels[index]);
                          },
                          children: ['Mother', 'Father', 'Sister', 'Brother', 'Friend', 'Guardian', 'Family']
                              .map((r) => Center(child: Text(r, style: IosTypography.callout())))
                              .toList(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(ctx),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Add'),
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty && phoneCtrl.text.trim().isNotEmpty) {
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
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Name Required'),
          content: const Text('Please enter your full name.'),
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

    if (pin.length != 4 || pin != confirmPin) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('PIN Error'),
          content: const Text('Please enter and confirm a 4-digit emergency cancellation PIN.'),
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

    if (_contacts.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Contacts Required'),
          content: const Text('Please add at least 1 emergency contact to receive distress alerts.'),
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

    final duressPin = _duressPinController.text.trim();
    if (duressPin.isNotEmpty && duressPin.length != 4) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Duress PIN Error'),
          content: const Text('Decoy duress PIN must be exactly 4 digits.'),
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

    if (duressPin.isNotEmpty && duressPin == pin) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Duress PIN Error'),
          content: const Text('Duress PIN must differ from your normal emergency PIN.'),
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

    await ref.read(authProvider.notifier).saveProfile(
          name: name,
          pin: pin,
          contacts: _contacts,
          duressPin: duressPin.isNotEmpty ? duressPin : null,
        );

    if (mounted) {
      context.go('/citizen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authState = ref.watch(authProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
      appBar: AppBar(
        title: Text(l10n.completeProfile, style: IosTypography.headline(color: primaryTextColor)),
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
              // Inset Section 1: User Identity
              IosGroupedSection(
                header: 'IDENTITY',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: CupertinoTextField(
                      controller: _nameController,
                      placeholder: 'Your Full Name',
                      placeholderStyle: IosTypography.callout(color: AppColors.tertiaryTextDark),
                      style: IosTypography.callout(color: primaryTextColor),
                      prefix: Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Icon(CupertinoIcons.person_fill, size: 18, color: primaryTextColor),
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.secondarySurfaceDark : AppColors.secondaryBackgroundLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Inset Section 2: Security PINs
              IosGroupedSection(
                header: 'EMERGENCY & DURESS PINS',
                footer: 'Emergency PIN cancels false alarms. Duress PIN secretly alerts police when coerced by an attacker.',
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CupertinoTextField(
                          controller: _pinController,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          obscureText: true,
                          placeholder: '4-Digit Emergency PIN',
                          placeholderStyle: IosTypography.callout(color: AppColors.tertiaryTextDark),
                          style: IosTypography.callout(color: primaryTextColor),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.secondarySurfaceDark : AppColors.secondaryBackgroundLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CupertinoTextField(
                          controller: _confirmPinController,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          obscureText: true,
                          placeholder: 'Confirm Emergency PIN',
                          placeholderStyle: IosTypography.callout(color: AppColors.tertiaryTextDark),
                          style: IosTypography.callout(color: primaryTextColor),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.secondarySurfaceDark : AppColors.secondaryBackgroundLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CupertinoTextField(
                          controller: _duressPinController,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          obscureText: true,
                          placeholder: 'Decoy Duress PIN (Optional)',
                          placeholderStyle: IosTypography.callout(color: AppColors.tertiaryTextDark),
                          style: IosTypography.callout(color: primaryTextColor),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.secondarySurfaceDark : AppColors.secondaryBackgroundLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.separatorDark : AppColors.separatorLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Inset Section 3: Trusted Contacts
              IosGroupedSection(
                header: 'TRUSTED CONTACTS (${_contacts.length}/5)',
                footer: 'Contacts receive emergency dispatch links when SOS is initiated.',
                children: [
                  if (_contacts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No contacts added yet. Add at least 1 contact below.',
                        style: IosTypography.footnote(color: secondaryTextColor),
                      ),
                    )
                  else
                    ..._contacts.asMap().entries.map((entry) {
                      final index = entry.key;
                      final c = entry.value;
                      final isLast = index == _contacts.length - 1;
                      return IosListTile(
                        showDivider: !isLast,
                        leadingIcon: CupertinoIcons.person_crop_circle_fill,
                        title: c.name,
                        subtitle: '${c.relationship} • ${c.phone}',
                        trailing: CupertinoButton(
                          padding: EdgeInsets.zero,
                          minSize: 34,
                          child: Icon(CupertinoIcons.minus_circle_fill, size: 20, color: primaryTextColor),
                          onPressed: () => setState(() => _contacts.removeAt(index)),
                        ),
                      );
                    }),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: IosButton(
                  text: 'Add Emergency Contact',
                  icon: CupertinoIcons.plus_circle_fill,
                  type: IosButtonType.secondary,
                  onPressed: _contacts.length >= 5 ? null : _showAddContactDialog,
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: IosButton(
                  text: 'Save & Enter Protected Mode',
                  icon: CupertinoIcons.shield_fill,
                  isLoading: authState.isLoading,
                  onPressed: _handleSave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
