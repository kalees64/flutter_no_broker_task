import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PropertySpotlightBanner extends StatelessWidget {
  const PropertySpotlightBanner({super.key});

  static const String _imageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAreCkfc-yiGDchWu9VKGGnzx-K76cpm9r3SnASv0IQEI21mnFxCcI-nxblYFOGc0usFsbX7bQVOTXsSPyjPstx2ETaTZcvOJgQawgnJ-H7Qb8Nzx31DlyOBJGzvnmNCDtwUAe_nSY97X4Mkd3xnSFvQMHC50Km0zWESwyAD1DIQYtpo3R21RWhtlJYFvHOi0t84WpNGk-xirHf2frAP5sVC0YzZQybuAz9HEUJeSN88d9tcRZb8zA';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 144,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image with Fallback
            Positioned.fill(
              child: Image.network(
                _imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Deep Gradient Overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Top Right Glass Pill: "Featured"
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('★ ', style: TextStyle(color: Colors.amber, fontSize: 11)),
                    Text(
                      'Featured',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Text
            Positioned(
              bottom: 14,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'WHITEFIELD PALMS • TOWER C',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.secondaryContainer,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '100% Occupancy Milestone',
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
