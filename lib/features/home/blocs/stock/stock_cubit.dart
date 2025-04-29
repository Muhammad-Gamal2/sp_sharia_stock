import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sp_sharia_stock/core/helpers/request_status.dart';
import 'package:sp_sharia_stock/core/networking/api_result.dart';
import 'package:sp_sharia_stock/features/home/data/domain/models/chart_interval.dart';
import 'package:sp_sharia_stock/features/home/data/repository/models/stock_model.dart';
import 'package:sp_sharia_stock/features/home/data/repository/stock_repository.dart';

part 'stock_state.dart';

part 'stock_cubit.freezed.dart';

class StockCubit extends Cubit<StockState> {
  final StockRepository _stockRepository;

  StockCubit({required StockRepository stockRepository})
    : _stockRepository = stockRepository,
      super(StockState());

  /// Fetches stock chart data for the specified date range and interval
  ///
  /// [fromDate] The start date
  /// [toDate] The end date

  Future<void> getStockChartData({DateTime? fromDate, DateTime? toDate}) async {
    final startDate = fromDate ?? state.startDate;
    final endDate = toDate ?? state.endDate;

    if (startDate == null || endDate == null) return;

    emit(
      state.copyWith(
        status: RequestStatus.inProgress,
        startDate: startDate,
        endDate: endDate,
      ),
    );

    final result = await _stockRepository.getStockChartData(
      fromDate: startDate,
      toDate: endDate,
      interval: state.interval,
    );

    if (result is Success<StockModel>) {
      emit(
        state.copyWith(
          status: RequestStatus.success,
          stock: result.data,
          error: null,
        ),
      );
    } else if (result is Failure<StockModel>) {
      emit(
        state.copyWith(
          status: RequestStatus.failure,
          error: result.errorHandler.apiErrorModel.message,
        ),
      );
    }
  }

  void setInterval(ChartInterval interval) {
    emit(state.copyWith(interval: interval));
    getStockChartData();
  }

  void setDateRange(DateTime startDate, DateTime endDate) {
    getStockChartData(fromDate: startDate, toDate: endDate);
  }
}
