import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucky_star_admin/core/constants/app_padding.dart';
import 'package:lucky_star_admin/core/theme/color_scheme.dart';
import '../../../../core/theme/text_styles.dart';

enum SquareTileStyle { filled, outline, subtle }

class SquareIconTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onTap;

  // Visuals
  final SquareTileStyle style;
  final bool selected;
  final bool disabled;
  final bool uppercase;
  final double borderRadius;
  final double iconSize;

  // Optional badge (e.g., count)
  final String? badge;

  const SquareIconTile({
    super.key,
    required this.text,
    required this.icon,
    this.onTap,
    this.style = SquareTileStyle.filled,
    this.selected = false,
    this.disabled = false,
    this.uppercase = true,
    this.borderRadius = 12,
    this.iconSize = 28,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isInteractive = onTap != null && !disabled;
    final label = uppercase ? text.toUpperCase() : text;

    // Colors
    const cWhite = AppTheme.adminWhite;
    const cGreen = AppTheme.adminGreen;
    const cDk3  = AppTheme.adminGreenDarker;
    const cDk2  = AppTheme.adminGreenDark;
    const cDk1  = AppTheme.adminGreenLite;

    // Decoration by style
    BoxDecoration deco;
    switch (style) {
      case SquareTileStyle.filled:
        deco = BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [cDk3, cDk2, cDk1],
          ),
          borderRadius: BorderRadius.circular(borderRadius.r),
          border: Border.all(
            color: selected ? cGreen.withOpacity(.55) : cWhite.withOpacity(.10),
            width: selected ? 1.2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: cGreen.withOpacity(.25), blurRadius: 18, offset: const Offset(0, 6))]
              : [BoxShadow(color: Colors.black.withOpacity(.20), blurRadius: 12, offset: const Offset(0, 8))],
        );
        break;

      case SquareTileStyle.outline:
        deco = BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius.r),
          border: Border.all(
            color: selected ? cGreen : cWhite.withOpacity(.18),
            width: selected ? 1.4 : 1,
          ),
        );
        break;

      case SquareTileStyle.subtle:
        deco = BoxDecoration(
          color: cWhite.withOpacity(.06),
          borderRadius: BorderRadius.circular(borderRadius.r),
          border: Border.all(color: cWhite.withOpacity(.10), width: 1),
        );
        break;
    }

    final iconColor = AppTheme.adminGreen;
    final textColor = disabled ? cWhite.withOpacity(.60) : cWhite;

    return AspectRatio(
      aspectRatio: 1, // keep it perfectly square
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isInteractive ? onTap : null,
          borderRadius: BorderRadius.circular(borderRadius.r),
          splashColor: cGreen.withOpacity(.18),
          highlightColor: cGreen.withOpacity(.10),
          child: Ink(
            decoration: deco,
            child: Stack(
              children: [
                // content
                Center(
                  child: Padding(
                    padding: AppPadding.allLarge.copyWith(
                      left: 18.w, right: 18.w, top: 16.h, bottom: 16.h,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: iconColor, size: iconSize.sp),
                        SizedBox(height: 10.h),
                        Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyBold.copyWith(
                            fontSize: 11.sp,
                            color: textColor,
                            letterSpacing: .3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // badge (optional)
                if (badge != null && badge!.trim().isNotEmpty)
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: cGreen.withOpacity(.15),
                        borderRadius: BorderRadius.circular(999.r),
                        border: Border.all(color: cGreen.withOpacity(.6)),
                      ),
                      child: Text(
                        badge!,
                        style: AppTypography.bodyBold.copyWith(
                          color: cGreen,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                // disabled overlay
                if (disabled)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.15),
                      borderRadius: BorderRadius.circular(borderRadius.r),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
