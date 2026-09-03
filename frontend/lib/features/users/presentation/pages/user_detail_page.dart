import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/data/models/user_model.dart';
import '../controllers/users_controller.dart';
import '../widgets/delete_confirm_dialog.dart';

class UserDetailPage extends ConsumerWidget {
  final UserModel user;

  const UserDetailPage({super.key, required this.user});

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'U';
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(usersControllerProvider);
    final currentUser = usersState.users.firstWhere(
      (u) => u.id == user.id,
      orElse: () => user,
    );

    final isVerified = currentUser.kycStatus == 'verified';
    final roleFormatted = currentUser.role.isNotEmpty
        ? currentUser.role[0].toUpperCase() + currentUser.role.substring(1)
        : 'Resident';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0.5,
        title: Text(
          'Resident Profile',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.pencil, size: 20),
            onPressed: () async {
              final result = await context.push<bool>(
                '/users/${currentUser.id}/edit',
                extra: currentUser,
              );
              if (result == true) {
                ref.read(usersControllerProvider.notifier).refreshUser(currentUser.id);
              }
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.trash2, size: 20, color: AppColors.error),
            onPressed: () {
              DeleteConfirmDialog.show(
                context,
                userName: currentUser.name,
                onConfirm: () async {
                  final controller = ref.read(usersControllerProvider.notifier);
                  await controller.deleteUserImmediately(currentUser.id);
                  if (context.mounted) {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('User "${currentUser.name}" deleted successfully.'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Profile Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Hero(
                    tag: 'user-avatar-${currentUser.id}',
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryContainer,
                            AppColors.primary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(currentUser.name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentUser.name,
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        LucideIcons.badgeCheck,
                        color: AppColors.primaryContainer,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentUser.email,
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
                          color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          roleFormatted,
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isVerified
                              ? const Color(0xFF16A34A).withValues(alpha: 0.12)
                              : const Color(0xFFFF5A3C).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isVerified ? 'KYC Verified' : 'KYC Pending',
                          style: AppTextStyles.labelSm.copyWith(
                            color: isVerified
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFFF5A3C),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Actions Strip (Call, Email, WhatsApp)
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionBtn(
                    context,
                    icon: LucideIcons.phoneCall,
                    label: 'Call',
                    color: AppColors.primaryContainer,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Calling ${currentUser.phone ?? "user"}...')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickActionBtn(
                    context,
                    icon: LucideIcons.mail,
                    label: 'Email',
                    color: AppColors.secondary,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Composing email to ${currentUser.email}...')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickActionBtn(
                    context,
                    icon: LucideIcons.messageSquare,
                    label: 'Message',
                    color: const Color(0xFF16A34A),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Opening chat with ${currentUser.name}...')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Property & Residency Details
            Text(
              'Property Information',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: LucideIcons.home,
                    label: 'Flat / Unit Number',
                    value: currentUser.flatNumber ?? 'HQ-01',
                  ),
                  const Divider(height: 1, color: AppColors.surfaceContainerLow),
                  _buildDetailRow(
                    icon: LucideIcons.building2,
                    label: 'Society / Cluster',
                    value: currentUser.societyName ?? 'Whitefield Cluster',
                  ),
                  const Divider(height: 1, color: AppColors.surfaceContainerLow),
                  _buildDetailRow(
                    icon: LucideIcons.phone,
                    label: 'Primary Contact',
                    value: currentUser.phone ?? 'Not provided',
                  ),
                  const Divider(height: 1, color: AppColors.surfaceContainerLow),
                  _buildDetailRow(
                    icon: LucideIcons.fingerprint,
                    label: 'Resident ID',
                    value: 'NBR-#00${currentUser.id}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionBtn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.outline),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
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
}
