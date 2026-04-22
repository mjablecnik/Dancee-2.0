import 'dart:developer' as developer;
import 'package:dio/dio.dart';

import 'config.dart';
import 'exceptions.dart';

/// Dio-based HTTP client for the Directus CMS REST API.
///
/// Handles authentication, Directus envelope unwrapping (`data` field
/// extraction), and maps HTTP errors and network failures to [ApiException].
class DirectusClient {
  DirectusClient({
    required String baseUrl,
    required String accessToken,
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                headers: {
                  'Authorization': 'Bearer $accessToken',
                  'Content-Type': 'application/json',
                },
                connectTimeout:
                    const Duration(milliseconds: AppConfig.connectionTimeoutMs),
                receiveTimeout:
                    const Duration(milliseconds: AppConfig.receiveTimeoutMs),
              ),
            );

  final Dio _dio;

  /// Performs a GET request and returns the unwrapped `data` field from the
  /// Directus response envelope.
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return _unwrap(response);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Performs a POST request and returns the unwrapped `data` field.
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
      );
      return _unwrap(response);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Performs a DELETE request.
  Future<void> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      await _dio.delete<void>(
        path,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  dynamic _unwrap(Response<Map<String, dynamic>> response) {
    final body = response.data;
    if (body == null) return null;
    return body['data'];
  }

  ApiException _mapDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: 'Connection timed out. Please check your network.',
          originalError: e,
        );
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Server took too long to respond. Please try again.',
          originalError: e,
        );
      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'Request timed out while sending data.',
          originalError: e,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection. Please check your network.',
          originalError: e,
        );
      case DioExceptionType.badResponse:
        // ignore: avoid_print
        print(
          '[DirectusClient] badResponse: status=$statusCode '
          'body=${e.response?.data}',
        );
        return ApiException(
          statusCode: statusCode,
          message: _messageForStatusCode(statusCode),
          originalError: e,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled.',
          originalError: e,
        );
      default:
        return ApiException(
          statusCode: statusCode,
          message: e.message ?? 'An unexpected error occurred.',
          originalError: e,
        );
    }
  }

  String _messageForStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please try again.';
      case 401:
        return 'Authentication failed. Check your CMS access token.';
      case 403:
        return 'Access denied. Check your CMS permissions.';
      case 404:
        return 'The requested resource was not found.';
      case 409:
        return 'Conflict — the resource already exists.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. The server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        if (statusCode != null && statusCode >= 400 && statusCode < 500) {
          return 'Client error ($statusCode). Please try again.';
        }
        if (statusCode != null && statusCode >= 500) {
          return 'Server error ($statusCode). Please try again later.';
        }
        return 'An unexpected error occurred.';
    }
  }
}
