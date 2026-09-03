import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RecentActivityFeed extends StatelessWidget {
  final VoidCallback? onViewAll;

  const RecentActivityFeed({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with Ping indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Recent Activity',
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFF5A3C),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: onViewAll ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Viewing all audit logs.')),
                    );
                  },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View All',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Activity Card Container
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Activity 1: Vikram Malhotra
              _buildActivityItem(
                context,
                name: 'Vikram Malhotra',
                time: '12m ago',
                actionText: 'Approved rental agreement for ',
                actionHighlight: 'Villa 42',
                avatarUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuAGqLR2PdMXwdVZ5OxH1jAA6Vp_f_KeyQoGoQsh4PV4eIlESBg58qDFBOHTQ-MWbQbbYMfUE-504JbieYBazipbFbtCMuHpIWt83hqt3E0eqsvJNLVxs_KbeRBd2rNnNYqSApXWB9bg2-Vt0B6jQ_oB3E9olwKCdcFNrE2nXlo-ysrVeIjWmHhGceKG5XCWqM33JRwIgUCia1CVXcY4MQYcJ6bYdz9TS8UoSHSCWR8p9bwWJhQMmRc',
                badgeIcon: LucideIcons.check,
                badgeColor: const Color(0xFF16A34A),
                initials: 'VM',
                chips: [
                  _buildChip('Digitally Signed', AppColors.surfaceContainerLow, AppColors.onSurfaceVariant),
                  _buildChip('₹65,000/mo', AppColors.primaryContainer.withValues(alpha: 0.1), AppColors.primaryContainer),
                ],
              ),
              const Divider(height: 24, color: AppColors.surfaceContainerLow),

              // Activity 2: Priya Sharma
              _buildActivityItem(
                context,
                name: 'Priya Sharma',
                time: '35m ago',
                actionText: 'Uploaded identity proof (',
                actionHighlight: 'KYC Verified',
                highlightColor: const Color(0xFF16A34A),
                trailingCloseParen: true,
                avatarUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCanGIJ7rJsA-XihADA7hTcmYdZnEf1q8tQaJhfgfGgsYAiBawHLqnusqttn8U6XJDZOulz-2ufXTTKuTCWqOki5IYkFPSDZkOtC83bEwra9f-kbV8z1hnKaJn6b5CKM6n91Blw6LBaRBiwFrmz137nZZKRhisVVBEeUszLRhcpxUZE4Bcgsu0RTpsYOsgtWxkoT310DcdN19DAv9bj5aatd9W5Lldsr0duFLYOgGxuooW640NgbSQ',
                badgeIcon: LucideIcons.shield,
                badgeColor: AppColors.primaryContainer,
                initials: 'PS',
                chips: [
                  _buildChip('Aadhaar Instant Match', const Color(0xFF16A34A).withValues(alpha: 0.12), const Color(0xFF16A34A)),
                  _buildChip('Wing B • 502', AppColors.surfaceContainerLow, AppColors.onSurfaceVariant),
                ],
              ),
              const Divider(height: 24, color: AppColors.surfaceContainerLow),

              // Activity 3: Sneha Patel
              _buildActivityItem(
                context,
                name: 'Sneha Patel',
                time: '1h ago',
                actionText: 'Requested maintenance for ',
                actionHighlight: 'A-304',
                avatarUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuACTgcdT37DuCG_gwGNZG_rkgd515aZEJO159lMkd9aQmUbSlbnzFVFyjlG5JD0-SvrRZecn43_NTw118z10i-PSM59rw35W1XlnNxXkQmZZ12V-knVY9w_1UElQpNnz40PBxHjCWK8FcXF0MjFsiosIkaISV2ThdpbSRczDP0tkUvYwPvaIHEvgHUyWDo3OuN5Ya5pj8Dejbylzwp14e-qeTmOPX4FFDoYEdrCJDRoYuIRXFaxCOc',
                badgeIcon: LucideIcons.wrench,
                badgeColor: const Color(0xFFFF5A3C),
                initials: 'SP',
                chips: [
                  _buildChip('Plumbing • High Priority', AppColors.errorContainer.withValues(alpha: 0.5), AppColors.error),
                ],
                trailingAction: GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Assigning maintenance technician...')),
                    );
                  },
                  child: Text(
                    'Assign',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required String name,
    required String time,
    required String actionText,
    required String actionHighlight,
    required String avatarUrl,
    required IconData badgeIcon,
    required Color badgeColor,
    required String initials,
    required List<Widget> chips,
    Color? highlightColor,
    bool trailingCloseParen = false,
    Widget? trailingAction,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar + Status Badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                avatarUrl,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: AppColors.primaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surfaceContainerLowest,
                    width: 2,
                  ),
                ),
                child: Icon(badgeIcon, size: 8, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),

        // Text & Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.labelLg.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    time,
                    style: AppTextStyles.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(text: actionText),
                    TextSpan(
                      text: actionHighlight,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: highlightColor ?? AppColors.onSurface,
                      ),
                    ),
                    if (trailingCloseParen) const TextSpan(text: ')'),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  ...chips.map((c) => Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: c,
                      )),
                  if (trailingAction != null) ...[
                    const Spacer(),
                    trailingAction,
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: text,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
