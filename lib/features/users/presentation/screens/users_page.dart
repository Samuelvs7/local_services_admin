import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:local_services_admin/features/users/data/models/user_model.dart';
import 'package:local_services_admin/features/users/data/repositories/user_repository.dart';
import 'package:local_services_admin/core/widgets/app_toaster.dart';
import 'package:local_services_admin/core/widgets/app_toast.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  String _searchQuery = '';
  String _collegeFilter = 'all';

  void _toggleBlock(String userId, bool isCurrentlyBlocked) {
    ref.read(userRepositoryProvider).toggleUserBlock(userId, !isCurrentlyBlocked);
    AppToastManager.instance.show(
      title: 'User Updated',
      description: 'Account has been ${!isCurrentlyBlocked ? 'blocked' : 'unblocked'} successfully.',
      variant: !isCurrentlyBlocked ? AppToastVariant.destructive : AppToastVariant.defaultVariant,
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.simpleCurrency(name: 'INR', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersStreamProvider);

    return usersAsync.when(
      data: (users) {
        final colleges = ['all', ...users.map((u) => u.collegeName ?? 'Other').toSet()];
        
        final filtered = users.where((u) {
          final query = _searchQuery.toLowerCase();
          final matchSearch = u.name.toLowerCase().contains(query) || 
                              (u.phone?.contains(query) ?? false) || 
                              u.email.toLowerCase().contains(query);
          final matchCollege = _collegeFilter == 'all' || u.collegeName == _collegeFilter;
          return matchSearch && matchCollege;
        }).toList();

        final totalSpent = users.fold<double>(0, (sum, u) => sum + u.totalSpent);
        final blockedCount = users.where((u) => u.isBlocked).length;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'User Management',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage students and platform users',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(height: 32),
                
                // 1. Stats Row
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Total Users', '${users.length}', Icons.people_rounded, Colors.blue)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildStatCard('Active Students', '${users.length - blockedCount}', Icons.how_to_reg_rounded, Colors.green)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildStatCard('Blocked Users', '$blockedCount', Icons.person_off_rounded, Colors.red)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildStatCard('Total Revenue', _formatCurrency(totalSpent), Icons.currency_rupee_rounded, Colors.orange)),
                  ],
                ),
                const SizedBox(height: 32),

            // 2. Filter Bar & Table
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20)],
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
                          width: 280,
                          height: 40,
                          decoration: BoxDecoration(color: Theme.of(context).inputDecorationTheme.fillColor, borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            decoration: const InputDecoration(
                              hintText: 'Name, phone, email...',
                              hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                              prefixIcon: Icon(Icons.search_rounded, color: Colors.grey, size: 18),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildFilterDropdown(_collegeFilter, colleges, (v) => setState(() => _collegeFilter = v!)),
                        const Spacer(),
                        Text('${filtered.length} users found', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  ),

                  // Table
                  DataTable(
                    columnSpacing: 24,
                    headingRowHeight: 50,
                    dataRowMaxHeight: 70,
                    headingRowColor: WidgetStateProperty.all(Theme.of(context).dividerColor.withValues(alpha: 0.05)),
                    columns: const [
                      DataColumn(label: _ColHeader('USER')),
                      DataColumn(label: _ColHeader('PHONE')),
                      DataColumn(label: _ColHeader('COLLEGE')),
                      DataColumn(label: _ColHeader('ORDERS')),
                      DataColumn(label: _ColHeader('SPENT')),
                      DataColumn(label: _ColHeader('STATUS')),
                      DataColumn(label: _ColHeader('ACTIONS')),
                    ],
                    rows: filtered.map((u) => DataRow(
                      cells: [
                        DataCell(Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(u.email, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                          ],
                        )),
                        DataCell(Text(u.phone ?? 'N/A', style: const TextStyle(fontFamily: 'monospace', fontSize: 11))),
                        DataCell(Text(u.collegeName ?? 'N/A', style: const TextStyle(fontSize: 12))),
                        DataCell(Text('${u.totalOrders}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                        DataCell(Text(_formatCurrency(u.totalSpent), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green))),
                        DataCell(_buildStatusBadge(u.isBlocked)),
                        DataCell(
                          ElevatedButton.icon(
                            onPressed: () => _showBlockConfirm(u),
                            icon: Icon(u.isBlocked ? Icons.check_circle_outline_rounded : Icons.block_flipped, size: 14),
                            label: Text(u.isBlocked ? 'UNBLOCK' : 'BLOCK', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: u.isBlocked ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                              foregroundColor: u.isBlocked ? Colors.green : Colors.red,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ),
                      ],
                      onSelectChanged: (selected) {
                        if (selected != null) _showUserDetails(u);
                      },
                    )).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  },
  loading: () => const Center(child: CircularProgressIndicator()),
  error: (e, s) => Center(child: Text('Error: $e')),
 );
}

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Theme.of(context).inputDecorationTheme.fillColor, borderRadius: BorderRadius.circular(10)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          style: const TextStyle(fontSize: 13, color: Colors.black),
          onChanged: onChanged,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i.toUpperCase()))).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isBlocked) {
    final color = isBlocked ? Colors.red : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(isBlocked ? 'BLOCKED' : 'ACTIVE', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showUserDetails(UserProfile user) {
     showDialog(
      context: context,
      builder: (context) => _UserDetailDialog(
        user: user,
        formatCurrency: _formatCurrency,
        onToggleBlock: () {
          Navigator.pop(context);
          _showBlockConfirm(user);
        },
      ),
    );
  }

  void _showBlockConfirm(UserProfile user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.isBlocked ? 'Unblock User?' : 'Block User?'),
        content: Text(
          user.isBlocked 
            ? 'Are you sure you want to unblock ${user.name}? They will regain platform access.' 
            : 'Are you sure you want to block ${user.name}? They will not be able to place orders.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _toggleBlock(user.uid, user.isBlocked);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: user.isBlocked ? Colors.green : Colors.red),
            child: Text(user.isBlocked ? 'Unblock' : 'Block User', style: const TextStyle(color: Colors.white)),
          ),
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
    return Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 0.5));
  }
}

class _UserDetailDialog extends StatelessWidget {
  final UserProfile user;
  final String Function(double) formatCurrency;
  final VoidCallback onToggleBlock;

  const _UserDetailDialog({required this.user, required this.formatCurrency, required this.onToggleBlock});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('User Details', style: TextStyle(fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  child: Text(user.name.substring(0, 1).toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(user.email, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
                const Spacer(),
                _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 32),
            _buildStatGrid(context),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onToggleBlock,
                style: ElevatedButton.styleFrom(
                  backgroundColor: user.isBlocked ? Colors.green : Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(user.isBlocked ? 'Unblock User' : 'Block User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final color = user.isBlocked ? Colors.red : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(user.isBlocked ? 'Blocked' : 'Active', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatGrid(BuildContext context) {
    final stats = [
      ['Phone', user.phone ?? 'N/A'],
      ['College', user.collegeName ?? 'N/A'],
      ['Joined', DateFormat('dd MMM yyyy').format(user.createdAt)],
      ['Last Active', DateFormat('dd MMM HH:mm').format(user.lastActive)],
      ['Total Orders', user.totalOrders.toString()],
      ['Total Spent', formatCurrency(user.totalSpent)],
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: stats.map((s) => Container(
        width: 218,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Theme.of(context).inputDecorationTheme.fillColor, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s[0].toUpperCase(), style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(s[1], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      )).toList(),
    );
  }
}
