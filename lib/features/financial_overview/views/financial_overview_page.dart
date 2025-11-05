import 'package:flutter/material.dart';
import 'package:lucky_star_admin/core/theme/color_scheme.dart';

import '../../../shared/app_gradient_background.dart';

class FinancialOverviewPage extends StatelessWidget {
  const FinancialOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      colors: [
        AppTheme.adminGreenDark,
        AppTheme.adminGreenDark,
      ],
        child: Column(children: [Text("data")]));
  }
}
