import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/color_scheme.dart';

class PrimaryCTAButton extends StatelessWidget {
  final VoidCallback? onTap;

  /// Main title (bold)
  final String title;

  /// Subtitle (small description)
  final String subtitle;

  /// Small leading icon at the left
  final IconData leadingIcon;

  /// Big faded icon in the background (optional)
  final IconData? backgroundIcon;

  /// Minimum height of the card
  final double? minHeight;

  /// Inner padding
  final EdgeInsetsGeometry? contentPadding;

  /// Gradient background
  final Gradient? gradient;

  /// Border color
  final Color? borderColor;

  /// Shadow color
  final Color? shadowColor;

  /// Show / hide arrow on the right
  final bool showArrow;

  /// For accessibility (screen readers)
  final String? semanticsLabel;
  final String? semanticsHint;

  const PrimaryCTAButton({
    super.key,
    this.onTap,
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    this.backgroundIcon,
    this.minHeight,
    this.contentPadding,
    this.gradient,
    this.borderColor,
    this.shadowColor,
    this.showArrow = true,
    this.semanticsLabel,
    this.semanticsHint,
  });

  @override
  Widget build(BuildContext context) {
    final _minH = minHeight ?? 110.h;
    final _pad  = contentPadding ?? EdgeInsets.all(18.w);

    final Gradient effectiveGradient = gradient ??
        const LinearGradient(
          colors: [AppTheme.adminGreenLite, AppTheme.adminGreenDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

    final Color effectiveBorder = borderColor ?? AppTheme.adminGreenDarker;
    final Color effectiveShadow = shadowColor ?? AppTheme.adminGreenDark.withOpacity(.35);

    return Semantics(
      button: true,
      label: semanticsLabel ?? title,
      hint: semanticsHint ?? 'Opens $title',
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
              gradient: effectiveGradient,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: effectiveShadow,
                  offset: const Offset(0, 8),
                  blurRadius: 18,
                ),
              ],
              border: Border.all(color: effectiveBorder),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: _minH),
              child: Stack(
                children: [
                  if (backgroundIcon != null)
                    Positioned(
                      right: -20.w,
                      top: -20.h,
                      child: Icon(
                        backgroundIcon,
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
                          border: Border.all(color: effectiveBorder),
                        ),
                        child: Icon(
                          leadingIcon,
                          color: AppTheme.adminWhite,
                          size: 22.sp,
                        ),
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
                      if (showArrow)
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18.sp,
                          color: AppTheme.adminWhite.withOpacity(.9),
                        ),
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
