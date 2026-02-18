import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/transaction_provider.dart';
import 'widgets/settings_section.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final userProfileAsync = ref.watch(userProfileProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    // Get transaction count
    final now = DateTime.now();
    final transactionsAsync = ref.watch(
      transactionsStreamProvider('${now.year}-${now.month}'),
    );
    final transactionCount = transactionsAsync.when(
      data: (transactions) => transactions.length.toString(),
      loading: () => '...',
      error: (_, __) => '0',
    );

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
                userProfileAsync.when(
                  data: (userProfile) {
                    final displayName = userProfile?.displayName ?? 
                                       currentUser?.displayName ?? 
                                       'Người dùng';
                    final email = userProfile?.email ?? 
                                 currentUser?.email ?? 
                                 'user@example.com';
                    final photoUrl = userProfile?.photoUrl ?? 
                                    currentUser?.photoURL;

                    return Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: photoUrl != null
                                  ? NetworkImage(photoUrl)
                                  : null,
                              child: photoUrl == null
                                  ? Text(
                                      _getInitials(displayName),
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
                          displayName,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        Text(
                          email,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        child: Text(
                          _getInitials(currentUser?.displayName ?? 'U'),
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentUser?.displayName ?? 'Người dùng',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      Text(
                        currentUser?.email ?? 'user@example.com',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Edit profile button
                TextButton(
                  onPressed: () => _showEditProfileDialog(context, ref),
                  child: const Text('Chỉnh sửa hồ sơ'),
                ),
                const SizedBox(height: 24),
                // Quick stats row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.receipt_long,
                        value: transactionCount,
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
                      child: userProfileAsync.when(
                        data: (userProfile) {
                          final budget = userProfile?.monthlyBudget ?? 0;
                          return _StatCard(
                            icon: Icons.savings,
                            value: budget > 0 ? '${(budget / 1000000).toStringAsFixed(1)}M' : '0',
                            label: 'Ngân sách',
                          );
                        },
                        loading: () => const _StatCard(
                          icon: Icons.savings,
                          value: '...',
                          label: 'Ngân sách',
                        ),
                        error: (_, __) => const _StatCard(
                          icon: Icons.savings,
                          value: '0',
                          label: 'Ngân sách',
                        ),
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
                            .toggleTheme();
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

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final currentUser = ref.read(currentUserProvider);
    final userProfileAsync = ref.read(userProfileProvider);

    // Pre-fill with current data
    userProfileAsync.whenData((userProfile) {
      nameController.text = userProfile?.displayName ?? 
          currentUser?.displayName ?? '';
    });
    if (nameController.text.isEmpty) {
      nameController.text = currentUser?.displayName ?? '';
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Chỉnh sửa hồ sơ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tên hiển thị',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email),
                hintText: currentUser?.email ?? '',
              ),
              controller: TextEditingController(text: currentUser?.email ?? ''),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty && currentUser != null) {
                try {
                  final repo = ref.read(userRepositoryProvider);
                  await repo.updateProfile(currentUser.uid, {
                    'displayName': newName,
                    'email': currentUser.email ?? '',
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  // Also update Firebase Auth display name
                  await currentUser.updateDisplayName(newName);
                  // Force refresh user profile
                  ref.invalidate(userProfileProvider);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã cập nhật hồ sơ'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showBudgetDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final userProfileAsync = ref.read(userProfileProvider);
    
    // Pre-fill with current budget
    userProfileAsync.whenData((userProfile) {
      if (userProfile != null && userProfile.monthlyBudget > 0) {
        controller.text = userProfile.monthlyBudget.toStringAsFixed(0);
      }
    });

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
            onPressed: () async {
              final budget = double.tryParse(controller.text);
              if (budget != null && budget > 0) {
                try {
                  final user = ref.read(currentUserProvider);
                  final repo = ref.read(userRepositoryProvider);
                  await repo.updateBudget(
                    user!.uid, 
                    budget,
                    displayName: user.displayName ?? 'Người dùng',
                    email: user.email ?? '',
                  );
                  // Force refresh user profile
                  ref.invalidate(userProfileProvider);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã cập nhật ngân sách'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
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
            onPressed: () async {
              try {
                await ref.read(signOutProvider.future);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
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
