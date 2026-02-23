import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:local_services_admin/features/orders/data/repositories/order_repository.dart';
import 'package:local_services_admin/features/orders/data/models/order_model.dart';

class RecentOrdersTable extends ConsumerWidget {
  const RecentOrdersTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersStreamProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const Icon(Icons.refresh_rounded, size: 18, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 24),
          ordersAsync.when(
            data: (orders) {
              if (orders.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: Text('No orders found yet', style: TextStyle(color: Colors.grey))),
                );
              }

              final displayOrders = orders.take(5).toList();

              return DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.transparent),
                horizontalMargin: 0,
                columnSpacing: 24,
                columns: [
                  _buildColumn('ORDER ID'),
                  _buildColumn('STORE'),
                  _buildColumn('AMOUNT'),
                  _buildColumn('STATUS'),
                  _buildColumn('DATE'),
                ],
                rows: displayOrders.map((o) => _buildRow(context, o)).toList(),
              );
            },
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
            error: (e, s) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }

  DataColumn _buildColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  DataRow _buildRow(BuildContext context, OrderModel order) {
    return DataRow(
      cells: [
        DataCell(Text('#${order.id.substring(0, 6).toUpperCase()}', 
          style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color))),
        DataCell(Text(order.storeName)),
        DataCell(Text('₹${order.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(_buildStatusBadge(order.status)),
        DataCell(Text(DateFormat('MMM dd, yyyy').format(order.createdAt), style: TextStyle(color: Colors.grey[500]))),
      ],
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color bg;
    Color text;
    
    switch (status) {
      case OrderStatus.delivered:
        bg = Colors.green.shade50;
        text = Colors.green;
        break;
      case OrderStatus.pending:
        bg = Colors.amber.shade50;
        text = Colors.amber.shade800;
        break;
      case OrderStatus.accepted:
        bg = Colors.blue.shade50;
        text = Colors.blue;
        break;
      case OrderStatus.cancelled:
        bg = Colors.red.shade50;
        text = Colors.red;
        break;
      default:
        bg = Colors.grey.shade100;
        text = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
