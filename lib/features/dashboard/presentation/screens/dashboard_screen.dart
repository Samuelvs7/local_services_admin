import 'package:flutter/material.dart';

import 'package:local_services_admin/features/dashboard/presentation/screens/dashboard_page.dart';
import 'package:local_services_admin/features/admins/presentation/screens/admins_page.dart';
import 'package:local_services_admin/features/colleges/presentation/screens/college_list_screen.dart';
import 'package:local_services_admin/features/finance/presentation/screens/finance_page.dart';
import 'package:local_services_admin/features/orders/presentation/screens/orders_page.dart';
import 'package:local_services_admin/features/services/presentation/screens/services_page.dart';
import 'package:local_services_admin/features/settings/presentation/screens/settings_page.dart';
import 'package:local_services_admin/features/stores/presentation/screens/stores_page.dart';
import 'package:local_services_admin/features/users/presentation/screens/users_page.dart';
import 'package:local_services_admin/features/banners/presentation/screens/banners_page.dart';
import 'package:local_services_admin/features/announcements/presentation/screens/announcements_page.dart';
import '../widgets/admin_sidebar.dart';
import '../widgets/admin_top_bar.dart';
import '../../../../core/utils/responsive.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: Responsive.isDesktop(context) 
          ? null 
          : AdminSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() => _selectedIndex = index);
                Navigator.pop(context); // Close drawer on selection
              },
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Sidebar (Only for Desktop)
          if (Responsive.isDesktop(context))
            AdminSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() => _selectedIndex = index);
              },
            ),
          
          // 2. Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                AdminTopBar(
                  onMenuPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
                
                // Main Content Area
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: _buildContent(_selectedIndex),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(int index) {
    switch (index) {
      case 0:
        return DashboardPage(
          onNavigate: (index) {
            setState(() => _selectedIndex = index);
          },
        );
      case 1:
         return const CollegeListScreen(); 
      case 2:
        return const StoresPage();
      case 3:
        return const BannersPage();
      case 4:
        return const OrdersPage();
      case 5:
        return const UsersPage();
      case 6:
        return const ServicesPage();
      case 7:
        return const AnnouncementsPage();
      case 8:
        return const AdminsPage();
      case 9:
        return const SettingsPage();
      case 10:
        return const FinancePage();
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.construction_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Content for Index $index coming soon',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        );
    }
  }
}
