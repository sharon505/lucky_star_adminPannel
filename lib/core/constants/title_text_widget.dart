import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucky_star_admin/core/theme/color_scheme.dart';

import '../theme/text_styles.dart';

class TitleTextWidget extends StatelessWidget {
  final String? text;
  final double? fontSize;
  const TitleTextWidget({super.key, required this.text, this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(text ?? 'add text here',style: AppTypography.heading2.copyWith(
      fontSize: fontSize ??  20.sp,
      color: AppTheme.adminGreen
    ),);
  }
}
