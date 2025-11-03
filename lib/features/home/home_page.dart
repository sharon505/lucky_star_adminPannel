import 'package:flutter/material.dart';

import '../../core/theme/color_scheme.dart';
import '../../shared/app_gradient_background.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      colors: AppTheme.gradientOrangePurple,
      child: Center(
        child: Text(""),
      ),
    );
  }
}
