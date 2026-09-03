import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/models/user_model.dart';
import '../../data/repositories/users_repository.dart';

class UsersState {
  final List<UserModel> users;
  final int page;
  final int totalPages;
  final int totalItems;
  final Map<String, int>? counts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String searchQuery;
  final String selectedFilter;
  final String? errorMessage;
  final UserModel? pendingDeletedUser;
  final int? pendingDeletedIndex;

  const UsersState({
    this.users = const [],
    this.page = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.counts,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.searchQuery = '',
    this.selectedFilter = 'all',
    this.errorMessage,
    this.pendingDeletedUser,
    this.pendingDeletedIndex,
  });

  // Exact counts for every tab
  int get countAll => counts?['all'] ?? totalItems;
  int get countTenants => counts?['tenants'] ?? users.where((u) => u.role == 'tenant').length;
  int get countOwners => counts?['owners'] ?? users.where((u) => u.role == 'owner').length;
  int get countVendors => counts?['vendors'] ?? users.where((u) => u.role == 'vendor').length;
  int get countPending => counts?['pending'] ?? users.where((u) => u.kycStatus == 'pending').length;

  UsersState copyWith({
    List<UserModel>? users,
    int? page,
    int? totalPages,
    int? totalItems,
    Map<String, int>? counts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    String? searchQuery,
    String? selectedFilter,
    String? errorMessage,
    bool clearError = false,
    UserModel? pendingDeletedUser,
    int? pendingDeletedIndex,
    bool clearPendingDelete = false,
  }) {
    return UsersState(
      users: users ?? this.users,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      counts: counts ?? this.counts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pendingDeletedUser: clearPendingDelete
          ? null
          : (pendingDeletedUser ?? this.pendingDeletedUser),
      pendingDeletedIndex: clearPendingDelete
          ? null
          : (pendingDeletedIndex ?? this.pendingDeletedIndex),
    );
  }
}

final usersControllerProvider =
    StateNotifierProvider<UsersController, UsersState>((ref) {
  final repository = ref.watch(usersRepositoryProvider);
  return UsersController(repository: repository);
});

class UsersController extends StateNotifier<UsersState> {
  final UsersRepository repository;
  Timer? _debounceTimer;

  UsersController({required this.repository})
      : super(const UsersState()) {
    loadUsers();
  }

  Future<void> loadUsers({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(isRefreshing: true, clearError: true);
    } else {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      String? role;
      String? kycStatus;

      if (state.selectedFilter == 'tenants') {
        role = 'tenant';
      } else if (state.selectedFilter == 'owners') {
        role = 'owner';
      } else if (state.selectedFilter == 'vendors') {
        role = 'vendor';
      } else if (state.selectedFilter == 'pending') {
        kycStatus = 'pending';
      }

      final response = await repository.fetchUsers(
        page: 1,
        limit: 10,
        search: state.searchQuery,
        role: role,
        kycStatus: kycStatus,
      );

      state = state.copyWith(
        users: response.items,
        page: response.page,
        totalPages: response.totalPages,
        totalItems: response.totalItems,
        counts: response.counts,
        isLoading: false,
        isRefreshing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading || state.page >= state.totalPages) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.page + 1;
      String? role;
      String? kycStatus;

      if (state.selectedFilter == 'tenants') {
        role = 'tenant';
      } else if (state.selectedFilter == 'owners') {
        role = 'owner';
      } else if (state.selectedFilter == 'vendors') {
        role = 'vendor';
      } else if (state.selectedFilter == 'pending') {
        kycStatus = 'pending';
      }

      final response = await repository.fetchUsers(
        page: nextPage,
        limit: 10,
        search: state.searchQuery,
        role: role,
        kycStatus: kycStatus,
      );

      state = state.copyWith(
        users: [...state.users, ...response.items],
        page: response.page,
        totalPages: response.totalPages,
        totalItems: response.totalItems,
        counts: response.counts ?? state.counts,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      state = state.copyWith(searchQuery: query.trim());
      loadUsers();
    });
  }

  void onFilterChanged(String filter) {
    if (state.selectedFilter == filter) return;
    state = state.copyWith(selectedFilter: filter);
    loadUsers();
  }

  Future<bool> createUser(Map<String, dynamic> payload) async {
    try {
      final newUser = await repository.createUser(payload);
      state = state.copyWith(
        users: [newUser, ...state.users],
        totalItems: state.totalItems + 1,
        errorMessage: null,
      );
      loadUsers(refresh: true);
      return true;
    } on Exception catch (e) {
      state = state.copyWith(errorMessage: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> updateUser(int id, Map<String, dynamic> payload) async {
    try {
      final updated = await repository.updateUser(id, payload);
      state = state.copyWith(
        users: state.users.map((u) => u.id == id ? updated : u).toList(),
      );
      loadUsers(refresh: true);
      return true;
    } on Exception catch (e) {
      state = state.copyWith(errorMessage: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<UserModel?> refreshUser(int id) async {
    try {
      final fresh = await repository.getUserById(id);
      state = state.copyWith(
        users: state.users.map((u) => u.id == id ? fresh : u).toList(),
      );
      return fresh;
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteUserImmediately(int id) async {
    state = state.copyWith(
      users: state.users.where((u) => u.id != id).toList(),
      totalItems: state.totalItems > 0 ? state.totalItems - 1 : 0,
    );
    try {
      await repository.deleteUser(id);
      loadUsers(refresh: true);
      return true;
    } catch (e) {
      loadUsers(refresh: true);
      return false;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
