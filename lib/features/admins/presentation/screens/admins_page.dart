import 'package:flutter/material.dart';
import 'package:local_services_admin/features/admins/data/models/admin_user_model.dart';
import 'package:local_services_admin/features/dashboard/presentation/widgets/dashboard_stats_card.dart';

class AdminsPage extends StatelessWidget {
  const AdminsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data to match React counterpart
    final mockAdminUsers = [
      AdminUser(
        id: '1',
        name: 'Suresh Babu',
        email: 'suresh@nexsus-admin.in',
        role: AdminRole.super_admin,
        isActive: true,
        lastLogin: DateTime.now().subtract(const Duration(minutes: 5)),
        createdAt: 'Oct 2023',
      ),
      AdminUser(
        id: '2',
        name: 'Samuel Velicharla',
        email: 'samuel@nexsus-admin.in',
        role: AdminRole.moderator,
        isActive: true,
        lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
        createdAt: 'Nov 2023',
      ),
      AdminUser(
        id: '3',
        name: 'Sujya Naik',
        email: 'sujya@nexsus-admin.in',
        role: AdminRole.finance_admin,
        isActive: false,
        lastLogin: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: 'Jan 2024',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header
            const Text(
              'Admin Role Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A2D3E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage admin accounts and role-based permissions',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 32),

            // 2. Stat Cards
            Row(
              children: [
                Expanded(
                  child: DashboardStatsCard(
                    title: 'Super Admins',
                    value: '1',
                    icon: Icons.workspace_premium_rounded,
                    color: Colors.red,
                    growth: 'Full Access',
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: DashboardStatsCard(
                    title: 'Moderators',
                    value: '1',
                    icon: Icons.remove_red_eye_rounded,
                    color: const Color(0xFFFF6B00),
                    growth: 'Stores, Users, Orders',
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: DashboardStatsCard(
                    title: 'Finance Admins',
                    value: '1',
                    icon: Icons.payments_rounded,
                    color: Colors.green,
                    growth: 'Finance & Reports',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 3. Permission Matrix
            _buildPermissionMatrix(),
            const SizedBox(height: 32),

            // 4. Admin Accounts Table
            _buildAdminAccountsTable(mockAdminUsers),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionMatrix() {
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Permission Matrix',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A2D3E),
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
                  border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
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
                  border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.05))),
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
          : Text('—', style: TextStyle(color: Colors.grey.withOpacity(0.3))),
    );
  }

  Widget _buildAdminAccountsTable(List<AdminUser> users) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                const Text(
                  'Admin Accounts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A2D3E),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Admin'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF9F9FA)),
            dataRowMaxHeight: 65,
            columns: const [
              DataColumn(label: Text('ADMIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
              DataColumn(label: Text('ROLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
              DataColumn(label: Text('STATUS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
              DataColumn(label: Text('LAST LOGIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
              DataColumn(label: Text('SINCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
            ],
            rows: users.map((u) => DataRow(
              cells: [
                DataCell(Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFFF6B00).withOpacity(0.1),
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
                DataCell(_buildStatusBadge(u.isActive)),
                DataCell(Text(_formatDate(u.lastLogin), style: TextStyle(color: Colors.grey[600], fontSize: 12))),
                DataCell(Text(u.createdAt, style: TextStyle(color: Colors.grey[500], fontSize: 12))),
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
      case AdminRole.super_admin:
        color = Colors.red;
        label = 'Super Admin';
        break;
      case AdminRole.moderator:
        color = const Color(0xFFFF6B00);
        label = 'Moderator';
        break;
      case AdminRole.finance_admin:
        color = Colors.green;
        label = 'Finance Admin';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    final color = isActive ? Colors.green : Colors.red;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          isActive ? 'Active' : 'Inactive',
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }
}
