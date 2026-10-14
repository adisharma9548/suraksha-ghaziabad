import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/trusted_contact_model.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/repository_providers.dart';

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

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Emergency Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
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
                  if (val != null) setDialogState(() => relationship = val);
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
              onPressed: () async {
                if (nameCtrl.text.trim().isNotEmpty &&
                    phoneCtrl.text.trim().isNotEmpty) {
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
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(trustedContactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Contact', style: TextStyle(color: Colors.white)),
        onPressed: _showAddContactDialog,
      ),
      body: SafeArea(
        child: contactsAsync.when(
          data: (contacts) {
            if (contacts.isEmpty) {
              return const Center(child: Text('No contacts added yet. Tap Add Contact below.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
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
                    title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${contact.relationship} • ${contact.phone}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.sosRed),
                      onPressed: () async {
                        await ref
                            .read(authRepositoryProvider)
                            .removeTrustedContact(contact.id);
                        ref.invalidate(trustedContactsProvider);
                      },
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}
