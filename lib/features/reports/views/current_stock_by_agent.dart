import 'package:flutter/material.dart';
import 'package:lucky_star_admin/core/theme/color_scheme.dart';

import '../../../core/constants/app_appbar.dart';

class CurrentStockByAgent extends StatelessWidget {
  const CurrentStockByAgent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppbar(text: 'Current Stock By Agent'),
      backgroundColor: AppTheme.adminGreenLite,
    );
  }
}
