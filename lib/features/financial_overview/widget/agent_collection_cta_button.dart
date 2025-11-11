import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/color_scheme.dart';

class AgentCollectionCTAButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final double? minHeight;
  final EdgeInsetsGeometry? contentPadding;

  const AgentCollectionCTAButton({
    super.key,
    this.onTap,
    this.title = 'Get Collection',
    this.subtitle = 'Products • Agent • Receivable • Collected',
    this.leadingIcon = Icons.payments_outlined,
    this.minHeight,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final _minH = minHeight ?? 110.h;
    final _pad  = contentPadding ?? EdgeInsets.all(18.w);

    return Semantics(
      button: true,
      label: title,
      hint: 'Opens agent collection',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          splashColor: AppTheme.adminWhite.withOpacity(.15),
          highlightColor: AppTheme.adminWhite.withOpacity(.05),
          child: Ink(
            padding: _pad,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.adminGreenLite, AppTheme.adminGreenDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.adminGreenDark.withOpacity(.35),
                  offset: const Offset(0, 8),
                  blurRadius: 18,
                ),
              ],
              border: Border.all(color: AppTheme.adminGreenDarker),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: _minH),
              child: Stack(
                children: [
                  Positioned(
                    right: -20.w,
                    top: -20.h,
                    child: Icon(
                      Icons.payments_rounded,
                      size: 120.sp,
                      color: AppTheme.adminWhite.withOpacity(.08),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppTheme.adminWhite.withOpacity(.10),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: AppTheme.adminGreenDarker),
                        ),
                        child: Icon(leadingIcon, color: AppTheme.adminWhite, size: 22.sp),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.adminWhite,
                                fontWeight: FontWeight.w800,
                                fontSize: 16.sp,
                                letterSpacing: .2,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.adminWhite.withOpacity(.90),
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Icon(Icons.arrow_forward_ios_rounded, size: 18.sp, color: AppTheme.adminWhite.withOpacity(.9)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}