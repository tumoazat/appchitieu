import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_typography.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).uri.toString();
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final inactiveColor = Colors.grey;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home,
              label: 'Trang chủ',
              route: '/home',
              currentRoute: currentRoute,
              activeColor: primaryColor,
              inactiveColor: inactiveColor,
              onTap: () => context.go('/home'),
            ),
            _NavItem(
              icon: Icons.receipt_long,
              label: 'Giao dịch',
              route: '/transactions',
              currentRoute: currentRoute,
              activeColor: primaryColor,
              inactiveColor: inactiveColor,
              onTap: () => context.go('/transactions'),
            ),
            const SizedBox(width: 56),
            _NavItem(
              icon: Icons.bar_chart,
              label: 'Thống kê',
              route: '/statistics',
              currentRoute: currentRoute,
              activeColor: primaryColor,
              inactiveColor: inactiveColor,
              onTap: () => context.go('/statistics'),
            ),
            _NavItem(
              icon: Icons.person,
              label: 'Cá nhân',
              route: '/profile',
              currentRoute: currentRoute,
              activeColor: primaryColor,
              inactiveColor: inactiveColor,
              onTap: () => context.go('/profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentRoute;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentRoute,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentRoute == route;
    final color = isActive ? activeColor : inactiveColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall(context).copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
