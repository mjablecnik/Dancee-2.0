import 'package:dio/dio.dart';
import 'config.dart';
import 'exceptions.dart';

/// HTTP client wrapper for making API calls to the backend service.
///
/// This class wraps Dio functionality and provides a clean interface
/// for making HTTP requests with proper error handling, logging, and
/// configuration.
class ApiClient {
  final Dio _dio;
  
  /// Creates an ApiClient with the specified base URL.
  ///
  /// Configures Dio with timeouts, interceptors, and default headers.
  ApiClient({required String baseUrl}) : _dio = Dio() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(milliseconds: AppConfig.connectTimeout);
    _dio.options.receiveTimeout = Duration(milliseconds: AppConfig.receiveTimeout);
    _dio.options.sendTimeout = Duration(milliseconds: AppConfig.sendTimeout);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Add logging interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (obj) => print('[API] $obj'),
    ));
    
    // Add error interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        _handleError(error);
        handler.next(error);
      },
    ));
  }
  
  /// Makes a GET request to the specified path.
  ///
  /// Returns the response data on success.
  /// Throws ApiException on failure.
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _convertDioException(e);
    }
  }
  
  /// Makes a POST request to the specified path.
  ///
  /// Returns the response data on success.
  /// Throws ApiException on failure.
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _convertDioException(e);
    }
  }
  
  /// Makes a DELETE request to the specified path.
  ///
  /// Returns the response data on success.
  /// Throws ApiException on failure.
  Future<dynamic> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.delete(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _convertDioException(e);
    }
  }
  
  /// Checks if the backend service is available.
  ///
  /// Returns true if the health check succeeds, false otherwise.
  Future<bool> checkHealth() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Handles Dio errors and logs them.
  void _handleError(DioException error) {
    print('[API Error] ${error.type}: ${error.message}');
    if (error.response != null) {
      print('[API Error] Status: ${error.response?.statusCode}');
      print('[API Error] Data: ${error.response?.data}');
    }
  }
  
  /// Converts DioException to ApiException.
  ApiException _convertDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Request timeout. Please check your connection.',
          originalError: e,
        );
      
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Connection error. Please check your internet connection.',
          originalError: e,
        );
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final errorMessage = e.response?.data?['error'] ?? 'Server error occurred';
        return ApiException(
          message: errorMessage,
          statusCode: statusCode,
          originalError: e,
        );
      
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled',
          originalError: e,
        );
      
      default:
        return ApiException(
          message: 'An unexpected error occurred',
          originalError: e,
        );
    }
  }
}
