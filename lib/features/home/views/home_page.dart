import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sp_sharia_stock/core/helpers/request_status.dart';
import 'package:sp_sharia_stock/features/home/blocs/stock/stock_cubit.dart';
import 'package:sp_sharia_stock/features/home/data/domain/models/chart_interval.dart';
import 'package:sp_sharia_stock/features/home/data/repository/stock_repository.dart';
import 'package:sp_sharia_stock/features/home/widgets/date_range_picker_widget.dart';
import 'package:sp_sharia_stock/features/home/widgets/interval_button.dart';
import 'package:sp_sharia_stock/features/home/widgets/stock_data_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => StockCubit(
            stockRepository: RepositoryProvider.of<StockRepository>(context),
          )..getStockChartData(
            fromDate: DateTime.now().subtract(const Duration(days: 180)),
            toDate: DateTime.now(),
          ),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: BlocConsumer<StockCubit, StockState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error.toString())));
          }
        },
        builder: (context, state) {
          final currentInterval = state.interval;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Interval Filter
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IntervalButton(
                      interval: ChartInterval.day,
                      label: 'Day',
                      isSelected: currentInterval == ChartInterval.day,
                    ),
                    IntervalButton(
                      interval: ChartInterval.week,
                      label: 'Week',
                      isSelected: currentInterval == ChartInterval.week,
                    ),
                    IntervalButton(
                      interval: ChartInterval.month,
                      label: 'Month',
                      isSelected: currentInterval == ChartInterval.month,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Date Range Picker
                if (state.startDate != null && state.endDate != null)
                  DateRangePickerWidget(
                    startDate: state.startDate!,
                    endDate: state.endDate!,
                    onDateRangeSelected: (startDate, endDate) {
                      context.read<StockCubit>().setDateRange(
                        startDate,
                        endDate,
                      );
                    },
                  ),
                const SizedBox(height: 16),
                if (state.status.isInProgress)
                  const Center(child: CircularProgressIndicator()),
                if (state.status.isSuccess && state.stock != null)
                  StockDataWidget(
                    stock: state.stock!,
                    interval: state.interval,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
