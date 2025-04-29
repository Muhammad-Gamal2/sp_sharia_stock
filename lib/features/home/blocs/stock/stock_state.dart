part of 'stock_cubit.dart';

@freezed
abstract class StockState with _$StockState {
  const factory StockState({
    @Default(RequestStatus.initial) RequestStatus status,
    StockModel? stock,
    String? error,
    @Default(ChartInterval.week) ChartInterval interval,
    DateTime? startDate,
    DateTime? endDate,
  }) = _StockState;
}
