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
            (cubit) =>
                cubit.getStockChartData(fromDate: fromDate, toDate: toDate),
        expect:
            () => [
              StockState(
                status: RequestStatus.inProgress,
                startDate: fromDate,
                endDate: toDate,
              ),
              StockState(
                status: RequestStatus.success,
                stock: mockStockModel,
                startDate: fromDate,
                endDate: toDate,
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
            (cubit) =>
                cubit.getStockChartData(fromDate: fromDate, toDate: toDate),
        expect:
            () => [
              StockState(
                status: RequestStatus.inProgress,
                startDate: fromDate,
                endDate: toDate,
              ),
              StockState(
                status: RequestStatus.failure,
                error: 'Failed to fetch stock data',
                startDate: fromDate,
                endDate: toDate,
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

  group('setInterval', () {
    final mockStockModel = _createMockStockModel();
    final startDate = DateTime(2023, 1, 1);
    final endDate = DateTime(2023, 12, 31);

    test('should update interval in state', () {
      // Arrange
      when(
        mockStockRepository.getStockChartData(
          fromDate: anyNamed('fromDate'),
          toDate: anyNamed('toDate'),
          interval: anyNamed('interval'),
        ),
      ).thenAnswer((_) async => ApiResult.success(mockStockModel));

      // Act
      stockCubit.setInterval(ChartInterval.day);

      // Assert
      expect(stockCubit.state.interval, equals(ChartInterval.day));
    });

    blocTest<StockCubit, StockState>(
      'should update interval and call getStockChartData with updated interval',
      build: () {
        when(
          mockStockRepository.getStockChartData(
            fromDate: anyNamed('fromDate'),
            toDate: anyNamed('toDate'),
            interval: ChartInterval.month,
          ),
        ).thenAnswer((_) async => ApiResult.success(mockStockModel));

        return stockCubit;
      },
      seed:
          () => StockState(
            status: RequestStatus.initial,
            startDate: startDate,
            endDate: endDate,
          ),
      act: (cubit) => cubit.setInterval(ChartInterval.month),
      expect:
          () => [
            predicate<StockState>(
              (state) =>
                  state.interval == ChartInterval.month &&
                  state.status == RequestStatus.initial,
            ),
            predicate<StockState>(
              (state) =>
                  state.interval == ChartInterval.month &&
                  state.status == RequestStatus.inProgress,
            ),
            predicate<StockState>(
              (state) =>
                  state.interval == ChartInterval.month &&
                  state.status == RequestStatus.success &&
                  state.stock == mockStockModel,
            ),
          ],
      verify: (_) {
        verify(
          mockStockRepository.getStockChartData(
            fromDate: startDate,
            toDate: endDate,
            interval: ChartInterval.month,
          ),
        ).called(1);
      },
    );
  });

  group('setDateRange', () {
    final mockStockModel = _createMockStockModel();
    final startDate = DateTime(2023, 1, 1);
    final endDate = DateTime(2023, 12, 31);
    final newStartDate = DateTime(2023, 6, 1);
    final newEndDate = DateTime(2023, 6, 30);

    blocTest<StockCubit, StockState>(
      'should update date range and call getStockChartData with new dates',
      build: () {
        when(
          mockStockRepository.getStockChartData(
            fromDate: newStartDate,
            toDate: newEndDate,
            interval: ChartInterval.week,
          ),
        ).thenAnswer((_) async => ApiResult.success(mockStockModel));

        return stockCubit;
      },
      seed:
          () => StockState(
            status: RequestStatus.initial,
            startDate: startDate,
            endDate: endDate,
          ),
      act: (cubit) => cubit.setDateRange(newStartDate, newEndDate),
      expect:
          () => [
            StockState(
              status: RequestStatus.inProgress,
              startDate: newStartDate,
              endDate: newEndDate,
            ),
            StockState(
              status: RequestStatus.success,
              startDate: newStartDate,
              endDate: newEndDate,
              stock: mockStockModel,
            ),
          ],
      verify: (_) {
        verify(
          mockStockRepository.getStockChartData(
            fromDate: newStartDate,
            toDate: newEndDate,
            interval: ChartInterval.week,
          ),
        ).called(1);
      },
    );

    blocTest<StockCubit, StockState>(
      'should handle API failure when setting date range',
      build: () {
        final errorHandler = ErrorHandler.handle(Exception());

        when(
          mockStockRepository.getStockChartData(
            fromDate: newStartDate,
            toDate: newEndDate,
            interval: ChartInterval.week,
          ),
        ).thenAnswer((_) async => ApiResult.failure(errorHandler));

        return stockCubit;
      },
      seed:
          () => StockState(
            status: RequestStatus.initial,
            startDate: startDate,
            endDate: endDate,
          ),
      act: (cubit) => cubit.setDateRange(newStartDate, newEndDate),
      expect:
          () => [
            StockState(
              status: RequestStatus.inProgress,
              startDate: newStartDate,
              endDate: newEndDate,
            ),
            StockState(
              status: RequestStatus.failure,
              error: ApiErrors.defaultError,
              startDate: newStartDate,
              endDate: newEndDate,
            ),
          ],
    );
  });
}

// Helper function to create a mock StockModel
StockModel _createMockStockModel() {
  return StockModel(
    symbol: 'SPUS',
    companyName: 'SP Funds S&P 500 Sharia ETF',
    currentPrice: 38.57,
    previousClose: 38.25,
    priceStats: PriceStats(
      dayHigh: 38.63,
      dayLow: 38.02,
      fiftyTwoWeekHigh: 44.69,
      fiftyTwoWeekLow: 33.32,
      volume: 347015,
    ),
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
      ],
    ),
  );
}
