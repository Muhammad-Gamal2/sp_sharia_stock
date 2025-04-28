import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sp_sharia_stock/core/helpers/request_status.dart';
import 'package:sp_sharia_stock/core/networking/api_error_handler.dart';
import 'package:sp_sharia_stock/core/networking/api_error_model.dart';
import 'package:sp_sharia_stock/core/networking/api_result.dart';
import 'package:sp_sharia_stock/features/home/blocs/stock/stock_cubit.dart';
import 'package:sp_sharia_stock/features/home/data/domain/models/chart_interval.dart';
import 'package:sp_sharia_stock/features/home/data/repository/models/stock_model.dart';
import 'package:sp_sharia_stock/features/home/data/repository/stock_repository.dart';

import 'stock_cubit_test.mocks.dart';

// Run: flutter pub run build_runner build
@GenerateMocks([StockRepository])
void main() {
  late MockStockRepository mockStockRepository;
  late StockCubit stockCubit;

  setUp(() {
    mockStockRepository = MockStockRepository();
    stockCubit = StockCubit(stockRepository: mockStockRepository);
  });

  tearDown(() {
    stockCubit.close();
  });

  group('StockCubit', () {
    test('initial state is correct', () {
      expect(stockCubit.state, const StockState());
      expect(stockCubit.state.status, equals(RequestStatus.initial));
      expect(stockCubit.state.stock, isNull);
      expect(stockCubit.state.error, isNull);
    });

    group('getStockChartData', () {
      final fromDate = DateTime(2023, 1, 1);
      final toDate = DateTime(2023, 12, 31);
      final interval = ChartInterval.week;

      final mockStockModel = StockModel(
        symbol: 'SPUS',
        companyName: 'SP Funds S&P 500 Sharia Industry',
        currentPrice: 38.57,
        previousClose: 38.20,
        candlestickData: CandlestickData(
          entries: [
            CandlestickEntry(
              timestamp: 1701406800,
              open: 32.75,
              high: 34.375,
              low: 32.43,
              close: 34.20,
              volume: 2819700,
            ),
            CandlestickEntry(
              timestamp: 1701493200,
              open: 34.25,
              high: 35.10,
              low: 34.15,
              close: 35.05,
              volume: 1987600,
            ),
          ],
        ),
        priceStats: PriceStats(
          dayHigh: 38.95,
          dayLow: 38.10,
          fiftyTwoWeekHigh: 40.25,
          fiftyTwoWeekLow: 30.15,
          volume: 1234567,
        ),
      );

      blocTest<StockCubit, StockState>(
        'emits [inProgress, success] when getStockChartData succeeds',
        build: () {
          when(
            mockStockRepository.getStockChartData(
              fromDate: fromDate,
              toDate: toDate,
              interval: interval,
            ),
          ).thenAnswer((_) async => ApiResult.success(mockStockModel));
          return stockCubit;
        },
        act:
            (cubit) => cubit.getStockChartData(
              fromDate: fromDate,
              toDate: toDate,
            ),
        expect:
            () => [
              const StockState(status: RequestStatus.inProgress),
              StockState(
                status: RequestStatus.success,
                stock: mockStockModel,
                error: null,
              ),
            ],
        verify: (cubit) {
          verify(
            mockStockRepository.getStockChartData(
              fromDate: fromDate,
              toDate: toDate,
              interval: interval,
            ),
          ).called(1);
        },
      );

      final errorHandler = ErrorHandler.handle('Mock error');
      errorHandler.apiErrorModel = ApiErrorModel(
        message: 'Failed to fetch stock data',
        code: 500,
      );

      blocTest<StockCubit, StockState>(
        'emits [inProgress, failure] when getStockChartData fails',
        build: () {
          when(
            mockStockRepository.getStockChartData(
              fromDate: fromDate,
              toDate: toDate,
              interval: interval,
            ),
          ).thenAnswer((_) async => ApiResult.failure(errorHandler));
          return stockCubit;
        },
        act:
            (cubit) => cubit.getStockChartData(
              fromDate: fromDate,
              toDate: toDate,
            ),
        expect:
            () => [
              const StockState(status: RequestStatus.inProgress),
              StockState(
                status: RequestStatus.failure,
                error: 'Failed to fetch stock data',
              ),
            ],
        verify: (cubit) {
          verify(
            mockStockRepository.getStockChartData(
              fromDate: fromDate,
              toDate: toDate,
              interval: interval,
            ),
          ).called(1);
        },
      );
    });
  });
}
