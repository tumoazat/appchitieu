import 'package:go_router/go_router.dart';
import '../../presentation/auth/login_screen.dart';
import '../../presentation/auth/register_screen.dart';
import '../../presentation/navigation/main_scaffold.dart';
import '../../presentation/home/home_screen.dart';
import '../../presentation/transactions/transactions_screen.dart';
import '../../presentation/statistics/statistics_screen.dart';
import '../../presentation/ai_advice/ai_advice_screen.dart';
import '../../presentation/profile/profile_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/budgets/presentation/budget_screen.dart';

class AppRouter {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String transactions = '/transactions';
  static const String statistics = '/statistics';
  static const String aiAdvice = '/ai-advice';
  static const String profile = '/profile';
  static const String budget = '/budget';

  // Create router configuration
  static GoRouter createRouter({
    bool isAuthenticated = false,
    bool hasSeenOnboarding = true,
  }) {
    return GoRouter(
      initialLocation: isAuthenticated ? home : login,
      debugLogDiagnostics: true,
      routes: [
        // Onboarding route
        GoRoute(
          path: onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),

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
        final isOnboardingRoute = state.matchedLocation == onboarding;
        final isLoginRoute = state.matchedLocation == login;
        final isRegisterRoute = state.matchedLocation == register;

        // First-launch redirect to onboarding
        if (!hasSeenOnboarding && !isOnboardingRoute) {
          return onboarding;
        }

        // If not authenticated and trying to access protected route, redirect to login
        if (!isAuthenticated && !isLoginRoute && !isRegisterRoute && !isOnboardingRoute) {
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
