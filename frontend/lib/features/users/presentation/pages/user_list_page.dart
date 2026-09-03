import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/users_controller.dart';
import '../widgets/delete_confirm_dialog.dart';
import '../widgets/filter_chip_carousel.dart';
import '../widgets/user_card_item.dart';
import '../widgets/user_shimmer_skeleton.dart';

class UserListPage extends ConsumerStatefulWidget {
  const UserListPage({super.key});

  @override
  ConsumerState<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends ConsumerState<UserListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _previewSkeleton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(usersControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleDeleteUser(int id, String name) {
    DeleteConfirmDialog.show(
      context,
      userName: name,
      onConfirm: () async {
        final controller = ref.read(usersControllerProvider.notifier);
        final success = await controller.deleteUserImmediately(id);
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'User "$name" deleted successfully' : 'Failed to delete user'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersState = ref.watch(usersControllerProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
        elevation: 0.5,
        title: Row(
          children: [
            Image.asset(
              AppAssets.logo,
              height: 26,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Text(
              'User Directory',
              style: AppTextStyles.h3.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, size: 22, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 4.0),
            child: GestureDetector(
              onTap: () => context.go('/profile'),
              child: UserAvatar(
                name: authState.user?.name ?? 'Admin',
                size: 34,
                isVerified: true,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFF5A3C),
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(LucideIcons.userPlus, size: 20),
        label: const Text(
          'Add User',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        onPressed: () => context.push('/users/add'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(usersControllerProvider.notifier).loadUsers(refresh: true);
        },
        color: AppColors.primary,
        child: Column(
          children: [
            // Section Header & Skeleton Preview Toggle
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'User Directory',
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 20,
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${usersState.countAll} Users',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Skeleton Preview Mode Toggle
                  InkWell(
                    onTap: () {
                      setState(() {
                        _previewSkeleton = !_previewSkeleton;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _previewSkeleton
                            ? AppColors.primaryContainer
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.sparkles,
                            size: 13,
                            color: _previewSkeleton
                                ? AppColors.onPrimary
                                : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _previewSkeleton ? 'Showing Skeleton' : 'Preview Skeleton',
                            style: AppTextStyles.labelSm.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _previewSkeleton
                                  ? AppColors.onPrimary
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    ref.read(usersControllerProvider.notifier).onSearchChanged(val);
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name, email, flat no...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline),
                    prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppColors.outline),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(usersControllerProvider.notifier).onSearchChanged('');
                              setState(() {});
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Filter Chips Carousel
            FilterChipCarousel(
              selectedFilter: usersState.selectedFilter,
              countAll: usersState.countAll,
              countTenants: usersState.countTenants,
              countOwners: usersState.countOwners,
              countVendors: usersState.countVendors,
              countPending: usersState.countPending,
              onFilterSelected: (filter) {
                ref.read(usersControllerProvider.notifier).onFilterChanged(filter);
              },
            ),
            const SizedBox(height: 8),

            // Main List View
            Expanded(
              child: _previewSkeleton || usersState.isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: UserShimmerSkeleton(itemCount: 5),
                    )
                  : usersState.errorMessage != null && usersState.users.isEmpty
                      ? ErrorStateView(
                          message: usersState.errorMessage!,
                          onRetry: () => ref
                              .read(usersControllerProvider.notifier)
                              .loadUsers(refresh: true),
                        )
                      : usersState.users.isEmpty
                          ? EmptyStateView(
                              title: 'No Residents Found',
                              message: usersState.searchQuery.isNotEmpty
                                  ? 'No users match "${usersState.searchQuery}".'
                                  : 'There are no residents in this category.',
                              actionLabel: 'Reset Filters',
                              onAction: () {
                                _searchController.clear();
                                ref
                                    .read(usersControllerProvider.notifier)
                                    .onFilterChanged('all');
                              },
                            )
                          : ListView.separated(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                              itemCount: usersState.users.length +
                                  (usersState.isLoadingMore ? 1 : 0),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                if (index == usersState.users.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16.0),
                                      child: CircularProgressIndicator(strokeWidth: 2.5),
                                    ),
                                  );
                                }

                                final user = usersState.users[index];
                                return UserCardItem(
                                  user: user,
                                  onTap: () => context.push('/users/${user.id}', extra: user),
                                  onEdit: () => context.push('/users/${user.id}/edit', extra: user),
                                  onDelete: () => _handleDeleteUser(user.id, user.name),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
