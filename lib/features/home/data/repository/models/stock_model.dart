import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sp_sharia_stock/features/home/data/domain/models/chart_response.dart';

part 'stock_model.freezed.dart';
part 'stock_model.g.dart';

/// Model representing stock data optimized for candlestick chart visualization
@freezed
abstract class StockModel with _$StockModel {
  const factory StockModel({
    required String symbol,
    required String companyName,
    required double currentPrice,
    required double previousClose,
    required CandlestickData candlestickData,
    required PriceStats priceStats,
  }) = _StockModel;

  factory StockModel.fromJson(Map<String, dynamic> json) =>
      _$StockModelFromJson(json);
}

/// Price statistics for the stock
@freezed
abstract class PriceStats with _$PriceStats {
  const factory PriceStats({
    required double dayHigh,
    required double dayLow,
    required double fiftyTwoWeekHigh,
    required double fiftyTwoWeekLow,
    required int volume,
  }) = _PriceStats;

  factory PriceStats.fromJson(Map<String, dynamic> json) =>
      _$PriceStatsFromJson(json);
}

/// Data for rendering a candlestick chart
@freezed
abstract class CandlestickData with _$CandlestickData {
  const factory CandlestickData({required List<CandlestickEntry> entries}) =
      _CandlestickData;

  factory CandlestickData.fromJson(Map<String, dynamic> json) =>
      _$CandlestickDataFromJson(json);
}

/// Single entry in a candlestick chart
@freezed
abstract class CandlestickEntry with _$CandlestickEntry {
  const factory CandlestickEntry({
    required int timestamp,
    required double open,
    required double high,
    required double low,
    required double close,
    required int volume,
  }) = _CandlestickEntry;

  const CandlestickEntry._();

  /// Determines if this candle represents price increase (bullish)
  bool get isBullish => close >= open;

  /// Determines if this candle represents price decrease (bearish)
  bool get isBearish => close < open;

  /// The body height of the candlestick (absolute difference between open and close)
  double get bodyHeight => (close - open).abs();

  /// The entire range of the candlestick from high to low
  double get fullRange => high - low;

  /// The upper wick length (distance from body to high)
  double get upperWickLength => isBullish ? high - close : high - open;

  /// The lower wick length (distance from body to low)
  double get lowerWickLength => isBullish ? open - low : close - low;

  factory CandlestickEntry.fromJson(Map<String, dynamic> json) =>
      _$CandlestickEntryFromJson(json);
}

/// Factory to convert ChartResponse to StockModel
extension ChartResponseToStockModel on ChartResponse {
  StockModel toStockModel() {
    final result = chart.result.first;
    final meta = result.meta;
    final timestamps = result.timestamp;
    final quote = result.indicators.quote.first;
    final volumes = quote.volume;
    final opens = quote.open;
    final highs = quote.high;
    final lows = quote.low;
    final closes = quote.close;

    // Create candlestick entries
    final entries = <CandlestickEntry>[];
    for (int i = 0; i < timestamps.length; i++) {
      entries.add(
        CandlestickEntry(
          timestamp: timestamps[i],
          open: opens[i],
          high: highs[i],
          low: lows[i],
          close: closes[i],
          volume: volumes[i],
        ),
      );
    }

    // Create and return StockModel
    return StockModel(
      symbol: meta.symbol,
      companyName: meta.shortName,
      currentPrice: meta.regularMarketPrice,
      previousClose: meta.chartPreviousClose,
      priceStats: PriceStats(
        dayHigh: meta.regularMarketDayHigh,
        dayLow: meta.regularMarketDayLow,
        fiftyTwoWeekHigh: meta.fiftyTwoWeekHigh,
        fiftyTwoWeekLow: meta.fiftyTwoWeekLow,
        volume: meta.regularMarketVolume,
      ),
      candlestickData: CandlestickData(entries: entries),
    );
  }
}
