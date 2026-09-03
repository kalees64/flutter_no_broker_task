import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';
import '../widgets/error_banner.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _identifierController.clear();
    _passwordController.clear();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
          rememberMe: false,
        );

    if (success && mounted) {
      _identifierController.clear();
      _passwordController.clear();
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Logo
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
                  child: Image.asset(
                    AppAssets.logo,
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Interactive Error Alert Banner
              if (authState.errorMessage != null) ...[
                ErrorBanner(
                  title: authState.errorCode == 'INVALID_CREDENTIALS'
                      ? 'Authentication Failed'
                      : 'Sign In Error',
                  message: authState.errorMessage!,
                  onDismiss: () =>
                      ref.read(authNotifierProvider.notifier).clearError(),
                ),
                const SizedBox(height: 12),
              ],

              // Main Login Card
              AppCard(
                borderRadius: 16,
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Welcome Area
                      Text(
                        'Welcome back!',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sign in to manage properties, tenants, and approvals.',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Input 1: Email or Mobile Number
                      AppTextField(
                        label: 'Email or Mobile Number',
                        subLabel: 'Primary Access',
                        hint: 'name@organization.com or 10-digit number',
                        controller: _identifierController,
                        prefixIcon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        showSuccessCheck: _identifierController.text.contains('@'),
                        helperText: 'Verified corporate administrator account format',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email or mobile number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Input 2: Password
                      AppTextField(
                        label: 'Password',
                        hint: 'Enter your security passkey',
                        controller: _passwordController,
                        prefixIcon: LucideIcons.lock,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Primary Action Button
                      AppButton(
                        text: 'Sign In to Dashboard',
                        icon: LucideIcons.arrowRight,
                        isLoading: isLoading,
                        onPressed: _handleLogin,
                      ),
                      const SizedBox(height: 20),

                      // Register Link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: AppTextStyles.bodySmall,
                            ),
                            GestureDetector(
                              onTap: () => context.push('/register'),
                              child: Text(
                                'Sign Up',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
