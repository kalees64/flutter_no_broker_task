import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class DashboardPlaceholderPage extends ConsumerWidget {
  const DashboardPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'NoBroker Dashboard',
          style: AppTextStyles.h2.copyWith(color: AppColors.onSurface),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, size: 22),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: UserAvatar(
              name: user?.name ?? 'Admin',
              size: 36,
              isVerified: true,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome greeting card
              AppCard(
                borderRadius: 16,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    UserAvatar(
                      name: user?.name ?? 'Rajesh Kumar',
                      size: 56,
                      isVerified: true,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Good day, ${user?.name.split(' ').first ?? 'User'}!',
                                style: AppTextStyles.h2,
                              ),
                              const SizedBox(width: 4),
                              const Text('👋', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'Logged in',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Role: ${user?.role.toUpperCase() ?? 'USER'} • KYC ${user?.kycStatus.toUpperCase() ?? 'VERIFIED'}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Operational status chip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.shieldCheck, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cluster Health: 99.4%',
                            style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'All societies operational without dispute',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Logout button
              AppButton(
                text: 'Log Out',
                variant: AppButtonVariant.outline,
                icon: LucideIcons.logOut,
                onPressed: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
