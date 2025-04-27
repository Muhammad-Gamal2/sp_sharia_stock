
import 'package:sp_sharia_stock/core/networking/api_error_handler.dart';
import 'package:sp_sharia_stock/core/networking/api_result.dart';
import 'package:sp_sharia_stock/core/networking/api_service.dart';
import 'models/chart_response.dart';

/// Client for the Yahoo Finance API
class StockApiClient {
  final ApiService _apiService;

  StockApiClient({required ApiService apiService}) : _apiService = apiService;

  /// Fetches stock chart data for SPUS
  ///
  /// [fromTimestamp] The start timestamp (Unix time in seconds)
  /// [toTimestamp] The end timestamp (Unix time in seconds)
  /// [interval] The data interval ("1d", "1wk", or "1mo")
  Future<ApiResult<ChartResponse>> getStockChart({
    required int fromTimestamp,
    required int toTimestamp,
    required String interval,
  }) async {
    assert(
      interval == "1d" || interval == "1wk" || interval == "1mo",
      "Interval must be one of: 1d, 1wk, 1mo",
    );

    final queryParams = {
      'period1': fromTimestamp,
      'period2': toTimestamp,
      'interval': interval,
    };

    try {
      final result = await _apiService.get<Map<String, dynamic>>(
        path: 'v8/finance/chart/SPUS',
        queryParameters: queryParams,
      );

      if (result is Success<Map<String, dynamic>>) {
        final data = result.data;
        final chartResponse = ChartResponse.fromJson(data);
        return ApiResult.success(chartResponse);
      } else if (result is Failure<Map<String, dynamic>>) {
        return ApiResult.failure(result.errorHandler);
      } else {
        final error = Exception('Unknown API result type');
        return ApiResult.failure(ErrorHandler.handle(error));
      }
    } catch (e) {
      return ApiResult.failure(ErrorHandler.handle(e));
    }
  }
}
