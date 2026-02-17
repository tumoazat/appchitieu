import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/settings_section.dart';

// Placeholder providers - these should be properly implemented in your app
final userProfileProvider = Provider<UserProfile>((ref) {
  return UserProfile(
    name: 'Người dùng',
    email: 'user@example.com',
    photoUrl: null,
  );
});

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

final signOutProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    // Implement sign out logic
  };
});

final updateBudgetProvider = Provider<Future<void> Function(double)>((ref) {
  return (budget) async {
    // Implement budget update logic
  };
});

class UserProfile {
  final String name;
  final String email;
  final String? photoUrl;

  UserProfile({
    required this.name,
    required this.email,
    this.photoUrl,
  });
}

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }

  void toggleDarkMode(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Header section
                Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child: user.photoUrl == null
                              ? Text(
                                  _getInitials(user.name),
                                  style: const TextStyle(fontSize: 32),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Edit profile button
                TextButton(
                  onPressed: () {
                    // Navigate to edit profile
                  },
                  child: const Text('Chỉnh sửa hồ sơ'),
                ),
                const SizedBox(height: 24),
                // Quick stats row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.receipt_long,
                        value: '24',
                        label: 'Giao dịch',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.local_fire_department,
                        value: '7',
                        label: 'Liên tiếp',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.savings,
                        value: '2.5M',
                        label: 'Tiết kiệm',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Settings sections
                SettingsSection(
                  title: 'TÙY CHỌN',
                  items: [
                    SettingsItem(
                      leading: Icons.dark_mode,
                      title: 'Chế độ tối',
                      isToggle: true,
                      toggleValue: isDarkMode,
                      onToggle: (value) {
                        ref
                            .read(themeModeProvider.notifier)
                            .toggleDarkMode(value);
                      },
                    ),
                    SettingsItem(
                      leading: Icons.currency_exchange,
                      title: 'Đơn vị tiền tệ',
                      value: 'VNĐ',
                      onTap: () {
                        // Show currency selection
                      },
                    ),
                    SettingsItem(
                      leading: Icons.language,
                      title: 'Ngôn ngữ',
                      value: 'Tiếng Việt',
                      onTap: () {
                        // Show language selection
                      },
                    ),
                  ],
                ),
                SettingsSection(
                  title: 'DỮ LIỆU',
                  items: [
                    SettingsItem(
                      leading: Icons.account_balance_wallet,
                      title: 'Ngân sách',
                      onTap: () => _showBudgetDialog(context, ref),
                    ),
                    SettingsItem(
                      leading: Icons.file_download,
                      title: 'Xuất dữ liệu',
                      onTap: () {
                        // Export data
                      },
                    ),
                  ],
                ),
                SettingsSection(
                  title: 'VỀ ỨNG DỤNG',
                  items: [
                    SettingsItem(
                      leading: '⭐',
                      title: 'Đánh giá ứng dụng',
                      onTap: () {
                        // Open app store
                      },
                    ),
                    SettingsItem(
                      leading: '📧',
                      title: 'Liên hệ',
                      onTap: () {
                        // Open contact
                      },
                    ),
                    SettingsItem(
                      leading: '🔒',
                      title: 'Chính sách bảo mật',
                      onTap: () {
                        // Open privacy policy
                      },
                    ),
                    SettingsItem(
                      leading: Icons.info,
                      title: 'Phiên bản',
                      value: '1.0.0',
                      onTap: null,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Logout button
                TextButton(
                  onPressed: () => _showLogoutDialog(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Đăng xuất'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  void _showBudgetDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đặt ngân sách'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Số tiền',
            suffixText: 'VNĐ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              final budget = double.tryParse(controller.text);
              if (budget != null) {
                ref.read(updateBudgetProvider)(budget);
                Navigator.pop(context);
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              ref.read(signOutProvider)();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
