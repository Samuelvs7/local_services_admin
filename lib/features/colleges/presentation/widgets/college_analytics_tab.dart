import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/models/college_model.dart';
import '../../../../features/stores/data/repositories/store_repository.dart';
import '../../../../features/stores/data/models/store_model.dart';

class CollegeAnalyticsTab extends ConsumerWidget {
  final College college;

  const CollegeAnalyticsTab({super.key, required this.college});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vendorsAsync = ref.watch(storesByCollegeProvider(college.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pre-Aggregated Analytics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildMainStatCard('Total Revenue', '₹${college.revenue.toInt()}', Icons.trending_up_rounded, Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildMainStatCard('Total Orders', '${college.totalOrders}', Icons.shopping_bag_outlined, Colors.orange)),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Top Performing Vendors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          vendorsAsync.when(
            data: (vendors) => _buildTopVendorsList(vendors),
            loading: () => _buildLoadingSkeleton(),
            error: (e, s) => Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withValues(alpha: 0.1)),
              ),
              child: const Center(
                child: Text('Failed to load top vendors.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildMainStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 20),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildTopVendorsList(List<Store> vendors) {
    if (vendors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(16),
           border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        alignment: Alignment.center,
        child: const Text('No vendor data available yet.', style: TextStyle(color: Colors.grey)),
      );
    }

    // Sort heavily by totalRevenue descending
    final sortedVendors = List<Store>.from(vendors)
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
      
    final topVendors = sortedVendors.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: topVendors.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
        itemBuilder: (context, index) {
          final vendor = topVendors[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: index == 0 ? Colors.amber.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.1),
              child: Text(
                '#${index + 1}',
                style: TextStyle(
                  color: index == 0 ? Colors.amber[800] : Colors.blue[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            title: Text(vendor.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('${vendor.totalOrders} Orders', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            trailing: Text(
              '₹${vendor.totalRevenue.toInt()}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green),
            ),
          );
        },
      ),
    );
  }
}
