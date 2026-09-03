import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class QuickActionSheet extends StatelessWidget {
  const QuickActionSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const QuickActionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'title': 'New Tenant',
        'desc': 'Issue onboarding link',
        'icon': LucideIcons.userPlus,
        'color': const Color(0xFFFF5A3C),
        'onTap': () {
          Navigator.pop(context);
          context.push('/users/add');
        },
      },
      {
        'title': 'Create Invoice',
        'desc': 'Maintenance or deposit',
        'icon': LucideIcons.receipt,
        'color': AppColors.primaryContainer,
        'onTap': () {
          Navigator.pop(context);
          context.go('/services');
        },
      },
      {
        'title': 'Digital Pass',
        'desc': 'Generate QR gate token',
        'icon': LucideIcons.qrCode,
        'color': const Color(0xFF16A34A),
        'onTap': () {
          Navigator.pop(context);
          context.go('/services');
        },
      },
      {
        'title': 'Broadcast',
        'desc': 'Alert cluster tenants',
        'icon': LucideIcons.megaphone,
        'color': AppColors.secondary,
        'onTap': () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cluster broadcast notification queued.')),
          );
        },
      },
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),

          // Title & Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Action Dispatch',
                style: AppTextStyles.h2.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(LucideIcons.x, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2x2 Grid of Actions
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
            ),
            itemBuilder: (context, index) {
              final item = actions[index];
              final title = item['title'] as String;
              final desc = item['desc'] as String;
              final icon = item['icon'] as IconData;
              final color = item['color'] as Color;
              final onTap = item['onTap'] as VoidCallback;

              return InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 24, color: color),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        desc,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
