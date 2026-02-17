import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/statistics_provider.dart';
import '../shared/loading_shimmer.dart';
import '../shared/empty_state.dart';
import '../../core/utils/currency_formatter.dart';
import 'widgets/pie_chart_section.dart';
import 'widgets/bar_chart_section.dart';
import 'widgets/category_breakdown.dart';
import 'widgets/insight_card.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final params = {'year': now.year, 'month': now.month};
    final statsAsync = ref.watch(monthlyStatsProvider(params));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: statsAsync.when(
          data: (stats) {
            if (stats.transactionCount == 0) {
              return EmptyState.noData();
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    'Thống kê',
                    style: AppTypography.headlineLarge(context),
                  ),
                  const SizedBox(height: 24),
                  
                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Thu nhập',
                          amount: stats.totalIncome,
                          color: Theme.of(context).colorScheme.primary,
                          icon: '💰',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Chi tiêu',
                          amount: stats.totalExpense,
                          color: Theme.of(context).colorScheme.error,
                          icon: '💸',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Số dư',
                          amount: stats.balance,
                          color: stats.balance >= 0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                          icon: '💵',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Pie Chart Section
                  if (stats.categoryBreakdown.isNotEmpty) ...[
                    PieChartSection(
                      categoryBreakdown: stats.categoryBreakdown,
                      totalExpense: stats.totalExpense,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Bar Chart Section
                  const BarChartSection(),
                  const SizedBox(height: 24),

                  // Category Breakdown
                  if (stats.categoryBreakdown.isNotEmpty) ...[
                    CategoryBreakdown(params: params),
                    const SizedBox(height: 24),
                  ],

                  // Insight Card
                  InsightCard(stats: stats),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
          loading: () => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  'Thống kê',
                  style: AppTypography.headlineLarge(context),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: LoadingShimmer.card(height: 100)),
                    const SizedBox(width: 12),
                    Expanded(child: LoadingShimmer.card(height: 100)),
                    const SizedBox(width: 12),
                    Expanded(child: LoadingShimmer.card(height: 100)),
                  ],
                ),
                const SizedBox(height: 24),
                LoadingShimmer.card(height: 300),
                const SizedBox(height: 24),
                LoadingShimmer.card(height: 250),
              ],
            ),
          ),
          error: (error, stack) => EmptyState.error(message: error.toString()),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final String icon;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  icon,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.labelMedium(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                CurrencyFormatter.formatCompact(amount),
                style: AppTypography.titleLarge(context).copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
