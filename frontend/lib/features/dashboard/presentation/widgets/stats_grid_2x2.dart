import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class StatsGrid2x2 extends StatelessWidget {
  final int? verifiedUsersCount;
  final VoidCallback? onUsersTap;

  const StatsGrid2x2({super.key, this.verifiedUsersCount, this.onUsersTap});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Stat 1: Verified Users
        _buildStatTile(
          onTap: onUsersTap,
          title: 'Verified Users',
          value: verifiedUsersCount != null
              ? verifiedUsersCount.toString()
              : '2,845',
          icon: LucideIcons.users,
          iconBg: AppColors.secondaryContainer.withValues(alpha: 0.25),
          iconColor: AppColors.primaryContainer,
          badge: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.trendingUp,
                  size: 11,
                  color: Color(0xFF16A34A),
                ),
                SizedBox(width: 2),
                Text(
                  '+12.4%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
          footerNote: 'this mo',
        ),

        // Stat 2: Active Leases
        _buildStatTile(
          title: 'Active Leases',
          value: '1,420',
          icon: LucideIcons.key,
          iconBg: AppColors.surfaceContainerHigh,
          iconColor: AppColors.onSurfaceVariant,
          badge: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '98.2%',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10,
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          footerNote: 'occupancy',
        ),

        // Stat 3: Pending Approvals (Coral Urgency)
        _buildStatTile(
          title: 'Pending Approvals',
          value: '24',
          icon: LucideIcons.clockAlert,
          iconBg: const Color(0xFFFF5A3C).withValues(alpha: 0.12),
          iconColor: const Color(0xFFFF5A3C),
          badge: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFF5A3C),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Needs Action',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          footerNote: '8 agreements expiring',
        ),

        // Stat 4: Monthly Revenue
        _buildStatTile(
          title: 'Monthly Rev',
          value: '₹42.8L',
          icon: LucideIcons.wallet,
          iconBg: AppColors.primaryFixed.withValues(alpha: 0.3),
          iconColor: AppColors.primary,
          badge: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.arrowUpRight,
                  size: 11,
                  color: Color(0xFF16A34A),
                ),
                SizedBox(width: 1),
                Text(
                  '+8.1%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
          footerNote: 'MoM',
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Widget badge,
    String? footerNote,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Title + Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconBg,
                  ),
                  child: Icon(icon, size: 15, color: iconColor),
                ),
              ],
            ),

            // Bottom Block: Value + Badge on top row, footerNote clearly below
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: AppTextStyles.h2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(child: badge),
                  ],
                ),
                if (footerNote != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    footerNote,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.outline,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
