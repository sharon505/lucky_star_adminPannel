import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/color_scheme.dart';

class AgentCollectionCTAButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String title;
  final String subtitle;
  final IconData leadingIcon;

  /// Control overall height (defaults to a taller button)
  final double? minHeight;

  /// Optional: extra internal padding if you want even more spacing
  final EdgeInsetsGeometry? contentPadding;

  const AgentCollectionCTAButton({
    super.key,
    this.onTap,
    this.title = 'Get Collection',
    this.subtitle = 'Products • Agent • Receivable • Collected',
    this.leadingIcon = Icons.payments_outlined,
    this.minHeight, // if null, we set a nice tall default below
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final grad1 = AppTheme.adminGreenLite;
    final grad2 = AppTheme.adminGreenDark;
    final onTile = Colors.white;

    final _minH = minHeight ?? 110.h; // ⬅️ taller default (was ~60–80 before)
    final _pad  = contentPadding ?? EdgeInsets.all(18.w); // a bit roomier

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
          splashColor: Colors.white.withOpacity(.15),
          highlightColor: Colors.white.withOpacity(.05),
          child: Ink(
            padding: _pad,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [grad1, grad2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: grad2.withOpacity(.35),
                  offset: const Offset(0, 8),
                  blurRadius: 18,
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: _minH),
              child: Stack(
                children: [
                  // larger decorative icon for taller card
                  Positioned(
                    right: -20.w,
                    top: -20.h,
                    child: Icon(
                      Icons.payments_rounded,
                      size: 120.sp, // ⬆️ bigger background icon
                      color: Colors.white.withOpacity(.10),
                    ),
                  ),
                  // content centered vertically for tall layout
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.12),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: Colors.white.withOpacity(.18)),
                        ),
                        child: Icon(leadingIcon, color: onTile, size: 22.sp),
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
                                color: onTile,
                                fontWeight: FontWeight.w800,
                                fontSize: 16.sp, // ⬆️ a touch larger
                                letterSpacing: .2,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              subtitle,
                              maxLines: 2, // allow 2 lines in taller card
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: onTile.withOpacity(.9),
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Icon(Icons.arrow_forward_ios_rounded, size: 18.sp, color: onTile.withOpacity(.9)),
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
