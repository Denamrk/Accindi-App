import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/primary_button.dart';
import '../widgets/outline_button.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback? onLogin;
  final VoidCallback? onRegister;

  const WelcomeScreen({super.key, this.onLogin, this.onRegister});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Scale hero height to available space — 380 on tall screens,
            // shrinks proportionally on shorter ones (min 240).
            final heroHeight =
                (constraints.maxHeight * 0.45).clamp(240.0, 380.0);

            return Column(
              children: [
                // Scrollable content area
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),

                        // Hero illustration area
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            height: heroHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                begin: Alignment(-0.6, -0.8),
                                end: Alignment(0.8, 0.8),
                                colors: [
                                  Color(0xFFFEEECC),
                                  Color(0xFFF0E7CE),
                                  Color(0xFFD9F0EF),
                                ],
                                stops: [0.0, 0.35, 1.0],
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  // Dot texture
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _DotPatternPainter(),
                                    ),
                                  ),
                                  // Placeholder illustration
                                  Center(
                                    child: _WelcomeIllustration(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Heading
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(28, 32, 28, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'One app.\nYour identity.\nYour rewards.',
                                style: AppTypography.h2.copyWith(
                                  fontSize: 32,
                                  color: AppColors.navy,
                                  letterSpacing: -0.7,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'The companion app for Accindi research participants. Manage your ID and earnings in one place.',
                                style: AppTypography.mReg
                                    .copyWith(color: AppColors.ink2),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Action buttons — always visible, pinned at bottom
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PrimaryButton(
                          label: 'Log In', onPressed: onLogin),
                      const SizedBox(height: 12),
                      OutlineButton(
                          label: 'Create Account',
                          onPressed: onRegister),
                      const SizedBox(height: 18),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Learn more about Accindi',
                          style: AppTypography.sBold.copyWith(
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Dot pattern overlay for the illustration area
class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.navy.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    const spacing = 14.0;
    const radius = 0.6;

    for (double x = 2; x < size.width; x += spacing) {
      for (double y = 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Placeholder illustration widget — QR code + document visual
class _WelcomeIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Card backdrop
          Positioned(
            top: 10,
            child: Transform.rotate(
              angle: -0.05,
              child: Container(
                width: 180,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // QR code placeholder
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.navy.withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                      ),
                      child: CustomPaint(
                        painter: _QRPlaceholderPainter(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Lines placeholder
                    Container(
                      width: 80,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.navy.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 56,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.navy.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Gold accent circle
          Positioned(
            top: 0,
            right: 20,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Teal accent circle
          Positioned(
            bottom: 0,
            left: 20,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QRPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.navy.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final cellSize = size.width / 7;
    final random = math.Random(42); // Fixed seed for consistent pattern

    // Draw QR-like grid pattern
    for (int row = 0; row < 7; row++) {
      for (int col = 0; col < 7; col++) {
        // Corner squares (QR finder patterns)
        bool isCorner = (row < 2 && col < 2) ||
            (row < 2 && col > 4) ||
            (row > 4 && col < 2);

        if (isCorner || random.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(
              col * cellSize + 2,
              row * cellSize + 2,
              cellSize - 2,
              cellSize - 2,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
