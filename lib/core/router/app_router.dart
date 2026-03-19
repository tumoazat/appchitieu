import 'package:go_router/go_router.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/navigation/main_scaffold.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/transactions/transactions_screen.dart';
import '../../presentation/statistics/statistics_screen.dart';
import '../../presentation/ai_advice/ai_advice_screen.dart';
import '../../presentation/profile/profile_screen.dart';
import '../../features/budgets/presentation/budget_screen.dart';
import '../../presentation/transactions/search_screen.dart';
import '../../presentation/settings/settings_screen.dart';
import '../../features/gamification/screens/achievements_screen.dart';
import '../../features/ocr/ocr_scan_screen.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String transactions = '/transactions';
  static const String statistics = '/statistics';
  static const String aiAdvice = '/ai-advice';
  static const String profile = '/profile';
  static const String budget = '/budget';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String achievements = '/achievements';
  static const String ocrScan = '/ocr-scan';

  // Create router configuration
  static GoRouter createRouter({
    bool isAuthenticated = false,
  }) {
    return GoRouter(
      initialLocation: isAuthenticated ? home : login,
      debugLogDiagnostics: true,
      routes: [
        // Auth routes
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: register,
          builder: (context, state) => const RegisterScreen(),
        ),

        // Budget route (outside shell so it has its own AppBar)
        GoRoute(
          path: budget,
          builder: (context, state) => const BudgetScreen(),
        ),

        // Tìm kiếm giao dịch nâng cao
        GoRoute(
          path: search,
          builder: (context, state) => const SearchScreen(),
        ),

        // Màn hình cài đặt
        GoRoute(
          path: settings,
          builder: (context, state) => const SettingsScreen(),
        ),

        // Màn hình thành tựu gamification
        GoRoute(
          path: achievements,
          builder: (context, state) => const AchievementsScreen(),
        ),

        // Màn hình scan hóa đơn OCR
        GoRoute(
          path: ocrScan,
          builder: (context, state) => const OcrScanScreen(),
        ),

        // Main app with bottom navigation shell
        ShellRoute(
          builder: (context, state, child) {
            return MainScaffold(child: child);
          },
          routes: [
            GoRoute(
              path: home,
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: transactions,
              builder: (context, state) => const TransactionsScreen(),
            ),
            GoRoute(
              path: statistics,
              builder: (context, state) => const StatisticsScreen(),
            ),
            GoRoute(
              path: aiAdvice,
              builder: (context, state) => const AiAdviceScreen(),
            ),
            GoRoute(
              path: profile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        final isLoginRoute = state.matchedLocation == login;
        final isRegisterRoute = state.matchedLocation == register;

        // If not authenticated and trying to access protected route, redirect to login
        if (!isAuthenticated && !isLoginRoute && !isRegisterRoute) {
          return login;
        }

        // If authenticated and on login/register, redirect to home
        if (isAuthenticated && (isLoginRoute || isRegisterRoute)) {
          return home;
        }

        // No redirect needed
        return null;
      },
    );
  }
}
