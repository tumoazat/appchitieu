import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/transaction_model.dart';
import '../../core/constants/category_data.dart';
import '../../core/utils/currency_formatter.dart';

class AiChatService {
  static const String _apiKey = 'AIzaSyA8R-AEVqBPOjjGZYi_MsaZ6pVzFHoNy8o';

  late final GenerativeModel _model;
  final List<Content> _history = [];

  AiChatService() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topP: 0.95,
        topK: 40,
        maxOutputTokens: 2048,
      ),
      systemInstruction: Content.system(_systemPrompt),
    );
  }

  static const String _systemPrompt = '''
Bạn là "AI Tài Chính Thông Minh" - trợ lý tài chính cá nhân trong ứng dụng quản lý chi tiêu.

QUY TẮC:
1. Luôn trả lời bằng tiếng Việt
2. Phân tích dựa trên DỮ LIỆU THỰC của người dùng (sẽ được cung cấp trong context)
3. Đưa ra lời khuyên CỤ THỂ, THỰC TẾ với con số chính xác
4. Sử dụng emoji phù hợp để trực quan hơn
5. Giọng điệu thân thiện, dễ hiểu, không quá trang trọng
6. Khi nói về tiền, luôn dùng đơn vị VNĐ
7. Format số tiền dễ đọc (vd: 1.500.000đ thay vì 1500000)
8. Nếu được hỏi ngoài phạm vi tài chính, nhẹ nhàng chuyển hướng về quản lý chi tiêu
9. Trả lời ngắn gọn nhưng đầy đủ thông tin
10. Luôn dựa trên dữ liệu tài chính được cung cấp, không bịa số liệu

KHẢNĂNG:
- Phân tích chi tiêu theo danh mục
- So sánh thu nhập vs chi tiêu
- Gợi ý tiết kiệm dựa trên pattern chi tiêu thực tế
- Cảnh báo khi chi tiêu vượt ngân sách
- Lập kế hoạch tài chính cá nhân
- Đánh giá sức khỏe tài chính
- Tư vấn quản lý tiền thông minh
''';

  /// Build financial context string from user data
  String buildFinancialContext({
    required List<TransactionModel> transactions,
    required double monthlyBudget,
    String? userName,
  }) {
    final expenses = transactions.where((t) => t.isExpense).toList();
    final incomes = transactions.where((t) => t.isIncome).toList();

    final totalExpense = expenses.fold<double>(0, (sum, t) => sum + t.amount);
    final totalIncome = incomes.fold<double>(0, (sum, t) => sum + t.amount);
    final balance = totalIncome - totalExpense;
    final savingRate = totalIncome > 0
        ? ((totalIncome - totalExpense) / totalIncome * 100)
        : 0.0;

    // Category breakdown
    final categoryTotals = <String, double>{};
    final categoryCounts = <String, int>{};
    for (var expense in expenses) {
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
      categoryCounts[expense.categoryId] =
          (categoryCounts[expense.categoryId] ?? 0) + 1;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final categoryBreakdown = sortedCategories.map((entry) {
      final cat = CategoryModel.findById(entry.key);
      final percent = totalExpense > 0
          ? (entry.value / totalExpense * 100).toStringAsFixed(1)
          : '0';
      return '  - ${cat?.emoji ?? '📦'} ${cat?.name ?? entry.key}: ${CurrencyFormatter.formatVND(entry.value)} ($percent%, ${categoryCounts[entry.key]} giao dịch)';
    }).join('\n');

    // Income breakdown
    final incomeTotals = <String, double>{};
    for (var income in incomes) {
      incomeTotals[income.categoryId] =
          (incomeTotals[income.categoryId] ?? 0) + income.amount;
    }
    final incomeBreakdown = incomeTotals.entries.map((entry) {
      final cat = CategoryModel.findById(entry.key);
      return '  - ${cat?.emoji ?? '💰'} ${cat?.name ?? entry.key}: ${CurrencyFormatter.formatVND(entry.value)}';
    }).join('\n');

    // Budget status
    final budgetUsed = monthlyBudget > 0
        ? (totalExpense / monthlyBudget * 100).toStringAsFixed(1)
        : 'chưa đặt';
    
    // Days left in month
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = daysInMonth - now.day;
    final dailyBudgetLeft = daysLeft > 0 && monthlyBudget > 0
        ? (monthlyBudget - totalExpense) / daysLeft
        : 0.0;

    // Recent transactions (last 5)
    final recentTransactions = List<TransactionModel>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    final recentList = recentTransactions.take(5).map((t) {
      final cat = CategoryModel.findById(t.categoryId);
      final sign = t.isIncome ? '+' : '-';
      return '  - ${t.date.day}/${t.date.month}: $sign${CurrencyFormatter.formatVND(t.amount)} (${cat?.name ?? t.categoryId})${t.note != null ? ' - ${t.note}' : ''}';
    }).join('\n');

    // Largest single expense
    String largestExpense = 'Không có';
    if (expenses.isNotEmpty) {
      final largest = expenses.reduce((a, b) => a.amount > b.amount ? a : b);
      final cat = CategoryModel.findById(largest.categoryId);
      largestExpense = '${CurrencyFormatter.formatVND(largest.amount)} (${cat?.name ?? largest.categoryId}, ngày ${largest.date.day}/${largest.date.month})';
    }

    return '''
📊 DỮ LIỆU TÀI CHÍNH THÁNG ${now.month}/${now.year}:
${userName != null ? '👤 Người dùng: $userName' : ''}

💵 TỔNG QUAN:
  - Thu nhập: ${CurrencyFormatter.formatVND(totalIncome)} (${incomes.length} giao dịch)
  - Chi tiêu: ${CurrencyFormatter.formatVND(totalExpense)} (${expenses.length} giao dịch)
  - Số dư: ${CurrencyFormatter.formatVND(balance)}
  - Tỷ lệ tiết kiệm: ${savingRate.toStringAsFixed(1)}%
  - Tổng giao dịch: ${transactions.length}

💰 NGÂN SÁCH:
  - Ngân sách tháng: ${monthlyBudget > 0 ? CurrencyFormatter.formatVND(monthlyBudget) : 'Chưa đặt'}
  - Đã sử dụng: $budgetUsed%
  - Còn $daysLeft ngày trong tháng
  - Ngân sách còn lại/ngày: ${dailyBudgetLeft > 0 ? CurrencyFormatter.formatVND(dailyBudgetLeft) : 'N/A'}

📉 CHI TIÊU THEO DANH MỤC:
$categoryBreakdown

📈 THU NHẬP THEO NGUỒN:
$incomeBreakdown

🏷️ GIAO DỊCH GẦN ĐÂY:
$recentList

🔴 CHI TIÊU LỚN NHẤT: $largestExpense
''';
  }

  /// Send a message and get AI response
  Future<String> sendMessage({
    required String userMessage,
    required String financialContext,
  }) async {
    try {
      // Add financial context as first user message if history is empty
      if (_history.isEmpty) {
        _history.add(Content.multi([
          TextPart('Đây là dữ liệu tài chính hiện tại của tôi:\n\n$financialContext\n\nHãy ghi nhớ dữ liệu này cho toàn bộ cuộc trò chuyện.'),
        ]));
        _history.add(Content.model([
          TextPart('Tôi đã ghi nhận đầy đủ dữ liệu tài chính của bạn. Tôi sẵn sàng phân tích và tư vấn! 😊'),
        ]));
      }

      // Add current user message
      _history.add(Content.multi([
        TextPart('$userMessage\n\n[Context cập nhật: $financialContext]'),
      ]));

      // Create chat session
      final chat = _model.startChat(history: _history.take(_history.length - 1).toList());
      
      final response = await chat.sendMessage(
        Content.text('$userMessage\n\n[Context cập nhật: $financialContext]'),
      );

      final responseText = response.text ?? 'Xin lỗi, tôi không thể trả lời lúc này.';

      // Add AI response to history
      _history.add(Content.model([TextPart(responseText)]));

      // Keep history manageable (last 20 messages)
      if (_history.length > 20) {
        _history.removeRange(0, _history.length - 20);
      }

      return responseText;
    } catch (e) {
      return _handleError(e, userMessage, financialContext);
    }
  }

  /// Fallback when API fails - use local analysis
  String _handleError(dynamic error, String userMessage, String financialContext) {
    final lowerMsg = userMessage.toLowerCase();
    
    if (lowerMsg.contains('phân tích') || lowerMsg.contains('chi tiêu')) {
      return '📊 **Phân tích nhanh:**\n\n'
          'Hiện tại tôi đang gặp sự cố kết nối AI. Tuy nhiên, dựa trên dữ liệu của bạn:\n\n'
          '$financialContext\n\n'
          '💡 Hãy thử lại sau hoặc kiểm tra kết nối mạng!';
    }
    
    return '⚠️ Xin lỗi, tôi đang gặp sự cố kết nối ($error). Hãy thử lại sau nhé! 🔄';
  }

  /// Clear chat history
  void clearHistory() {
    _history.clear();
  }
}
