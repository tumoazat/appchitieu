import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/ai_advice_service.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/user_provider.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../shared/gradient_button.dart';
import '../shared/loading_shimmer.dart';
import 'widgets/advice_card.dart';
import 'widgets/budget_progress.dart';

class AiAdviceScreen extends ConsumerStatefulWidget {
  const AiAdviceScreen({super.key});

  @override
  ConsumerState<AiAdviceScreen> createState() => _AiAdviceScreenState();
}

class _AiAdviceScreenState extends ConsumerState<AiAdviceScreen> {
  bool _isAnalyzing = false;
  List<AdviceItem> _advices = [];
  final _aiService = AiAdviceService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _analyzeTransactions();
    });
  }

  Future<void> _analyzeTransactions() async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final now = DateTime.now();
      final transactionsAsync = ref.read(
        transactionsStreamProvider({'year': now.year, 'month': now.month}),
      );

      final monthlyBudget = ref.read(monthlyBudgetProvider);

      transactionsAsync.when(
        data: (transactions) async {
          final advices = await _aiService.analyzeTransactions(
            transactions: transactions,
            monthlyBudget: monthlyBudget,
          );

          if (mounted) {
            setState(() {
              _advices = advices;
              _isAnalyzing = false;
            });
          }
        },
        loading: () {
          if (mounted) {
            setState(() {
              _isAnalyzing = false;
            });
          }
        },
        error: (error, stack) {
          if (mounted) {
            setState(() {
              _isAnalyzing = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final transactionsAsync = ref.watch(
      transactionsStreamProvider({'year': now.year, 'month': now.month}),
    );
    final monthlyBudget = ref.watch(monthlyBudgetProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingLg),
          child: transactionsAsync.when(
            data: (transactions) {
              final expenses = transactions.where((t) => t.isExpense).toList();
              final totalExpense = expenses.fold<double>(
                0,
                (sum, t) => sum + t.amount,
              );

              if (_isAnalyzing) {
                return _buildLoadingState();
              }

              if (transactions.isEmpty) {
                return _buildEmptyState();
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppConstants.spacingLg),
                    
                    // Title
                    Text(
                      '🤖 AI Tư Vấn Tài Chính',
                      style: AppTypography.headlineLarge(context),
                    ),
                    
                    const SizedBox(height: AppConstants.spacingLg),
                    
                    // AI Status Card
                    _buildAiStatusCard(context),
                    
                    const SizedBox(height: AppConstants.spacingLg),
                    
                    // Budget Progress
                    BudgetProgress(
                      spent: totalExpense,
                      budget: monthlyBudget,
                    ),
                    
                    const SizedBox(height: AppConstants.spacingLg),
                    
                    // Advice Cards
                    if (_advices.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _advices.length,
                        itemBuilder: (context, index) {
                          return AdviceCard(
                            advice: _advices[index],
                            index: index,
                          );
                        },
                      )
                    else
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.spacingXl),
                          child: Text(
                            'Thêm giao dịch để nhận lời khuyên',
                            style: AppTypography.bodyMedium(context),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: AppConstants.spacingLg),
                    
                    // Reanalyze Button
                    GradientButton(
                      label: '✨ Phân tích lại',
                      onPressed: _analyzeTransactions,
                      width: double.infinity,
                    ),
                    
                    const SizedBox(height: AppConstants.spacingXl),
                  ],
                ),
              );
            },
            loading: () => _buildLoadingState(),
            error: (error, stack) => Center(
              child: Text(
                'Có lỗi xảy ra',
                style: AppTypography.bodyMedium(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAiStatusCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusXl),
      ),
      padding: const EdgeInsets.all(AppConstants.cardPadding),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🤖',
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingBase),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Phân Tích',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isAnalyzing
                      ? 'Đang phân tích chi tiêu...'
                      : 'Phân tích hoàn tất',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (_isAnalyzing)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.spacingLg),
          
          Text(
            '🤖 AI Tư Vấn Tài Chính',
            style: AppTypography.headlineLarge(context),
          ),
          
          const SizedBox(height: AppConstants.spacingLg),
          
          LoadingShimmer.card(height: 100, borderRadius: BorderRadius.circular(AppConstants.borderRadiusXl)),
          
          const SizedBox(height: AppConstants.spacingLg),
          
          LoadingShimmer.card(height: 150, borderRadius: BorderRadius.circular(AppConstants.borderRadiusXl)),
          
          const SizedBox(height: AppConstants.spacingLg),
          
          LoadingShimmer.card(height: 120, borderRadius: BorderRadius.circular(AppConstants.borderRadiusXl)),
          
          const SizedBox(height: AppConstants.spacingBase),
          
          LoadingShimmer.card(height: 120, borderRadius: BorderRadius.circular(AppConstants.borderRadiusXl)),
          
          const SizedBox(height: AppConstants.spacingBase),
          
          LoadingShimmer.card(height: 120, borderRadius: BorderRadius.circular(AppConstants.borderRadiusXl)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🤖',
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: AppConstants.spacingLg),
          Text(
            'AI Tư Vấn Tài Chính',
            style: AppTypography.headlineLarge(context),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingXxl),
            child: Text(
              'Thêm giao dịch để nhận lời khuyên',
              style: AppTypography.bodyMedium(context),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
