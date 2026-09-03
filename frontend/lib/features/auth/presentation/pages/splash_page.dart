import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/auth_controller.dart';
import '../widgets/session_progress_card.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  double _progress = 0.28;
  String _statusText = 'Validating JWT token...';
  String _subText = 'Checking secure session & credentials...';
  bool _isCompleted = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSessionCheckSequence();
  }

  void _startSessionCheckSequence() {
    // Stage 1
    _timer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _progress = 0.65;
        _statusText = 'Deciphering session keys...';
        _subText = 'Establishing TLS handshakes & claims...';
      });

      // Stage 2
      _timer = Timer(const Duration(milliseconds: 700), () async {
        if (!mounted) return;

        // Perform actual Riverpod checkAuthStatus
        await ref.read(authNotifierProvider.notifier).checkAuthStatus();
        final authState = ref.read(authNotifierProvider);

        if (!mounted) return;
        setState(() {
          _progress = 1.0;
          _isCompleted = true;
          _statusText = authState.status == AuthStatus.authenticated
              ? 'Token verified safely'
              : 'Routing to sign in...';
          _subText = authState.status == AuthStatus.authenticated
              ? 'Routing to personalized dashboard...'
              : 'Preparing authentication portal...';
        });

        // Navigate
        _timer = Timer(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          if (authState.status == AuthStatus.authenticated) {
            context.go('/dashboard');
          } else {
            context.go('/login');
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient soft glowing blobs
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryContainer.withValues(alpha: 0.18),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            right: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryFixedDim.withValues(alpha: 0.2),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width * 0.2,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tertiaryFixed.withValues(alpha: 0.12),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Zero Brokerage Platform Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(color: AppColors.outlineVariant, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          LucideIcons.shieldCheck,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'ZERO BROKERAGE PLATFORM',
                          style: AppTextStyles.caption.copyWith(
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center Logo & Slogan Hub
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Brand Logo Container with Radiance Aura
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.primaryFixedDim.withValues(alpha: 0.4),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x141B1E28),
                                  blurRadius: 20,
                                  offset: Offset(0, 8),
                                ),
                              ],
                              border: Border.all(color: AppColors.outlineVariant, width: 1),
                            ),
                            child: Image.asset(
                              AppAssets.logo,
                              width: 160,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    LucideIcons.home,
                                    size: 44,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'NOBROKER',
                                    style: AppTextStyles.h2.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "India's #1 Real Estate",
                        style: AppTextStyles.h1.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '& Property Management Network',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 36),

                      // Session Progress Card
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 340),
                        child: SessionProgressCard(
                          progress: _progress,
                          statusText: _statusText,
                          subText: _subText,
                          isCompleted: _isCompleted,
                        ),
                      ),
                    ],
                  ),

                  // Bottom Encryption Metadata
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.lock,
                            size: 13,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Secure 256-bit Encrypted Session',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'v3.8.2 • High Availability Node',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
