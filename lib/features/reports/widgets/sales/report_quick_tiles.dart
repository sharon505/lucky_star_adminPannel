import 'package:flutter/material.dart';
import 'package:lucky_star_admin/core/theme/color_scheme.dart';

class ReportTileData extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData leadingIcon;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;

  const ReportTileData({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon = Icons.description_outlined,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
  });

  @override
  Widget build(BuildContext context) {
    // Use AppTheme colors directly (not ColorScheme.onSurface etc.)
    final bg  = AppTheme.adminWhite.withOpacity(.06);
    final brd = AppTheme.adminWhite.withOpacity(.10);
    final pill = AppTheme.adminWhite.withOpacity(.08);
    final titleColor = AppTheme.adminWhite;
    final subColor   = AppTheme.adminWhite.withOpacity(.75);
    final chevron    = AppTheme.adminWhite.withOpacity(.6);
    final accent     = AppTheme.adminGreen;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: brd),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: pill,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(leadingIcon, color: accent),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: (subtitle == null)
            ? null
            : Text(
          subtitle!,
          style: TextStyle(color: subColor),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: chevron,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
    );
  }
}
