import 'package:flutter/material.dart';
import '../theme.dart';
import '../data/app_state.dart';
import '../models/models.dart';

class ContactsScreen extends StatefulWidget {
  final AppState state;
  const ContactsScreen({super.key, required this.state});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    widget.state.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.state.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => mounted ? setState(() {}) : null;

  void _openAddSheet() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final relationCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add Trusted Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _field(nameCtrl, 'Full name', Icons.person_outline),
            const SizedBox(height: 12),
            _field(phoneCtrl, 'Phone number', Icons.phone_outlined),
            const SizedBox(height: 12),
            _field(relationCtrl, 'Relation (e.g. Sister, Friend)', Icons.favorite_outline),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) return;
                  widget.state.addContact(TrustedContact(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    relation: relationCtrl.text.trim().isEmpty ? 'Contact' : relationCtrl.text.trim(),
                  ));
                  Navigator.pop(context);
                },
                child: const Text('Save Contact'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon) {
    return TextField(
      controller: c,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contacts = widget.state.contacts;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Trusted Contacts', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: _openAddSheet,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'They receive alerts and live location when SOS is triggered.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: contacts.isEmpty
                  ? const Center(
                      child: Text('No trusted contacts yet.', style: TextStyle(color: AppColors.textSecondary)))
                  : ListView.separated(
                      itemCount: contacts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final c = contacts[i];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primary.withOpacity(0.2),
                                child: Text(
                                  c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                    Text('${c.relation} · ${c.phone}',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => widget.state.removeContact(c.id),
                                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
