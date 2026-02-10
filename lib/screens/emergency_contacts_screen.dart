import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final List<Map<String, String>> _contacts = [
    {'name': 'Mom', 'phone': '+91 98765 43210', 'relation': 'Mother', 'priority': '1'},
    {'name': 'Dad', 'phone': '+91 98765 43211', 'relation': 'Father', 'priority': '2'},
  ];

  void _showAddContactDialog() {
    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    final relationC = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Add Emergency Contact', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            TextField(controller: nameC, decoration: const InputDecoration(hintText: 'Contact Name', prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 14),
            TextField(controller: phoneC, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined), prefixText: '+91 ')),
            const SizedBox(height: 14),
            TextField(controller: relationC, decoration: const InputDecoration(hintText: 'Relation (e.g., Mother, Friend)', prefixIcon: Icon(Icons.family_restroom_outlined))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (nameC.text.isNotEmpty && phoneC.text.isNotEmpty) {
                    setState(() {
                      _contacts.add({
                        'name': nameC.text,
                        'phone': '+91 ${phoneC.text}',
                        'relation': relationC.text,
                        'priority': '${_contacts.length + 1}',
                      });
                    });
                    Navigator.pop(ctx);
                  }
                },
                child: Text('Add Contact', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppShell(
      currentIndex: 3,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(child: Text('Emergency Contacts', style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700))),
            const SizedBox(height: 8),
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: Text('These contacts will be notified if you miss a call from a stranger',
                  style: GoogleFonts.poppins(fontSize: 14, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
            ),
            const SizedBox(height: 24),
            // Info card
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.info.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Contacts are called in priority order if you don\'t answer within 30 seconds.',
                          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.info)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Contacts list
            Expanded(
              child: _contacts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.contacts_outlined, size: 64, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          const SizedBox(height: 16),
                          Text('No emergency contacts yet', style: GoogleFonts.poppins(fontSize: 16, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      itemCount: _contacts.length,
                      onReorder: (old, newIdx) {
                        setState(() {
                          if (newIdx > old) newIdx--;
                          final item = _contacts.removeAt(old);
                          _contacts.insert(newIdx, item);
                          for (int i = 0; i < _contacts.length; i++) {
                            _contacts[i]['priority'] = '${i + 1}';
                          }
                        });
                      },
                      itemBuilder: (context, index) {
                        final c = _contacts[index];
                        return FadeInUp(
                          key: ValueKey(c['phone']),
                          delay: Duration(milliseconds: 100 * index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.lightCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColors.accent.withOpacity(0.1),
                                  ),
                                  child: Center(
                                    child: Text(c['priority']!, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.accent)),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c['name']!, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
                                      Row(
                                        children: [
                                          Text(c['phone']!, style: GoogleFonts.poppins(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                                          if (c['relation']!.isNotEmpty) ...[
                                            Text('  •  ', style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                                            Text(c['relation']!, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.accent)),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 22),
                                  onPressed: () => setState(() => _contacts.removeAt(index)),
                                ),
                                ReorderableDragStartListener(
                                  index: index,
                                  child: const Icon(Icons.drag_handle_rounded, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            // Add buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Sync from device contacts
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contact sync requires permission')));
                    },
                    icon: const Icon(Icons.sync_rounded, size: 20),
                    label: Text('Sync Contacts', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showAddContactDialog,
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: Text('Add Manual', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}