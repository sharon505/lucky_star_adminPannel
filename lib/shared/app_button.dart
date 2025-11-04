import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/theme/color_scheme.dart';
import '../core/theme/text_styles.dart';


class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? textColor;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;
  final TextStyle? style;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height, this.style,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 48.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppTheme.adminGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
          width: 22.w,
          height: 22.w,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
            ],
            Text(
              text,
              style: style ?? AppTypography.heading2.copyWith(
                fontSize: 20.sp,
                color: textColor ?? AppTheme.adminDrawer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
