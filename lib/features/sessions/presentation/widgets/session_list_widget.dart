import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/session_provider.dart';
import 'add_edit_session_dialog.dart';

class SessionListWidget extends ConsumerWidget {
  final String collegeId;

  const SessionListWidget({super.key, required this.collegeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionsStreamProvider(collegeId));

    return sessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('No sessions found.'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddEditSessionDialog(collegeId: collegeId),
                    );
                  },
                  child: const Text('Add First Session'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddEditSessionDialog(collegeId: collegeId),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Session'),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: sessions.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  final dateFormat = DateFormat('MMM yyyy');
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(
                        Icons.calendar_today,
                        color: session.isActive ? Colors.green : Colors.grey,
                      ),
                      title: Row(
                        children: [
                          Text(session.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          if (session.isActive)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'ACTIVE',
                                style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text('${dateFormat.format(session.startDate)} - ${dateFormat.format(session.endDate)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AddEditSessionDialog(collegeId: collegeId, session: session),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Delete Session?'),
                                  content: const Text('Are you sure you want to delete this session?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                ref.read(sessionActionProvider.notifier).deleteSession(collegeId, session.id);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
