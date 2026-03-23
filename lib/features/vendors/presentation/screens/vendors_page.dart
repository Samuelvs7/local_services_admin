import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:local_services_admin/features/vendors/data/models/vendor_model.dart';
import 'package:local_services_admin/features/vendors/data/repositories/vendor_repository.dart';
import 'package:local_services_admin/core/widgets/app_toaster.dart';
import 'package:local_services_admin/core/widgets/app_toast.dart';

class VendorsPage extends ConsumerStatefulWidget {
  const VendorsPage({super.key});

  @override
  ConsumerState<VendorsPage> createState() => _VendorsPageState();
}

class _VendorsPageState extends ConsumerState<VendorsPage> {
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all', 'approved', 'pending'

  void _approveVendor(String vendorId, String vendorName) {
    ref.read(vendorRepositoryProvider).approveVendor(vendorId);
    AppToastManager.instance.show(
      title: 'Vendor Approved ✅',
      description: '$vendorName has been approved and can now access the app.',
      variant: AppToastVariant.defaultVariant,
    );
  }

  void _rejectVendor(String vendorId, String vendorName) {
    ref.read(vendorRepositoryProvider).rejectVendor(vendorId);
    AppToastManager.instance.show(
      title: 'Vendor Rejected',
      description: '$vendorName has been rejected.',
      variant: AppToastVariant.destructive,
    );
  }

  void _deleteVendor(String vendorId, String vendorName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vendor?'),
        content: Text(
            'Are you sure you want to permanently delete "$vendorName"? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(vendorRepositoryProvider).deleteVendor(vendorId);
              AppToastManager.instance.show(
                title: 'Vendor Deleted',
                description: '$vendorName has been removed permanently.',
                variant: AppToastVariant.destructive,
              );
              Navigator.pop(context);
            },
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendorsAsync = ref.watch(vendorsStreamProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: vendorsAsync.when(
        data: (vendors) {
          final filtered = vendors.where((v) {
            final query = _searchQuery.toLowerCase();
            final matchSearch = v.name.toLowerCase().contains(query) ||
                v.email.toLowerCase().contains(query) ||
                (v.storeName?.toLowerCase().contains(query) ?? false) ||
                v.phone.contains(query);
            final matchStatus = _statusFilter == 'all' ||
                (_statusFilter == 'approved' && v.isApproved) ||
                (_statusFilter == 'pending' && !v.isApproved);
            return matchSearch && matchStatus;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Vendor Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Approve, reject, or manage vendor accounts',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(height: 32),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                        child: _buildCountBox(
                            'Total Vendors',
                            '${vendors.length}',
                            Icons.people_rounded,
                            Colors.blue)),
                    const SizedBox(width: 24),
                    Expanded(
                        child: _buildCountBox(
                            'Pending Approval',
                            '${vendors.where((v) => !v.isApproved).length}',
                            Icons.hourglass_top_rounded,
                            Colors.orange)),
                    const SizedBox(width: 24),
                    Expanded(
                        child: _buildCountBox(
                            'Approved',
                            '${vendors.where((v) => v.isApproved).length}',
                            Icons.check_circle_rounded,
                            Colors.green)),
                    const SizedBox(width: 24),
                    Expanded(
                        child: _buildCountBox(
                            'Online Now',
                            '${vendors.where((v) => v.storeOpen || v.isOnline).length}',
                            Icons.circle,
                            Colors.teal)),
                  ],
                ),
                const SizedBox(height: 32),

                // Table Card
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Filters
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 250,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .inputDecorationTheme
                                      .fillColor,
                                  borderRadius: BorderRadius.circular(10)),
                              child: TextField(
                                onChanged: (v) =>
                                    setState(() => _searchQuery = v),
                                decoration: const InputDecoration(
                                  hintText: 'Search vendors...',
                                  hintStyle: TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                  prefixIcon: Icon(Icons.search_rounded,
                                      color: Colors.grey, size: 18),
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            _buildFilterDropdown(
                                _statusFilter,
                                ['all', 'pending', 'approved'],
                                (v) =>
                                    setState(() => _statusFilter = v!)),
                            const Spacer(),
                            Text('${filtered.length} vendors',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[500])),
                          ],
                        ),
                      ),

                      // Data Table
                      filtered.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(60),
                              child: Column(
                                children: [
                                  Icon(Icons.people_outline_rounded,
                                      size: 48, color: Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  Text('No vendors found',
                                      style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 16)),
                                ],
                              ),
                            )
                          : DataTable(
                              columnSpacing: 24,
                              headingRowHeight: 50,
                              dataRowMaxHeight: 70,
                              headingRowColor: WidgetStateProperty.all(
                                  Theme.of(context)
                                      .dividerColor
                                      .withValues(alpha: 0.05)),
                              columns: const [
                                DataColumn(
                                    label: _ColHeader('VENDOR')),
                                DataColumn(
                                    label: _ColHeader('STORE')),
                                DataColumn(
                                    label: _ColHeader('ROLE')),
                                DataColumn(
                                    label: _ColHeader('REGISTERED')),
                                DataColumn(
                                    label: _ColHeader('STATUS')),
                                DataColumn(
                                    label: _ColHeader('ACTIONS')),
                              ],
                              rows: filtered.map((v) {
                                return DataRow(cells: [
                                  // Vendor info
                                  DataCell(Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(v.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13)),
                                      Text(v.email,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[500])),
                                    ],
                                  )),
                                  // Store name
                                  DataCell(Text(
                                      v.storeName ?? '—',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]))),
                                  // Role badge
                                  DataCell(_buildRoleBadge(v.role)),
                                  // Registered date
                                  DataCell(Text(
                                    v.createdAt != null
                                        ? DateFormat('dd MMM yyyy')
                                            .format(v.createdAt!)
                                        : '—',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                        fontFamily: 'monospace'),
                                  )),
                                  // Status
                                  DataCell(_buildStatusBadge(v.isApproved)),
                                  // Actions
                                  DataCell(Row(
                                    children: [
                                      if (!v.isApproved)
                                        IconButton(
                                          icon: const Icon(
                                              Icons
                                                  .check_circle_outline_rounded,
                                              size: 18),
                                          onPressed: () => _approveVendor(
                                              v.id, v.name),
                                          color: Colors.green,
                                          tooltip: 'Approve',
                                        ),
                                      if (v.isApproved)
                                        IconButton(
                                          icon: const Icon(
                                              Icons.block_rounded,
                                              size: 18),
                                          onPressed: () => _rejectVendor(
                                              v.id, v.name),
                                          color: Colors.orange,
                                          tooltip: 'Revoke Approval',
                                        ),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18),
                                        onPressed: () => _deleteVendor(
                                            v.id, v.name),
                                        color: Colors.red,
                                        tooltip: 'Delete',
                                      ),
                                    ],
                                  )),
                                ]);
                              }).toList(),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildCountBox(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
      String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: Theme.of(context).inputDecorationTheme.fillColor,
          borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          style: const TextStyle(fontSize: 13, color: Colors.black),
          onChanged: onChanged,
          items: items
              .map((i) => DropdownMenuItem(
                  value: i, child: Text(i.toUpperCase())))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color color;
    switch (role) {
      case 'vendor':
        color = const Color(0xFFFF6B00);
        break;
      case 'delivery':
        color = Colors.blue;
        break;
      case 'both':
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Text(role.toUpperCase(),
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusBadge(bool isApproved) {
    final color = isApproved ? Colors.green : Colors.orange;
    final label = isApproved ? 'APPROVED' : 'PENDING';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String label;
  const _ColHeader(this.label);
  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
            letterSpacing: 0.5));
  }
}
