import 'package:sp_sharia_stock/core/networking/api_error_handler.dart';
import 'package:sp_sharia_stock/core/networking/api_result.dart';
import 'package:sp_sharia_stock/features/home/data/domain/models/chart_interval.dart';
import 'package:sp_sharia_stock/features/home/data/domain/models/chart_response.dart';
import 'package:sp_sharia_stock/features/home/data/domain/stock_api_client.dart';
import 'package:sp_sharia_stock/features/home/data/repository/models/stock_model.dart';

/// Repository for handling stock-related data operations
class StockRepository {
  final StockApiClient _stockApiClient;

  /// Creates a new StockRepository with the given [stockApiClient]
  StockRepository({required StockApiClient stockApiClient})
    : _stockApiClient = stockApiClient;

  /// Fetches stock chart data for the specified date range and interval
  ///
  /// [fromDate] The start date
  /// [toDate] The end date
  /// [interval] The data interval (day, week, month)
  ///
  /// Returns ApiResult'<'StockModel'>' with data optimized for chart visualization
  Future<ApiResult<StockModel>> getStockChartData({
    required DateTime fromDate,
    required DateTime toDate,
    required ChartInterval interval,
  }) async {
    // Convert DateTime to Unix timestamps (seconds since epoch)
    final fromTimestamp = fromDate.millisecondsSinceEpoch ~/ 1000;
    final toTimestamp = toDate.millisecondsSinceEpoch ~/ 1000;

    // Call the API client with the converted parameters
    final result = await _stockApiClient.getStockChart(
      fromTimestamp: fromTimestamp,
      toTimestamp: toTimestamp,
      interval: interval.toApiString(),
    );

    // Map the API result to StockModel result
    if (result is Success<ChartResponse>) {
      // Convert ChartResponse to StockModel using the extension method
      final stockModel = result.data.toStockModel();
      return ApiResult.success(stockModel);
    } else if (result is Failure<ChartResponse>) {
      // Pass through any errors
      return ApiResult.failure(result.errorHandler);
    } else {
      // Fallback for any unexpected result type
      return ApiResult.failure(ErrorHandler.handle(''));
    }
  }
}
