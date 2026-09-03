import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class UserAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final double size;
  final bool isVerified;
  final bool isOnline;

  const UserAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.size = 44.0,
    this.isVerified = false,
    this.isOnline = false,
  });

  String _getInitials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outlineVariant, width: 1.5),
              gradient: const LinearGradient(
                colors: [
                  AppColors.primaryContainer,
                  AppColors.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: ClipOval(
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildInitials(),
                    )
                  : _buildInitials(),
            ),
          ),
          if (isVerified || isOnline)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  color: isVerified ? AppColors.primary : AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: isVerified
                    ? Icon(
                        Icons.check,
                        size: size * 0.18,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        _getInitials(name),
        style: AppTextStyles.titleMedium.copyWith(
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
