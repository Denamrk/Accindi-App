import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class FloatingLabelField extends StatefulWidget {
  final String label;
  final String? placeholder;
  final String? help;
  final String? prefix;
  final String value;
  final ValueChanged<String> onChanged;
  final bool obscureText;
  final bool autofocus;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const FloatingLabelField({
    super.key,
    required this.label,
    this.placeholder,
    this.help,
    this.prefix,
    required this.value,
    required this.onChanged,
    this.obscureText = false,
    this.autofocus = false,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  State<FloatingLabelField> createState() => _FloatingLabelFieldState();
}

class _FloatingLabelFieldState extends State<FloatingLabelField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  bool get _lifted => _focused || widget.value.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void didUpdateWidget(FloatingLabelField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _focused ? AppColors.navy : AppColors.hair,
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              children: [
                // Floating label
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  left: 0,
                  top: _lifted ? 10 : 20,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 140),
                    style: _lifted
                        ? AppTypography.xsReg.copyWith(
                            color: _focused ? AppColors.navy : AppColors.ink3,
                            fontWeight: FontWeight.w600,
                          )
                        : AppTypography.mReg.copyWith(
                            color: AppColors.ink3,
                          ),
                    child: Text(widget.label),
                  ),
                ),

                // Input row
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(top: _lifted ? 14 : 0),
                    child: Row(
                      children: [
                        if (widget.prefix != null && _lifted)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Text(
                              widget.prefix!,
                              style: AppTypography.mReg
                                  .copyWith(color: AppColors.ink2),
                            ),
                          ),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            autofocus: widget.autofocus,
                            obscureText: widget.obscureText,
                            keyboardType: widget.keyboardType,
                            inputFormatters: widget.inputFormatters,
                            maxLength: widget.maxLength,
                            style: AppTypography.mReg
                                .copyWith(color: AppColors.ink),
                            decoration: InputDecoration(
                              hintText: _lifted ? widget.placeholder : null,
                              hintStyle: AppTypography.mReg
                                  .copyWith(color: AppColors.ink3),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              counterText: '',
                            ),
                            onChanged: widget.onChanged,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Help text
          if (widget.help != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                widget.help!,
                style: AppTypography.xsReg.copyWith(color: AppColors.ink3),
              ),
            ),
        ],
      ),
    );
  }
}
