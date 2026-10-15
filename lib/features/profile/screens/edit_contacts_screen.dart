import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/ios_typography.dart';
import '../../../core/widgets/ios_widgets.dart';
import '../../../data/models/trusted_contact_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/repository_providers.dart';

/// Native iOS Edit Contacts Screen
/// Grouped inset list with Apple HIG add contact modal and high-contrast contact management.
class EditContactsScreen extends ConsumerStatefulWidget {
  const EditContactsScreen({super.key});

  @override
  ConsumerState<EditContactsScreen> createState() => _EditContactsScreenState();
}

class _EditContactsScreenState extends ConsumerState<EditContactsScreen> {
  final _uuid = const Uuid();

  void _showAddContactDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String relationship = 'Family';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;

    showCupertinoDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => CupertinoAlertDialog(
          title: Text('Add Emergency Contact', style: IosTypography.headline()),
          content: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CupertinoTextField(
                  controller: nameCtrl,
                  placeholder: 'Full Name',
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
              child: const Text('Add Contact'),
              onPressed: () async {
                if (nameCtrl.text.trim().isNotEmpty && phoneCtrl.text.trim().isNotEmpty) {
                  await ref.read(authRepositoryProvider).addTrustedContact(
                        TrustedContactModel(
                          id: _uuid.v4(),
                          userId: '',
                          name: nameCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          relationship: relationship,
                        ),
                      );
                  ref.invalidate(trustedContactsProvider);
                  Navigator.pop(ctx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(trustedContactsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final secondaryTextColor = isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
      appBar: AppBar(
        title: Text('Emergency Contacts', style: IosTypography.headline(color: primaryTextColor)),
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.secondaryBackgroundLight,
        elevation: 0,
        centerTitle: true,
        actions: [
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onPressed: _showAddContactDialog,
            child: Icon(CupertinoIcons.add, color: primaryTextColor),
          ),
        ],
      ),
      body: SafeArea(
        child: contactsAsync.when(
          data: (contacts) {
            if (contacts.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.person_2, size: 54, color: secondaryTextColor),
                      const SizedBox(height: 16),
                      Text(
                        'No Emergency Contacts',
                        style: IosTypography.title2(color: primaryTextColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add up to 5 trusted friends or relatives who will automatically receive your live location and SMS during SOS alerts.',
                        textAlign: TextAlign.center,
                        style: IosTypography.body(color: secondaryTextColor),
                      ),
                      const SizedBox(height: 24),
                      IosButton(
                        text: 'Add First Contact',
                        icon: CupertinoIcons.add,
                        onPressed: _showAddContactDialog,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.only(top: 8, bottom: 32),
              children: [
                IosGroupedSection(
                  header: 'REGISTERED CONTACTS (${contacts.length}/5)',
                  footer: 'Contacts are notified concurrently via SMS and push messaging when SOS triggers.',
                  children: contacts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final contact = entry.value;
                    final isLast = index == contacts.length - 1;

                    return IosListTile(
                      showDivider: !isLast,
                      leadingIcon: CupertinoIcons.person_crop_circle_fill,
                      title: contact.name,
                      subtitle: '${contact.relationship} • ${contact.phone}',
                      trailing: CupertinoButton(
                        padding: EdgeInsets.zero,
                        minSize: 36,
                        onPressed: () async {
                          await ref
                              .read(authRepositoryProvider)
                              .removeTrustedContact(contact.id);
                          ref.invalidate(trustedContactsProvider);
                        },
                        child: Icon(
                          CupertinoIcons.minus_circle_fill,
                          color: isDark ? AppColors.secondaryTextDark : const Color(0xFF1C1C1E),
                          size: 22,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: IosButton(
                    text: 'Add Another Contact',
                    icon: CupertinoIcons.plus_circle_fill,
                    type: IosButtonType.secondary,
                    onPressed: contacts.length >= 5 ? null : _showAddContactDialog,
                  ),
                ),
              ],
            );
          },
          loading: () => Center(
            child: CupertinoActivityIndicator(radius: 14, color: primaryTextColor),
          ),
          error: (err, _) => Center(
            child: Text('Error: $err', style: IosTypography.subhead(color: secondaryTextColor)),
          ),
        ),
      ),
    );
  }
}
