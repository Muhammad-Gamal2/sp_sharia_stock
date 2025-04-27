import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sp_sharia_stock/core/networking/api_error_handler.dart';
import 'package:sp_sharia_stock/core/networking/api_result.dart';
import 'package:sp_sharia_stock/core/networking/api_service.dart';
import 'package:sp_sharia_stock/features/home/data/domain/models/chart_response.dart';
import 'package:sp_sharia_stock/features/home/data/domain/stock_api_client.dart';

import 'stock_api_client_test.mocks.dart';

// Run: flutter pub run build_runner build
@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;
  late StockApiClient stockApiClient;

  setUp(() {
    mockApiService = MockApiService();
    stockApiClient = StockApiClient(apiService: mockApiService);
  });

  group('getStockChart', () {
    final fromTimestamp = 1699549200;
    final toTimestamp = 1731319200;
    final interval = '1mo';

    final mockResponseData = {
      'chart': {
        'result': [
          {
            'meta': {
              'currency': 'USD',
              'symbol': 'SPUS',
              'exchangeName': 'PCX',
              'fullExchangeName': 'NYSEArca',
              'instrumentType': 'ETF',
              'firstTradeDate': 1576679400,
              'regularMarketTime': 1745611200,
              'hasPrePostMarketData': true,
              'gmtoffset': -14400,
              'timezone': 'EDT',
              'exchangeTimezoneName': 'America/New_York',
              'regularMarketPrice': 38.57,
              'fiftyTwoWeekHigh': 44.69,
              'fiftyTwoWeekLow': 33.32,
              'regularMarketDayHigh': 38.63,
              'regularMarketDayLow': 38.025,
              'regularMarketVolume': 347015,
              'longName': 'SP Funds S&P 500 Sharia Industry Exclusions ETF',
              'shortName': 'SP Funds S&P 500 Sharia Industr',
              'chartPreviousClose': 31.36,
              'priceHint': 2,
              'currentTradingPeriod': {
                'pre': {
                  'timezone': 'EDT',
                  'start': 1745568000,
                  'end': 1745587800,
                  'gmtoffset': -14400,
                },
                'regular': {
                  'timezone': 'EDT',
                  'start': 1745587800,
                  'end': 1745611200,
                  'gmtoffset': -14400,
                },
                'post': {
                  'timezone': 'EDT',
                  'start': 1745611200,
                  'end': 1745625600,
                  'gmtoffset': -14400,
                },
              },
              'dataGranularity': '1mo',
              'range': '',
              'validRanges': [
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
            },
            'timestamp': [1701406800, 1704085200],
            'indicators': {
              'quote': [
                {
                  'volume': [2819700, 2315500],
                  'open': [32.75, 33.90],
                  'high': [34.375, 35.69],
                  'low': [32.43, 33.27],
                  'close': [34.20, 34.82],
                },
              ],
              'adjclose': [
                {
                  'adjclose': [33.85, 34.47],
                },
              ],
            },
          },
        ],
        'error': null,
      },
    };

    test('should return ChartResponse when API call is successful', () async {
      // Arrange
      when(
        mockApiService.get<Map<String, dynamic>>(
          path: 'v8/finance/chart/SPUS',
          queryParameters: {
            'period1': fromTimestamp,
            'period2': toTimestamp,
            'interval': interval,
          },
        ),
      ).thenAnswer((_) async => ApiResult.success(mockResponseData));

      // Act
      final result = await stockApiClient.getStockChart(
        fromTimestamp: fromTimestamp,
        toTimestamp: toTimestamp,
        interval: interval,
      );

      // Assert
      expect(result, isA<Success<ChartResponse>>());
      final chartResponse = (result as Success<ChartResponse>).data;
      expect(chartResponse.chart.result.length, 1);
      expect(chartResponse.chart.result[0].meta.symbol, 'SPUS');
      expect(chartResponse.chart.result[0].timestamp.length, 2);
      expect(
        chartResponse.chart.result[0].indicators.quote[0].volume.length,
        2,
      );

      // Verify API service was called with correct parameters
      verify(
        mockApiService.get<Map<String, dynamic>>(
          path: 'v8/finance/chart/SPUS',
          queryParameters: {
            'period1': fromTimestamp,
            'period2': toTimestamp,
            'interval': interval,
          },
        ),
      ).called(1);
    });

    test('should return ApiResult.failure when API call fails', () async {
      // Arrange
      final errorHandler = ErrorHandler.handle(Exception('API Error'));
      when(
        mockApiService.get<Map<String, dynamic>>(
          path: 'v8/finance/chart/SPUS',
          queryParameters: {
            'period1': fromTimestamp,
            'period2': toTimestamp,
            'interval': interval,
          },
        ),
      ).thenAnswer((_) async => ApiResult.failure(errorHandler));

      // Act
      final result = await stockApiClient.getStockChart(
        fromTimestamp: fromTimestamp,
        toTimestamp: toTimestamp,
        interval: interval,
      );

      // Assert
      expect(result, isA<Failure<ChartResponse>>());
    });

    test(
      'should return ApiResult.failure for no data available in date range',
      () async {
        // Arrange
        final mockErrorResponse = {
          'chart': {
            'result': null,
            'error': {
              'code': 'Bad Request',
              'description':
                  "Data doesn't exist for startDate = 40090566, endDate = 41590566",
            },
          },
        };

        when(
          mockApiService.get<Map<String, dynamic>>(
            path: 'v8/finance/chart/SPUS',
            queryParameters: {
              'period1': fromTimestamp,
              'period2': toTimestamp,
              'interval': interval,
            },
          ),
        ).thenAnswer(
          (_) async => ApiResult.failure(
            ErrorHandler.handle(
              DioException(
                requestOptions: RequestOptions(path: 'v8/finance/chart/SPUS'),
                type: DioExceptionType.badResponse,
                response: Response(
                  statusCode: 400,
                  data: mockErrorResponse,
                  requestOptions: RequestOptions(path: 'v8/finance/chart/SPUS'),
                ),
              ),
            ),
          ),
        );

        // Act
        final result = await stockApiClient.getStockChart(
          fromTimestamp: fromTimestamp,
          toTimestamp: toTimestamp,
          interval: interval,
        );

        // Assert
        expect(result, isA<Failure<ChartResponse>>());
        final failure = result as Failure<ChartResponse>;
        expect(failure.errorHandler.apiErrorModel.code, 400);
        expect(
          failure.errorHandler.apiErrorModel.message,
          "Data doesn't exist for startDate = 40090566, endDate = 41590566",
        );
      },
    );

    test('should validate interval parameter', () async {
      // Act & Assert
      expect(
        () => stockApiClient.getStockChart(
          fromTimestamp: fromTimestamp,
          toTimestamp: toTimestamp,
          interval: 'invalid',
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
