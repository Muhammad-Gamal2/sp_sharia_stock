import 'package:dio/dio.dart';

import 'api_error_model.dart';

/// Error message constants
class ApiErrors {
  // API error messages
  static const String forbiddenError = "forbiddenError";
  static const String unauthorizedError = "unauthorizedError";
  static const String notFoundError = "notFoundError";
  static const String internalServerError = "internalServerError";

  // Connection error messages
  static const String timeoutError = "timeoutError";
  static const String defaultError = "defaultError";
  static const String cacheError = "cacheError";
  static const String noInternetError = "noInternetError";
}

/// Error response codes
class ResponseCode {
  // API status codes
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int internalServerError = 500;

  // Local error codes
  static const int connectTimeout = -1;
  static const int cancel = -2;
  static const int receiveTimeout = -3;
  static const int sendTimeout = -4;
  static const int defaultError = -5;
}

/// Error handler implementation
class ErrorHandler implements Exception {
  late ApiErrorModel apiErrorModel;

  ErrorHandler.handle(dynamic error) {
    if (error is DioException) {
      apiErrorModel = _handleDioError(error);
    } else {
      apiErrorModel = ApiErrorModel(
        code: ResponseCode.defaultError,
        message: ApiErrors.defaultError,
      );
    }
  }

  /// Handle Dio specific errors
  static ApiErrorModel _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiErrorModel(
          code: ResponseCode.connectTimeout,
          message: ApiErrors.timeoutError,
        );
      case DioExceptionType.sendTimeout:
        return ApiErrorModel(
          code: ResponseCode.sendTimeout,
          message: ApiErrors.timeoutError,
        );
      case DioExceptionType.receiveTimeout:
        return ApiErrorModel(
          code: ResponseCode.receiveTimeout,
          message: ApiErrors.timeoutError,
        );
      case DioExceptionType.badResponse:
        return _handleResponseError(error);
      case DioExceptionType.cancel:
        return ApiErrorModel(
          code: ResponseCode.cancel,
          message: ApiErrors.defaultError,
        );
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return ApiErrorModel(
          code: ResponseCode.defaultError,
          message: ApiErrors.defaultError,
        );
    }
  }

  /// Handle HTTP response errors
  static ApiErrorModel _handleResponseError(DioException error) {
    if (error.response == null) {
      return ApiErrorModel(
        code: ResponseCode.defaultError,
        message: ApiErrors.defaultError,
      );
    }

    switch (error.response?.statusCode) {
      case ResponseCode.badRequest:
        return ApiErrorModel(
          code: ResponseCode.badRequest,
          message: error.response?.data['chart']['error']['description'],
        );
      case ResponseCode.unauthorized:
        return ApiErrorModel(
          code: ResponseCode.unauthorized,
          message: ApiErrors.unauthorizedError,
        );
      case ResponseCode.forbidden:
        return ApiErrorModel(
          code: ResponseCode.forbidden,
          message: ApiErrors.forbiddenError,
        );
      case ResponseCode.notFound:
        return ApiErrorModel(
          code: ResponseCode.notFound,
          message: ApiErrors.notFoundError,
        );
      case ResponseCode.internalServerError:
        return ApiErrorModel(
          code: ResponseCode.internalServerError,
          message: ApiErrors.internalServerError,
        );
      default:
        // Try to parse error from response data if available
        try {
          return ApiErrorModel.fromJson(error.response!.data);
        } catch (_) {
          return ApiErrorModel(
            code: error.response?.statusCode ?? ResponseCode.defaultError,
            message: ApiErrors.defaultError,
          );
        }
    }
  }
}
