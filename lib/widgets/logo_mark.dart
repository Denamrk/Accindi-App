import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class LogoMark extends StatelessWidget {
  final double size;

  const LogoMark({super.key, this.size = 88});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(size * 0.27),
        boxShadow: const [
          BoxShadow(
            color: Color(0x401A365D),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'a',
              style: GoogleFonts.inter(
                fontSize: size * 0.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1,
                letterSpacing: -size * 0.02,
              ),
            ),
            Container(
              width: size * 0.09,
              height: size * 0.09,
              margin: EdgeInsets.only(left: size * 0.02),
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
