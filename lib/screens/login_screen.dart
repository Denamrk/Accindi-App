import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onForgot;

  const LoginScreen({super.key, this.onSuccess, this.onForgot});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigit(String digit) {
    if (_pin.length >= 8) return;
    setState(() => _pin += digit);

    // Auto-submit when 8 digits entered
    if (_pin.length == 8) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          widget.onSuccess?.call();
          setState(() => _pin = '');
        }
      });
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Spacer(),

            // Heading
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Enter Your PIN',
                    style: AppTypography.h4.copyWith(
                      fontSize: 24,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '8-digit PIN',
                    style: AppTypography.sReg.copyWith(color: AppColors.ink3),
                  ),
                ],
              ),
            ),

            // PIN dots
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final shake = _shakeController.isAnimating
                    ? _shakeOffset(_shakeController.value)
                    : 0.0;
                return Transform.translate(
                  offset: Offset(shake, 0),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(8, (i) {
                  final filled = i < _pin.length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled ? AppColors.navy : Colors.transparent,
                        border: Border.all(
                          color: filled ? AppColors.navy : AppColors.ink3,
                          width: 1.5,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const Spacer(),

            // Keypad
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Column(
                children: [
                  // Rows 1-3
                  for (int row = 0; row < 3; row++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          for (int col = 0; col < 3; col++) ...[
                            if (col > 0) const SizedBox(width: 12),
                            Expanded(
                              child: _KeypadButton(
                                digit: '${row * 3 + col + 1}',
                                onTap: () =>
                                    _onDigit('${row * 3 + col + 1}'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  // Bottom row: empty, 0, delete
                  Row(
                    children: [
                      Expanded(child: Container(height: 64)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _KeypadButton(
                          digit: '0',
                          onTap: () => _onDigit('0'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DeleteKeyButton(onTap: _onDelete),
                      ),
                    ],
                  ),

                  // Forgot PIN link
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: widget.onForgot,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Forgot PIN?',
                        style: AppTypography.sBold.copyWith(
                          color: AppColors.navy,
                          decoration: TextDecoration.underline,
                        ),
                      ),
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

  /// Generates shake offset from animation value (0→1)
  double _shakeOffset(double t) {
    // Quick oscillation: -6, 6, -6, 6, 0
    return 6 * (1 - t) * (((t * 4).round() % 2 == 0) ? -1 : 1);
  }
}

class _KeypadButton extends StatefulWidget {
  final String digit;
  final VoidCallback onTap;

  const _KeypadButton({required this.digit, required this.onTap});

  @override
  State<_KeypadButton> createState() => _KeypadButtonState();
}

class _KeypadButtonState extends State<_KeypadButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 64,
        decoration: BoxDecoration(
          color: _pressed ? AppColors.navySoft : const Color(0xFFF5F5F2),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Text(
            widget.digit,
            style: AppTypography.h3.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: AppColors.navy,
              letterSpacing: -0.6,
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteKeyButton extends StatefulWidget {
  final VoidCallback onTap;

  const _DeleteKeyButton({required this.onTap});

  @override
  State<_DeleteKeyButton> createState() => _DeleteKeyButtonState();
}

class _DeleteKeyButtonState extends State<_DeleteKeyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 64,
        decoration: BoxDecoration(
          color: _pressed ? AppColors.navySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.backspace_outlined,
          color: AppColors.navy,
          size: 26,
        ),
      ),
    );
  }
}
