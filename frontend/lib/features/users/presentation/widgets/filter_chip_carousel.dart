import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class FilterChipCarousel extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  final int countAll;
  final int countTenants;
  final int countOwners;
  final int countVendors;
  final int countPending;

  const FilterChipCarousel({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    this.countAll = 0,
    this.countTenants = 0,
    this.countOwners = 0,
    this.countVendors = 0,
    this.countPending = 0,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': 'all', 'label': 'All', 'count': '$countAll'},
      {'key': 'tenants', 'label': 'Tenants', 'count': '$countTenants'},
      {'key': 'owners', 'label': 'Owners', 'count': '$countOwners'},
      {'key': 'vendors', 'label': 'Vendors', 'count': '$countVendors'},
      {
        'key': 'pending',
        'label': 'Pending KYC',
        'count': '$countPending',
        'isAlert': countPending > 0,
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: filters.map((f) {
          final isSelected = selectedFilter == f['key'];
          final isAlert = f['isAlert'] == true;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => onFilterSelected(f['key'] as String),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryContainer
                      : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryContainer
                        : AppColors.outlineVariant.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppColors.primaryContainer.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAlert) ...[
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFF5A3C),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      f['label'] as String,
                      style: AppTextStyles.labelMd.copyWith(
                        color: isSelected
                            ? AppColors.onPrimary
                            : AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      f['count'] as String,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected
                            ? AppColors.onPrimary.withValues(alpha: 0.8)
                            : AppColors.outline,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
