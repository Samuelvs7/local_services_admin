import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:local_services_admin/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:local_services_admin/features/dashboard/presentation/widgets/dashboard_stats_card.dart';
import 'package:local_services_admin/features/dashboard/presentation/widgets/recent_orders_table.dart';
import 'package:local_services_admin/features/stores/presentation/providers/store_provider.dart';
import 'package:local_services_admin/features/dashboard/data/models/admin_stats_model.dart';

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

                const SizedBox(height: 32),

                // 4. Charts Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildTrendChart(context, stats)),
                    const SizedBox(width: 24),
                    Expanded(flex: 1, child: _buildServiceDistribution(context, stats)),
                  ],
                ),

                const SizedBox(height: 32),

                // 5. College Revenue Bar Chart
                _buildCollegeRevenueChart(context, stats),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Text('Error: $e'),
          ),

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

  Widget _buildTrendChart(BuildContext context, AdminStats stats) {
    // Generate trend spots from last7DaysRevenue. Index 0 is 6 days ago, index 6 is today.
    final spots = List.generate(7, (i) {
      return FlSpot(i.toDouble(), stats.last7DaysRevenue[i] > 0 ? stats.last7DaysRevenue[i] : 0);
    });
    
    double maxY = 0;
    for (var val in stats.last7DaysRevenue) {
      if (val > maxY) maxY = val;
    }
    // Give some headroom to maxY
    maxY = maxY > 0 ? maxY * 1.2 : 10;

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
                minY: 0,
                maxY: maxY,
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        if (val < 0 || val > 6) return const Text('');
                        final daysAgo = 6 - val.toInt();
                        if (daysAgo == 0) return const Text('Today', style: TextStyle(fontSize: 10));
                        return Text('${daysAgo}d', style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (val, meta) {
                        if (val == 0) return const Text('');
                        return Text(_formatCurrency(val), style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
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

  Widget _buildServiceDistribution(BuildContext context, AdminStats stats) {
    final totalOrders = stats.ordersByService.values.fold(0, (sum, val) => sum + val);

    final colors = [
      Theme.of(context).colorScheme.primary,
      Colors.blue.shade400,
      Colors.purple.shade400,
      Colors.orange.shade400,
      Colors.teal.shade400,
    ];

    List<PieChartSectionData> sections = [];
    List<Widget> legends = [];

    int i = 0;
    stats.ordersByService.forEach((service, count) {
      if (count > 0 && totalOrders > 0) {
        final percentage = (count / totalOrders) * 100;
        final color = colors[i % colors.length];

        sections.add(
          PieChartSectionData(
            color: color, 
            value: percentage, 
            title: service.length > 6 ? '${service.substring(0, 5)}.' : service, 
            radius: 50, 
            titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        );

        legends.add(_buildLegend(service, color, '${percentage.toStringAsFixed(1)}%'));
        i++;
      }
    });

    if (sections.isEmpty) {
      sections.add(PieChartSectionData(color: Colors.grey.shade300, value: 100, title: 'No Data', radius: 50));
      legends.add(_buildLegend('No Orders', Colors.grey.shade300, '0%'));
    }

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
                sections: sections,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...legends,
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

  Widget _buildCollegeRevenueChart(BuildContext context, AdminStats stats) {
    List<BarChartGroupData> barGroups = [];
    int i = 0;
    double maxY = 0;
    
    stats.topCollegesRevenue.forEach((collegeName, revenue) {
      if (revenue > maxY) maxY = revenue;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [BarChartRodData(toY: revenue, color: Theme.of(context).colorScheme.primary, width: 20, borderRadius: BorderRadius.circular(4))],
        ),
      );
      i++;
    });

    if (barGroups.isEmpty) {
       barGroups.add(BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 0, color: Colors.blue, width: 20)]));
    }
    
    maxY = maxY > 0 ? maxY * 1.2 : 10;

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
          const Text('Platform earnings per institution (Top 4)', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: maxY,
                barGroups: barGroups,
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (val, meta) {
                        if (val == 0) return const Text('');
                        return Text(_formatCurrency(val), style: const TextStyle(fontSize: 10));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        int index = val.toInt();
                        if (index >= 0 && index < stats.topCollegesRevenue.length) {
                          String name = stats.topCollegesRevenue.keys.elementAt(index);
                          if (name.length > 20) name = '${name.substring(0, 18)}...';
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(name, style: const TextStyle(fontSize: 10)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
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
