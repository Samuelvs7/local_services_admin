import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:local_services_admin/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:local_services_admin/features/dashboard/presentation/widgets/dashboard_stats_card.dart';
import 'package:local_services_admin/features/dashboard/presentation/widgets/recent_orders_table.dart';
import 'package:local_services_admin/features/stores/presentation/providers/store_provider.dart';

class DashboardPage extends ConsumerWidget {
  final Function(int) onNavigate;

  const DashboardPage({super.key, required this.onNavigate});

  String _formatCurrency(double amount) {
    return NumberFormat.simpleCurrency(name: 'INR', decimalDigits: 0).format(amount);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final pendingStoresAsync = ref.watch(pendingStoresProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Welcome back! Here's what's happening today.",
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text('Live · Updated just now', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          statsAsync.when(
            data: (stats) => Column(
              children: [
                // 2. Main Stats Grid
                _buildStatsGrid(stats),
                const SizedBox(height: 24),
                
                // 3. Secondary Stats Grid
                _buildSecondaryStatsGrid(stats),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Text('Error: $e'),
          ),

          const SizedBox(height: 32),

          // 4. Charts Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildTrendChart(context)),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: _buildServiceDistribution(context)),
            ],
          ),

          const SizedBox(height: 32),

          // 5. College Revenue Bar Chart
          _buildCollegeRevenueChart(context),

          const SizedBox(height: 32),

          // 6. Recent Orders + Pending Approvals Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: RecentOrdersTable()),
              const SizedBox(width: 24),
              Expanded(
                child: _buildPendingApprovalsList(context, pendingStoresAsync),
              ),
            ],
          ),
          
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(dynamic stats) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = (constraints.maxWidth - 72) / 4;
      return Wrap(
        spacing: 24,
        runSpacing: 24,
        children: [
          SizedBox(
            width: width,
            child: DashboardStatsCard(
              title: 'Total Users',
              value: '${stats.totalUsers}',
              icon: Icons.people_rounded,
              color: Colors.blue,
              growth: '+12%',
            ),
          ),
          SizedBox(
            width: width,
            child: DashboardStatsCard(
              title: 'Active Stores',
              value: '${stats.activeStores}',
              icon: Icons.store_rounded,
              color: Colors.green,
              growth: 'Live',
            ),
          ),
          SizedBox(
            width: width,
            child: DashboardStatsCard(
              title: "Today's Orders",
              value: '${stats.todayOrders}',
              icon: Icons.shopping_bag_rounded,
              color: Theme.of(context).colorScheme.primary,
              growth: '+8%',
            ),
          ),
          SizedBox(
            width: width,
            child: DashboardStatsCard(
              title: 'Net Commission',
              value: _formatCurrency(stats.totalCommission),
              icon: Icons.account_balance_wallet_rounded,
              color: Colors.deepPurple,
              growth: '+18.5%',
            ),
          ),
          SizedBox(
            width: width,
            child: DashboardStatsCard(
              title: 'Pending Payouts',
              value: _formatCurrency(stats.pendingPayouts),
              icon: Icons.pending_actions_rounded,
              color: Colors.orange,
              growth: 'Review',
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSecondaryStatsGrid(dynamic stats) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = (constraints.maxWidth - 72) / 4;
      return Wrap(
        spacing: 24,
        runSpacing: 24,
        children: [
          SizedBox(
            width: width,
            child: DashboardStatsCard(
              title: 'Pending Approvals',
              value: '${stats.pendingStoreApprovals}',
              icon: Icons.query_builder_rounded,
              color: Colors.amber,
              growth: 'Needs Action',
              onTap: () => onNavigate(2),
            ),
          ),
          SizedBox(
            width: width,
            child: DashboardStatsCard(
              title: 'Total Orders',
              value: '${stats.totalOrders}',
              icon: Icons.trending_up_rounded,
              color: Colors.blue,
              growth: 'All time',
            ),
          ),
          SizedBox(
            width: width,
            child: DashboardStatsCard(
              title: 'Total Colleges',
              value: '${stats.totalColleges}',
              icon: Icons.school_rounded,
              color: Colors.teal,
              growth: '${stats.activeColleges} Active',
            ),
          ),
          SizedBox(
            width: width,
            child: DashboardStatsCard(
              title: 'Total Vendors',
              value: '${stats.totalStores}',
              icon: Icons.person_add_alt_rounded,
              color: Colors.indigo,
              growth: 'Registered',
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTrendChart(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Orders & Revenue Trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Last 7 days performance', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: const FlTitlesData(
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3), FlSpot(1, 4), FlSpot(2, 3.5), FlSpot(3, 5),
                      FlSpot(4, 4), FlSpot(5, 6), FlSpot(6, 5),
                    ],
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDistribution(BuildContext context) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Service Distribution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Orders by service type', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 24),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: Theme.of(context).colorScheme.primary, 
                    value: 40, 
                    title: 'Food', 
                    radius: 50, 
                    titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: Colors.blue.shade400, 
                    value: 30, 
                    title: 'Bike', 
                    radius: 50, 
                    titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  PieChartSectionData(
                    color: Colors.purple.shade400, 
                    value: 30, 
                    title: 'Parcel', 
                    radius: 50, 
                    titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLegend('Food', Theme.of(context).colorScheme.primary, '40%'),
          _buildLegend('Bike', Colors.blue, '30%'),
          _buildLegend('Parcel', Colors.purple, '30%'),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCollegeRevenueChart(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Revenue by College', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Platform earnings per institution', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: Colors.blue, width: 20)]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: Colors.blue, width: 20)]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 7, color: Colors.blue, width: 20)]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 12, color: Colors.blue, width: 20)]),
                ],
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalsList(BuildContext context, AsyncValue pendingStoresAsync) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pending Approvals', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: () => onNavigate(2),
                  child: const Text('Review all', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          pendingStoresAsync.when(
            data: (stores) {
              if (stores.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                       Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 40),
                       SizedBox(height: 12),
                       Text('All caught up!', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }
              final displayStores = (stores as List).take(5).toList();
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayStores.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
                itemBuilder: (context, index) {
                  final store = displayStores[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber.withValues(alpha: 0.1),
                      child: const Icon(Icons.store_rounded, color: Colors.amber, size: 20),
                    ),
                    title: Text(store.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text(store.serviceType, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }
}
