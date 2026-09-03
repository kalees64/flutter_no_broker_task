import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/data/models/user_model.dart';

class UserCardItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserCardItem({
    super.key,
    required this.user,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  String get _initials {
    final parts = user.name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'U';
    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = user.kycStatus == 'verified';
    final roleFormatted = user.role[0].toUpperCase() + user.role.substring(1);
    final location = [
      user.flatNumber,
      user.societyName,
    ].where((e) => e != null && e.trim().isNotEmpty).join(', ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with Hero
                Hero(
                  tag: 'user-avatar-${user.id}',
                  child: Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryContainer,
                              AppColors.primary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isVerified
                                ? const Color(0xFF16A34A)
                                : const Color(0xFFFF5A3C),
                            border: Border.all(
                              color: AppColors.surfaceContainerLowest,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.name,
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            LucideIcons.badgeCheck,
                            size: 16,
                            color: AppColors.primaryContainer,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        location.isNotEmpty
                            ? '$roleFormatted • $location'
                            : roleFormatted,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isVerified
                        ? AppColors.surfaceContainerLow
                        : const Color(0xFFFF5A3C).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isVerified
                              ? AppColors.primaryContainer
                              : const Color(0xFFFF5A3C),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isVerified ? 'KYC Verified' : 'Pending',
                        style: AppTextStyles.labelSm.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isVerified
                              ? AppColors.onSurface
                              : const Color(0xFFFF5A3C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bottom Action Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.phone,
                        size: 14,
                        color: AppColors.outline,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.phone ?? '+91 98450 12345',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurface,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Call action
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          LucideIcons.phoneCall,
                          size: 16,
                          color: AppColors.primaryContainer,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Dialing ${user.phone ?? "user"}...'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      // More Popup
                      PopupMenuButton<String>(
                        icon: const Icon(
                          LucideIcons.moreVertical,
                          size: 16,
                          color: AppColors.outline,
                        ),
                        padding: EdgeInsets.zero,
                        onSelected: (val) {
                          if (val == 'view') {
                            onTap();
                          } else if (val == 'edit') {
                            onEdit();
                          } else if (val == 'delete') {
                            onDelete();
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(LucideIcons.eye, size: 16),
                                SizedBox(width: 8),
                                Text('View Details'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(LucideIcons.pencil, size: 16),
                                SizedBox(width: 8),
                                Text('Edit User'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(LucideIcons.trash2, size: 16, color: AppColors.error),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: AppColors.error)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
