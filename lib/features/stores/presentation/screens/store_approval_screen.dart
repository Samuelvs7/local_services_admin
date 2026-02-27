import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/store_provider.dart';
import '../../data/models/store_model.dart';
import 'package:intl/intl.dart';
import 'package:local_services_admin/core/widgets/app_toaster.dart';
import 'package:local_services_admin/core/widgets/app_toast.dart';

class StoreApprovalScreen extends ConsumerWidget {
  const StoreApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(text: 'Pending'),
                Tab(text: 'Approved'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _PendingStoresTab(),
                _ApprovedStoresTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingStoresTab extends ConsumerWidget {
  const _PendingStoresTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingStoresAsync = ref.watch(pendingStoresProvider);

    return pendingStoresAsync.when(
      data: (stores) {
        if (stores.isEmpty) {
          return const Center(child: Text("No pending store approvals."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: stores.length,
          itemBuilder: (context, index) {
            final store = stores[index];
            return _StoreCard(
              store: store,
              isPending: true,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _ApprovedStoresTab extends ConsumerWidget {
  const _ApprovedStoresTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvedStoresAsync = ref.watch(approvedStoresProvider);

    return approvedStoresAsync.when(
      data: (stores) {
        if (stores.isEmpty) {
          return const Center(child: Text("No approved stores yet."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: stores.length,
          itemBuilder: (context, index) {
            final store = stores[index];
            return _StoreCard(
              store: store,
              isPending: false,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _StoreCard extends ConsumerWidget {
  final Store store;
  final bool isPending;

  const _StoreCard({required this.store, required this.isPending});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  child: Text(
                    store.name.isNotEmpty ? store.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Type: ${store.serviceType}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      Text(
                        'Created: ${DateFormat.yMMMd().format(store.createdAt)}',
                         style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (!isPending) ...[
                   // Active Toggle
                   Switch(
                     value: store.isActive,
                     onChanged: (val) {
                       ref.read(storeActionControllerProvider.notifier).toggleStoreActive(store.id, val);
                     },
                     activeThumbColor: Colors.green,
                   ),
                ]
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isPending) ...[
                  OutlinedButton(
                    onPressed: () => _showRejectDialog(context, ref, store.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text("Reject"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                       // Admin ID should be fetched from Auth Provider, but for MVP we mock or pass user id
                       // Assuming we have a user provider or similar. Using 'admin' for now.
                       ref.read(storeActionControllerProvider.notifier).approveStore(store.id, 'admin');
                       AppToastManager.instance.show(
                         title: 'Store Approved',
                         description: '${store.name} has been successfully onboarded.',
                       );
                    },
                     style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Approve"),
                  ),
                ] else ...[
                   // Suspend Button
                   TextButton.icon(
                     onPressed: () {
                        // Suspend checks
                          ref.read(storeActionControllerProvider.notifier).suspendStore(store.id, 'admin');
                          AppToastManager.instance.show(
                            title: 'Store Suspended',
                            description: '${store.name} is now hidden from users.',
                            variant: AppToastVariant.destructive,
                          );
                     },
                     icon: const Icon(Icons.block, size: 16, color: Colors.orange),
                     label: const Text("Suspend", style: TextStyle(color: Colors.orange)),
                   ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref, String storeId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reject Store"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: "Reason for rejection",
            hintText: "e.g., Incomplete documents",
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                 ref.read(storeActionControllerProvider.notifier).rejectStore(storeId, 'admin', reasonController.text.trim());
                 AppToastManager.instance.show(
                   title: 'Application Rejected',
                   description: 'Store request has been declined.',
                   variant: AppToastVariant.destructive,
                 );
                 Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Reject"),
          ),
        ],
      ),
    );
  }
}
