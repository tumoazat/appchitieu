import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_provider.dart';
import '../../core/constants/category_data.dart';

// Monthly statistics model
class MonthlyStats {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final Map<String, double> categoryBreakdown;
  final Map<String, int> categoryCount;
  final int transactionCount;

  MonthlyStats({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.categoryBreakdown,
    required this.categoryCount,
    required this.transactionCount,
  });

  double get savingRate {
    if (totalIncome == 0) return 0;
    return ((totalIncome - totalExpense) / totalIncome) * 100;
  }
}

// Chart data point
class ChartDataPoint {
  final String label;
  final double value;
  final String categoryId;

  ChartDataPoint({
    required this.label,
    required this.value,
    required this.categoryId,
  });
}

// Monthly stats provider
final monthlyStatsProvider = Provider.autoDispose
    .family<AsyncValue<MonthlyStats>, Map<String, int>>((ref, params) {
  final year = params['year']!;
  final month = params['month']!;

  final transactionsAsync = ref.watch(
    transactionsStreamProvider({'year': year, 'month': month}),
  );

  return transactionsAsync.when(
    data: (transactions) {
      double totalIncome = 0;
      double totalExpense = 0;
      final Map<String, double> categoryBreakdown = {};
      final Map<String, int> categoryCount = {};

      for (var transaction in transactions) {
        if (transaction.isIncome) {
          totalIncome += transaction.amount;
        } else {
          totalExpense += transaction.amount;
        }

        // Category breakdown (only for expenses)
        if (transaction.isExpense) {
          categoryBreakdown[transaction.categoryId] =
              (categoryBreakdown[transaction.categoryId] ?? 0) + 
              transaction.amount;
          categoryCount[transaction.categoryId] =
              (categoryCount[transaction.categoryId] ?? 0) + 1;
        }
      }

      return AsyncValue.data(MonthlyStats(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        balance: totalIncome - totalExpense,
        categoryBreakdown: categoryBreakdown,
        categoryCount: categoryCount,
        transactionCount: transactions.length,
      ));
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Pie chart data provider
final pieChartDataProvider = Provider.autoDispose
    .family<List<ChartDataPoint>, Map<String, int>>((ref, params) {
  final statsAsync = ref.watch(monthlyStatsProvider(params));

  return statsAsync.when(
    data: (stats) {
      final List<ChartDataPoint> dataPoints = [];

      stats.categoryBreakdown.forEach((categoryId, amount) {
        final category = CategoryModel.findById(categoryId);
        dataPoints.add(ChartDataPoint(
          label: category?.name ?? 'Khác',
          value: amount,
          categoryId: categoryId,
        ));
      });

      // Sort by value descending
      dataPoints.sort((a, b) => b.value.compareTo(a.value));

      return dataPoints;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Bar chart data provider (daily spending for current month)
final barChartDataProvider = Provider.autoDispose<List<ChartDataPoint>>((ref) {
  final now = DateTime.now();
  final transactionsAsync = ref.watch(
    transactionsStreamProvider({'year': now.year, 'month': now.month}),
  );

  return transactionsAsync.when(
    data: (transactions) {
      // Group expenses by day
      final Map<int, double> dailyExpenses = {};

      for (var transaction in transactions) {
        if (transaction.isExpense) {
          final day = transaction.date.day;
          dailyExpenses[day] = (dailyExpenses[day] ?? 0) + transaction.amount;
        }
      }

      // Convert to chart data points
      final List<ChartDataPoint> dataPoints = [];
      dailyExpenses.forEach((day, amount) {
        dataPoints.add(ChartDataPoint(
          label: day.toString(),
          value: amount,
          categoryId: '',
        ));
      });

      // Sort by day
      dataPoints.sort((a, b) => 
          int.parse(a.label).compareTo(int.parse(b.label)));

      return dataPoints;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Top spending category provider
final topSpendingCategoryProvider = Provider.autoDispose
    .family<String?, Map<String, int>>((ref, params) {
  final statsAsync = ref.watch(monthlyStatsProvider(params));

  return statsAsync.when(
    data: (stats) {
      if (stats.categoryBreakdown.isEmpty) return null;

      // Find category with highest spending
      String topCategory = '';
      double maxAmount = 0;

      stats.categoryBreakdown.forEach((categoryId, amount) {
        if (amount > maxAmount) {
          maxAmount = amount;
          topCategory = categoryId;
        }
      });

      return topCategory;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Category spending percentage provider
final categorySpendingPercentageProvider = Provider.autoDispose
    .family<Map<String, double>, Map<String, int>>((ref, params) {
  final statsAsync = ref.watch(monthlyStatsProvider(params));

  return statsAsync.when(
    data: (stats) {
      final Map<String, double> percentages = {};

      if (stats.totalExpense == 0) return percentages;

      stats.categoryBreakdown.forEach((categoryId, amount) {
        percentages[categoryId] = (amount / stats.totalExpense) * 100;
      });

      return percentages;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});
