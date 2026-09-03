import 'package:dio/dio.dart';

class AppNetworkException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final dynamic details;

  AppNetworkException({
    required this.message,
    this.code,
    this.statusCode,
    this.details,
  });

  factory AppNetworkException.fromDioError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] as String? ?? 'An error occurred';
        final code = data['code'] as String? ?? 'UNKNOWN_ERROR';
        return AppNetworkException(
          message: message,
          code: code,
          statusCode: error.response?.statusCode,
          details: data['errors'],
        );
      }
      return AppNetworkException(
        message: 'Server error: ${error.response?.statusCode}',
        statusCode: error.response?.statusCode,
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppNetworkException(
          message: 'Connection timed out. Please check your internet connection.',
          code: 'TIMEOUT',
        );
      case DioExceptionType.connectionError:
        return AppNetworkException(
          message: 'Cannot reach server. Ensure backend server is running.',
          code: 'CONNECTION_ERROR',
        );
      case DioExceptionType.cancel:
        return AppNetworkException(
          message: 'Request was cancelled.',
          code: 'CANCELLED',
        );
      default:
        return AppNetworkException(
          message: error.message ?? 'Unexpected network error occurred',
          code: 'UNKNOWN',
        );
    }
  }

  @override
  String toString() => message;
}
