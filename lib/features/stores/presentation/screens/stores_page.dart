import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:local_services_admin/features/stores/data/models/store_model.dart';
import 'package:local_services_admin/features/stores/data/models/store_audit_log_model.dart';
import 'package:local_services_admin/features/stores/data/repositories/store_repository.dart';
import 'package:local_services_admin/features/auth/presentation/providers/auth_provider.dart';
import 'package:local_services_admin/features/stores/data/repositories/menu_repository.dart';
import 'package:local_services_admin/features/orders/data/repositories/order_repository.dart';
import 'package:local_services_admin/features/orders/data/models/order_model.dart';
import 'package:local_services_admin/features/stores/data/models/product_model.dart';
import 'package:local_services_admin/core/widgets/app_toaster.dart';
import 'package:local_services_admin/core/widgets/app_toast.dart';

class StoresPage extends ConsumerStatefulWidget {
  const StoresPage({super.key});

  @override
  ConsumerState<StoresPage> createState() => _StoresPageState();
}

class _StoresPageState extends ConsumerState<StoresPage> {
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _serviceFilter = 'all';

  void _updateStatus(String storeId, StoreStatus newStatus, {String? reason}) {
    final authState = ref.read(authProvider);
    String adminId = 'unknown';
    if (authState is AuthSuccess) {
      adminId = authState.user.uid;
    }

    if (newStatus == StoreStatus.approved) {
      ref.read(storeRepositoryProvider).approveStore(storeId, adminId);
    } else if (newStatus == StoreStatus.rejected) {
      ref.read(storeRepositoryProvider).rejectStore(storeId, adminId, reason ?? 'No reason provided');
    } else if (newStatus == StoreStatus.suspended) {
      ref.read(storeRepositoryProvider).suspendStore(storeId, adminId);
    }

    AppToastManager.instance.show(
      title: 'Store Status Updated',
      description: 'Store has been moved to ${newStatus.name.toUpperCase()}.',
      variant: (newStatus == StoreStatus.rejected || newStatus == StoreStatus.suspended) 
        ? AppToastVariant.destructive 
        : AppToastVariant.defaultVariant,
    );
  }

