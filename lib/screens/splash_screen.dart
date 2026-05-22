import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/logo_mark.dart';
import '../widgets/wordmark.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onDone;
  final bool auto;

  const SplashScreen({super.key, this.onDone, this.auto = true});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _spinController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 8 / 844),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _spinController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();

    _fadeController.forward();

    if (widget.auto) {
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) widget.onDone?.call();
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Radial gradient background wash
          Positioned.fill(
            child: CustomPaint(
              painter: _WarmGradientPainter(),
            ),
          ),

          // Content
          Positioned.fill(
            child: SafeArea(
              child: Column(
              children: [
                const Spacer(),

                // Logo + wordmark + tagline
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LogoMark(size: 88),
                        const SizedBox(height: 24),
                        const Wordmark(size: 36),
                        const SizedBox(height: 10),
                        Text(
                          'Your Research ID & Wallet',
                          style: AppTypography.sReg
                              .copyWith(color: AppColors.ink2),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Spinner
                Padding(
                  padding: const EdgeInsets.only(bottom: 90),
                  child: AnimatedBuilder(
                    animation: _spinController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _spinController.value * 2 * math.pi,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.navy.withValues(alpha: 0.13),
                          width: 2.5,
                        ),
                      ),
                      child: CustomPaint(
                        painter: _SpinnerArcPainter(),
                      ),
                    ),
                  ),
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

class _WarmGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.3),
        radius: 1.2,
        colors: [
          const Color(0xFFFEEECC).withValues(alpha: 0.7),
          const Color(0xFFF6F5F1).withValues(alpha: 0.7),
          const Color(0xFFEFEEE9).withValues(alpha: 0.7),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SpinnerArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.navy
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final rect = Offset.zero & size;
    canvas.drawArc(rect, -math.pi / 2, math.pi / 2, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
