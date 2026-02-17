import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/theme/app_typography.dart';

class MonthSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;

  const MonthSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _onPreviousMonth,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: Text(
              DateFormatter.formatShortMonthYear(selectedDate),
              style: AppTypography.titleMedium(context),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _onNextMonth,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _onPreviousMonth() {
    final newDate = DateTime(
      selectedDate.year,
      selectedDate.month - 1,
    );
    onDateChanged(newDate);
  }

  void _onNextMonth() {
    final newDate = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
    );
    onDateChanged(newDate);
  }
}
