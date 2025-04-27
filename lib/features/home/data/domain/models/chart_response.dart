import 'package:freezed_annotation/freezed_annotation.dart';

part 'chart_response.freezed.dart';
part 'chart_response.g.dart';

@freezed
abstract class ChartResponse with _$ChartResponse {
  const factory ChartResponse({required Chart chart}) = _ChartResponse;

  factory ChartResponse.fromJson(Map<String, dynamic> json) =>
      _$ChartResponseFromJson(json);
}

@freezed
abstract class Chart with _$Chart {
  const factory Chart({required List<ChartResult> result, String? error}) =
      _Chart;

  factory Chart.fromJson(Map<String, dynamic> json) => _$ChartFromJson(json);
}

@freezed
abstract class ChartResult with _$ChartResult {
  const factory ChartResult({
    required Meta meta,
    required List<int> timestamp,
    required Indicators indicators,
  }) = _ChartResult;

  factory ChartResult.fromJson(Map<String, dynamic> json) =>
      _$ChartResultFromJson(json);
}

@freezed
abstract class Meta with _$Meta {
  const factory Meta({
    required String currency,
    required String symbol,
    required String exchangeName,
    required String fullExchangeName,
    required String instrumentType,
    required int firstTradeDate,
    required int regularMarketTime,
    required bool hasPrePostMarketData,
    required int gmtoffset,
    required String timezone,
    required String exchangeTimezoneName,
    required double regularMarketPrice,
    required double fiftyTwoWeekHigh,
    required double fiftyTwoWeekLow,
    required double regularMarketDayHigh,
    required double regularMarketDayLow,
    required int regularMarketVolume,
    required String longName,
    required String shortName,
    required double chartPreviousClose,
    required int priceHint,
    required TradingPeriod currentTradingPeriod,
    required String dataGranularity,
    required String range,
    required List<String> validRanges,
  }) = _Meta;

  factory Meta.fromJson(Map<String, dynamic> json) => _$MetaFromJson(json);
}

@freezed
abstract class TradingPeriod with _$TradingPeriod {
  const factory TradingPeriod({
    required TradingPeriodDetails pre,
    required TradingPeriodDetails regular,
    required TradingPeriodDetails post,
  }) = _TradingPeriod;

  factory TradingPeriod.fromJson(Map<String, dynamic> json) =>
      _$TradingPeriodFromJson(json);
}

@freezed
abstract class TradingPeriodDetails with _$TradingPeriodDetails {
  const factory TradingPeriodDetails({
    required String timezone,
    required int start,
    required int end,
    required int gmtoffset,
  }) = _TradingPeriodDetails;

  factory TradingPeriodDetails.fromJson(Map<String, dynamic> json) =>
      _$TradingPeriodDetailsFromJson(json);
}

@freezed
abstract class Indicators with _$Indicators {
  const factory Indicators({
    required List<Quote> quote,
    required List<AdjClose> adjclose,
  }) = _Indicators;

  factory Indicators.fromJson(Map<String, dynamic> json) =>
      _$IndicatorsFromJson(json);
}

@freezed
abstract class Quote with _$Quote {
  const factory Quote({
    required List<int> volume,
    required List<double> open,
    required List<double> high,
    required List<double> low,
    required List<double> close,
  }) = _Quote;

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);
}

@freezed
abstract class AdjClose with _$AdjClose {
  const factory AdjClose({required List<double> adjclose}) = _AdjClose;

  factory AdjClose.fromJson(Map<String, dynamic> json) =>
      _$AdjCloseFromJson(json);
}
