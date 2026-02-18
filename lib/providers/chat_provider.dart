import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/chat_message.dart';
import '../data/models/transaction_model.dart';
import '../data/services/ai_chat_service.dart';
import 'transaction_provider.dart';
import 'user_provider.dart';
import 'auth_provider.dart';
import 'package:uuid/uuid.dart';

// AI Chat Service singleton provider
final aiChatServiceProvider = Provider<AiChatService>((ref) {
  return AiChatService();
});

// Chat messages state
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref _ref;
  final AiChatService _chatService;

  ChatNotifier(this._ref, this._chatService) : super([]) {
    // Add welcome message
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final welcome = ChatMessage(
      id: const Uuid().v4(),
      role: MessageRole.assistant,
      content: 'Xin chào! 👋 Tôi là **AI Tài Chính** - trợ lý quản lý chi tiêu thông minh của bạn.\n\n'
          'Tôi có thể giúp bạn:\n'
          '• 📊 Phân tích chi tiêu chi tiết\n'
          '• 💡 Gợi ý cách tiết kiệm\n'
          '• ⚠️ Cảnh báo vượt ngân sách\n'
          '• 📅 Lập kế hoạch tài chính\n'
          '• 🏆 Đánh giá sức khỏe tài chính\n\n'
          'Hãy chọn một gợi ý bên dưới hoặc hỏi tôi bất cứ điều gì về tài chính của bạn! 😊',
      type: MessageType.text,
    );
    state = [welcome];
  }

  String _getFinancialContext() {
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month}';
    final transactionsAsync = _ref.read(transactionsStreamProvider(monthKey));
    final monthlyBudget = _ref.read(monthlyBudgetProvider);
    final user = _ref.read(currentUserProvider);

    final transactions = transactionsAsync.when(
      data: (data) => data,
      loading: () => <TransactionModel>[],
      error: (_, __) => <TransactionModel>[],
    );

    return _chatService.buildFinancialContext(
      transactions: transactions,
      monthlyBudget: monthlyBudget,
      userName: user?.displayName,
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      role: MessageRole.user,
      content: text.trim(),
    );
    state = [...state, userMsg];

    // Add loading placeholder
    final loadingId = const Uuid().v4();
    final loadingMsg = ChatMessage(
      id: loadingId,
      role: MessageRole.assistant,
      content: '',
      isLoading: true,
    );
    state = [...state, loadingMsg];

    try {
      // Get fresh financial context
      final context = _getFinancialContext();

      // Get AI response
      final response = await _chatService.sendMessage(
        userMessage: text.trim(),
        financialContext: context,
      );

      // Replace loading message with actual response
      state = state.map((msg) {
        if (msg.id == loadingId) {
          return msg.copyWith(
            content: response,
            isLoading: false,
          );
        }
        return msg;
      }).toList();
    } catch (e) {
      // Replace loading with error
      state = state.map((msg) {
        if (msg.id == loadingId) {
          return msg.copyWith(
            content: '❌ Có lỗi xảy ra: ${e.toString()}\n\nHãy thử lại nhé!',
            isLoading: false,
          );
        }
        return msg;
      }).toList();
    }
  }

  void clearChat() {
    _chatService.clearHistory();
    state = [];
    _addWelcomeMessage();
  }
}

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  final chatService = ref.watch(aiChatServiceProvider);
  return ChatNotifier(ref, chatService);
});
