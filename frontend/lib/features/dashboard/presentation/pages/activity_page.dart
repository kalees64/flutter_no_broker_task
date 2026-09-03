import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/recent_activity_feed.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0.5,
        title: Text(
          'Operations & Audit Log',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryContainer.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.shieldCheck, color: AppColors.primaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All society actions are cryptographically signed and stored in the PostgreSQL audit log.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const RecentActivityFeed(),
          ],
        ),
      ),
    );
  }
}
