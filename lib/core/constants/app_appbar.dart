import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucky_star_admin/core/theme/color_scheme.dart';

import '../theme/text_styles.dart';

class AppAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? text;
  const AppAppbar({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: IconThemeData(color: AppTheme.adminWhite,size: 27.sp),
      backgroundColor: AppTheme.adminGreenDark,
      title: Text(text ?? 'data',style: AppTypography.heading1.copyWith(
        fontSize: 17.sp,
        color: AppTheme.adminGreen
      ),),
    );
  }


  @override
  Size get preferredSize =>
      Size.fromHeight(65.h);
}
