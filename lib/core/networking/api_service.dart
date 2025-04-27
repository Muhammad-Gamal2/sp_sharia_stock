import 'package:dio/dio.dart';

import 'api_error_handler.dart';
import 'api_result.dart';
import 'app_interceptors.dart';

/// Base API URLs for different environments
abstract class ApiBaseUrl {
  static const String dev = "https://query2.finance.yahoo.com/";
}

/// Default request timeout in milliseconds
const int _defaultTimeout = 30000;

/// API Service for handling network requests
class ApiService {
  final Dio _dio;

  /// Creates an API service with configured Dio instance
  ApiService() : _dio = Dio() {
    _configureDio();
  }

  /// Creates an API service with a pre-configured Dio instance (useful for testing)
  ApiService.withDio(this._dio);

  /// Configure Dio with default settings
  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: ApiBaseUrl.dev,
      connectTimeout: Duration(milliseconds: _defaultTimeout),
      receiveTimeout: Duration(milliseconds: _defaultTimeout),
      sendTimeout: Duration(milliseconds: _defaultTimeout),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    // Add app interceptors
    _dio.interceptors.add(AppInterceptors());

    // Add logging interceptor in debug mode
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  /// Performs a GET request
  ///
  /// [path] The API endpoint path
  /// [queryParameters] Optional query parameters
  /// [options] Optional Dio request options
  Future<ApiResult<T>> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return ApiResult.success(_handleResponse<T>(response));
    } on DioException catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  /// Performs a POST request
  ///
  /// [path] The API endpoint path
  /// [data] The request body
  /// [queryParameters] Optional query parameters
  /// [options] Optional Dio request options
  Future<ApiResult<T>> post<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return ApiResult.success(_handleResponse<T>(response));
    } on DioException catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  /// Performs a PUT request
  ///
  /// [path] The API endpoint path
  /// [data] The request body
  /// [queryParameters] Optional query parameters
  /// [options] Optional Dio request options
  Future<ApiResult<T>> put<T>({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return ApiResult.success(_handleResponse<T>(response));
    } on DioException catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  /// Performs a DELETE request
  ///
  /// [path] The API endpoint path
  /// [queryParameters] Optional query parameters
  /// [options] Optional Dio request options
  Future<ApiResult<T>> delete<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      return ApiResult.success(_handleResponse<T>(response));
    } on DioException catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    } catch (error) {
      return ApiResult.failure(ErrorHandler.handle(error));
    }
  }

  /// Handle API response and convert to the requested type
  T _handleResponse<T>(Response<dynamic> response) {
    final data = response.data;

    if (data == null) {
      throw Exception('Response data is null');
    }

    if (T == dynamic) {
      return data as T;
    }

    // For primitive types like String, int, bool
    if (T == String || T == int || T == bool) {
      return data as T;
    }

    // For List type
    if (T.toString().startsWith('List<')) {
      if (data is List) {
        return data as T;
      }
      throw Exception('Expected list but got ${data.runtimeType}');
    }

    // For Map type
    if (T.toString() == 'Map<String, dynamic>') {
      if (data is Map<String, dynamic>) {
        return data as T;
      }
      throw Exception(
        'Expected Map<String, dynamic> but got ${data.runtimeType}',
      );
    }

    // Fallback for any other type
    return data as T;
  }
}
