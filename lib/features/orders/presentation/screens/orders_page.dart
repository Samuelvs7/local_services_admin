import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:local_services_admin/features/orders/data/models/order_model.dart';
import 'package:local_services_admin/features/orders/data/repositories/order_repository.dart';
import 'package:local_services_admin/core/widgets/app_toaster.dart';
import 'package:local_services_admin/core/widgets/app_toast.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _serviceFilter = 'all';

  void _cancelOrder(String id) {
    ref.read(orderRepositoryProvider).cancelOrder(id, 'Cancelled by admin');
    AppToastManager.instance.show(
      title: 'Order Cancelled',
      description: 'Order #$id has been successfully voided.',
      variant: AppToastVariant.destructive,
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.simpleCurrency(name: 'INR', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersStreamProvider);

    return ordersAsync.when(
      data: (orders) {
        final filteredOrders = orders.where((o) {
          final query = _searchQuery.toLowerCase();
          final matchesSearch = o.id.toLowerCase().contains(query) || 
                              o.userName.toLowerCase().contains(query) || 
                              o.storeName.toLowerCase().contains(query);
          
          final matchesStatus = _statusFilter == 'all' || o.status.name == _statusFilter;
          final matchesService = _serviceFilter == 'all' || o.serviceType == _serviceFilter;
          
          return matchesSearch && matchesStatus && matchesService;
        }).toList();

        final activeCount = orders.where((o) => [OrderStatus.accepted, OrderStatus.preparing, OrderStatus.out_for_delivery].contains(o.status)).length;
        final deliveredCount = orders.where((o) => o.status == OrderStatus.delivered).length;
        final cancelledCount = orders.where((o) => o.status == OrderStatus.cancelled).length;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // 1. Header
            Text(
              'Order Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const SizedBox(height: 4),
            Text(
              'Monitor and manage all platform orders',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),

            // 2. Stats Grid
            Row(
              children: [
                Expanded(child: _buildStatBox('Total Orders', '${orders.length}', Icons.shopping_bag_rounded, Colors.blue)),
                const SizedBox(width: 24),
                Expanded(child: _buildStatBox('Active Orders', '$activeCount', Icons.local_shipping_rounded, Colors.orange)),
                const SizedBox(width: 24),
                Expanded(child: _buildStatBox('Delivered', '$deliveredCount', Icons.check_circle_rounded, Colors.green)),
                const SizedBox(width: 24),
                Expanded(child: _buildStatBox('Cancelled', '$cancelledCount', Icons.cancel_rounded, Colors.red)),
              ],
            ),
            const SizedBox(height: 32),

            // 3. Filters & Table Card
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4)),
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
                          decoration: BoxDecoration(color: Theme.of(context).inputDecorationTheme.fillColor, borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            onChanged: (v) => setState(() => _searchQuery = v),
                            decoration: const InputDecoration(
                              hintText: 'Order ID, user, store...',
                              hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                              prefixIcon: Icon(Icons.search_rounded, color: Colors.grey, size: 18),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        _buildDropdown('Status', _statusFilter, ['all', ...OrderStatus.values.map((v) => v.name)], (v) => setState(() => _statusFilter = v!)),
                        const SizedBox(width: 16),
                        _buildDropdown('Service', _serviceFilter, ['all', 'food', 'bike', 'parcel'], (v) => setState(() => _serviceFilter = v!)),
                        const Spacer(),
                        Text('${filteredOrders.length} orders', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
                      DataColumn(label: _ColHeader('ORDER ID')),
                      DataColumn(label: _ColHeader('CUSTOMER')),
                      DataColumn(label: _ColHeader('STORE')),
                      DataColumn(label: _ColHeader('TYPE')),
                      DataColumn(label: _ColHeader('AMOUNT')),
                      DataColumn(label: _ColHeader('STATUS')),
                      DataColumn(label: _ColHeader('ACTIONS')),
                    ],
                    rows: filteredOrders.map((o) => DataRow(
                      cells: [
                        DataCell(Text(o.id, style: TextStyle(fontFamily: 'monospace', color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12))),
                        DataCell(Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(o.collegeName, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                          ],
                        )),
                        DataCell(Text(o.storeName, style: const TextStyle(fontSize: 13))),
                        DataCell(_buildTypeBadge(o.serviceType)),
                        DataCell(Text(_formatCurrency(o.totalAmount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                        DataCell(_buildStatusBadge(o.status)),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility_outlined, size: 18),
                              onPressed: () => _showOrderDetail(o),
                              color: Colors.blueGrey,
                            ),
                            if (![OrderStatus.delivered, OrderStatus.cancelled].contains(o.status))
                              IconButton(
                                icon: const Icon(Icons.cancel_outlined, size: 18),
                                onPressed: () => _showCancelConfirm(o.id),
                                color: Colors.redAccent.withValues(alpha: 0.7),
                              ),
                          ],
                        )),
                      ],
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

  Widget _buildStatBox(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2)),
        ],
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

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
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

  Widget _buildTypeBadge(String type) {
     Color color = Theme.of(context).colorScheme.primary;
     if (type == 'bike') color = Colors.blue;
     if (type == 'parcel') color = Colors.purple;
     
     return Container(
       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
       child: Text(type.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
     );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.delivered: color = Colors.green; break;
      case OrderStatus.pending: color = Colors.amber; break;
      case OrderStatus.cancelled: color = Colors.red; break;
      default: color = Colors.blue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showOrderDetail(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => _OrderDetailDialog(order: order, onCancel: _cancelOrder, formatCurrency: _formatCurrency, statusBadge: _buildStatusBadge, typeBadge: _buildTypeBadge),
    );
  }

  void _showCancelConfirm(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          ElevatedButton(
            onPressed: () {
              _cancelOrder(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
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

class _OrderDetailDialog extends StatelessWidget {
  final OrderModel order;
  final Function(String) onCancel;
  final String Function(double) formatCurrency;
  final Widget Function(OrderStatus) statusBadge;
  final Widget Function(String) typeBadge;

  const _OrderDetailDialog({required this.order, required this.onCancel, required this.formatCurrency, required this.statusBadge, required this.typeBadge});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Order ${order.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   statusBadge(order.status),
                   const SizedBox(width: 12),
                   typeBadge(order.serviceType),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoGrid(context),
              const SizedBox(height: 24),
              const Text('ITEMS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
              const SizedBox(height: 12),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Theme.of(context).dividerColor.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.name} × ${item.quantity}', style: const TextStyle(fontSize: 13)),
                      Text(formatCurrency(item.price * item.quantity), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 24),
              _buildTotalSummary(context),
              if (order.cancellationReason != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.05), border: Border.all(color: Colors.red.withValues(alpha: 0.1)), borderRadius: BorderRadius.circular(10)),
                  child: Text('Cancelled: ${order.cancellationReason}', style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (![OrderStatus.delivered, OrderStatus.cancelled].contains(order.status))
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                onCancel(order.id);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Cancel Order', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoGrid(BuildContext context) {
    final info = [
      ['Customer', order.userName],
      ['Store', order.storeName],
      ['College', order.collegeName],
      ['Address', order.deliveryAddress],
      ['Placed At', DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)],
      ['Updated At', DateFormat('dd/MM/yyyy HH:mm').format(order.updatedAt)],
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: info.map((i) => Container(
        width: 270,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Theme.of(context).inputDecorationTheme.fillColor, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(i[0].toUpperCase(), style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(i[1], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildTotalSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _summaryRow('Subtotal', formatCurrency(order.totalAmount - order.deliveryFee - order.platformFee)),
          const SizedBox(height: 8),
          _summaryRow('Delivery Fee', formatCurrency(order.deliveryFee)),
          const SizedBox(height: 8),
          _summaryRow('Platform Fee', formatCurrency(order.platformFee), isWarning: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white10),
          ),
          _summaryRow('Total', formatCurrency(order.totalAmount), isBold: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isWarning = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        Text(
          value, 
          style: TextStyle(
            color: isWarning ? Colors.amber : Colors.white, 
            fontSize: isBold ? 16 : 13, 
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500
          )
        ),
      ],
    );
  }
}
