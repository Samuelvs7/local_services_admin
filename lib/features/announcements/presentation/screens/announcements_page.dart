import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:local_services_admin/features/announcements/data/models/announcement_model.dart';
import 'package:local_services_admin/features/announcements/data/repositories/announcement_repository.dart';
import 'package:local_services_admin/features/colleges/data/repositories/college_repository.dart';
import 'package:local_services_admin/core/widgets/app_toaster.dart';
import 'package:local_services_admin/core/widgets/app_toast.dart';

class AnnouncementsPage extends ConsumerStatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  ConsumerState<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends ConsumerState<AnnouncementsPage> {
  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(announcementsStreamProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Announcements',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Broadcast messages and alerts to users across the platform',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddDialog(context),
                  icon: const Icon(Icons.campaign_outlined),
                  label: const Text('New Broadcast'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            announcementsAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => _buildAnnouncementCard(list[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 100),
          Icon(Icons.speaker_notes_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No active announcements', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Share important updates or alerts with your users.'),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement a) {
    Color typeColor;
    IconData typeIcon;
    switch (a.type) {
      case AnnouncementType.warning:
        typeColor = Colors.orange;
        typeIcon = Icons.warning_amber_rounded;
        break;
      case AnnouncementType.critical:
        typeColor = Colors.red;
        typeIcon = Icons.error_outline_rounded;
        break;
      case AnnouncementType.success:
        typeColor = Colors.green;
        typeIcon = Icons.check_circle_outline_rounded;
        break;
      default:
        typeColor = Colors.blue;
        typeIcon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: typeColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(typeIcon, color: typeColor, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 8),
                        if (a.collegeId != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('TARGETED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                          ),
                      ],
                    ),
                    Switch(
                      value: a.isActive,
                       onChanged: (v) {
                        ref.read(announcementRepositoryProvider).toggleActive(a.id, v);
                        AppToastManager.instance.show(
                          title: 'Broadcast Updated',
                          description: 'Message is now ${v ? 'active' : 'inactive'}.',
                        );
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(a.message, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      'Posted ${DateFormat('dd MMM, hh:mm a').format(a.createdAt)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: () => _deleteConfirm(a.id),
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _deleteConfirm(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Broadcast?'),
        content: const Text('This will remove the message from all user apps immediately.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(announcementRepositoryProvider).deleteAnnouncement(id);
              AppToastManager.instance.show(
                title: 'Broadcast Deleted',
                description: 'The message has been removed from all apps.',
                variant: AppToastVariant.destructive,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddAnnouncementDialog(),
    );
  }
}

class _AddAnnouncementDialog extends ConsumerStatefulWidget {
  const _AddAnnouncementDialog();

  @override
  ConsumerState<_AddAnnouncementDialog> createState() => _AddAnnouncementDialogState();
}

class _AddAnnouncementDialogState extends ConsumerState<_AddAnnouncementDialog> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  AnnouncementType _type = AnnouncementType.info;
  String? _selectedCollegeId;

  @override
  Widget build(BuildContext context) {
    final collegesAsync = ref.watch(collegesStreamProvider);

    return AlertDialog(
      title: const Text('Create New Broadcast'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g., Happy New Year!'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Message', hintText: 'The main content of your alert...'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AnnouncementType>(
              value: _type,
              items: AnnouncementType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
              onChanged: (v) => setState(() => _type = v!),
              decoration: const InputDecoration(labelText: 'Alert Type'),
            ),
            const SizedBox(height: 16),
            collegesAsync.when(
              data: (list) => DropdownButtonFormField<String?>(
                value: _selectedCollegeId,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Global (All Colleges)')),
                  ...list.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                ],
                onChanged: (v) => setState(() => _selectedCollegeId = v),
                decoration: const InputDecoration(labelText: 'Target Audience'),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isEmpty || _messageController.text.isEmpty) return;
            
            final a = Announcement(
              id: '',
              title: _titleController.text,
              message: _messageController.text,
              type: _type,
              collegeId: _selectedCollegeId,
              createdAt: DateTime.now(),
            );

            ref.read(announcementRepositoryProvider).addAnnouncement(a);
            AppToastManager.instance.show(
              title: 'Broadcast Live',
              description: 'Users will receive the alert shortly.',
            );
            Navigator.pop(context);
          },
          child: const Text('Broadcast Now'),
        ),
      ],
    );
  }
}
