import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_services_admin/features/auth/presentation/providers/auth_provider.dart';
import 'package:local_services_admin/features/admins/data/models/admin_user_model.dart';
import 'package:local_services_admin/core/providers/theme_provider.dart';
import 'package:local_services_admin/core/theme/app_colors.dart';
import 'package:local_services_admin/core/utils/responsive.dart';
import 'package:local_services_admin/features/dashboard/data/repositories/dashboard_repository.dart';

class AdminTopBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;
  final VoidCallback onPendingPressed;
  const AdminTopBar({super.key, required this.onMenuPressed, required this.onPendingPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == AppThemeType.dark;
    final theme = Theme.of(context);
    final currentAdminAsync = ref.watch(currentAdminProvider);
    
    final (displayName, roleLabel) = currentAdminAsync.maybeWhen(
      data: (admin) => (
        admin?.name ?? 'Admin User',
        admin?.role == AdminRole.superAdmin ? 'Super Admin' : 
        admin?.role == AdminRole.moderator ? 'Moderator' : 'Finance Admin'
      ),
      orElse: () => ('Admin User', 'Super Admin'),
    );


    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // 1. Search Bar
          if (!Responsive.isDesktop(context))
            IconButton(
              onPressed: onMenuPressed,
              icon: const Icon(Icons.menu_rounded, color: Color(0xFF1E1E2D)),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                _buildSearchInput(isDark),
              ],
            ),
          ),
          
          const SizedBox(width: 20),
          
          // 2. Actions
          Row(
            children: [
              // Theme Toggle
              IconButton(
                onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? Colors.amber : Colors.blueGrey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),

              // Notification Bell
              _buildNotificationButton(isDark),
              
              const SizedBox(width: 12),
              
              // Pending Indicator
              Consumer(
                builder: (context, ref, child) {
                  final statsAsync = ref.watch(dashboardStatsProvider);
                  return statsAsync.maybeWhen(
                    data: (stats) => stats.pendingStoreApprovals > 0 
                      ? _buildPendingIndicator(stats.pendingStoreApprovals) 
                      : const SizedBox.shrink(),
                    orElse: () => const SizedBox.shrink(),
                  );
                },
              ),
              
              const SizedBox(width: 20),
              
              // Vertical Divider
              Container(
                width: 1,
                height: 32,
                color: Colors.grey.withValues(alpha: 0.1),
              ),
              
              const SizedBox(width: 20),
              
              // Profile Section
              _buildProfileSection(context, isDark, displayName, roleLabel),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput(bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      height: 38,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface2 : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.darkBorder : Colors.transparent),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search users, stores, orders...',
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey, size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 9),
        ),
      ),
    );
  }

  Widget _buildNotificationButton(bool isDark) {
    return Stack(
      children: [
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.notifications_none_rounded, color: isDark ? Colors.grey[400] : Colors.blueGrey, size: 22),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingIndicator(int count) {
    return InkWell(
      onTap: onPendingPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.amber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$count Pending Approvals',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, bool isDark, String displayName, String roleLabel) {
    return InkWell(
      onTap: () {
        // Handle dropdown
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Icon(Icons.shield_rounded, color: Theme.of(context).colorScheme.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                roleLabel,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueGrey, size: 18),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
