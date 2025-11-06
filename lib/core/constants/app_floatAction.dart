import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/color_scheme.dart';

class AppFloatAction extends StatelessWidget {
  final  Function()? onPressed;
  final IconData? icon;
  const AppFloatAction({super.key, this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed ?? () => log('add fuction'),
      backgroundColor: AppTheme.adminGreen,
      child: Icon(icon ?? Icons.search,size: 30.sp,),
    );
  }
}
