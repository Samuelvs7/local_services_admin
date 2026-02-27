import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:local_services_admin/features/admins/data/models/admin_user_model.dart';
import 'package:local_services_admin/features/admins/data/repositories/admin_repository.dart';
import 'package:local_services_admin/features/dashboard/presentation/widgets/dashboard_stats_card.dart';
import 'package:local_services_admin/core/widgets/app_toaster.dart';
import 'package:local_services_admin/core/widgets/app_toast.dart';

class AdminsPage extends ConsumerWidget {
  const AdminsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminsAsync = ref.watch(adminsStreamProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: adminsAsync.when(
        data: (admins) {
          final superAdmins = admins.where((a) => a.role == AdminRole.superAdmin).length;
          final moderators = admins.where((a) => a.role == AdminRole.moderator).length;
          final financeAdmins = admins.where((a) => a.role == AdminRole.financeAdmin).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header
                Text(
                  'Admin Role Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage admin accounts and role-based permissions',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(height: 32),

                // 2. Stat Cards
                Row(
                  children: [
                    Expanded(
                      child: DashboardStatsCard(
                        title: 'Super Admins',
                        value: '$superAdmins',
                        icon: Icons.workspace_premium_rounded,
                        color: Colors.red,
                        growth: 'Full Access',
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: DashboardStatsCard(
                        title: 'Moderators',
                        value: '$moderators',
                        icon: Icons.remove_red_eye_rounded,
                        color: const Color(0xFFFF6B00),
                        growth: 'Stores, Users, Orders',
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: DashboardStatsCard(
                        title: 'Finance Admins',
                        value: '$financeAdmins',
                        icon: Icons.payments_rounded,
                        color: Colors.green,
                        growth: 'Finance & Reports',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // 3. Permission Matrix
                _buildPermissionMatrix(context),
                const SizedBox(height: 32),

                // 4. Admin Accounts Table
                _buildAdminAccountsTable(context, ref, admins),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildPermissionMatrix(BuildContext context) {
    final modules = [
      ['Dashboard', true, true, true],
      ['Colleges', true, false, false],
      ['Store Approval', true, true, false],
      ['User Management', true, true, false],
      ['Orders', true, true, false],
      ['Finance', true, false, true],
      ['Notifications', true, true, false],
      ['Settings', true, false, false],
      ['Admin Roles', true, false, false],
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Permission Matrix',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 24),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
                ),
                children: [
                   _buildMatrixHeader('Module', alignment: Alignment.centerLeft),
                   _buildMatrixHeader('Super Admin'),
                   _buildMatrixHeader('Moderator'),
                   _buildMatrixHeader('Finance Admin'),
                ],
              ),
              ...modules.map((m) => TableRow(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.05))),
                ),
                children: [
                   Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(m[0] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ),
                  _buildCheck(m[1] as bool),
                  _buildCheck(m[2] as bool),
                  _buildCheck(m[3] as bool),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixHeader(String label, {Alignment alignment = Alignment.center}) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildCheck(bool isEnabled) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: isEnabled 
          ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16)
          : Text('—', style: TextStyle(color: Colors.grey.withValues(alpha: 0.3))),
    );
  }

  Widget _buildAdminAccountsTable(BuildContext context, WidgetRef ref, List<AdminUser> users) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Admin Accounts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddAdminDialog(context, ref),
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text('Add Admin', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          DataTable(
            headingRowColor: WidgetStateProperty.all(Theme.of(context).dividerColor.withValues(alpha: 0.05)),
            dataRowMaxHeight: 65,
            columns: const [
              DataColumn(label: Text('ADMIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
              DataColumn(label: Text('ROLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
              DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
              DataColumn(label: Text('LAST LOGIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
              DataColumn(label: Text('SINCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
              DataColumn(label: Text('ACTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
            ],
            rows: users.map((u) => DataRow(
              cells: [
                DataCell(Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFFF6B00).withValues(alpha: 0.1),
                      child: Text(u.name[0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFFF6B00))),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(u.email, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      ],
                    ),
                  ],
                )),
                DataCell(_buildRoleBadge(u.role)),
                DataCell(
                  Switch(
                    value: u.isActive,
                    onChanged: (v) {
                      ref.read(adminRepositoryProvider).toggleAdminStatus(u.id, v);
                      AppToastManager.instance.show(
                        title: 'Status Updated',
                        description: '${u.name} is now ${v ? 'active' : 'inactive'}.',
                      );
                    },
                    activeThumbColor: Colors.green,
                  ),
                ),
                DataCell(Text(DateFormat('dd MMM, HH:mm').format(u.lastLogin), style: TextStyle(color: Colors.grey[600], fontSize: 12))),
                DataCell(Text(DateFormat('MMM yyyy').format(u.createdAt), style: TextStyle(color: Colors.grey[500], fontSize: 12))),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => _showDeleteConfirm(context, ref, u),
                  ),
                ),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(AdminRole role) {
    Color color;
    String label;
    
    switch (role) {
      case AdminRole.superAdmin:
        color = Colors.red;
        label = 'Super Admin';
        break;
      case AdminRole.moderator:
        color = const Color(0xFFFF6B00);
        label = 'Moderator';
        break;
      case AdminRole.financeAdmin:
        color = Colors.green;
        label = 'Finance Admin';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, AdminUser admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Admin?'),
        content: Text('Are you sure you want to remove ${admin.name}? This will revoke all their access.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(adminRepositoryProvider).deleteAdmin(admin.id);
              AppToastManager.instance.show(
                title: 'Admin Removed',
                description: '${admin.name} has been deleted.',
                variant: AppToastVariant.destructive,
              );
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddAdminDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    AdminRole selectedRole = AdminRole.moderator;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Admin'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 16),
              DropdownButtonFormField<AdminRole>(
                initialValue: selectedRole,
                items: AdminRole.values.map((r) => DropdownMenuItem(value: r, child: Text(r.name.toUpperCase()))).toList(),
                onChanged: (v) => setDialogState(() => selectedRole = v!),
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final admin = AdminUser(
                  id: '',
                  name: nameController.text,
                  email: emailController.text,
                  role: selectedRole,
                  isActive: true,
                  lastLogin: DateTime.now(),
                  createdAt: DateTime.now(),
                );
                ref.read(adminRepositoryProvider).addAdmin(admin);
                AppToastManager.instance.show(
                  title: 'Admin Added',
                  description: '${admin.name} has been invited.',
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
