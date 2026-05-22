import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/top_bar.dart';
import '../widgets/primary_button.dart';
import '../widgets/floating_label_field.dart';

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

  int get _amountNum => int.tryParse(_amount) ?? 0;
  bool get _isValid => _from.isNotEmpty && _amountNum > 0;

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
                  label: 'From',
                  placeholder: 'Name, email, or Wallet ID',
                  value: _from,
                  onChanged: (v) => setState(() => _from = v),
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

                PrimaryButton(
                  label: 'Send Request',
                  onPressed: _isValid ? () {} : null,
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
