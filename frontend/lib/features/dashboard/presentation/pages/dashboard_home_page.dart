import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../users/presentation/controllers/users_controller.dart';
import '../widgets/cluster_health_card.dart';
import '../widgets/daily_dispatch_card.dart';
import '../widgets/operations_launchpad.dart';
import '../widgets/property_spotlight_banner.dart';
import '../widgets/quick_action_sheet.dart';
import '../widgets/recent_activity_feed.dart';
import '../widgets/stats_grid_2x2.dart';

class DashboardHomePage extends ConsumerWidget {
  const DashboardHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    final displayName = (user != null && user.name.isNotEmpty)
        ? user.name.split(' ').first
        : 'Rajesh';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
        elevation: 0.5,
        scrolledUnderElevation: 1,
        title: Row(
          children: [
            Image.asset(
              AppAssets.logo,
              height: 28,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NoBroker',
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Dashboard',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(LucideIcons.bell, size: 22, color: AppColors.onSurfaceVariant),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF5A3C),
                      border: Border.all(
                        color: AppColors.surfaceContainerLowest,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All cluster operations are up to date!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 4.0),
            child: GestureDetector(
              onTap: () => context.go('/profile'),
              child: UserAvatar(
                name: user?.name ?? 'Rajesh Kumar',
                size: 34,
                isVerified: true,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFFFF5A3C),
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(LucideIcons.plus, size: 20),
          label: const Text(
            'Quick Action',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          onPressed: () => QuickActionSheet.show(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(usersControllerProvider.notifier).loadUsers(refresh: true);
        },
        color: AppColors.primary,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16.0, 14.0, 16.0, 100.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting & Subtitle
                  Row(
                    children: [
                      Text(
                        'Good morning, $displayName!',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 22,
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('👋', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Property Operations Lead • Whitefield Cluster',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Live Sync Micro Badge
                  GestureDetector(
                    onTap: () {
                      ref.read(usersControllerProvider.notifier).loadUsers(refresh: true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Syncing cluster directory...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.refreshCw,
                            size: 13,
                            color: AppColors.primaryContainer,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Updated just now • Tap to sync',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.primaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Operational Health Alert Banner (NoBroker Trust Assurance)
                  ClusterHealthCard(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cluster Whitefield has 0 pending safety disputes.'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  // Quick Stats 2x2 Grid (Verified Users, Active Leases, Pending Approvals, Monthly Rev)
                  StatsGrid2x2(
                    verifiedUsersCount: 2845,
                    onUsersTap: () => context.go('/users'),
                  ),
                  const SizedBox(height: 11),

                  // Operations Launchpad (Horizontal Carousel with Add User, Verify KYC, Collect Rent, Maintenance, Gate Pass)
                  const OperationsLaunchpad(),
                  const SizedBox(height: 11),

                  // Recent Visual Highlights Banner: Whitefield Property Spotlight
                  const PropertySpotlightBanner(),
                  const SizedBox(height: 11),

                  // Recent Activity Feed (Vikram Malhotra, Priya Sharma, Sneha Patel)
                  RecentActivityFeed(
                    onViewAll: () => context.go('/users'),
                  ),
                  const SizedBox(height: 11),

                  // Daily Dispatch Tasks (Progress bar: 18 of 22 Completed)
                  const DailyDispatchCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
