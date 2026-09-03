import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient: apiClient);
});

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  Future<AuthResponseModel> login({
    required String identifier,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.login,
      data: {
        'identifier': identifier.trim(),
        'password': password,
      },
    );

    final data = response['data'] as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data);
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? role,
    String? flatNumber,
    String? societyName,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.register,
      data: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
        'role': ?role,
        if (flatNumber != null && flatNumber.trim().isNotEmpty)
          'flatNumber': flatNumber.trim(),
        if (societyName != null && societyName.trim().isNotEmpty)
          'societyName': societyName.trim(),
      },
    );

    final data = response['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout({required String refreshToken}) async {
    await apiClient.post(
      ApiEndpoints.logout,
      data: {'refreshToken': refreshToken},
    );
  }

  Future<UserModel> getProfile() async {
    final response = await apiClient.get(ApiEndpoints.me);
    final data = response['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile(int userId, Map<String, dynamic> payload) async {
    final response = await apiClient.patch(
      '${ApiEndpoints.users}/$userId',
      data: payload,
    );
    final data = response['data'] as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }
}
