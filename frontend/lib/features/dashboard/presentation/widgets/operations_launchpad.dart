import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class OperationsLaunchpad extends StatelessWidget {
  const OperationsLaunchpad({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {
        'label': 'Add User',
        'icon': LucideIcons.userPlus,
        'hasBadge': false,
        'route': '/users/add',
      },
      {
        'label': 'Verify KYC',
        'icon': LucideIcons.badgeCheck,
        'hasBadge': true,
        'route': '/users',
      },
      {
        'label': 'Collect Rent',
        'icon': LucideIcons.wallet,
        'hasBadge': false,
        'route': '/services',
      },
      {
        'label': 'Maintenance',
        'icon': LucideIcons.wrench,
        'hasBadge': false,
        'route': '/services',
      },
      {
        'label': 'Gate Pass',
        'icon': LucideIcons.qrCode,
        'hasBadge': false,
        'route': '/services',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Operations Launchpad',
              style: AppTextStyles.h3.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Launchpad shortcuts are fully optimized.'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Customize',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: actions.map((act) {
              final label = act['label'] as String;
              final icon = act['icon'] as IconData;
              final hasBadge = act['hasBadge'] as bool;
              final route = act['route'] as String;

              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: InkWell(
                  onTap: () {
                    if (route == '/users/add') {
                      context.push(route);
                    } else if (route == '/users') {
                      context.go(route);
                    } else {
                      context.go(route);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 76,
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColors.outlineVariant.withValues(alpha: 0.35),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                icon,
                                size: 26,
                                color: AppColors.primaryContainer,
                              ),
                            ),
                            if (hasBadge)
                              Positioned(
                                top: -1,
                                right: -1,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFF5A3C),
                                    border: Border.all(
                                      color: AppColors.surfaceContainerLowest,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          style: AppTextStyles.labelMd.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