  @override
  Widget build(BuildContext context) {
    final storesAsync = ref.watch(storesStreamProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: storesAsync.when(
        data: (list) {
          final filtered = list.where((s) {
            final query = _searchQuery.toLowerCase();
            final matchSearch = s.name.toLowerCase().contains(query) || 
                                s.ownerName.toLowerCase().contains(query) || 
                                s.phone.contains(query);
            final matchStatus = _statusFilter == 'all' || s.status.name == _statusFilter;
            final matchService = _serviceFilter == 'all' || s.serviceType == _serviceFilter;
            return matchSearch && matchStatus && matchService;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Store Approval System',
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold, 
                    color: Theme.of(context).textTheme.bodyLarge?.color
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Review and manage vendor/store applications',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(height: 32),

                // 1. Stats Row
                Row(
                  children: [
                    Expanded(child: _buildCountBox('Pending Review', '${list.where((s) => s.status == StoreStatus.pending).length}', Icons.history_rounded, Colors.orange)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildCountBox('Approved Stores', '${list.where((s) => s.status == StoreStatus.approved).length}', Icons.check_circle_rounded, Colors.green)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildCountBox('Rejected', '${list.where((s) => s.status == StoreStatus.rejected).length}', Icons.cancel_rounded, Colors.red)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildCountBox('Suspended', '${list.where((s) => s.status == StoreStatus.suspended).length}', Icons.warning_rounded, Colors.amber)),
                  ],
                ),
                const SizedBox(height: 32),

                // 2. Filters & Table
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                                  hintText: 'Search stores...',
                                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey, size: 18),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            _buildFilterDropdown(_statusFilter, ['all', 'pending', 'approved', 'rejected', 'suspended'], (v) => setState(() => _statusFilter = v!)),
                            const SizedBox(width: 16),
                            _buildFilterDropdown(_serviceFilter, ['all', 'food', 'bike', 'parcel'], (v) => setState(() => _serviceFilter = v!)),
                            const Spacer(),
                            Text('${filtered.length} stores', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          ],
                        ),
                      ),
                      DataTable(
                        columnSpacing: 24,
                        headingRowHeight: 50,
                        dataRowMaxHeight: 70,
                        headingRowColor: WidgetStateProperty.all(Theme.of(context).dividerColor.withValues(alpha: 0.05)),
                        columns: const [
                          DataColumn(label: _ColHeader('STORE')),
                          DataColumn(label: _ColHeader('SERVICE')),
                          DataColumn(label: _ColHeader('COLLEGE')),
                          DataColumn(label: _ColHeader('PHONE')),
                          DataColumn(label: _ColHeader('STATUS')),
                          DataColumn(label: _ColHeader('ACTIONS')),
                        ],
                        rows: filtered.map((s) => DataRow(
                          cells: [
                            DataCell(Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(s.ownerName, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                              ],
                            )),
                            DataCell(_buildTypeBadge(s.serviceType)),
                            DataCell(Text(s.collegeName, style: TextStyle(fontSize: 12, color: Colors.grey[500]))),
                            DataCell(Text(s.phone, style: const TextStyle(fontFamily: 'monospace', fontSize: 11))),
                            DataCell(_buildStatusBadge(s.status)),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, size: 18),
                                  onPressed: () => _showDetail(s),
                                  color: Colors.blueGrey,
                                ),
                                if (s.status == StoreStatus.pending || s.status == StoreStatus.suspended)
                                  IconButton(
                                    icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                                    onPressed: () => _updateStatus(s.id, StoreStatus.approved),
                                    color: Colors.green,
                                  ),
                                if (s.status == StoreStatus.pending)
                                  IconButton(
                                    icon: const Icon(Icons.cancel_outlined, size: 18),
                                    onPressed: () => _showReasonDialog(s, StoreStatus.rejected),
                                    color: Colors.red,
                                  ),
                                if (s.status == StoreStatus.approved)
                                  IconButton(
                                    icon: const Icon(Icons.block_flipped, size: 18),
                                    onPressed: () => _showReasonDialog(s, StoreStatus.suspended),
                                    color: Colors.orange,
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }


  Widget _buildCountBox(String title, String value, IconData icon, Color color) {
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

  Widget _buildTypeBadge(String type) {
    Color color = const Color(0xFFFF6B00);
    if (type == 'bike') color = Colors.blue;
    if (type == 'parcel') color = Colors.purple;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(type.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatusBadge(StoreStatus status) {
    Color color;
    switch (status) {
      case StoreStatus.approved: color = Colors.green; break;
      case StoreStatus.pending: color = Colors.orange; break;
      case StoreStatus.rejected: color = Colors.red; break;
      case StoreStatus.suspended: color = Colors.amber; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  void _showDetail(Store store) {
    showDialog(
      context: context,
      builder: (context) => _StoreDetailDialog(
        store: store, 
        auditLogs: const [], // Providing empty list for now
        onAction: (newStatus) {
           if (newStatus == StoreStatus.rejected || newStatus == StoreStatus.suspended) {
             _showReasonDialog(store, newStatus);
           } else {
             _updateStatus(store.id, newStatus);
           }
        },
      ),
    );
  }

  void _showReasonDialog(Store store, StoreStatus targetStatus) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${targetStatus.name.toUpperCase()} Store: ${store.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Please provide a reason for this action:', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Incomplete documentation',
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              _updateStatus(store.id, targetStatus, reason: controller.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: targetStatus == StoreStatus.rejected ? Colors.red : Colors.orange),
            child: Text(targetStatus == StoreStatus.rejected ? 'Reject' : 'Suspend', style: const TextStyle(color: Colors.white)),
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


class _StoreDetailDialog extends ConsumerStatefulWidget {
  final Store store;
  final List<StoreAuditLog> auditLogs; // Keeping for now, but should be a provider later
  final Function(StoreStatus) onAction;

  const _StoreDetailDialog({required this.store, required this.auditLogs, required this.onAction});

  @override
  ConsumerState<_StoreDetailDialog> createState() => _StoreDetailDialogState();
}

class _StoreDetailDialogState extends ConsumerState<_StoreDetailDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.store.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text('Store ID: ${widget.store.id}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
          ],
        ),
      ),
      content: SizedBox(
        width: 850,
        height: 600,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(text: 'PROFILE'),
                Tab(text: 'MENU / PRODUCTS'),
                Tab(text: 'PERFORMANCE'),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProfileTab(),
                  _buildMenuTab(),
                  _buildPerformanceTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.all(24),
      actions: [
         if (widget.store.status == StoreStatus.pending || widget.store.status == StoreStatus.suspended)
           ElevatedButton(
              onPressed: () { 
                Navigator.pop(context);
                widget.onAction(StoreStatus.approved);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              child: const Text('Approve Store', style: TextStyle(color: Colors.white)),
            ),
         if (widget.store.status == StoreStatus.pending)
           ElevatedButton(
             onPressed: () {
               Navigator.pop(context);
               widget.onAction(StoreStatus.rejected);
             },
             style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
             child: const Text('Reject Store', style: TextStyle(color: Colors.white)),
           ),
         if (widget.store.status == StoreStatus.approved)
           ElevatedButton(
             onPressed: () {
               Navigator.pop(context);
               widget.onAction(StoreStatus.suspended);
             },
             style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
             child: const Text('Suspend Store', style: TextStyle(color: Colors.white)),
           ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoGrid(),
          const SizedBox(height: 24),
          const Text('DOCUMENTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: widget.store.documents.map((doc) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).inputDecorationTheme.fillColor, 
                borderRadius: BorderRadius.circular(8), 
                border: Border.all(color: Colors.black.withValues(alpha: 0.05))
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.file_present_rounded, size: 14, color: Color(0xFFFF6B00)),
                  const SizedBox(width: 8),
                  Text(doc, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),
          const Text('AUDIT LOG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).dividerColor.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
            child: widget.auditLogs.isEmpty 
              ? const Center(child: Text('No audit logs found', style: TextStyle(color: Colors.grey)))
              : Column(
                  children: widget.auditLogs.map((log) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(margin: const EdgeInsets.only(top: 4), width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFF6B00), shape: BoxShape.circle)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(log.action, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            Text('by ${log.performedBy} • ${DateFormat('dd/MM/yyyy HH:mm').format(log.timestamp)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            if (log.reason != null) Text('Reason: ${log.reason}', style: TextStyle(fontSize: 11, color: Colors.grey[600], fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ],
                    ),
                  )).toList(),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTab() {
    final productsAsync = ref.watch(storeProductsProvider(widget.store.id));
    
    return productsAsync.when(
      data: (products) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${products.length} Products', style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                ElevatedButton.icon(
                  onPressed: () => _showProductForm(),
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text('Add Product', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: products.isEmpty 
              ? const Center(child: Text('No products listed in this store.'))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => _showProductForm(product: p),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  image: p.imageUrl.isNotEmpty ? DecorationImage(image: NetworkImage(p.imageUrl), fit: BoxFit.cover) : null,
                                ),
                                child: p.imageUrl.isEmpty ? const Icon(Icons.fastfood_rounded, color: Colors.grey, size: 24) : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis)),
                                        Switch(
                                          value: p.isAvailable, 
                                          onChanged: (v) {
                                            ref.read(menuRepositoryProvider).toggleProductAvailability(p.id, v);
                                            AppToastManager.instance.show(
                                              title: v ? 'Product Available' : 'Product Hidden',
                                              description: '${p.name} status updated.',
                                            );
                                          },
                                          activeThumbColor: Colors.green,
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ],
                                    ),
                                    Text('₹${p.price}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                                    Row(
                                      children: [
                                        Text(p.category, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                          onPressed: () => _deleteProduct(p),
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
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  void _deleteProduct(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(menuRepositoryProvider).deleteProduct(product.id);
              AppToastManager.instance.show(
                title: 'Product Deleted',
                description: '${product.name} removed from menu.',
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

  void _showProductForm({ProductModel? product}) {
    final nameController = TextEditingController(text: product?.name);
    final descController = TextEditingController(text: product?.description);
    final priceController = TextEditingController(text: product?.price.toString());
    final categoryController = TextEditingController(text: product?.category ?? 'General');
    final imgController = TextEditingController(text: product?.imageUrl);
    bool isVeg = product?.isVeg ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(product == null ? 'Add New Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Product Name')),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
                Row(
                  children: [
                    Expanded(child: TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Price', prefixText: '₹'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(child: TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category'))),
                  ],
                ),
                TextField(controller: imgController, decoration: const InputDecoration(labelText: 'Image URL')),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Vegetarian food?'),
                    const SizedBox(width: 12),
                    Switch(value: isVeg, onChanged: (v) => setDialogState(() => isVeg = v)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final newProduct = ProductModel(
                  id: product?.id ?? '',
                  storeId: widget.store.id,
                  name: nameController.text,
                  description: descController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  imageUrl: imgController.text,
                  category: categoryController.text,
                  isAvailable: product?.isAvailable ?? true,
                  isVeg: isVeg,
                  createdAt: product?.createdAt ?? DateTime.now(),
                );

                if (product == null) {
                  ref.read(menuRepositoryProvider).addProduct(newProduct);
                  AppToastManager.instance.show(title: 'Product Added', description: '${newProduct.name} created successfully.');
                } else {
                  ref.read(menuRepositoryProvider).updateProduct(newProduct);
                  AppToastManager.instance.show(title: 'Product Updated', description: '${newProduct.name} saved changes.');
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B00)),
              child: Text(product == null ? 'Add' : 'Update', style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTab() {
    final ordersAsync = ref.watch(storeOrdersStreamProvider(widget.store.id));

    return ordersAsync.when(
      data: (orders) {
        final totalOrders = orders.length;
        final totalRevenue = orders.where((o) => o.status == OrderStatus.delivered).fold<double>(0, (sum, o) => sum + o.totalAmount);
        final deliveredCount = orders.where((o) => o.status == OrderStatus.delivered).length;

        return Column(
          children: [
            Row(
              children: [
                _buildSmallStatCard('Total Orders', '$totalOrders', Icons.shopping_cart_rounded, Colors.blue),
                const SizedBox(width: 16),
                _buildSmallStatCard('Total Revenue', '₹${totalRevenue.toStringAsFixed(0)}', Icons.payments_rounded, Colors.green),
                const SizedBox(width: 16),
                _buildSmallStatCard('Completion Rate', '${totalOrders > 0 ? ((deliveredCount / totalOrders) * 100).toStringAsFixed(1) : 0}%', Icons.trending_up, Colors.purple),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Theme.of(context).dividerColor.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('RECENT ORDERS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: orders.take(5).length,
                        separatorBuilder: (context, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final o = orders[index];
                          return ListTile(
                            title: Text('Order #${o.id.substring(0, 8)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            subtitle: Text(DateFormat('dd MMM, HH:mm').format(o.createdAt), style: const TextStyle(fontSize: 11)),
                            trailing: Text('₹${o.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            dense: true,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildSmallStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoGrid() {
    final info = [
      ['Store Name', widget.store.name],
      ['Owner', widget.store.ownerName],
      ['Phone', widget.store.phone],
      ['Email', widget.store.email],
      ['College', widget.store.collegeName],
      ['Address', widget.store.address],
      ['Applied At', DateFormat('dd/MM/yyyy').format(widget.store.createdAt)],
      ['Rating', widget.store.rating != null ? '${widget.store.rating}/5' : 'N/A'],
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: info.map((i) => Container(
        width: 380,
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
}
