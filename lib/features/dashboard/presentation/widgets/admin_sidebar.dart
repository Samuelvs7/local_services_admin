import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_services_admin/core/providers/sidebar_provider.dart';
import 'package:local_services_admin/core/providers/theme_provider.dart';
import 'package:local_services_admin/core/theme/app_colors.dart';

class AdminSidebar extends ConsumerWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collapsed = ref.watch(sidebarCollapsedProvider);
    final isDark = ref.watch(themeProvider) == AppThemeType.dark;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: collapsed ? 80 : 260,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFF1E1E2D),
        border: Border(
          right: BorderSide(color: isDark ? AppColors.darkBorder : Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Column(
        children: [
          // 1. Logo Section
          _buildLogo(context, collapsed),
          
          // 2. Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildGroup(collapsed, 'OVERVIEW', [
                  _SidebarItem(
                    label: 'Dashboard',
                    icon: Icons.dashboard_rounded,
                    isSelected: selectedIndex == 0,
                    collapsed: collapsed,
                    onTap: () => onItemSelected(0),
                  ),
                ]),
                _buildGroup(collapsed, 'PLATFORM', [
                  _SidebarItem(
                    label: 'Colleges',
                    icon: Icons.school_rounded,
                    isSelected: selectedIndex == 1,
                    collapsed: collapsed,
                    onTap: () => onItemSelected(1),
                  ),
                  _SidebarItem(
                    label: 'Stores & Vendors',
                    icon: Icons.store_rounded,
                    isSelected: selectedIndex == 2,
                    collapsed: collapsed,
                    onTap: () => onItemSelected(2),
                  ),
                  _SidebarItem(
                    label: 'Vendor Approvals',
                    icon: Icons.person_add_alt_rounded,
                    isSelected: selectedIndex == 11,
                    collapsed: collapsed,
                    onTap: () => onItemSelected(11),
                  ),
                  _SidebarItem(
                    label: 'Marketing Banners',
                    icon: Icons.add_photo_alternate_rounded,
                    isSelected: selectedIndex == 3,
                    collapsed: collapsed,
                    onTap: () => onItemSelected(3),
                  ),
                  _SidebarItem(
                    label: 'Users',
                    icon: Icons.people_rounded,
                    isSelected: selectedIndex == 5,
                    collapsed: collapsed,
                    onTap: () => onItemSelected(5),
                  ),
                  _SidebarItem(
                    label: 'Orders',
                    icon: Icons.shopping_bag_rounded,
                    isSelected: selectedIndex == 4,
                    collapsed: collapsed,
                    onTap: () => onItemSelected(4),
                  ),
                ]),
                _buildGroup(collapsed, 'SERVICES', [
                   _SidebarItem(
                    label: 'Service Config',
                    icon: Icons.bolt_rounded,
                    isSelected: selectedIndex == 6,
                    collapsed: collapsed,
                    onTap: () => onItemSelected(6),
                  ),
                ]),
                _buildGroup(collapsed, 'COMMUNICATION', [
                   _SidebarItem(
                    label: 'Broadcasts',
                    icon: Icons.campaign_rounded,
                    isSelected: selectedIndex == 7,
                    collapsed: collapsed,
                    onTap: () => onItemSelected(7),
                  ),
                ]),
                _buildGroup(collapsed, 'SYSTEM', [
                   _SidebarItem(
                    label: 'Admin Roles',
                    icon: Icons.shield_rounded,
                    isSelected: selectedIndex == 8,
                    collapsed: collapsed,
                    onTap: () => onItemSelected(8),
                  ),
                   _SidebarItem(
                    label: 'Finance',
                    icon: Icons.account_balance_wallet_rounded,
                    isSelected: selectedIndex == 10,
                    collapsed: collapsed,
                    onTap: () => onItemSelected(10),
                  ),
                   _SidebarItem(
                    label: 'Settings',
                    icon: Icons.settings_rounded,
                    isSelected: selectedIndex == 9,
                    collapsed: collapsed,
                    onTap: () => onItemSelected(9),
                  ),
                ]),
              ],
            ),
          ),
          
          // 3. Collapse Toggle
          _buildCollapseToggle(ref, collapsed),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context, bool collapsed) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
          ),
          if (!collapsed) ...[
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NexSus Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: -0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Hyperlocal Platform',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGroup(bool collapsed, String label, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!collapsed)
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 20, bottom: 8),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.2),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ...items,
      ],
    );
  }

  Widget _buildCollapseToggle(WidgetRef ref, bool collapsed) {
    return InkWell(
      onTap: () => ref.read(sidebarCollapsedProvider.notifier).state = !collapsed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(
              collapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
              color: Colors.white38, size: 20,
            ),
            if (!collapsed) ...[
               const SizedBox(width: 8),
               const Text(
                'Collapse',
                style: TextStyle(color: Colors.white38, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool collapsed;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 0 : 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (isSelected && !collapsed)
                Positioned(
                  left: -12,
                  child: Container(
                    width: 3,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              Row(
                mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white60,
                    size: collapsed ? 22 : 20,
                  ),
                  if (!collapsed) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white60,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
