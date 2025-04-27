import 'package:dio/dio.dart';

/// Custom interceptors for API requests
class AppInterceptors extends Interceptor {
  /// Called when request is created
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add any request pre-processing here
    // For example: adding common query parameters, request timestamps, etc.

    // Always call super to continue the request
    super.onRequest(options, handler);
  }

  /// Called when response is received
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Add any response post-processing here
    // For example: logging, common response handling, etc.

    // Always call super to continue the response
    super.onResponse(response, handler);
  }

  /// Called when error occurs
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle common errors here
    // For example: refresh token on 401, retry logic, etc.

    // Always call super to continue the error handling
    super.onError(err, handler);
  }
}
