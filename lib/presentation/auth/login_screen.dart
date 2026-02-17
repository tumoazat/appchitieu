import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../shared/gradient_button.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/social_login_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getVietnameseErrorMessage(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signInWithGoogle();

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getVietnameseErrorMessage(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getVietnameseErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'Không tìm thấy tài khoản';
    } else if (error.contains('wrong-password')) {
      return 'Mật khẩu không đúng';
    } else if (error.contains('invalid-email')) {
      return 'Email không hợp lệ';
    } else if (error.contains('user-disabled')) {
      return 'Tài khoản đã bị vô hiệu hóa';
    } else if (error.contains('too-many-requests')) {
      return 'Quá nhiều lần thử. Vui lòng thử lại sau';
    } else if (error.contains('network-request-failed')) {
      return 'Lỗi kết nối mạng';
    } else {
      return 'Đã xảy ra lỗi. Vui lòng thử lại';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingXl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.maxContentWidth,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo and Title
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadiusXl,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '💰',
                              style: TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingBase),
                        Text(
                          'Smart Expense',
                          style: AppTypography.displayMedium(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingSm),
                        Text(
                          'Quản lý chi tiêu thông minh',
                          style: AppTypography.bodyMedium(context).copyWith(
                            color: isDark 
                                ? AppColors.textSecondaryDark 
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacing3xl),

                    // Email field
                    AuthTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: AppConstants.spacingBase),

                    // Password field
                    AuthTextField(
                      controller: _passwordController,
                      hintText: 'Mật khẩu',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      validator: _validatePassword,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: AppConstants.spacingMd),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                // TODO: Implement forgot password
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Tính năng sẽ được cập nhật sớm',
                                    ),
                                  ),
                                );
                              },
                        child: Text(
                          'Quên mật khẩu?',
                          style: AppTypography.bodyMedium(context).copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingBase),

                    // Login button
                    GradientButton(
                      label: 'Đăng nhập',
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: AppConstants.spacingBase),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isDark 
                                ? AppColors.borderDark 
                                : AppColors.borderLight,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingBase,
                          ),
                          child: Text(
                            'HOẶC',
                            style: AppTypography.bodySmall(context),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDark 
                                ? AppColors.borderDark 
                                : AppColors.borderLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingBase),

                    // Google sign in
                    SocialLoginButton(
                      icon: Icons.g_mobiledata,
                      text: 'Đăng nhập với Google',
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                      iconColor: const Color(0xFF4285F4),
                    ),
                    const SizedBox(height: AppConstants.spacingXl),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Chưa có tài khoản? ',
                          style: AppTypography.bodyMedium(context),
                        ),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  context.go('/register');
                                },
                          child: Text(
                            'Đăng ký',
                            style: AppTypography.bodyMedium(context).copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
