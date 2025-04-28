import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sp_sharia_stock/core/networking/api_error_handler.dart';
import 'package:sp_sharia_stock/core/networking/api_result.dart';
import 'package:sp_sharia_stock/features/home/data/domain/models/chart_interval.dart';
import 'package:sp_sharia_stock/features/home/data/domain/models/chart_response.dart';
import 'package:sp_sharia_stock/features/home/data/domain/stock_api_client.dart';
import 'package:sp_sharia_stock/features/home/data/repository/models/stock_model.dart';
import 'package:sp_sharia_stock/features/home/data/repository/stock_repository.dart';

import 'stock_repository_test.mocks.dart';

// Run: flutter pub run build_runner build
@GenerateMocks([StockApiClient])
void main() {
  late MockStockApiClient mockStockApiClient;
  late StockRepository stockRepository;

  setUp(() {
    mockStockApiClient = MockStockApiClient();
    stockRepository = StockRepository(stockApiClient: mockStockApiClient);
  });

  group('getStockChartData', () {
    final fromDate = DateTime(2023, 1, 1);
    final toDate = DateTime(2023, 12, 31);
    final interval = ChartInterval.day;

    // Calculate the expected timestamps (seconds since epoch)
    final fromTimestamp = fromDate.millisecondsSinceEpoch ~/ 1000;
    final toTimestamp = toDate.millisecondsSinceEpoch ~/ 1000;

    // Create a mock ChartResponse that matches what the API would return
    final mockChartResponse = createMockChartResponse();

    test('should return StockModel when API call is successful', () async {
      // Arrange
      when(
        mockStockApiClient.getStockChart(
          fromTimestamp: fromTimestamp,
          toTimestamp: toTimestamp,
          interval: interval.toApiString(),
        ),
      ).thenAnswer((_) async => ApiResult.success(mockChartResponse));

      // Act
      final result = await stockRepository.getStockChartData(
        fromDate: fromDate,
        toDate: toDate,
        interval: interval,
      );

      // Assert
      expect(result, isA<Success<StockModel>>());

      final stockModel = (result as Success<StockModel>).data;
      expect(stockModel.symbol, equals('SPUS'));
      expect(stockModel.companyName, equals('SP Funds S&P 500 Sharia Industr'));
      expect(stockModel.currentPrice, equals(38.57));
      expect(stockModel.candlestickData.entries.length, equals(2));

      // Check the first candlestick entry
      final firstEntry = stockModel.candlestickData.entries.first;
      expect(firstEntry.timestamp, equals(1701406800));
      expect(firstEntry.open, equals(32.75));
      expect(firstEntry.high, equals(34.375));
      expect(firstEntry.low, equals(32.43));
      expect(firstEntry.close, equals(34.20));
      expect(firstEntry.volume, equals(2819700));

      // Verify the API client was called with correct parameters
      verify(
        mockStockApiClient.getStockChart(
          fromTimestamp: fromTimestamp,
          toTimestamp: toTimestamp,
          interval: interval.toApiString(),
        ),
      ).called(1);
    });

    test('should return ApiResult.failure when API call fails', () async {
      // Arrange
      final errorHandler = ErrorHandler.handle(Exception('API Error'));
      when(
        mockStockApiClient.getStockChart(
          fromTimestamp: fromTimestamp,
          toTimestamp: toTimestamp,
          interval: interval.toApiString(),
        ),
      ).thenAnswer((_) async => ApiResult.failure(errorHandler));

      // Act
      final result = await stockRepository.getStockChartData(
        fromDate: fromDate,
        toDate: toDate,
        interval: interval,
      );

      // Assert
      expect(result, isA<Failure<StockModel>>());

      // Verify the API client was called with correct parameters
      verify(
        mockStockApiClient.getStockChart(
          fromTimestamp: fromTimestamp,
          toTimestamp: toTimestamp,
          interval: interval.toApiString(),
        ),
      ).called(1);
    });

    test('should convert DateTime to Unix timestamps correctly', () async {
      // Arrange
      when(
        mockStockApiClient.getStockChart(
          fromTimestamp: anyNamed('fromTimestamp'),
          toTimestamp: anyNamed('toTimestamp'),
          interval: anyNamed('interval'),
        ),
      ).thenAnswer((_) async => ApiResult.success(mockChartResponse));

      // Act
      await stockRepository.getStockChartData(
        fromDate: fromDate,
        toDate: toDate,
        interval: interval,
      );

      // Assert - Verify the exact timestamp values
      verify(
        mockStockApiClient.getStockChart(
          fromTimestamp: fromTimestamp, // 1672531200 (2023-01-01)
          toTimestamp: toTimestamp, // 1704067200 (2023-12-31)
          interval: interval.toApiString(),
        ),
      ).called(1);
    });
  });
}

// Helper function to create a mock ChartResponse for testing
ChartResponse createMockChartResponse() {
  // This creates a simplified version of what the API might return
  return ChartResponse(
    chart: Chart(
      result: [
        ChartResult(
          meta: Meta(
            currency: 'USD',
            symbol: 'SPUS',
            exchangeName: 'PCX',
            fullExchangeName: 'NYSEArca',
            instrumentType: 'ETF',
            firstTradeDate: 1576679400,
            regularMarketTime: 1745611200,
            hasPrePostMarketData: true,
            gmtoffset: -14400,
            timezone: 'EDT',
            exchangeTimezoneName: 'America/New_York',
            regularMarketPrice: 38.57,
            fiftyTwoWeekHigh: 44.69,
            fiftyTwoWeekLow: 33.32,
            regularMarketDayHigh: 38.63,
            regularMarketDayLow: 38.025,
            regularMarketVolume: 347015,
            longName: 'SP Funds S&P 500 Sharia Industry Exclusions ETF',
            shortName: 'SP Funds S&P 500 Sharia Industr',
            chartPreviousClose: 31.36,
            priceHint: 2,
            currentTradingPeriod: TradingPeriod(
              pre: TradingPeriodDetails(
                timezone: 'EDT',
                start: 1745568000,
                end: 1745587800,
                gmtoffset: -14400,
              ),
              regular: TradingPeriodDetails(
                timezone: 'EDT',
                start: 1745587800,
                end: 1745611200,
                gmtoffset: -14400,
              ),
              post: TradingPeriodDetails(
                timezone: 'EDT',
                start: 1745611200,
                end: 1745625600,
                gmtoffset: -14400,
              ),
            ),
            dataGranularity: '1mo',
            range: '',
            validRanges: [
              '1d',
              '5d',
              '1mo',
              '3mo',
              '6mo',
              '1y',
              '2y',
              '5y',
              '10y',
              'ytd',
              'max',
            ],
          ),
          timestamp: [1701406800, 1704085200],
          indicators: Indicators(
            quote: [
              Quote(
                volume: [2819700, 2315500],
                open: [32.75, 33.90],
                high: [34.375, 35.69],
                low: [32.43, 33.27],
                close: [34.20, 34.82],
              ),
            ],
            adjclose: [
              AdjClose(adjclose: [33.85, 34.47]),
            ],
          ),
        ),
      ],
      error: null,
    ),
  );
}
