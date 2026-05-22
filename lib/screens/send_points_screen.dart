import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/top_bar.dart';
import '../widgets/primary_button.dart';
import '../widgets/floating_label_field.dart';

class SendPointsScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const SendPointsScreen({super.key, this.onBack});

  @override
  State<SendPointsScreen> createState() => _SendPointsScreenState();
}

class _SendPointsScreenState extends State<SendPointsScreen> {
  String _to = '';
  String _amount = '';
  String _note = '';
  final int _available = 1330;

  int get _amountNum => int.tryParse(_amount) ?? 0;
  bool get _isValid => _to.isNotEmpty && _amountNum > 0 && _amountNum <= _available;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          TopBar(title: 'Send Points', onBack: widget.onBack),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              children: [
                FloatingLabelField(
                  label: 'To',
                  placeholder: 'Name, email, or Wallet ID',
                  value: _to,
                  onChanged: (v) => setState(() => _to = v),
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
                          color: _amount.isNotEmpty ? AppColors.navy : AppColors.ink3,
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
                const SizedBox(height: 8),
                Center(
                  child: Text.rich(
                    TextSpan(
                      style: AppTypography.xsReg.copyWith(color: AppColors.ink3),
                      children: [
                        const TextSpan(text: 'Available: '),
                        TextSpan(
                          text: '${_available.toString()} pts',
                          style: AppTypography.xsReg.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                FloatingLabelField(
                  label: 'Note (optional)',
                  placeholder: "What's this for?",
                  value: _note,
                  onChanged: (v) => setState(() => _note = v),
                ),

                const SizedBox(height: 40),

                PrimaryButton(
                  label: 'Review & Send',
                  onPressed: _isValid ? () {} : null,
                  disabled: !_isValid,
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "You'll confirm before sending",
                    style: AppTypography.xsReg.copyWith(color: AppColors.ink3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
