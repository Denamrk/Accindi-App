import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextStyle _inter({
    required double fontSize,
    required FontWeight fontWeight,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static final h2 = _inter(fontSize: 40, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.8);
  static final h3 = _inter(fontSize: 30, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.6);
  static final h4 = _inter(fontSize: 20, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.5);

  static final pretitle = _inter(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.16 * 12);

  static final xlReg = _inter(fontSize: 20, fontWeight: FontWeight.w400, height: 1.4, letterSpacing: -0.5);

  static final lReg = _inter(fontSize: 18, fontWeight: FontWeight.w400, height: 1.4, letterSpacing: -0.4);
  static final lBold = _inter(fontSize: 18, fontWeight: FontWeight.w700, height: 1.4, letterSpacing: -0.4);

  static final mReg = _inter(fontSize: 16, fontWeight: FontWeight.w400, height: 1.4, letterSpacing: -0.3);
  static final mBold = _inter(fontSize: 16, fontWeight: FontWeight.w700, height: 1.4, letterSpacing: -0.3);

  static final sReg = _inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4, letterSpacing: -0.2);
  static final sBold = _inter(fontSize: 14, fontWeight: FontWeight.w700, height: 1.4, letterSpacing: -0.2);

  static final xsReg = _inter(fontSize: 12, fontWeight: FontWeight.w400, height: 1.3, letterSpacing: -0.1);
  static final xsBold = _inter(fontSize: 12, fontWeight: FontWeight.w700, height: 1.3, letterSpacing: -0.1);
}
