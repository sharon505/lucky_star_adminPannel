// lib/widgets/title_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/color_scheme.dart';

class TitleCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData leadingIcon;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;

  const TitleCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon = Icons.description_outlined,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(vertical: 5),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.adminGreenLite,
            AppTheme.adminGreenDark,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.adminGreenDark, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.adminGreenDarker,
            blurRadius: 14,
            spreadRadius: 0,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Leading icon badge
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.adminGreenDarker.withOpacity(.55),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.adminGreenDark),
                  ),
                  child: Icon(leadingIcon, color: AppTheme.adminGreen),
                ),
                const SizedBox(width: 12),
                // Title & subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Headline
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.adminWhite,
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
                            letterSpacing: .2,
                          ),
                        ),
                      ),
                      if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppThemeText.subtle,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: AppTheme.adminGreen.withOpacity(.75),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppThemeText {
  static const subtle = TextStyle(
    color: AppTheme.adminWhite,
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    letterSpacing: .2,
  );
}
