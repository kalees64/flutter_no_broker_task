import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends QueuedInterceptor {
  final SecureStorageService storage;
  final Dio _refreshDio;

  AuthInterceptor({
    required this.storage,
  }) : _refreshDio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Content-Type': 'application/json'},
          ),
        );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Avoid attaching token on public endpoints
    final path = options.path;
    final isPublic = path.contains(ApiEndpoints.login) ||
        path.contains(ApiEndpoints.register) ||
        path.contains(ApiEndpoints.refresh);

    if (!isPublic) {
      final token = await storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final requestPath = err.requestOptions.path;

    // Check if 401 Unauthorized and not already refreshing or logging in
    if (response?.statusCode == 401 &&
        !requestPath.contains(ApiEndpoints.refresh) &&
        !requestPath.contains(ApiEndpoints.login)) {
      final refreshToken = await storage.getRefreshToken();

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Attempt token refresh
          final refreshResponse = await _refreshDio.post(
            ApiEndpoints.refresh,
            data: {'refreshToken': refreshToken},
          );

          if (refreshResponse.statusCode == 200 &&
              refreshResponse.data?['success'] == true) {
            final data = refreshResponse.data['data'];
            final newAccessToken = data['accessToken'] as String;
            final newRefreshToken = data['refreshToken'] as String;

            // Save refreshed tokens
            await storage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );

            // Replay original request with updated token
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';

            final originDio = Dio(
              BaseOptions(
                baseUrl: ApiEndpoints.baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

            final cloneReq = await originDio.fetch(options);
            return handler.resolve(cloneReq);
          }
        } catch (_) {
          // Refresh failed - purge invalid tokens
          await storage.clearTokens();
        }
      }
    }

    return handler.next(err);
  }
}
