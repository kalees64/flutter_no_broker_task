import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../widgets/edit_profile_dialog.dart';
import '../widgets/logout_dialog.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    final roleFormatted = (user != null && user.role.isNotEmpty)
        ? user.role[0].toUpperCase() + user.role.substring(1)
        : 'Administrator';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0.5,
        title: Row(
          children: [
            Image.asset(
              AppAssets.logo,
              height: 24,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Text(
              'Account & Profile',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(LucideIcons.pencil, size: 20),
              tooltip: 'Edit Profile',
              onPressed: () => EditProfileDialog.show(context, user: user),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          children: [
            // User Identity Card
            AppCard(
              borderRadius: 20,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  UserAvatar(
                    name: user?.name ?? 'Corporate Admin',
                    size: 72,
                    isVerified: true,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user?.name ?? 'Corporate Admin',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        LucideIcons.badgeCheck,
                        size: 20,
                        color: AppColors.primaryContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'admin@nobroker.in',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          roleFormatted,
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.primaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Active Session',
                          style: AppTextStyles.labelSm.copyWith(
                            color: const Color(0xFF16A34A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (user != null) ...[
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => EditProfileDialog.show(context, user: user),
                      icon: const Icon(LucideIcons.pencil, size: 15),
                      label: const Text('Edit Profile Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryContainer,
                        side: BorderSide(
                          color: AppColors.primaryContainer.withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Profile Info List
            AppCard(
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  _buildProfileTile(
                    icon: LucideIcons.phone,
                    title: 'Phone Number',
                    subtitle: user?.phone ?? '+91 90000 00001',
                  ),
                  const Divider(height: 1, color: AppColors.surfaceContainerLow),
                  _buildProfileTile(
                    icon: LucideIcons.building,
                    title: 'Assigned Cluster',
                    subtitle: user?.societyName ?? 'Whitefield Operations Hub',
                  ),
                  const Divider(height: 1, color: AppColors.surfaceContainerLow),
                  _buildProfileTile(
                    icon: LucideIcons.mapPin,
                    title: 'Unit Location',
                    subtitle: user?.flatNumber ?? 'HQ-01 (Executive)',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Trust & Security Standards Card
            AppCard(
              borderRadius: 16,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Institutional Compliance & Trust',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTrustItem(
                    icon: LucideIcons.shieldCheck,
                    title: '256-Bit TLS End-to-End Encryption',
                    subtitle: 'All communication with PostgreSQL cluster is secured.',
                  ),
                  const SizedBox(height: 10),
                  _buildTrustItem(
                    icon: LucideIcons.fileText,
                    title: 'RERA Compliant Architecture',
                    subtitle: 'Real estate transaction safety and disclosure compliant.',
                  ),
                  const SizedBox(height: 10),
                  _buildTrustItem(
                    icon: LucideIcons.lock,
                    title: 'JWT Access & Refresh Token Rotation',
                    subtitle: 'Short-lived access tokens with automatic revocation.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sign Out Button
            AppButton(
              text: 'Sign Out from Device',
              icon: LucideIcons.logOut,
              backgroundColor: AppColors.error,
              onPressed: () {
                LogoutDialog.show(
                  context,
                  onLogout: () async {
                    await ref.read(authNotifierProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 14),

            Text(
              'NoBroker Management Hub • v3.8.2 (Enterprise)',
              style: AppTextStyles.caption.copyWith(color: AppColors.outline),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF16A34A)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
