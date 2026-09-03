import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  final UserModel user;

  const EditProfileDialog({super.key, required this.user});

  static Future<bool?> show(BuildContext context, {required UserModel user}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileDialog(user: user),
    );
  }

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _societyController;
  late final TextEditingController _flatController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _societyController = TextEditingController(text: widget.user.societyName ?? 'Whitefield Operations Hub');
    _flatController = TextEditingController(text: widget.user.flatNumber ?? 'HQ-01');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _societyController.dispose();
    _flatController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final payload = <String, dynamic>{
      'name': _nameController.text.trim(),
      if (_phoneController.text.trim().isNotEmpty)
        'phone': _phoneController.text.trim(),
      if (_societyController.text.trim().isNotEmpty)
        'societyName': _societyController.text.trim(),
      if (_flatController.text.trim().isNotEmpty)
        'flatNumber': _flatController.text.trim(),
    };

    final success = await ref.read(authNotifierProvider.notifier).updateProfile(payload);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(authNotifierProvider).errorMessage ?? 'Update failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Profile Information',
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Full Name
              AppTextField(
                label: 'Full Name',
                hint: 'e.g. Rajesh Kumar',
                controller: _nameController,
                prefixIcon: LucideIcons.user,
                validator: (val) {
                  if (val == null || val.trim().length < 2) {
                    return 'Please enter a valid name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Phone Number
              AppTextField(
                label: 'Contact Number',
                hint: '+91 90000 00001',
                controller: _phoneController,
                prefixIcon: LucideIcons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),

              // Society / Cluster
              AppTextField(
                label: 'Assigned Cluster',
                hint: 'Whitefield Operations Hub',
                controller: _societyController,
                prefixIcon: LucideIcons.building,
              ),
              const SizedBox(height: 14),

              // Unit / Flat
              AppTextField(
                label: 'Unit / Flat Designation',
                hint: 'HQ-01 (Executive)',
                controller: _flatController,
                prefixIcon: LucideIcons.home,
              ),
              const SizedBox(height: 24),

              // Save Button
              AppButton(
                text: 'Save Changes',
                icon: LucideIcons.check,
                isLoading: _isLoading,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
