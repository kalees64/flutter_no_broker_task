import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/user_model.dart';
import '../models/user_list_response.dart';

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UsersRepository(apiClient: apiClient);
});

class UsersRepository {
  final ApiClient apiClient;

  UsersRepository({required this.apiClient});

  Future<UserListResponse> fetchUsers({
    int page = 1,
    int limit = 10,
    String? search,
    String? role,
    String? kycStatus,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (role != null && role != 'all') 'role': role,
      if (kycStatus != null && kycStatus != 'all') 'kycStatus': kycStatus,
    };

    final response = await apiClient.get(
      ApiEndpoints.users,
      queryParameters: queryParams,
    );

    final data = response['data'] as Map<String, dynamic>;
    return UserListResponse.fromJson(data);
  }

  Future<UserModel> getUserById(int id) async {
    final response = await apiClient.get('${ApiEndpoints.users}/$id');
    final data = response['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  Future<UserModel> createUser(Map<String, dynamic> payload) async {
    final response = await apiClient.post(
      ApiEndpoints.users,
      data: payload,
    );
    final data = response['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  Future<UserModel> updateUser(int id, Map<String, dynamic> payload) async {
    final response = await apiClient.patch(
      '${ApiEndpoints.users}/$id',
      data: payload,
    );
    final data = response['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  Future<void> deleteUser(int id) async {
    await apiClient.delete('${ApiEndpoints.users}/$id');
  }
}
