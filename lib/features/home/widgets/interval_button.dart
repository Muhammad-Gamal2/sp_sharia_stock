import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sp_sharia_stock/features/home/blocs/stock/stock_cubit.dart';
import 'package:sp_sharia_stock/features/home/data/domain/models/chart_interval.dart';

class IntervalButton extends StatelessWidget {
  const IntervalButton({
    super.key,
    required this.interval,
    required this.label,
    required this.isSelected,
  });

  final ChartInterval interval;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: () {
            context.read<StockCubit>().setInterval(interval);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor:
            isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade200,
            foregroundColor: isSelected ? Colors.white : Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
