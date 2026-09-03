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

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _flatController = TextEditingController();
  final _societyController = TextEditingController();

  String _selectedRole = 'tenant';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _flatController.dispose();
    _societyController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
          role: _selectedRole,
          flatNumber: _flatController.text.trim().isNotEmpty
              ? _flatController.text.trim()
              : null,
          societyName: _societyController.text.trim().isNotEmpty
              ? _societyController.text.trim()
              : null,
        );

    if (success && mounted) {
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

              // Dynamic Error Alert Banner
              if (authState.errorMessage != null) ...[
                ErrorBanner(
                  title: 'Registration Error',
                  message: authState.errorMessage!,
                  onDismiss: () =>
                      ref.read(authNotifierProvider.notifier).clearError(),
                ),
                const SizedBox(height: 12),
              ],

              // Main Register Card
              AppCard(
                borderRadius: 16,
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Create an Account',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Join the NoBroker Management Hub network',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Full Name
                      AppTextField(
                        label: 'Full Name',
                        subLabel: '*Required',
                        hint: 'e.g. Rahul Sharma',
                        controller: _nameController,
                        prefixIcon: LucideIcons.user,
                        validator: (val) {
                          if (val == null || val.trim().length < 2) {
                            return 'Full name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Work Email
                      AppTextField(
                        label: 'Work Email',
                        subLabel: '*Required',
                        hint: 'name@company.com',
                        controller: _emailController,
                        prefixIcon: LucideIcons.mail,
                        keyboardType: TextInputType.emailAddress,
                        helperText: 'Email will be verified with session credentials',
                        validator: (val) {
                          if (val == null || !val.contains('@')) {
                            return 'Valid work email is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Mobile Number
                      AppTextField(
                        label: 'Mobile Number',
                        hint: '+91 98765 43210',
                        controller: _phoneController,
                        prefixIcon: LucideIcons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      AppTextField(
                        label: 'Password',
                        subLabel: '*Min 8 chars',
                        hint: 'Create strong passkey',
                        controller: _passwordController,
                        prefixIcon: LucideIcons.lock,
                        isPassword: true,
                        validator: (val) {
                          if (val == null || val.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Role Selector Chips
                      Text(
                        'Select Account Role',
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildRoleChip('tenant', 'Tenant', LucideIcons.home),
                          const SizedBox(width: 8),
                          _buildRoleChip('owner', 'Owner', LucideIcons.key),
                          const SizedBox(width: 8),
                          _buildRoleChip('vendor', 'Vendor', LucideIcons.wrench),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Flat No & Society Name
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Flat / Unit No',
                              hint: 'e.g. Flat 402',
                              controller: _flatController,
                              prefixIcon: LucideIcons.hash,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              label: 'Society Name',
                              hint: 'e.g. Oakwood Res.',
                              controller: _societyController,
                              prefixIcon: LucideIcons.building,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // CTA Button
                      AppButton(
                        text: 'Complete Registration',
                        icon: LucideIcons.userCheck,
                        isLoading: isLoading,
                        onPressed: _handleRegister,
                      ),
                      const SizedBox(height: 20),

                      // Sign In Link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: AppTextStyles.bodySmall,
                            ),
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Text(
                                'Sign In',
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

  Widget _buildRoleChip(String roleKey, String label, IconData icon) {
    final isSelected = _selectedRole == roleKey;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = roleKey;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.outlineVariant,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: isSelected ? Colors.white : AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
