import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_padding.dart';
import '../../../shared/app_button.dart';

Widget button({Function()? onPressed,String? text, EdgeInsetsGeometry? padding}) {
  return Padding(
    padding: padding ?? AppPadding.allMedium.copyWith(bottom: 25.h),
    child: AppButton(
      height: 60.h,
      text: text ??  "Get Started",
      onPressed: onPressed ?? () => debugPrint('$text button pressed'),
    ),
  );
}