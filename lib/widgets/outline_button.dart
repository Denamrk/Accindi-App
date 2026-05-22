import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class OutlineButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;

  const OutlineButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  State<OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<OutlineButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) {
        setState(() => _hovered = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.navy.withValues(alpha: 0.04)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.navy,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: AppTypography.lBold.copyWith(color: AppColors.navy),
        ),
      ),
    );
  }
}
