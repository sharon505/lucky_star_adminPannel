import 'package:flutter/material.dart';
import '../core/theme/color_scheme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final Alignment begin;
  final Alignment end;
  final EdgeInsets? padding;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors = AppTheme.gradientOrangeGold,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ?? [Color(0xFF0f2027), Color(0xFF2c5364)],
          begin: begin,
          end: end,
        ),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: child,
      ),
    );
  }
}
