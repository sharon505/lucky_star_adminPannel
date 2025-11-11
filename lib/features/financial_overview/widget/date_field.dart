import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/color_scheme.dart';

class DateField extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppTheme.adminGreen.withOpacity(.12),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppTheme.adminGreen.withOpacity(.35)),
        ),
        child: Row(
          children: [
            Icon(Icons.event_outlined, color: AppTheme.adminWhite.withOpacity(.9)),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                        color: AppTheme.adminWhite,
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(height: 2.h),
                  Text(text, style: TextStyle(color: AppTheme.adminWhite.withOpacity(.9))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}