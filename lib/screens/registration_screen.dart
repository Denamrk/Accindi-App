import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/top_bar.dart';
import '../widgets/primary_button.dart';
import '../widgets/floating_label_field.dart';
import '../services/bix_api.dart';

class RegistrationScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onLogin;

  const RegistrationScreen({
    super.key,
    this.onBack,
    this.onLogin,
  });

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _phone = '';
  String _pin = '';
  String _confirmPin = '';
  bool _agreed = false;
  bool _loading = false;

  bool get _isValid =>
      _firstName.isNotEmpty &&
      _lastName.isNotEmpty &&
      _email.isNotEmpty &&
      _isValidEmail(_email) &&
      _pin.length == 8 &&
      _pin == _confirmPin &&
      _agreed;

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  Future<void> _handleSubmit() async {
    if (!_isValid || _loading) return;

    setState(() => _loading = true);

    final response = await BixApi.registerUser(
      firstName: _firstName,
      lastName: _lastName,
      email: _email,
      pin: _pin,
      mobileNo: _phone,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (response.isSuccess) {
      // Show success message — user needs to check email to activate
      _showResultDialog(
        title: 'Account Created',
        message: response.displayMessage.isNotEmpty
            ? response.displayMessage
            : 'Your account has been created. Please check your email to activate your account, then log in.',
        isSuccess: true,
        onDismiss: () {
          Navigator.of(context).pop(); // close dialog
          // Go to login screen after successful registration
          widget.onLogin?.call();
        },
      );
    } else {
      _showResultDialog(
        title: response.isInfo ? 'Notice' : 'Error',
        message: response.displayMessage.isNotEmpty
            ? response.displayMessage
            : 'Registration failed. Please try again.',
        isSuccess: false,
      );
    }
  }

  void _showResultDialog({
    required String title,
    required String message,
    required bool isSuccess,
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isSuccess,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.info_outline,
              color: isSuccess ? AppColors.teal : AppColors.navy,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: AppTypography.mBold.copyWith(color: AppColors.ink),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTypography.sReg.copyWith(color: AppColors.ink2),
        ),
        actions: [
          TextButton(
            onPressed: onDismiss ?? () => Navigator.of(ctx).pop(),
            child: Text(
              isSuccess ? 'Continue' : 'OK',
              style: AppTypography.sBold.copyWith(color: AppColors.navy),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top bar
          TopBar(
            title: 'Create Account',
            onBack: widget.onBack,
          ),

          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section heading
                  Text(
                    'Tell us about you',
                    style: AppTypography.h4.copyWith(color: AppColors.navy),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'We use this to verify your identity for studies you participate in.',
                    style: AppTypography.sReg.copyWith(color: AppColors.ink3),
                  ),
                  const SizedBox(height: 20),

                  // Form fields
                  FloatingLabelField(
                    label: 'First Name',
                    placeholder: 'Anna',
                    value: _firstName,
                    onChanged: (v) => setState(() => _firstName = v),
                  ),
                  FloatingLabelField(
                    label: 'Last Name',
                    placeholder: 'Lindqvist',
                    value: _lastName,
                    onChanged: (v) => setState(() => _lastName = v),
                  ),
                  FloatingLabelField(
                    label: 'Email',
                    placeholder: 'anna@example.com',
                    value: _email,
                    onChanged: (v) => setState(() => _email = v),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  FloatingLabelField(
                    label: 'Mobile Number',
                    placeholder: '+46 70 123 4567',
                    value: _phone,
                    onChanged: (v) => setState(() => _phone = v),
                    keyboardType: TextInputType.phone,
                    prefix: '+46',
                  ),
                  FloatingLabelField(
                    label: 'PIN',
                    placeholder: '••••••••',
                    value: _pin,
                    onChanged: (v) => setState(() => _pin = v),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    maxLength: 8,
                    help: "8 digits — you'll use this to log in",
                  ),
                  FloatingLabelField(
                    label: 'Confirm PIN',
                    placeholder: '••••••••',
                    value: _confirmPin,
                    onChanged: (v) => setState(() => _confirmPin = v),
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(8),
                    ],
                    maxLength: 8,
                  ),

                  // Terms checkbox
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(top: 1),
                          decoration: BoxDecoration(
                            color: _agreed ? AppColors.navy : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _agreed ? AppColors.navy : AppColors.ink3,
                              width: 1.5,
                            ),
                          ),
                          child: _agreed
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: AppTypography.sReg
                                  .copyWith(color: AppColors.ink2),
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: AppTypography.sReg.copyWith(
                                    color: AppColors.navy,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: AppTypography.sReg.copyWith(
                                    color: AppColors.navy,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  _loading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: CircularProgressIndicator(
                              color: AppColors.navy,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      : PrimaryButton(
                          label: 'Create Account',
                          onPressed: _isValid ? _handleSubmit : null,
                          disabled: !_isValid,
                        ),

                  // Login link
                  const SizedBox(height: 20),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        style:
                            AppTypography.sReg.copyWith(color: AppColors.ink2),
                        children: [
                          const TextSpan(text: 'Already have an account? '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: widget.onLogin,
                              child: Text(
                                'Log In',
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
