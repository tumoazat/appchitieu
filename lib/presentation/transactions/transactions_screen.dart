import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/auth_provider.dart';
import '../home/widgets/transaction_item.dart';
import '../shared/empty_state.dart';
import '../shared/loading_shimmer.dart';
import 'widgets/filter_chips.dart';
import 'widgets/month_selector.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _selectedFilter = 'all';
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(
      transactionsStreamProvider({
        'year': _selectedDate.year,
        'month': _selectedDate.month,
      }),
    );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Giao dịch',
                style: AppTypography.headlineLarge(context),
              ),
              
              const SizedBox(height: 16),
              
              // Filter chips
              FilterChips(
                selectedFilter: _selectedFilter,
                onFilterChanged: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              ),
              
              const SizedBox(height: 12),
              
              // Month selector
              MonthSelector(
                selectedDate: _selectedDate,
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Transactions list
              Expanded(
                child: transactionsAsync.when(
                  data: (transactions) {
                    final filteredTransactions = _filterTransactions(transactions);
                    
                    if (filteredTransactions.isEmpty) {
                      return EmptyState.noTransactions();
                    }
                    
                    final groupedTransactions = _groupTransactionsByDate(
                      filteredTransactions,
                    );
                    
                    return ListView.builder(
                      itemCount: groupedTransactions.length,
                      itemBuilder: (context, index) {
                        final dateGroup = groupedTransactions.keys.elementAt(index);
                        final dateTransactions = groupedTransactions[dateGroup]!;
                        final dailyTotal = _calculateDailyTotal(dateTransactions);
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date header with daily total
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 4,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormatter.formatTransactionGroup(dateGroup),
                                    style: AppTypography.titleMedium(context).copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.formatVND(dailyTotal),
                                    style: AppTypography.titleSmall(context).copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Transactions for this date
                            ...dateTransactions.map((transaction) {
                              return Dismissible(
                                key: Key(transaction.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (direction) async {
                                  return await _showDeleteConfirmation(
                                    context,
                                    transaction,
                                  );
                                },
                                onDismissed: (direction) {
                                  _deleteTransaction(transaction);
                                },
                                child: TransactionItem(transaction: transaction),
                              );
                            }),
                          ],
                        );
                      },
                    );
                  },
                  loading: () => ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => LoadingShimmer.listItem(),
                  ),
                  error: (error, stack) => EmptyState.error(
                    message: error.toString(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TransactionModel> _filterTransactions(List<TransactionModel> transactions) {
    if (_selectedFilter == 'all') {
      return transactions;
    } else if (_selectedFilter == 'expense') {
      return transactions.where((t) => t.type == TransactionType.expense).toList();
    } else {
      return transactions.where((t) => t.type == TransactionType.income).toList();
    }
  }

  Map<DateTime, List<TransactionModel>> _groupTransactionsByDate(
    List<TransactionModel> transactions,
  ) {
    final Map<DateTime, List<TransactionModel>> grouped = {};
    
    for (final transaction in transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(transaction);
    }
    
    // Sort dates in descending order
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    
    final Map<DateTime, List<TransactionModel>> sortedGrouped = {};
    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }
    
    return sortedGrouped;
  }

  double _calculateDailyTotal(List<TransactionModel> transactions) {
    double total = 0;
    for (final transaction in transactions) {
      total += transaction.amount;
    }
    return total;
  }

  Future<bool> _showDeleteConfirmation(
    BuildContext context,
    TransactionModel transaction,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa giao dịch này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _deleteTransaction(TransactionModel transaction) {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    ref.read(transactionRepositoryProvider).deleteTransaction(
      user.uid,
      transaction.id,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xóa giao dịch'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
