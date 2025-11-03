import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'color_scheme.dart';

class AppTypography {
  // 🎯 Headings
  static TextStyle heading1 = TextStyle(
    fontFamily: "Boldonse",
    fontSize: 24.sp,
    color: AppTheme.textPrimary,
  );

  static TextStyle heading2 = GoogleFonts.oswald(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: AppTheme.textPrimary,
  );

  static TextStyle heading3 = GoogleFonts.poiretOne(
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
    color: AppTheme.textPrimary,
  );

  // 📝 Body
  static TextStyle body = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppTheme.textSecondary,
  );

  static TextStyle bodyBold = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppTheme.textPrimary,
  );

  // 🔘 Buttons
  static TextStyle button = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // 🎉 Rewards
  static TextStyle rewardTitle = TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
    color: AppTheme.primary,
  );

  static TextStyle rewardSubtitle = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: AppTheme.accentGreen,
  );

  // ⚠️ Error
  static TextStyle error = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppTheme.accentRed,
  );
}
