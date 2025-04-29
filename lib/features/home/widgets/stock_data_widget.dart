import 'package:flutter/material.dart';
import 'package:sp_sharia_stock/features/home/data/domain/models/chart_interval.dart';
import 'package:sp_sharia_stock/features/home/data/repository/models/stock_model.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StockDataWidget extends StatelessWidget {
  const StockDataWidget({
    super.key,
    required this.stock,
    required this.interval,
  });

  final StockModel stock;
  final ChartInterval interval;

  @override
  Widget build(BuildContext context) {
    final data = stock.candlestickData.entries;
    final currentPrice = stock.currentPrice;
    final priceColor =
        currentPrice >= stock.previousClose
            ? Colors.green.shade700
            : Colors.red.shade700;
    final chartInterval =
        interval == ChartInterval.day || interval == ChartInterval.week
            ? DateTimeIntervalType.days
            : DateTimeIntervalType.months;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stock Info Header
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      stock.symbol,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        stock.companyName,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.bodyLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${currentPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: priceColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Candlestick Chart with Volume
        SizedBox(
          height: 300,
          child: SfCartesianChart(
            plotAreaBorderWidth: 0,
            primaryXAxis: DateTimeAxis(
              intervalType: chartInterval,
              majorGridLines: const MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              labelFormat: '\${value}',
              majorGridLines: const MajorGridLines(
                width: 0.5,
                color: Colors.grey,
              ),
              axisLine: const AxisLine(width: 0),
            ),
            trackballBehavior: TrackballBehavior(
              enable: true,
              activationMode: ActivationMode.singleTap,
              tooltipSettings: const InteractiveTooltip(
                enable: true,

                color: Colors.black,
              ),
              lineType: TrackballLineType.vertical,
            ),
            zoomPanBehavior: ZoomPanBehavior(
              enablePinching: true,
              enableDoubleTapZooming: true,
              enablePanning: true,
              enableMouseWheelZooming: true,
              zoomMode: ZoomMode.x,
            ),
            crosshairBehavior: CrosshairBehavior(
              enable: true,
              activationMode: ActivationMode.longPress,
              lineType: CrosshairLineType.both,
              lineColor: Colors.grey.shade700,
              lineDashArray: const [5, 5],
            ),
            series: <CartesianSeries>[
              CandleSeries<CandlestickEntry, DateTime>(
                dataSource: data,
                xValueMapper:
                    (CandlestickEntry data, _) =>
                        DateTime.fromMillisecondsSinceEpoch(
                          data.timestamp * 1000,
                        ),
                highValueMapper: (CandlestickEntry data, _) => data.high,
                lowValueMapper: (CandlestickEntry data, _) => data.low,
                openValueMapper: (CandlestickEntry data, _) => data.open,
                closeValueMapper: (CandlestickEntry data, _) => data.close,
                bullColor: Colors.green.shade600,
                bearColor: Colors.red.shade600,
                enableSolidCandles: true,
                enableTooltip: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}
