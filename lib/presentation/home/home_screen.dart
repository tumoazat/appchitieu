import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/transaction_provider.dart';
import '../../core/theme/app_typography.dart';
import '../shared/empty_state.dart';
import 'widgets/home_header.dart';
import 'widgets/balance_card.dart';
import 'widgets/quick_actions_row.dart';
import 'widgets/transaction_item.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentTransactionsAsync = ref.watch(recentTransactionsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Invalidate the provider to refresh data
          ref.invalidate(recentTransactionsProvider);
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  
                  // Header with avatar and greeting
                  const HomeHeader(),
                  const SizedBox(height: 24),
                  
                  // Balance card
                  const BalanceCard(),
                  const SizedBox(height: 24),
                  
                  // Quick actions
                  const QuickActionsRow(),
                  const SizedBox(height: 24),
                  
                  // Recent transactions title
                  Text(
                    'Giao dịch gần đây',
                    style: AppTypography.headlineMedium(context),
                  ),
                  const SizedBox(height: 16),
                  
                  // Recent transactions list
                  recentTransactionsAsync.when(
                    data: (transactions) {
                      if (transactions.isEmpty) {
                        return EmptyState.noTransactions();
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return TransactionItem(
                            transaction: transaction,
                            onTap: () {
                              // TODO: Navigate to transaction detail
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: EmptyState.error(
                          message: 'Không thể tải giao dịch',
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
