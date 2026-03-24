import 'package:flutter/material.dart';
import '../../data/models/college_model.dart';
import '../../../sessions/presentation/widgets/session_list_widget.dart';
import '../widgets/college_vendors_tab.dart';
import '../widgets/college_analytics_tab.dart';

class CollegeDetailScreen extends StatelessWidget {
  final College college;

  const CollegeDetailScreen({super.key, required this.college});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FA),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              stretch: true,
              backgroundColor: const Color(0xFFFF6B00),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  college.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (college.bannerImage.isNotEmpty)
                      Image.network(
                        college.bannerImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                           return Container(
                             decoration: const BoxDecoration(
                               gradient: LinearGradient(
                                 colors: [Color(0xFFFF6B00), Color(0xFFE85D04)],
                                 begin: Alignment.topLeft,
                                 end: Alignment.bottomRight,
                               ),
                             ),
                           );
                        },
                      ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  labelColor: const Color(0xFFFF6B00),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: const Color(0xFFFF6B00),
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 32),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.dashboard_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Overview'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Sessions'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.storefront_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Vendors'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.analytics_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Analytics'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _buildOverviewTab(context),
              SessionListWidget(collegeId: college.id),
              CollegeVendorsTab(collegeId: college.id),
              CollegeAnalyticsTab(college: college),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsRow(context),
          const SizedBox(height: 32),
          _buildInfoCard(context),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = (constraints.maxWidth - 48) / 4;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: width, child: _buildMiniStat('Students', '${college.totalStudents}', Icons.people_rounded, Colors.blue)),
          SizedBox(width: width, child: _buildMiniStat('Vendors', '${college.totalStores}', Icons.store_rounded, Colors.indigo)),
          SizedBox(width: width, child: _buildMiniStat('Orders', '${college.totalOrders}', Icons.shopping_bag_rounded, Colors.orange)),
          SizedBox(width: width, child: _buildMiniStat('Revenue', '₹${college.revenue.toInt()}', Icons.account_balance_wallet_rounded, Colors.green)),
        ],
      );
    });
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.85), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Institution Details', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          _detailRow('Full Name', college.name),
          _detailRow('Short Code', college.shortName),
          _detailRow('City', college.city),
          _detailRow('State', college.state),
          _detailRow('Location', '${college.location.latitude}, ${college.location.longitude}'),
          _detailRow('Status', college.isActive ? 'Active' : 'Inactive', isStatus: true),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (value == 'Active' ? Colors.green : Colors.red).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(value, style: TextStyle(color: value == 'Active' ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
            )
          else
            Expanded(
              child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF2A2D3E))),
            ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
