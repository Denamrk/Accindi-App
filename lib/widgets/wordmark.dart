import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class Wordmark extends StatelessWidget {
  final double size;
  final Color color;
  final Color dotColor;

  const Wordmark({
    super.key,
    this.size = 28,
    this.color = AppColors.navy,
    this.dotColor = AppColors.gold,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'accindi',
          style: GoogleFonts.inter(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: -size * 0.03,
            height: 1,
          ),
        ),
        Container(
          width: size * 0.18,
          height: size * 0.18,
          margin: const EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
