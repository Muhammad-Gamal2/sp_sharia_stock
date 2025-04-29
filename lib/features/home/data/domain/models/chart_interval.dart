/// Represents available interval options for stock chart data
enum ChartInterval {
  day,
  week,
  month;

  String toApiString() {
    switch (this) {
      case ChartInterval.day:
        return '1d';
      case ChartInterval.week:
        return '1wk';
      case ChartInterval.month:
        return '1mo';
    }
  }

  String get displayName {
    switch (this) {
      case ChartInterval.day:
        return 'Daily';
      case ChartInterval.week:
        return 'Weekly';
      case ChartInterval.month:
        return 'Monthly';
    }
  }
}
