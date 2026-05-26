import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/floating_label_field.dart';
import '../widgets/primary_button.dart';
import '../services/bix_api.dart';
import '../services/session.dart';
import '../services/wallet_state.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onForgot;

  /// If true, skip email entry and go straight to PIN (returning user).
  final bool pinOnly;

  const LoginScreen({
    super.key,
    this.onSuccess,
    this.onForgot,
    this.pinOnly = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Two-step login: email first, then PIN
  bool _emailConfirmed = false;
  String _email = '';
  String _pin = '';
  bool _loading = false;
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );

    // Returning user: skip email step, go straight to PIN
    if (widget.pinOnly && Session().email != null) {
      _email = Session().email!;
      _emailConfirmed = true;
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  void _confirmEmail() {
    if (_isValidEmail(_email)) {
      setState(() => _emailConfirmed = true);
    }
  }

  void _onDigit(String digit) {
    if (_pin.length >= 8 || _loading) return;
    setState(() => _pin += digit);

    // Auto-submit when 8 digits entered
    if (_pin.length == 8) {
      _handleLogin();
    }
  }

  void _onDelete() {
    if (_pin.isEmpty || _loading) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _handleLogin() async {
    setState(() => _loading = true);

    final response = await BixApi.loginUser(
      email: _email,
      pin: _pin,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (response.isSuccess) {
      // Save session data locally
      await Session().setFromLoginData(response.data);
      Session().email = _email;

      // Fetch wallet balance & transactions before navigating
      await WalletState().fetch();

      if (!mounted) return;
      widget.onSuccess?.call();
    } else {
      // Shake the dots and show error
      _shakeController.forward(from: 0);
      setState(() => _pin = '');

      _showErrorSnackBar(
        response.displayMessage.isNotEmpty
            ? response.displayMessage
            : 'Login failed. Please check your credentials.',
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTypography.sReg.copyWith(color: Colors.white),
        ),
        backgroundColor: const Color(0xFFCF3B3B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _emailConfirmed ? _buildPinEntry() : _buildEmailEntry(),
      ),
    );
  }

  // ── Step 1: Email entry ──────────────────────────────────────

  Widget _buildEmailEntry() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Spacer(),

          // Heading
          Text(
            'Welcome Back',
            style: AppTypography.h4.copyWith(
              fontSize: 24,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter your email to continue',
            style: AppTypography.sReg.copyWith(color: AppColors.ink3),
          ),
          const SizedBox(height: 32),

          // Email field
          FloatingLabelField(
            label: 'Email',
            placeholder: 'anna@example.com',
            value: _email,
            onChanged: (v) => setState(() => _email = v),
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
          ),

          const SizedBox(height: 8),
          PrimaryButton(
            label: 'Continue',
            onPressed: _isValidEmail(_email) ? _confirmEmail : null,
            disabled: !_isValidEmail(_email),
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  // ── Step 2: PIN keypad entry ─────────────────────────────────

  Widget _buildPinEntry() {
    return Column(
      children: [
        const SizedBox(height: 16),

        // Back to email entry
        Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: () => setState(() {
              _emailConfirmed = false;
              _pin = '';
              _email = '';
            }),
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.chevron_left,
                  color: AppColors.navy,
                  size: 28,
                ),
              ),
            ),
          ),
        ),

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
                _email,
                style: AppTypography.sReg.copyWith(color: AppColors.ink3),
              ),
            ],
          ),
        ),

        // PIN dots or loading spinner
        const SizedBox(height: 32),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 3),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: AppColors.navy,
                strokeWidth: 2,
              ),
            ),
          )
        else
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
                            onTap: () => _onDigit('${row * 3 + col + 1}'),
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
    );
  }

  double _shakeOffset(double t) {
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
        child: const Icon(
          Icons.backspace_outlined,
          color: AppColors.navy,
          size: 26,
        ),
      ),
    );
  }
}
