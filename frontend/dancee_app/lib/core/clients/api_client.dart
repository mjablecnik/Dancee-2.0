import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../exceptions/api_exception.dart';

/// HTTP client wrapper for making API calls to the backend service
/// 
/// This class wraps Dio and provides a consistent interface for making
/// HTTP requests with proper error handling, logging, and configuration.
class ApiClient {
  final Dio _dio;

  ApiClient({String? baseUrl}) : _dio = Dio() {
    // Configure Dio with base URL and timeouts
    _dio.options.baseUrl = baseUrl ?? ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(milliseconds: ApiConfig.connectionTimeout);
    _dio.options.receiveTimeout = const Duration(milliseconds: ApiConfig.receiveTimeout);
    _dio.options.sendTimeout = const Duration(milliseconds: ApiConfig.sendTimeout);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add logging interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => print('[API] $obj'),
      ),
    );

    // Add error interceptor for consistent error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // Convert DioException to ApiException
          final apiException = _handleDioError(error);
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: apiException,
              type: error.type,
            ),
          );
        },
      ),
    );
  }

  /// Make a GET request
  /// 
  /// [path] - API endpoint path (e.g., '/api/events')
  /// [queryParameters] - Optional query parameters
  /// 
  /// Returns the response data
  /// Throws [ApiException] on error
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw _handleDioError(e);
    }
  }

  /// Make a POST request
  /// 
  /// [path] - API endpoint path (e.g., '/api/favorites')
  /// [data] - Request body data
  /// 
  /// Returns the response data
  /// Throws [ApiException] on error
  Future<dynamic> post(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw _handleDioError(e);
    }
  }

  /// Make a DELETE request
  /// 
  /// [path] - API endpoint path (e.g., '/api/favorites/123')
  /// [queryParameters] - Optional query parameters
  /// 
  /// Returns the response data
  /// Throws [ApiException] on error
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw _handleDioError(e);
    }
  }

  /// Check backend health
  /// 
  /// Returns true if backend is available, false otherwise
  Future<bool> checkHealth() async {
    try {
      await _dio.get(ApiConfig.healthEndpoint);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Convert DioException to ApiException with user-friendly messages
  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Request timeout. Please check your internet connection.',
          error: error,
          stackTrace: error.stackTrace,
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Connection error. Please check your internet connection.',
          error: error,
          stackTrace: error.stackTrace,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        
        String message = 'Server error occurred.';
        if (responseData is Map && responseData.containsKey('error')) {
          message = responseData['error'].toString();
        } else if (statusCode != null) {
          message = 'Server error: HTTP $statusCode';
        }

        return ApiException(
          message: message,
          error: error,
          stackTrace: error.stackTrace,
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled.',
          error: error,
          stackTrace: error.stackTrace,
        );

      case DioExceptionType.unknown:
      default:
        return ApiException(
          message: 'An unexpected error occurred. Please try again.',
          error: error,
          stackTrace: error.stackTrace,
        );
    }
  }
}
