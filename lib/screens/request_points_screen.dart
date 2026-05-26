import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/top_bar.dart';
import '../widgets/primary_button.dart';
import '../widgets/floating_label_field.dart';
import '../services/bix_api.dart';
import '../services/session.dart';
import '../services/wallet_state.dart';

class RequestPointsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const RequestPointsScreen({super.key, this.onBack});

  @override
  State<RequestPointsScreen> createState() => _RequestPointsScreenState();
}

class _RequestPointsScreenState extends State<RequestPointsScreen> {
  String _from = '';
  String _amount = '';
  String _reason = '';
  bool _loading = false;

  int get _amountNum => int.tryParse(_amount) ?? 0;

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  bool get _isValid => _isValidEmail(_from) && _amountNum > 0;

  Future<void> _handleSubmit() async {
    if (!_isValid || _loading) return;

    setState(() => _loading = true);

    final session = Session();
    final response = await BixApi.requestPayment(
      authorizationKey: session.authorizationKey!,
      senderEmail: session.email!,
      receiverEmail: _from,
      amount: '$_amountNum.00',
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (response.isSuccess) {
      // Refresh wallet data
      WalletState().fetch();

      _showResultDialog(
        title: 'Request Sent',
        message: response.displayMessage.isNotEmpty
            ? response.displayMessage
            : 'Payment request for $_amountNum pts sent to $_from.',
        isSuccess: true,
      );
    } else {
      _showResultDialog(
        title: response.isInfo ? 'Notice' : 'Error',
        message: response.displayMessage.isNotEmpty
            ? response.displayMessage
            : 'Failed to send request. Please try again.',
        isSuccess: false,
      );
    }
  }

  void _showResultDialog({
    required String title,
    required String message,
    required bool isSuccess,
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
            Expanded(
              child: Text(
                title,
                style: AppTypography.mBold.copyWith(color: AppColors.ink),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTypography.sReg.copyWith(color: AppColors.ink2),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (isSuccess) {
                widget.onBack?.call(); // Go back to wallet
              }
            },
            child: Text(
              isSuccess ? 'Done' : 'OK',
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
          TopBar(title: 'Request Points', onBack: widget.onBack),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              children: [
                FloatingLabelField(
                  label: 'From (email)',
                  placeholder: 'user@example.com',
                  value: _from,
                  onChanged: (v) => setState(() => _from = v),
                  keyboardType: TextInputType.emailAddress,
                ),

                // Big amount field
                const SizedBox(height: 4),
                Text(
                  'AMOUNT',
                  style: AppTypography.xsBold.copyWith(
                    color: AppColors.ink3,
                    letterSpacing: 0.48,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.hair, width: 1.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 20,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      TextField(
                        onChanged: (v) => setState(() => _amount = v),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        textAlign: TextAlign.center,
                        style: AppTypography.h2.copyWith(
                          fontSize: 48,
                          color: _amount.isNotEmpty
                              ? AppColors.navy
                              : AppColors.ink3,
                          letterSpacing: -1,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: AppTypography.h2.copyWith(
                            fontSize: 48,
                            color: AppColors.ink3,
                            letterSpacing: -1,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: Text(
                          'pts',
                          style: AppTypography.lBold.copyWith(
                            color: AppColors.ink3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Reason textarea
                Text(
                  'REASON',
                  style: AppTypography.xsBold.copyWith(
                    color: AppColors.ink3,
                    letterSpacing: 0.48,
                  ),
                ),
                const SizedBox(height: 6),
                _ReasonField(
                  value: _reason,
                  onChanged: (v) => setState(() => _reason = v),
                ),

                const SizedBox(height: 40),

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
                        label: 'Send Request',
                        onPressed: _isValid ? _handleSubmit : null,
                        disabled: !_isValid,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonField extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _ReasonField({required this.value, required this.onChanged});

  @override
  State<_ReasonField> createState() => _ReasonFieldState();
}

class _ReasonFieldState extends State<_ReasonField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _focused ? AppColors.navy : AppColors.hair,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        onChanged: widget.onChanged,
        maxLines: 3,
        style: AppTypography.mReg.copyWith(color: AppColors.ink),
        decoration: InputDecoration(
          hintText: 'Why are you requesting?',
          hintStyle: AppTypography.mReg.copyWith(color: AppColors.ink3),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        onTap: () => setState(() => _focused = true),
        onEditingComplete: () => setState(() => _focused = false),
      ),
    );
  }
}
