import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../features/stores/data/repositories/store_repository.dart';
import '../../../../features/stores/data/models/store_model.dart';

class CollegeVendorsTab extends ConsumerWidget {
  final String collegeId;

  const CollegeVendorsTab({super.key, required this.collegeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorsAsync = ref.watch(storesByCollegeProvider(collegeId));

    return vendorsAsync.when(
      data: (vendors) {
        if (vendors.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.storefront_rounded, size: 48, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
                ),
                const SizedBox(height: 24),
                const Text('No Vendors Found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('Add vendors to this college to track performance.', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: vendors.length,
          itemBuilder: (context, index) {
            final vendor = vendors[index];
            return _buildVendorCard(context, vendor);
          },
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: 4,
        itemBuilder: (_, __) => _buildLoadingSkeleton(context),
      ),
      error: (e, s) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.red[300], size: 48),
              const SizedBox(height: 16),
              const Text('Failed to load vendors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(e.toString(), textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 140,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildVendorCard(BuildContext context, Store vendor) {
    // Determine status colors
    Color statusColor;
    String statusText;
    
    if (vendor.isActive) {
      statusColor = Colors.green;
      statusText = 'Active';
    } else if (vendor.status == StoreStatus.pending) {
      statusColor = Colors.orange;
      statusText = 'Pending';
    } else if (vendor.status == StoreStatus.rejected || vendor.status == StoreStatus.suspended) {
      statusColor = Colors.red;
      statusText = vendor.status.name.toUpperCase();
    } else {
      statusColor = Colors.grey;
      statusText = 'Inactive';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.storefront_rounded, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vendor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(vendor.serviceType.toUpperCase(), style: TextStyle(color: Colors.grey[500], fontSize: 11, letterSpacing: 0.5)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total Orders', '${vendor.totalOrders}', Icons.shopping_cart_outlined, Colors.blue),
              _buildStatItem('Revenue', '₹${vendor.totalRevenue.toInt()}', Icons.account_balance_wallet_outlined, Colors.green),
              _buildStatItem('Rating', vendor.rating != null ? '${vendor.rating}' : 'N/A', Icons.star_border_rounded, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
      ],
    );
  }
}
