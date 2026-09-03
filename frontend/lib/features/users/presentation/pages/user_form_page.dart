import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/data/models/user_model.dart';
import '../controllers/users_controller.dart';

class UserFormPage extends ConsumerStatefulWidget {
  final UserModel? user;

  const UserFormPage({super.key, this.user});

  @override
  ConsumerState<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends ConsumerState<UserFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _phoneController;
  late final TextEditingController _flatController;
  late final TextEditingController _societyController;

  late String _selectedRole;
  late String _selectedKyc;
  bool _isLoading = false;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameController = TextEditingController(text: u?.name ?? '');
    _emailController = TextEditingController(text: u?.email ?? '');
    _passwordController = TextEditingController(text: _isEditing ? '' : 'Password123!');
    _phoneController = TextEditingController(text: u?.phone ?? '');
    _flatController = TextEditingController(text: u?.flatNumber ?? '');
    _societyController = TextEditingController(text: u?.societyName ?? 'Oakwood Residency');
    _selectedRole = u?.role ?? 'tenant';
    _selectedKyc = u?.kycStatus ?? 'verified';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _flatController.dispose();
    _societyController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final controller = ref.read(usersControllerProvider.notifier);
    bool success = false;

    if (_isEditing) {
      final payload = <String, dynamic>{
        'name': _nameController.text.trim(),
        'role': _selectedRole,
        'kycStatus': _selectedKyc,
        if (_phoneController.text.trim().isNotEmpty)
          'phone': _phoneController.text.trim(),
        if (_flatController.text.trim().isNotEmpty)
          'flatNumber': _flatController.text.trim(),
        if (_societyController.text.trim().isNotEmpty)
          'societyName': _societyController.text.trim(),
      };
      success = await controller.updateUser(widget.user!.id, payload);
    } else {
      final payload = <String, dynamic>{
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
        'password': _passwordController.text,
        'role': _selectedRole,
        'kycStatus': _selectedKyc,
        if (_phoneController.text.trim().isNotEmpty)
          'phone': _phoneController.text.trim(),
        if (_flatController.text.trim().isNotEmpty)
          'flatNumber': _flatController.text.trim(),
        if (_societyController.text.trim().isNotEmpty)
          'societyName': _societyController.text.trim(),
      };
      success = await controller.createUser(payload);
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      context.pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'User updated successfully!'
              : 'New resident added to cluster directory!'),
        ),
      );
    } else {
      final error = ref.read(usersControllerProvider).errorMessage ?? 'Action failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0.5,
        title: Text(
          _isEditing ? 'Edit Resident' : 'Add New Resident',
          style: AppTextStyles.h3.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: AppCard(
            borderRadius: 16,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Update Details' : 'Resident Information',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.onSurface,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fill in resident profile and cluster allocation details.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),

                // Name
                AppTextField(
                  label: 'Full Name',
                  hint: 'e.g. Rahul Sharma',
                  controller: _nameController,
                  prefixIcon: LucideIcons.user,
                  validator: (val) {
                    if (val == null || val.trim().length < 2) {
                      return 'Please enter a valid name (min 2 chars)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email
                AppTextField(
                  label: 'Work / Personal Email',
                  hint: 'name@company.com',
                  controller: _emailController,
                  prefixIcon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isEditing, // Email immutable on edit for security
                  validator: (val) {
                    if (val == null || !val.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password (only for Add)
                if (!_isEditing) ...[
                  AppTextField(
                    label: 'Temporary Password',
                    hint: 'Min 8 characters',
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
                  const SizedBox(height: 16),
                ],

                // Phone
                AppTextField(
                  label: 'Mobile Number',
                  hint: '+91 98765 43210',
                  controller: _phoneController,
                  prefixIcon: LucideIcons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Role Selector
                Text(
                  'Resident Role',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['tenant', 'owner', 'vendor', 'admin'].map((r) {
                    final isSel = _selectedRole == r;
                    return ChoiceChip(
                      label: Text(r[0].toUpperCase() + r.substring(1)),
                      selected: isSel,
                      selectedColor: AppColors.primaryContainer,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedRole = r);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Flat Number & Society
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Flat / Unit',
                        hint: 'Flat 402',
                        controller: _flatController,
                        prefixIcon: LucideIcons.home,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'Society',
                        hint: 'Oakwood',
                        controller: _societyController,
                        prefixIcon: LucideIcons.building,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // KYC Status Selector
                Text(
                  'KYC Verification Status',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Verified'),
                      selected: _selectedKyc == 'verified',
                      selectedColor: const Color(0xFF16A34A),
                      labelStyle: TextStyle(
                        color: _selectedKyc == 'verified' ? Colors.white : AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedKyc = 'verified');
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Pending Verification'),
                      selected: _selectedKyc == 'pending',
                      selectedColor: const Color(0xFFFF5A3C),
                      labelStyle: TextStyle(
                        color: _selectedKyc == 'pending' ? Colors.white : AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedKyc = 'pending');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Submit Button
                AppButton(
                  text: _isEditing ? 'Save Changes' : 'Create Resident Profile',
                  icon: _isEditing ? LucideIcons.check : LucideIcons.userPlus,
                  isLoading: _isLoading,
                  onPressed: _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
