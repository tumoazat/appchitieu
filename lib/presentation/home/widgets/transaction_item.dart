import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/transaction_model.dart';
import '../../../core/constants/category_data.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/currency_formatter.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = CategoryModel.findById(transaction.categoryId);
    final categoryEmoji = category?.emoji ?? '❓';
    final categoryName = category?.name ?? 'Khác';
    final categoryColor = category?.color ?? Colors.grey;

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                // Leading circle with emoji
                CircleAvatar(
                  radius: 22,
                  backgroundColor: categoryColor.withOpacity(0.2),
                  child: Text(
                    categoryEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Category name and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryName,
                        style: AppTypography.titleMedium(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormatter.formatVietnamese(transaction.date),
                        style: AppTypography.bodySmall(context).copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Amount
                Text(
                  CurrencyFormatter.formatWithSign(
                    transaction.amount,
                    isIncome: transaction.isIncome,
                  ),
                  style: AppTypography.titleMedium(context).copyWith(
                    color: transaction.isIncome
                        ? Colors.green[600]
                        : Colors.red[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Divider with indent
          Divider(
            height: 1,
            thickness: 1,
            indent: 68,
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: -0.2, duration: 300.ms);
  }
}
