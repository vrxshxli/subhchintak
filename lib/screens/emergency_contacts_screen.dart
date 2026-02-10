import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final List<Map<String, String>> _contacts = [];
  bool _isSyncing = false;

  // ========== MANUAL ADD ==========
  void _showAddContactDialog() {
    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    String selectedRelation = 'Friend';

    final relations = [
      'Mother', 'Father', 'Spouse', 'Brother', 'Sister',
      'Son', 'Daughter', 'Friend', 'Colleague', 'Neighbor', 'Other'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text('Add Emergency Contact',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              TextField(
                  controller: nameC,
                  decoration: const InputDecoration(
                      hintText: 'Contact Name',
                      prefixIcon: Icon(Icons.person_outline))),
              const SizedBox(height: 14),
              TextField(
                  controller: phoneC,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      hintText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      prefixText: '+91 ')),
              const SizedBox(height: 14),
              // Relation dropdown
              DropdownButtonFormField<String>(
                value: selectedRelation,
                decoration: const InputDecoration(
                  hintText: 'Relation',
                  prefixIcon: Icon(Icons.family_restroom_outlined),
                ),
                items: relations
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) =>
                    setSheetState(() => selectedRelation = v ?? 'Friend'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameC.text.isNotEmpty && phoneC.text.isNotEmpty) {
                      setState(() {
                        _contacts.add({
                          'name': nameC.text,
                          'phone': phoneC.text.startsWith('+')
                              ? phoneC.text
                              : '+91 ${phoneC.text}',
                          'relation': selectedRelation,
                          'priority': '${_contacts.length + 1}',
                        });
                      });
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text('Add Contact',
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========== SYNC CONTACTS FROM DEVICE ==========
  Future<void> _syncContactsFromDevice() async {
    setState(() => _isSyncing = true);

    // Request permission
    final status = await Permission.contacts.request();
    if (!status.isGranted) {
      setState(() => _isSyncing = false);
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: Row(children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.warning, size: 28),
              const SizedBox(width: 10),
              Text('Permission Required',
                  style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700)),
            ]),
            content: Text(
                'SHUBHCHINTAK needs access to your contacts to sync emergency contacts. Please allow access in Settings.',
                style: GoogleFonts.poppins(fontSize: 14)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    openAppSettings();
                  },
                  child: const Text('Open Settings')),
            ],
          ),
        );
      }
      return;
    }

    // Fetch contacts
    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      // Filter contacts that have phone numbers
      final List<Map<String, String>> deviceContacts = [];
      for (final contact in contacts) {
        if (contact.phones.isNotEmpty) {
          String phone = contact.phones.first.number;
          phone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
          if (!phone.startsWith('+')) {
            if (phone.startsWith('0')) {
              phone = '+91${phone.substring(1)}';
            } else if (phone.length == 10) {
              phone = '+91$phone';
            }
          }
          deviceContacts.add({
            'name': contact.displayName,
            'phone': phone,
          });
        }
      }

      deviceContacts.sort((a, b) => a['name']!.compareTo(b['name']!));

      setState(() => _isSyncing = false);

      if (deviceContacts.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No contacts with phone numbers found.')));
        }
        return;
      }

      if (mounted) _showContactPickerSheet(deviceContacts);
    } catch (e) {
      setState(() => _isSyncing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to read contacts: $e')));
      }
    }
  }

  // ========== CONTACT PICKER BOTTOM SHEET ==========
  void _showContactPickerSheet(List<Map<String, String>> deviceContacts) {
    final searchController = TextEditingController();
    List<Map<String, String>> filteredContacts = List.from(deviceContacts);
    final Set<int> selectedIndices = {};

    // Relation for each selected contact
    final Map<int, String> contactRelations = {};

    final relations = [
      'Mother', 'Father', 'Spouse', 'Brother', 'Sister',
      'Son', 'Daughter', 'Friend', 'Colleague', 'Neighbor', 'Other'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.9,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 16),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.success.withOpacity(0.1)),
                          child: const Icon(Icons.contacts_rounded,
                              color: AppColors.success, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Select Contacts',
                                  style: GoogleFonts.spaceGrotesk(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700)),
                              Text(
                                  '${deviceContacts.length} contacts on your device',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        if (selectedIndices.isNotEmpty)
                          GestureDetector(
                            onTap: () =>
                                setSheetState(() => selectedIndices.clear()),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                  color: AppColors.danger.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text('Clear',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.danger)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name or number...',
                        prefixIcon:
                            const Icon(Icons.search_rounded, size: 22),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () {
                                  searchController.clear();
                                  setSheetState(() => filteredContacts =
                                      List.from(deviceContacts));
                                },
                              )
                            : null,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (query) {
                        setSheetState(() {
                          if (query.isEmpty) {
                            filteredContacts = List.from(deviceContacts);
                          } else {
                            filteredContacts = deviceContacts.where((c) {
                              return c['name']!
                                      .toLowerCase()
                                      .contains(query.toLowerCase()) ||
                                  c['phone']!.contains(query);
                            }).toList();
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Selected count bar
                  if (selectedIndices.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.accent.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: AppColors.accent, size: 20),
                          const SizedBox(width: 10),
                          Text(
                              '${selectedIndices.length} contact(s) selected',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent)),
                        ],
                      ),
                    ),

                  Divider(
                      color: isDark
                          ? AppColors.darkDivider
                          : AppColors.lightDivider),

                  // Contact list
                  Expanded(
                    child: filteredContacts.isEmpty
                        ? Center(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text('No contacts match your search',
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey)),
                            ],
                          ))
                        : ListView.builder(
                            itemCount: filteredContacts.length,
                            itemBuilder: (ctx, index) {
                              final contact = filteredContacts[index];
                              final originalIndex =
                                  deviceContacts.indexOf(contact);
                              final isSelected =
                                  selectedIndices.contains(originalIndex);
                              final isAlreadyAdded = _contacts.any(
                                  (c) => c['phone'] == contact['phone']);
                              final assignedRelation =
                                  contactRelations[originalIndex];

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.accent.withOpacity(0.05)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: isSelected
                                      ? Border.all(
                                          color:
                                              AppColors.accent.withOpacity(0.2))
                                      : null,
                                ),
                                child: Column(
                                  children: [
                                    ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 2),
                                      leading: CircleAvatar(
                                        radius: 22,
                                        backgroundColor: isAlreadyAdded
                                            ? Colors.grey.withOpacity(0.2)
                                            : isSelected
                                                ? AppColors.accent
                                                    .withOpacity(0.15)
                                                : AppColors.info
                                                    .withOpacity(0.1),
                                        child: Text(
                                          contact['name']![0].toUpperCase(),
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: isAlreadyAdded
                                                ? Colors.grey
                                                : isSelected
                                                    ? AppColors.accent
                                                    : AppColors.info,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        contact['name']!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isAlreadyAdded
                                              ? Colors.grey
                                              : null,
                                        ),
                                      ),
                                      subtitle: Text(
                                        contact['phone']!,
                                        style: GoogleFonts.poppins(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                      trailing: isAlreadyAdded
                                          ? Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: AppColors.success
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: Text('Already Added',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppColors.success)),
                                            )
                                          : Checkbox(
                                              value: isSelected,
                                              activeColor: AppColors.accent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4)),
                                              onChanged: (val) {
                                                setSheetState(() {
                                                  if (val == true) {
                                                    selectedIndices
                                                        .add(originalIndex);
                                                    contactRelations[
                                                            originalIndex] =
                                                        'Friend';
                                                  } else {
                                                    selectedIndices
                                                        .remove(originalIndex);
                                                    contactRelations
                                                        .remove(originalIndex);
                                                  }
                                                });
                                              },
                                            ),
                                      onTap: isAlreadyAdded
                                          ? null
                                          : () {
                                              setSheetState(() {
                                                if (selectedIndices
                                                    .contains(originalIndex)) {
                                                  selectedIndices
                                                      .remove(originalIndex);
                                                  contactRelations
                                                      .remove(originalIndex);
                                                } else {
                                                  selectedIndices
                                                      .add(originalIndex);
                                                  contactRelations[
                                                      originalIndex] = 'Friend';
                                                }
                                              });
                                            },
                                    ),

                                    // Relation picker (shows when selected)
                                    if (isSelected)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            56, 0, 12, 10),
                                        child: Row(
                                          children: [
                                            Text('Relation: ',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: Colors.grey)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  children:
                                                      relations.map((r) {
                                                    final isChosen =
                                                        assignedRelation == r;
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 6),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setSheetState(() {
                                                            contactRelations[
                                                                originalIndex] = r;
                                                          });
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 6),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: isChosen
                                                                ? AppColors
                                                                    .accent
                                                                : AppColors
                                                                    .accent
                                                                    .withOpacity(
                                                                        0.06),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            border: Border.all(
                                                              color: isChosen
                                                                  ? AppColors
                                                                      .accent
                                                                  : AppColors
                                                                      .accent
                                                                      .withOpacity(
                                                                          0.2),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            r,
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: isChosen
                                                                  ? Colors.white
                                                                  : AppColors
                                                                      .accent,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  // Bottom action button
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCard : AppColors.lightCard,
                      border: Border(
                          top: BorderSide(
                              color: isDark
                                  ? AppColors.darkDivider
                                  : AppColors.lightDivider)),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: selectedIndices.isEmpty
                            ? null
                            : () {
                                setState(() {
                                  for (final idx in selectedIndices) {
                                    final contact = deviceContacts[idx];
                                    if (!_contacts.any((c) =>
                                        c['phone'] == contact['phone'])) {
                                      _contacts.add({
                                        'name': contact['name']!,
                                        'phone': contact['phone']!,
                                        'relation':
                                            contactRelations[idx] ?? 'Friend',
                                        'priority':
                                            '${_contacts.length + 1}',
                                      });
                                    }
                                  }
                                });
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded,
                                            color: Colors.white, size: 20),
                                        const SizedBox(width: 10),
                                        Text(
                                            '${selectedIndices.length} contact(s) added as emergency contacts'),
                                      ],
                                    ),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedIndices.isEmpty
                              ? Colors.grey[300]
                              : AppColors.accent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                selectedIndices.isEmpty
                                    ? Icons.person_add_disabled_rounded
                                    : Icons.person_add_alt_1_rounded,
                                size: 22,
                                color: Colors.white),
                            const SizedBox(width: 10),
                            Text(
                              selectedIndices.isEmpty
                                  ? 'Select contacts to add'
                                  : 'Add ${selectedIndices.length} Contact(s)',
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ========== EDIT RELATION ==========
  void _editRelation(int index) {
    final relations = [
      'Mother', 'Father', 'Spouse', 'Brother', 'Sister',
      'Son', 'Daughter', 'Friend', 'Colleague', 'Neighbor', 'Other'
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('Set Relation for ${_contacts[index]['name']}',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: relations.map((r) {
                  final isSelected = _contacts[index]['relation'] == r;
                  return GestureDetector(
                    onTap: () {
                      setState(
                          () => _contacts[index]['relation'] = r);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.accent.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.accent.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        r,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.accent,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // ========== BUILD ==========
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
            FadeInDown(
                child: Text('Emergency Contacts',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 24, fontWeight: FontWeight.w700))),
            const SizedBox(height: 8),
            FadeInDown(
              delay: const Duration(milliseconds: 100),
              child: Text(
                  'These contacts will be notified if you miss a call from a stranger',
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary)),
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
                    const Icon(Icons.info_outline_rounded,
                        color: AppColors.info, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                          'Contacts are called in priority order if you don\'t answer within 30 seconds. Drag to reorder.',
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: AppColors.info)),
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
                      child: FadeIn(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.accent.withOpacity(0.08),
                              ),
                              child: Icon(Icons.contacts_outlined,
                                  size: 40,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary),
                            ),
                            const SizedBox(height: 20),
                            Text('No emergency contacts yet',
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary)),
                            const SizedBox(height: 8),
                            Text(
                                'Tap "Sync Contacts" to import from\nyour phone or add manually',
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary),
                                textAlign: TextAlign.center),
                          ],
                        ),
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
                          key: ValueKey('${c['phone']}_$index'),
                          delay: Duration(milliseconds: 50 * index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkCard
                                  : AppColors.lightCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: isDark
                                      ? AppColors.darkDivider
                                      : AppColors.lightDivider),
                            ),
                            child: Row(
                              children: [
                                // Priority number
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColors.accent.withOpacity(0.1),
                                  ),
                                  child: Center(
                                    child: Text(c['priority']!,
                                        style: GoogleFonts.spaceGrotesk(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.accent)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Name, phone, relation
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(c['name']!,
                                          style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 2),
                                      Text(c['phone']!,
                                          style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: isDark
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors
                                                      .lightTextSecondary)),
                                      const SizedBox(height: 4),
                                      // Relation chip (tap to edit)
                                      GestureDetector(
                                        onTap: () => _editRelation(index),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent
                                                .withOpacity(0.08),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                c['relation']!.isEmpty
                                                    ? 'Set relation'
                                                    : c['relation']!,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.accent),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(Icons.edit_rounded,
                                                  size: 12,
                                                  color: AppColors.accent),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Delete button
                                IconButton(
                                  icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppColors.danger,
                                      size: 22),
                                  onPressed: () => setState(
                                      () => _contacts.removeAt(index)),
                                ),
                                // Drag handle
                                ReorderableDragStartListener(
                                  index: index,
                                  child: const Icon(
                                      Icons.drag_handle_rounded,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Bottom buttons
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _isSyncing ? null : _syncContactsFromDevice,
                      icon: _isSyncing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.sync_rounded, size: 20),
                      label: Text(
                        _isSyncing ? 'Syncing...' : 'Sync Contacts',
                        style: GoogleFonts.poppins(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _showAddContactDialog,
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: Text('Add Manual',
                          style: GoogleFonts.poppins(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
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